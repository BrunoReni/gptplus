#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINA018.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FINA018   � Autor � Alvaro Camillo Neto   � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao do Cadastro de Cambio de Moedas Contabeis       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �SIGAFIN                                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Generico                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FINA018(aRotAuto,nOpcAuto)
Local lRet := .T.

PRIVATE aRotina    := MenuDef()  			// Array com opcoes do menu da mBrowse
PRIVATE cCadastro := OemtoAnsi(STR0001)	//"Atualizacao de Indice"
PRIVATE lFIN018AUT := .F. 					// Determina a execucao automatica da rotina quando .T.

DEFAULT aRotAuto := {}
DEFAULT nOpcAuto := 3

If Len(aRotAuto) > 0
	lFIN018AUT := .T.
EndIf

//�����������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//�������������������������������
If AliasInDic("FIT") .And.  AliasInDic("FIU")

	If lFIN018AUT
		//��������������������������������������������������������������Ŀ
		//�Tratamento a ser considerado quando chamada pela MsExecAuto() �
		//����������������������������������������������������������������

		PRIVATE aAutoCab := Aclone(aRotAuto)

		MBrowseAuto(nOpcAuto,aAutoCab,"FIU")

	Else
		mBrowse( 6, 1,22,75,"FIU")
	EndIf

Else

	If lFIN018AUT

		//�����������������������������������������������������������������Ŀ
		//�Quando chamada pela MsExecAuto() desvia Help para arquivo de log �
		//�������������������������������������������������������������������
		lSetHelp := HelpInDark(.T.)

	Endif

	Help(" ",1,"FINNoTab") // "Dicion�rio n�o atualizado, por favor executar o atualizador"
	lRet := .F.

	HelpInDark(lSetHelp)

EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fin018Cal  � Autor � ALvaro Camillo Neto  � Data � 16/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe na tela o calendario e a getdados                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FIN018cal(cAlias,nReg,nOpc)                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nil                                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FIN018                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Fin018Cal(cAlias,nReg,nOpc)

Local aSaveArea:= GetArea()
Local aAltera	:= {"FIU_INDICE","FIU_BLOQ"}
Local oDlg, oCalend
Local oGet
Local dData
Local nInd    := 0	// Indexadora de laco For/Next
Local nPos    := 0	// Posicao de elementos do arrau aAutoCab
Local aDados  := {}	// Array auxiliar com informacoes para atualizacao do aCols quando chamada pela MsExecAuto()
Local nPosCod := 0	// Posicao referente ao campo FIU_CODIND no aCols
Local nPosInd := 0	// Posicao referente ao campo FIU_INDICE no aCols

Private aTELA[0][0],aGETS[0],aHeader[0]
Private aCols 		:= {}
Private aColsAnt	:= {}
Private nUsado 	:= 0
Private nPosCodInd, nPosIndice, nPosBloq
Private lInclui

dbSelectArea("FIT")
dbSetOrder(1)
dbSeek(xFilial())
If Eof() .Or. (xFilial("FIT") <> FIT->FIT_FILIAL)
	Help(" ",1,"FIN18NOIND") // N�o h� indices cadastrados
	Return
EndIf

DbSelectArea("FIU")
dbSetOrder(1)

If FIU->(Bof()) .And. FIU->(Eof())
	dData := dDataBase
Else
	dData := FIU->FIU_DATA
EndIf

Fin018Ahead()

If !lFIN018AUT
	lInclui := Fin018Acols(dData)
	aColsAnt := Aclone(aCols)
Endif

nOpca := 0

If !lFIN018AUT

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) FROM 9,0 TO 23,80 OF oMainWnd

	oCalend:=MsCalend():New(0,0,oDlg)

	oCalend:dDiaAtu	:= dData
	dData					:= oCalend:dDiaAtu

	oCalend:bChange := {|| At018ChgDia(@oCalend,@oGet,@dData,@lInclui), oDlg:Refresh() }

	oGet := MSGetDados():New(00,140,66,314,nOpc,"AlwaysTrue","AlwaysTrue","",.F.,aAltera)
	oGet:oBrowse:bAdd := { || .F. }

    DEFINE SBUTTON FROM 80, 280 TYPE 1 ACTION (FIN018OK(dData,lInclui),oDlg:End()) ENABLE Of oDlg

	ACTIVATE DIALOG oDlg CENTERED

Else

	//����������������������������������������������������������Ŀ
	//�Tratamento de inclusao considerado para rotina automatica �
	//������������������������������������������������������������
	AxInclui(cAlias,nReg,nOpc,,,,,,,,,aAutoCab)

EndIf

RestArea(aSaveArea)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �At018chgdia� Autor � Pilar S Albaladejo   � Data � 17/07/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastrar cotacoes no dia escolhido                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �At018ChgDia(oCalend,oGet,dData,lInclui)             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA018                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto do Calendario                               ���
���          � ExpO2 = Objeto do Get		                                ���
���          � ExpD1 = Data           		                                ���
���          � ExpL1 = Define se eh inclusao ou nao		                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function At018ChgDia(oCalend,oGet,dData,lInclui)

Local lRet := .F.
Local aSaveArea := GetArea()


lRet := Fin018Comp(lInclui)

If lRet
	BEGIN TRANSACTION
		FIN018Grava(dData)
	END TRANSACTION
EndIf

dData := oCalend:dDiaAtu

lInclui := Fin018Acols(dData)
aColsAnt := Aclone(aCols)
oGet:oBrowse:Refresh()

RestArea(aSaveArea)


Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fin018AHEAD� Autor � Alvaro Camillo Neto  � Data � 16/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera matriz Aheader - para montagem posterior da acols     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Fin018AHead                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA018                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Fin018Ahead()

Local aSaveArea := GetArea()

dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("FIT_DESC")
nUsado++
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
				 x3_tamanho, x3_decimal, x3_valid,;
				 x3_usado, x3_tipo, x3_arquivo } )

dbSelectArea("Sx3")
dbSetOrder(1)
dbseek("FIU")
While !EOF() .And. (x3_arquivo == "FIU")
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. Trim(X3_CAMPO) != "FIU_DATA"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
					 x3_tamanho, x3_decimal, x3_valid,;
					 x3_usado, x3_tipo, x3_arquivo } )
	ENDIF
	dBSkip()
EndDO

F018HeaderWT("FIU", aHeader)

RestArea(aSaveArea)

Return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fin018Acols� Autor � Alvaro Camillo Neto  � Data � 17/07/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera matriz Acols para preenchimento das cotacoes          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Fin018Acols(dData,oGet)                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T./.F.                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA018                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpD1=Data				                                      ���
���          � ExpO1=Objeto do Get		                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Fin018Acols(dData,oGet)

Local aSaveArea:= GetArea()
Local lInclui	:= .F.
Local nCont 	:= 1
Local cCodInd, nTaxa, cBloq
Local cAlias, nRecno
Local nPos_ALI_WT, nPos_REC_WT

nPosCodInd	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "FIU_CODIND"})
nPosIndice	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "FIU_INDICE"})
nPosBloq	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "FIU_BLOQ"})
nPosDesc	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "FIT_DESC"})

nPos_ALI_WT := AScan(aHeader,{|x| Upper(AllTrim(x[2])) == "FIU_ALI_WT"})
nPos_REC_WT := AScan(aHeader,{|x| Upper(AllTrim(x[2])) == "FIU_REC_WT"})

aCols := {}

FIT->(dbSetOrder(1))
FIU->(dbSetOrder(2))

FIT->(dbSeek(xFilial()))
While FIT->(!Eof()) .And. xFilial("FIT") == FIT->FIT_FILIAL
	If FIU->(!MsSeek( xFilial("FIU") + Dtos(dData) + FIT->FIT_CODIND))
		lInclui	:= .T.
		cCodInd	:= FIT->FIT_CODIND
		nTaxa		:= CriaVar("FIU_INDICE",.T.)
		cBloq		:= CriaVar("FIU_BLOQ",.T.)
		cAlias  	:= "FIU"
		nRecno	:= 0
	Else
		lInclui	:= .F.
		cCodInd	:= FIU->FIU_CODIND
		nTaxa		:= FIU->FIU_INDICE
		cBloq		:= FIU->FIU_BLOQ
		cAlias  := "FIU"
		nRecno	:= FIU->(Recno())
	EndIf

	AADD(aCols,Array(nUsado+1))
	aCols[nCont][nPosCodInd]	:= cCodInd
	aCols[nCont][nPosIndice]	:= nTaxa
	aCols[nCont][nPosBloq]		:= cBloq
	aCols[nCont][nPosDesc]		:= FIT->FIT_DESC
	aCols[nCont][nUsado+1]		:= .F.

	If nPos_ALI_WT > 0
		aCols[nCont][nPos_ALI_WT] := cAlias
	EndIf

	If nPos_REC_WT > 0
		aCols[nCont][nPos_REC_WT] := nRecno
	EndIf

	nCont++
	FIT->(dbSkip())

EndDo

RestArea(aSaveArea)
Return lInclui

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fin018Grava� Autor � Alvaro Camillo Neto  � Data � 16/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava ou exclui as cotacoes digitadas na GetDados          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fin018Grava(dData)                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Fina018                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpD1 = Data                                               ���
���          � ExpL1 = Se eh exclusao ou nao. 	                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Fin018Grava(dData)

Local nCont
Local aSaveArea	:= GetArea()

FIT->(dbSetOrder(1))
FIU->(dbSetOrder(2))

For nCont := 1 To Len(aCols)
	If !(aCols[nCont][nPosIndice] == 0)
		If FIU->(!DbSeek(xFilial("FIU") + Dtos(dData) + aCols[nCont][nPosCodInd]))
			If FIT->(dbSeek(xFilial("FIT") + aCols[nCont][nPosCodInd]))
				dbSelectArea("FIU")
				RecLock("FIU",.T.)
				FIU->FIU_FILIAL	:= xFilial("FIU")
				FIU->FIU_DATA 		:= dData
				FIU->FIU_CODIND	:= aCols[nCont][nPosCodInd]
				FIU->FIU_INDICE := aCols[nCont][nPosIndice]
				FIU->FIU_BLOQ   := aCols[nCont][nPosBloq]
		  		FIU->(MsUnlock())
			EndIf
		Else
			RecLock("FIU",.F.)
			FIU->FIU_INDICE := aCols[nCont][nPosIndice]
			FIU->FIU_BLOQ   := aCols[nCont][nPosBloq]
			FIU->(MsUnlock())
		EndIf
	EndIf
Next nCont

RestArea(aSaveArea)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fin018Comp � Autor � Pilar S Albaladejo   � Data � 17/07/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Compara matriz aCols e aColsAnt                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Fin018Comp(lInclui)                                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T./.F.                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA018                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpL1 = Se eh inclusao ou nao.                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Fin018Comp(lInclui)

Local nCont, nCont1
Local lRet 		:= .F.
Local aSaveAREA := GetArea()
Local lEntrei := .F.

For nCont := 1 To Len(aCols)
	For nCont1 := 1 To nUsado
		If lInclui .Or. (aCols[nCont][nCont1]!= aColsAnt[nCont][nCont1])
			lRet := MsgYesNo(OemToAnsi(STR0002),OemToAnsi(STR0003)) // "Gravar Dados?"##"Aten��o"?
			lEntrei := .T.
			Exit
		EndIf
	Next nCont1
	If lEntrei
		Exit
	EndIf
Next nCont

RestArea(aSaveArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fin018Ok   � Autor � Alvaro Camillo Neto  � Data � 16/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do botao OK                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Fin018Ok(dData,lInclui)                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T./.F.                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA018                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpD1 = Data                                                ���
���          �ExpL1 = Se eh inclusao ou nao. 	                          ���
���          �ExpL2 = Se eh exclusao ou nao. 	                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Fin018Ok(dData,lInclui)

Local lRet 		:= .T.
Local aSaveArea := GetArea()

IF lRet
	lRet := Iif(lFIN018AUT,.t.,Fin018Comp(lInclui))
	If lRet
		Fin018Grava(dData)
	EndIf
Endif

RestArea(aSaveArea)

Return lRet

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Alvaro Camillo Neto   � Data � 16/12/09 ���
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

Local aRotina := {		{ STR0004	, "AxPesqui"	, 0 , 1,,.F.},;			//"Pesquisar"
                     	{ STR0005	, "AxVisual"	, 0 , 2},;					//"Visualizar"
                     	{ STR0006	, "FIN018Cal"	, 0 , 3},;   				//"Atual. de Indices"
                     	{ STR0007	, "FIN018Del"	, 0 , 5},;				//"Excluir"
						{ STR0008	, "Fin018Imp"	, 0 , 3},;				//"Importar"
						{ STR0009	, "Fin018Exp"	, 0 , 4}}				//"Exportar"


Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F018HeaderWT �Autor � Paulo Carnelossi  � Data � 09/03/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Adiciona no aHeader campos necessarios para funcionamento  ���
���          � Walk-Thru quando nao se utiliza a funcao FillGetDados()    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function F018HeaderWT(cAlias, aHeader)
Local aArea := GetARea()
Local aAreaSX3 := SX3->(GetArea())
Local cUsado

dbSelectArea("SX3")
dbSetOrder(2)
cAlias := Alltrim(cAlias)

If SX3->(DbSeek(cAlias+"_FILIAL"))
	cUsado := SX3->X3_USADO

	AADD( aHeader, { "Alias WT", cAlias+"_ALI_WT", "", 09, 0,, cUsado, "C", cAlias, "V"} )
	nUsado++
	AADD( aHeader, { "Recno WT", cAlias+"_REC_WT", "", 09, 0,, cUsado, "N", cAlias, "V"} )
	nUsado++
EndIf

RestArea(aAreaSX3)
RestArea(aArea)

Return


/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun�ao    �FINA018Exp � Autor � Marco Aurelio - Mano    � Data �19/07/10  ���
����������������������������������������������������������������������������Ĵ��
���Descri�ao �Exporta indices financeiros para arquivo CSV                   ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �FINA018Exp()                                                   ���
����������������������������������������������������������������������������Ĵ��
���Parametros�                                                               ���
����������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFIN                                                       ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function FIN018Exp()
Local aRet      := {}				// Conteudo de retorno da ParamBox
Local lRet      := .t.				// Conteudo de retorno da funcao
Local aPerg     := {}				// Array de parametros a serem passados para a ParamBox
Local cDescPar  := STR0012			// Descricao do parametro (###"Nome do arquivo exporta��o")
Local cIniPar   := PadR("",150) 	// Conteudo inicial do parametro
Local cPictPar  := ""				// Mascara de edicao do parametro
Local cValidPar := ""				// Validacao posterio do parametro
Local cWhenPar  := ""				// Validacao anterior do parametro
Local nTamPar   := 90				// Tamanho da MsGet do parametro
Local lObrigat  := .t.				// Determina se o parametro e obrigatorio
Local cTipArq   := STR0013		 	// Texto referente aos tipos de arquivos a serem exibidos(### "Arquivo .CSV |*.CSV" )
Local cDirIni   := ""			 	// Diretorio inicial do cGetFile
Local cParGetF  := ""			 	// Parametros da cGetFile
Local cTitulo   := STR0014		 	// Titulo da tela de parametros(###"Exportar �ndices Financeiros - CSV")

SaveInter()

cParGetF := GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE

//�������������������������������������������������Ŀ
//�Array a ser passado para ParamBox quando tipo(6) �
//���������������������������������������������������
aAdd( aPerg,{6,cDescPar,cIniPar,cPictPar,cValidPar,cWhenPar,nTamPar,lObrigat,cTipArq,cDirIni,cParGetF})

//�������������������������������������������������������������������Ŀ
//�Caso confirme a tela de parametros processa a rotina de exportacao �
//���������������������������������������������������������������������
If ParamBox(aPerg,cTitulo,@aRet)

	oProcess:= MsNewProcess():New( {|lEnd| CTBExpCSV( lEnd, oProcess, aRet[1], { {"FIU",1} } )} )
	oProcess:Activate()

EndIf

RestInter()

Return(lRet)

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun�ao    �FINA018Imp � Autor � Marco Aurelio - Mano    � Data �19/07/10  ���
����������������������������������������������������������������������������Ĵ��
���Descri�ao �Importa indices financeiros para arquivo CSV                   ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �FINA018Imp()                                                   ���
����������������������������������������������������������������������������Ĵ��
���Parametros�                                                               ���
����������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFIN                                                       ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function FIN018Imp()
Local aRet      := {}				// Conteudo de retorno da ParamBox
Local aPerg     := {}				// Array de parametros a serem passados para a ParamBox
Local cDescPar  := STR0016			// Descricao do parametro (###"Nome do arquivo para importa��o")
Local cIniPar   := PadR("",150) 	// Conteudo inicial do parametro
Local cPictPar  := ""				// Mascara de edicao do parametro
Local cValidPar := ""				// Validacao posterio do parametro
Local cWhenPar  := ""				// Validacao anterior do parametro
Local nTamPar   := 90				// Tamanho da MsGet do parametro
Local lObrigat  := .t.				// Determina se o parametro e obrigatorio
Local cTipArq   := STR0013		 	// Texto referente aos tipos de arquivos a serem exibidos(### "Arquivo .CSV |*.CSV" )
Local cDirIni   := ""			 	// Diretorio inicial do cGetFile
Local cParGetF  := ""			 	// Parametros da cGetFile
Local cTitulo   := STR0015		 	// Titulo da tela de parametros(### "Importar �ndices Financeiros - CSV")
Local aCposFiu  := {}			 	// Campos a serem atualizados na tabela FIU
Local aCfgImp   := {}			 	// Array de configuracoes a serem passadas para a CTBImpCSV

aCposFIU := { 	{"FIU_DATA"  ,"D",TamSX3("FIU_DATA")[1]  ,TamSX3("FIU_DATA")[2]		},;
				{"FIU_CODIND","C",TamSX3("FIU_CODIND")[1],TamSX3("FIU_CODIND")[2]	},;
				{"FIU_INDICE","N",TamSX3("FIU_INDICE")[1],TamSX3("FIU_INDICE")[2]	},;
				{"FIU_BLOQ"  ,"C",TamSX3("FIU_BLOQ")[1]  ,TamSX3("FIU_BLOQ")[2]		}}

aCfgImp  := { { "FIU", aCposFiu, {||MSExecAuto({|x,y| FINA018(x,y)},xAutoCab,3)}} }
cParGetF := GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE

//�������������������������������������������������Ŀ
//�Array a ser passado para ParamBox quando tipo(6) �
//���������������������������������������������������
aAdd( aPerg,{6,cDescPar,cIniPar,cPictPar,cValidPar,cWhenPar,nTamPar,lObrigat,cTipArq,cDirIni,cParGetF})

//�������������������������������������������������������������������Ŀ
//�Caso confirme a tela de parametros processa a rotina de exportacao �
//���������������������������������������������������������������������
If ParamBox(aPerg,cTitulo,@aRet)

	oProcess:= MsNewProcess():New( {|lEnd| CTBImpCSV( lEnd, oProcess, aRet[1], aCfgImp )} )
	oProcess:Activate()

EndIf

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MyFINA018 � Autor � Marco Aurelio - Mano  � Data � 15/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Exemplo de chamada do FINA018 pela MSExecAuto() para        ���
���          �atualizacao automatica das taxas dos indices financeiros    ���
�������������������������������������������������������������������������Ĵ��
���Uso       �SIGAFIN                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MyFINA018()
Local aDadosAuto := {}		// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica

Private lMsHelpAuto := .f.	// Determina se as mensagens de help devem ser direcionadas para o arq. de log
Private lMsErroAuto := .f.	// Determina se houve alguma inconsistencia na execucao da rotina em relacao aos

aDadosAuto:= {	{'FIU_CODIND' , "02"			, Nil},;	// Data de referencia para atualizacao dos indices
				{'FIU_DATA'   , CTOD("22/07/10"), Nil},;	// Data de referencia para atualizacao dos indices
			 	{'FIU_INDICE' , 0.22222      	, Nil},;   	// Dados para atualizacao do aCols
			 	{'FIU_BLOQ'   , "2"		     	, Nil}}   	// Dados para atualizacao do aCols

MSExecAuto({|x,y| FINA018(x,y)},aDadosAuto,3)

If lMsErroAuto
	lRetorno := .F.
	MostraErro()
Else
	lRetorno:=.T.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN018Del
Fun��o de Exclus�o de �ndice financeiro.

@param		cAlias Alias da tabela utilizada na exclus�o de registros de �ndice financeiro
@param		nReg Identifica��o do registro posicionado para dele��o do registro de �ndice financeiro
@param		nOpc Modo de edi��o informado ao posicionar e clicar para excluir na mBrowse de �ndices financeiros

@author	david.moraes
@since		18/12/2013
@version	MP11.80
/*/
//-------------------------------------------------------------------
Function FIN018Del( cAlias, nReg, nOpc)
	local nOpcA		as numeric
	local aArea		as array
	local cQuery	as character
	local cTemp		as character
	
	aArea	:= GetArea()
	cTemp	:= GetNextAlias()

	BEGIN TRANSACTION

	cQuery := "SELECT N1_INDAVP "
	cQuery += "FROM " + RetSqlName("SN1") + " SN1 "
	cQuery += "WHERE SN1.N1_INDAVP = '" + Alltrim(FIU->FIU_CODIND) + "' "
	cQuery += "AND SN1.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	If SELECT(cTemp) > 0
		(cTemp)->(dbCloseArea())
	EndIf

	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cTemp,.F.,.T. )

	If (cTemp)->(!EOF())
		Help( , 1 , "FINA018DEL" , , STR0017) //"Este �ndice est� vinculado a um ativo"
	Else
		nOpca := AxDeleta(cAlias, nReg, nOpc)
	EndIf

	END TRANSACTION

	RestArea( aArea )

	If SELECT(cTemp) > 0
		(cTemp)->(dbCloseArea())
	EndIf

Return
