#INCLUDE "QPPA340.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QPPA340  � Autor � Robson Ramiro A. Olive� Data � 15.10.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � PSA                                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPA340(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PPAP                                                       ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  , 0, 1,,.F.},; 	//"Pesquisar"
					{ OemToAnsi(STR0002), "PPA340Roti", 0, 2},;		 	//"Visualizar"
					{ OemToAnsi(STR0003), "PPA340Roti", 0, 3},;		 	//"Incluir"
					{ OemToAnsi(STR0004), "PPA340Roti", 0, 4},;		 	//"Alterar"
					{ OemToAnsi(STR0005), "PPA340Roti", 0, 5},;		 	//"Excluir"
					{ OemToAnsi(STR0006), "QPPR340(.T.)", 0,6,,.T.} } 	//"Imprimir"

Return aRotina

Function QPPA340()

//���������������������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                                �
//�����������������������������������������������������������������������������
Private cCadastro := OemToAnsi(STR0007) //"PSA Amostras Iniciais"

Private aRotina := MenuDef()

DbSelectArea("QL0")
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"QL0",,,,,,)

Return


/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �PPA340Roti  � Autor � Robson Ramiro A.Olivei� Data �15.10.03  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para Visualizacao                                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void PPA340Visu(ExpC1,ExpN1,ExpN2)                           ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                     ���
���          � ExpN1 = Numero do registro                                   ���
���          � ExpN2 = Numero da opcao                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PPA340Roti(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local lOk 			:= .F.
Local aCposVis		:= {}
Local aButtons		:= {}
Local oPanel1
Local oPanel2
Local oSize
Local oEnch

Private nItem	:= 1
Private nItem2	:= 1
Private nItem3	:= 1

Private lRELDIM := .F.
Private lRELMAT := .F.
Private lRELESP := .F.
Private lRELESM := .F.

Private lCOPIAP := .F.
Private lPLACA	:= .F.
Private lPVACEI	:= .F.

If nOpc == 2 .or. nOpc == 5
	aButtons := {{"BMPVISUAL",	{ || QPPR340() }, OemToAnsi(STR0008), OemToAnsi(STR0051) }} //"Visualizar/Imprimir"###"Vis/Prn"
Endif

If nOpc == 3 .or. nOpc == 4
	aButtons := {{"EDIT", { || QPP340APRO() }, OemToAnsi(STR0009), OemToAnsi(STR0052) }} //"Aprovar/Desaprovar"###"Apr/Des"
Endif

aCposVis := { 	"QL0_PECA",		"QL0_REV", 		"QL0_RAINUM",	"QL0_OCM",; 
				"QL0_DTOCM", 	"QL0_NOMARQ", 	"QL0_INDARQ",	"QL0_DTARQ",;
				"QL0_DTARQ", 	"QL0_SEGREG",	"QL0_NUMPED",	"QL0_MATREF",;
				"QL0_FORNEC", 	"QL0_CDCNOR",	"QL0_DTCDC",	"QL0_ESPPSA",;
				"QL0_DTPSA", 	"QL0_PADRAO", 	"QL0_DTPADR",	"QL0_APROVA",;
				"QL0_DTAPROVA" }

If nOpc == 4
	If !QPPVldAlt(QL0->QL0_PECA,QL0->QL0_REV,QL0->QL0_APROVA)
		Return
	Endif
Endif

If nOpc == 5
	If !QPPVldExc(QL0->QL0_REV,QL0->QL0_APROVA)
		Return
	Endif
Endif


DbSelectArea(cAlias)

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize := FwDefSize():New( .F. )

oSize:AddObject( "CIMA"  ,  100,  30, .T., .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "BAIXO",  100, 70, .T., .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//��������������������������������������������������������������Ŀ
//� Monta Dialog                                                 �
//����������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE cCadastro ;  //"PSA Amostras Iniciais"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
							
RegToMemory("QL0",(nOpc == 3))

//��������������������������������������������������������������Ŀ
//� Adiciona Panel                                               �
//����������������������������������������������������������������
oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[2,3])

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

//��������������������������������������������������������������Ŀ
//� Monta Enchoice                                               �
//����������������������������������������������������������������
oEnch:=MsMGet():New("QL0",nReg,nOpc, , , ,aCposVis,oSize:aPosObj[1],,,,,,oPanel1,,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

QPP340TELA(nOpc, oPanel2)
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP340TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, ,aButtons ) centered

If lOk .and. (nOpc == 3 .or. nOpc == 4)
	PPA340Grav(nOpc)
Endif

If nOpc == 5 .and. lOk
	A340Dele()
Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QPP340TELA� Autor � Robson Ramiro A.Olivei� Data � 15.10.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Tela para informacoes do ScrollBox                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPP340TELA(ExpN1, ExpO1)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao do mBrowse									  ���
���          � ExpO1 = Dialog       									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA340                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPP340TELA(nOpc,oDlg)

Local oScrollBox 	:= NIL
Local oPanel		:= NIL
Local oGroup1, oGroup2, oGroup3, oGroup4, oGroup5
Local oQTDE, oREGENT, oETIQUE, oDTEQUI, oNMOLDE, oINDMOD, oNAPRIN, oEXPLIC
Local oRELDIM, oRELMAT, oRELESP, oRELESM, oCOPIAP, oPLACA, oPVACEI, oESTADO
Local oRad, oRad2, oRad3

DEFINE FONT oFont NAME "Arial" SIZE 7,15

If nOpc <> 3
	QPP340CHEC()
Endif


@ 058,003 MSPANEL oPanel PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE 390,012 OF oDlg
@ 004,180 SAY OemToAnsi(STR0010) COLOR CLR_WHITE SIZE 065,010 OF oPanel PIXEL //"IDENTIFICACAO"

//��������������������������������������������������������������Ŀ
//� Monta Scrool com a tela                                   	 �
//����������������������������������������������������������������
oScrollBox := TScrollBox():New(oDlg,,,,,.T.,.F.,.T.)
oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

@ 002,002 GROUP oGroup1 TO 155,378 LABEL OemToAnsi(STR0011) COLOR CLR_RED OF oScrollBox PIXEL //"ENVIO"

@ 015, 010 RADIO oRad VAR nItem 3D SIZE 150, 11 PROMPT;
							OemToAnsi(STR0012),; //"Produto novo"
							OemToAnsi(STR0013),; //"Produto modificado"
							OemToAnsi(STR0014),; //"Produto proveniente de um novo molde"
							OemToAnsi(STR0015),; //"Produto proveniente de um molde modificado"
							OemToAnsi(STR0016),; //"Produto proveniente de um equipamento retocado"
							OemToAnsi(STR0017),; //"Produto fabricado em uma nova fabrica"
							OemToAnsi(STR0018),; //"Produto fabricado em uma nova linha"
							OemToAnsi(STR0019),; //"Reapresentacao de uma fabricacao do grupo PSA"
							OemToAnsi(STR0020),; //"Produto entregue em uma nova planta PSA"
							OemToAnsi(STR0021),; //"Processo modificado"
							OemToAnsi(STR0022),; //"Novo procedimento de fabricacao"
							OemToAnsi(STR0023) OF oScrollBox PIXEL //"Outro Motivo"


@ 145,010 SAY OemToAnsi(STR0024) SIZE 040,015 OF oScrollBox PIXEL FONT oFont //"Quantidade"

@ 145,045 MSGET oQTDE VAR M->QL0_QTDE PICTURE PesqPict("QL0", "QL0_QTDE");
			SIZE 040,005 OF oScrollBox PIXEL FONT oFont

@ 145,130 SAY OemToAnsi(STR0025) SIZE 060,015 OF oScrollBox PIXEL FONT oFont //"No. Registro Entrega"

@ 145,190 MSGET oREGENT VAR M->QL0_REGENT PICTURE PesqPict("QL0", "QL0_REGENT");
			SIZE 040,005 OF oScrollBox PIXEL FONT oFont

@ 145,250 SAY OemToAnsi(STR0026) SIZE 060,015 OF oScrollBox PIXEL FONT oFont //"No. Etiqueta GALIA"

@ 145,310 MSGET oETIQUE VAR M->QL0_ETIQUE PICTURE PesqPict("QL0", "QL0_ETIQUE");
			SIZE 040,005 OF oScrollBox PIXEL FONT oFont


@ 165,002 GROUP oGroup2 TO 240,378 LABEL OemToAnsi(STR0027) COLOR CLR_RED OF oScrollBox PIXEL //"MEIOS DE FABRICACAO"

@ 180, 010 RADIO oRad2 VAR nItem2 3D SIZE 150, 11 PROMPT;
							OemToAnsi(STR0028),; //"Seriado validado"
							OemToAnsi(STR0029),; //"Seriado nao validado"
							OemToAnsi(STR0030),; //"Nao seriado"
							OemToAnsi(STR0031) OF oScrollBox PIXEL //"Validacao pela montadora"

@ 230,010 SAY OemToAnsi(STR0032) SIZE 080,015 OF oScrollBox PIXEL FONT oFont //"Dt. do Equip. Definitivo"

@ 230,080 MSGET oDTEQUI VAR M->QL0_DTEQUI PICTURE PesqPict("QL0", "QL0_DTEQUI");
			SIZE 040,005 OF oScrollBox PIXEL FONT oFont

@ 230,130 SAY OemToAnsi(STR0033) SIZE 060,015 OF oScrollBox PIXEL FONT oFont //"No. Molde Impresso"

@ 230,190 MSGET oNMOLDE VAR M->QL0_NMOLDE PICTURE PesqPict("QL0", "QL0_NMOLDE");
			SIZE 040,005 OF oScrollBox PIXEL FONT oFont

@ 230,250 SAY OemToAnsi(STR0034) SIZE 060,015 OF oScrollBox PIXEL FONT oFont //"Indice Modif. Equip."

@ 230,310 MSGET oINDMOD VAR M->QL0_INDMOD PICTURE PesqPict("QL0", "QL0_INDMOD");
			SIZE 040,005 OF oScrollBox PIXEL FONT oFont
					 
@ 250,002 GROUP oGroup3 TO 270,378 LABEL OemToAnsi(STR0035) COLOR CLR_RED OF oScrollBox PIXEL //"AMOSTRAS"

@ 260,010 SAY OemToAnsi(STR0036) SIZE 140,015 OF oScrollBox PIXEL FONT oFont //"Numero de apresentacao dentro do indice"

@ 260,150 MSGET oNAPRIN VAR M->QL0_NAPRIN PICTURE PesqPict("QL0", "QL0_NAPRIN");
			SIZE 080,005 OF oScrollBox PIXEL FONT oFont

@ 280,002 GROUP oGroup4 TO 340,378 LABEL OemToAnsi(STR0037) COLOR CLR_RED OF oScrollBox PIXEL //"EXPLICACOES/COMENTARIOS"

@ 290,010 MSGET oEXPLIC VAR M->QL0_EXPLIC SIZE 360, 005 OF oScrollBox PIXEL

@ 310,010 SAY OemToAnsi(STR0038) SIZE 090,015 OF oScrollBox PIXEL FONT oFont //"Acondicionamento em serie ?"

@ 320, 010 RADIO oRad3 VAR nItem3 3D SIZE 100, 11 PROMPT;
							OemToAnsi(STR0039),; //"Sim"
							OemToAnsi(STR0040) OF oScrollBox PIXEL //"Nao"

@ 350,002 GROUP oGroup5 TO 370,378 LABEL OemToAnsi(STR0041) COLOR CLR_RED OF oScrollBox PIXEL //"COMPOSICAO DO RELATORIO"

@ 360,010 CHECKBOX oRELDIM VAR lRELDIM SIZE 006,006 OF oScrollBox PIXEL
@ 360,020 SAY OemToAnsi(STR0042) SIZE 080,010 OF oScrollBox PIXEL //"Relatorio Dimensional"

@ 360,100 CHECKBOX oRELMAT VAR lRELMAT SIZE 006,006 OF oScrollBox PIXEL
@ 360,110 SAY OemToAnsi(STR0043) SIZE 080,010 OF oScrollBox PIXEL //"Relatorio Mat. Prima"

@ 360,200 CHECKBOX oRELESP VAR lRELESP SIZE 006,006 OF oScrollBox PIXEL
@ 360,210 SAY OemToAnsi(STR0044) SIZE 080,010 OF oScrollBox PIXEL //"Relatorio Especific."

@ 360,300 CHECKBOX oRELESM VAR lRELESM SIZE 006,006 OF oScrollBox PIXEL
@ 360,310 SAY OemToAnsi(STR0045) SIZE 080,010 OF oScrollBox PIXEL //"Relatorio Espec. Materiais"

@ 380,002 GROUP oGroup5 TO 410,378 LABEL OemToAnsi(STR0046) COLOR CLR_RED OF oScrollBox PIXEL //"ELEMENTOS ANEXOS"

@ 390,010 CHECKBOX oCOPIAP VAR lCOPIAP SIZE 006,006 OF oScrollBox PIXEL
@ 390,020 SAY OemToAnsi(STR0047) SIZE 080,010 OF oScrollBox PIXEL //"Copia PV Ens. Oficial"

@ 390,100 CHECKBOX oPLACA VAR lPLACA SIZE 006,006 OF oScrollBox PIXEL
@ 390,110 SAY OemToAnsi(STR0048) SIZE 080,010 OF oScrollBox PIXEL //"Placas de Amostras"

@ 390,200 CHECKBOX oPVACEI VAR lPVACEI SIZE 006,006 OF oScrollBox PIXEL
@ 390,210 SAY OemToAnsi(STR0049) SIZE 150,010 OF oScrollBox PIXEL //"PV de aceitacao da 1a. Planta Utilizadora"

@ 400,010 SAY OemToAnsi(STR0050) SIZE 100,015 OF oScrollBox PIXEL FONT oFont //"Estado de Utilizacao Estimado"

@ 400,120 MSGET oESTADO VAR M->QL0_ESTADO PICTURE PesqPict("QL0", "QL0_ESTADO");
			SIZE 060,005 OF oScrollBox PIXEL FONT oFont

@ 420,000 SAY " " SIZE 010,010 OF oScrollBox PIXEL


If nOpc == 2 .or. nOpc == 5
	oQTDE:lReadOnly 	:= .T.
	oREGENT:lReadOnly 	:= .T.
	oETIQUE:lReadOnly 	:= .T.
	oDTEQUI:lReadOnly 	:= .T.
	oNMOLDE:lReadOnly 	:= .T.
	oINDMOD:lReadOnly 	:= .T.
	oNAPRIN:lReadOnly 	:= .T.
	oEXPLIC:lReadOnly 	:= .T.
	oRELDIM:lReadOnly 	:= .T.
	oRELMAT:lReadOnly 	:= .T.
	oRELESP:lReadOnly 	:= .T.
	oRELESM:lReadOnly 	:= .T.
	oCOPIAP:lReadOnly 	:= .T.
	oPLACA:lReadOnly 	:= .T.
	oPVACEI:lReadOnly 	:= .T.
	oESTADO:lReadOnly 	:= .T.
	oRad:lReadOnly 		:= .T.
	oRad2:lReadOnly 	:= .T.
	oRad3:lReadOnly 	:= .T.
Endif

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA340Grav� Autor � Robson Ramiro A Olivei� Data � 15/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Gravacao - Incl./Alter.                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA340Grav(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Exp1N = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA340                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA340Grav(nOpc)

Local nCont
Local bCampo		:= { |nCPO| Field(nCPO) }
Local lGraOk		:= .T.

DbSelectArea("QL0")
	
Begin Transaction

If ALTERA
	RecLock("QL0",.F.)
Else	                   
	RecLock("QL0",.T.)
Endif

For nCont := 1 To FCount()
	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QL0"))
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif
Next nCont

QL0->QL0_REVINV	:= Inverte(M->QL0_REV)

QL0->QL0_MOTENV	:= StrZero(nItem,2)
QL0->QL0_MEIOFA	:= Str(nItem2,1,0)
QL0->QL0_ACONSE	:= Str(nItem3,1,0)

QL0->QL0_RELDIM := Iif(lRELDIM, "1", "0")
QL0->QL0_RELMAT := Iif(lRELMAT, "1", "0")
QL0->QL0_RELESP := Iif(lRELESP, "1", "0")
QL0->QL0_RELESM := Iif(lRELESM, "1", "0")

QL0->QL0_COPIAP	:= Iif(lCOPIAP, "1", "0")
QL0->QL0_PLACA	:= Iif(lPLACA, "1", "0")
QL0->QL0_PVACEI	:= Iif(lPVACEI, "1", "0")

MsUnLock()
	
End Transaction
				
Return lGraOk

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    �PP340TudOk � Autor � Robson Ramiro A. Olive� Data � 15.10.03 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para inclusao/alteracao geral                  ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP340TudOk                                                  ���
��������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                        ���
��������������������������������������������������������������������������Ĵ��
���Uso       � QPPA340                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PP340TudOk

Local lRetorno	:= .T.

If Empty(M->QL0_PECA) .or. Empty(M->QL0_REV)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

If INCLUI
	If !ExistChav("QL0",M->QL0_PECA+M->QL0_REV)
		lRetorno := .F.
		Help(" ",1,"JAGRAVADO")  // Campo ja Existe
	Endif
	If !ExistCpo("QK1",M->QL0_PECA+M->QL0_REV)
		lRetorno := .F.
		Help(" ",1,"REGNOIS")  // Nao existe amarracao
	Endif
Endif

Return lRetorno


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A340Dele � Autor � Robson Ramiro A Olivei� Data � 15/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Fucao para exclusao                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A340Dele()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA340                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A340Dele()

DbSelectArea("QL0")

Begin Transaction

RecLock("QL0",.F.)
DbDelete()
MsUnLock()

End Transaction

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QPP340CHEC� Autor � Robson Ramiro A Olivei� Data � 20/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Fucao para checagem das variaveis                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPP340CHEC()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA340                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPP340CHEC

nItem	:= Val(QL0->QL0_MOTENV)
nItem2 	:= Val(QL0->QL0_MEIOFA)
nItem3 	:= Val(QL0->QL0_ACONSE)

lRELDIM := (QL0->QL0_RELDIM == "1")
lRELMAT := (QL0->QL0_RELMAT == "1")
lRELESP := (QL0->QL0_RELESP == "1")
lRELESM := (QL0->QL0_RELESM == "1")

lCOPIAP := (QL0->QL0_COPIAP == "1")
lPLACA 	:= (QL0->QL0_PLACA == "1")
lPVACEI	:= (QL0->QL0_PVACEI == "1")

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QPP340APRO� Autor � Robson Ramiro A.Olivei� Data � 20.10.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Aprova PSA                                				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPP340APRO(Void)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                 									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA340                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPP340APRO()
                    
DbSelectArea("QAA")
DbSetOrder(6)
If Dbseek(Upper(cUserName))
	M->QL0_DTAPRO	:= Iif(Empty(M->QL0_DTAPRO), dDataBase, CtoD(" / / "))
	M->QL0_APROVA	:= Iif(Empty(M->QL0_APROVA), cUserName, Space(15))
Else
	messagedlg(STR0053) //"O usu�rio logado n�o est� cadastrado no cadastro de usu�rios do m�dulo, portanto n�o poder� ser o aprovador"
Endif

Return .T.