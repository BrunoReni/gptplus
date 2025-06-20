
#include "PROTHEUS.CH"
#include "PLSR737.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PLSR737  � Autor � Tulio Cesar           � Data � 17/11/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Recibo de pagamento de vias de acesso                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PLSR737                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���              �        �      �                                        ��� 
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSR737()

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL aArea		:= GetArea()
LOCAL aRetASE1

PRIVATE wnRel
PRIVATE cNomeProg   := "PLSR737"
PRIVATE Titulo		:= oEmToAnsi(STR0001)
PRIVATE cDesc1      := oEmToAnsi(STR0001)
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cString     := "BED"
PRIVATE cPerg       := ""
PRIVATE Li         	:= 0
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrd		:= {}
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""
PRIVATE aReturn 	:= { OemtoAnsi(STR0004), 1,OemtoAnsi(STR0005), 2, 2, 1, "", 1 }  	//"Zebrado"###"Administracao"
PRIVATE aLinha		:= { }
PRIVATE nomeprog	:="PLSR737",nLastKey := 0
PRIVATE Tamanho 	:= "P" 
PRIVATE nLimite     := 080
PRIVATE nSvRecno	:= BED->( Recno() )												//Salva posicao do BED para Restaurar apos SetPrint()

SE1->(DbSetOrder(1))
If ! SE1->(DbSeek(xFilial("SE1")+BED->(BED_PREFIX+BED_NUMTIT+BED_PARCEL+BED_TIPTIT)))
	MsgAlert(STR0023, "PLSR737") //"T�tulo n�o encontrado."
	Return
Endif

If SE1->E1_SALDO > 0 
	MsgAlert(STR0024, "PLSR7371") //"T�tulo ainda n�o baixado."
	Return
Endif              

wnrel:="PLSR737"    																	//--Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.F.,tamanho)

/*��������������������������������������������������������������������������Ŀ
  | Verifica se foi cancelada a operacao                                     �
  ����������������������������������������������������������������������������*/
If nLastKey  == 27
	Return
Endif
/*��������������������������������������������������������������������������Ŀ
  � Configura impressora                                                     �
  ����������������������������������������������������������������������������*/
SetDefault(aReturn,cString)
If nLastKey = 27
	Return
Endif 

RptStatus({|lEnd| R737Imp(@lEnd,wnRel,cString)},Titulo)

/*
��������������������������������������������������������������Ŀ
�Restaura Area e Ordem de Entrada                              �
����������������������������������������������������������������*/
//--Retornar Set Epoch Padrao
RestArea( aArea)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R737IMP  � Autor � Tulio Cesar           � Data � 17/11/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR737                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function R737Imp(lEnd,wnRel,cString)


Private nLin		:= 02

DbSelectArea("BED")
//-- Posiciona o ponteiro
BED->( dbGoto( nSvRecno ) )	

/*��������������������������������������������������������������Ŀ
  �Impressao do Cabecalho                                        �
  ����������������������������������������������������������������*/
	fImpCabec()
/*��������������������������������������������������������������Ŀ
  �Dados do Usuario                                              |
  ����������������������������������������������������������������*/
	fDadosUsua()

fImpRecibo()
fImpRecibo() 

/*��������������������������������������������������������������������������Ŀ
  � Libera impressao                                                         �
  ����������������������������������������������������������������������������*/
m_pag := 0

If  aReturn[5] == 1
	Set Printer To
	Ourspool(wnRel)
EndIf
/*��������������������������������������������������������������������������Ŀ
  � Fim do Relat�rio                                                         �
  ����������������������������������������������������������������������������*/

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �fImpCabec   �Autor  �Microsiga           � Data �  17/11/05   ���
���������������������������������������������������������������������������͹��
���Desc.     �Cabecalho da Guia                                             ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � Generico                                                     ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function fImpCabec()
Local cFileLogo		:= ""
Local cPrazoLib		:= StrZero(GetMv("MV_PLPRZLB"),02)
Local cDet			:= ""          

/*��������������������������������������������������������������Ŀ
  �Reinicializa nLIn                     					     �
  ����������������������������������������������������������������*/
nLin		:= 02

/*��������������������������������������������������������������Ŀ
  �Setar Impressora Tamanho Normal       					     �
  ����������������������������������������������������������������*/
aDriver		:= ReadDriver()                  
If aReturn[4] == 1  // Comprimido
    @ 0,0 PSAY &(if(Tamanho=="P",aDriver[2],if(Tamanho=="G",aDriver[5],aDriver[3])))
Else                // Normal
    @ 0,0 PSAY &(if(Tamanho=="P",aDriver[2],if(Tamanho=="G",aDriver[6],aDriver[4])))
Endif

@ nLin , 0 PSAY &(aDriver[4])

/*��������������������������������������������������������������Ŀ
  �Impressao dos Dados Da Operadora 						     �
  ����������������������������������������������������������������*/
fImpNomOpe()

/*��������������������������������������������������������������Ŀ
  �Identificacao do Cartao Gerado                                �
  ����������������������������������������������������������������*/
nLin ++
cDet := OemToAnsi(STR0001)+ OemToAnsi(STR0006) + space(1) 
cDet += BED->BED_CDIDEN
@ nLin , 001 psay cDet 
nLin ++ 


Return(nil)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �fDadosUsua  �Autor  �Microsiga           � Data �  17/11/05   ���
���������������������������������������������������������������������������͹��
���Desc.     �Informacoes do Usuario                                        ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � Generico                                                     ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/ 
Static Function fDadosUsua()
Local cDet := "" 

/*��������������������������������������������������������������Ŀ
  �Usuario  / codigo                                             �
  ����������������������������������������������������������������*/
nLin ++
cDet 	:= OemToAnsi(STR0007) + space(1) + BED->(BED_CODINT+"."+BED_CODEMP+"."+BED_MATRIC+"."+BED_TIPREG+"-"+BED_DIGITO)
cDet	+= space(2) + BED->BED_NOMUSR + space(1)
@ nLIn , 001 psay cDet 
nLin ++

/*��������������������������������������������������������������Ŀ
  �Empresa                                                       �
  ����������������������������������������������������������������*/
BG9->(DbSetOrder(1))
BG9->(DbSeek( xFilial("BG9") + BED->(BED_CODINT+BED_CODEMP) )  )
cDet := OemToAnsi(STR0008)   + space(1) + BED->( BED_CODINT+BED_CODEMP )
cDet += Space(02)+BG9->BG9_DESCRI 
@ nLin ,001 psay cDet
nLin ++

/*��������������������������������������������������������������Ŀ
  �Plano                                                         �
  ����������������������������������������������������������������*/
BI3->(DbSetOrder(1))
BI3->(DbSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
cDet := OemToAnsi(STR0009) + space(1) + BI3->(BI3_CODIGO + Space(02)+BI3_DESCRI ) 
@ nLin ,001 psay cDet
nLin += 1


Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fImpRecibo�Autor  �Tulio Cesar         � Data �  18/09/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �Impressao do Recibo                                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fImpRecibo()
Local cDet 			:= ""
Local cNumRecibo 	:= SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
Local nValor  	 	:= SE1->E1_VALOR
@ nLin, 001 psay repl("-",80)
nLin ++

/*��������������������������������������������������������������Ŀ
  �Impressao dos Dados Da Operadora 						     �
  ����������������������������������������������������������������*/
fImpNomOpe()

/*��������������������������������������������������������������Ŀ
  �Detalhe do Recibo                         				     �
  ����������������������������������������������������������������*/
nLIn ++
@ nLin , 001 psay oEmToAnsi(STR0016) + cNumRecibo
@ nLin , 050 psay oEmToAnsi(STR0017) + Transform(nValor    , "@E 999,999.99") 
nLin += 2
cDet := oEmtoAnsi(STR0018)+  space(1) 
cDet += Transform(nValor, "@E 999,999.99" ) 
@ nLin, 001 psay  cDet
nLin ++
@ nLin, 001 psay "("+Extenso(nValor ,.F.,1) + REPLICATE("*", 077 - LEN(EXTENSO(nValor,,,) ) )+ "),"
nLin ++
@ nLin, 001 psay oEmToAnsi(STR0019)
nLin ++
cDet := oemToAnsi(STR0007) + space(1) + BED->(BED_CODINT+"."+BED_CODEMP+"."+BED_MATRIC+"."+BED_TIPREG+"-"+BED_DIGITO) + space(1)
cDet += BED->BED_NOMUSR
@ nLin, 001 psay cDet
nLin += 2
@ nlin, 001 psay Alltrim(BID->BID_DESCRI) + ", "+SUBSTR(DTOC(dDataBase),1,2)+ " de " + MesExtenso(MONTH(dDataBase)) + " de " + STR(YEAR(dDataBase),4)
@ nLin, 040 psay left(BA0->BA0_NOMINT,40)
nLin ++
@ nLin, 040 psay oEmToansi(STR0021) 
nLin ++ 
Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fImpNomOpe�Autor  �RH - Natie          � Data �  18/09/02   ���
�������������������������������������������������������������������������͹��
���Desc.     � Impressao dos Dados da Operadora                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function fImpNomOpe()

/*��������������������������������������������������������������Ŀ
  �Nome da Operadora 										     �
  ����������������������������������������������������������������*/

BA0->(DbSetOrder(1))
BA0->(DbSeek(xFilial("BED")+ BED->BED_CODINT ) ) 
@ nLin, 001 psay  BA0->BA0_NOMINT
nLin  ++ 
/*��������������������������������������������������������������Ŀ
  �Endereco                										 �
  ����������������������������������������������������������������*/
BID->(DbSetOrder(1)) 
BID->(DbSeek( xFilial("BID")+BA0->(BA0_CODMUN ) )  )
@ nLin, 001 psay alltrim(BA0->BA0_END)   + space(02) + alltrim(BA0->BA0_BAIRRO)
nLin ++
@ nLIn, 001 psay Alltrim(BID->BID_DESCRI) + "-"+ BA0->BA0_EST + space(5) +oEmToAnsi(STR0022)  + BA0->BA0_CEP + space(05) +  "CGC: " +Transform(BA0->BA0_CGC,  "@R ##.###.###/####-##" )
nLin  ++


Return( Nil )
