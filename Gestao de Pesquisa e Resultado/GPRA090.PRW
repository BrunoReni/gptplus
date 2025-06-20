#INCLUDE "GPRDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPRA090.CH"
#INCLUDE "SHELL.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPRA090    �Autora � Henry Fila           � Data � 07/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao de pesquisas ativas                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function GPRA090(aRotAuto,nOpc)

Local aCores      := {}

Private cCadastro := OemtoAnsi( STR0001 ) //Pesquisas ativas por pesquisador

Private aRotina   := MenuDef()

Aadd(aCores,{"KN_REAENTR == '1'","ENABLE"}) //Pesquisador com entrevista ativa permitida
Aadd(aCores,{"KN_REAENTR == '2'","BR_AZUL"}) //Pesquisador nao autorizado a entrevista ativa

dbSelectArea( "SKN" )
dbSetOrder(1)        

mBrowse( 6, 1, 22, 75, "SKN" ,,,,,,aCores)

Return						

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Conrado Q. Gomes      � Data � 12.12.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
	Local aRotina := {	{ STR0002 ,"AxPesqui"	,0	,1	,0	,.F.	}	,;
						{ STR0003 ,"Gpr090Entr"	,0	,1	,0	,.T.	}	,;
						{ STR0010 ,"Gpr090Leg"	,0	,1	,0	,.T.	}	}
Return(aRotina)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gpr090Entr �Autora � Henry Fila           � Data � 07/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao de pesquisas ativas                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Hanna C.  |30/03/07|9.12  �Bops 118469 - Alterado o nome dos Bitmaps   ���
���        	 �        |      �definidos pela Engenharia para o Protheus 10���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Gpr090Entr( aAlias, nReg, nOpc ) 

Local aArea    := GetArea()               //Armazena area atual
Local aPesq    := GprxPEntr( SKN->KN_CODPES ) //Retorna todas as pesquisas ativas de um pesquisador
Local aPosObj  := {}                //Calculo de dimensoes do objeto
Local aObjects := {}                //Calculo de dimensoes do objeto
Local aSize	   := MsAdvSize()       //Calculo de dimensoes do objeto
Local aButtons    := { {"NOTE"   , { || Gpr090Pesq( aPesq[ oPesq:nAT, 1 ], SKN->KN_CODPES ) }, STR0006,STR0005 } } //Realiza pesquisa 


Local nOpca    := 0                 //Variavel de confirmacao da tela

Local oDlg                          //Objeto da tela
Local oPesq                         //Objeto do listbox de pesquisas x pesquisador

//������������������������������������������������������Ŀ
//� Faz o calculo automatico de dimensoes de objetos     �
//��������������������������������������������������������
aSize := MsAdvSize()
AAdd( aObjects, { 100,20,.T.,.F. } )
AAdd( aObjects, { 100,100,.T.,.T.,.T. } )
aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 } 
aPosObj  := MsObjSize( aInfo, aObjects )


DEFINE MSDIALOG oDlg FROM aSize[7], 000 TO aSize[6],aSize[5] TITLE OemtoAnsi( STR0001 ) OF oMainWnd PIXEL 

	@ 18,05 SAY OemtoAnsi( STR0011 ) + SKN->KN_CODPES + "-" + SKN->KN_NOMPES OF oDlg SIZE 400,8 PIXEL  

	@ aPosObj[2,1],aPosObj[2,2] LISTBOX oPesq VAR cVar Fields HEADER OemtoAnsi( STR0004 ),	OemtoAnsi( STR0005 ) ; 
								SIZE aPosObj[2,3],aPosObj[2,4] OF oDlg PIXEL
					
	oPesq:SetArray(aPesq)                      
	oPesq:bLine:={ || { aPesq[oPesq:nAT,1],;
						aPesq[oPesq:nAT,2]} }

	oPesq:Refresh()

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, { || nOpca := 1,oDlg:End()}, {||oDlg:End()},,aButtons)

Return


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Gpr090Pesq� Autor � Henry Fila            � Data � 17/02/2005 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Realiza a pesquisa ativa                                      ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �Gpr010Pesq                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Codigo da pesquisa                                     ���
���          �ExpC2: Codigo do pesquisador                                  ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Pesquisa e Resultado                                         ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function Gpr090Pesq( cPesquisa, cPesquisador ) 

Local cParam := ""                
Local aArea  := GetArea()

SKC->( dbSetOrder( 1 ) )
If SKC->(MsSeek(xFilial( "SKC" ) + cPesquisa ) )
	cParam += fPesq2URL( SKC->KC_CODPQ + "000000000000000000000000101" )
	ShellExecute("open",GetSrvProfString("UrlGpr","")+"w_pgpr000.apw?cID="+cParam, "","",SW_SHOW)
Endif	
                         
RestArea( aArea )

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gpr010Leg  �Autora � Henry Fila           � Data � 20/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta a Legenda das Pesquisas                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gpr010Leg()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPR                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Marcelo K.�09/08/04�710   �-Revisao do fonte:Sintaxe, documentacao     ���
���          �        �      �                                            ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Gpr090Leg()

/*
  ��������������������������������������������������Ŀ
  �VERDE     - Pesquisador com entrevista habilitada �
  �AZUL      - Pesquisador sem entrevista habilitada �
  ����������������������������������������������������
*/

Local aLegenda := {	{"BR_VERDE",	STR0007},; //"Pesquisador com permissao de entrevista"
					{"BR_AZUL" ,	STR0008}}  //"Pesquisador sem permissao de entrevista"


BrwLegenda(STR0009,STR0010,aLegenda) 			//"Pesquisas","Legenda"

Return(.T.)




