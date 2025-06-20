#INCLUDE "ofioa130.ch"
#Include "Protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIOA130 � Autor �  Fabio/Renata         � Data � 07/07/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Habilidade do Produtivo                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico  (Modelo3)                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION OFIOA130

PRIVATE aRotina := MenuDef()
Private aGets    := {}
Private aTela    := {}
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemToAnsi(STR0007) , nIndVAI := 0 //Habilidade de Produtivos
Private nUsado := 0
Private nQtdReg:= 0
Private cChave

Private aCores := {{'VAI->VAI_FUNPRO == "1" .AND. EMPTY(VAI->VAI_DATDEM)','BR_VERDE'},; // Tecnicos Produtivos
{'!EMPTY(VAI->VAI_DATDEM)','BR_VERMELHO'},; // Tecnicos Demitidos
{'VAI->VAI_FUNPRO<>"1"','BR_PRETO'}} // Tecnicos Nao Produtivos

mBrowse( 6, 1,22,75,"VAI",,,,,,aCores)

Return
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �OF130     � Autor �Renata                 � Data � 06/06/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo 3                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � OF130(CALIAS,NREG,NOPC)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � OFICINA                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OF130(cAlias, nReg, nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0
//
Local bCampo   := { |nCPO| Field(nCPO) } , _ni := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Private aCpoEnchoice  :={}
Private nOpcao := 0
Private oLbaSrv , oFolder
Private cArqTra , cArqTra1 , cArqIndex1 := CriaTrab(NIL, .F.) , cArqIndex2 := CriaTrab(NIL, .F.)    && Cria Indice de trabalho
Private aTELA[0][0], aGETS[0], aHeader[0],n:=1, nIndVO2 := 0
Private nOpcX := nOpc
Private nLenAcols := 0

If VAI->VAI_FUNPRO != "1" .or. VAI->(RecCount()) == 0
	Help("  ",1,"APEFUNPRO",,VAI->VAI_CODTEC+" "+VAI->VAI_NOMTEC,4,1)
	DbSelectArea("VAI")
	Return .t.
EndIf
If !Empty(VAI->VAI_DATDEM)
	Help("  ",1,"FUNCJADEM",,VAI->VAI_CODTEC+" "+VAI->VAI_NOMTEC,4,1)
	DbSelectArea("VAI")
	Return .t.
EndIf

//��������������������������������������������������������������Ŀ
//� Cria variaveis M->????? da Enchoice                          �
//����������������������������������������������������������������
RegToMemory("VAI",.T.)
DbSelectArea("VAI")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

//��������������������������������������������������������������Ŀ
//� Opcoes de acesso para a Modelo 3                             �
//����������������������������������������������������������������
Do Case
	Case nOpc == 3 && Incluir
		nOpcE:=2
		nOpcG:=3
	Case nOpc == 4 && Alterar
		nOpcE:=2
		nOpcG:=4
	Case nOpc == 2 && Visualizar
		nOpcE:=2
		nOpcG:=2
	Case nOpc == 5  && Excluir
		nOpcE:=2
		nOpcG:=5
	Otherwise      && Duplica
		nOpcE:=4
		nOpcG:=2
EndCase

//��������������������������������������������������������������Ŀ
//� Cria aHeader e aCols da GetDados                             �
//����������������������������������������������������������������
nUsado:=0
dbSelectArea("SX3")
dbSeek("VOC")
aHeader:={}
While !Eof().And.(x3_arquivo=="VOC")
	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VOC_CODPRO/VOC_NOMPRO/VOC_DESMAR])
		nUsado:=nUsado+1
		Aadd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,X3CBOX(),SX3->X3_RELACAO})
		&("M->"+x3_campo) := CriaVar(x3_campo)
	Endif
	dbSkip()
End

If INCLUI
	aColsSer := { Array(nUsado + 1) }
	aColsSer[1,nUsado+1] := .F.
	For nCntFor:=1 to nUsado
		aColsSer[1,nCntFor]:=CriaVar(aHeader[nCntFor,2])
	Next
Else // ... caso contr�rio deve-se montar a acols com os registros da base
	aColsSer:={}
	dbSelectArea("VOC")
	dbSetOrder(1)
	DbSeek(xFilial("VOC")+M->VAI_CODTEC)
	While !eof() .and. xFilial("VOC")+M->VAI_CODTEC == VOC->VOC_FILIAL + VOC->VOC_CODPRO
		AADD(aColsSer,Array(nUsado+1))
		For nCntFor:=1 to nUsado
			if aHeader[nCntFor,10] == "V"
				SX3->(DBSetOrder(2))
				SX3->(DBSeek(aHeader[nCntFor,2]))
				aColsSer[Len(aColsSer),nCntFor] := &(sx3->x3_relacao)
				if aHeader[nCntFor,2] == "VOC_DESSER"
					cMarca := aColsSer[Len(aColsSer),fg_posvar("VOC_CODMAR","aHeader")]
					cServ := aColsSer[Len(aColsSer),fg_posvar("VOC_CODSER","aHeader")]
					aColsSer[Len(aColsSer),nCntFor] := Posicione("VO6",2,xFilial("VO6")+cMarca+cServ,"VO6_DESSER")
				endif
			else
				aColsSer[Len(aColsSer),nCntFor] := FieldGet(FieldPos(aHeader[nCntFor,2]))
			endif
		Next
		aColsSer[Len(aColsSer),nUsado+1]:=.F.
		DbSkip()
	EndDo
EndIf

//��������������������������������������������������������������Ŀ
//� Executa a Modelo 3                                           �
//����������������������������������������������������������������

cTitulo       :=STR0007
cAliasEnchoice:="VAI"
cAliasGetD    :="VOC"
cLinOk        :="OA130LINOK"
cTudOk        :="OA130TUDOK"
cFieldOk      :="OA130FOK"
aCpoEnchoice  :={}

DbSelectArea("SX3")
DbSeek("VAI")
While !Eof().and.(x3_arquivo=="VAI")
	if X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VAI_VALOR/VAI_CC/VAI_CENTRA/VAI_PAGER/VAI_EMAIL/VAI_FONE/VAI_REGIAO/VAI_TURNO/VAI_RATE/VAI_CUSTO/VAI_LOCAL/VAI_LOCLZR/VAI_LOCLZF/VAI_TIPO/VAI_ALOCA/VAI_LOCLZB])
		AADD(aCpoEnchoice,x3_campo)
	Endif
	DbSkip()
End

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 120 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
//AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
//AAdd( aObjects, { 10, 10, .T. , .F. } )  //list box inferior
//tamanho para resolucao 1024*768
//aSizeAut[3]:= 508
//aSizeAut[5]:= 1016
// Fator de reducao de 0.8
//for nCntFor := 1 to Len(aSizeAut)
//	aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
//next

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

//criado panel pois nao respeitava os tamanhos em MDI - Rafael 09/04/10
//	@ 014,003 MSpanel oPanel1 VAR "" OF oDlg SIZE 314,115 LOWERED
@ aPosObj[1,1],aPosObj[1,2] MSpanel oPanel1 VAR "" OF oDlg SIZE aPosObj[1,4],aPosObj[1,3] LOWERED

// 	aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]
EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{1,1,aPosObj[1,3],aPosObj[1,4]},,3,,,,oPanel1,,.F.)
oGetDados := MsNewGetDados():New(aPosObj[2,1]+15,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinok,cTudOk,,,0,999,cFieldOk,,,oDlg,aHeader,aColsSer )
//   oGetDados:nMax := nQtdReg
//oGetDados:oBrowse:bEditCol := { ||  FS_OA130DES() }
oGetDados:oBrowse:bDelete  := {|| OA130DELP() }

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcao := 1, If(OA130TUDOK(),oDlg:End(),nOpcao := 0)}, { ||oDlg:End() } ) //Importa servicos!

If nOpcao == 1 .and. nOpcX <> 2
	FS_OA130GRA(nOpc)
Endif

DbSelectArea("VAI")

Return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_OA130GR�Autor  �Fabio               � Data �  08/26/00   ���
�������������������������������������������������������������������������͹��
���Desc.     �Grava a Habilidade do Produtivo                             ���
�������������������������������������������������������������������������͹��
���Uso       � Oficina                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_OA130GRA(nOpc,lDupl)

Local lRet := .t. , i := 0
Local nCntFor,nCntFor2
Local nFCount := 0
Private lMsHelpAuto := .t., lMsFinalAuto := .f.
Default lDupl := .F.

//��������������������������������������������������������������Ŀ
//� Executar processamento                                       �
//����������������������������������������������������������������
If nOpc # 2
	
	for nCntFor := 1 to Len(oGetDados:aCols)
		DbSelectArea("VOC")
		DbSetOrder(1)
		cCodMar := oGetDados:aCols[nCntFor,fg_posvar("VOC_CODMAR","aHeader")]
		cCodSer := oGetDados:aCols[nCntFor,fg_posvar("VOC_CODSER","aHeader")]
		if !Empty(cCodSer) .or. nOpc == 5
			lAchou := DbSeek(xFilial("VOC")+M->VAI_CODTEC+cCodMar+cCodSer)
			//
			if oGetDados:aCols[nCntFor,Len(oGetDados:aCols[oGetDados:nAt])] == .t. .or. nOpc == 5
				if lAchou .and. nOpc # 3
					reclock("VOC",.f.,.t.)
					dbdelete()
					msunlock()
				endif
			else
				reclock("VOC",!lAchou)
				VOC->VOC_CODPRO := M->VAI_CODTEC
				VOC->VOC_FILIAL := xFilial("VOC")
				For nCntFor2 := 1 to Len(aHeader)
					&(aHeader[nCntFor2,2]) := oGetDados:aCols[nCntFor,nCntFor2]
				next
			endif
		endif
	Next
	
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_OF130DUP Autor �Renata/FABIO           � Data � 06/06/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Duplica os dados ja cadastrados para outro codigo de mecan ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FS_OF130DUP(CALIAS,NREG,NOPC)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � OFICINA                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_OF130DUP(cAlias,nReg,nOpc)

return .t.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_DESTEC � Autor �Renata                 � Data � 06/06/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Busca o nome do tecnico                                    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FS_DESTEC()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � OFICINA                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_DESTEC()
********************

Local lRet := .t.

DbSelectArea("VAI")
DbSetOrder(1)
DbSeek(xFilial("VAI")+cTecDes)
cDesTec := VAI->VAI_NOMTEC
lRet := Found()
DbSeek(xFilial("VAI")+cCodTec)

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_OA130DE�Autor  �Fabio               � Data �  08/29/00   ���
�������������������������������������������������������������������������͹��
���Desc.     � Grava duplicacao                                           ���
�������������������������������������������������������������������������͹��
���Uso       � Oficina                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_OA130DES()

If ReadVar() == "M->VOC_CODSER"
	If !Empty(M->VOC_CODMAR) .and. !Empty(M->VOC_CODSER)
		FG_SEEK("VO6","FG_MARSRV(M->VOC_CODMAR,M->VOC_CODSER)+M->VOC_CODSER",2,.f.)
		M->VOC_DESSER   := VO6->VO6_DESSER
		oGetDados:aCols[oGetDados:nAt,fg_posvar("VOC_CODSER","aHeader")] := M->VS3_GRUITE
		oGetDados:oBrowse:Refresh()
	Else
		M->VOC_DESSER   := Space(Len(VO6->VO6_DESSER))
		oGetDados:oBrowse:Refresh()
	Endif
Endif

Return .t.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OA130LINOK�Autor  �Ricardo Farinelli   � Data �  14/08/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida a Linha da Msgetdb                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao de Concessionarias                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OA130LINOK()
Local lRet 		 := .T.
Local nCntFor

If nOpcx == 5 .OR. nOpcX == 2
	Return (.t.)
Endif

If nOpcx == 3 .and. VOC->(DBseek(xFilial("VOC")+M->VAI_CODTEC+M->VOC_CODMAR+M->VOC_CODSER))
	Help(" ",1,"JAGRAVADO")
	Return  .f.
Endif

// ############################################################
// # Pula registros deletados                                 #
// ############################################################
If oGetDados:aCols[oGetDados:nAt,len(oGetDados:aCols[oGetDados:nAt])]
	Return .t.
EndIf
// ############################################################
// # Verifica campos obrigatorios                             #
// ############################################################

For nCntFor:=1 to Len(aHeader)
	If X3Obrigat(aHeader[nCntFor,2])  .and. (Empty(oGetDados:aCols[oGetDados:nAt,nCntFor]))
		Help(" ",1,"OBRIGAT2",,RetTitle(aHeader[nCntFor,2]),4,1)
		Return .f.
	EndIf
Next       
if Empty(oGetDados:aCols[oGetDados:nAt,fg_posvar("VOC_CODMAR","aHeader")]) .or. ;
	Empty(oGetDados:aCols[oGetDados:nAt,fg_posvar("VOC_CODSER","aHeader")])	
	return .f.
endif


Return  lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OA130TUDOK�Autor  �Ricardo Farinelli   � Data �  14/08/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida a Tela da Msgetdb                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao de Concessionarias                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OA130TUDOK()


If nOpcx==5 .or. nOpcx==2
	Return (.t.)
Endif

Return .t.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_IA130PESQAutor�Emilton              � Data �  16/10/01   ���
�������������������������������������������������������������������������͹��
���Desc.     � Pesquisa e nao perde o indice                              ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao de Concessionarias                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_IA130PESQ()

Local lRet

lRet := axPesqui()
DbSelectArea("VAI")
Return lRet




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � LOFIOA130   � Autor � Andre Luis Almeida � Data � 17/03/09 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Legenda do browse                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LOFIOA130()
Local aLegenda := {{'BR_VERDE'  ,STR0018},; // Tecnicos Produtivos
{'BR_PRETO'   ,STR0019},; // Tecnicos Nao Produtivos
{'BR_VERMELHO',STR0020}} // Tecnicos Demitidos
BrwLegenda(cCadastro,STR0017 ,aLegenda) //Legenda
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_IA130PESQAutor�Emilton              � Data �  16/10/01   ���
�������������������������������������������������������������������������͹��
���Desc.     � Pesquisa e nao perde o indice                              ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao de Concessionarias                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_VALIDSER()
dbSelectArea("VO6")
dbSetOrder(2)
dbSeek(xFilial("VO6")+M->VOC_CODMAR+M->VOC_CODSER)
M->VOC_DESSER := VO6->VO6_DESSER
Return(.t.)
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | OX001DELP  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Atualiza informacoes quando a linha da acols e deletada      |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA130DELP()
//
Local nCntFor

if oGetDados:aCols[oGetDados:nAt,Len(oGetDados:aCols[oGetDados:nAt])] == .t.
	for nCntFor := 1 to Len(oGetDados:aCols)
		if nCntFor != oGetDados:nAt .and. oGetDados:aCols[nCntFor,Len(oGetDados:aCols[oGetDados:nAt])] != .t.
			if oGetDados:aCols[nCntFor,fg_posvar("VOC_CODMAR","aHeader")] == M->VOC_CODMAR .and. ;
				oGetDados:aCols[nCntFor,fg_posvar("VOC_CODSER","aHeader")] == M->VOC_CODSER
				Help(" ",1,"JAGRAVADO")
				return .f.
			endif
		endif
	next
endif	
oGetDados:aCols[oGetDados:nAt,Len(oGetDados:aCols[oGetDados:nAt])] := !oGetDados:aCols[oGetDados:nAt,Len(oGetDados:aCols[oGetDados:nAt])]
oGetDados:oBrowse:refresh()
//
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | OX001DELP  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Atualiza informacoes quando a linha da acols e deletada      |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/

Function OA130FOK

Local nCntFor

If ReadVar() == "M->VOC_CODSER"
	
	for nCntFor := 1 to Len(oGetDados:aCols)
		
		if nCntFor != oGetDados:nAt .and. oGetDados:aCols[nCntFor,Len(oGetDados:aCols[oGetDados:nAt])] != .t.
			if oGetDados:aCols[nCntFor,fg_posvar("VOC_CODMAR","aHeader")] == M->VOC_CODMAR .and. ;
				oGetDados:aCols[nCntFor,fg_posvar("VOC_CODSER","aHeader")] == M->VOC_CODSER
				Help(" ",1,"JAGRAVADO")
				return .f.
			endif
		endif
	next
	
	If !Empty(M->VOC_CODMAR) .and. !Empty(M->VOC_CODSER)
		FG_SEEK("VO6","FG_MARSRV(M->VOC_CODMAR,M->VOC_CODSER)+M->VOC_CODSER",2,.f.)
		M->VOC_DESSER   := VO6->VO6_DESSER
		oGetDados:aCols[oGetDados:nAt,fg_posvar("VOC_DESSER","aHeader")] := M->VOC_DESSER
		oGetDados:oBrowse:Refresh()
	Else
		M->VOC_DESSER   := Space(Len(VO6->VO6_DESSER))
		oGetDados:aCols[oGetDados:nAt,fg_posvar("VOC_DESSER","aHeader")] := M->VOC_DESSER
		oGetDados:oBrowse:Refresh()
	Endif
Endif

return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | MenuDef    | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function MenuDef()
Local aRotina := { { STR0001 ,"FS_IA130PESQ", 0 , 1},;  //Pesquisar
{ STR0002 ,"OF130", 0 , 2},;       //Visualizar
{ STR0003 ,"OF130", 0 , 3},;       //Incluir
{ STR0004 ,"OF130", 0 , 4},;       //Alterar
{ STR0005 ,"OF130", 0 , 5},;       //Excluir
{ STR0017 ,"LOFIOA130", 0 , 2 ,0,.f.} } //Legenda
//                     { STR0017 ,"LOFIOA130", 0 , 3 ,2,.f.} } //Legenda
// { STR0006 ,"FS_OF130DUP", 0 , 3},; //Duplicar
Return aRotina
