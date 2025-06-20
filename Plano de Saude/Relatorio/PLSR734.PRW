#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSR734.CH"
#INCLUDE "TOPCONN.CH"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR734 � Autor � Natie Sugahara         � Data � 11/09/03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � RECEITA X DESPESAS POR CONTRATO                            ����
���          �                                                            ����
���          �                                                            ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR734()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial                               ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
���          |      |             |                                       ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSR734()
/*��������������������������������������������������������������������������Ŀ
  � Define variaveis padroes para todos os relatorios...                     �
  ����������������������������������������������������������������������������*/
PRIVATE wnRel
PRIVATE cNomeProg   := "PLSR734"
PRIVATE nLimite     := 132
PRIVATE nTamanho    := "M"
PRIVATE nQtdeClas	:= 0
PRIVATE Titulo		:= oEmToAnsi(STR0001)
PRIVATE cDesc1      := oEmToAnsi(STR0001)
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BA1"
PRIVATE cPerg       := "PLR734"
PRIVATE Li         	:= 0
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aReturn     := { oEmToAnsi(STR0002), 1,oEmToAnsi(STR0003) , 1, 1, 1, "",1 }
PRIVATE aOrd		:= {}
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""

//��������������������������������������������������������������Ŀ
//� Variaveis Utilizadas na funcao IMPR                          �
//����������������������������������������������������������������
PRIVATE cCabec
PRIVATE Colunas		:= 132
PRIVATE AT_PRG  	:= "PLSR734"
PRIVATE wCabec0 	:= 1
PRIVATE wCabec1		:= ""
PRIVATE wCabec2		:= ""
PRIVATE wCabec3		:= ""
PRIVATE wCabec4		:= ""
PRIVATE wCabec5		:= ""
PRIVATE wCabec6		:= ""
PRIVATE wCabec7		:= ""
PRIVATE wCabec8		:= ""
PRIVATE wCabec9		:= ""
PRIVATE CONTFL		:= 1
PRIVATE cPathPict	:= ""

Pergunte(cPerg,.F.)

/*��������������������������������������������������������������Ŀ
  � Envia controle para a funcao SETPRINT                        �
  ����������������������������������������������������������������*/
wnrel:="Plsr734"					           //Nome Default do relatorio em Disco
wnrel:=SetPrint(cAlias,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)

/*��������������������������������������������������������������������������Ŀ
  | Verifica se foi cancelada a operacao                                     �
  ����������������������������������������������������������������������������*/
If nLastKey  == 27
	Return
Endif
/*��������������������������������������������������������������������������Ŀ
  � Configura impressora                                                     �
  ����������������������������������������������������������������������������*/
SetDefault(aReturn,cAlias)
If nLastKey = 27
	Return
Endif

MsAguarde({|lEnd| R734Imp( @lEnd,wnRel,cAlias ) },Titulo )

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R734Imp  � Autor � Natie Sugahara        � Data � 11/09/03 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Emite relatorio                                            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function R734Imp()
Local   cSQL			:= ""
Local   cDet			:= ""
Local   nOrdem  		:= aReturn[8]
Local   nX				:= 0
Local   nTotReceita		:= 0
Local   nTotDespesa 	:= 0

Private cSQLCond		:= ""
Private aData			:= {} 					//-- Array Totais

/*��������������������������������������������������������������������������Ŀ
  � Acessa parametros do relatorio...                                        �
  � Variaveis utilizadas para parametros                                     �
  ����������������������������������������������������������������������������*/
cCodOpe 	:= mv_par01					//-- codigo da Operadora
cGrupoDe	:= mv_par02					//-- Codigo Grupo Empresa De
cGrupoAte	:= mv_par03					//-- Codigo Grupo Empresa Ate
cCodContDe	:= mv_par04					//-- Codigo Contrato de
cCodContAte := mv_par05					//-- Codigo Contrato Ate
cCodSubCDe	:= mv_par06					//-- Codigo Sub-Contrato De
cCodSubCAte	:= mv_par07					//-- Codigo Sub-contrato Ate
cCodFamDe	:= mv_par08					//-- Codigo Familia De
cCodFamAte	:= mv_par09					//-- Codigo Familia Ate
cDataDe 	:= mv_par10  				//-- Mes/ano De
cDataAte 	:= mv_par11  				//-- Mes/ano Ate
nSinAnal	:= mv_par12 				//-- Modo Sintetico ( Sub-contrato -PJ Familia- PF )/ Modo Analitico ( Usuario da Familia )
cTipoAnaR   := mv_par13                 //-- Considerar receitas baixadas, em aberto ou ambas

IF EMPTY(cDataDe)
	IF EMPTY(cDataAte)  
		MSGINFO(STR0021)
		Return
	ENDIF
ENDIF
/*��������������������������������������������������������������������������Ŀ
  � Processa valores da Receita e Despesa Apurados                           �
  ����������������������������������������������������������������������������*/
	PLR734Receita()

	PLR734Custo()

/*��������������������������������������������������������������������Ŀ
  � Texto do Cabecalho de Acordo com nSinAnal                          �
  ��������������������������������������������������������������������-|*/
Wcabec1 := If(nSinAnal = 1, oemToAnsi(STR0009),  oemToAnsi(STR0008) )

/*��������������������������������������������������������������������Ŀ
  � Ordena em  ordem  decrescente p/ Receita x Despesa                 �
  ��������������������������������������������������������������������-|*/
aSort(aData,,,{|x,y| x[3]+ x[4] > y[3] + y[4] }  )

/*��������������������������������������������������������������������Ŀ
  � Inicializa a Impressao                                             �
  ��������������������������������������������������������������������-|*/
For nX := 1 to Len(aData)
	/*��������������������������������������������������������������������Ŀ
	  � Verifica se foi abortada a impressao...                            �
	  ����������������������������������������������������������������������*/
	If Interrupcao(lAbortPrint)
		Exit
	Endif
	/*��������������������������������������������������������������������Ŀ
 	  � Exibe mensagem...                                                  �
	  ����������������������������������������������������������������������*/
	MsProcTXT("Imprimindo " + aData[nx,1] + "..." )
    nSaldo := (aData[nx,3] - aData[nX,4] )
    If nSinAnal = 2
        cDet := Transform(aData[nX,1], "@R ####.####.######-##" ) + space(1)
 	Else
		cDet := Transform(aData[nx,1] , "@R ####.####.############-###.#########-###" )  + space(1)
 	Endif
	cDet	+= aData[nX,2] + space(1)
	cDet	+= Transform(aData[nX,3], "@E 99,999,999.99" ) + space(1)
	cDet	+= Transform(aData[nX,4], "@E 99,999,999.99" ) + space(1)
	cDet	+= Transform((aData[nX,4]/aData[nX,3]) * 100,  "@E 999,999.99") + space(1)
	cDet    += Transform(nSaldo     , "@E 9,999,999.99" )
    Impr(cDet, "C" )
    nTotReceita	+= aData[nX,3]
    nTotDespesa += aData[nX,4]
Next nX
/*��������������������������������������������������������������������Ŀ
  � Impressao dos totais do Relatorio                                  �
  ��������������������������������������������������������������������-|*/
If li + 3 >= 58
	Li := 0
Endif
Impr(__PrtThinLine() ,"C")
nSaldo := (nTotReceita - nTotDespesa )
If nSinanal = 1				//-- Modo Sintetico
	cDet 	:= space(41)+ oEmToansi(STR0007) +Space(15) + Transform(nTotREceita,  "@E 99,999,999.99 ") + space(1)
Else
	cDet 	:= space(20)+ oEmToansi(STR0007) +Space(15) + Transform(nTotREceita,  "@E 99,999,999.99 ") + space(1)
Endif
cDet 	+= Transform(nTotDespesa,  "@E 99,999,999.99 " )+ space(1)
cDet	+= Transform((nTotDespesa/nTotReceita) * 100 , "@E 999,999.99" ) + space(1)
cDet    += Transform(nSaldo     , "@E 9,999,999.99" )
Impr(cDet, "C")
Impr(__PrtThinLine() ,"C")
Impr("","C")

/*      10        20        30        40        50        60        70        80        90       100       120       130
123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Modo Analitico
Codigo Familia      Nome Usuario                    Receita       Despesa   %           Saldo
####.####.######-## xxxxxxxxxxxxxxxxxxxxxxxxx 99,999,999.99 99,999,999.99 999.99 9,999,999.99
                    Media Geral               99.999,999.99 99,999,999.99 999.99 9,999,999.99

Modo Sintetico
Contrato                   Sub-Contrato  Descricao                       Receita       Despesa   %           Saldo
####.####.############-###.#########-### xxxxxxxxxxxxxxxxxxxxxxxxx 99,999,999.99 99,999,999.99 999.99 9,999,999.99
                                         Media Geral               99.999,999.99 99,999,999.99 999.99 9,999,999.99

*/

/*��������������������������������������������������������������������������Ŀ
  � Libera impressao                                                         �
  ����������������������������������������������������������������������������*/
m_pag := 0
Impr("","F")

If  aReturn[5] == 1
	Set Printer To
	Ourspool(wnRel)
EndIf
/*��������������������������������������������������������������������������Ŀ
  � Fim do Relat�rio                                                         �
  ����������������������������������������������������������������������������*/
Return

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �PLR734Receita�Autor  �Microsiga           � Data �  11/09/03   ���
����������������������������������������������������������������������������͹��
���Desc.     � Receita do Usuario apurado no periodo                         ���
���          �                                                               ���
����������������������������������������������������������������������������͹��
���Uso       � AP                                                            ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function  PLR734Receita()

Local cChave := ""
Local cNome := ""
Local nPos := 0
Local cQueryBM1 := ""
Local cAliasQry := GetNextAlias()

cQueryBM1 := " SELECT "
cQueryBM1 += " 		BM1.BM1_CODINT,  "
cQueryBM1 += " 		BM1.BM1_CODEMP,  "
cQueryBM1 += " 		BM1.BM1_MATRIC,  "
cQueryBM1 += " 		BM1.BM1_CONEMP, "
cQueryBM1 += " 		BM1.BM1_VERCON,  "
cQueryBM1 += " 		BM1.BM1_SUBCON,  "
cQueryBM1 += " 		BM1.BM1_VERSUB,  "
cQueryBM1 += " 		BM1.BM1_TIPREG, "
cQueryBM1 += " 		BM1.BM1_ANO,  "
cQueryBM1 += " 		BM1.BM1_MES, "
cQueryBM1 += " 		BM1.BM1_VALOR, " 
cQueryBM1 += " 		BM1.BM1_PREFIX,  "
cQueryBM1 += " 		BM1.BM1_NUMTIT,  "
cQueryBM1 += " 		BM1.BM1_PARCEL,  "
cQueryBM1 += " 		BM1.BM1_TIPO, "
cQueryBM1 += " 		SE1.E1_SALDO, "
cQueryBM1 += " 		SE1.E1_VALOR "
cQueryBM1 += " FROM  " + BM1->(RetSQLName("BM1")) + " BM1 "
cQueryBM1 += " INNER JOIN " + SE1->(RetSQLName("SE1")) + " SE1 ON "
cQueryBM1 += " 		SE1.E1_FILIAL = '" + SE1->(xFilial("SE1")) + "' AND "
cQueryBM1 += " 		SE1.E1_PREFIXO = BM1.BM1_PREFIX AND "
cQueryBM1 += "  	SE1.E1_NUM = BM1.BM1_NUMTIT AND "
cQueryBM1 += "  	SE1.E1_TIPO = BM1.BM1_TIPTIT AND "
cQueryBM1 += "  	SE1.E1_PARCELA = BM1.BM1_PARCEL AND "
cQueryBM1 += "  	SE1.D_E_L_E_T_ = '' "
cQueryBM1 += " WHERE  "
cQueryBM1 += " 		BM1.BM1_FILIAL = '" + BM1->(xFilial("BM1")) + "' AND "
cQueryBM1 += " 		BM1.BM1_CODINT = '"  + cCodOpe + "' AND "
cQueryBM1 += " 		BM1.BM1_CODEMP >= '"  + cGrupoDe + "' AND "
cQueryBM1 += "  	BM1.BM1_CODEMP <= '"  + cGrupoAte + "' AND "
cQueryBM1 += "  	BM1.BM1_ANO+BM1.BM1_MES >= '" + Subs(cDataDe,3,4)+Subs(cDataDe,1,2) + "' AND "
cQueryBM1 += "  	BM1.BM1_ANO+BM1.BM1_MES <= '" + Subs(cDataAte,3,4)+Subs(cDataAte,1,2) + "' AND  "
cQueryBM1 += "  	BM1.BM1_CONEMP >= '"  + cCodContDe + "' AND "
cQueryBM1 += "  	BM1.BM1_CONEMP <= '"  + cCodContAte + "' AND "
cQueryBM1 += "  	BM1.BM1_SUBCON >= '"  + cCodSubCDe + "' AND "
cQueryBM1 += "  	BM1.BM1_SUBCON <= '"  + cCodSubCAte + "' AND "
cQueryBM1 += "  	BM1.BM1_MATRIC >= '"  + cCodFamDe + "' AND "
cQueryBM1 += "  	BM1.BM1_MATRIC <= '"  + cCodFamAte + "'AND "

Do Case 
	Case cTipoAnaR == 1 //Baixadas
       cQueryBM1 += "  SE1.E1_SALDO = 0 AND"
	Case cTipoAnaR == 2 //Em Aberto
       cQueryBM1 += "  SE1.E1_SALDO > 0 AND "
EndCase

cQueryBM1 += " BM1.D_E_L_E_T_ = ''  "

/*��������������������������������������������������������������������������Ŀ
  � Se houver filtro executa parse para converter expressoes adv para SQL    �
  ����������������������������������������������������������������������������*/
If ! Empty(aReturn[7])
	cQueryBM1 	+= " and " + PLSParSQL( aReturn[7] )
Endif

cQueryBM1 += " ORDER BY  "
cQueryBM1 += " 	BM1.BM1_FILIAL,  "
cQueryBM1 += "	BM1.BM1_CODINT,  "
cQueryBM1 += "	BM1.BM1_CODEMP,  "
cQueryBM1 += "	BM1.BM1_CONEMP,  "
cQueryBM1 += "	BM1.BM1_VERCON,  "
cQueryBM1 += "	BM1.BM1_SUBCON,  "
cQueryBM1 += "	BM1.BM1_VERSUB,  "
cQueryBM1 += "	BM1.BM1_MATRIC  "

cQueryBM1 := ChangeQuery(cQueryBM1)

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQueryBM1),cAliasQry,.F.,.T.)

(cAliasQry)->(DbGoTop())
While !(cAliasQry)->( Eof() )
	
	If Interrupcao(lAbortPrint)
		Exit
	Endif
	
	MsProcTXT("Processando Receita " + (cAliasQry)->(BM1_CODINT + '.'+ BM1_CODEMP + '.' + BM1_MATRIC + '-' + BM1_TIPREG) + "..." )

	cChave 	:= If( nSinAnal = 1 ,	(cAliasQry)->( BM1_CODINT + BM1_CODEMP +  BM1_CONEMP +  BM1_VERCON + BM1_SUBCON + BM1_VERSUB ),;
									(cAliasQry)->( BM1_CODINT + BM1_CODEMP + BM1_MATRIC + BM1_TIPREG) )

	cNome 	:= If (nSinAnal = 1 , fDesc("BQC" ,cChave, "BQC_DESCRI"), Posicione("BA1", 2, xFilial("BA1")+cChave,"BA1_NOMUSR") )
	cNome 	:= Substr(cNome + space(25) ,  1,25)
	nPos 	:= Ascan(aData,  {|x|x[1] = cChave } )

	If nPos > 0
		aData[nPos,3] += If( nSinAnal = 1, (cAliasQry)->E1_VALOR, (cAliasQry)->BM1_VALOR)
	Else
		aadd(aData ,{  cChave, ;
		cNome , ;
		If( nSinAnal = 1, (cAliasQry)->E1_VALOR, (cAliasQry)->BM1_VALOR),;
		0  ;
		} )
	Endif

	(cAliasQry)->(DbSkip())
Enddo

(cAliasQry)->(dbCloseArea())
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLR734Custo�Autor �Microsiga           � Data �  11/09/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Custo do Usuario apurado no periodo                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function  PLR734Custo()
Local cSQL 		:= ""
Local cChave 	:= ""
Local cNome		:= ""
Local nPos 		:= 0
Local dDataDe	:= ctod('//')
Local dDataAte	:= ctod('//')
Local dDataAux	:= ctod('//')

/*��������������������������������������������������������������������������Ŀ
  � (cDataDe/cDataAte)                                                       �
  ����������������������������������������������������������������������������*/
dDataDe 	:= CtoD( "01/" + substr(cDataDe ,1,2) + "/" + substr(cDataDe ,3,4) )
dDataAux	:= CtoD( "01/" + substr(cDataAte,1,2) + "/" + substr(cDataAte,3,4) )
dDataAte	:= CtoD(strzero(Last_Day(dDataAux),02)+ "/" + substr(cDataAte,1,2) + "/" + substr(cDataAte,3,4) )

/*��������������������������������������������������������������������������Ŀ
  � Faz filtro no arquivo...                                                 �
  ����������������������������������������������������������������������������*/
cSQL 	:= "SELECT  BD6_CODOPE ,BD6_CODESP , BD6_OPEUSR, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_CONEMP, "
cSQL    += "        BD6_VERCON, BD6_SUBCON , BD6_VERSUB, BD6_NOMUSR, BD6_VLRPAG, BD6_FASE  , BD6_SITUAC  "
cSQL 	+= "FROM  " + RetSQLName("BD6") + " WHERE "
cSQL 	+= "BD6_FILIAL = '" + xFilial("BD6") + "' AND "
cSQL 	+= "D_E_L_E_T_ = ''                       AND "
cSQL 	+= "BD6_FASE   = '4' AND "									//-- Somente Faturado
cSQL 	+= "BD6_SITUAC = '1' AND " 									//-- Ativo
cSQL 	+= "BD6_CODOPE = '"  + cCodOpe  + "' AND "
cSQL 	+= "BD6_CODEMP >='"+ cGrupoDe       +"' AND BD6_CODEMP  <= '"+ cGrupoAte     +"' AND "
cSQL    += "BD6_DATPRO >='"             + dtos(dDataDe)  +"' AND BD6_DATPRO             <= '"+ dtos(dDataAte)+"' AND "
cSQL    += "BD6_CONEMP >= '"            +cCodContDe      +"' AND "
cSQL    += "BD6_CONEMP <= '"            +cCodContAte     +"' AND "
cSQL    += "BD6_SUBCON >= '"            +cCodSubCDe      +"' AND "
cSQL    += "BD6_SUBCON <= '"            +cCodSubCAte     +"' AND "
cSQL    += "BD6_MATRIC >='" + cCodFamDe            +"' AND BD6_MATRIC  <= '"+ cCodFamAte             +"' "


/*��������������������������������������������������������������������������Ŀ
  � Se houver filtro executa parse para converter expressoes adv para SQL    �
  ����������������������������������������������������������������������������*/
If ! Empty(aReturn[7])
	cSQL += " and " + PLSParSQL( aReturn[7] )
Endif
/*��������������������������������������������������������������������������Ŀ
  � Define order by de acordo com a ordem...                                 �
  ����������������������������������������������������������������������������*/
cSQL += "ORDER BY BD6_FILIAL ,  BD6_CODOPE , BD6_CODEMP ,  BD6_CONEMP ,  BD6_VERCON , BD6_SUBCON, BD6_VERSUB , BD6_MATRIC ,  BD6_TIPREG  "

cSQL := PLSAvaSQL(cSQL)
TCQUERY cSQL NEW ALIAS "BD6Trb"

BD6Trb->(DbGoTop())

While !( BD6Trb->(EOF() ) )
	/*��������������������������������������������������������������������Ŀ
	  � Verifica se foi abortada a impressao...                            �
	  ����������������������������������������������������������������������*/
	If Interrupcao(lAbortPrint)
		Exit
	Endif
	/*��������������������������������������������������������������������Ŀ
 	  � Exibe mensagem...                                                  �
	  ����������������������������������������������������������������������*/
	MsProcTXT("Processando Despesas " + BD6Trb->( BD6_CODOPE + BD6_CODEMP + BD6_MATRIC )  + "..." )

	cChave 	:= If( nSinAnal = 1 , BD6Trb->(BD6_CODOPE+ BD6_CODEMP +  BD6_CONEMP + BD6_VERCON +  BD6_SUBCON + BD6_VERSUB  ) , BD6Trb->( BD6_CODOPE + BD6_CODEMP + BD6_MATRIC + BD6_TIPREG ) )
	cNome 	:= If (nSinAnal = 1 , fDesc("BQC" ,cChave, "BQC_DESCRI") , LEFT(BD6Trb->BD6_NOMUSR,25) )
	cNome 	:= Substr(cNome + space(25) ,  1,25)
	nPos 	:= Ascan(aData,  {|x|x[1] = cChave } )
	If nPos > 0
		aData[nPos,4] := aData[nPos,4] + BD6Trb->BD6_VLRPAG
	Else
		aadd(aData ,{ cChave, ;
		               cNome, ;
		               0 , ;
		               BD6Trb->BD6_VLRPAG ;
		             } )
	Endif
	BD6Trb->(DbSkip())
Enddo

/*��������������������������������������������������������������������Ŀ
  � Fecha arquivo...                                                   �
  ��������������������������������������������������������������������-|*/
BD6Trb->(dbCloseArea())

Return
