
#INCLUDE "PLSR570.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR570 � Autor � Wagner Mobile Costa    � Data � 16.09.03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Emite o relatorio dos sub-contratos com negociacao no per. ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR570                                                    ����
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
//� Define nome da funcao                                                    �
//����������������������������������������������������������������������������
Function PLSR570()
//��������������������������������������������������������������������������Ŀ
//� Define variaveis padroes para todos os relatorios...                     �
//����������������������������������������������������������������������������
PRIVATE nQtdLin     := 60
PRIVATE cTamanho    := "M"
PRIVATE cTitulo     := STR0001 //"DEMONSTRATIVO DA PERIODICIDADE DO REAJUSTE DOS SUB-CONTRATOS"
PRIVATE cDesc1      := STR0002 //"Este Relatorio tem como objetivo demonstrar a partir da periodicidade informada"
PRIVATE cDesc2      := STR0003  //"no cadastro dos Sub-Contratos todos que tenham negociacao no periodo solicitado."
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BQC"
PRIVATE cPerg       := "PLR570"
PRIVATE cRel        := "PLSR570"
PRIVATE nli         := 80
PRIVATE m_pag       := 1    
PRIVATE lCompres    := .F. 
PRIVATE lDicion     := .F. 
PRIVATE lFiltro     := .T. 
PRIVATE lCrystal    := .F. 
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } 
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := STR0004 //"EMPRESA  CONTRATO/VERSAO SUB-CONTRATO/VERSAO NOME DA EMPRESA                             PERIODO       INDICE PADRAO  PRXS REAJUSTES"
PRIVATE cCabec2     := ""

//��������������������������������������������������������������������������Ŀ
//� Testa ambiente do relatorio somente top...                               �
//����������������������������������������������������������������������������
If ! PLSRelTop()
   Return
Endif    
//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint (padrao)                                                  �
//����������������������������������������������������������������������������
cRel := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
//��������������������������������������������������������������������������Ŀ
//� Verifica se foi cancelada a operacao (padrao)                            �
//����������������������������������������������������������������������������
If nLastKey  == 27 
   Return
Endif
//�����������������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         				�
//� mv_par01 // Mes Base Reajuste                                				�
//� mv_par02 // Ano Base                                         				�
//� mv_par03 // Operadora de                                     				�
//� mv_par04 // Operadora ate                                    				�
//� mv_par05 // Empresa de                                       				�
//� mv_par06 // Empresa ate                                      				�
//� mv_par07 // Contrato de                                      				�
//� mv_par08 // Contrato ate                                     				�
//� mv_par09 // Sub-Contrato de                                  				�
//� mv_par10 // Sub-Contrato ate                                                �
//�������������������������������������������������������������������������������
Pergunte(cPerg,.F.)

//��������������������������������������������������������������������������Ŀ
//� Configura impressora (padrao)                                            �
//����������������������������������������������������������������������������
SetDefault(aReturn,cAlias) 
//��������������������������������������������������������������������������Ŀ
//� Emite relat�rio                                                          �
//����������������������������������������������������������������������������
MsAguarde({|| R570Imp() }, cTitulo, "", .T.)
//��������������������������������������������������������������������������Ŀ
//� Fim da rotina                                                            �
//����������������������������������������������������������������������������
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R570Imp  � Autor � Tulio Cesar           � Data � 14.06.02 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Imprime detalhe do relatorio...                            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/
Static Function R570Imp()
//��������������������������������������������������������������������������Ŀ
//� Define variaveis...                                                      �
//����������������������������������������������������������������������������
//LOCAL cLinha
//LOCAL cQuebra     
LOCAL cSQL  
LOCAL cBQCName 	:= BQC->(RetSQLName("BQC"))
Local cPrxs		:= "", nPrxs := 0

mv_par01 := If(Empty(mv_par01), "00", mv_par01)

BQC->(DbSetOrder(1))

//��������������������������������������������������������������������������Ŀ
//� Monta query...                                                           �
//����������������������������������������������������������������������������
cSQL := "SELECT * FROM "+cBQCName+" WHERE "
cSQL += "BQC_FILIAL = '"+xFilial("BQC")+"' AND "
cSQL += "BQC_CODIGO >= '"+mv_par03+mv_par05+"' AND BQC_CODIGO <= '"+mv_par04+mv_par06+"' AND "
cSQL += "BQC_NUMCON >= '"+mv_par07+"' AND BQC_NUMCON <= '"+mv_par08+"' AND "
cSQL += "BQC_SUBCON >= '"+mv_par09+"' AND BQC_SUBCON <= '"+mv_par10+"' AND "
cSQL += "((BQC_PERREJ IN ('12', '06', '03', '02') AND BQC_MESREA = '"+mv_par01+"') OR "
cSQL +=  "(BQC_PERREJ = '03' AND CONVERT(INTEGER, BQC_MESREA) + 9 = " + mv_par01+") OR "
cSQL +=  "(BQC_PERREJ IN ('06', '03') AND CONVERT(INTEGER, BQC_MESREA) + 6 = " + mv_par01+") OR "
cSQL +=  "(BQC_PERREJ IN ('06', '03') AND CONVERT(INTEGER, BQC_MESREA) - 6 = " + mv_par01+") OR "
cSQL +=  "(BQC_PERREJ = '03' AND CONVERT(INTEGER, BQC_MESREA) - 9 = " + mv_par01+") OR "
cSQL +=  "(BQC_PERREJ = '03' AND CONVERT(INTEGER, BQC_MESREA) - 3 = " + mv_par01+") OR "
cSQL +=  "(BQC_PERREJ = '03' AND CONVERT(INTEGER, BQC_MESREA) + 3 = " + mv_par01+") OR "
cSQL +=  "(BQC_PERREJ = '02' AND CONVERT(INTEGER, BQC_MESREA) + 10 = " + mv_par01+") OR "
cSQL +=  "(BQC_PERREJ = '02' AND CONVERT(INTEGER, BQC_MESREA) + 8 = " + mv_par01+") OR "
cSQL +=  "(BQC_PERREJ = '02' AND CONVERT(INTEGER, BQC_MESREA) + 6 = " + mv_par01+") OR "
cSQL +=  "(BQC_PERREJ = '02' AND CONVERT(INTEGER, BQC_MESREA) + 4 = " + mv_par01+") OR "
cSQL +=  "(BQC_PERREJ = '02' AND CONVERT(INTEGER, BQC_MESREA) + 2 = " + mv_par01+") OR "
cSQL +=  "(BQC_PERREJ = '02' AND CONVERT(INTEGER, BQC_MESREA) - 10 = " + mv_par01+") OR "
cSQL +=  "(BQC_PERREJ = '02' AND CONVERT(INTEGER, BQC_MESREA) - 8 = " + mv_par01+") OR "
cSQL +=  "(BQC_PERREJ = '02' AND CONVERT(INTEGER, BQC_MESREA) - 6 = " + mv_par01+") OR "
cSQL +=  "(BQC_PERREJ = '02' AND CONVERT(INTEGER, BQC_MESREA) - 4 = " + mv_par01+") OR "
cSQL +=  "(BQC_PERREJ = '02' AND CONVERT(INTEGER, BQC_MESREA) - 2 = " + mv_par01+") OR "
cSQL +=  "(BQC_PERREJ = '01')) AND "

If ! Empty(aReturn[7])
	cSQL += PLSParSQL(aReturn[7]) + " AND "
Endif   
cSQL += cBQCName+".D_E_L_E_T_ = '' "
cSQL += "ORDER BY " + BQC->(IndexKey())

PLSQuery(cSQL,"R570Imp")

If R570Imp->(Eof())
   R570Imp->(DbCloseArea())
   Help("",1,"RECNO")
   Return
Endif
//��������������������������������������������������������������������������Ŀ
//� Exibe mensagem...                                                        �
//����������������������������������������������������������������������������
MsProcTxt(PLSTR0001) 

//��������������������������������������������������������������������������Ŀ
//� Inicio da impressao dos detalhes...                                      �
//����������������������������������������������������������������������������

cTitulo += " - " + mv_par01 + "/" + mv_par02

BG9->(DbSetOrder(1))

While ! R570Imp->(Eof())
	VldPag()

	BG9->(DbSeek(xFilial("BG9") + R570Imp->BQC_CODIGO))

	@ nLi,001 PSay Right(R570Imp->BQC_CODIGO, 4)
	@ nLi,008 PSay R570Imp->BQC_NUMCON + "/" + R570Imp->BQC_VERCON
	@ nLi,028 PSay R570Imp->BQC_SUBCON + "/" + R570Imp->BQC_VERSUB
	@ nLi,045 PSay Left(BG9->BG9_DESCRI, 43)
	@ nLi,089 PSAY Left(AllTrim(QA_CBOX("BQC_PERREJ",R570Imp->BQC_PERREJ)), 10)
	If ! Empty(R570Imp->BQC_INDREA)
		AAD->(DbSeek(xFilial("AAD") + R570Imp->BQC_INDREA))
		@ nLi,100 PSay R570Imp->BQC_INDREA + "-" + Left(AAD->AAD_DESCRI, 10)
	Endif

	cPrxs := ""
	If R570Imp->BQC_PERREJ = "12"
		cPrxs := R570Imp->BQC_MESREA + "/" + Str(Val(mv_par02), 4)
	Else
		For nPrxs := Val(mv_par01) + Val(R570Imp->BQC_PERREJ) To 12 Step Val(R570Imp->BQC_PERREJ)
			cPrxs += StrZero(nPrxs, 2) + "/"
		Next
		cPrxs := Left(cPrxs, Len(cPrxs) - 1)
	Endif
	
	@ nLi,118 PSay Padc(AllTrim(Left(cPrxs, 14)), 14)
	nLi ++
	cPrxs := Subs(cPrxs, 15, Len(cPrxs))
	If Left(cPrxs, 1) = "/"
		cPrxs := Subs(cPrxs, 2, Len(cPrxs))
	Endif
	If Right(cPrxs, 1) = "/"
		cPrxs := Left(cPrxs, Len(cPrxs) - 1)
	Endif
	If ! Empty(cPrxs)
		@ nLi,118 PSay Padc(AllTrim(Left(cPrxs, 14)), 14)
		nLi ++
	Endif

	cPrxs := Subs(cPrxs, 15, Len(cPrxs))
	If Left(cPrxs, 1) = "/"
		cPrxs := Subs(cPrxs, 2, Len(cPrxs))
	Endif
	If Right(cPrxs, 1) = "/"
		cPrxs := Left(cPrxs, Len(cPrxs) - 1)
	Endif
	If ! Empty(cPrxs)
		@ nLi,118 PSay Padc(AllTrim(Left(cPrxs, 14)), 14)
		nLi ++
	Endif
	                                   
 	R570Imp->(DbSkip())
Enddo
//��������������������������������������������������������������������Ŀ
//� Imprime rodape do relatorio...                                     �
//����������������������������������������������������������������������
Roda(0,space(10),cTamanho)
//��������������������������������������������������������������������Ŀ
//� Fecha arquivo...                                                   �
//����������������������������������������������������������������������
R570Imp->(DbCloseArea())
//��������������������������������������������������������������������������Ŀ
//� Libera impressao                                                         �
//����������������������������������������������������������������������������
If  aReturn[5] == 1 
    Set Printer To
    Ourspool(cRel)
Endif
//��������������������������������������������������������������������������Ŀ
//� Fim do Relat�rio                                                         �
//����������������������������������������������������������������������������
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ�� 
���Programa   � R570Cabec � Autor � Tulio Cesar          � Data � 14.06.02 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Imprime Cabecalho                                          ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/
Static Function R570Cabec()      
//��������������������������������������������������������������������������Ŀ
//� Imprime cabecalho...                                                     �
//����������������������������������������������������������������������������
nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
nLi ++
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina...                                                         �
//����������������������������������������������������������������������������
Return                                                                       
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ�� 
���Programa   � VLDPAG    � Autor � Tulio Cesar          � Data � 14.06.02 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Valida a proxima pagina...                                 ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/
Static Function VldPag()

If nLi > nQtdLin
   R570Cabec()
Endif 


Return
