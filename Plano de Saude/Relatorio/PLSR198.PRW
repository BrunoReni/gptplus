#include "PLSMGER.CH"

Static objCENFUNLGP := CENFUNLGP():New()

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR198 � Autor � Sandro Hoffman Lopes   � Data � 29.11.05 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Lista relatorio das Empresas com mais de ?? vidas          ����
���          � pois as mesmas nao tem carencia para CPT                   ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR198()                                                  ����
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
*/
Function PLSR198(lAuto)

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de Vidas por Operadora/Empresa/Contrato/SubContrato."
Local cDesc3        := ""
Local cPict         := ""
Local titulo        := "RELACAO DE VIDAS POR OPERADORA/EMPRESA/CONTRATO/SUBCONTRATO"
Local nLin          := 80
Local Cabec1        := ""
Local Cabec2        := ""
Local imprime       := .T.
Local aOrd          := {}

Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt       := ""
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := "PLSR198"
Private nTipo       := 15
Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey    := 0
Private cPerg       := "PLR198"
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "PLSR198"
Private lCompres    := .T.
Private lDicion     := .F.
Private lFiltro     := .F.
Private lCrystal    := .F.
Private cString     := "BQC"
Private nTotVid     := 0
Private cCodIntDe   := ""
Private cCodIntAte  := ""
Private cCodEmpDe   := ""
Private cCodEmpAte  := ""
Private cNumConDe   := ""
Private cNumConAte  := ""
Private cVerConDe   := ""
Private cVerConAte  := ""
Private cSubConDe   := ""
Private cSubConAte  := ""
Private cVerSubDe   := ""
Private cVerSubAte  := ""

Pergunte(cPerg,.F.)

//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������
wnrel:=  SetPrint(cString,NomeProg,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,lDicion,aOrd,lCompres,Tamanho,{},lFiltro,lCrystal)

	aAlias := {"BQC","BA1","BA0","BG9"}
	objCENFUNLGP:setAlias(aAlias)

If nLastKey == 27
	Return
Endif

If !lAuto
   SetDefault(aReturn,cString)
Endif   

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

nTotVid    := mv_par01
cCodIntDe  := mv_par02
cCodIntAte := mv_par03
cCodEmpDe  := mv_par04
cCodEmpAte := mv_par05
cNumConDe  := mv_par06
cNumConAte := mv_par07
cVerConDe  := mv_par08
cVerConAte := mv_par09
cSubConDe  := mv_par10
cSubConAte := mv_par11
cVerSubDe  := mv_par12
cVerSubAte := mv_par13

//��������������������������������������������������������������������������Ŀ
//� Emite relat�rio                                                          �
//����������������������������������������������������������������������������
MsAguarde({|| R198Imp(Cabec1,Cabec2,Titulo,nLin,lAuto) }, Titulo, "", .T.)

Roda(0,"","M")

//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������

SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R198Imp    � Autor � Sandro Hoffman Lopes  � Data � 24/11/05���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime relatorio para conferencia dos valores gerados no   ���
���          �arquivo de pagamento da RDA.                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function R198Imp(Cabec1,Cabec2,Titulo,nLin,lAuto)
       
   Local cBA1Name := RetSQLName("BA1")
   Local cBQCName := RetSQLName("BQC")
   Local cChave   := ""
   Local nTotGer   := 0

   //��������������������������������������������������������������������������Ŀ
   //� Exibe mensagem...                                                        �
   //����������������������������������������������������������������������������
   If !lAuto
      MsProcTxt(PLSTR0001)
   Endif   
   //��������������������������������������������������������������������������Ŀ
   //� Faz filtro no arquivo...                                                 �
   //����������������������������������������������������������������������������
   cSQL := " SELECT BQC_CODINT, BQC_CODEMP, BQC_NUMCON, BQC_VERCON, BQC_SUBCON, BQC_VERSUB, BQC_DATCON, BQC_DESCRI, BQC_ANTCON, COUNT(BA1_MATVID) TOTVID "
   cSQL += " FROM " + cBQCName + " BQC " 
   cSQL += " LEFT OUTER JOIN " + cBA1Name + " BA1 "
   cSQL += " ON BA1_FILIAL = BQC_FILIAL AND "
   cSQL += " BA1_CODINT    = BQC_CODINT AND "
   cSQL += " BA1_CODEMP    = BQC_CODEMP AND "
   cSQL += " BA1_CONEMP    = BQC_NUMCON AND "
   cSQL += " BA1_VERCON    = BQC_VERCON AND "
   cSQL += " BA1_SUBCON    = BQC_SUBCON AND "
   cSQL += " BA1_VERSUB    = BQC_VERSUB AND "
   cSQL += " BA1_MOTBLO    = '" + Space(Len(BA1->BA1_MOTBLO)) + "' AND "
   cSQL += " BA1.D_E_L_E_T_ <> '*' "
   cSQL += " WHERE BQC_FILIAL = '" + xFilial("BQC") + "' AND "
   cSQL += " (BQC_CODINT >= '" + cCodIntDe + "' AND "
   cSQL += "  BQC_CODINT <= '" + cCodIntAte + "') AND "
   cSQL += " (BQC_CODEMP >= '" + cCodEmpDe + "' AND "
   cSQL += "  BQC_CODEMP <= '" + cCodEmpAte + "') AND "
   cSQL += " (BQC_NUMCON >= '" + cNumConDe + "' AND " 
   cSQL += "  BQC_NUMCON <= '" + cNumConAte + "') AND " 
   cSQL += " (BQC_VERCON >= '" + cVerConDe + "' AND " 
   cSQL += "  BQC_VERCON <= '" + cVerConAte + "') AND " 
   cSQL += " (BQC_SUBCON >= '" + cSubConDe + "' AND " 
   cSQL += "  BQC_SUBCON <= '" + cSubConAte + "') AND " 
   cSQL += " (BQC_VERSUB >= '" + cVerSubDe + "' AND " 
   cSQL += "  BQC_VERSUB <= '" + cVerSubAte + "') AND " 
   cSQL += " BQC.D_E_L_E_T_ <> '*'"
   //��������������������������������������������������������������������������Ŀ
   //� Se houver filtro executa parse para converter expressoes adv para SQL    �
   //����������������������������������������������������������������������������
   If ! Empty(aReturn[7])
      cSQL += " AND " + PLSParSQL(aReturn[7])
   Endif
   //��������������������������������������������������������������������������Ŀ
   //� Monta Grupo...                                                           �
   //����������������������������������������������������������������������������
	cSQL += " GROUP BY BQC_CODINT, BQC_CODEMP, BQC_NUMCON, BQC_VERCON, BQC_SUBCON, BQC_VERSUB, BQC_DATCON, BQC_DESCRI, BQC_ANTCON "   
   cSQL += " ORDER BY BQC_CODINT, BQC_CODEMP, BQC_NUMCON, BQC_VERCON, BQC_SUBCON, BQC_VERSUB "

   PLSQuery(cSQL,"Trb198") // Igual ao TCQuery
   Trb198->(DbGotop()) 
   Do While ! Trb198->(Eof())
      //��������������������������������������������������������������������Ŀ
      //� Verifica se foi abortada a impressao...                            �
      //����������������������������������������������������������������������
      If Interrupcao(lAbortPrint)
         @ ++nLi, 00 pSay PLSTR0002
         Exit
      Endif                                                  

      MsProcTxt(objCENFUNLGP:verCamNPR("BQC_CODINT",Trb198->BQC_CODINT) + "." + objCENFUNLGP:verCamNPR("BQC_CODEMP",Trb198->BQC_CODEMP))
      If StrZero(Trb198->TOTVID, 16, 0) > StrZero(nTotVid, 16, 0)
         If Trb198->(BQC_CODINT+BQC_CODEMP) <> cChave
            If !Empty(cChave)
               
        	   fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2)
    	       @ nLin, 0 pSay "                                                                                                           Total de Vidas por Empresa"    
	           fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1) 
               @ nLin,125 pSay Transform(nTotger, "@E 999,999")
	           fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2) 
               @ nLin, 0 pSay Replicate("-", Limite)
               fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1)
            EndIf
            fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1)
            cChave := Trb198->(BQC_CODINT+BQC_CODEMP) 
            nTotGer:=0
            @ nLin, 0 pSay "Operadora: " + objCENFUNLGP:verCamNPR("BQC_CODINT",Trb198->BQC_CODINT) + " - " +;
                                           objCENFUNLGP:verCamNPR("BA0_NOMINT",Posicione("BA0", 1, xFilial("BA0")+Trb198->BQC_CODINT, "BA0_NOMINT"))
            fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1)
            @ nLin, 0 pSay "Empresa:   " + objCENFUNLGP:verCamNPR("BQC_CODEMP",Trb198->BQC_CODEMP) + " - " +;
                                           objCENFUNLGP:verCamNPR("BG9_DESCRI",Posicione("BG9", 1, xFilial("BG9")+Trb198->BQC_CODEMP, "BG9_DESCRI"))
            fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2)
            @ nLin, 0 pSay "Contrato/Versao  SubCon/Versao Data Contrato Descricao                                                   Nr Ant Contr Total de Vidas"
         EndIf
         fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1)
         @ nLin,  0 pSay objCENFUNLGP:verCamNPR("BQC_NUMCON",Trb198->BQC_NUMCON) + "/" +;
                         objCENFUNLGP:verCamNPR("BQC_VERCON",Trb198->BQC_VERCON)
         @ nLin, 17 pSay objCENFUNLGP:verCamNPR("BQC_SUBCON",Trb198->BQC_SUBCON) + "/" +;
                         objCENFUNLGP:verCamNPR("BQC_VERSUB",Trb198->BQC_VERSUB)
         @ nLin, 31 pSay objCENFUNLGP:verCamNPR("BQC_DATCON",DtoC(Trb198->BQC_DATCON))
         @ nLin, 45 pSay objCENFUNLGP:verCamNPR("BQC_DESCRI",SubStr(Trb198->BQC_DESCRI, 1, 60))
         @ nLin,105 pSay objCENFUNLGP:verCamNPR("BQC_ANTCON",Trb198->BQC_ANTCON)
         @ nLin,125 pSay Transform(Trb198->TOTVID, "@E 999,999") 
         nTotGer+=Trb198->TOTVID
         
      EndIf
      Trb198->(DbSkip())
   EndDo
   If nTotger >0
  	   fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2)
      @ nLin, 0 pSay "                                                                                                           Total de Vidas por Empresa" 
   	fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1)
      @ nLin,125 pSay Transform(nTotger, "@E 999,999")

  Endif      
   
   Trb198->(DbCloseArea())
   
Return

/*/  
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
��� Programa  � fSomaLin      � Autor � Sandro Hoffman     � Data � 28.11.2005 ���
������������������������������������������������������������������������������Ĵ��
��� Descri��o � Soma "n" Linhas a variavel "nLin" e verifica limite da pagina  ���
���           � para impressao do cabecalho                                    ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
Static Function fSomaLin(nLin, Titulo, Cabec1, Cabec2, nLinSom)

   nLin += nLinSom
   If nLin > 58
      nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo) + 1
   EndIf

Return