#INCLUDE "QIEA130.CH"
#INCLUDE "PROTHEUS.CH"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEA130  � Autor � Vera Lucia S. Simoes  � Data � 09/06/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Skip-Teste por Grupo            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 				      ���
�������������������������������������������������������������������������Ĵ��
���Vera        �14/04/99�------� Inclusao da Loja do Fornecedor           ���
���Antonio     �24/01/99�------� Aumento das caixas de texto para         ���
���            �        �      � tratamento de Fornec. de ate 20 caract.  ���
���            �        �      � e alguns ajustes de vari�veis.           ���
���Marcelo     �25/04/00�------� Incluido o quinto parametro como 3 no    ���
���Marcelo     �25/04/00�------� array aRotina.                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0004),"AxPesqui"  , 0 , 1,,.F.},;  	// "Pesquisar"
					{OemToAnsi(STR0005),"QIE130Visu"  , 0 , 2},; // "Visualizar"
					{OemToAnsi(STR0006),"QIE130Incl"  , 0 , 3},; // "Incluir"
					{OemToAnsi(STR0007),"QIE130Alte"  , 0 , 6},; // "Alterar"
					{OemToAnsi(STR0008),"QIE130Del"  , 0 , 5 , 3} } // "Excluir"

Return aRotina

Function QIEA130
Private aCRA := { OemToAnsi(STR0001), OemToAnsi(STR0002), OemToAnsi(STR0003) }  //"Confirma" ### "Redigita" ### "Abandona"

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0009)  //"Skip-Teste por Grupo"

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//�    6 - Nao permite inclusao na getdados                      �
//����������������������������������������������������������������
Private aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QEI")

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIE130Visu� Autor � Vera Lucia S. Simoes  � Data � 09/06/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao Skip-Teste Grupo  -  Incl./Alter.  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIE130Visu(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION QIE130Visu(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local cRevi		:= 0
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3   := NIL
Local oBox

Private cIE130For := Space(TamSX3("QEI_FORNEC")[1])
Private cIE130Gru := Space(TamSX3("QEI_GRUPO")[1])
Private cIE130LjF := Space(TamSX3("QEI_LOJFOR")[1])
Private aHeader	:= {}
Private aCols 		:= {}
Private aEnsaios	:= {}
Private nUsado		:= 0

Private nPosEns	:= 0
Private nPosSkT	:= 0
Private nPosSkI 	:= 0
Private oGet		:= NIL

//��������������������������������������������������������������Ŀ
//� Salva a integridade dos campos de Bancos de Dados            �
//����������������������������������������������������������������
dbSelectArea("SX2")  // Posiciona pq. rotinas internas utilizam inf. do SX2
dbSeek("QEI")

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) ;
					FROM 150,3 TO 388,613 OF oMainWnd PIXEL	// "Skip-Teste Grupo"

@ 000,000 SCROLLBOX oBox SIZE 0,0 OF oDlg

cIE130For := QEI->QEI_FORNEC
cIE130LjF := QEI->QEI_LOJFOR
cIE130Gru := QEI->QEI_GRUPO

//������������������������������������������������������Ŀ
//� Gets do Fornecedor                         				�
//��������������������������������������������������������
@ 5,03 SAY TitSX3("QEI_FORNEC")[1] SIZE 56,07 OF oBox PIXEL  
@ 3,61 MSGET oGet_1 VAR cIE130For PICTURE PesqPict("SA2","A2_COD") ;
						WHEN .F. ;			
						SIZE 66,10 OF oBox PIXEL  
//������������������������������������������������������Ŀ
//� Gets da Loja                               				�
//��������������������������������������������������������
@ 5,131 SAY TitSX3("QEI_LOJFOR")[1] SIZE 56, 7 OF oBox PIXEL 
@ 3,189 MSGET oGet_2 VAR cIE130LjF PICTURE PesqPict("SA5","A5_LOJA") ;
						WHEN .F. ;
					   SIZE 15,10 OF oBox PIXEL						
//������������������������������������������������������Ŀ
//� Gets da Grupo                              				�
//��������������������������������������������������������
@ 20, 3 SAY   TitSX3("QEI_GRUPO")[1] SIZE 56,7 OF oBox PIXEL		//"Grupo"
@ 18,61 MSGET oGet_3 VAR cIE130Gru PICTURE PesqPict("QE3","QE3_GRUPO") ;
								WHEN .F. ;								
								SIZE 66,10 OF oBox PIXEL
@ 20,131 SAY QIEXDeGr(cIE130Gru) SIZE 130,7 OF oBox PIXEL

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader e aCols a ser utilizado na getdados      �
//����������������������������������������������������������������
Q130FGet(cRevi,nOpc,oDlg)

oGet:= MSGetDados():New(50,2,190,312,nOpc ,"AllwaysTrue","AllwaysTrue","",.F.)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGet:Refresh()
	
ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}),;
								AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{75}))
	
dbSelectArea(cAlias)
dbGoto(nReg)

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIE130Incl� Autor � Vera Lucia S. Simoes  � Data � 09/06/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao Skip-Teste Grupo  -  Incl./Alter.  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIE130Incl(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QIE130Incl(cAlias,nReg,nOpc)

Local nI			:= 0
Local cRevi		:= ""
Local lGravaOk := .F.
Local oDlg		:= NIL
Local oGet_1 	:= NIL
Local oGet_2 	:= NIL
Local oGet_3 	:= NIL
Local oBox

Private cIE130For := Space(TamSX3("QEI_FORNEC")[1])
Private cIE130LjF := Space(TamSX3("QEI_LOJFOR")[1])
Private cIE130Gru := Space(TamSX3("QEI_GRUPO")[1])
Private nPosEns	:= 0
Private nPosSkT	:= 0
Private nPosSkI 	:= 0
Private nUsado		:= 0
Private aHeader	:= {}
Private aCols		:= {}
Private oGet		:= NIL
Private aEnsaios	:= {}

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) ;
				FROM 150,3 TO 388,613 OF oMainWnd PIXEL	// "Skip-Teste Grupo"

@ 000,000 SCROLLBOX oBox SIZE 0,0 OF oDlg

//������������������������������������������������������Ŀ
//� Gets do Fornecedor                         				�
//��������������������������������������������������������
@ 5,03 SAY TitSX3("QEI_FORNEC")[1] SIZE 56,07 OF oBox PIXEL  
@ 3,61 MSGET oGet_1 VAR cIE130For PICTURE PesqPict("SA2","A2_COD") ;
						F3 "QFO" ;
						VALID	ExistCpo("SA2",cIE130For) ;
						SIZE 58,10 OF oBox PIXEL  
//������������������������������������������������������Ŀ
//� Gets da Loja                               				�
//��������������������������������������������������������
@ 5,131 SAY TitSX3("QEI_LOJFOR")[1] SIZE 56, 7 OF oBox PIXEL 
@ 3,189 MSGET oGet_2 VAR cIE130LjF PICTURE PesqPict("SA5","A5_LOJA") ;
						  VALID ExistCpo("SA2",cIE130For+cIE130LjF) ;
						  SIZE 15,10 OF oBox PIXEL
@ 5,208 SAY QIEXDeFo(cIE130For,cIE130LjF,2) SIZE 80,7 OF oBox PIXEL 
//������������������������������������������������������Ŀ
//� Gets da Grupo                              				�
//��������������������������������������������������������
@ 20, 3 SAY   TitSX3("QEI_GRUPO")[1] SIZE 56,7 OF oBox PIXEL		//"Grupo"
@ 18,61 MSGET oGet_3 VAR cIE130Gru PICTURE PesqPict("QE3","QE3_GRUPO") F3 "QE3";
								VALID ExistCpo("QE3",cIE130Gru) .And. ;
								ExistCpo2("QEA",cIE130Gru,,STR0010);	//"Grupo n�o tem Produtos associados"
								.And. A130aCols(@cRevi,nOpc,oDlg) .And. oGet:oBrowse:Refresh() ;
								SIZE 58,10 OF oBox PIXEL
@ 20,131 SAY QIEXDeGr(cIE130Gru) SIZE 130,7 OF oBox PIXEL


//��������������������������������������������������������������Ŀ
//� O par�metro nOpc que corresponde ao aRotina[3][4] � alterado �
//�  para 6, indicando 'alteracao.  Isto � necess�rio para n�o'  �
//�  permitir a inclus�o de linhas na GetDados                   �
//����������������������������������������������������������������	
aRotina[3][4] := 6 // {OemToAnsi(STR0006),"QIE130Incl"  , 0 , 6}

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader e aCols a ser utilizado na getdados      �
//����������������������������������������������������������������
Q130FGet(cRevi,nOpc,oDlg)

oGet:= MSGetDados():New(50, 2, 240, 350, nOpc, "AllwaysTrue", "AllwaysTrue", "", .T.,,,,,,,, "QE130VlDel")
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(;
	oDlg, {|| IIf(lGravaOk:=QI130TdOk(), oDlg:End(),)},;
	{||oDlg:End(),lGrava:=.F. } ),;
	AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{75});
	)

aRotina[3][4] := 3 

If lGravaOk
	Begin Transaction
		lGravaOk := A130GrvST()
		nReg := QEI->(Recno())  // Torno o novo como atual.
		If !lGravaOK
			Help(" ",1,"A010NAOGRV")
		Else
			//Processa Gatilhos
			EvalTrigger()
		EndIf
	End Transaction
EndIf

dbSelectArea(cAlias)
dbGoto(nReg)

Return .T.


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIE130Alte� Autor � Vera Lucia S. Simoes  � Data � 09/06/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao Skip-Teste Grupo  -  Incl./Alter.  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIE130Alte(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Par�metros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QIE130Alte(cAlias,nReg,nOpc)

Local cRevi		:= ""
Local lGravaOk := .F.
Local oDlg		:= NIL
Local oGet_1 	:= NIL
Local oGet_2 	:= NIL
Local oGet_3 	:= NIL
Local oBox

Private cIE130For := Space(TamSX3("QEI_FORNEC")[1])
Private cIE130LjF := Space(TamSX3("QEI_LOJFOR")[1])
Private cIE130Gru := Space(TamSX3("QEI_GRUPO")[1])
Private nPosEns	:= 0
Private nPosSkT	:= 0
Private nPosSkI 	:= 0
Private nUsado		:= 0
Private aHeader	:= {}
Private aCols		:= {}
Private oGet		:= NIL
Private aEnsaios	:= {}

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) ;
				FROM 150,3 TO 388,613 OF oMainWnd PIXEL	// "Skip-Teste Grupo"

@ 000,000 SCROLLBOX oBox SIZE 0,0 OF oDlg

cIE130For := QEI->QEI_FORNEC
cIE130LjF := QEI->QEI_LOJFOR
cIE130Gru := QEI->QEI_GRUPO

//������������������������������������������������������Ŀ
//� Gets do Fornecedor                         				�
//��������������������������������������������������������
@ 5,03 SAY TitSX3("QEI_FORNEC")[1] SIZE 56,07 OF oBox PIXEL  
@ 3,61 MSGET oGet_1 VAR cIE130For PICTURE PesqPict("SA2","A2_COD") ;
					WHEN .F. ;			
					SIZE 66,10 OF oBox PIXEL  
//������������������������������������������������������Ŀ
//� Gets da Loja                               				�
//��������������������������������������������������������
@ 5,131 SAY TitSX3("QEI_LOJFOR")[1] SIZE 56, 7 OF oBox PIXEL 
@ 3,189 MSGET oGet_2 VAR cIE130LjF PICTURE PesqPict("SA5","A5_LOJA") ;
					WHEN .F. ;
				   SIZE 15,10 OF oBox PIXEL						
//������������������������������������������������������Ŀ
//� Gets da Grupo                              				�
//��������������������������������������������������������
@ 20, 3 SAY   TitSX3("QEI_GRUPO")[1] SIZE 56,7 OF oBox PIXEL		//"Grupo"
@ 18,61 MSGET oGet_3 VAR cIE130Gru PICTURE PesqPict("QE3","QE3_GRUPO") ;
							WHEN .F. ;								
							SIZE 66,10 OF oBox PIXEL
@ 20,131 SAY QIEXDeGr(cIE130Gru) SIZE 130,7 OF oBox PIXEL

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader e aCols a ser utilizado na getdados      �
//����������������������������������������������������������������
Q130FGet(cRevi,nOpc,oDlg)

oGet:= MSGetDados():New(50,2,190,312,nOpc,"AllwaysTrue","AllwaysTrue","",.T.,,,,,,,,"QE130VlDel")
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,;
				{|| IIf(lGravaOk:=QI130TdOk(), oDlg:End(),)},{||lGrava:=.F., oDlg:End()} ),;
				AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{75}))

If lGravaOk
	Begin Transaction
		lGravaOk := A130GrvST()
		nReg := QEI->(Recno())  // Torno o novo como atual.
		If !lGravaOK
			Help(" ",1,"A010NAOGRV")
		Else
			//Processa Gatilhos
			EvalTrigger()
		EndIf
	End Transaction
EndIf

dbSelectArea(cAlias)
dbGoto(nReg)

Return .T.


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIE130Del � Autor � Vera Lucia S. Simoes  � Data � 09/06/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualiza��o Skip-Teste Grupo  -  Incl./Alter.  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIE130Del(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Par�metros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QIE130Del(cAlias,nReg,nOpc)

Local cRevi		:= ""
Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3	:= NIL
Local lDeleta  := .T.
Local oBox

Private cIE130For := Space(TamSX3("QEI_FORNEC")[1])
Private cIE130LjF := Space(TamSX3("QEI_LOJFOR")[1])
Private cIE130Gru := Space(TamSX3("QEI_GRUPO")[1])
Private aHeader 	:= {}
Private aCols		:= {}
Private nUsado		:= 0
Private oGet		:= NIL
Private cCod		:= ""
Private cChvQEZ	:= ""
Private aEnsaios	:= {}
Private nPosEns	:= 0
Private nPosSkT	:= 0
Private nPosSkI	:= 0

//��������������������������������������������������������������Ŀ
//� Salva a integridade dos campos de Bancos de Dados            �
//����������������������������������������������������������������
dbSelectArea("SX2")  // Posiciona pq. rotinas internas utilizam inf. do SX2
dbSeek("QEI")

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) FROM 150,3 TO 388,613 OF oMainWnd PIXEL	// "Skip-Teste Grupo"

@ 000,000 SCROLLBOX oBox SIZE 0,0 OF oDlg

cIE130For := QEI->QEI_FORNEC
cIE130LjF := QEI->QEI_LOJFOR
cIE130Gru := QEI->QEI_GRUPO

//������������������������������������������������������Ŀ
//� Gets do Fornecedor                         				�
//��������������������������������������������������������
@ 5,03 SAY TitSX3("QEI_FORNEC")[1] SIZE 56,07 OF oBox PIXEL  
@ 3,61 MSGET oGet_1 VAR cIE130For PICTURE PesqPict("SA2","A2_COD") ;
					WHEN .F. ;			
					SIZE 66,10 OF oBox PIXEL  
//������������������������������������������������������Ŀ
//� Gets da Loja                               			 �
//��������������������������������������������������������
@ 5,131 SAY TitSX3("QEI_LOJFOR")[1] SIZE 56, 7 OF oBox PIXEL 
@ 3,189 MSGET oGet_2 VAR cIE130LjF PICTURE PesqPict("SA5","A5_LOJA") ;
					WHEN .F. ;
				   SIZE 15,10 OF oBox PIXEL						
//������������������������������������������������������Ŀ
//� Gets da Grupo                              			 �
//��������������������������������������������������������
@ 20, 3 SAY   TitSX3("QEI_GRUPO")[1] SIZE 56,7 OF oBox PIXEL		//"Grupo"
@ 18,61 MSGET oGet_3 VAR cIE130Gru PICTURE PesqPict("QE3","QE3_GRUPO") ;
							WHEN .F. ;								
							SIZE 66,10 OF oBox PIXEL
@ 20,131 SAY QIEXDeGr(cIE130Gru) SIZE 130,7 OF oBox PIXEL
	
//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader e aCols a ser utilizado na getdados      �
//����������������������������������������������������������������
Q130FGet(cRevi,nOpc,oDlg)

oGet:= MSGetDados():New(50,2,190,312,nOpc,"AllwaysTrue","AllwaysTrue","",.F.)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,;
					{||oDlg:End(),lDeleta:=.T.},	{||oDlg:End(),lDeleta:=.F.} ),;
				AlignObject(oDlg,{oBox,oGet:oBrowse},1,,{75}))

If lDeleta
	Begin Transaction
		dbSelectArea(cAlias)
		cCod := cIE130For+cIE130LjF+cIE130Gru
		dbSetOrder(1)
		dbSeek(xFilial("QEI")+cCod)
		While !Eof() .And. xFilial("QEI") == QEI_FILIAL .And. ;
			cCod == QEI_FORNEC+QEI_LOJFOR+QEI_GRUPO
			//��������������������������������������������������������������Ŀ
			//� Deleta o registro                                            �
			//����������������������������������������������������������������
			RecLock(cAlias,.F.,.T.)
			dbDelete()
			MsUnLock()
		
			//���������������������������������������������������������������Ŀ
			//� Deleta o Controle Skip-Teste por Grupo                        �
			//�����������������������������������������������������������������
			QEO->(dbSetOrder(1))
			If QEO->(dbSeek( xFilial("QEO")+cCod+QEI->QEI_ENSAIO ))
				RecLock("QEO", .F.)
				QEO->(dbDelete())
				MsUnLock()
			EndIf
			
			//���������������������������������������������������������������Ŀ
			//� Deleta o Historico Skip-Teste do Ensaio                       �
			//�����������������������������������������������������������������
			cChvQEZ := QEI->QEI_FORNEC+QEI->QEI_LOJFOR+QEI->QEI_GRUPO+QEI->QEI_ENSAIO
			QEZ->(dbSetOrder(2))
			QEZ->(dbSeek(xFilial("QEZ")+cChvQEZ))
			While QEZ->QEZ_FILIAL+QEZ->QEZ_FORNEC+QEZ->QEZ_LOJFOR+QEZ->QEZ_GRUPO+;
				QEZ->QEZ_ENSAIO == xFilial("QEZ")+cChvQEZ .And. !QEZ->(Eof())
				RecLock("QEZ", .F.)
				QEZ->(dbDelete())
				MsUnLock()
				QEZ->(dbSkip())
			Enddo
			QEZ->(dbSetOrder(1))
			dbSelectArea("QEI")
			dbSkip()
		EndDo	
	End Transaction
EndIf

dbSelectArea(cAlias)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A130GrvST � Autor � Vera Lucia S. Simoes  � Data � 10/06/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava os Skip-Testes por Grupo                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A130GrvST()

Local nx ,ny , nMaxArray := Len(aCols)
Local cChvQEZ
Local nOrdSA2 := SA2->(IndexOrd())
Local nOrdQE3 := QE3->(IndexOrd())

//���������������������������������������Ŀ
//� Revalido os dados                     �
//�����������������������������������������
SA2->(dbSetOrder(1))
If !SA2->(dbSeek(xFilial("SA2")+cIE130For+cIE130LjF))
	SA2->(dbSetOrder(nOrdSA2))
	Return .F.
EndIf
SA2->(dbSetOrder(nOrdSA2))

QE3->(dbSetOrder(1))
If !QE3->(dbSeek(xFilial("QE3")+cIE130Gru))
	QE3->(dbSetOrder(nOrdQE3))
	Return .F.
EndIf
QE3->(dbSetOrder(nOrdQE3))

//���������������������������������������Ŀ
//� Grava o arquivo QEI                   �
//�����������������������������������������
dbSelectArea("QEI")
QEI->(dbSetOrder(1))

For nX := 1 to nMaxArray
	dbSelectArea("QEI")
	If !Acols[nX][nUsado+1]	.And. ;// Nao esta deletado
			!Empty(aCols[nX][nPosSkT]) // Skip-Teste nao vazio
		If dbSeek(xFilial("QEI")+cIE130For+cIe130LjF+cIE130Gru+aCols[nX][nPosEns])
			RecLock("QEI",.F.)   // Lock
		Else
			RecLock("QEI",.T.)   // Append
			QEI->QEI_FILIAL := xFilial("QEI")
			QEI->QEI_FORNEC := cIE130For
			QEI->QEI_LOJFOR := cIE130LjF
			QEI->QEI_GRUPO  := cIE130Gru
			QEI->QEI_ENSAIO := aCols[nX][nPosEns]
		Endif

		For ny := 1 to Len(aHeader)
			If aHeader[ny][10] <> "V"
				cVar := alltrim(aHeader[ny][2])
				Replace &cVar. With aCols[nx][ny]
			Endif
		Next ny
		MsUnLock()
	Else	// Se cancelou ou alterou para zero
		//���������������������������������������Ŀ
		//� Cancela o Skip-Teste do Ensaio        �
		//�����������������������������������������
		If dbSeek(xFilial("QEI")+cIE130For+cIE130LjF+cIE130Gru+aCols[nX][nPosEns])
			RecLock("QEI",.F.)
			dbDelete()
			MsUnLock()

			//���������������������������������������������������������������Ŀ
			//� Deleta o Controle Skip-Teste por Grupo                        �
			//�����������������������������������������������������������������
			QEO->(dbSetOrder(1))
			If QEO->(dbSeek(xFilial("QEO")+cIE130For+cIe130LjF+cIE130Gru+aCols[nX][nPosEns]))
				RecLock("QEO", .F.)
				QEO->(dbDelete())
				MsUnLock()
			EndIf

			//���������������������������������������������������������������Ŀ
			//� Deleta o Historico Skip-Teste do Ensaio                       �
			//�����������������������������������������������������������������
			cChvQEZ := QEI->QEI_FORNEC+QEI->QEI_LOJFOR+QEI->QEI_GRUPO+QEI->QEI_ENSAIO
			QEZ->(dbSetOrder(2))
			QEZ->(dbSeek(xFilial("QEZ")+cChvQEZ))
			While QEZ->QEZ_FILIAL+QEZ->QEZ_FORNEC+QEZ->QEZ_LOJFOR+QEZ->QEZ_GRUPO+;
					QEZ->QEZ_ENSAIO == xFilial("QEZ")+cChvQEZ .And. !QEZ->(Eof())
				RecLock("QEZ", .F.)
				QEZ->(dbDelete())
				MsUnLock()
				QEZ->(dbSkip())
			Enddo
			QEZ->(dbSetOrder(1))
		EndIf
	EndIf
Next nx

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A130WhST � Autor � Vera Lucia S. Simoes  � Data � 10/06/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Define a clausula WHEN para o campo Skip-Teste             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A130WhST()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A130WhST()
Local lRetu := .t.
Local nPos

//�����������������������������������������������������Ŀ
//� Verifica se j� definiu o skip-teste individual      �
//�������������������������������������������������������
nPos := aScan(aEnsaios, { |x| x[1] == aCols[n][nPosEns] })
If nPos < 1
	Help(" ",1,"A130GRUVAZ")	// "Grupo de Produtos nao tem ensaios em comum"
	lRetu := .F.
Else	
	If aEnsaios[nPos][3] <> 0 
		MsgInfo(OemToAnsi(STR0011),OemToAnsi(STR0009)) // "O Skip-Teste referente a ensaio est� definido como individual."  "Skip-Teste por Grupo"
		lRetu := .F.
	EndIf
EndIf

Return(lRetu)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A130Acols� Autor � Marcelo/Vera          � Data � 16/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega vetor aCols para a GetDados                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A130Acols(ExpC1,ExpN1)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Revisao do Produto                                  ���
���          � ExpN1: Opcao selecionada                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function A130Acols(cRevi,nOpc,oDlg)
Local n
Local nI := 0   
Local nX

nUsado := Len(aHeader)

//��������������������������������������������������������������Ŀ
//� Guarda as posicoes dos campos p/ posterior consistencia      �
//����������������������������������������������������������������
nPosEns := aScan(aHeader, { |x| alltrim(x[2]) == 'QEI_ENSAIO' })
nPosSkT := aScan(aHeader, { |x| alltrim(x[2]) == 'QEI_SKPTES' })
nPosAli := aScan(aHeader, { |x| alltrim(x[2]) == 'QEI_ALI_WT' })
nPosRec := aScan(aHeader, { |x| alltrim(x[2]) == 'QEI_REC_WT' })

//��������������������������������������������������������������Ŀ
//� Seleciona os Ensaios comuns dos Produtos deste Grupo         �
//����������������������������������������������������������������
aEnsaios:={}

QEA->(dbSetOrder(1))
If QEA->(dbSeek(xFilial("QEA")+cIE130Gru))
	While QEA->QEA_FILIAL+QEA->QEA_GRUPO == xFilial("QEA")+cIE130Gru .And. !QEA->(Eof())
		// Identifica os ensaios mensuraveis
		If QE7->(dbSeek(xFilial("QE7")+QEA->QEA_PRODUT))
			While QE7->QE7_FILIAL+QE7->QE7_PRODUT == ;
				xFilial("QE7")+QEA->QEA_PRODUT .And. !QE7->(Eof())
				nPos := Ascan(aEnsaios, { |x| x[1] == QE7->QE7_ENSAIO })
				If nPos == 0
					Aadd(aEnsaios, { QE7->QE7_ENSAIO, 1, 0 })	// Ensaio, ocorr. e S.T. Indiv.
					nPos := Len(aEnsaios)
				Else
					aEnsaios[nPos][2]++
				EndIf
				QEH->(dbSetOrder(1))
				If QEH->(dbSeek( xFilial("QEH")+cIE130For+cIE130LjF+QEA->QEA_PRODUT+QE7->QE7_ENSAIO))
					aEnsaios[nPos][3] := QEH->QEH_SKPTES
				EndIf
				QE7->(dbSkip())
			EndDo
		EndIf

		// Identifica os ensaios texto
		QE8->(dbSetOrder(1))
		If QE8->(dbSeek(xFilial("QE8")+QEA->QEA_PRODUT))
			While QE8->QE8_FILIAL+QE8->QE8_PRODUT == ;
				xFilial("QE8")+QEA->QEA_PRODUT .And. !QE8->(Eof())
				nPos := Ascan(aEnsaios, { |x| x[1] == QE8->QE8_ENSAIO })
				If nPos == 0
					Aadd(aEnsaios, { QE8->QE8_ENSAIO, 1, 0 })	// Ensaio, ocorr. e S.T. Indiv.
					nPos := Len(aEnsaios)
				Else
					aEnsaios[nPos][2]++
				EndIf
				QEH->(dbSetOrder(1))
				If QEH->(dbSeek( xFilial("QEH")+cIE130For+cIE130LjF+QEA->QEA_PRODUT+QE8->QE8_ENSAIO))
					aEnsaios[nPos][3] := QEH->QEH_SKPTES
				EndIf
				QE8->(dbSkip())
			EndDo
		EndIf
		QEA->(dbSkip())
	EndDo
EndIf

//��������������������������������������������������������������Ŀ
//� Inicializa o aCols                                           �
//����������������������������������������������������������������
aCols := {}

//������������������������������������������������������������������Ŀ
//� Alimenta vetor aCols com os Ensaios comuns do Grupo              �
//��������������������������������������������������������������������
For nI := 1 to Len(aEnsaios)
	aadd(aCols,Array(nUsado+1))	// Cria novo elemento no acols
	nCnt := Len(aCols)
	// Alimenta o aCols
	aCols[nCnt][ascan(aHeader,{|x| alltrim(x[2])=='QEI_ENSAIO'})] := aEnsaios[nI][1]
	aCols[nCnt][ascan(aHeader,{|x| alltrim(x[2])=='QEI_DESENS'})] := QIEXDeEn(aEnsaios[nI][1])
	aCols[nCnt][ascan(aHeader,{|x| alltrim(x[2])=='QEI_SKPIND'})] := aEnsaios[nI][3]

	QEI->(dbSetOrder(1))
	If QEI->(dbSeek(xFilial("QEI")+cIE130For+cIE130LjF+cIE130Gru+aEnsaios[nI][1]))
		aCols[nCnt][nPosSkT] := QEI->QEI_SKPTES
	Else
		aCols[nCnt][nPosSkT] := 0
	EndIf
	If nPosAli > 0 .and. nPosRec > 0
	aCols[Len(aCols),nPosAli] := "QEI"
		If IsHeadRec(aHeader[nPosRec,2])
			aCols[Len(aCols),nPosRec] := QEI->(RecNo())
		EndIf
	Endif
	aCols[nCnt][nUsado+1] := .F.
Next nI

//��������������������������������������������������������������Ŀ
//� Ordena Ensaios de acordo com o campo Ensaio                  �
//����������������������������������������������������������������
aCols := asort(aCols,,, { | x,y | x[nPosEns] < y[nPosEns] } )

Return(.T.)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QE130VlDel� Autor � Eduardo de Souza      � Data � 21/03/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se linha pode ser deletada.                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QE130VlDel()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QE130VlDel()

Local lRet:= .T.

If Acols[n,nPosSkT] == 0
	lRet:= .F.
EndIf

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q130FGet  � Autor � Rafael S. Bernardi    � Data � 30/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta o aHeader e aCols usando FillGetDados                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q130FGet(cRevi,nOpc,oDlg)                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function Q130FGet(cRevi,nOpc,oDlg)

If nOpc != 3
	FillGetDados(nOpc,"QEI",1      ,       ,           ,         ,         ,          ,        ,       ,{|| A130aCols(@cRevi,nOpc,@oDlg)},       ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols                         ,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
Else
	FillGetDados(nOpc,"QEI",1     ,      ,             ,         ,         ,          ,        ,       ,                                 ,  .T.  ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty                 ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
EndIf

dbSelectArea("SX3")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QI130TdOk
Fun��o de valida��o de linha
@author marco.guimaraes
@since 15/09/14
@return lRet
/*/
//-------------------------------------------------------------------
Function QI130TdOk()
Local lRet := .T.
Local nSkpTeste := aScan(aHeader, { |x| alltrim(x[2]) == 'QEI_SKPTES' })
Local nEnsaio := aScan(aHeader, { |x| alltrim(x[2]) == 'QEI_ENSAIO' })
Local cMsgErro := "" 
Local i:= 0

For i := 1 To Len(aCols)
	If aCols[i, nSkpTeste] < 1
		cMsgErro += "<br>" + aCols[i, nEnsaio] 
	EndIf
Next

If !Empty(cMsgErro) 
	lRet := .F.
	Help("", 1, "QI130SKTT",, STR0012 + cMsgErro, 4, 1) // Valor inv�lido do Skip-Teste para o(os) ensaio(os):
EndIf

Return lRet