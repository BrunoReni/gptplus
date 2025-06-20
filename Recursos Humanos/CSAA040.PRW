#include "dbtree.ch"
#include "Protheus.ch"
#include "font.ch"
#include "COLORS.CH"
#INCLUDE "CSAA040.CH"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSAA040  � Autor � Cristina Ogura        � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro dos Dados Coletados da Empresas Participantes     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSAA040                                                    ���
�������������������������������������������������������������������������Ĵ��
���Programado� Data   � BOPS �  Motivo da Alteracao                       ���
�������������������������������������������������������������������������Ĵ��
���Cecilia C.�07/07/14�TPZVTW�Incluido o fonte da 11 para a 12 e efetuada ���
���          �        �      �a limpeza.                                  ���
���Mariana M.�11/12/15�TUAHAD� Ajuste permitir que seja coletado os mesmos���
���			 �        �      � mesmos dados, com adicionais diferentes na ���
���			 �        �      � coleta da pesquisa.                        ���
���Victor A. �24/05/16�TVEIU7� Ajusta na atualiza��o dos valores do array ���
���			 �        �      � aGuarda.			                          ���
���Raquel H. �07/06/16�TVEIU7�Ajusta na carga das fun��es da filial corren���
���			 �        �      �te.  										  ���
���Oswaldo L �08-05-17�DRHPONTP11  �Projeto SOYUZ ajuste Ctree            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CSAA040
Local cFiltra			// Variavel para filtro
Local aIndFil:= {}		// Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		// Variavel para Filtro

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
//����������������������������������������������������������������
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0003)	//"Dados Coletados das Empresas Participantes"

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
dbSelectArea("RB0")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RB0","1")
bFiltraBrw 	:= {|| FilBrowse("RB0",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

dbSelectArea("RB0")
dbGotop()

mBrowse(6, 1, 22, 75, "RB0")

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("RB0",aIndFil)

dbSelectArea("RB0")
dbSetOrder(1)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Cs040Rot � Autor � Cristina Ogura        � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina que trata os dados das Empresas Participantes       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cs040Rot(cExpC1,nExpN1,nExpN2)                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAA040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs040Rot(cAlias,nReg,nOpc)
Local oDlg, o2Lbx
Local oGroup0, oGroup1, oGroup2
Local c2Lbx
Local aFields	:={}
Local nOpca := 0
Local cGera:= "N"

//��������������������������������������������������������������Ŀ
//� Variaveis para Dimensionar Tela		                         �
//����������������������������������������������������������������
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Local aAdv11Size	:= {}
Local aInfo11AdvSize:= {}
Local aObj11Size	:= {}
Local aObj11Coords	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}

Local aAdv21Size	:= {}
Local aInfo21AdvSize:= {}
Local aObj21Size	:= {}
Local aObj21Coords	:= {}

Local aAdv22Size	:= {}
Local aInfo22AdvSize:= {}
Local aObj22Size	:= {}
Local aObj22Coords	:= {}

Private cMesDiss, cMesOld
Private nHoraPesq
Private oSay, oGet
Private cSay
Private oArq2Tmp

Private aCols:={}
Private aHeader:={}
Private Continua:=.F.

Private aGuarda := {}

aFields :={"RB2_FILIAL","RB2_FUNCAO ","RB2_EMPRES","RB2_DESCCA"}

// Monta o aHeader para a Tela de Dados da Empresa
TrmHeader(@aHeader,aFields,"RB2")

// Cria arquivos temporarios para o Listbox
Cs040CriaArq()

// Monta o listbox com os dados das Funcoes
If !Cs040ListBox()
	Help("",1,"CS040NFUNC")
	Return
EndIf

// Monta os aCols possiveis - 1 para cada Funcao dependo da empresa selecionada
Cs040aCols(RB0->RB0_EMPRES)

cCodEmp	:= RB0->RB0_EMPRES
cNome 	:= RB0->RB0_NOME

dbSelectArea("RB2")
dbSetOrder(1)
If dbSeek(xFilial("RB2")+cCodEmp)
	cMesDiss	:= RB2->RB2_DISSID
	nHoraPesq	:= RB2->RB2_HORAS
Else
	cMesDiss	:= CriaVar("RB2->RB2_DISSID")
	nHoraPesq	:= CriaVar("RB2->RB2_HORAS")
EndIf

cMesOld := cMesDiss

dbSelectArea("TR2")
dbSetOrder(1)
dbGotop()

Cs040Troca(.T.)

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 037 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

aAdv1Size		:= aclone(aObjSize[1])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords )

aAdv11Size		:= aclone(aObj1Size[1])
aInfo11AdvSize	:= { aAdv11Size[2] , aAdv11Size[1] , aAdv11Size[4] , aAdv11Size[3] , 5 , 5 }
aAdd( aObj11Coords , { 060 , 000 , .F. , .T. } )
aAdd( aObj11Coords , { 030 , 000 , .F. , .T. } )
aAdd( aObj11Coords , { 018 , 000 , .F. , .T. } )
aAdd( aObj11Coords , { 048 , 000 , .F. , .T. } )
aAdd( aObj11Coords , { 035 , 000 , .F. , .T. } )
aAdd( aObj11Coords , { 010 , 000 , .F. , .T. } )
aObj11Size		:= MsObjSize( aInfo11AdvSize , aObj11Coords,,.T. )


aAdv2Size		:= aclone(aObjSize[2])
aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 0 , 5 }
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
aAdd( aObj2Coords , { 005 , 000 , .F. , .T. } )
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords,,.T. )


aAdv21Size		:= aclone(aObj2Size[1])
aInfo21AdvSize	:= { aAdv21Size[2] , aAdv21Size[1] , aAdv21Size[4] , aAdv21Size[3] , 5 , 5 }
aAdd( aObj21Coords , { 000 , 000 , .T. , .T., .T. } )
aObj21Size		:= MsObjSize( aInfo21AdvSize , aObj21Coords )

aAdv22Size		:= aclone(aObj2Size[3])
aInfo22AdvSize	:= { aAdv22Size[2] , aAdv22Size[1] , aAdv22Size[4] , aAdv22Size[3] , 5 , 5 }
aAdd( aObj22Coords , { 000 , 010 , .T. , .F. } )
aAdd( aObj22Coords , { 000 , 000 , .T. , .T. } )
aObj22Size		:= MsObjSize( aInfo22AdvSize , aObj22Coords )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM  aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

	//Cabecalho
	@ aObjSize[1,1],aObjSize[1,2] 	GROUP oGroup0 TO aObjSize[1,3],aObjSize[1,4] PIXEL

	@ aObj1Size[1,1],aObj11Size[1,2]	SAY OemToAnsi(STR0012) PIXEL	//"Empresa Participante: "
	@ aObj1Size[1,1],aObj11Size[2,2]	MSGET cCodEmp	WHEN .F. SIZE 10,7	PIXEL
	@ aObj1Size[1,1],aObj11Size[3,2]	MSGET cNome WHEN .F. SIZE 200,7 PIXEL

	@ aObj1Size[2,1],aObj11Size[1,2]	SAY OemToAnsi(STR0013)	PIXEL			//"              Mes Dissidio: "
	@ aObj1Size[2,1],aObj11Size[2,2]	MSGET cMesDiss 		PICTURE "@E 99";
											VALID Cs040MesDis();
											SIZE 20,7 PIXEL
	@ aObj1Size[2,1],aObj11Size[3,2]	SAY OemToAnsi(STR0014) 	PIXEL			//"Horas: "
	@ aObj1Size[2,1],aObj11Size[4,2]	MSGET nHoraPesq 	PICTURE "@E 999.99";
											VALID nHoraPesq > 0 SIZE 30,7 PIXEL	 HASBUTTON

	@ aObj1Size[2,1],aObj11Size[5,2]	SAY OemToAnsi(STR0020) PIXEL			//"Gerar Dados:"
	@ aObj1Size[2,1],aObj11Size[6,2]	MSGET cGera			PICTURE "@!";
											VALID Cs040Gera(cGera,cMesDiss,nHoraPesq) SIZE 10,7 PIXEL

	//ListBox
	@ aObj2Size[1,1],aObj2Size[1,2] GROUP oGroup1 TO aObj2Size[1,3],aObj2Size[1,4] PROMPT OemtoAnsi(STR0015) OF oDlg PIXEL 	// "Funcoes"
	dbSelectArea("TR2")
	@ aObj21Size[1,1]+5,aObj21Size[1,2] LISTBOX o2Lbx VAR c2Lbx FIELDS;
		HEADER 	OemtoAnsi(STR0016),;		//"Descricao Funcao"
				OemtoAnsi(STR0017);			//"Cod Funcao"
		COLSIZES 	GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
					GetTextWidth(0,"BBBBB") SIZE aObj21Size[1,3],aObj21Size[1,4]-5 OF oDlg PIXEL;
	ON CHANGE (Cs040Troca(.F.))
	o2Lbx:bLine:= {||{TR2->TR2_NOME, TR2->TR2_COD}}
	o2Lbx:bGotFocus:={|| Cs040Ver()}


	//GetDados
	@ aObj2Size[3,1]+3,aObj2Size[3,2] GROUP oGroup2 TO aObj2Size[3,3],aObj2Size[3,4] PROMPT '' OF oDlg PIXEL

	@ aObj22Size[1,1]+3,aObj22Size[1,2]	SAY OemToAnsi(STR0018) PIXEL		// "Funcao: "
	@ aObj22Size[1,1]+3,aObj22Size[1,2]+55	SAY oSay PROMPT cSay   OF oDlg PIXEL SIZE 100,7

	oGet:= MSGetDados():New(aObj22Size[2,1],aObj22Size[2,2],aObj22Size[2,3],aObj22Size[2,4],nOpc,"Cs040Ok","Cs040TOk","",.T.,,1, ,900,,,,,oDlg)
	oGet:oBrowse:bGotFocus:={|| Cs040Ver()}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=1,If(oGet:TudoOK(),oDlg:End(),nOpca:=0)},{|| nOpca:=0,oDlg:End()})

If nOpca == 1
	Begin Transaction
		Cs040Grava(cCodEmp)
	End Transaction
EndIf

dbSelectArea("TR2")
dbCloseArea()

If oArq2Tmp <> Nil
	oArq2Tmp:Delete()
	Freeobj(oArq2Tmp)
EndIf


dbSelectArea("SRJ")
dbSetOrder(1)
dbGotop()

dbSelectArea("SRA")
dbSetOrder(1)
dbGotop()

dbSelectArea("RB1")
dbSetOrder(1)
dbGotop()

dbSelectArea("RB0")

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Cs040ListBox � Autor � Cristina Ogura    � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta os listbox com os Funcoes                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cs040ListBox(nExpN1)			                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAA040       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs040ListBox()
Local lRet:= .F.

dbSelectArea("SRJ")
dbSetOrder(1)
dbGotop()
While !Eof()

	If SRJ->RJ_FILIAL == xFilial("SRJ")

		RecLock("TR2",.T.)
			TR2->TR2_NOME		:= SRJ->RJ_DESC
			TR2->TR2_COD		:= SRJ->RJ_FUNCAO
		MsUnlock()

    EndIf

	lRet := .T.
	dbSelectArea("SRJ")
	dbSkip()

EndDo

dbSelectArea("TR2")
dbSetOrder(1)
dbGotop()

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Cs040aCols � Autor � Cristina Ogura      � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria array aCols com os dados das pesquisa conf funcao     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cs040aCols(cExpC1)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Codigo da Empresa Participante                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAA040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs040aCols(cCodEmp)
Local nCntFor := 0
Local nUsado  := Len(aHeader)
Local nAcols  := 0
Local aAuxCols:={}
Local cChave  :=""
Local l1Vez   := .T.

// Monta o Acols para todos as Funcoes
dbSelectArea("TR2")
dbGotop()
While !Eof()
	aAuxCols := {}
	cChave 	 := xFilial("RB2")+cCodEmp+TR2->TR2_COD
	dbSelectArea("RB2")
	If dbSeek(cChave)
		While !Eof() .And. RB2->RB2_FILIAL+RB2->RB2_EMPRES+RB2->RB2_FUNCAO==;
								 cChave
			Aadd(aAuxCols,Array(nUsado+1))
			nAcols := Len(aAuxCols)
  			For nCntFor := 1 To Len(aHeader)
				If aHeader[nCntFor][10] != "V"
					aAuxCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
				Else
					aAuxCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
				EndIf
			Next nCntFor

			aAuxCols[nAcols][nUsado+1] := .F.

			If l1Vez
				cMesDiss	:= RB2->RB2_DISSID
				nHoraPesq	:= RB2->RB2_HORAS
				l1Vez := .F.
			EndIf
			dbSelectArea("RB2")
			dbSkip()
		EndDo
	Else
		dbSelectArea("SX3")
		dbSeek("RB2")
		Aadd(aAuxCols,Array(nUsado+1))
		nAcols := Len(aAuxCols)
		For nCntFor := 1 To Len(aHeader)
			aAuxCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
		Next nCntFor
		aAuxCols[1][nUsado+1] := .F.
	EndIf

	dbSelectArea("TR2")
	Aadd(aGuarda,{TR2->TR2_COD,aAuxCols})
	dbSkip()
EndDo

Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Cs040Troca� Autor � Cristina Ogura        � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao que troca o acols conforme a Funcao da Empresa       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Cs040Troca(lExpL1)	                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpL1 : Indica dar refresh nos objs ou nao                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA040                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs040Troca(l1Vez)
Local nPos:=0

cSay := TR2->TR2_NOME
nPos:= Ascan(aGuarda,{|x| x[1]== TR2->TR2_COD })

If nPos > 0
	aCols 	:={}
	aCols 	:=aGuarda[nPos][2]
//	n		:=Len(aCols)
	n		:= 1
EndIf

If !l1Vez

	oGet:ForceRefresh()
	oSay:Refresh()
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Cs040Ok     � Autor � Cristina Ogura      � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao que controla a Linha OK                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA040                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs040Ok()
Local nPosDt	:= Ascan(aHeader,{ |x| x[2] = "RB2_DTBASE"})
Local nPosFreq	:= Ascan(aHeader,{ |x| x[2] = "RB2_FREQ  "})
Local nPosSal	:= Ascan(aHeader,{ |x| x[2] = "RB2_SALARI"})
Local nPosHoras	:= Ascan(aHeader,{ |x| x[2] = "RB2_HORAS "})
Local nPosDiss	:= Ascan(aHeader,{ |x| x[2] = "RB2_DISSID"})
Local nPosBenef	:= Ascan(aHeader,{ |x| x[2] = "RB2_VLBENE"})
Local nPosAdic	:= Ascan(aHeader,{ |x| x[2] = "RB2_ADICIO"})
Local i
Local nPosFunc	:= Ascan(aGuarda,{|x| x[1]== TR2->TR2_COD })

If 	(nPosFreq>0 .And. nPosSal>0 .And. nPosHoras>0 .And. nPosDiss>0 .And. nPosDt>0) .And.;
	(Empty(aCols[n][nPosFreq]) .Or. Empty(aCols[n][nPosSal]) .Or.;
	 Empty(aCols[n][nPosHoras]) .Or. Empty(aCols[n][nPosDiss]) .Or.;
	 Empty(aCols[n][nPosDt])) .And.;
	 !aCols[n][Len(aCols[n])]
	Help("",1,"Cs040NPODE")		// Frequencia e Salario devem ser preenchidos
	Return .F.
EndIf

For i:= 1 To Len(aCols)
	If 	aCols[n][nPosDt]   == aCols[i][nPosDt] .And.;
		aCols[n][nPosFreq] == aCols[i][nPosFreq] .And.;
		aCols[n][nPosSal]  == aCols[i][nPosSal] .And.;
		aCols[n][nPosHoras]== aCols[i][nPosHoras] .And.;
		aCols[n][nPosDiss] == aCols[i][nPosDiss] .And.;
		aCols[n][nPosBenef] == aCols[i][nPosBenef] .And.;
		aCols[n][nPosAdic] == aCols[i][nPosAdic] .And.;
		!aCols[n][Len(aCols[n])] .And.;
		n # i
		Help("",1,"Cs040IGUAL")	// Este mes/ano ja existe.
		Return .F.
	EndIf
Next i

// TVEIU7 - Atualiza o array aGuarda pois ser� ele que ser� utilizado como base para gravar na RB2
aGuarda[nPosFunc][2] := aClone( aCols )

Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Cs040TOk    � Autor � Cristina Ogura      � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao que controla TUDO OK                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA040                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs040TOk()
Local nPosDt	:= Ascan(aHeader,{ |x| x[2] = "RB2_DTBASE"})
Local nPosFreq	:= Ascan(aHeader,{ |x| x[2] = "RB2_FREQ  "})
Local nPosSal	:= Ascan(aHeader,{ |x| x[2] = "RB2_SALARI"})
Local nPosHoras	:= Ascan(aHeader,{ |x| x[2] = "RB2_HORAS "})
Local nPosDiss	:= Ascan(aHeader,{ |x| x[2] = "RB2_DISSID"})
Local i

For i:= 1 To Len(aCols)
	If 	(nPosFreq>0 .And. nPosSal>0 .And. nPosHoras>0 .And. nPosDiss>0 .And. nPosDt>0) .And.;
		(Empty(aCols[i][nPosFreq]) .Or. Empty(aCols[i][nPosSal]) .Or.;
		 Empty(aCols[i][nPosHoras]) .Or. Empty(aCols[i][nPosDiss]).And.;
		 Empty(aCols[i][nPosDt])) .And.;
	 	 !aCols[i][Len(aCols[i])]
		Help("",1,"Cs040NPODE")		// Frequencia e Salario devem ser preenchidos
		Return .F.
	EndIf
Next i

Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Cs040CriaArq� Autor � Cristina Ogura      � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cria arquivo para gravar os dados do listbox 2              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA040                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs040CriaArq()
Local a2Stru:={}
Local cCond2:=""
Local aLstIndices := {}

Aadd(a2Stru,{"TR2_NOME"		,"C",30,0})
Aadd(a2Stru,{"TR2_COD"		,"C", TamSx3("RJ_FUNCAO")[1],0})

AAdd( aLstIndices, {"TR2_NOME"})

oArq2Tmp := RhCriaTrab('TR2', a2Stru, aLstIndices)

Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Cs040Atu    � Autor � Cristina Ogura      � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Atualiza os campos de Horas e Mes dissidio na getdados      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA040                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs040Atu()
Local nPosHora	:= Ascan(aHeader,{ |x| x[2] = "RB2_HORAS"})
Local nPosMes	:= Ascan(aHeader,{ |x| x[2] = "RB2_DISSID"})

If Empty(aCols[n][nPosHora])
	aCols[n][nPosHora]	:= nHoraPesq
EndIf

If Empty(aCols[n][nPosMes])
	aCols[n][nPosMes]	:= cMesDiss
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Cs040Ver    � Autor � Cristina Ogura      � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica os campos de Horas e Mes dissidio nos Gets         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA040                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs040Ver()
If Empty(cMesDiss) .Or. Empty(nHoraPesq)
	Help("",1,"Cs040EMPTY")	// Verifique os campos de dissidio ou Horas devem ser preenchidos
	Return .F.
EndIf
Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Cs040Mes    � Autor � Cristina Ogura      � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica os campos de Horas e Mes dissidio nos Gets         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA040                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs040Mes()
Local cVar:= &(ReadVar())

If 	Empty(cVar) .Or.;
	Val(cVar) <1 .Or. ;
	Val(cVar) >12
	Help("",1,"Cs040MES")
	Return .F.
EndIf

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Cs040Grava� Autor � Cristina Ogura        � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava os registros referente as Empresas                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
���          � ExpC2 : Codigo calendario                                  ���
���          � ExpC3 : Codigo curso                                       ���
���          � ExpC4 : Codigo turma                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �TRMA060                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Cs040Grava(cCodEmp)
Local nx:=0, ny:=0, nz:=0, nt:=0
Local cFuncao := ""
Local aAnterior := {}
Local cCampo, xConteudo
Local nTam := 0
Local nPosFreq:=0

// Grava os dados da pesquisa por empresa e funcao
For nz:=1 To Len(aGuarda)
	cFuncao		:= aGuarda [nz][1]
	aCols		:= aClone(aGuarda[nz][2])
	nPosFreq	:= 0
	nPosFreq	:= Ascan(aHeader,{ |x| x[2] = "RB2_FREQ  "})
	nTam 		:= Len(aCols)
	aAnterior 	:= {}

	If 	Empty(aCols[Len(aCols)][nPosFreq])
		Loop
	EndIf

	dbSelectArea("RB2")
	dbSetOrder(1)
	If dbSeek(xFilial("RB2")+cCodEmp+cFuncao)
		While !Eof() .And. xFilial("RB2")+cCodEmp+cFuncao ==;
				RB2->RB2_FILIAL+RB2->RB2_EMPRES+RB2->RB2_FUNCAO
				Aadd(aAnterior, RecNo())
			dbSkip()
		EndDo
	EndIf

	For nx:=1 to nTam
		If nx <= Len(aAnterior)
			dbGoto(aAnterior[nx])
			RecLock("RB2",.F.)
			//--Verifica se esta deletado
			If aCols[nx][Len(aCols[nx])]
				dbDelete()
				MsUnlock()
				MSMM(RB2_OBSERV,,,,2)
				Loop
			EndIf
		Else
			If aCols[nx][Len(aCols[nx])]
				Loop
			EndIf
			RecLock("RB2",.T.)
			Replace RB2->RB2_FILIAL 	With xFilial("RB2")
			Replace RB2->RB2_EMPRES		With cCodEmp
			Replace RB2->RB2_FUNCAO		With cFuncao
		EndIf

		For nt := 1 To Len(aHeader)
			If aHeader[nt][10] # "V"
				cCampo	 := Trim(aHeader[nt][2])
				xConteudo := aCols[nx][nt]
				Replace &cCampo With xConteudo
			EndIf
			If aHeader[nt][8] == "M"   // Campo Memo
				MsUnlock()
				MSMM(RB2_OBSERV,,,aCols[nx][nt],1,,,"RB2","RB2_OBSERV")
				RecLock("RB2",.F.)
			EndIf
		Next nt

		MsUnlock()
    Next nx
Next nz
Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Cs040Gera � Autor � Cristina Ogura        � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os registro de salario e Freq desta Empresa            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : S ou N                                             ���
���          � ExpC2 : Mes                                                ���
���          � ExpN2 : Horas                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �TRMA060                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Cs040Gera(cGera,cMes,nHoras)
Local cAuxFun:="", aAuxCols:={}
Local cAlias:=Alias(), nOrder:= IndexOrd(), nReg:=RecNo()
Local nSalario:=0, nFreq:=0
Local nPosFreq	:= Ascan(aHeader,{ |x| x[2] = "RB2_FREQ  "})
Local nPosSal	:= Ascan(aHeader,{ |x| x[2] = "RB2_SALARI"})
Local nPosHoras	:= Ascan(aHeader,{ |x| x[2] = "RB2_HORAS "})
Local nPosDiss	:= Ascan(aHeader,{ |x| x[2] = "RB2_DISSID"})
Local nx, nz

If !cGera $ "S/N"
	Help("",1,"CS040GERA")			// Preencha com S ou N para gerar os dados de salario e remuneracao para esta empresa.
	Return .F.
EndIf

If cGera == "S"
	nOp:=AVISO(STR0021,STR0022,{STR0023,STR0024})  //"Aviso"###"Sera gerado dados da Frequencia e Salario desta Empresa "###"Confirma"###"Redigita"
	If nOp == 1
		For nz:=1 To Len(aGuarda)
			cAuxFuncao	:= aGuarda [nz][1]
			aAuxCols	:= aClone(aGuarda[nz][2])
			nSalario	:= 0
			nFreq		:= 0
			dbSelectArea("SRJ")
			dbSetOrder(1)
			If dbSeek(xFilial("SRJ")+cAuxFuncao)
				nSalario := SRJ->RJ_SALARIO
			EndIf

			dbSelectArea("SRA")
			dbSetOrder(7)
			If dbSeek(xFilial("SRA")+cAuxFuncao)
				While !Eof() .And. xFilial("SRA")+cAuxFuncao == ;
						SRA->RA_FILIAL+SRA->RA_CODFUNC
					//�����������������������������������������������������Ŀ
					//� Considera apenas funcionarios ativos na Base do SRA �
					//�������������������������������������������������������
					If SRA->RA_SITFOLH <> "D"
						nFreq := nFreq + 1
					EndIf

					dbSkip()
				EndDo
			EndIf

			For nx:= 1 To Len(aAuxCols)
				If nx== 1
					aAuxCols[nx][nPosSal]  := nSalario
					aAuxCols[nx][nPosFreq] := nFreq
					aAuxCols[nx][nPosDiss] := cMes
					aAuxCols[nx][nPosHoras]:= nHoras
				Else
					aAuxCols[nx][Len(aAuxCols[n])] := .T.
				EndIf
			Next nx

			aGuarda[nz][2] := aClone(aAuxCols)
		Next nz
	EndIf
EndIf

Cs040Troca(.F.)

dbSelectArea(cAlias)
dbSetOrder(nOrder)
dbGoto(nReg)

Return .T.


// Verifica o mes do dissidio e se for alteracao mostra a mensagem de que sera alterado todos os mes do acols
Function Cs040MesDis()
Local nOp:= 0
Local nPosDiss	:= Ascan(aHeader,{ |x| x[2] = "RB2_DISSID"})
Local aAuxAcols :={}
Local nx, ny

If 	Val(cMesDiss)< 1 .Or. Val(cMesDiss)>13
	Help("",1,"Cs040Mes")
	Return .F.
EndIf

If !Empty(cMesDiss) .And. cMesOld # cMesDiss .And. !Empty(cMesOld)
	nOp:=AVISO(STR0025,STR0026,{STR0023,STR0024})  //"Aviso"###"Sera alterado todos os itens para este Dissidio"###"Confirma"###"Redigita"
	If nOp == 1			// Confirma
		For nx:=1 To Len(aGuarda)
			aAuxAcols:= aClone(aGuarda[nx][2])
			If 	nPosDiss > 0
				For ny:=1 To Len(aAuxaCols)
					aAuxAcols[ny][nPosDiss] := cMesDiss
				Next ny
			EndIf
			aGuarda[nx][2] := aClone(aAuxAcols)
		Next nx
		Cs040Troca(.F.)
		cMesOld := cMesDiss
	Else
		Return .F.
	EndIf
EndIf

Return .T.

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �27/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �CSAA040                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/

Static Function MenuDef()

 Local aRotina := { 	{ STR0001, 'PesqBrw', 0, 1,,.F.}, ;	//'Pesquisar'
						{ STR0002, 'Cs040Rot', 0, 4}}		//'Dados Pesquisa'

Return aRotina
