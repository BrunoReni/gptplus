#include "PLSA984.CH"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PLSA984 � Autor � Microsiga            � Data � 22/10/2015 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Guias de Reembolso de Anestesista importadas PTU A500      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Microsiga                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSA984
Local cFiltro := " B7Q_CODBRJ = '" + BRJ->BRJ_CODIGO + "' "
//��������������������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                               �
//����������������������������������������������������������������������������
Private aRotina   := MenuDef()
Private cFilter	  := ""
//��������������������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                              �
//����������������������������������������������������������������������������
B7Q->(DbSetOrder(1))
B7Q->(DbGoTop())
B7Q->(mBrowse(006,001,022,075,"B7Q",,,,,,/*aCores*/,,,,,   ,,,cFiltro))
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal                                                  �
//����������������������������������������������������������������������������
Return  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PL984Mov � Autor � Microsiga             � Data � 22/10/15 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Movimentacao de Guias de Reembolso de Anestesista          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
Function PL984Mov(cAlias,nReg,nOpc)  
Local aPosObj   := {}     
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}    
Local aVetB7R   := {}          
Local aVetBVG   := {} 
Local aVetBVK   := {}  

//��������������������������������������������������������������������������Ŀ
//� Define Variaveis para Enchoice...                                        �
//����������������������������������������������������������������������������
Private oEnchoice
Private aTELA[0][0]
Private aGETS[0]
//��������������������������������������������������������������������������Ŀ
//� Define Variaveis para montagem da tela                                   �
//����������������������������������������������������������������������������
Private aHeaderB7R
Private aColsB7R    
Private aColsB7RGrv := {}
Private aHeaderBVG
Private aColsBVG   
Private aColsBVGGrv := {} 
Private aHeaderBVK
Private aColsBVK     
Private aColsBVKGrv := {} 

//��������������������������������������������������������������������������Ŀ
//� Monta aCols e aHeader...                                                 �
//����������������������������������������������������������������������������
Store Header "B7R" TO aHeaderB7R For .T.      
                     
//��������������������������������������������������������������������������Ŀ
//� Carrega aCols B7R                                                        �
//����������������������������������������������������������������������������
B7R->(dbSetOrder(1)) //B7R_FILIAL+B7R_OPESOL+B7R_NUMSEQ+B7R_CODPAD+B7R_CODPRO
If B7R->(MsSeek(xFilial("B7R")+B7Q->(B7Q_CODBRJ+B7Q_SEQGUI)))
	Store COLS "B7R" TO aColsB7R FROM aHeaderB7R VETTRAB aVetB7R While xFilial("B7R")+B7R->(B7R_CODBRJ+B7R_SEQGUI) == xFilial("B7R")+B7Q->(B7Q_CODBRJ+B7Q_SEQGUI)
Else
	Store COLS Blank "B7R" TO aColsB7R FROM aHeaderB7R
EndIf

//��������������������������������������������������������������������������Ŀ
//� Define Dialogo...                                                        �
//����������������������������������������������������������������������������
aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 001, 100, .T., .F., .F. } )
AAdd( aObjects, { 001, 130, .T., .F., .F. } )     

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects,.T. )

DEFINE MSDIALOG oDlg TITLE STR0001 FROM aSize[7],0 To aSize[6],aSize[5] Pixel //"Reembolso Anestesista"
//��������������������������������������������������������������������������Ŀ
//� Monta Enchoice...                                                        �
//����������������������������������������������������������������������������
Zero();oEnchoice := MsMGet():New("B7Q",nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.)

//��������������������������������������������������������������������������Ŀ
//� Define Folders                                                           �
//���������������������������������������������������������������������������� 
oFolder1 := TFolder():New(aPosObj[2][1],aPosObj[2][2],{STR0002},{""}, oDlg,,,, .T., , aPosObj[2][4]-010, aPosObj[2][3] - aPosObj[1][3]) //"Procedimentos"

//��������������������������������������������������������������������������Ŀ
//� Monta GetDados...                                                        �
//����������������������������������������������������������������������������
oGetB7R := MsNewGetDados():New(005,005,(aPosObj[2][3] - aPosObj[1][3]) - 030,aPosObj[2][4]-010,,,,,,,9999,,,,oFolder1:aDialogs[1],aHeaderB7R,aColsB7R) 
//oGetB7R := TPLSBrw():New(005,005,(aPosObj[2][3] - aPosObj[1][3]) - 015,(aPosObj[2][3] - aPosObj[1][3]) - 015,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aHeaderB7R ,aColsB7R ,.F. ,"B7R" ,nOpc,"Eventos" ,,nil,nil,aVetB7R,/*'PlsVldB1M'*/)
//��������������������������������������������������������������������������Ŀ
//� Ativa o Dialogo...                                                       �
//����������������������������������������������������������������������������
ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,{|| .T.,oDlg:End() },{||oDlg:End()},.F.,{})  })

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Microsiga             � Data �02/12/2011���
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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
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

Private aRotina  := {	{ STR0003 		, 'AxPesqui' , 0, K_Pesquisar  	, 0, .F.},; //"Pesquisar"
						{ STR0004 		, 'PL984Mov' , 0, K_Visualizar 	, 0, Nil},; //"Visualizar"
						{ STR0005	, 'PLSAREV'  , 0, K_Alterar    , 0, Nil}} // "Revalorizar"

Return(aRotina)     
                          
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PL984Mov � Autor � Renan Sakai           � Data � 02/12/11 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Movimentacao do Ordem de Servi�o Tran. Online              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
Function PLSAREV  
Local cCodBRJ := B7Q->B7Q_CODBRJ
Local lRet    := .T.   

If BRJ->BRJ_STATUS == "2"
	MsgInfo(STR0006)//"Esta guia j� foi paga e n�o poder� ser revalorizada."
	Return
EndIf
//������������������������������������������������������������������Ŀ
//� Posiciona na B7R                                             	 |
//�������������������������������������������������������������������� 
B7R->(DbSetOrder(1))                           
If B7R->(MsSeek(xFilial("B7R")+cCodBRJ))   
	While !B7R->(EOF()) .AND. B7R->B7R_CODBRJ == cCodBRJ
		//��������������������������������������������������������������������������Ŀ
		//� Procura se existe o evento                                             	 |
		//���������������������������������������������������������������������������� 
		BR8->(DbSetOrder(1))                           
		If !BR8->(MsSeek(xFilial("BR8")+B7R->B7R_CODPAD+B7R->B7R_CODPRO))   
			lRet :=.F.    
	    Endif
		B7R->(RecLock("B7R",.F.)) 
		B7R->B7R_VLRBPG := BR8->BR8_VLRANE  
	    nVlrEvento      := B7R->B7R_VLRSER - B7R->B7R_VLRDIF
	    If (nVlrDifCalc := B7R->B7R_VLRBPG - nVlrEvento) > 0
	    	B7R->B7R_VLRGLO := B7R->B7R_VLRDIF - nVlrDifCalc 	
	    Else
	        B7R->B7R_VLRGLO := 0
	    Endif
	    B7R->(MsUnLock())
		B7R->(dbSkip())
	Enddo
Else
	lRet :=.F.    
Endif
If !lRet	
	MsgInfo(STR0007)//"Revaloriza��o n�o realizada!"
Else
	MsgInfo(STR0008)//"Revaloriza��o realizada com sucesso!"
Endif  

Return