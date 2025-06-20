#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "CERT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Certif   � Autor � Equipe Desenv. R.H.   � Data � 02.02.00 ���
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
Function TRMR110()

Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= {"RA_NOME", "RA7_NOME"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

SetPrvt("CCADASTRO,ASAYS,ABUTTONS,NOPCA,CTYPE,CARQUIVO")
SetPrvt("NVEZ,OWORD,CINICIO,CFIM,CFIL,CXINSTRU,CXLOCAL")
SetPrvt("LIMPRESS,CARQSAIDA,CARQPAG,NPAG,CPATH,CARQLOC,NPOS")

//Tratamento de acesso a Dados Sens�veis
If lBlqAcesso
	//"Dados Protegidos- Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Saiba mais em {link documenta��o centralizadora}"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Return
EndIf

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
//� MV_PAR11         Situacao Folha               �
//� MV_PAR12         Turma De                     �
//� MV_PAR13         Turma Ate                    �
//� MV_PAR14         1-Impressora / 2-Arquivo     �
//� MV_PAR15         Nome do arquivo de saida     �
//�������������������������������������������������

Pergunte("CERTIF",.F.)

cCadastro 	:= OemtoAnsi(STR0001) //"Integra��o com MS-Word"
aSays	  	:= {}
aButtons  	:= {}

AADD(aSays,OemToAnsi(STR0002) )  //"Esta rotina ir� imprimir os certificados dos cursos realizados "

AADD(aButtons, { 5,.T.,{|| Pergunte("CERTIF",.T. )}})
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch()}})
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	Processa({|| WORDIMP()})  // Chamada do Processamento// Substituido pelo assistente de conversao do AP5 IDE em 14/02/00 ==> 	Processa({|| Execute(WORDIMP)})  // Chamada do Processamento
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � WORDIMP  � Autor � Equipe Desenv. R.H.   � Data � 31.03.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Certificados dos cursos  - VIA WORD           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  �                                          � Data �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static FUNCTION WORDIMP()

// Seleciona Arquivo Modelo
cType := "CERTIF     | *.DOT"
cArquivo := cGetFile(cType, OemToAnsi(STR0003+Subs(cType,1,6)),,,.T.,GETF_ONLYSERVER )//"Selecione arquivo "

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
nPag 		:= 0

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

cInicio 	:= "RA4->RA4_FILIAL+RA4->RA4_CALEND"
cFim		:= MV_PAR02+MV_PAR08
cFil		:= xFilial("RA4", MV_PAR01)

dbSelectArea("RA4")
dbSetOrder(3)
dbSeek(cFil+MV_PAR07,.T.)
While ! Eof() .And. &cInicio <= cFim

	If 	RA4->RA4_FILIAL	< MV_PAR01 .Or. RA4->RA4_FILIAL > MV_PAR02 .Or.;
		RA4->RA4_CURSO  < MV_PAR09 .Or. RA4->RA4_CURSO  > MV_PAR10 .Or.;
		RA4->RA4_CALEND < MV_PAR07 .Or. RA4->RA4_CALEND > MV_PAR08	.Or.;
		RA4->RA4_TURMA 	< MV_PAR12 .Or.	 RA4->RA4_TURMA > MV_PAR13

		dbSkip()
		Loop
	EndIf

    dbSelectArea("RA2")
    dbSetOrder(1)
	cFil	:= xFilial("RA2", RA4->RA4_FILIAL)
	cXInstru:= ""
	cXLocal	:= ""
    If dbSeek(cFil+RA4->RA4_CALEND)

    	While !Eof() .And. RA4->RA4_CALEND == RA2->RA2_CALEND
    		If (RA4->RA4_CURSO+RA4->RA4_TURMA != RA2->RA2_CURSO+RA2_TURMA)

    			dbSelectArea("RA2")
    			dbSkip()
    			Loop
    		EndIf
			cXInstru:= RA2->RA2_INSTRU
	//	   	cXLocal := RA2->RA2_LOCAL
			exit
		EndDo
	EndIf

	cXLocal := Fdesc("RA0",RA4->RA4_ENTIDA,"RA0_DESC")

  	dbSelectArea("SRA")
   	dbSetOrder(1)
   	If dbSeek(RA4->RA4_FILIAL+RA4->RA4_MAT)

		If SRA->RA_MAT < MV_PAR05 .Or.;
			SRA->RA_MAT > MV_PAR06 .Or.;
			SRA->RA_CC < MV_PAR03 .Or.;
			SRA->RA_CC > MV_PAR04 .Or.;
			!(SRA->RA_SITFOLH $ MV_PAR11)

			dbSelectArea("RA4")
			dbSkip()
			Loop
		EndIf

		dbSelectArea("RA7")
		cFil:= xFilial("RA7", RA4->RA4_FILIAL)
		dbSeek(cFil+cXInstru)

		// Variaveis a serem usadas na Montagem do Documento no Word
		//--Cadastro Funcionario
		OLE_SetDocumentVar(oWord,"cNomeFun",SRA->RA_NOME)

		//--Curso
		OLE_SetDocumentVar(oWord,"cLocal" ,cXLocal)
		OLE_SetDocumentVar(oWord,"cCurso" ,POSICIONE("RA1",1,xFilial("RA1")+RA4->RA4_CURSO,"RA1->RA1_DESC"))
		OLE_SetDocumentVar(oWord,"dInicio",RA4->RA4_DATAIN)
		OLE_SetDocumentVar(oWord,"dFim"   ,RA4->RA4_DATAFI)

		//--Data atual
		OLE_SetDocumentVar(oWord,"cDia"	, StrZero(Day(RA4->RA4_DATAFI),2))
		OLE_SetDocumentVar(oWord,"cAno"	, StrZero(Year(RA4->RA4_DATAFI),4))
		OLE_SetDocumentVar(oWord,"cMes"	, MesExtenso(Month(RA4->RA4_DATAFI)))

		//--Instrutor
		OLE_SetDocumentVar(oWord,"cInstrutor"	, RA7->RA7_NOME)

		//--Sinonimo de Curso
		OLE_SetDocumentVar(oWord,"cSinon"	, Fdesc("RA9", RA4->RA4_SINONI, "RA9_DESCR"))

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

	dbSelectArea("RA4")
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
