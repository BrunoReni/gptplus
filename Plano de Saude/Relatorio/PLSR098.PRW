
#INCLUDE "PROTHEUS.CH"
#include "PLSR098.CH"
#IFDEF TOP
   #INCLUDE "TOPCONN.CH"
#ENDIF   

Static objCENFUNLGP := CENFUNLGP():New()
static lAutoSt := .F.

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR098 � Autor � Natie Sugahara         � Data � 11/06/03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Profissionais da Saude                                     ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR098()                                                  ����
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
Function PLSR098(lauto)
/*��������������������������������������������������������������������������Ŀ
  � Define variaveis padroes para todos os relatorios...                     �
  ����������������������������������������������������������������������������*/
PRIVATE wnRel
PRIVATE cNomeProg   := "PLSR010"
PRIVATE nLimite     := 132
PRIVATE nTamanho    := "M"
PRIVATE Titulo		:= oEmToAnsi(STR0001)
PRIVATE cDesc1      := oEmToAnsi(STR0001)
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BB0"
PRIVATE cPerg       := "PLS098"
PRIVATE Li         	:= 0
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aReturn     := { oEmToAnsi(STR0006), 1,oEmToAnsi(STR0007) , 1, 1, 1, "",1 }
PRIVATE aOrd		:= { STR0002,STR0003,STR0011,STR0012}
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := STR0017+" : " //"Questionario"
PRIVATE cCabec2     := "PERGUNTAS"

//��������������������������������������������������������������Ŀ
//� Variaveis Utilizadas na funcao IMPR                          �
//����������������������������������������������������������������
PRIVATE cCabec
PRIVATE Colunas		:= 132
PRIVATE AT_PRG  	:= "PLSR098"
PRIVATE wCabec0 	:= 2
PRIVATE wCabec1		:= oemToAnsi(STR0008)
PRIVATE wCabec2		:= SPACE(07)+oemToAnsi(STR0009) + SPACE(88) + oemToAnsi(STR0010)
PRIVATE wCabec3		:=""
PRIVATE wCabec4		:=""
PRIVATE wCabec5		:=""
PRIVATE wCabec6		:=""
PRIVATE wCabec7		:=""
PRIVATE wCabec8		:=""
PRIVATE wCabec9		:=""
PRIVATE CONTFL		:=1
PRIVATE cPathPict	:= ""

default lAuto := .F.

lAutoSt := lAuto

Pergunte(cPerg,.F.)

/*��������������������������������������������������������������Ŀ
  � Envia controle para a funcao SETPRINT                        �
  ����������������������������������������������������������������*/
wnrel:="Plsr098"					           //Nome Default do relatorio em Disco
If !lAuto
	wnrel:=SetPrint(cAlias,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)
	aAlias := {"BB0"}
	objCENFUNLGP:setAlias(aAlias)
endif
/*��������������������������������������������������������������������������Ŀ
  | Verifica se foi cancelada a operacao                                     �
  ����������������������������������������������������������������������������*/
If !lAuto .AND. nLastKey  == 27
   Return
Endif
/*��������������������������������������������������������������������������Ŀ
  � Configura impressora                                                     �
  ����������������������������������������������������������������������������*/
If !lAuto
	SetDefault(aReturn,cAlias)
endif

If !lAuto .AND. nLastKey = 27
	Return
Endif 

If !lAuto
	MsAguarde({|lEnd| R098Imp(@lEnd,wnRel,cAlias)},Titulo)
else
	R098Imp(.F.,wnRel,cAlias)
endif

Return


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R098Imp  � Autor � Natie Sugahara        � Data � 11/06/03 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Emite relatorio                                            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function R098Imp()
Local   cSQL	:= ""
Local   nOrdem  := aReturn[8]
//Local   nX		:= 0
Local   nTotProf := 0
Local   nTotGeral:= 0
//Local   aDados	:= {}
Private aCampo	:= {}

/*��������������������������������������������������������������������������Ŀ
  � Acessa parametros do relatorio...                                        �
  � Variaveis utilizadas para parametros                                     �
  ����������������������������������������������������������������������������*/
cSiglaDe	:= mv_par01					//-- Sigla C.R. Inicial
cSiglaAte	:= mv_par02					//-- Sigla C.R. Final
cUfDe		:= mv_par03					//-- Estado C.R. Inicial 
cUfAte		:= mv_par04					//-- Estado C.R. Final
nVinculo	:= mv_par05					//-- Vinculo : Faz parte da Rede ou Nao faz parte da Rede
nSintAnal	:= mv_par06					//-- RElatorio modo sintetico ou analitico

if lAutoSt
	cSiglaDe	:= "   "					//-- Sigla C.R. Inicial
	cSiglaAte	:= "ZZZ"					//-- Sigla C.R. Final
	cUfDe		:= "  "					//-- Estado C.R. Inicial 
	cUfAte		:= "ZZ"					//-- Estado C.R. Final
	nVinculo	:= 1					//-- Vinculo : Faz parte da Rede ou Nao faz parte da Rede
	nSintAnal	:= 2					//-- RElatorio modo sintetico ou analitico
endif

if nSintAnal= 2
	wCabec0	:= 1
	WCabec2	:= ""
Endif	

//��������������������������������������������������������������������������Ŀ
//� Faz filtro no arquivo...                                                 �
//����������������������������������������������������������������������������
#IFDEF TOP
        cSQL := "SELECT * FROM "+BB0->(RetSQLName("BB0"))+" WHERE "
        cSQL += "BB0_FILIAL = '"+xFilial("BB0")+"' "
        cSQL += "AND D_E_L_E_T_ = ' '  AND "
        cSQL += "BB0_CODSIG >= '"+cSiglaDe+"' AND BB0_CODSIG <= '"+cSiglaAte+"' AND "
		If nVinculo = 1 .or. nVinculo =2
			cSQL += "BB0_ESTADO >= '"+cUfDe   +"' AND BB0_ESTADO <= '"+cUfAte+"' AND "
			cSQL += "BB0_VINC   = '"+ alltrim(str(nVinculo))+"'"
	 	Else
	        cSQL += "BB0_ESTADO >= '"+cUfDe   +"' AND BB0_ESTADO <= '"+cUfAte+"'"
	    Endif
        //��������������������������������������������������������������������������Ŀ
        //� Se houver filtro executa parse para converter expressoes adv para SQL    �
        //����������������������������������������������������������������������������
        If ! Empty(aReturn[7])
			cSQL += " and " + PLSParSQL(aReturn[7])
        Endif   
        //��������������������������������������������������������������������������Ŀ
        //� Define order by de acordo com a ordem...                                 �
        //����������������������������������������������������������������������������
        If     nOrdem  == 1
			cSQL += " ORDER BY BB0_FILIAL, BB0_VINC, BB0_CODIGO"
        ElseIf nOrdem  == 2
			cSQL += " ORDER BY BB0_FILIAL, BB0_VINC, BB0_NOME"
        ElseIf nOrdem  == 3
			cSQL += " ORDER BY BB0_FILIAL, BB0_VINC, BB0_CGC"
        ElseIf nOrdem  == 4
			cSQL += " ORDER BY BB0_FILIAL, BB0_VINC, BB0_ESTADO, BB0_NUMCR, BB0_CODSIG"
        Endif
        cSQL := PLSAvaSQL(cSQL)
        TCQUERY cSQL NEW ALIAS "BB0Trb"
#ENDIF

Li 		:= 0
cChave	:= ""
BB0Trb->(dbgoTop())
While  !( BB0Trb->(Eof()) )
	cCodVinc	:= BB0Trb->(BB0_VINC)
	If li + 3 >=58
	   	Impr("","P")
	Endif 		
	Impr("","C")
	Impr(X3COMBO("BB0_VINC", cCodVinc) ,"C",,,00,.T.)
	Impr(__PrtThinLine(),"C",,,00,.T.)
	While  !( BB0Trb->(Eof()) ) .AND. cCodVinc = BB0Trb->(BB0_VINC)
	   	cDet := ""
		/*��������������������������������������������������������������������Ŀ
		  � Exibe mensagem...                                                  �
		  ����������������������������������������������������������������������*/
		If !lAutoSt
			MsProcTXT(STR0018+" " +  space(1)+ objCENFUNLGP:verCamNPR("BB0_CODIGO",BB0Trb->BB0_CODIGO) + SPACE(1) + ;
											objCENFUNLGP:verCamNPR("BB0_NOME",BB0Trb->BB0_NOME)  +"..." ) //"Imprimindo"
		endif
		/*��������������������������������������������������������������������Ŀ
		  � Impressao do Detalhe                                               �
		  ����������������������������������������������������������������������*/
		If !lAutoSt
		    cDet	:=  objCENFUNLGP:verCamNPR("BB0_CODIGO",BB0Trb->BB0_CODIGO) + SPACE(1) + ;
					objCENFUNLGP:verCamNPR("BB0_NOME",BB0Trb->BB0_NOME) + SPACE(1) + SPACE(5)+ ;
					objCENFUNLGP:verCamNPR("BB0_NUMCR",BB0Trb->BB0_NUMCR)+SPACE(1)

			cDet	+=  objCENFUNLGP:verCamNPR("BB0_CODSIG",BB0Trb->BB0_CODSIG) + SPACE(1) + ;
					objCENFUNLGP:verCamNPR("BB0_CODSIG",Left(fDesc("BAH",BB0Trb->BB0_CODSIG,"BAH_DESCRI"),55)) + SPACE(1)+;
					objCENFUNLGP:verCamNPR("BB0_ESTADO",BB0Trb->BB0_ESTADO) 
		endif
		Impr(cDet,"C",,,00,.T.)
		If nSintAnal = 1							//-- Modo Analitico
			cDet	:= objCENFUNLGP:verCamNPR("BB0_ENDERE",BB0Trb->BB0_ENDERE) + SPACE(6) + ;
						objCENFUNLGP:verCamNPR("BB0_BAIRRO",left(BB0Trb->BB0_BAIRRO,25)) + SPACE(1) + ;
						objCENFUNLGP:verCamNPR("BB0_CIDADE",BB0Trb->BB0_CIDADE) + SPACE(1)+ ;
						objCENFUNLGP:verCamNPR("BB0_UF",BB0Trb->BB0_UF)+ SPACE(1)

			cDet	+= objCENFUNLGP:verCamNPR("BB0_CGC",Transform(BB0Trb->BB0_CGC,"@R ##.###.###/####-##")) + SPACE(11) + ;
						objCENFUNLGP:verCamNPR("BB0_CODOPE",BB0Trb->BB0_CODOPE)
			Impr(cDet,"C",,,07,.T.)
			Impr("","C")
		Endif
		cChave := BB0Trb->(BB0_VINC)
		nTotProf	++
		nTotGeral	++
		BB0Trb->(dbSkip())
	Enddo
	Impr( __PrtThinLine(),"C")
	Impr( ( STR0015 +Transform(nTotProf, "@E 99,999") ) , "C",,,00,.T.)
	nTotProf:= 0
Enddo
Impr(__PrtThinLine(),"C")
Impr(  STR0016 +Transform(nTotGeral, "@E 99,999")  , "C",,,00,.T.)
Impr("","F")

//��������������������������������������������������������������������Ŀ
//� Fecha arquivo...                                                   �
//����������������������������������������������������������������������
BB0Trb->(DbCloseArea())

/*��������������������������������������������������������������������������Ŀ
  � Libera impressao                                                         �
  ����������������������������������������������������������������������������*/
If !lAutoSt .AND. aReturn[5] == 1
	Set Printer To
	Ourspool(wnRel)
End  

/*��������������������������������������������������������������������������Ŀ
  � Fim do Relat�rio                                                         �
  ����������������������������������������������������������������������������*/

Return
