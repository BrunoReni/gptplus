#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "CONVIT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � convite  � Autor � Equipe Desenv. R.H.   � Data � 02.02.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio                        - VIA WORD                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  �                                          � Data �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programador � Data   � FNC  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������ĳ��
���Cecilia Car.�31/07/14�TPZWAO�AIncluido o fonte da 11 para a 12 e efetu-���
���            �        �      �ada a limpeza.                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TRMR120()
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
	Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList({"RA_NOME"}) )

	SetPrvt("CCADASTRO,ASAYS,ABUTTONS,NOPCA,CTYPE,CARQUIVO")
	SetPrvt("NVEZ,OWORD,CINICIO,CFIM,CFIL")
	SetPrvt("LIMPRESS,CARQSAIDA,CARQPAG,NPAG,CPATH,CARQLOC,NPOS")

	//�����������������������������������������������Ŀ
	//� Parametros usados na rotina                   �
	//� MV_PAR01         Filial   De                  �
	//� MV_PAR02         Filial   Ate                 �
	//� MV_PAR03         C.Custo  De                  �
	//� MV_PAR04         C.Custo  Ate                 �
	//� MV_PAR05         Matricula De                 �
	//� MV_PAR06         Matricula Ate                �
	//� MV_PAR07         Calendario De                �
	//� MV_PAR08         Calendario Ate               �
	//� MV_PAR09         Curso De                     �
	//� MV_PAR10         Curso Ate                    �
	//� MV_PAR11         Turma De 	                  �
	//� MV_PAR12         Turma Ate 	                  �
	//� MV_PAR13         Situacao Folha               �
	//� MV_PAR14         1-Impressora / 2-Arquivo     �
	//� MV_PAR15         Nome do arquivo de saida     �
	//�������������������������������������������������

		//Tratamento de acesso a Dados Sens�veis
	If lBlqAcesso
		//"Dados Protegidos-Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Saiba mais em {link documenta��o centralizadora}"
		Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Else
		Pergunte("CONVIT",.F.)

		cCadastro := OemtoAnsi(STR0001) //"Integra��o com MS-Word"
		aSays	  :={}
		aButtons  :={}

		AADD(aSays,OemToAnsi(STR0002) ) //"Esta rotina ir� imprimir os convites dos cursos realizados "

		AADD(aButtons, { 5,.T.,{|| Pergunte("CONVIT",.T. )}})
		AADD(aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch()}})
		AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

		FormBatch( cCadastro, aSays, aButtons )

		If nOpca == 1
			Processa({|| WORDIMP()})  // Chamada do Processamento// Substituido pelo assistente de conversao do AP5 IDE em 14/02/00 ==> 	Processa({|| Execute(WORDIMP)})  // Chamada do Processamento
		EndIf
	EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � WORDIMP  � Autor � Equipe Desenv. R.H.   � Data � 31.03.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de convites dos cursos  - VIA WORD               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  �                                          � Data �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static FUNCTION WORDIMP()

// Seleciona Arquivo Modelo
cType 		:= "CONVITE     | *.DOT"
cArquivo 	:= cGetFile(cType, OemToAnsi(STR0003+Subs(cType,1,6)),,,.T.,GETF_ONLYSERVER )//"Selecione arquivo "

//����������������������������������������������������Ŀ
//� Copiar Arquivo .DOT do Server para Diretorio Local �
//������������������������������������������������������
nPos := Rat("\",cArquivo)
If nPos > 0
	cArqLoc := AllTrim(Subst(cArquivo, nPos+1,20 ))
Else
	cArqLoc := cArquivo
EndIF
cPath := GETTEMPPATH()
If Right( AllTrim(cPath), 1 ) != "\"
   cPath += "\"
Endif
If !CpyS2T(cArquivo, cPath, .T.)
	Return
Endif

lImpress	:= ( MV_PAR14 == 1 )	// Verifica se a saida sera em Tela ou Impressora
cArqSaida	:= AllTrim( MV_PAR15 )	// Nome do arquivo de saida

// Inicia o Word
nVez := 1

// Inicializa o Ole com o MS-Word 97 ( 8.0 )
oWord := OLE_CreateLink('TMsOleWord97')

OLE_NewFile(oWord,cPath+cArqLoc)

If lImpress
	OLE_SetProperty( oWord, oleWdVisible,   .F. )
	OLE_SetProperty( oWord, oleWdPrintBack, .T. )
Else
	OLE_SetProperty( oWord, oleWdVisible,   .T. )
	OLE_SetProperty( oWord, oleWdPrintBack, .F. )
EndIf

cInicio := "RA3->RA3_FILIAL+RA3->RA3_CALEND"
cFim	:= MV_PAR02+MV_PAR08
cFil	:= xFilial("RA3", MV_PAR01)
nPag	:= 0

dbSelectArea("RA3")
dbSetOrder(2)
dbSeek(cFil+MV_PAR07,.T.)
While ! Eof() .And. &cInicio <= cFim
	IF  RA3->RA3_FILIAL	< MV_PAR01 .Or. RA3->RA3_FILIAL > MV_PAR02 .Or.;
		RA3->RA3_CALEND	< MV_PAR07 .Or. RA3->RA3_CALEND > MV_PAR08 .Or.;
		RA3->RA3_CURSO 	< MV_PAR09 .Or. RA3->RA3_CURSO > MV_PAR10	.Or.;
		RA3->RA3_TURMA 	< MV_PAR11 .Or. RA3->RA3_TURMA > MV_PAR12	.Or.;
		RA3->RA3_RESERV != "R"

		dbSkip()
		Loop
	Endif

    dbSelectArea("RA2")
    dbSetOrder(1)
	cFil	:= xFilial("RA2", RA3->RA3_FILIAL)
    If dbSeek(cFil+RA3->RA3_CALEND)

    	While !Eof() .And. RA3->RA3_CALEND == RA2->RA2_CALEND
    		If (RA3->RA3_CURSO+RA3->RA3_TURMA != RA2->RA2_CURSO+RA2_TURMA)

    			dbSelectArea("RA2")
    			dbSkip()
    			Loop
    		EndIf
			If RA2->RA2_REALIZ == "S"

				dbSelectArea("RA3")
				dbSkip()
				Loop
			EndIf
			exit
		EndDo
	Else
		dbSelectArea("RA3")
		dbSkip()
		Loop
	EndIf

	dbSelectArea("SRA")
	dbSetOrder(1)
	If dbSeek(RA3->RA3_FILIAL+RA3->RA3_MAT)

		If 	SRA->RA_CC < MV_PAR03 .Or.;
			SRA->RA_CC > MV_PAR04 .Or.;
			SRA->RA_MAT < MV_PAR05 .Or.;
			SRA->RA_MAT > MV_PAR06 .Or.;
			!(SRA->RA_SITFOLH $ MV_PAR13)

			dbSelectArea("RA3")
			dbSkip()
			Loop
		EndIf

		dbSelectArea("RA1")
		cFil:= xFilial("RA1", SRA->RA_FILIAL)
		dbSeek(cFil+RA3->RA3_CURSO)

		dbSelectArea("RA7")
		cFil:= xFilial("RA7", SRA->RA_FILIAL)
		dbSeek(cFil+RA2->RA2_INSTRU)

		dbSelectArea("CTT")
		cFil:= xFilial("CTT", SRA->RA_FILIAL)
		dbSeek(cFil+SRA->RA_CC)

		dbSelectArea("RA0")
		cFil:= xFilial("RA0", SRA->RA_FILIAL)
		dbSeek(cFil+RA2->RA2_ENTIDA)

		// Variaveis a serem usadas na Montagem do Documento no Word
		//--Cadastro Funcionario
		OLE_SetDocumentVar(oWord,"cNome",SRA->RA_NOME)
		OLE_SetDocumentVar(oWord,"cMat" ,SRA->RA_MAT)

		//--Centro de Custo
		OLE_SetDocumentVar(oWord,"cCC",CTT->CTT_DESC01)

		//--Curso
		OLE_SetDocumentVar(oWord,"cLocal" 	,RA2->RA2_LOCAL)
		OLE_SetDocumentVar(oWord,"cCurso" 	,RA1->RA1_DESC)
		OLE_SetDocumentVar(oWord,"dInicio"	,RA2->RA2_DATAIN)
		OLE_SetDocumentVar(oWord,"dFim"		,RA2->RA2_DATAFI)
		OLE_SetDocumentVar(oWord,"cHorario"	,RA2->RA2_HORARI)
		OLE_SetDocumentVar(oWord,"cEntidade",RA0->RA0_DESC)

		//--Data atual
		OLE_SetDocumentVar(oWord,"cDia"	, StrZero(Day(dDataBase),2))
		OLE_SetDocumentVar(oWord,"cAno"	, StrZero(Year(dDataBase),4))
		OLE_SetDocumentVar(oWord,"cMes"	, MesExtenso(Month(dDataBase)))

		//--Sinonimo de Curso
		OLE_SetDocumentVar(oWord,"cSinon" ,Fdesc("RA9", RA2->RA2_SINON, "RA9_DESCR"))

		//--Atualiza Variaveis
		OLE_UpDateFields(oWord)

		//Alterar nome do arquivo para Cada Pagina do arquivo para evitar sobreposicao.
		nPag ++
		cArqPag := cArqSaida + Strzero(nPag,3)

		//-- Imprime as variaveis
		IF lImpress
			OLE_SetProperty( oWord, '208', .F. ) ; OLE_PrintFile( oWord, "ALL",,, 1 )
		Else
			Aviso("", STR0004 +cArqPag+ STR0005, {STR0006}) //"Alterne para o programa do Ms-Word para visualizar o documento "###" ou clique no botao para fechar."###"Fechar"
			OLE_SaveAsFile( oWord, cArqPag )
		EndIF

	EndIf

	dbSelectArea("RA3")
	dbSkip()
EndDo

OLE_CloseLink( oWord ) 			// Fecha o Documento

//����������������������������������������������������Ŀ
//�  Apaga arquivo .DOT temporario da Estacao 		   �
//������������������������������������������������������
If File(cPath+cArqLoc)
	FErase(cPath+cArqLoc)
Endif

Return
