
#INCLUDE "Plsa730.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA730 � Autor � Tulio Cesar            � Data � 25.07.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Consulta posicao de usuario                                ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSA730()                                                  ����
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
Function PLSA730
//��������������������������������������������������������������������������Ŀ
//� Define variaveis PRIVATE...                                              �
//����������������������������������������������������������������������������
PRIVATE aRotina   := MenuDef()                        
PRIVATE cCadastro := STR0006 //"Consulta Posicao do Usuario"
//��������������������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE...                                           �
//����������������������������������������������������������������������������
BA1->(DbSetOrder(1))
BA1->(DbGoTop())
If ExistBlock('PL730COR')
	aAuxCor		:= ExecBlock('PL730COR',.f.,.f.)
	aCores 		:= aAuxCor[1]
	aCdCores  	:= aAuxCor[2]
Else		
	//aCores := 	{ 	{ "(BA1->BA1_MOTBLO<>Space(03))", 'BR_VERMELHO' },;
	//				{ "BA1->BA1_MOTBLO==Space(03)", 'BR_VERDE' }}

	aCores := 	{ 	{ "(BA1->BA1_MOTBLO==Space(03) .and. BA1->BA1_DATINC >  dDataBase )", 'BR_BRANCO' },;
					{ "(BA1->BA1_MOTBLO<>Space(03) .and. BA1->BA1_DATBLO <= dDataBase )", 'BR_VERMELHO' },;
					{ "BA1->BA1_MOTBLO==Space(03)", 'BR_VERDE' },; 
					{ "(BA1->BA1_MOTBLO<>Space(03) .and. BA1->BA1_DATBLO > dDataBase )", 'BR_AMARELO' }}
										
	aCdCores  	:= { 	{ 'BR_VERDE'    ,OemtoAnsi(STR0018)},; //'Usuario ativo'
						{ 'BR_VERMELHO' ,OemtoAnsi(STR0019)} } //'Usuario Bloqueado'
Endif

BA1->(mBrowse(06,01,22,75,"BA1",,,,,,aCores,,,,, .T. ))

//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal...                                               �
//����������������������������������������������������������������������������
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PL700MOV � Autor � Tulio Cesar           � Data � 25.07.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Consulta posicao de usuario                                ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PL700MOV(cALias,nReg,nOpcao)

LOCAL nRegBA1 := BA1->(Recno())
LOCAL nOrdBA1 := BA1->(IndexOrd())
LOCAL aRet
LOCAL dDataDe 
LOCAL dDataAte 

DBRUnlock(nRegBA1)
If     nOpcao == 3
       PLPOSFIN(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),.T.,.T.)
ElseIf nOpcao == 4 
	   aRet := PLSA730FAS()  
	   If aRet[1]
	      PLHISMOV(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),aRet[2],aRet[3],NIL,NIL,aRet[4])
	   EndIf    
ElseIf nOpcao == 5                                                                      
	   PLSVLRCOB(,,.T.)
ElseIf nOpcao == 6
       PLSMSGCA(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))
ElseIf nOpcao == 7
       PLSVSCLACAR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))
ElseIf nOpcao == 8
       NaoDisp()
ElseIf nOpcao == 9
       PLSRTGCUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
ElseIf nOpcao == 10
       If Pergunte("PLA790",.T.)
          dDataDe  := mv_par01
          dDataAte := mv_par02
          PLMOVGEN('6',STR0011,dDataDe, dDataAte,"BA1") //"Custo/Receita"
       Endif   
Endif
      
BA1->(DbGoTo(nRegBA1))
BA1->(DbSetOrder(nOrdBA1))

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLSA730MOV� Autor � Wagner Mobile Costa   � Data � 25.09.03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Consulta posicao de usuario                                ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA730MOV(cALias,nReg,nOpcao)

private lJuridico 	:= .F.
private lAmbos		:= .F.

If ! Empty(BA1->(BA1_CONEMP + BA1_VERCON + BA1_SUBCON + BA1_VERSUB))
	BQC->(DbSetOrder(1))
	BQC->(DbSeek(xFilial("BQC") + BA1->(BA1_CODINT + BA1->BA1_CODEMP + BA1_CONEMP +	BA1_VERCON + BA1_SUBCON + BA1_VERSUB)))
	lJuridico 	:= .T.
else
	BG9->(DbSetOrder(1))
	BG9->(DbSeek(xFilial("BG9") + BA1->(BA1_CODINT + BA1->BA1_CODEMP )))
Endif	

PLSA260MVC(.F.,.T.,cValToChar(MODEL_OPERATION_VIEW))


Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PLSA730FAS � Autor � Alexander	      � Data � 15.07.2005 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pede para selecionar um filtro de fASES...         		  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSA730FAS()
//��������������������������������������������������������������������������Ŀ
//� Define variaveis...                                                      �
//���������������������������������������������������������������������������� 
LOCAL oDlg
LOCAL cFilAux 	:= ""
LOCAL cFilSC 	:= ""
LOCAL cFilHO 	:= ""
LOCAL nOpca    	:= 0
LOCAL bOK      	:= { || nOpca := 1, oDlg:End() }
LOCAL bCancel  	:= { || nOpca := 0, oDlg:End() }
LOCAL lChkFA01 	:= .F.          
LOCAL lChkFA02 	:= .T.          
LOCAL lChkFA03 	:= .T.          
LOCAL lChkFA04 	:= .T.          
LOCAL nColIni  	:= 010
LOCAL nLinIni  	:= 030                     
LOCAL aDadSelect := {}
//��������������������������������������������������������������������������Ŀ
//� Define dialogo...                                                        �
//���������������������������������������������������������������������������� 
DEFINE MSDIALOG oDlg TITLE STR0012 FROM 008.2,008.3 TO 025,060 OF oMainWnd //"Selecao de Fases das Guias"
	//��������������������������������������������������������������������������Ŀ
	//� Monta Label																 �
	//���������������������������������������������������������������������������� 
	@ nLinIni, nColIni  TO 105, 180 PIXEL OF oDlg LABEL 'Fases'
	nLinIni += 12
	//��������������������������������������������������������������������������Ŀ
	//� CheckBox Fase															 �
	//���������������������������������������������������������������������������� 
	@ nLinIni-1,nColIni CHECKBOX oChkFA VAR lChkFA01 PROMPT STR0013 	PIXEL SIZE 60, 09 OF oDlg  //"Em digitacao"
    nLinIni += 12
	@ nLinIni-1,nColIni CHECKBOX oChkFA VAR lChkFA02 PROMPT STR0014 	PIXEL SIZE 60, 09 OF oDlg //"Conferencia"
    nLinIni += 12
	@ nLinIni-1,nColIni CHECKBOX oChkFA VAR lChkFA03 PROMPT STR0015 		PIXEL SIZE 60, 09 OF oDlg //"Pronto"
    nLinIni += 12
	@ nLinIni-1,nColIni CHECKBOX oChkFA VAR lChkFA04 PROMPT STR0016 		PIXEL SIZE 60, 09 OF oDlg //"Faturada"
	
ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{}) CENTERED

If nOpca == K_OK

   If(lChkFA01,(cFilAux += "1,"),"")
   If(lChkFA02,(cFilAux += "2,"),"")
   If(lChkFA03,(cFilAux += "3,"),"")
   If(lChkFA04,(cFilAux += "4,"),"")
   cFilAux := AllTrim(SubsTring(cFilAux,1,Len(cFilAux)-1))

   cFilSC := "(BD6->BD6_FASE $ '"+cFilAux+"' .And. ( ( BD6->BD6_SITUAC = '1' ) .Or. ( BD6->BD6_SITUAC = '3' .And. BD6->BD6_LIBERA = '1' )  )  )"
   cFilHO := "(BE4->BE4_FASE $ '"+cFilAux+"' .And. BE4->BE4_SITUAC = '1')"
   
   aDadSelect := {lChkFA01,;
   			      lChkFA02,;
   			      lChkFA03,;
   			      lChkFA04 }
Endif                    

Return( { IF(nOpca==K_OK,.T.,.F.),cFilSC,cFilHO,aDadSelect} )

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
��� Funcao    � PL730RDA()    � Autor � Sandro Hoffman     � Data � 04.09.2006 ���
������������������������������������������������������������������������������Ĵ��
��� Descri��o � Pesquisar Rede de Atendimento por parametros                   ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Function PL730RDA()

	P730VldPerg("PL730A")
	
	If Pergunte("PL730A", .T.)

		PLSCONRDA(BA1->BA1_CODPLA, BA1->BA1_VERSAO, (mv_par01 == 1))
		
	EndIf

Return


/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
��� Funcao    � P730VldPerg() � Autor � Sandro Hoffman     � Data � 04.09.2006 ���
������������������������������������������������������������������������������Ĵ��
��� Descri��o � Cria grupo de perguntas caso seja necessario                   ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function P730VldPerg(cPerg)

	Local aRegs := {}
	// 1     2     3       4      5      6       7    8       9       10     11  12    13    14    15      16      17    18    19    20      21      22    23    24    25      26      27    28    29    30      31      32    33    34    35      36      37    38 39
	// Grupo/Ordem/Pergunt/PerSpa/PerEng/Variavl/Tipo/Tamanho/Decimal/PreSel/GSC/Valid/Var01/Def01/DefSpa1/DefEng1/Cnt01/Var02/Def02/DefSpa2/DefEng2/Cnt02/Var03/Def03/DefSpa3/DefEng3/Cnt03/Var04/Def04/DefSpa4/DefEng4/Cnt04/Var05/Def05/DefSpa5/DefEng5/Cnt05/F3/GRPSXG
	//             1    2       3                 45   6      7   8  9 0  1   2    3        4  5  6  7  8  9  0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5  6  7  8  9
   
	aAdd(aRegs,{cPerg,"01","Filtrar RDA's cfe Prod Usu?","","","mv_cha","N",01,00,1,"C","","mv_par01","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",""})
   
	PlsVldPerg(aRegs)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �09/01/2007���
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
Local lBiomet := SuperGetMv("MV_BIOCONF",,.F.)
Private aRotina := {	{ STR0001	, 'AxPesqui'   ,  0, K_Pesquisar 	, 0, .F.},; //"Pesquisar"
						{ STR0002	, 'plSA730Mov' ,  0, K_Visualizar	, 0, Nil},; //"Contrato"
						{ STR0003	, 'pl700Mov'   ,  0, 3           	, 0, Nil},; //"Financeira"
						{ STR0004	, 'pl700Mov'   ,  0, 4           	, 0, Nil},; //"Movimentacao"
						{ STR0005	, 'pl700Mov'   ,  0, 5           	, 0, Nil},;
						{ STR0007	, 'PL700Mov'   ,  0, 6           	, 0, Nil},; //"Grupo Carencia"
						{ STR0008	, 'PL700Mov'   ,  0, 7           	, 0, Nil},; //"Classe Carencia"
						{ STR0009	, 'PLSC005'    ,  0, 8           	, 0, Nil},; //"Cobert/Carencia"
						{ STR0010	, 'PL700MOV'   ,  0, 9	          	, 0, Nil},; //"Grupo Cobert."
						{ STR0011	, 'PL700MOV'   ,  0, 10          	, 0, Nil},; //"Custo/Receita"
						{ STR0017	, 'PL730RDA'   ,  0, 11          	, 0, Nil} } //"Rede Atendimento"
If lBiomet
	AaDd( aRotina,{ STR0020 ,'PLSBIOMET("BTS",BA1->BA1_MATVID,.T.,"2")' , 0 , 12 } )
	AaDd( aRotina,{ STR0021 ,'PLSBIOMET("BTS",BA1->BA1_MATVID,.T.,"1")' , 0 , 13 } )
EndIf

Return(aRotina)
