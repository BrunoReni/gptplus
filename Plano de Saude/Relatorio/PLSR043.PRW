
#INCLUDE "PROTHEUS.CH"
#IFDEF TOP
	#INCLUDE "TOPCONN.CH"
#ENDIF
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLSR043 � Autor � Tulio Cesar            � Data � 15.07.04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Impressao de Etiquetas Genericas.                          ���
�������������������������������������������������������������������������Ĵ��
���            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Altera��o                     ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
//��������������������������������������������������������������������������Ŀ
//� Associa arquivo de definicoes                                            �
//����������������������������������������������������������������������������
#include "PLSMGER.CH"
//��������������������������������������������������������������������������Ŀ
//� Define nome da funcao                                                    �
//����������������������������������������������������������������������������
Function PLSR043(cTitRel,aDados,nNumCol,nNumLin)
//��������������������������������������������������������������������������Ŀ
//� Define variaveis padroes para todos os relatorios...                     �
//����������������������������������������������������������������������������
PRIVATE cNomeProg   := "PLSR043"
PRIVATE cTamanho    := "G"
PRIVATE cTitulo     
PRIVATE cDesc1      := ""
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "SA1"
PRIVATE cPerg       := ""
PRIVATE nRel        := "PLSR043"
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""
DEFAULT nNumCol     := 3        
DEFAULT cTitRel     := ""
DEFAULT aDados      := {}
//��������������������������������������������������������������������������Ŀ
//� Define titulo do relatorio...                                            �
//����������������������������������������������������������������������������
cTitulo := cTitRel
//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint                                                           �
//����������������������������������������������������������������������������
nRel     := SetPrint(cAlias,nRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
//��������������������������������������������������������������������������Ŀ
//� Testa se foi cancelada a utilizacao do relatorio...                      �
//����������������������������������������������������������������������������
If nLastKey == 27
   Return
Endif
//��������������������������������������������������������������������������Ŀ
//� Seta dados para a impressora...                                          �
//����������������������������������������������������������������������������
SetDefault(aReturn,"SA1")
//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������
RptStatus({|| RunReport(aDados,nNumCol,nNumLin) },cTitulo)
//���������������������������������������������������������������������Ŀ
//� Fim da rotina principal...                                          �
//�����������������������������������������������������������������������
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � Tulio Cesar        � Data �  15.07.04   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function RunReport(aDados,nNumCol,nNumLin)
//���������������������������������������������������������������������Ŀ
//� Define variaveis da rotina...                                       �
//�����������������������������������������������������������������������
LOCAL nFor
LOCAL nAux   
LOCAL nInd
LOCAL nDados    := Len(aDados)
LOCAL nLin      := 01
LOCAL nColIni   := 00    
LOCAL nRegCtn
LOCAL nRegMat
//���������������������������������������������������������������������Ŀ
//� Seta a impressora para a posicao zero...                            �
//�����������������������������������������������������������������������
SetPrc(0,0)
//���������������������������������������������������������������������Ŀ
//� Inicia a leitura dos dados que deverao ser impressos...             �
//�����������������������������������������������������������������������
For nFor := 1 To nDados
	//���������������������������������������������������������������������Ŀ
	//� Verifica o cancelamento pelo usuario...                             �
	//�����������������������������������������������������������������������
	If lAbortPrint
	   @ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
	   Exit
	Endif
	//���������������������������������������������������������������������Ŀ
	//� Monta dados para a impressao...                                     �
	//�����������������������������������������������������������������������
    nColIni := 00                       
    nRegCtn := nFor

	For nAux := 1 To nNumLin
    	nRegMat := nRegCtn
	    For nInd := 1 To nNumCol
	        nColIni := (nInd-1) * 73
	        @ nLin, nColIni pSay aDados[nRegMat,nAux]
	        nRegMat ++
	        If nRegMat > nDados
	           Exit
	        Endif   
	    Next      
	    nLin ++  
	    If nFor > nDados
	       Exit
	    Endif   
	Next           
	nFor += nNumCol-1
	nLin ++

Next
//���������������������������������������������������������������������Ŀ
//� Starta o spooll se necessario...                                    �
//�����������������������������������������������������������������������
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(nrel)
Endif


Return
