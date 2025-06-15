#INCLUDE 'Dlga220.ch'
#INCLUDE "FIVEWIN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � DLGA220  � Autor � Alex Egydio           � Data � 26.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ordem de Servico do W.M.S.                                 ���
���          � Disparar servicos que nao estao relacionados a um movimento���
���          � interno(SD3), nem a uma NFE(SD1), nem a uma NF(SD2).       ���
���          � Ex: Preciso fazer um abastecimento ou montagem de kit sem  ���
���          � um vinculo com o cliente.                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �DLGA220(Void)                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Generico                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function DLGA220()

Local aCores := { {"!Empty(DCF_SERVIC).And.(Empty(DCF_STSERV).Or.DCF_STSERV=='1')",'ENABLE'},;//-- O.S. Nao Executada
               {"!Empty(DCF_SERVIC).And.DCF_STSERV=='2'",'BR_AMARELO'},;//-- O.S. Interrompida
               {"!Empty(DCF_SERVIC).And.DCF_STSERV=='3'",'DISABLE'},;//-- O.S. Executada
               {"!Empty(DCF_SERVIC).And.DCF_STSERV=='4'",'BR_AZUL'},;//-- O.S. Em Conferencia
               {"Empty(DCF_SERVIC)",'BR_PRETO'}} //-- O.S. Sem Servico
If SuperGetMv("MV_WMSNEW",.F.,.F.)
	Return WMSA221()
EndIf

//���������������������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa                   �
//� ----------- Elementos contidos por dimens�o ------------                  �
//� 1. Nome a aparecer no cabe�alho                                           �
//� 2. Nome da Rotina associada                                               �
//� 3. Usado pela rotina                                                      �
//� 4. Tipo de Transa��o a ser efetuada                                       �
//�    1 - Pesquisa e Posiciona em um Banco de Dados                          �
//�    2 - Simplesmente Mostra os Campos                                      �
//�    3 - Inclui registros no Bancos de Dados                                �
//�    4 - Altera o registro corrente                                         �
//�    5 - Remove o registro corrente do Banco de Dados                       �
//�����������������������������������������������������������������������������
Private aRotina := MenuDef()

//���������������������������������������������������������������������������Ŀ
//� Define o cabe�alho da tela de atualiza��es                                �
//�����������������������������������������������������������������������������
Private cCadastro := OemToAnsi(STR0007) //'Ordem de Servico'

If AMiIn(39,42) //-- Somente autorizado para OMS e WMS.
   dbSelectArea('DCF')
   dbSetOrder(1)
   mBrowse(06, 01, 22, 75, 'DCF',,,,,,aCores)
   RetIndex('DCF')
EndIf
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �DLA220Manut� Autor � Alex Egydio          � Data � 29.12.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao no Cadastro de Ordem de Servico                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � DLA220Manut(ExpC1,ExpN1,ExpN2)                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function DLA220Manut( cAlias, nReg, nOpcX )
Local cCadAnt    := ''
Local aRotAnt    := {}
Local lRet       := .T.
Local nPos       := 0
Local cServico   := CriaVar('DCF_SERVIC')
Local oDlg
Local laRotPesq  := (nOpcx==1) //-- Pesquisa
Local laRotVisu  := (nOpcx==2) //-- Visualiza
Local laRotIncl  := (nOpcx==3) //-- Inclui
Local laRotAlte  := (nOpcx==4) //-- Altera
Local laRotExcl  := (nOpcx==5) //-- Exclui
Local laRotAtri  := (nOpcx==6) //-- Atribui Servico
Local lAltServ   := .F.

Private aAlter     := {}
Private aAcho      := {}
Private aTela[0][0]
Private aGets[0]
Private cDelFunc   := 'DLA220VDel()'
Private cOkFunc    := 'DLA220VlOk()'
Private lDelFunc   := .T.
//-- Define o arotina caso a funcao dla220manut seja executada de outro programa
If Type('aRotina')=='A'
   aRotAnt := AClone(aRotina)
EndIf
aRotina := {   {STR0001, 'AxPesqui'   ,0 ,1},; //'&Pesquisar' 1
            {STR0002, 'AxVisual'   ,0 ,2},; //'&Visualizar' 2
            {STR0003, 'DLA220Manut',0 ,3},; //'&Incluir' 3
            {STR0004, 'DLA220Manut',0 ,4},; //'&Alterar' 4
            {STR0005, 'DLA220Manut',0 ,5},; //'&Excluir' 5
            {STR0015, 'DLA220Manut',0 ,4},; //'At&ribuir Servico' 5
            {STR0006, 'DLA220Legen',0,3,0}} //'&Legenda' 7
//-- Define o ccadastro caso a funcao dla220manut seja executada de outro programa
If Type('cCadastro')=='C'
   cCadAnt := cCadastro
EndIf
cCadastro := OemToAnsi(STR0007) //'Ordem de Servico'
//-- .T. = Deleta automaticamente, .F. = Deleta atraves do axdelete
If Type('l150DelAut')!='L'
   l150DelAut := .F.
EndIf
//��������������������������������������������������������������Ŀ
//� Verificar data do ultimo fechamento em SX6.                  �
//����������������������������������������������������������������
If If(FindFunction('MVUlmes'),MVUlmes(),SuperGetMV('MV_ULMES',.F.,'14990101')) >= dDataBase
   Help (' ', 1, 'FECHTO')
   If !Empty(aRotAnt)
      aRotina := AClone(aRotAnt)
   EndIf
   If !Empty(cCadAnt)
      cCadastro := cCadAnt
   EndIf
   Return Nil
EndIf

If laRotIncl .Or. laRotAlte
   //��������������������������������������������������������������Ŀ
   //� Ativa tecla F4 para comunicacao com Saldos dos Lotes         �
   //����������������������������������������������������������������
   Set Key VK_F4 TO AvalF4()

   DLA220Cpos(aAcho)
   //���������������������������������������������������������������������������Ŀ
   //� Cria o array aAlter com base no array aAcho                               �
   //�����������������������������������������������������������������������������
   aAlter := aClone(aAcho)
   //���������������������������������������������������������������������������Ŀ
   //� Deleta do Array aAlter os campos que NAO devem ser editaveis              �
   //�����������������������������������������������������������������������������
   If (nPos :=aScan(aAlter,{|x| 'DCF_CLIFOR' $ Upper(x)})) > 0
      aDel(aAlter, nPos); aSize(aAlter, Len(aAlter)-1)
   EndIf
   If (nPos :=aScan(aAlter,{|x| 'DCF_LOJA' $ Upper(x)})) > 0
      aDel(aAlter, nPos); aSize(aAlter, Len(aAlter)-1)
   EndIf
EndIf

If laRotIncl
   AxInclui(Alias(), Recno(), nOpcX, aAcho,, aAlter,cOkFunc,,'DLA220Atu()')
ElseIf laRotAlte
   If !(DCF->DCF_STSERV=='1')
      Aviso('DLGA22001',STR0019,{'Ok'})//'Somente Ordens de Servico NAO EXECUTADAS poder ser alteradas'
      lRet := .F.
   Else
      AxAltera(Alias(), Recno(), nOpcX, aAcho, aAlter,,, cOkFunc)
   EndIf
ElseIf laRotExcl
   //-- Deleta automaticamente
   If l150DelAut
      RecLock(Alias(),.F.,.T.)
      dbDelete()
      MsUnLock()
   Else
      AxDeleta(Alias(), Recno(), nOpcX)
   EndIf
ElseIf laRotAtri

   lAltServ := .F.
   If !Empty(DCF_SERVIC)
      If !(DCF_STSERV=='1')
         Aviso("DLGA22002", STR0028, {"Ok"}) //"Esta O.S. precisa ser Estornada para que seu servico seja alterado"
      Else
         lAltServ := (Aviso("DLGA22002", STR0029+DCF_SERVIC+STR0030, {STR0010, STR0009})==1) //"Esta O.S. ja possui o servico "###" atribuido. Deseja alterar este servico?"###"Sim"###"Nao"
      EndIf
   EndIf

   If Empty(DCF_SERVIC) .Or. lAltServ
      If ConPad1(,,, 'DC5',,, .F.)
         DLA220Clas(DC5->DC5_SERVIC, !lAltServ)
         If lAltServ
            DLA150Stat('1', DC5->DC5_SERVIC)
         EndIf
      EndIf
   EndIf

EndIf

If laRotIncl .Or. laRotAlte
   //��������������������������������������������������������������Ŀ
   //� Desativa tecla F4 para comunicacao com Saldos dos Lotes      �
   //����������������������������������������������������������������
   Set Key VK_F4 TO
EndIf
If !Empty(aRotAnt)
   aRotina := AClone(aRotAnt)
EndIf
If !Empty(cCadAnt)
   cCadastro := cCadAnt
EndIf
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � DLA220Cpos � Autor �Fernando Joly/Eduardo� Data �03.09.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria um Array com os Campos do DCF                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � DLA220Cpos(ExpA1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array com os campos do DCF                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � DLGA220                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function DLA220Cpos(aAcho)
Local cNoFields  := "DCF_FILIAL|DCF_OK|DCF_STSERV|DCF_ORIGEM|DCF_NUMSEQ|DCF_STRADI|DCF_ID|DCF_SEQUEN"
Local oStructDCF := FWFormStruct(2,"DCF",{|x| !(AllTrim(x) $ cNoFields)})
Local aFields    := oStructDCF:aFields
Local nI         := 1

	For nI := 1 To Len(aFields)
		aAdd(aAcho, aFields[nI,1])
	Next nI

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � DLA220Atu  � Autor �Fernando Joly/Eduardo� Data �03.09.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava os campos que nao aparecem na Tela                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � DLA220Atu()                                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � DLGA220                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function DLA220Atu()
Local cNumSeq := ProxNum()
Local cIdDCF  := ProxNum()
RecLock('DCF', .F.)
Replace DCF_FILIAL With xFilial('DCF')
Replace DCF_STSERV With '1'
Replace DCF_ORIGEM With 'DCF'
Replace DCF_NUMSEQ With cNumSeq
Replace DCF_STRADI With '0'
Replace DCF_ID     With cIdDCF
MsUnlock()

Return Nil

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �DLA220VlOk� Autor � VICCO                 � Data �28/01/2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a gravacao                                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function DLA220VlOk()
Local lRet   := .T.
Local lRetPE := .T.
//- PE na confirmacao (antes da  gravacao)
If ExistBlock("DLGA220INC")
   lRetPE := ExecBlock("DLGA220INC",.F.,.F.)
   If ValType(lRetPE)=='L'
      lRet := lRetPE
   EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � DLA220VDel � Autor �Fernando Joly/Eduardo� Data �04.09.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a Delecao                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � DLA220VDel()                                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � DLGA220                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function DLA220VDel()
Local lRet := .F.

If !(DCF->DCF_STSERV=='1')
   Aviso('DLGA22003', STR0027, {'OK'}) //'Somente Ordens de Servico NAO EXECUTADAS podem ser excluidas'
Else
   lRet := (Aviso('SIGAWMS',STR0011,{STR0010,STR0009})==1)//'Confirma a Exclusao da Ordem de Servico?'#'Sim'#'Nao'
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �DLA220Legen�Autor � Fernando Joly Siquini � Data �04.09.2001 ���
��������������������������������������������������������������������������Ĵ��
���          �Demonstra a legenda das cores da mbrowse                     ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina monta uma dialog com a descricao das cores da    ���
���          �Mbrowse.                                                     ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function DLA220Legen()
BrwLegenda(cCadastro,STR0006,{   {'ENABLE',    STR0012},; //'Legenda'#'O.S. Nao Executada'
                        {'BR_AMARELO',STR0013},; //'O.S. Interrompida'
                        {'DISABLE',   STR0014},; //'O.S. Executada'
                        {'BR_AZUL',   STR0031},; //'O.S. Em Conferencia'
                        {'BR_PRETO',  STR0018}}) //'O.S. sem atribuicao de Servico'
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Dla220Vld� Autor � Alex Egydio           � Data �10.04.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida digitacao                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � DlgA150                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function DLA220Vld()
Local lRet  := .T.
Local cCampo:= ReadVar()

If cCampo == "M->DCF_SERVIC"
   lRet := ExistCpo("DC5",M->DCF_SERVIC)
ElseIf cCampo == "M->DCF_CODPRO"
   lRet := ExistCpo("SB1",M->DCF_CODPRO)
ElseIf cCampo == "M->DCF_CLIFOR"
   lRet := ExistCpo("SA1",M->DCF_CLIFOR)
ElseIf cCampo == "M->DCF_REGRA"
   If M->DCF_REGRA=="1"
      If Empty(M->DCF_LOTECT)
         lRet:=.F.
         Help(' ', 1, 'DLGA220H01')
      Else
         M->DCF_DATA  := CtoD("")
         M->DCF_SERIE := Space(SerieNfId("DCF",6,"DCF_SERIE"))
      EndIf
   ElseIf   M->DCF_REGRA=="2"
      If Empty(M->DCF_SERIE)
         lRet:=.F.
         Help(' ', 1, 'DLGA220H02')
      Else
         M->DCF_DATA   := CtoD("")
         M->DCF_LOTECT := Space(TamSX3("DCF_LOTECT")[1])
      EndIf
   ElseIf   M->DCF_REGRA=="3"
      If Empty(M->DCF_DATA)
         lRet:=.F.
         Help(' ', 1, 'DLGA220H03')
      Else
         M->DCF_SERIE  := Space(SerieNfId("DCF",6,"DCF_SERIE"))
         M->DCF_LOTECT := Space(TamSX3("DCF_LOTECT")[1])
      EndIf
   EndIf
EndIf
If lRet .And. !Empty(M->DCF_CODPRO) .And. !Empty(M->DCF_CLIFOR)
   lRet := ExistChav("DCF",M->DCF_SERVIC+M->DCF_CODPRO+M->DCF_CLIFOR)
EndIf
Return( lRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AVALF4   � Autor � Fernando Joly Siquini � Data � 10/10/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada da funcao F4                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � DLGA220                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function AvalF4()
If Upper(ReadVar()) $ 'M->DCF_NUMLOT/M->DCF_LOTECT'
   F4Lote(,,,'DLA220',M->DCF_CODPRO,M->DCF_LOCAL)
ElseIf Upper(ReadVar()) $ 'M->DCF_ENDER/M->DCF_ENDEST'
   F4Localiz(,,,'DLA220',M->DCF_CODPRO,If(Upper(ReadVar())=='M->DCF_ENDER',M->DCF_LOCAL,M->DCF_LOCDES),M->DCF_QUANT,ReadVar())
EndIf
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �DLA220Clas� Autor � Fernando Joly Siquini � Data � 10/10/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao Servico Atribuido no DCF                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � DLGA220                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function DLA220Clas(cServico, lGravaOrig)
Local lRet := .T.

Begin Transaction
RecLock('DCF', .F.)
Replace DCF_SERVIC With cServico
Replace DCF_STSERV With '1'
If lGravaOrig
   Replace DCF_ORIGEM With 'DCF'
EndIf
MsUnlock()
End Transaction

Return lRet

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �26/10/2006���
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
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
PRIVATE aRotina   := {  {STR0001, 'AxPesqui'   ,0 ,1, 0, .F.},; //'&Pesquisar' 1
                  {STR0002, 'AxVisual'   ,0 ,2, 0, nil},; //'&Visualizar' 2
                  {STR0003, 'DLA220Manut',0 ,3, 0, nil},; //'&Incluir' 3
                  {STR0004, 'DLA220Manut',0 ,4, 0, nil},; //'&Alterar' 4
                  {STR0005, 'DLA220Manut',0 ,5, 0, nil},; //'&Excluir' 5
                  {STR0015, 'DLA220Manut',0 ,4, 0, nil},; //'At&ribuir Servico' 5
                  {STR0006, 'DLA220Legen',0 ,3, 0, .F.} } //'&Legenda' 7

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
//��������������������������������������������������������������������������
If ExistBlock("DLG220MNU")
   ExecBlock("DLG220MNU",.F.,.F.)
EndIf
Return(aRotina)
