#INCLUDE "PROTHEUS.CH"
#include "MSGRAPHI.CH"
#include "ATFC010.CH"


// 17/08/2009 - Ajuste para filiais com mais de 2 caracteres.

// TRADUCAO DE CH'S PARA PORTUGAL

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ATFC010  � Autor � Claudio D. de Souza   � Data � 23-09-2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta de valores ja depreciados de um bem                 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Atfc010()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Ativo Fixo                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
FUNCTION AtfC010

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := STR0001 //"Consulta gr�fica de bens depreciados"

//���������������������������������������Ŀ
//� Variaveis utilizadas para parametros  �
//� mv_par01	  // Da data     			 	|
//� mv_par02	  // Ate a data            |
//� mv_par03	  // Moeda                 |
//� mv_par04	  // Mostra / Vlr. deprec. / Deprec. Acumulada
//�����������������������������������������
Pergunte("AFC010",.T.)
If mv_par03 <= 0
	mv_par03 := Val(GetMv("MV_ATFMOED"))
Endif
Private aRotina := MenuDef()
//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"SN1")

Return

/*/
���������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Program   �Atfc010Con   � Autor � Claudio D. de Souza   � Data � 13.10.03 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta grafica das depreciacoes                             ���
����������������������������������������������������������������������������Ĵ��
���Uso       � Atfc010                                                       ���
����������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Function Atfc010Con(cAlias,nReg,nOpc)
Local aSize	
Local aObjects
Local aInfo	
Local aPosObj
Local oBold
Private cDtini:=mv_par01
Private cDtfim:=mv_par02

// Se op periodo ultrapassar um ano, avisa e nao permite a consulta.
If Val(Left(Dtos(cDtfim),6)) - Val(Left(Dtos(cDtini),6)) >= 100
	IW_MSGBOX(STR0004, STR0005,"STOP") //"Per�do ultrapassa o m�ximo permitido para a consulta, que � um ano"###"Aten��o"
	Return
Endif	
//������������������������������������������������������Ŀ
//� Faz o calculo automatico de dimensoes de objetos     �
//��������������������������������������������������������
aSize		:= MsAdvSize(,.F.,430)
aObjects	:= {{ 100, 157 , .T., .T. }}
aInfo		:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosObj	:= MsObjSize( aInfo, aObjects )

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

DEFINE MSDIALOG oDlg FROM 0,0 TO 450,770 PIXEL TITLE STR0001 //"Consulta gr�fica de bens depreciados"

// Layout da janela
@ 000, 000 BITMAP oBmp RESNAME "ProjetoAP" oF oDlg SIZE 50, 250 NOBORDER WHEN .F. PIXEL
@ 003, 060 SAY STR0006 + AllTrim(SN1->N1_DESCRIC) + STR0007 + Dtoc(cDtini) + STR0008 + Dtoc(cDtfim) FONT oBold PIXEL //"Deprecia��o "###" no per�do de "###" a "

@ 014, 050 TO 16 ,400 LABEL '' OF oDlg  PIXEL

ACTIVATE MSDIALOG oDlg ON INIT Atfc010Grap(oDlg, 1, aPosObj, nOpc) CENTERED

Return .T.


/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Program   � Atfc010Grap � Autor � Claudio D. de Souza   � Data � 24.09.03 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Monta grafico de depreciacao de bens do ativo                 ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   � Atfc010Grap                                                   ���
����������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                           ���
����������������������������������������������������������������������������Ĵ��
���Parametros�                                                               ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Function Atfc010Grap(oDlg, nGrafico, aPosObj, nOpc, cCbx)
Local nSerie := 0
Local oBold
Local aCbx 	:= { STR0009, STR0010 } //"Linhas"###"Barras"
Local nCbx	:= 1
Local oGraphic
Local o3d
Local oSerie
Local bWhile
Local bFor
Local bAction
Local nDeprecAc := 0  
Local dData	:= ""   
Local nVlrOc := 0 
Local cQuery := ""

Default cCbx := aCbx[1]

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

@ 020, 055 MSGRAPHIC oGraphic SIZE 327,158 OF oDlg PIXEL

@ 180, 145 	SAY STR0011 OF oDlg FONT oBold PIXEL //"Bens Depreciados"
@ 190, 145 	MSCOMBOBOX oSerie VAR cCbx ITEMS aCbx SIZE 060, 015 OF oDlg;
				PIXEL ON CHANGE (nCbx := oSerie:nAt,Atfc010Grap(oDlg, If(nCbx=2,4,1), aPosObj, nOpc, @cCbx))

@ 190, 208 	BUTTON STR0012 SIZE 40,14 OF oDlg PIXEL ACTION Atfc010Efeito(oGraphic, "ROTACAO-", nSerie) //"Rota��o &-"
@ 190, 251 	BUTTON STR0013 SIZE 40,14 OF oDlg PIXEL ACTION Atfc010Efeito(oGraphic, "ROTACAO+", nSerie) //"Rota��o &+"
@ 190, 294 	BUTTON o3D PROMPT "2D" SIZE 40,14 OF oDlg PIXEL ACTION Atfc010Efeito(oGraphic, "EFEITO", o3D)
@ 190, 337 	BUTTON STR0014 SIZE 40,14 OF oDlg PIXEL ACTION GrafSavBmp( oGraphic ) //"Salva &BMP"

@ 207, 050 	TO 209 ,400 LABEL '' OF oDlg  PIXEL
@ 212, 251 	BUTTON STR0015 SIZE 40,12 OF oDlg PIXEL ACTION CtbGrafPrint(oGraphic,STR0016,{STR0006 + SN1->N1_DESCRIC + STR0007 + Dtoc(cDtini) + STR0008 + Dtoc(cDtfim)},{{"",""}}, .F.) //"&Imprime"###"Deprecia��o"###"Deprecia��o "###" no per�do de "###" a "
@ 212, 294 	BUTTON STR0022 SIZE 40,12 OF oDlg PIXEL ACTION PmsGrafMail(oGraphic,STR0006 + SN1->N1_DESCRIC + STR0007 + Dtoc(cDtini) + STR0008 + Dtoc(cDtfim),; //"&E-mail"###"Deprecia��o "###" no per�do de "###" a "
																								 {STR0006 + SN1->N1_DESCRIC + STR0007 + Dtoc(cDtini) + STR0008 + Dtoc(cDtfim)},{}) //"Deprecia��o "###" no per�do de "###" a "
@ 212, 337 	BUTTON STR0017 SIZE 40,12 OF oDlg PIXEL ACTION oDlg:End() //"&Sair"

oGraphic:SetMargins( 15, 10, 10, 10 )

oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
oGraphic:SetTitle( ,STR0018, CLR_GREEN, A_RIGHTJUS , GRP_FOOT  ) //"Meses"
oGraphic:SetTitle( 	STR0019, "", CLR_GREEN, A_LEFTJUST , GRP_TITLE  ) //"Valores"

oGraphic:SetLegenProp( GRP_SCRTOP, CLR_YELLOW, GRP_SERIES, .F.)

nSerie   := oGraphic:CreateSerie(nGrafico)

If nSerie != GRP_CREATE_ERR
	// Localizo o valor de aquisicao do bem       
	cQuery := " SELECT N4_DATA, SUM(N4_VLROC" + Alltrim(Str(MV_PAR03)) + ") N4_VLROC FROM " + RetSqlName("SN4")  
	cQuery += " WHERE N4_FILIAL = '" + xFilial("SN4") + "' AND N4_CBASE = '" + SN1->N1_CBASE + "' AND " 
	cQuery += " N4_ITEM = '" + SN1->N1_ITEM + "' AND  N4_OCORR IN ('06','10','11') AND N4_TIPO = '01' AND "
	cQuery += " N4_TIPOCNT = '3' AND N4_DATA <= '" + DTOS(cDtfim) + "' AND D_E_L_E_T_ <> '*' " 
	cQuery += " GROUP BY N4_DATA "    

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TMP',.T.,.F.)	

	dbSelectArea("TMP")	   

	dbGoTop()

	While !Eof() 

		dData := STOD(TMP->N4_DATA)
		
		If (mv_par04 == 1, nVlrOc := TMP->N4_VLROC, nVlrOc += TMP->N4_VLROC)
			
		oGraphic:Add(nSerie, nVlrOc, DTOC(dData) ,CLR_HRED)

		dbSkip()
	End

	nVlrOC := 0
	dbCloseArea()
Else  
	ApMsgAlert(STR0020) //"N�o foi poss�vel criar a s�rie"
Endif   

Return .T.

/*/
���������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Program   �Atfc010Efeito� Autor � Claudio D. de Souza   � Data � 30.09.03 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Executa operacoes no grafico dependendo do parametro          ���
����������������������������������������������������������������������������Ĵ��
���Uso       � Atfc010                                                       ���
����������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Static Function Atfc010Efeito(oGraphic, cAcao, uParam1, uParam2, uParam3)

If oGraphic # Nil
	If cAcao = "EFEITO"
		oGraphic:l3D := !oGraphic:l3D
		If uParam2 = Nil
			uParam1:cCaption := If(oGraphic:l3D, "2D", "3D")
		Else
			If oGraphic:l3D
				uParam1:Show()
				uParam2:Hide()
			Else
				uParam2:Show()
				uParam1:Hide()
			Endif
		Endif
	ElseIf cAcao = "ROTACAO+" .And. oGraphic:l3D
		oGraphic:ChgRotat( uParam1, 1, .F. ) // nRotation tem que estar entre 1 e 30 passos	
	ElseIf cAcao = "ROTACAO-" .And. oGraphic:l3D
		oGraphic:ChgRotat( uParam1, 1, .T. ) // nRotation tem que estar entre 1 e 30 passos
	Endif
Endif

Return .T.

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �30/11/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
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
Local aRotina := {	{STR0002,"AxPesqui"		,	0, 1},;  //"Pesquisa"
               {STR0021,"AtfC010Con"	, 	0, 2} } //"Consulta"
Return(aRotina)
