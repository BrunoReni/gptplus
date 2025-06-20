#INCLUDE "PLSR017.ch"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR017 � Autor � Regiane Rocha Barreira � Data � 05.02.07 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Relatorio de prorrogacao de diarias por lote...            ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR017()                                                  ����
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
Function PLSR017()

//��������������������������������������������������������������������������Ŀ
//� Define variaveis padroes para todos os relatorios...                     �
//����������������������������������������������������������������������������
LOCAL cDesc1      := STR0001	//"Este relat�rio emite as infoma��es de Prorroga��o de Interna��es por Lote"
LOCAL cDesc2      := STR0002	//"conforme par�metros informados pelo usu�rio."
LOCAL cDesc3      := ""

PRIVATE nQtdLin     := 58
PRIVATE cNomeProg   := "PLSR017"
PRIVATE nLimite     := 220
PRIVATE cTamanho    := "G"
PRIVATE cTitulo     := FunDesc()	//"Relat�rio de Prorroga��o de Di�rias para Lote"
PRIVATE cAlias      := "B38"
PRIVATE cPerg       := "PLR017"
PRIVATE wnrel       := "PLSR017"
Private Cabec1  	:= ""
Private Cabec2		:= ""
Private Cabec3   	:= ""
PRIVATE nLi         := 60
PRIVATE m_pag       := 1
PRIVATE cbCont   	:= 0
PRIVATE cbTxt    	:= ""
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
/*+----------------------
  | Parametros do aReturn 
  +----------------------
aReturn - Preenchido pelo SetPrint()
aReturn[1] - Reservado para formulario
aReturn[2] - Reservado para numero de vias
aReturn[3] - Destinatario
aReturn[4] - Formato 1=Comprimido 2=Normal
aReturn[5] - Midia 1-Disco 2=Impressora
aReturn[6] - Prota ou arquivo 1-Lpt1... 4-Com1...
CReturn[7] - Expressao do filtro
aReturn[8] - Ordem a ser selecionada
aReturn[9] [10] [n] - Campos a processar se houver
*/
PRIVATE aReturn     := { STR0004, 1,STR0005, 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros					     �
//� mv_par01			  // Lote De		              	     �
//� mv_par02			  // Lote Ate            	     		 �
//����������������������������������������������������������������

//+-------------------------------------------------------------------------------
//| Disponibiliza para usuario digitar os parametros
//+-------------------------------------------------------------------------------
Pergunte(cPerg,.F.)

//��������������������������������������������������������������������������Ŀ
//� Solicita ao usuario a parametrizacao do relatorio.						 �
//����������������������������������������������������������������������������
wnrel := SetPrint(cAlias,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
//SetPrint(cAlias,cNome,cPerg,cDesc,cCnt1,cCnt2,cCnt3,lDic,aOrd,lCompres,;
//cSize,aFilter,lFiltro,lCrystal,cNameDrv,lNoAsk,lServer,cPortToPrint)

//��������������������������������������������������������������������������Ŀ
//� Verifica se foi cancelada a operacao                                     �
//����������������������������������������������������������������������������
If nLastKey  == 27
	Return
Endif

//��������������������������������������������������������������������������Ŀ
//�  Estabelece os padroes para impressao, conforme escolha do usuario�
//����������������������������������������������������������������������������
SetDefault(aReturn,cAlias)

//��������������������������������������������������������������������������Ŀ
//� Emite relat�rio                                                          �
//����������������������������������������������������������������������������
Processa({|| R017Imp() }, cTitulo, STR0006, .T.)  //"Processando..."

Return


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R017Imp  � Autor � Regiane Rocha Barreira� Data � 06.02.07 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Emite o relatorio... 					                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function R017Imp()

//��������������������������������������������������������������������������Ŀ
//� Define as variaveis da rotina....                                        �
//����������������������������������������������������������������������������
Local cQuery    := ""
Local cCODOPE	:= ""
Local cLOTE		:= ""

/*
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16     
      Local                     Cod                                                                                                               Data        
Seq   Digit PEG       Numero    RDA    Nome RDA                                   Matricula             Nome Usuario                              Interna��o  Prorrogada
****************************************************************************************************************************************************************************************************************************

Operadora: xxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   Lote: xxxxxxxx    Data: xx/xx/xx   
Diaria:    xxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   Qtd Dias Prorrogados: xxx

xxxx  xxxx  xxxxxxxx  xxxxxxxx  xxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   xxxx.xxxx.xxxxxx.xx-x xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xx/xx/xx        x
*/

Cabec1   := STR0007	//"      Local                     Cod                                                                                                               Data"
Cabec2   := STR0008	//"Seq   Digit PEG       Numero    RDA    Nome RDA                                   Matricula             Nome Usuario                              Interna��o  Prorrogada"

//+-----------------------
//| Cria filtro temporario
//+-----------------------
cQuery := "SELECT "
cQuery += "B38.B38_CODOPE, B38.B38_LOTE, B38.B38_DATGER, B38.B38_CODPRO, B38.B38_QTDPRO, B38.B38_CODPAD, "
cQuery += "B39.B39_SEQ, B39.B39_CODLDP, B39.B39_CODPEG, B39.B39_NUMERO, B39.B39_STATUS, "
cQuery += "BE4.BE4_CODRDA, BE4.BE4_NOMRDA, BE4.BE4_DATPRO, BE4.BE4_OPEUSR, BE4.BE4_CODEMP, BE4.BE4_MATRIC, "
cQuery += "BE4.BE4_TIPREG, BE4.BE4_DIGITO, BE4.BE4_NOMUSR "
cQuery += "FROM "+RetSqlName("B38")+ " B38, " + RetSqlName("B39")+ " B39, " + RetSqlName("BE4")+ " BE4 "
cQuery += "WHERE B38.B38_FILIAL   = '" + xFilial("B38") + "' "
cQuery += "AND   B38.B38_LOTE BETWEEN '" + mv_par01 + "' AND '"+  mv_par02 +"' "
cQuery += "AND   B39.B39_FILIAL   = '" + xFilial("B39") + "' "
cQuery += "AND   B39.B39_CODOPE   = B38.B38_CODOPE "
cQuery += "AND   B39.B39_LOTE     = B38.B38_LOTE "
cQuery += "AND   BE4.BE4_FILIAL   = '  ' "
cQuery += "AND   BE4.BE4_CODOPE   = B39.B39_CODOPE "
cQuery += "AND   BE4.BE4_CODLDP   = B39.B39_CODLDP "
cQuery += "AND   BE4.BE4_CODPEG   = B39.B39_CODPEG "
cQuery += "AND   BE4.BE4_NUMERO   = B39.B39_NUMERO "
cQuery += "AND B38.D_E_L_E_T_ <> '*' "
cQuery += "AND B39.D_E_L_E_T_ <> '*' "
cQuery += "AND BE4.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY B38_CODOPE, B38_LOTE, B39_SEQ"

//+-----------------------
//| Cria uma view no banco
//+-----------------------
PLSQuery(cQuery,"TRB")

TRB->(DbGoTop())

While !Eof()

	If nLi > 55
		nLi := Cabec(cTitulo,Cabec1,Cabec2,cNomeProg,cTamanho) + 1
		nLi ++
	Endif

	@ nLi,00 PSay STR0009 + TRB->B38_CODOPE + " " + Alltrim(Substr(Posicione("BA0",1,xFilial("BA0")+TRB->B38_CODOPE,"BA0_NOMINT"),1,60))	//"Operadora: "
	@ nLi,79 PSay STR0010 + TRB->B38_LOTE	//"Lote: "
	@ nLi,97 PSay STR0011 + DTOC(TRB->B38_DATGER)	//"Data: "
	nLi ++
	@ nLi,00 PSay STR0012 + Alltrim(TRB->B38_CODPRO) + " " + Alltrim(Substr(Posicione("BR8",1,xFilial("BR8")+TRB->B38_CODPAD+TRB->B38_CODPRO,"BR8_DESCRI"),1,60))	//"Diaria: "
	@ nLi,91 PSay STR0013 + StrZero(TRB->B38_QTDPRO,3)	//"Qtd Dias Prorrogados: "
	nLi += 2

	cCODOPE := TRB->B38_CODOPE
	cLOTE 	:= TRB->B38_LOTE

	While TRB->B38_CODOPE = cCODOPE .AND. TRB->B38_LOTE = cLOTE
		@ nLi,00  PSay TRB->B39_SEQ
		@ nLi,06  PSay TRB->B39_CODLDP
		@ nLi,12  PSay TRB->B39_CODPEG
		@ nLi,22  PSay TRB->B39_NUMERO
		@ nLi,32  PSay TRB->BE4_CODRDA + " " + Alltrim(Substr(TRB->BE4_NOMRDA,1,40))
		@ nLi,82  PSay TRB->BE4_OPEUSR + "." + TRB->BE4_CODEMP + "." + TRB->BE4_MATRIC + "." + TRB->BE4_TIPREG + "-" + TRB->BE4_DIGITO
		@ nLi,104 PSay Alltrim(Substr(TRB->BE4_NOMUSR,1,40))
		@ nLi,146 PSay DTOC(TRB->BE4_DATPRO)
		@ nLi,162 PSay If(TRB->B39_STATUS = "1", "X", "")
		dbSkip()
		nLi ++
	EndDo      
	nLi := 60
EndDo
   
If nLi <> 80
   Roda(cbCont,cbTxt,cTamanho)
Endif

TRB->(dbCloseArea())

If aReturn[5] == 1
   Set Printer TO
   dbCommitAll()
   Ourspool(wnrel)
EndIf

Ms_Flush()

Return