
#INCLUDE "PLSA220.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA220 � Autor � Tulio Cesar            � Data � 25.07.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Baixa de Titulos no Caixa                                  ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSA220()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial.                              ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA220

//��������������������������������������������������������������������������Ŀ
//� Define variaveis PRIVATE...                                              �
//����������������������������������������������������������������������������
PRIVATE aRotina   := MenuDef()
PRIVATE cCadastro := STR0007 //"Baixa de Titulos"

//��������������������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE...                                           �
//����������������������������������������������������������������������������
BA1->(DbSetOrder(2))
BA1->(DbGoTop())
BA1->(mBrowse(06,01,22,75,"BA1",,"BA1->BA1_MOTBLO<>Space(03)",20))
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal...                                               �
//����������������������������������������������������������������������������
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLA220MOV � Autor � Tulio Cesar          � Data � 25.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Exibe titulos para o usuario/contrato selecionado...       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLA220Mov(cAlias,nReg,nOpc,lAutoma)
Default lAutoma := .F.
//��������������������������������������������������������������������������Ŀ
//� Busca dados para localizar titulo...                                     �
//����������������������������������������������������������������������������
If ! Pergunte("PLA700",.T.)
   Return
Endif    

cAno    := mv_par01
cMes    := mv_par02
cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
//��������������������������������������������������������������������������Ŀ
//� Define dados para manter conpatibilidade com Financeiro...               �
//����������������������������������������������������������������������������
PRIVATE oFontLbl ; DEFINE FONT oFontLbl NAME "Arial" SIZE 6, 15 BOLD
PRIVATE nTotAGer  := 0
PRIVATE nTotADesc := 0
PRIVATE nTotAMul  := 0
PRIVATE nTotAJur  := 0
PRIVATE nTotADesp := 0
PRIVATE cLoteFin  := Space (4 )
PRIVATE cMarca    := GetMark()
PRIVATE cOld      := cCadastro
PRIVATE aCampos   := {}   
PRIVATE cLote     := ""
PRIVATE aCaixaFin 
PRIVATE lF070Auto := .F.
PRIVATE lFini055  := FwIsInCallStack("FINI055")
PRIVATE aAutoCab  := {}
PRIVATE lOracle	:= "ORACLE"$Upper(TCGetDB())
PRIVATE aCols     := {}
PRIVATE nIrrf     := 0
PRIVATE nPIS      := 0
PRIVATE nCOFINS   := 0
PRIVATE nCSLL     := 0
PRIVATE nIss      := 0
PRIVATE nInss		:= 0
//��������������������������������������������������������������������������Ŀ
//� Busca parametros da rotina do financeiro...                              �
//����������������������������������������������������������������������������
Pergunte("FIN070",.F.)

SE1->(DbSetOrder(GETMV("MV_PLORDE1")))

If ! SE1->(DbSeek(xFilial("SE1")+cMatric+cAno+cMes))
   Help("",1,"PLTITMAT")
Else
   If     nOpc == 3 // Baixa
          aCaixaFin	:= xCxFina()
          If !lAutoma
            FA070Tit("SE1",0,SE1->(Recno()))
         else
            Return .T.
          EndIf
   Endif
Endif       
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina...                                                         �
//����������������������������������������������������������������������������

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �02/01/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local nInt
Private aRotina := {	{ STR0001	,'AxPesqui' 	,  0 , K_Pesquisar  , 0, .F.},; //"Pesquisar"
											{ STR0002	,'plsa260Mov'	,  0 , K_Visualizar , 0, Nil},; //"Visualizar"
											{ STR0003	,'PLA220Mov'	,  0 , 3            , 0, Nil},; //"Baixar"
											{ STR0005	,'PLSA260VCB'	,  0 , 4            , 0, Nil} } //"Valor Cobranca"
                        
If ExistBlock("PLS220RT")
   aVets := ExecBlock("PLS220RT",.F.,.F.)
   nInt  := 0
   For nInt := 1 To Len(aVets)
       aadd(aRotina,aVets[nInt])
   Next    
Endif                              
Return(aRotina)
