
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR010 � Autor � Eduardo Motta          � Data � 24.05.01 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Relatorio de Questionario                                  ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR010()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial                               ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
//��������������������������������������������������������������������������Ŀ
//� Associa arquivo de definicoes                                            �
//����������������������������������������������������������������������������
#include "PLSMGER.CH"
//��������������������������������������������������������������������������Ŀ
//� Define nome da funcao                                                    �
//����������������������������������������������������������������������������
Function PLSR010()
//��������������������������������������������������������������������������Ŀ
//� Define variaveis padroes para todos os relatorios...                     �
//����������������������������������������������������������������������������
PRIVATE nQtdLin     := 58
PRIVATE cNomeProg   := "PLSR010"
PRIVATE nLimite     := 132
PRIVATE cTamanho    := "M"
PRIVATE cTitulo     := "Questionario"
PRIVATE cDesc1      := "Questionario"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BAM"
PRIVATE cPerg       := "PLR010"
PRIVATE nRel        := "PLSR010"
PRIVATE nLi         := nQtdLin+1
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := "Questionario : "
PRIVATE cCabec2     := "PERGUNTAS"
//��������������������������������������������������������������������������Ŀ
//� Parametros do relatorio (SX1)...                                         �
//����������������������������������������������������������������������������
PRIVATE nModelo
PRIVATE cMotBloDe
PRIVATE cMotBloAte
PRIVATE dDatBloDe
PRIVATE dDatBloAte
//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint                                                           �
//����������������������������������������������������������������������������
nRel := SetPrint(cAlias,nRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
//��������������������������������������������������������������������������Ŀ
//� Verifica se foi cancelada a operacao                                     �
//����������������������������������������������������������������������������
If nLastKey  == 27
   Return
Endif
//��������������������������������������������������������������������������Ŀ
//� Acessa parametros do relatorio...                                        �
//����������������������������������������������������������������������������
Pergunte(cPerg,.F.)

cPropri       := Str(mv_par02,1)
cQuestionario := mv_par01

If !ExistCpo("BAM",cPropri+cQuestionario)
   Return
EndIf

BAM->(DbSeek(xFilial("BAM")+cPropri+cQuestionario))


cCabec1 := "Questionario : "+cQuestionario+" "+BAM->BAM_DESCRI

//��������������������������������������������������������������������������Ŀ
//� Configura impressora                                                     �
//����������������������������������������������������������������������������
SetDefault(aReturn,cAlias)
//��������������������������������������������������������������������������Ŀ
//� Emite relat�rio                                                          �
//����������������������������������������������������������������������������
MsAguarde({|| R010Imp() }, cTitulo, "", .T.)

Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R010Imp  � Autor � Eduardo Motta         � Data � 24.05.01 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Emite relatorio de questionario...                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function R010Imp()
Local aResp := {}
Local nCont := 0
Local nI    := 0
Local cDesCom
Local cDesPer1
Local cDesPer2
//��������������������������������������������������������������������������Ŀ
//� Imprime cabecalho do relatorio...                                        �
//����������������������������������������������������������������������������
R010Pag(.T.)

BAJ->(DbSeek(xFilial("BAJ")+BAM->BAM_PROPRI+BAM->BAM_CODQUE))

While ! BAJ->(Eof()) .and. xFilial("BAJ") = BAJ->BAJ_FILIAL .and. BAM->BAM_PROPRI == BAJ->BAJ_PROQUE .and. BAM->BAM_CODQUE == BAJ->BAJ_CODQUE
      //��������������������������������������������������������������������Ŀ
      //� Verifica se foi abortada a impressao...                            �
      //����������������������������������������������������������������������
      If Interrupcao(lAbortPrint)
         @ ++nLi, 00 pSay PLSTR0002
         Exit
      Endif
      aResp := {}      
      if BAJ->BAJ_TIPRES == "2"  // resposta sugerida
         BAK->(DbSeek(xFilial()+BAJ->BAJ_PROQUE+BAJ->BAJ_CODQUE+BAJ->BAJ_CODPER))
         While ! BAK->(Eof()) .and. xFilial("BAK") = BAK->BAK_FILIAL .and. BAJ->BAJ_PROQUE == BAK->BAK_PROQUE .AND. BAJ->BAJ_CODQUE == BAK->BAK_CODQUE .and. BAJ->BAJ_CODPER == BAK->BAK_CODPER
            aadd(aResp,{BAK->BAK_CODRES,BAK->BAK_DESCRI,BAK->BAK_PEDCOM,BAK->BAK_DESCOM})
            BAK->(DbSkip())
         EndDo
      EndIf   
      
      If (nLi+2)+Len(aResp) > nQtdLin
         nLi := nQtdlin + 1
         R010Pag(.F.)
      EndIf
      cDesPer1 := SubStr(BAJ->BAJ_DESCRI,001,100)
      cDesPer2 := SubStr(BAJ->BAJ_DESCRI,061,100)
      @ ++nLi, 00 pSay StrZero(++nCont,3)+". "+cDesPer1
      If !Empty(cDesPer2)
         @ ++nLi, 00 pSay Space(05)+cDesPer2
      EndIf
      if BAJ->BAJ_TIPRES == "2"  // resposta sugerida
         For nI := 1 to Len(aResp)
            cDesCom := ""
            If aResp[nI,3] == "1" // se tiver complemento.
               cDesCom := AllTrim(aResp[nI,4])+" "+Replicate("_",80)
            EndIf
            @ ++nLi, 05 pSay "[  ] "+AllTrim(aResp[nI,2])+Space(10)+cDesCom
         Next   
         nLi++
      Else
         @ ++nLi, 00 pSay "R:"+Replicate("_",78)
         nLi++
      EndIf   
      BAJ->(DbSkip())
      R010Pag(.F.)
Enddo

//��������������������������������������������������������������������Ŀ
//� Imprime rodade padrao do produto Microsiga                         �
//����������������������������������������������������������������������
Roda(0,space(10),cTamanho)
//��������������������������������������������������������������������������Ŀ
//� Libera impressao                                                         �
//����������������������������������������������������������������������������
If  aReturn[5] == 1
    Set Printer To
    Ourspool(nRel)
End
//��������������������������������������������������������������������������Ŀ
//� Fim do Relat�rio                                                         �
//����������������������������������������������������������������������������
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R010Pag  � Autor �   Eduardo Motta       � Data � 24.05.01 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Avanca pagina caso necessario...                           ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function R010Pag(l1Vez)

If nLi > nQtdLin
   nLi := cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
Endif   

Return
