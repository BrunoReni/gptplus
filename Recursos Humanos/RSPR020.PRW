#include "rwmake.ch"
#INCLUDE "RSR001.CH"

Function RSPR020()

SetPrvt("CDESC1,CDESC2,CDESC3,CSTRING,AORD,IMPRIME")
SetPrvt("LEND,ARETURN,NOMEPROG,ALINHA,NLASTKEY,CPERG")
SetPrvt("TITULO,AT_PRG,CCABEC,WCABEC0,WCABEC1,CONTFL")
SetPrvt("LI,NOPC,NOPCA,WNREL,NTAMANHO,NORDEM")
SetPrvt("L1VEZ,CCANCEL,CARQNTX,CINDCOND,CINICIO,CFIM")
SetPrvt("CDETALHE,CVALID,CVAR,I,CLINE,LATIV")
SetPrvt("CSAVALIAS,NSAVREG,NLINHA,CDESCFAT,CDESCGRA,CDESCGRU")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RSR001   � Autor � Equipe R.H.           � Data � 03.03.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime os curriculos conforme parametros selecionados     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RdMake                                                     ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�06/08/14�TQENRX�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
���Esther V.   �05/02/15�TRHKWR�Limitada a impressao do campo QL_EMPRESA a���
���            �        �      �apenas 30 caracteres (tamanho padrao).    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
cDesc1  := OemtoAnsi(STR0001) //"Este programa tem como objetivo imprimir os curriculos"
cDesc2  := OemtoAnsi(STR0002) //"conforme parametros selecionados."
cDesc3  := ""
cString := "SQG"
aOrd    := {STR0003,STR0004} //"Curriculo"###"Nome"
Imprime := .T.
lEnd    := .F.

//��������������������������������������������������������������Ŀ
//� Define Variaveis (Basicas)                            		 �
//����������������������������������������������������������������
aReturn  := { STR0005,1,STR0006,2,2,1,"",1 } //"Zebrado"###"Administracao"
NomeProg := "RSR001"
aLinha   := {}
nLastKey := 0
cPerg    := "RSR001"

//��������������������������������������������������������������Ŀ
//� Define Variaveis (Programa)                                  �
//����������������������������������������������������������������
Titulo  := OemToAnsi(STR0007) //"Curriculos"
At_prg  := "RSR001"
cCabec  := ""
wCabec0 := 0
wCabec1 := ""
ContFl  := 1
Li      := 1

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("RSR001",.F.)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01        //  Curriculo de                             �
//� mv_par02        //  Curriculo ate                            �
//� mv_par03        //  Nome de              			         �
//� mv_par04        //  Nome ate        						 �
//� mv_par05        //  Area de					        		 �
//� mv_par06        //  Area ate                      		     �
//� mv_par07        //  Situacao         			  			 �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
nOpc:=2
nOpca:=2
wnrel:="RSR001"   					    //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
EndIf

RptStatus({|| F001Impr()})

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � F001Impr � Autor � Equipe R.H. 			� Data � 03.03.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de impressao dos curriculos                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RdMake                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F001Impr()
cCabec  := ""
At_prg  := "RSR001"
WCabec0 := 1
WCabec1 := OemtoAnsi(STR0008) //"Curriculo Vitae"
Contfl  := 1
Li      := 0
nTamanho:= "M"
nOrdem  := aReturn[8]
l1Vez   := .T.
cCancel := STR0009 //"Cancelado pelo usuario"
nOrdem  := aReturn[8]
cArqNtx	:= ""

dbSelectArea("SQG")
If nOrdem == 1					// Curriculo
	dbSetOrder(1)
ElseIf nOrdem == 2			// Nome
	cArqNtx  := CriaTrab(NIL,.f.)
	cIndCond := "QG_FILIAL + QG_NOME"
	IndRegua("SQG",cArqNtx,cIndCond,,,STR0010) //"Selecionando Registros..."
EndIf

dbGoTop()

If nOrdem == 1
	dbSeek(xFilial("SQG")+mv_par01,.T.)
	cInicio := "SQG->QG_FILIAL + SQG->QG_CURRIC"
	cFim	:= xFilial("SQG")+mv_par02
ElseIf nOrdem == 2
	dbSeek(xFilial("SQG")+Upper(mv_par03),.T.)
	cInicio := "SQG->QG_FILIAL + SQG->QG_NOME"
	cFim	:= xFilial("SQG")+mv_par04
EndIf

SetRegua( RecCount() )

While	!Eof() .And. &cInicio <= cFim

	//��������������������������������������������������������������Ŀ
	//� Movimenta Regua Processamento                                �
	//����������������������������������������������������������������
	IncRegua()

	If 	( SQG->QG_CURRIC 		< mv_par01 			.Or. SQG->QG_CURRIC > mv_par02 ) 				.Or.;
		( Upper(SQG->QG_NOME) 	< Upper(mv_par03) 	.Or. Upper(SQG->QG_NOME) > Upper(mv_par04) ) 	.Or.;
		( SQG->QG_AREA 			< mv_par05 			.Or. SQG->QG_AREA > mv_par06 ) 					.Or.;
		( SQG->QG_SITUAC 		< mv_par07 			.Or. SQG->QG_SITUAC > mv_par08 )
		dbSkip()
		Loop
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Cancela Impress�o ao se pressionar <ALT> + <A>               �
	//����������������������������������������������������������������
	If lEnd
		cDetalhe:= STR0011 //"Cancelado pelo Operador"
		Impr(cDetalhe,"P")
		Exit
	EndIf

	// Dados Pessoais
	FDados()

	l1Vez:= .T.

	// Qualificacao
	FQualific()

	l1Vez:= .T.
	// Experiencia
	FExperienc()

	l1Vez:= .T.
	// Analise
	FAnalise()

	l1Vez:= .T.
	// Historico Profissional
	FHistor()

	l1Vez:= .T.
	cValid := "S"
	// Formacao Escolar
	FEscolar()

	l1Vez:= .T.
	cValid := "N"
	// Cursos ExtraCurriculares
	FEscolar()

	l1Vez:= .T.
	// Caracter�sticas dos Candidatos
	FCaracteres()

	dbSelectArea("SQG")
	DbSkip()

	If !Eof() .And. &cInicio <= cFim
		cDetalhe:=""
		Impr(cDetalhe,"P")
	EndIf

EndDo

cDetalhe:=""
Impr(cDetalhe,"F")

//��������������������������������������������������������������Ŀ
//� Termino do Relatorio                                         �
//����������������������������������������������������������������
dbSelectArea("SQG" )
dbSetOrder(1)
dbGoTop()

If File(cArqNtx+OrdBagExt())
	RetIndex("SQG")
	FErase(cArqNtx+OrdBagExt())
	Set Filter to
Endif

Set Device To Screen
Set Printer To
Commit

If aReturn[5] == 1
	Ourspool(wnrel)
EndIf

MS_FLUSH()
RETURN

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FDados   � Autor � Equipe R.H. 			� Data � 03.03.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de impressao dos Dados Pessoais do curriculo        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RdMake                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FDados()
Local cStatus := ""
cDetalhe:=""
Impr(cDetalhe,"C")
cDetalhe := Space(10)+OemtoAnsi(STR0012) //"DADOS PESSOAIS"
Impr(cDetalhe,"C")
cDetalhe:=""
Impr(cDetalhe,"C")
cDetalhe:= Space(15)+OemtoAnsi(STR0013)+ Alltrim(SQG->QG_NOME) //"Nome: "
Impr(cDetalhe,"C")
cDetalhe:= Space(15)+OemtoAnsi(STR0014) + Alltrim(SQG->QG_FONE) //"Tel.: "
Impr(cDetalhe,"C")

dbSelectArea("SX5")
dbSeek(xFilial()+"33"+SQG->QG_ESTCIV)

cDetalhe:= Space(15)+Alltrim(RetTitle("QG_DTNASC"))+": " + DtoC(SQG->QG_DTNASC)+If(__SetCentury(),Space(3),Space(5))+OemtoAnsi(STR0016)+UPPER(Substr(SX5->X5_DESCRI,1,30)) //"Dt.Nasc.: "###"Est.Civil: "
Impr(cDetalhe,"C")
cDetalhe:= Space(15)+OemtoAnsi(STR0017)+ Alltrim(SQG->QG_ENDEREC) //"Endereco: "
Impr(cDetalhe,"C")
cDetalhe:= Space(25)+Alltrim(SQG->QG_COMPLEM)
Impr(cDetalhe,"C")
cDetalhe:= Space(25)+Alltrim(SQG->QG_BAIRRO)+" "+Alltrim(SQG->QG_MUNICIP)
Impr(cDetalhe,"C")
cDetalhe:= Space(25)+SQG->QG_ESTADO+"   "+SQG->QG_CEP
Impr(cDetalhe,"C")
cDetalhe:= Space(15)+Alltrim(RetTitle("QG_RG"))+": "+SQG->QG_RG+Space(05)+Alltrim(RetTitle("QG_CIC"))+": "+SQG->QG_CIC //"RG: "###"CIC: "
Impr(cDetalhe,"C")
If SQG->( ColumnPos("QG_ACEITE") ) > 0
	cStatus := If( SQG->QG_ACEITE == "2", STR0045, STR0046 )				//"Aceito"/"Pendente"
	If !Empty(SQG->QG_ACTRSP)
		cStatus += STR0047 + If( SQG->QG_ACTRSP == "2", STR0045, STR0046 )	//" / Respons�vel "
	EndIf
	cDetalhe := Space(15) + STR0044 + cStatus						//"Status Consentimento: "
	Impr(cDetalhe,"C")
EndIf
cDetalhe:=""
Impr(cDetalhe,"C")

cDetalhe:= Space(10)+OemtoAnsi(STR0020) //"AREA DE INTERESSE"
Impr(cDetalhe,"C")
cDetalhe:=""
Impr(cDetalhe,"C")
cDetalhe:= Space(15)+OemtoAnsi(STR0021)+SQG->QG_DESCFUN+Space(05)+STR0022+str(SQG->QG_PRETSAL) //"Cargo: "###"Pret.Salarial: "
Impr(cDetalhe,"C")
cDetalhe:= Space(15)+OemtoAnsi(STR0023)+Alltrim(SQG->QG_INDICAD) //"Indicado por: "
Impr(cDetalhe,"C")
cDetalhe:=""
Impr(cDetalhe,"C")
RETURN

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FQualific� Autor � Equipe R.H. 			� Data � 03.03.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime as Qualificacoes do curriculos                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RdMake                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FQualific()
Local nLinha := 0
Local i		 := 0
Local cGrupo := ""
Local cFator := ""
Local cGrau  := ""
Local cDscFatAux := ""
Local cDscGraAux := ""

cSavAlias	:= Alias()
nSavReg  	:= RecNo()

cDetalhe:= Space(10)+OemtoAnsi(STR0024) //"QUALIFICACOES"
Impr(cDetalhe,"C")
cDetalhe:= ""
Impr(cDetalhe,"C")

dbSelectArea("SQI")
dbSetOrder(1)
If dbSeek(xFilial()+SQG->QG_CURRIC)
	cDetalhe:=Space(15)+OemtoAnsi(STR0040) //"Grupo              Fator                           Grau"
	Impr(cDetalhe,"C")

	While !Eof() .And. xFilial("SQG")+SQG->QG_CURRIC == QI_FILIAL+QI_CURRIC
		cDescGru := TrmDesc("SQ0",SQI->QI_GRUPO,"Q0_DESCRIC")
		cDescFat := TrmDesc("SQ1",SQI->QI_GRUPO+SQI->QI_FATOR,"Q1_DESCSUM")
		cDescGra := TrmDesc("SQ2",SQI->QI_GRUPO+SQI->QI_FATOR+SQI->QI_GRAU,"Q2_DESC")

		cGrupo   := SQI->QI_GRUPO + "-"
		cFator   := SQI->QI_FATOR + "-"
		cGrau    := SQI->QI_GRAU  + "-"

        nLinha := Max( MlCount(cDescFat,30) , MlCount(cDescGra,30) ) //Verifica a quantidade de linhas para a maior descricao

        For i := 1 to nLinha

			cDscFatAux := Memoline(cDescFat,30,i,,.T.)
			cDscGraAux := Memoline(cDescGra,30,i,,.T.)

			cDscFatAux := If (Empty(cDscFatAux),Space(30),cDscFatAux)
			cDscGraAux := If (Empty(cDscGraAux),Space(30),cDscGraAux)

			cDetalhe:=Space(15)+cGrupo+cDescGru+" "+cFator+cDscFatAux+" "+cGrau+cDscGraAux

			cGrupo   := "   "
			cFator   := "   "
			cGrau    := "   "
			cDescGru := Space(15)

			Impr(cDetalhe,"C")
        Next i

	    l1Vez := .F.

		dbSelectArea("SQI")
		dbSkip()
	EndDo
EndIf
If l1Vez
	cDetalhe:= Space(15)+ OemtoAnsi(STR0025) //"*** Qualificacoes nao cadastrada ***"
	Impr(cDetalhe,"C")
EndIf

cDetalhe:=""
Impr(cDetalhe,"C")

dbSelectArea(cSavAlias)
dbGoto(nSavReg)

RETURN

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FExperienc� Autor � Equipe R.H. 			� Data � 03.03.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime as Experiencias do curriculos                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RdMake                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FExperienc()
Local i	:= 0

cDetalhe:= Space(10)+OemtoAnsi(STR0038) //"EXPERIENCIA"
Impr(cDetalhe,"C")
cDetalhe:= ""
Impr(cDetalhe,"C")

cVar	:= MSMM(SQG->QG_EXPER,,,,3,,,"SQG")
nLinha 	:= MlCount(cVar,80)
For i := 1 to nLinha
	cLine:= Space(15)+Memoline(cVar,80,i,,.T.)
	Impr(cLine,"C")
	l1Vez:= .F.
Next i

If l1Vez
	cDetalhe:= Space(15)+ OemtoAnsi(STR0039) //"*** Experiencia nao cadastrada ***"
	Impr(cDetalhe,"C")
EndIf

cDetalhe:=""
Impr(cDetalhe,"C")

RETURN

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FAnalise � Autor � Equipe R.H. 			� Data � 03.03.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime a Analise feita do curriculo                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RdMake                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FAnalise()
Local i	:= 0
cDetalhe:= Space(10)+OemtoAnsi(STR0026) //"ANALISE"
Impr(cDetalhe,"C")
cDetalhe:= ""
Impr(cDetalhe,"C")

cVar	:= MSMM(SQG->QG_ANALISE,,,,3,,,"SQG")
nLinha 	:= MlCount(cVar,80)
For i := 1 to nLinha
	cLine:= Space(15)+MemoLine(cVar,80,i,,.T.)
	Impr(cLine,"C")
	l1Vez:= .F.
Next i

If l1Vez
	cDetalhe:= Space(15)+ OemtoAnsi(STR0027) //"*** Analise nao cadastrada ***"
	Impr(cDetalhe,"C")
EndIf

cDetalhe:=""
Impr(cDetalhe,"C")

RETURN

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FHistor  � Autor � Equipe R.H. 			� Data � 03.03.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Historico Profissional do candidato                ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RdMake                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FHistor()
Local i	:= 0

If li > 55
	cDetalhe:=""
	Impr(cDetalhe,"P")
EndIf

lAtiv:= .T.
cSavAlias:= Alias()
nSavReg  := RecNo()

cDetalhe:= Space(10)+OemtoAnsi(STR0028) //"HISTORICO PROFISSIONAL "
Impr(cDetalhe,"C")
cDetalhe:= ""
Impr(cDetalhe,"C")

dbSelectArea("SQL")
dbSetOrder(1)
dbSeek(xFilial()+SQG->QG_CURRIC)
While !Eof() .And. xFilial("SQG")+SQG->QG_CURRIC == QL_FILIAL+QL_CURRIC

	cDetalhe:=Space(15)+OemtoAnsi(STR0029) //"Admissao Demissao Area                                Empresa                        Funcao"
	//									    99/99/99 99/99/99  001 012345678901234567890123456789 012345678901234567890123456789 01234567890123456780
	Impr(cDetalhe,"C")

	dbSelectArea("SX5")
	dbSetOrder(1)
	dbSeek(xFilial()+"R1"+SQL->QL_AREA)

	cDetalhe:=Space(15)+DtoC(SQL->QL_DTADMIS)+If(__SetCentury(),Space(1),Space(3))+DtoC(SQL->QL_DTDEMIS)+If(__SetCentury(),Space(1),Space(3))+SQL->QL_AREA+"-"+UPPER(Substr(SX5->X5_DESCRI,1,30))+"  "+Substr(SQL->QL_EMPRESA,1,30)+" "+SQL->QL_FUNCAO
	Impr(cDetalhe,"C")

	cDetalhe:= Space(17)+OemtoAnsi(STR0030) //"Atividades:"
	Impr(cDetalhe,"C")

	l1Vez:= .F.

	cVar	:= RHMSMM(SQL->QL_ATIVIDA,,,,,,, "SQL",,"RDY",, "RDY")
	nLinha 	:= MlCount(cVar, 100)
	For i := 1 to nLinha
		cDetalhe := Space(20) + MemoLine(cVar, 100, i,, .T.)
		Impr(cDetalhe,"C")
		lAtiv := .F.
	Next i

	If lAtiv
		cDetalhe:= Space(20)+ OemtoAnsi(STR0031) //"*** Atividade nao cadastrada ***"
		Impr(cDetalhe,"C")
	EndIf

	dbSelectArea("SQL")
	dbSkip()
EndDo

If l1Vez
	cDetalhe:= Space(15)+ OemtoAnsi(STR0032) //"*** Historico Profissional nao cadastrada ***"
	Impr(cDetalhe,"C")
EndIf

cDetalhe:=""
Impr(cDetalhe,"C")

dbSelectArea(cSavAlias)
dbGoto(nSavReg)

RETURN

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FEscolar � Autor � Equipe R.H. 			� Data � 03.03.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime a formacao Escolar e Cursos extracurriculares      ���
�������������������������������������������������������������������������Ĵ��
���Observacao� cValid ="S" - Formacao Escolar  "N"-Curso ExtraCurricular  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RdMake                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FEscolar()

If li > 55
	cDetalhe:=""
	Impr(cDetalhe,"P")
EndIf

cSavAlias:= Alias()
nSavReg  := RecNo()

If cValid == "S"
	cDetalhe:= Space(10)+OemtoAnsi(STR0033) //"FORMACAO ESCOLAR"
	Impr(cDetalhe,"C")
Else
	cDetalhe:= Space(10)+OemtoAnsi(STR0034) //"CURSOS EXTRACURRICULARES"
	Impr(cDetalhe,"C")
EndIf

cDetalhe:=""
Impr(cDetalhe,"C")

dbSelectArea("SQM")
dbSetOrder(1)
dbSeek(xFilial()+SQG->QG_CURRIC)

While !Eof() .And. xFilial()+SQG->QG_CURRIC == QM_FILIAL+QM_CURRIC

	If SQM->QM_ESCOLAR #cValid
		dbSkip()
		Loop
	EndIf

	If l1Vez
		cDetalhe:= Space(15)+OemtoAnsi(STR0035) //"Dt.Formacao Entidade                       Curso"
		//	    						    	     99/99/99   012345678901234567890123456789 012345 -
		Impr(cDetalhe,"C")
		l1Vez:= .F.
	EndIf


	dbSelectArea("SQT")
	dbSetOrder(1)
	dbSeek(xFilial()+SQM->QM_CURSO)

	cDetalhe:= Space(15)+ DtoC(SQM->QM_DATA)+If(__SetCentury(),Space(4),Space(6))+SQM->QM_ENTIDAD+" "+SQM->QM_CURSO+" - "+SQT->QT_DESCRIC
	Impr(cDetalhe,"C")

	dbSelectArea("SQM")
	dbSetOrder(1)
	dbSkip()
EndDo

If l1Vez
	If cValid == "S"
		cDetalhe:= Space(15)+ OemtoAnsi(STR0036) //"*** Formacao Escolar nao cadastrada ***"
	Else
		cDetalhe:= Space(15)+ OemtoAnsi(STR0037) //"*** Curso ExtraCurricular nao cadastrado ***"
	EndIf
	Impr(cDetalhe,"C")
EndIf

cDetalhe:=""
Impr(cDetalhe,"C")

dbSelectArea(cSavAlias)
dbGoto(nSavReg)

RETURN

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FCaracteres � Autor � Equipe R.H. 		  Data � 01.06.16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Caracteristicas do candidato                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RdMake                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FCaracteres()
Local nX	:= 0
Local aAux	:= {}

If li > 55
	cDetalhe:=""
	Impr(cDetalhe,"P")
EndIf

cSavAlias:= Alias()
nSavReg  := RecNo()

cDetalhe:= Space(10)+OemtoAnsi(STR0041) //"CARACTERISTICAS DO FUNCION�RIO "
Impr(cDetalhe,"C")

cDetalhe:= ""
Impr(cDetalhe,"C")

dbSelectArea("SM6")
dbSetOrder(1)
dbSeek(xFilial("SM6")+SQG->QG_CURRIC)
While SM6->(!Eof() .And. xFilial("SM6")+SQG->QG_CURRIC == M6_FILIAL+M6_CURRIC)

	dbSelectArea("RS6")
	dbSetOrder(1)
	dbSeek(xFilial("RS6")+SM6->M6_TIPO)

	If RS6->RS6_INTERN <> "1"
		SM6->(DbSkip())
		Loop
	EndIf

	aAux := {}

	If !l1Vez
		cDetalhe:=""
		Impr(cDetalhe,"C")
	EndIf

	l1Vez := .F.

	If li > 55
		cDetalhe:=""
		Impr(cDetalhe,"P")
	EndIf

	cDetalhe:=Space(15)+OemtoAnsi(STR0042) //"Caracter�stica                 Resposta"

	Impr(cDetalhe,"C")

	If RS6->RS6_RESP == "3"
		QuebraR(Padr(RS6->RS6_DESC,31),Alltrim(SM6->M6_RESP))
	Else
		aAux := StrToArray( SM6->M6_ALTERNA , "*")
		For nX := 1 to Len(aAux)
			If nX == 1
				If !Empty(aAux[nX] )
					cDetalhe:=Space(15)+Padr(RS6->RS6_DESC,31) + aAux[nX] + " - " + PosAlias( "RS7" , RS6->RS6_CODIGO + aAux[nX] , cFilAnt, "RS7_DESC" )
				Else
					cDetalhe:=Space(15)+Padr(RS6->RS6_DESC,31)
				EndIf
				Impr(cDetalhe,"C")
			Else
				If !Empty(aAux[nX] )
					cDetalhe:=Space(46) + aAux[nX] + " - " + PosAlias( "RS7" , RS6->RS6_CODIGO + aAux[nX] , cFilAnt, "RS7_DESC" )
					Impr(cDetalhe,"C")
				EndIf
			EndIf
		Next nX
	EndIf

	l1Vez:= .F.

	dbSelectArea("SM6")
	dbSkip()
EndDo

If l1Vez
	cDetalhe:= Space(15)+ OemtoAnsi(STR0043) //"*** Caracter�sticas do Funcion�rio n�o foram definidas ***"
	Impr(cDetalhe,"C")
EndIf

cDetalhe:=""
Impr(cDetalhe,"C")

dbSelectArea(cSavAlias)
dbGoto(nSavReg)

Return

Static Function QuebraR(cDesc,cTexto)
Local nSpace 	:= 80
Local nTamStr 	:= Len( cTexto )
Local nIniStr 	:= 0
Local aLinhas	:= {}
Local cLinha	:= ""
Local nI		:= 1
Local nTam		:= 0
If nTamStr > nSpace
	nIniStr := 1
	While nTam < nTamStr

    	cLinha := SubStr( cTexto, nIniStr , nSpace )
		aAdd(aLinhas,cLinha)
    	nTam += Len(cLinha)
    	nIniStr += Len(cLinha)
    Enddo
Else
	cLinha += cTexto + Space(nSpace - Len(cTexto) -1)
	aAdd(aLinhas,cLinha)
EndIf
For nI := 1 To Len(aLinhas)
	If nI == 1
		cLinha:= Space(15)+cDesc + aLinhas[nI]
	Else
		cLinha:= Space(46) + aLinhas[nI]
	EndIf
	Impr(cLinha,"C")
Next nI
Return
