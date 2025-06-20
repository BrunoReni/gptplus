#include "PROTHEUS.CH"
#INCLUDE "Plsr340.ch"

Static lAutoSt := .F.

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR340 � Autor � Tulio Cesar            � Data � 06.10.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Relatorio de Mudanca de Valor                              ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR340()                                                  ����
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
//� Define nome da funcao...                                                 �
//����������������������������������������������������������������������������
Function PLSR340(lAuto)
//��������������������������������������������������������������������������Ŀ
//� Define variaveis...                                                      �
//����������������������������������������������������������������������������
Default lAuto := .F.

PRIVATE nQtdLin     := 58
PRIVATE cNomeProg   := "PLSR340"
PRIVATE nCaracter   := 15
PRIVATE nColuna     := 00
PRIVATE nLimite     := 132
PRIVATE cTamanho    := "M"
PRIVATE cTitulo     := STR0001 //"Relatorio de Mudanca de Valor"
PRIVATE cDesc1      := STR0001 //"Relatorio de Mudanca de Valor"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cCabec1     := "X"
PRIVATE cCabec2     := ""
PRIVATE cAlias      := "BA3"
PRIVATE cPerg       := "PLR340"
PRIVATE cRel        := "PLSR340"
PRIVATE nLi         := 01
PRIVATE m_pag       := 1
PRIVATE aReturn     := { "Zebrado", 1,STR0002, 1, 1, 1, "",1 } //"Administracao"
PRIVATE lAbortPrint := .F.                                                                       
PRIVATE aOrdens     := {STR0003} //"Matricula da Familia"
PRIVATE lDicion     := .F.
PRIVATE lCompres    := .F.
PRIVATE lCrystal    := .F.
PRIVATE lFiltro     := .T.
//��������������������������������������������������������������������������Ŀ
//� Parametros do SX1...                                                     �
//����������������������������������������������������������������������������
PRIVATE cAno01
PRIVATE cMes01
PRIVATE cAno02
PRIVATE cMes02
PRIVATE nModelo
PRIVATE nDifPad
//��������������������������������������������������������������������������Ŀ
//� Variaveis genericas...                                                   �
//����������������������������������������������������������������������������
PRIVATE nTotal  := 0
//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint                                                           �
//����������������������������������������������������������������������������
lAutoSt := lAuto

if !lAuto
   cRel                := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrdens,lCompres,cTamanho,{},lFiltro,lCrystal)
endif
//��������������������������������������������������������������������������Ŀ
//� Verifica se foi cancelada a operacao                                     �
//����������������������������������������������������������������������������
If !lAuto .AND. nLastKey  == 27
   Return
Endif
//��������������������������������������������������������������������������Ŀ
//� Recebe parametros                                                        �
//����������������������������������������������������������������������������
Pergunte(cPerg,.F.)            

cAno01  := mv_par01
cMes01  := mv_par02
cAno02  := mv_par03
cMes02  := mv_par04
nMod01  := mv_par05
nMod02  := mv_par06
nDifPad := mv_par07
cDatFin := mv_par08

//��������������������������������������������������������������������������Ŀ
//� Configura Impressora                                                     �
//����������������������������������������������������������������������������
if !lAuto
   SetDefault(aReturn,cAlias)
endif
//��������������������������������������������������������������������������Ŀ
//� Monta RptStatus...                                                       �
//����������������������������������������������������������������������������
if !lAuto
   MsAguarde( {|| RImp340() }  , STR0004 , "" , .T. ) //"Processando..."
else
   RImp340()
endif
//��������������������������������������������������������������������������Ŀ
//� Libera filtros...                                                        �
//����������������������������������������������������������������������������
BA3->(DbClearFilter())
BA3->(RetIndex("BA3"))
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal...                                               �
//����������������������������������������������������������������������������
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � R340Imp � Autor � Tulio Cesar            � Data � 17.02.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Relatorio de contratos.                                    ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
//��������������������������������������������������������������������������Ŀ
//� Define nome da funcao                                                    �
//����������������������������������������������������������������������������
Function RImp340()
Local cMvPLORDE1 := GETMV("MV_PLORDE1")
//��������������������������������������������������������������������������Ŀ
//� Monta cabec's...                                                         �
//����������������������������������������������������������������������������
PRIVATE cCabec1 := STR0005+cAno01+"/"+cMes01+Space(08)+cAno02+"/"+cMes02+Space(06)+STR0006 //"MATRICULA        TITULAR                       PLANO  DATA      OPERADOR               "###"DIFERENCA"
//��������������������������������������������������������������������������Ŀ
//� Variaveis do relatorio...                                                �
//����������������������������������������������������������������������������
PRIVATE cLinha  := Space(00)
PRIVATE cFor
PRIVATE cOrdem
PRIVATE cInd    := CriaTrab(Nil,.F.)
PRIVATE pMoeda  := "@E 99,999,999.99"
//��������������������������������������������������������������������������Ŀ
//� Totalizadores gerais...                                                  �
//����������������������������������������������������������������������������
PRIVATE nVal01Tot  := 0
PRIVATE nVal02Tot  := 0
PRIVATE nValDifTot := 0

PRIVATE nVal01
PRIVATE nVal02
PRIVATE nValDi
//��������������������������������������������������������������������������Ŀ
//� Monta Expressao de filtro...                                             �
//����������������������������������������������������������������������������
cFor := "BA3_FILIAL = '"+xFilial("BA3")+"'"
cFor += " .And. DTOS(BA3_DATBAS) <= '"+DTOS(cDatFin)+"' "
cFor += " .And. (Empty(BA3_DATBLO) .OR. DTOS(BA3_DATBLO) <= '"+DTOS(cDatFin)+"')"

If ! Empty(aReturn[7])
   cFor := cFor + " .And. "+AllTrim(aReturn[7])
Endif   
//��������������������������������������������������������������������������Ŀ
//� Monta ordem...                                                           �
//����������������������������������������������������������������������������
cOrdem := "BA3_CODINT+BA3_CODEMP+BA3_MATRIC"
//��������������������������������������������������������������������������Ŀ
//� Monta filtro de acordo com os grupos informados no parametro...          �
//����������������������������������������������������������������������������
if !lAutoSt
   BA3->(IndRegua("BA3",cInd,cOrdem,nil,cFor,nil,.T.))
endif
//��������������������������������������������������������������������������Ŀ
//� Posicione no primeiro registro no arquivo de usuarios...                 �
//����������������������������������������������������������������������������
BA3->(DbGoTop())

R340CAB()

nQtdReg := 0
nErros  := 0

While ! BA3->(Eof())
      //��������������������������������������������������������������������Ŀ
      //� Verifica se foi abortada a impressao...                            �
      //����������������������������������������������������������������������
      If !lAutoSt .AND. Interrupcao(lAbortPrint)
         Exit
      Endif

      nQtdReg ++

      //��������������������������������������������������������������������Ŀ
      //� Incrementa a regua...                                              �
      //����������������������������������������������������������������������
      if !lAutoSt
         MsPROCTxt("Matric "+BA3->(BA3_CODINT+"."+BA3_CODEMP+"-"+BA3_MATRIC)+" Pag "+Str(m_pag,3)+" Reg "+Str(nQtdReg,6)+" / "+Str(nErros,6))
      endif
      //��������������������������������������������������������������������Ŀ
      //� Para cada familia posiciona no titular...                          �
      //����������������������������������������������������������������������
      BA1->(DbSetOrder(2))
      
      BA1->(DbSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
      //��������������������������������������������������������������������Ŀ
      //� Busca a parcela no contas a receber do primeiro mes informado...   �
      //����������������������������������������������������������������������
      nVal01 := 0
      nVal02 := 0

      SE1->(DbSetOrder(cMvPLORDE1))
      
      If nMod01  == 1
         nVal01 := PLSVLRFAM(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),cAno01,cMes01)[1][3]
         
      Else
         If SE1->(DbSeek(xFilial("SE1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+cAno01+cMes01))
            nVal01 := SE1->E1_VALOR
         Endif   
      Endif   
      
      If nMod02  == 1
         nVal02 := PLSVLRFAM(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),cAno02,cMes02)[1][3]
      Else
         If SE1->(DbSeek(xFilial("SE1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+cAno02+cMes02))
            nVal02 := SE1->E1_VALOR
         Endif   
      Endif                            
      
	  If Valtype(nVal01) == "C"
	      nVal01 := 0  
	  Endif
      
	  If Valtype(nVal02) == "C"
	      nVal02 := 0  
	  Endif

      If nVal01 == 0 .Or. nVal02 == 0
         BA3->(DbSkip())
         Loop
      Endif   
      
      lDif   := (Str(nVal02,13,2) == Str(nVal01,13,2))
      nDif   := nVal02 - nVal01
      
      If nDifPad <> 0
         lDif := (ABS(nDif) <= nDifPad)
      Endif
      
      If lDif
         BA3->(DbSkip())
         Loop
      Endif
      //��������������������������������������������������������������������Ŀ
      //� PROVISORIO...                                                      �
      //����������������������������������������������������������������������
      /*/
      IF BA3->BA3_CODPLA = '010'
         BA3->(DbSkip())
         Loop
      Endif                 
      
      
      BA2->(DbSetOrder(1))
      
      If ! BA2->(DbSeek(xFilial("BA2")+BA3->BA3_CODPLA))
         BA3->(DbSkip())
         Loop
      Endif                 
      
      While nDif < 0
         
            MsPROCTxt("Diminuindo... "+Str(nDif,10,4))
            //��������������������������������������������������������������������Ŀ
            //� Aumenta ou diminui o coeficiente ate chegar o valor...             �
            //����������������������������������������������������������������������
            BA1->(DbSetOrder(2))
            If BA1->(DbSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
               
               X     := nVal01*BA1->BA1_COEFIC
               Y     := X / nVal02
               
               While ! BA1->(Eof()) .And. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
                     
                     BA1->(RecLock("BA1",.F.))
                     BA1->BA1_COEFIC := Y
                     BA1->(MsUnLock())

               BA1->(DbSkip())
               Enddo
            Endif   
            
            nVal02 := PLSVLRFAM(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),cAno02,cMes02)[1]
         
            lDif   := (Str(nVal02,13,2) == Str(nVal01,13,2))
            nDif   := nVal02 - nVal01
      
            If nDifPad <> 0
               lDif := (ABS(nDif) <= nDifPad)
            Endif          
            
            nAux := Str(nDif,17,1)
            nDif := Val(nAux)
            
      Enddo
     /*/
      //��������������������������������������������������������������������Ŀ
      //� FIM PROVISORIO...                                                  �
      //����������������������������������������������������������������������
      cLinha := BA3->(BA3_CODINT+"."+BA3_CODEMP+"-"+BA3_MATRIC)+Space(02)
      cLinha += BA1->BA1_NOMUSR+Space(02)
      cLinha += BA3->BA3_CODPLA+Space(02)
      cLinha += dtoc(BA3->BA3_DATBAS)+Space(02)
      cLinha += BA3->BA3_USUOPE+Space(02)
      cLinha += TransForm(nVal01,pMoeda)+Space(02)
      cLinha += TransForm(nVal02,pMoeda)+Space(02)
      cLinha += TransForm(nDif,pMoeda)+Space(02)
      nLi ++
      @ nLi, nColuna pSay cLinha
      //��������������������������������������������������������������������Ŀ
      //� Totalizadores...                                                   �
      //����������������������������������������������������������������������
      nVal01Tot  += nVal01
      nVal02Tot  += nVal02
      nValDifTot += nDif
      nErros ++
//��������������������������������������������������������������������Ŀ
//� Reimprime cabecalho se necessario...                               �
//����������������������������������������������������������������������
If nLi > nQtdLin 
   R340Cab()
Endif
//��������������������������������������������������������������������Ŀ
//� Proxima familia...                                                 �
//����������������������������������������������������������������������
BA3->(DbSkip())
//��������������������������������������������������������������������Ŀ
//� Fim do laco...                                                     �
//����������������������������������������������������������������������
Enddo
//��������������������������������������������������������������������Ŀ
//� Imprime totalizadores gerais...                                    �
//����������������������������������������������������������������������
@ nLi, nColuna pSay Replicate('-',nLimite)

cLinha := Space(Len(BA3->(BA3_CODINT+"."+BA3_CODEMP+"-"+BA3_MATRIC)+Space(02)))
cLinha += Space(Len(BA1->BA1_NOMUSR+Space(02)))
cLinha += Space(Len(BA3->BA3_CODPLA+Space(02)))
cLinha += Space(Len(dtoc(BA3->BA3_DATBAS)+Space(02)))
cLinha += Space(Len(BA3->BA3_USUOPE+Space(02)))
cLinha += TransForm(nVal01Tot,pMoeda)+Space(02)
cLinha += TransForm(nVal02Tot,pMoeda)+Space(02)
cLinha += TransForm(nValDifTot,pMoeda)+Space(02)

nLi ++
@ nLi, nColuna pSay cLinha
nLi ++
@ nLi, nColuna pSay Replicate('-',nLimite)
//��������������������������������������������������������������������Ŀ
//� Imprime rodape...                                                  �
//����������������������������������������������������������������������
if !lAutoSt
   Roda(0,Space(10))
endif
//��������������������������������������������������������������������������Ŀ
//� Libera impressao                                                         �
//����������������������������������������������������������������������������
If !lAutoSt .AND. aReturn[5] == 1
    Set Printer To
    Ourspool(crel)
End
//��������������������������������������������������������������������������Ŀ
//� Fim da impressao do relatorio...                                         �
//����������������������������������������������������������������������������
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � R340Cab � Autor � Tulio Cesar            � Data � 04.07.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Cabecalho do relatorio.                                    ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function R340Cab()

nLi ++
if !lAutoSt
   nLi := cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
endif
nLi ++

Return

Function R340DatRef()

Return(Year(mv_par08)==Val(mv_par03).And.Month(mv_par08)==Val(mv_par04))
