#INCLUDE "SIGAXEDI.CH"
#INCLUDE "FIVEWIN.CH"
//***#INCLUDE "SIGAWIN.CH"

/*���������������������������������������������������������������������������
���Descri��o � Funcoes para utilizacao do EDI.                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���   Data	 � BOPS �Prograd.�                 Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���          �      �        �                                            ���
���������������������������������������������������������������������������*/
/*���������������������������������������������������������������������������
���Fun��o    � SIGAXEDI � Autor � Fabio F. Pessoa       � Data � 18/08/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Contem as funcoes responsaveis pelo EDI.                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
���������������������������������������������������������������������������*/
//***User Function EDILoadT()
Function EDILoadT()
Local   oDlg, oMark
Local   cMarca     := GetMark()          // Utilizado na MSSelect()
Local   cTitle     := OemToAnsi(STR0003) // Geracao dos arquivos para EDI
Local   aCpos      := {}                 // Campos p/ arquivos de trabalho
Local   aPerguntas := {}                 // Perguntas para os filtros de geracao
Local   lInverte   := .F.                // Utilizado na MSSelect()
Local   cArqTrab   := ""                 // Nome do arquivo de trabalho
Local   i          := 0                  // Contador auxiliar
Local   nOpc       := 0                  // Opcao selecionada
Local 	oTblTmp    := {}

Private cSA21      := Space(6)
Private cSA22      := "ZZZZZZ"
Private cSA23      := PadR("SA2" + cNumEmp + ".TXT", 100)
Private cSM01      := Space(FWGETTAMFILIAL)
Private cSM02      := "ZZ"
Private cSM03      := PadR("SM0" + cNumEmp + ".TXT", 100)
Private aCampos    := {}
Private aTabela    := {{OemtoAnsi(STR0001), "SM0", .F., "cSM0", .F., "M0_CODFIL","MATA000 ", NIL     },; // Filiais
                       {OemToAnsi(STR0002), "SA2", .F., "cSA2", .F., "A2_COD"   ,"MATA020 ", "A2_EDI"}}  // Fornecedores

aPerguntas := {{OemToAnsi(STR0006), OemToAnsi(STR0007), OemToAnsi(STR0015)},; // Filial de / Filial ate
		       {OemToAnsi(STR0008), OemToAnsi(STR0009), OemToAnsi(STR0015)}}  // Fornecedor de / Fornecedor ate

//���������������������������������������������������������������������Ŀ
//� Este array  aCampos possui todos os  campos que devem ser gravados  �
//� no arquivo TXT. Dessa forma e' possivel incluir ou retirar campos,  �
//� conforme a necessidade do usuario. Caso todos os campos declarados  �
//� no SX3 devao ser exportados, entao pode-se usar a LoadFields().     �
//�����������������������������������������������������������������������
dbSelectArea("SM0")
aCpos := dbStruct()
For i := 1 To Len(aCpos)

  If aCpos[i][1] <> "M0_SEQUENC" .And. aCpos[i][1] <> "M0_LIBMOD"
     aAdd(aCampos, {"SM0", aCpos[i][1], aCpos[i][2],  aCpos[i][3], aCpos[i][4]})
  EndIf

Next i

aCpos := {}

LoadFields("SA2")

DEFINE MSDIALOG oDlg FROM 180,215 TO 375,500 TITLE cTitle PIXEL OF oMainWnd

  //���������������������������������������������������������Ŀ
  //� Campos do arquivo de trabalho                           �
  //�����������������������������������������������������������
  aCpos := {{"OK"     , "C",  2, 0 },;
            {"TABELA" , "C", 20, 0 }}

  //���������������������������������������������������������Ŀ
  //� Cria o e arquivo de trabalho.                           �
  //�����������������������������������������������������������  
  oTblTmp := LjCrTmpTbl("TRB",aCpos)
  DbSelectArea("TRB")

  For i := 1 To Len(aTabela)
    RecLock("TRB", .T.)
    TRB->OK     := Space(2)
    TRB->TABELA := aTabela[i, 1]
    MsUnlock()
  Next i
  dbGoTop()

  aCpos := {}
  aAdd(aCpos, {"OK"    ,"x"     ,"",""})
  aAdd(aCpos, {"TABELA","Tabela","",""})

  oMark := MsSelect():New("TRB", "OK", , aCpos, @lInverte, @cMarca, {2,1,78,143})
  oMark:oBrowse:lHasMark    := .T.
  oMark:oBrowse:lCanAllmark := .T.

  DEFINE SBUTTON FROM 80,082 TYPE 1 ACTION ( nOpc := 1, oDlg:End() ) ENABLE OF oDlg
  DEFINE SBUTTON FROM 80,113 TYPE 2 ACTION ( nOpc := 0, oDlg:End() ) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTER

If nOpc == 1
   CriaTela(aPerguntas)
EndIf

oTblTmp:Delete()

Return .T.

/*���������������������������������������������������������������������������
���Fun��o    � CriaTela � Autor � Fabio F. Pessoa       � Data � 18/08/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria a tela de filtragem dos arquivos.                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array que contem as tabelas                        ���
���          � ExpA2 = Array que contem as perguntas                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
���������������������������������������������������������������������������*/
Static Function CriaTela(aPerguntas)
Local oDlg
Local i       := 0
Local nLin    := 0
Local nTotSel := 0
Local cTitle  := OemToAnsi(STR0004)      // Parametros para geracao de arquivos - EDI

//��������������������������������������������������������������Ŀ
//� Passa dados do arquivo de trabalho para o Array              �
//����������������������������������������������������������������
TRB->(dbGotop())
For i := 1 To Len(aTabela)

  If !Empty(TRB->Ok)
    aTabela[i,3] := .T.
    nTotSel      := nTotSel + 1
  EndIf
  TRB->(dbSkip())

Next

//���������������������������������������������������������������������Ŀ
//� Existe algum arquivo selecionado ?                                  �
//�����������������������������������������������������������������������
If nTotSel > 0

  DEFINE MSDIALOG oDlg FROM 180,010 TO IIf(nTotSel=2,405,315),260 TITLE cTitle PIXEL OF oMainWnd

    nLin := 6
    @ 01,12 To 45,115 PIXEL

    If aTabela[1,3]

       @ nLin   , 14 SAY aPerguntas[1][1] SIZE 55,08 OF oDlg PIXEL
       @ nLin   , 64 GET cSM01            SIZE 50,10 OF oDlg PIXEL
       @ nLin+12, 14 SAY aPerguntas[1][2] SIZE 55,08 OF oDlg PIXEL
       @ nLin+12, 64 GET cSM02            SIZE 50,10 OF oDlg PIXEL
       @ nLin+24, 14 SAY aPerguntas[1][3] SIZE 55,08 OF oDlg PIXEL
       @ nLin+24, 64 GET cSM03            SIZE 50,10 OF oDlg PIXEL

       If aTabela[2,3]
         nLin := nLin + 46
       EndIf

    EndIf

    If aTabela[2,3]

       If aTabela[1,3]
          @ 47,12 To 91,115 PIXEL
       EndIf

       @ nLin   , 14 SAY aPerguntas[2][1] SIZE 55,08 OF oDlg PIXEL
       @ nLin   , 64 GET cSA21            SIZE 50,10 OF oDlg PIXEL
       @ nLin+12, 14 SAY aPerguntas[2][2] SIZE 55,08 OF oDlg PIXEL
       @ nLin+12, 64 GET cSA22            SIZE 50,10 OF oDlg PIXEL
       @ nLin+24, 14 SAY aPerguntas[2][3] SIZE 55,08 OF oDlg PIXEL
       @ nLin+24, 64 GET cSA23            SIZE 50,10 OF oDlg PIXEL

    EndIf

    DEFINE SBUTTON FROM IIf(nTotSel=2,92,46),54 TYPE 1 ACTION ( GeraTxt(), oDlg:End() ) ENABLE OF oDlg
    DEFINE SBUTTON FROM IIf(nTotSel=2,92,46),85 TYPE 2 ACTION ( oDlg:End())             ENABLE OF oDlg

  ACTIVATE MSDIALOG oDlg CENTER

EndIf

Return .T.


/*���������������������������������������������������������������������������
���Fun��o    �  GeraTxt � Autor � Fabio F. Pessoa       � Data � 18/08/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao responsavel pela geracao do arquivo texto.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array que contem as tabelas                        ���
���          � ExpA2 = Array que contem as perguntas                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
���������������������������������������������������������������������������*/
Static Function GeraTxt()
Local i         := 0
Local j         := 0
Local k         := 1
Local nTotCarac := 0
Local aCpos     := {}
Local lOk       := .T.
Local aArea     := { Alias(), IndexOrd(), Recno() }
Local aCondicao := {}
Local aNomArq   := {}
Local aEMail    := {}
Local cIndex, cCampos, cPotencia, cTemp, cVar, nPosFile
Local cNomeTxt, nPos, cChar, cFim, nU, cTipOp, cTexto, nIndex1

//���������������������������������������������������������������������Ŀ
//� Condicao para filtragem dos arquivos                                �
//�����������������������������������������������������������������������
aAdd(aCondicao,'M0_CODFIL >= "' + cSM01 + '" .And. M0_CODFIL <= "' + cSM02 + '"')                        // Filiais
aAdd(aCondicao,'A2_COD >= "'    + cSA21 + '" .And. A2_COD <= "'    + cSA22 + '" .And. ' + aTabela[2, 8]) // Fornecedores

//���������������������������������������������������������������������Ŀ
//� Nome dos arquivos Txt                                               �
//�����������������������������������������������������������������������
aAdd(aNomArq, cSM03)                   // Filiais
aAdd(aNomArq, cSA23)                   // Fornecedores

//���������������������������������������������������������������������Ŀ
//� Emails dos responsaveis pelos arquivos enviados                     �
//�����������������������������������������������������������������������
aAdd(aEMail, IIf(aTabela[1,3],GetMv("MV_MATA000"),""))     // e-mails dos responsaveis pelo arquivo das Filial
aAdd(aEMail, IIf(aTabela[2,3],GetMv("MV_MATA020"),""))     // e-mails dos responsaveis pelo arquivo de Fornecedores

For i := 1 To Len(aTabela)

   If aTabela[i,3] .And. (IIf(aTabela[i, 8]<>NIL,VldCpoEDI(aTabela[i, 2], aTabela[i, 8], aTabela[i, 1]),.T.))

      cIndex := CriaTrab(NIL, .F.)
      dbSelectArea( aTabela[i, 2] )
      IndRegua(aTabela[i, 2], cIndex, aTabela[i, 6], , aCondicao[i], STR0005 ) //Selecionando registros ...

      If aTabela[i, 2] <> "SM0"

        nIndex1 := RetIndex(aTabela[i, 2])
        #IFNDEF TOP
           dbSetIndex(cIndex + OrdBagExt())
        #ENDIF
        dbSetOrder( nIndex1 + 1 )

      EndIf
      dbGoTop()

      k         := 1
      nTotCarac := 0
      aCpos     := {}
      aAdd(aCpos,"")
	  cCampos  := ""
	  For j := 1 To Len( aCampos )

        If ( aCampos[j,1] == aTabela[i,2] )

          If ( aCampos[j,3] == "N" )

            cPotencia := StrZero( 10 ** aCampos[j, 5], aCampos[j, 5] + 1 )
            cTemp     := "StrZero(" + aCampos[j, 2] + "*" + cPotencia + "," + Str(aCampos[j, 4]) + ", 0)"
            cCampos   := cTemp

          ElseIf ( aCampos[j, 3] == "D" )

            cCampos   := " PadR(DtoS(" + aCampos[j, 2] + ")," + STRZERO( aCampos[j, 4], 3) + ")"

          Else

            cCampos   := " PadR(" + aCampos[j, 2] + "," + STRZERO( aCampos[j, 4], 3) + ")"

          EndIf

          nTotCarac := nTotCarac + aCampos[j, 4]
          If nTotCarac >= 200
            nTotCarac := aCampos[j, 4]
            k         := k + 1
            aAdd(aCpos,"")
          EndIf
          aCpos[k] := AllTrim(aCpos[k]) + IIf(!Empty(aCpos[k]),"+","") + AllTrim(cCampos)

        EndIf

      Next

      cVar     := aTabela[i, 4] + "2"
      cNomeTxt := aNomArq[i]
      cTexto   := aTabela[i, 7] + SM0->M0_CODIGO + SM0->M0_CODFIL + aEMail[i] + Chr(13) + Chr(10)

      If !File(cNomeTxt)

        nHandle := FCreate(cNomeTxt, 0)
        FWrite(nHandle, cTexto)

        If ( nHandle == -1 )
          MsgStop(OemToAnsi(STR0010))  //Nao foi possivel criar o arquivo texto. Operacao cancelada !
          lOk := .F.
        EndIf

      Else

        nHandle := FOpen(cNomeTxt, 2)

        If ( nHandle == -1 )
          MsgStop(OemToAnsi(STR0011))  // Nao foi possivel abrir o arquivo texto. Operacao cancelada !
          lOk := .F.
        EndIf

        If lOk

          nPos    := FSeek(nHandle , 0, 2)
          cChar   := ' '
          cFim    := ''
          nU      := 1
          While .T.

            nPosFile := FSeek( nHandle, nPos - nU )
            cChar := ' '
            FRead( nHandle, @cChar, 1 )
            FSeek( nHandle, nPos - nU )
            cFim := cChar + cFim
            If (Left(cFim, 3) == "FIM" ) .Or. nPosFile = 2
               Exit
            EndIf
            nU := nU + 1

          End
          FWrite(nHandle, cTexto)

        EndIf

      EndIf

      If lOk
        While !( Eof() )

          If !( aTabela[i,5] )
            cTipOp := " I"
          Else
            cTipOp := "HI"
          EndIf

          For k := 1 To Len(aCpos)

            cCampos := aCpos[k]

            If k = 1
              FWrite(nHandle, cTipOp + &cCampos)
            Else
              cCampos := cCampos + IIf(k==Len(aCpos)," + Chr(13)+Chr(10)","")
              FWrite(nHandle, &cCampos)
            EndIf

          Next k
          dbSkip()

        End

        FWrite( nHandle, "FIM" + Chr(13) + Chr(10) )
        FClose( nHandle )

        DelArqTrab(Nil, cIndex)

      EndIf

   EndIf
Next

//���������������������������������������������������������������������Ŀ
//� Restaura a area de trabalho                                         �
//�����������������������������������������������������������������������
dbSelectArea(aArea[1])
dbSetOrder(aArea[2])
dbGoTo(aArea[3])

Return lOk

/*���������������������������������������������������������������������������
���Fun��o    �LoadFields� Autor � Fabio F. Pessoa       � Data �18/07/1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega todos os campos de um determinado Alias            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � LoadFields(ExpC1, ExpA1)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Nome do Alias a ser avaliado                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAXEDI                                                   ���
���������������������������������������������������������������������������*/
Static Function LoadFields(cAlias)
Local aArea := { Alias(), IndexOrd(), Recno() }

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)
While X3_ARQUIVO == cAlias .And. !Eof()

  If x3uso(X3_USADO) .And. AllTrim(X3_CAMPO) <> "A2_EDI"
     aAdd(aCampos, {cAlias, X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL})
  EndIf
  dbSkip()

End

//���������������������������������������������������������������������Ŀ
//� Restaura a area de trabalho                                         �
//�����������������������������������������������������������������������
dbSelectArea(aArea[1])
dbSetOrder(aArea[2])
dbGoTo(aArea[3])

Return .T.

/*���������������������������������������������������������������������������
���Fun��o    � DelArqTrab � Autor � Fabio F. Pessoa     � Data �18/08/1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Deleta arquivos de trabalho                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Nome do alias                                      ���
���          � ExpC2 = Nome do arquivo                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAXEDI                                                   ���
���������������������������������������������������������������������������*/
Static Function DelArqTrab(cAlias, cArqTrab)
Local cFile := cArqTrab + GetDBExtension()

If cAlias <> Nil
	dbSelectArea(cAlias)
	Set Filter To
	dbCloseArea()
	If File(cFile)
		FErase(cFile)
	EndIf
EndIf

If File(cArqTrab + OrdBagExt())
   FErase(cArqTrab + OrdBagExt())
EndIf

Return .T.

/*���������������������������������������������������������������������������
���Fun��o    � VldCpoEDI  � Autor � Fabio F. Pessoa     � Data �18/08/1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se o campo que identifica se o registro faz ou nao  ���
���          � EDI esta criado no SX3.                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Nome do alias                                      ���
���          � ExpC2 = Nome do campo                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAXEDI                                                   ���
���������������������������������������������������������������������������*/
Static Function VldCpoEDI(cAlias, cCampo, cArquivo)
Local aArea := { Alias(), IndexOrd(), Recno() }
Local lRet  := .T.

dbSelectArea("SX3")
dbSetOrder(2)
If !dbSeek(cCampo)

   lRet := .F.
   // Nao sera possivel criar o arquivo texto para o arquivo de <xxxxxs>.
   // O campo <xxxxx> deve ser criado no dicionario de dados
   MsgStop(OemToAnsi(STR0012) + cArquivo + ". " + OemToAnsi(STR0013) + " " + cCampo + " " + OemToAnsi(STR0014))

EndIf
dbSetOrder(1)

//���������������������������������������������������������������������Ŀ
//� Restaura a area de trabalho                                         �
//�����������������������������������������������������������������������
dbSelectArea(aArea[1])
dbSetOrder(aArea[2])
dbGoTo(aArea[3])

Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � EdiA010  � Autor � Fabio F. Pessoa       � Data � 10/09/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manipula a tela de manutencao do cadastro de codigos p/ EDI���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SigaFat e/ou SigaCom                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function EDIA010()

Private cCadastro := OemtoAnsi(STR0016)	                               // Cadastro de codigos para o EDI
PRIVATE aRotina   := { { OemToAnsi(STR0017), "AxPesqui", 0 , 1},;      // Pesquisar
                       { OemToAnsi(STR0029), "A010Det1", 0 , 2},;      // Visualizar
                       { OemToAnsi(STR0018), "A010Det1", 0 , 3} }      // Detalhar

mBrowse( 6, 1,22,75,"SAM")

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � A010Det1 � Autor � Fabio F. Pessoa       � Data � 08/09/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Disponibiliza a escolha de qual Alias o usuario pretende   ���
���          � incluir os codigos de compatibilizacao para o EDI.         ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SigaxEDI                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A010Det1(cAlias, nReg, nOpcx)
Local oDlg, oComb1, oComb2, cComb1, cComb2, cOpcComb2
Local nTotAlias := Len(cFOpened)
Local i         := 1
Local nOpcA     := 0
Local aComb1    := {}
Local aComb2    := {}

dbSelectArea("SX2")
dbSetOrder(1)
While i <= nTotAlias

  If dbSeek(Substr(cFOpened, i, 3)) .And. Substr(cFOpened, i, 3) <> "SX5"
     AAdd(aComb1, FWX2CHAVE() + " - " + FWX2Nome( FWX2CHAVE() ))

     If SAM->AM_ARQUIVO == FWX2CHAVE()
        cComb1 := aComb1[Len(aComb1)]
     EndIf

  EndIf
  i := i + 3

EndDo

aComb1 := aSort(aComb1)
AAdd(aComb2, OemToAnsi(STR0019))     // Cliente    - Fornecedor"
AAdd(aComb2, OemToAnsi(STR0020))     // Fornecedor - Cliente

DEFINE MSDIALOG oDlg FROM 80,1 TO 202,315 TITLE cCadastro PIXEL OF GetWndDefault()

  @ .1,.5 To 3, 19
  @ 10,10 SAY OemToAnsi(STR0021)                    SIZE  45,08 OF oDlg PIXEL  // Arquivo
  @ 10,36 MSCOMBOBOX oComb1 VAR cComb1 ITEMS aComb1 SIZE 110,50 OF oDlg PIXEL

  @ 23,10 SAY OemToAnsi(STR0022)                    SIZE  45,08 OF oDlg PIXEL  // Sentido
  @ 23,36 MSCOMBOBOX oComb2 VAR cComb2 ITEMS aComb2 SIZE 110,50 OF oDlg PIXEL

  DEFINE SBUTTON FROM 45, 96 TYPE 1 ACTION (nOpcA:=1, cOpcComb2 := Str(oComb2:nAt,1,0), oDlg:End()) ENABLE OF oDlg
  DEFINE SBUTTON FROM 45,125 TYPE 2 ACTION (nOpcA:=0, oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTER

If nOpcA == 1
   A010Det2(cComb1, cComb2, cOpcComb2, nOpcx)
EndIf

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � A010Det2 � Autor � Fabio F. Pessoa       � Data � 08/09/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processa a manutencao dos detalhes dos codigos pertencentes���
���          � a um Alias.                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� sExp1 : Conteudo do ComboBox que indica o Alias escolhido. ���
���          � sExp2 : Conteudo do ComoboBox que indica qual o sentido.   ���
���          � sExp3 : Qual o sentido escolhido.                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SigaxEDI                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function A010Det2(cComb1, cComb2, cSentido, nOpcx)
Local oDlg, oComb1, oComb2, oGet, cTitulo
Local nOpcA     := 0
Local aComb1    := {}
Local aComb2    := {}
Local cAlias    := Substr(cComb1, 1, 3)
Local lExist    := .F.

//���������������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                                 �
//�����������������������������������������������������������������������
Private aTELA[0][0], aGETS[0], aHeader[0], nUsado := 0
Private aOriginal := {}

dbSelectArea("SAM")
dbSetOrder(1)
lExist := dbSeek(xFilial("SAM") + cSentido + cAlias)

dbSelectArea("SX3")
dbSeek("SAM")
While !Eof() .And. (X3_ARQUIVO == "SAM")

  If X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. !(X3_CAMPO $ "AM_SENTIDO/AM_ARQUIVO")

    nUsado++

    If X3_CAMPO == "AM_CODSENT"
      cTitulo := IIf(cSentido=="1", OemToAnsi(STR0024), OemToAnsi(STR0023))   //Cod. Cliente / Cod. Fornecedor
    Else
      cTitulo := TRIM(X3_TITULO)
    EndIf

	AAdd(aHeader,{ cTitulo   , X3_CAMPO  , X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID,;
                   X3_USADO  , X3_TIPO   , X3_ARQUIVO, X3_CONTEXT } )
  EndIf
  dbSkip()

End

If lExist
  Private aCOLS := {}
Else
  Private aCOLS[1][nUsado+1]
EndIf

//���������������������������������������������������������������������Ŀ
//� Inicializa o aCols para a GetDados                                  �
//�����������������������������������������������������������������������
A010IaCols(cAlias, cSentido, lExist)

AAdd(aComb1, cComb1)
AAdd(aComb2, cComb2)

DEFINE MSDIALOG oDlg FROM 80,1 TO 422,620 TITLE cCadastro PIXEL OF GetWndDefault()

  @ .1,.5 To 2, 38
  @ 10, 10 SAY OemToAnsi(STR0006)                    SIZE  45,08          OF oDlg PIXEL //Arquivo
  @ 10, 45 MSCOMBOBOX oComb1 VAR cComb1 ITEMS aComb1 SIZE 100,50 When .F. OF oDlg PIXEL

  @ 10,160 SAY OemToAnsi(STR0007)                    SIZE  45,08          OF oDlg PIXEL //Sentido
  @ 10,195 MSCOMBOBOX oComb2 VAR cComb2 ITEMS aComb2 SIZE 100,50 When .F. OF oDlg PIXEL

  oGet := MSGetDados():New(31,04,145,304,nOpcx,"A010LOk","A010TOk","",.T.,,,,200)
  oGet:nOpc := 3

  DEFINE SBUTTON FROM 150,248 TYPE 1 ACTION (nOpcA:=1, A010Grava(cAlias, cSentido), oDlg:End()) ENABLE OF oDlg
  DEFINE SBUTTON FROM 150,277 TYPE 2 ACTION (nOpcA:=0, oDlg:End())                              ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTER

Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �A010IaCols� Autor � Fabio F. Pessoa       � Data � 13/09/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializa o aCols para a GetDados                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� sExp1 : Alias selecionado.                                 ���
���          � sExp2 : Sentido selecionado.                               ���
���          � lExp3 : Existe este Alias c/ este sentido na base ?        ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SigaxEDI                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function A010IaCols(cAlias, cSentido, lExist)
Local nCnt := 0
Local i, nTotCpo

If lExist

  dbSelectArea("SAM")
  dbsetOrder(1)
  dbSeek(xFilial("SAM") + cSentido + cAlias)
  While !Eof() .And. (xFilial("SAM") + cSentido + cAlias) == (AM_FILIAL + AM_SENTIDO +  AM_ARQUIVO)

    nCnt++
    AADD(aCols, Array(nUsado+1))

    nTotCpo := Len(aCols)
    For i := 1 To nUsado

      If aHeader[i, 10] <> "V"                           // E campo virtual ?
        aCols[nTotCpo, i]        := FieldGet( FieldPos(aHeader[i, 2]) )
        aCOLS[nTotCpo, nUsado+1] := .F.
      EndIf

    Next
    dbSkip()

  EndDo

Else

  nUsado := 0
  dbSelectArea("SX3")
  dbSeek( "SAM" )
  While !Eof() .And. X3_ARQUIVO == "SAM"

    If x3Uso(X3_USADO) .And. cNivel >= X3_NIVEL .And. !(X3_CAMPO $ "AM_SENTIDO/AM_ARQUIVO")

      nUsado++
      //���������������������������Ŀ
      //� Monta Array de 1 elemento �
      //� vazio. Se inclus�o.       �
      //�����������������������������
      If X3_TIPO == "C"
        aCOLS[1][nUsado] := Space(X3_TAMANHO)
      ElseIf X3_TIPO == "N"
        aCOLS[1][nUsado] := 0
      ElseIf X3_TIPO == "D"
        aCOLS[1][nUsado] := dDataBase
      Else
        aCOLS[1][nUsado] := .F.
      EndIf

    EndIf
    dbSkip()

  End
  aCOLS[1][nUsado+1] := .F.

EndIf

//���������������������������������������������������������������������Ŀ
//� Armazena o array original para consistencias no decorrer da operacao�
//�����������������������������������������������������������������������
aOriginal := aClone(aCols)
Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � A010Grava� Autor � Fabio F. Pessoa       � Data � 15/09/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua a gravacao dos codigos de compatibilidade para o EDI ��
�������������������������������������������������������������������������Ĵ��
���Parametros� sExp1 : Alias selecionado.                                 ���
���          � sExp2 : Sentido selecionado.                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SigaxEDI                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function A010Grava(cAlias, cSentido)
Local i, lExist
Local nPosCodSen, nPosChaveO, nPosChaveD

nPosCodSen := Ascan(aHeader, {|x|AllTrim(x[2])=='AM_CODSENT'})
nPosChaveO := Ascan(aHeader, {|x|AllTrim(x[2])=='AM_CHAVEO' })
nPosChaveD := Ascan(aHeader, {|x|AllTrim(x[2])=='AM_CHAVED' })

dbSelectArea("SAM")
dbSetOrder(1)

For i := 1 To Len(aCols)

  If !aCols[i, nUsado+1]
    aCols[i, nPosCodSen] := aCols[i, nPosCodSen] + Replicate(" ",TamSx3("AM_CODSENT")[1] - Len(aCols[i, nPosCodSen]))

    //���������������������������������������������������������������������Ŀ
    //� Alteracao / Delecao / Inclusao                                      �
    //�����������������������������������������������������������������������
    lExist := dbSeek( xFilial("SAM") + cSentido + cAlias + aCols[i, nPosCodSen] + aCols[i, nPosChaveO])

    RecLock("SAM", !lExist)
    If lExist

      //���������������������������������������������������������������������Ŀ
      //� Se esta deletado no aCols e existe na Base, entao deleta na Base.   �
      //�����������������������������������������������������������������������
      If aCols[i, nUsado+1]

        dbDelete()
        WriteSx2("SAM")

      Else

        Replace AM_CHAVED With aCols[i, nPosChaveD]

      EndIf

    Else

      Replace AM_FILIAL  With xFilial("SAM")
      Replace AM_SENTIDO With cSentido
      Replace AM_ARQUIVO With cAlias
      Replace AM_CODSENT With aCols[i, nPosCodSen]
      Replace AM_CHAVEO  With aCols[i, nPosChaveO]
      Replace AM_CHAVED  With aCols[i, nPosChaveD]

    EndIf
    MsUnlock()

  EndIf

Next i

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � A010LOk  � Autor � Fabio F. Pessoa       � Data � 14/09/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a linha da MSGetDados.                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SigaxEDI                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A010LOk()
Local lRet := .T.
Local nPosChaveO

nPosChaveO := Ascan(aHeader, {|x|AllTrim(x[2])== 'AM_CHAVEO'})

If n <= Len(aOriginal) .And. Len(aOriginal) >= 1

  lRet := !(aCols[n, nPosChaveO] <> aOriginal[n, nPosChaveO] .And. !aCols[n, nUsado+1])

  If !lRet

    aCols[n, nPosChaveO] := aOriginal[n, nPosChaveO]

    // A coluna 'Chave Origem' nao pode ser alterada,
    // o item deve ser deletado e inserido novamente.
    // Atencao
    MsgStop(OemtoAnsi(STR0025) + OemToAnsi(STR0026), OemToAnsi(STR0027))

  EndIf

EndIf

If lRet
  lRet := A010TOk()
EndIf

Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � A010TOk  � Autor � Fabio F. Pessoa       � Data � 14/09/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a linha da MSGetDados.                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SigaxEDI                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A010TOk()
Local i, j, nAux, nPosCodSen, nPosChaveO
Local lRet := .T.

nPosCodSen := Ascan(aHeader, {|x|AllTrim(x[2])=='AM_CODSENT'})
nPosChaveO := Ascan(aHeader, {|x|AllTrim(x[2])=='AM_CHAVEO' })

For i := 1 To Len(aCols)

  If !aCols[i, nUsado+1]

    nAux := 0
    For j := 1 To Len(aCols)

      If !aCols[j, nUsado+1] .And. (aCols[j, nPosCodSen] + aCols[j, nPosChaveO]) == (aCols[i, nPosCodSen] + aCols[i, nPosChaveO])
        nAux ++
      EndIf

    Next j

    lRet := !(nAux >= 2)
    If !lRet
      Exit
    EndIf

  EndIf

Next i

If !lRet
    // Existem itens duplicados. / Atencao
    MsgStop(OemtoAnsi(STR0028), OemToAnsi(STR0012))
EndIf

Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �CriaTxtEdi� Autor � Fabio F. Pessoa       � Data � 01/09/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria um arquivo Txt no padrao estabelecido pelo EDI.       ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nExp1 : Retorna o Handle do arquivo criado                 ���
���          � sExp2 : String com o nome da funcao que sera acionada pelo ���
���          �         SigaAuto.                                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CriaTxtEDI(cFunc)
Local nPosFile, cNomeTxt, nPos, cChar, cFim, nU, cTexto

cNomeTxt := "SIGAAUTO.TXT"
cTexto   := PadR(cFunc, 8) + SM0->M0_CODIGO + SM0->M0_CODFIL + GetMv("MV_"+cFunc) + Chr(13) + Chr(10)

If !File(cNomeTxt)

   nHandle := FCreate(cNomeTxt, 0)
   FWrite(nHandle, cTexto)

Else

   nHandle := FOpen(cNomeTxt, 2)
   If nHandle >= 0

      nPos    := FSeek(nHandle , 0, 2)
      cChar   := ' '
      cFim    := ''
      nU      := 1
      While .T.

         nPosFile := FSeek( nHandle, nPos - nU )
         cChar := ' '
         FRead( nHandle, @cChar, 1 )
         FSeek( nHandle, nPos - nU )
         cFim := cChar + cFim
         If (Left(cFim, 3) == "FIM" ) .Or. nPosFile = 2
            Exit
         EndIf
         nU := nU + 1

       End
       FWrite(nHandle, cTexto)

   EndIf

EndIf

Return nHandle


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �EDI_RetCod� Autor � Fabio F. Pessoa       � Data � 08/09/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a chave correspondente, de um determinado alias,   ���
���          � no destino da informacao.                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� sExp1 : Chave correspondente da informacao no seu destino  ���
���          � sExp2 : Qual o sentido da operacao:                        ���
���          �         1 - Do Cliente para o Fornecedor                   ���
���          �         2 - Do Fornecedor para o Cliente                   ���
���          � sExp3 : Alias que se deseja enviar o codigo                ���
���          � sExp4 : Indica o codigo do sentido, ou seja, o codigo do   ���
���          �         Fornecedor /Cliente a ser tratado                  ���
���          � sExp5 : Chave da origem da informacao que deve ser         ���
���          �         procurada.                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function EDI_RetCod(cSentido, cAlias, cCodSentido, cChaveO)
Local aArea   := { Alias(), IndexOrd(), Recno() }
Local cChaveD := "NOT FOUND"

dbSelectArea("SAM")
dbSetOrder(1)

cCodSentido := cCodSentido + Replicate(" ",TamSx3("AM_CODSENT")[1] - Len(cCodSentido))

If dbSeek(xFilial("SAM") + cSentido + cAlias + cCodSentido + cChaveO, .T.)
  cChaveD := SAM->AM_CHAVED
EndIf

//���������������������������������������������������������������������Ŀ
//� Restaura a area de trabalho                                         �
//�����������������������������������������������������������������������
dbSelectArea(aArea[1])
dbSetOrder(aArea[2])
dbGoTo(aArea[3])

Return cChaveD