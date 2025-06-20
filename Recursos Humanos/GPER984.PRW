#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "ETIQMD.CH"

Function GPER984()        // incluido pelo assistente de conversao do AP5 IDE em 05/07/00
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
	Local aFldRel		:= {"RA_NOME", "RA_ENDEREC", "RA_COMPLEM", "RA_BAIRRO", "RA_MUNICIP", "RA_ESTADO", "RA_CEP", "RA_CC"}
	Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
	//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
	//� identificando as variaveis publicas do sistema utilizadas no codigo �
	//� Incluido pelo assistente de conversao do AP5 IDE                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

	SetPrvt("CBTXT,CSTRING,AORD,CDESC1,CDESC2,CDESC3")
	SetPrvt("LEND,ARETURN,NOMEPROG,AMALADIR,NLASTKEY,CPERG")
	SetPrvt("AINFO,AT_PRG,WCABEC0,WCABEC1,WCABEC2,CONTFL")
	SetPrvt("LI,NTAMANHO,TITULO,WNREL,NORDEM,CFILDE")
	SetPrvt("CFILATE,CCCDE,CCCATE,CMATDE,CMATATE,CNOMEDE")
	SetPrvt("CNOMEATE,CCHAPADE,CCHAPAATE,CSITUACAO,CCATEGORIA,DDATAREF")
	SetPrvt("NCOLUNAS,CINICIO,CFIM,CINDCOND,CFOR,CARQNTX")
	SetPrvt("CHAVE,NCOL,NALIN,CFILIALANT,CCCANT")
	SetPrvt("CTIPO")

	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 05/07/00 ==>    #DEFINE PSAY SAY

	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 05/07/00 ==> #INCLUDE "ETIQMD.CH"

	/*
	複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
	굇쿑un뇚o    � ETIQMD   � Autor � R.H. - Fernando Joly  � Data � 07/12/98 낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
	굇쿏escri뇚o � Emiss꼘 da Etiqueta para Mala Diretao                      낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
	굇� Uso      � RdMake                                                     낢�
	굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
	굇�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             낢�
	굇쳐컴컴컴컴컴컫컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
	굇쿛rogramador � Data   � BOPS �  Motivo da Alteracao                     낢�
	굇쳐컴컴컴컴컴컵컴컴컴컴탠컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
	굇쿎ecilia Car.�04/09/14쿟QMSLV쿐fetuada a limpeza do fonte.              낢�
	굇읕컴컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Define Variaveis Locais (Basicas)                            �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	CbTxt   := ""     //Ambiente
	cString := "SRA"  // alias do arquivo principal (Base)
	aOrd    := {STR0001,STR0002,STR0003,STR0004} //"Matricula"###"Centro de Custo"###"Nome"###"Chapa"
	cDesc1  := STR0005      //"Emiss꼘 de Etiquetas P/ Mala Direta"
	cDesc2  := STR0006      //"Ser� impresso de acordo com os parametros solicitados pelo"
	cDesc3  := STR0007      //"usu쟲io."

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Define Variaveis Private(Basicas)                            �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	lEnd     := .F.
	aReturn  := {STR0008,1,STR0009,2,2,1,"",1 }     //"Zebrado"###"Administra뇙o"
	NomeProg := "ETIQMD"
	aMalaDir := {}
	nLastKey := 0
	cPerg    := "GPR360"

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Define Variaveis Private(Programa)                           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	aInfo := {}

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Variaveis Utilizadas na funcao IMPR                          �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	AT_PRG   := "ETIQMD"
	wCabec0  := 2
	wCabec1  := ""
	wCabec2  := ""
	Contfl   := 1
	Li       := 0
	nTamanho := "M"

	//Tratamento de acesso a Dados Sens�veis
	If lBlqAcesso
		//"Dados Protegidos-Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Saiba mais em {link documenta豫o centralizadora}"
		Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
		Return
	EndIf

	/*
	旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	� Variaveis de Acesso do Usuario                               �
	읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸*/
	cAcessaSRA	:= &( " { || " + ChkRH( "ETIQMD" , "SRA" , "2" ) + " } " )

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Verifica as perguntas selecionadas                           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	pergunte("GPR360",.F.)

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Variaveis utilizadas para parametros                         �
	//� MV_PAR01        //  Filial De                                �
	//� MV_PAR02        //  Filial Ate                               �
	//� MV_PAR03        //  Centro de Custo De                       �
	//� MV_PAR04        //  Centro de Custo Ate                      �
	//� MV_PAR05        //  Matricula De                             �
	//� MV_PAR06        //  Matricula Ate                            �
	//� MV_PAR07        //  Nome De                                  �
	//� MV_PAR08        //  Nome Ate                                 �
	//� MV_PAR09        //  Chapa De                                 �
	//� MV_PAR10        //  Chapa Ate                                �
	//� MV_PAR11        //  Situa뉏es                                �
	//� MV_PAR12        //  Categorias                               �
	//� MV_PAR13        //  Data Referencia                          �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	Titulo := STR0010          //"EMISS랳 DE ETIQUETAS P/ MALA DIRETA"

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Envia controle para a funcao SETPRINT                        �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	wnrel:="ETIQMD"            //Nome Default do relatorio em Disco
	wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	RptStatus({||GR360Imp()})// Substituido pelo assistente de conversao do AP5 IDE em 05/07/00 ==>    RptStatus({||Execute(GR360Imp)})
Return Nil

// Substituido pelo assistente de conversao do AP5 IDE em 05/07/00 ==>    function GR360Imp
Static function GR360Imp()
	Local T

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Carregando variaveis MV_PAR?? para Variaveis do Sistema.     �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	nOrdem     := aReturn[8]
	cFilDe     := MV_PAR01
	cFilAte    := MV_PAR02
	cCcDe      := MV_PAR03
	cCcAte     := MV_PAR04
	cMatDe     := MV_PAR05
	cMatAte    := MV_PAR06
	cNomeDe    := MV_PAR07
	cNomeAte   := MV_PAR08
	cChapaDe   := MV_PAR09
	cChapaAte  := MV_PAR10
	cSituacao  := MV_PAR11
	cCategoria := MV_PAR12
	dDataref   := MV_PAR13
	nColunas   := If( MV_PAR14 > 4 , 4 , MV_PAR14 )

	dbSelectArea( "SRA" )
	If nOrdem == 1
		dbSetOrder( 1 )
	ElseIf nOrdem == 2
		dbSetOrder( 2 )
	ElseIf nOrdem == 3
		dbSetOrder(3)
	ElseIf nOrdem == 4
		dbSetOrder(1)
	Endif

	dbGoTop()

	If nOrdem == 1
		dbSeek(cFilDe + cMatDe,.T.)
		cInicio := SRA->RA_FILIAL + SRA->RA_MAT
		cFim    := cFilAte + cMatAte
	ElseIf nOrdem == 2
		dbSeek(cFilDe + cCcDe + cMatDe,.T.)
		cInicio := SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT
		cFim    := cFilAte + cCcAte + cMatAte
	ElseIf nOrdem == 3
		dbSeek(cFilDe + cNomeDe + cMatDe,.T.)
		cInicio := SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT
		cFim    := cFilAte + cNomeAte + cMatAte
	ElseIf nOrdem == 4
		dbSeek(cFilDe + cMatDe,.T.)
		cInicio := SRA->RA_FILIAL + SRA->RA_MAT
		cFim    := cFilAte + cMatAte
	Endif

	If nOrdem == 4
		cIndCond:= "SRA->RA_FILIAL + SRA->RA_CHAPA"
		cFor :='(RA_FILIAL + RA_CHAPA >= "'+cFilDe + cChapaDe+'")'
		cFor := cFor + '.And. (RA_FILIAL + RA_CHAPA <= "'+cFilAte + cChapaAte+'")'
	Endif

	If nOrdem == 4
		cArqNtx  := CriaTrab(Nil,.F.)
		IndRegua("SRA",cArqNtx,cIndCond,,cFor,STR0011)  //"Selecionando Registros..."
	Endif

	dbSelectArea( "SRA" )
	SetRegua(SRA->(RecCount()))

	Chave      := 0
	Li         := PROW()
	nCol       := 1
	nAlin      := 0
	If aReturn[5] # 1
		Li         := PROW()  // PROW - Informe em que linha o carro de impressao esta posicionado//
	//	@Li ,0 PSAY chr(12)
	EndIf

	For T:=1 TO nColunas
		aAdd(aMalaDir,{" "," "," "," "," "," "," "," "})
	Next

	cFilialAnt := Space(FWGETTAMFILIAL)
	cCcAnt     := Space(GetSx3Cache("RA_CC", "X3_TAMANHO"))

	//@Li ,0 PSAY chr(12)

	dbSelectArea( "SRA" )
	While !SRA->(Eof()) .And. Chave == 0
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Movimenta Regua Processamento                                �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		IncRegua()

		If SRA->RA_FILIAL != cFilialAnt
			If !fInfo(@aInfo,SRA->RA_FILIAL)
				Chave := 1
				Exit
			Endif
			dbSelectArea( "SRA" )
			cFilialAnt := SRA->RA_FILIAL
		Endif


		While !Eof() .And. SRA->RA_FILIAL == cFilialAnt
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Movimenta Regua Processamento                                �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			IncRegua()

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Verifica o De / Ate Solicitado                               �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			IF &(IndexKey()) > cFim .Or. Sra->(Eof())
				Chave := 1
				Exit
			ENDIF

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Cancela Impres�o ao se pressionar <ALT> + <A>                �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If lEnd
				Set Device to Printer
				@Prow()+1,0 PSAY cCancela
				Set Device to Screen
				Chave := 1
				Exit
			EndIF

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Consiste Parametriza눯o do Intervalo de Impress�o            �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If	(SRA->RA_CHAPA < cChapaDe) .OR. (SRA->RA_CHAPA > cChapaAte) .Or. ;
				(SRA->RA_NOME < cNomeDe) .OR. (SRA->RA_NOME > cNomeAte) .Or. ;
				(SRA->RA_MAT < cMatDe) .OR. (SRA->RA_MAT > cMatAte) .Or. ;
				(SRA->RA_CC < cCcDe) .OR. (SRA->RA_CC > cCCAte)
				SRA->(DBSkip(1))
				Loop
			EndIf

			/*
			旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			쿎onsiste Filiais e Acessos                                             �
			읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
			IF !( SRA->RA_FILIAL $ fValidFil() .and. Eval( cAcessaSRA ) )
				dbSelectArea("SRA")
				dbSkip()
				Loop
			EndIF

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Verifica Situacao e Categoria do Funcionario                 �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If !( SRA->RA_SITFOLH $ cSituacao ) .OR. !( SRA->RA_CATFUNC $ cCategoria )
				Sra->(dbSkip(1))
				Loop
			Endif
			nAlin := nAlin+1

			aMalaDir[nAlin,1] := If (Len(SRA->RA_NOME) < 60, PadR(SRA->RA_NOME,45) ,SubStr(SRA->RA_NOME,1,45))
			aMalaDir[nAlin,2] := If (Len(SRA->RA_ENDEREC) < 60, PadR(SRA->RA_ENDEREC,45) ,SubStr(SRA->RA_ENDEREC,1,45))
			aMalaDir[nAlin,3] := If (Len(SRA->RA_COMPLEM + " " + SRA->RA_BAIRRO) < 45, PadR(SRA->RA_COMPLEM + " " + SRA->RA_BAIRRO,45) ,SubStr(SRA->RA_COMPLEM + " " + SRA->RA_BAIRRO,1,45))
			aMalaDir[nAlin,4] := If (Len(SRA->RA_MUNICIP + " " + SRA->RA_ESTADO + " " + Left(SRA->RA_CEP,5) + "-" + Right(SRA->RA_CEP,3)) < 45, PadR(SRA->RA_MUNICIP + " " + SRA->RA_ESTADO + " " + Left(SRA->RA_CEP,5) + "-" + Right(SRA->RA_CEP,3),45),SubStr(SRA->RA_MUNICIP + " " + SRA->RA_ESTADO + " " + Left(SRA->RA_CEP,5) + "-" + Right(SRA->RA_CEP,3),1,45))
			aMalaDir[nAlin,5] := If (Len(SRA->RA_FILIAL + "-" + SRA->RA_MAT + "-" + SRA->RA_CC) < 45, PadR(SRA->RA_FILIAL + "-" + SRA->RA_MAT + "-" + SRA->RA_CC,45) ,SubStr(SRA->RA_FILIAL + "-" + SRA->RA_MAT + "-" + SRA->RA_CC,1,45))
			cTipo := "I"
			fChkETMD()
			dbSkip()
		EndDo
		IF Chave == 1
			Exit
		EndIf

		If Eof()
			Exit
		EndIf
	Enddo
	cTipo:="F"
	fChkETMD()
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Termino do Relatorio                                         �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	dbSelectArea( "SRA" )
	Set Filter to
	dbSetOrder(1)

	If nOrdem == 4
		fErase( cArqNtx + OrdBagExt() )
	EndIf

	Set Device To Screen

	If aReturn[5] == 1
		Set Printer To
		dbCommit()
		OurSpool(WnRel)
	EndIf

	MS_FLUSH()

Return

*-------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 05/07/00 ==> FuncTion fChkETMD
Static FuncTion fChkETMD()
*-------------------------------------

Local C
Local I

If (cTipo == "I" .And. nAlin == nColunas) .Or. (cTipo == "F" .And. nAlin > 0)
   For C:= 1 To 5
      nCol:=0
      For I:= 1 To nColunas
          @ Li,nCol PSAY aMalaDir[I,C]
          nCol := nCol + 10
          aMalaDir[I,C]:= " "
      Next
      Li := Li + 1
   Next
   nAlin:=0
	Li := Li + 1
Endif

If Li >= 56
	Li := 0
EndIf

If cTipo == "F"
   @ Li, 0 PSAY " "
Endif

Return(nil)        // incluido pelo assistente de conversao do AP5 IDE em 05/07/00
