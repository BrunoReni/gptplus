#INCLUDE "PROTHEUS.CH"
#Include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99

/*
굇읕컴컴컴컴컴컨컴컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컴컴쩡컴컴컴컴컫컴컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿛rogramador  � Data     � FNC            �  Motivo da Alteracao                      낢�
굇쳐컴컴컴컴컴컴탠컴컴컴컴컵컴컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴낢�
굇쿎ecilia Car. �04/09/2014쿟QMSLV          쿐fetuada a limpeza do fonte.               낢�
굇읕컴컴컴컴컴컴좔컴컴컴컴컨컴컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Function GPER1020()        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= {"RA_NOME", "RA_NUMCP", "RA_SERCP"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

	If lBlqAcesso	//Tratamento de acesso a dados pessoais
		Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)	//"Dados Protegidos- Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Saiba mais em {link documenta豫o centralizadora}"
		Return
	EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CSTRING,AORD,CDESC1,CDESC2,CDESC3,ARETURN")
SetPrvt("NOMEPROG,ALINHA,NLASTKEY,CPERG,LEND,AINFO")
SetPrvt("CLIN,AT_PRG,WCABEC0,WCABEC1,WCABEC2,CONTFL")
SetPrvt("LI,NTAMANHO,TITULO,WNREL,ADRIVER,ACODFOL")
SetPrvt("NCONT,NORDEM,CFILDE,CFILATE,CCCDE,CCCATE")
SetPrvt("CMATDE,CMATATE,CNOMEDE,CNOMEATE,CCHAPADE,CCHAPAATE")
SetPrvt("CSITUACAO,CCATEGORIA,DDATAREF,NTIPFOR,NTAMETIQ,NNUMLIN")
SetPrvt("NCOLUNAS,CINICIO,CFIM,CINDCOND,CFOR,CARQNTX")
SetPrvt("CHAVE,CFILIALANT,CCCANT,NFUNC,CLINHA1,CDESCEMP")
SetPrvt("CDESCEND,CDESCATIV,CDESCCGC,NTPINSC,WCCTO,WTURNO")
SetPrvt("CNORMAL_A,CNORMAL_D,CCOMPRI_A,CCOMPRI_D,CEXPAND_A")
SetPrvt("CESPAND_D,CSEXTO_A,CSEXTO_D,COITAVO_A,COITAVO_D,CEXPOEN_A")
SetPrvt("CEXPOEN_D,CINDICE_A,CINDICE_D,CDESCFUNC,LTESTE,NCOL")
SetPrvt("VEZ,INI,CDESCCCTO,SOMA")
SetPrvt("CDESCTURN,")

#IFNDEF  WINDOWS
	#Translate PSAY => SAY
#Endif
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � IMPETIQ  � Autor � R.H. - Aldo Marini    � Data � 04.06.97 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Emiss꼘 da Etiqueta / Cart꼘 de Ponto em RdMake            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Folha de Pagamento                                         낢�
굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             낢�
굇쳐컴컴컴컴컴컫컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛rogramador � Data   � BOPS �  Motivo da Alteracao                     낢�
굇쳐컴컴컴컴컴컵컴컴컴컴탠컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�            �        �      �                                          낢�
굇쿘arinaldo   �18/05/00�------� Considerar apenas as 05 primeiras    posi낢�
굇�            �--------�------� coes para impressao do Codigo CNAE.      낢�
굇쿘arinaldo   �18/05/00�------� Acerto das Macros para o Protheus        낢�
굇쿘arina      �30/08/00�------쿣alidacao Filial/Acesso.Retirada parte DOS낢�
굇쿙atie       �29/08/01�009963쿛rnFlush-Descarrega spool impressao teste 낢�
굇쿙atie       �11/12/01�009963� Acerto Impressao-Teste                   낢�
굇�            �14/04/04�----- � Acerto Driver de Impressao               낢�
굇쿌lex        �18/08/09�020257쿌juste no Grupo de Campos filial          낢�
굇�            �        � /2009퀃ratamento para n�o considerar 2 posi寤es 낢�
굇�            �        �      쿯ixas.                                    낢�
굇읕컴컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis  (Basicas)                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cString := "SRA"  // alias do arquivo principal (Base)
aOrd    := { "Matricula","Centro de Custo","Nome","Chapa" } //Ordem
cDesc1  := "Emiss꼘 da Etiqueta / Cart꼘 de Ponto"
cDesc2  := "Ser� impresso de acordo com os parametros solicitados pelo"
cDesc3  := "usuario."


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis Private(Basicas)                            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aReturn  := { "Zebrado",1,"Administra뇙o",2,2,1,"",1 }
NomeProg := "IMPETIQ"
aLinha   := {}
nLastKey := 0
cPerg    := "GPR310"
lEnd     := .F.

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis (Programa)                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aInfo := {}
cLin:={0,0,0,0,0,0,0,0}

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis Utilizadas na funcao IMPR                          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

AT_PRG   := "IMPETIQ"
wCabec0  := 2
wCabec1  := ""
wCabec2  := ""
Contfl   := 1
Li       := 0
nTamanho := "M"

/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
� Variaveis de Acesso do Usuario                               �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸*/
cAcessaSRA	:= &( " { || " + ChkRH( "IMPETIQ" , "SRA" , "2" ) + " } " )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica as perguntas selecionadas                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
pergunte("GPR310",.F.)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis utilizadas para parametros                         �
//� mv_par01        //  Filial De                                �
//� mv_par02        //  Filial Ate                               �
//� mv_par03        //  Centro de Custo De                       �
//� mv_par04        //  Centro de Custo Ate                      �
//� mv_par05        //  Matricula De                             �
//� mv_par06        //  Matricula Ate                            �
//� mv_par07        //  Nome De                                  �
//� mv_par08        //  Nome Ate                                 �
//� mv_par09        //  Chapa De                                 �
//� mv_par10        //  Chapa Ate                                �
//� mv_par11        //  Situa뉏es                                �
//� mv_par12        //  Categorias                               �
//� mv_par13        //  Data Referencia                          �
//� mv_par14        //  Tipo Formulario 1-Etiqueta 2-Cartao Ponto�
//� mv_par15        //  Tamanho da Etiqueta                      �
//� mv_par16        //  Informe Numero Linhas para Salto         �
//� mv_par17        //  Numero de Colunas                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Titulo := "EMISS랳 ETIQUETA / CART랳 DE PONTO"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
wnrel:="IMPETIQ"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa Impressao                                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If ! fInicia(cString)
	Return
Endif

RptStatus({|| GR310Imp()},Titulo)// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> 	RptStatus({|| Execute(GR310Imp)},Titulo)
Return


Static Function GR310Imp()

Local X

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis (Programa)                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aCodFol := {}
nCont   := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
nOrdem     := aReturn[8]
cFilDe     := mv_par01
cFilAte    := mv_par02
cCcDe      := mv_par03
cCcAte     := mv_par04
cMatDe     := mv_par05
cMatAte    := mv_par06
cNomeDe    := mv_par07
cNomeAte   := mv_par08
cChapaDe   := mv_par09
cChapaAte  := mv_par10
cSituacao  := mv_par11
cCategoria := mv_par12
dDataref   := mv_par13
nTipFor    := mv_par14
nTamEtiq   := mv_par15
nNumLin    := mv_par16
nColunas   := If( mv_par17 > 4 , 4 ,mv_par17 )

If nNumLin == 0
	nNumLin := 1
Endif

Check_imp()

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
	cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
	cFim    := cFilAte + cMatAte
ElseIf nOrdem == 2
	dbSeek(cFilDe + cCcDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
	cFim    := cFilAte + cCcAte + cMatAte
ElseIf nOrdem == 3
	DbSeek(cFilDe + cNomeDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
	cFim    := cFilAte + cNomeAte + cMatAte
ElseIf nOrdem == 4
	dbSeek(cFilDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
	cFim    := cFilAte + cMatAte
Endif

If nOrdem == 4
    cIndCond := "SRA->RA_FILIAL + SRA->RA_CHAPA"
	cFor :='(RA_FILIAL + RA_CHAPA >= "'+cFilDe + cChapaDe+'")'
	cFor := cFor + '.And. (RA_FILIAL + RA_CHAPA <= "'+cFilAte + cChapaAte+'")'
Endif

If nOrdem == 4
	cArqNtx  := CriaTrab(Nil,.F.)
	IndRegua("SRA",cArqNtx,cIndCond,,cFor,"Selecionando Registros...")
Endif


dbSelectArea( "SRA" )
SetRegua(SRA->(RecCount()))

If nTamEtiq == 2
	@ Li,0 PSAY cOitavo_A
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Efetua  teste de Impressao                                   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If aReturn[5] # 1
	TesteEtq()
Endif

Chave      := 0
cFilialAnt := Space(FWGETTAMFILIAL)
cCcAnt     := Space(9)

dbSelectArea( "SRA" )
While !Eof() .And. Chave == 0 .And. !lEnd
	Afill(cLin,"")
	nFunc   := 0
	nCont   := 1
	cLinha1 := ""

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Cancela Impres�o ao se pressionar <ALT> + <A>                �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

	If lEnd
		@Prow()+1,0 PSAY cCancel
		Exit
	EndIF

	While !Eof() .And. Chave == 0 .And. nFunc < nColunas .And. !lEnd
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Movimenta Regua Processamento                                �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		IncRegua()

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Cancela Impres�o ao se pressionar <ALT> + <A>                �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		If lEnd
			@Prow()+1,0 PSAY cCancel
			Exit
		EndIF

		If SRA->RA_FILIAL # cFilialAnt
			If !fInfo(@aInfo,SRA->RA_FILIAL)
				Exit
			Endif
			dbSelectArea( "SRA" )
			cFilialAnt := SRA->RA_FILIAL
		Endif

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Verifica o De / Ate Solicitado                               �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		If nOrdem == 1
			If SRA->RA_FILIAL + SRA->RA_MAT > cFilAte + cMatAte
				Chave := 1
				Exit
			Endif
		Elseif nOrdem == 2
			If SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT > cFilAte + cCcAte + cMatAte
				Chave := 1
				Exit
			Endif
		Elseif nOrdem == 3
			If SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT > cFilAte + cNomeAte + cMatAte
				Chave := 1
				Exit
			Endif
		Elseif nOrdem == 4
			If SRA->RA_FILIAL + SRA->RA_CHAPA > cFilAte + cChapaAte
				Chave := 1
				Exit
			Endif
		Endif

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Consiste Parametriza눯o do Intervalo de Impress�o            �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		If (Sra->Ra_Chapa < cChapaDe) .Or. (Sra->Ra_Chapa > cChapaAte) .Or. ;
			(Sra->Ra_Nome < cNomeDe) .Or. (Sra->Ra_Nome > cNomeAte) .Or. ;
		   (Sra->Ra_Mat < cMatDe) .Or. (Sra->Ra_Mat > cMatAte) .Or. ;
			(Sra->Ra_CC < cCcDe) .Or. (Sra->Ra_CC > cCCAte)
			dbSelectArea( "SRA" )
			dbSkip()
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
			dbSkip()
			Loop
		Endif
		cLin[nCont] := cLin[nCont] + cCompri_A + "CHAPA:"+ Space(18)
		cLin[nCont] := cLin[nCont] + "CATEG:" + fDesc("SX5","28"+SRA->RA_CATFUNC,"X5DESCRI()",11,SRA->RA_FILIAL)+" "+Upper(FDESC_MES(Month(dDataRef),3))+"/"+PADR(Right(Str(Year(dDataRef)),IF(nTData=8,2,4)),4)+If(nfunc < 3,SPACE(6),"")
		cLinha1     := cLinha1 + cCompri_A + Space(7) + cNormal_A + cExpand_A + SRA->RA_CHAPA + cEspand_D + cCompri_A + If(nFunc < 3,Space(If(nFunc==1,31,32)),"")
		nCont := nCont + 1
		cLin[nCont] := cLin[nCont] + "NOME:"+SRA->RA_NOME+" MATR:"+SRA->RA_MAT+If(nFunc < 3,Space(9),"")
		nCont := nCont + 1
		cLin[nCont] := cLin[nCont] + "FUNCAO:"+DescFun(SRA->RA_CODFUNC,SRA->RA_FILIAL)+" CTPS:"+SRA->RA_NUMCP+ "/" +SRA->RA_SERCP + If(nFunc<3 , Space(10) , "" )

		cDescEmp  := aInfo[03]									// Razao Social
		cDescEnd  := aInfo[04]									// Endereco
		cDescAtiv := StrZero(Val(Subst(aInfo[16],1,5)),5)	// Atividade Economica CNAE
		cDescCgc  := aInfo[08]									// CGC/CEI
		nTpInsc   := aInfo[15]									// Tipo de Inscricao

		If nTpInsc == 1
			cDescCgc  := cDescCgc+Space(4)
		Elseif nTpInsc == 2
			cDescCgc  := Transform(cDescCgc,"@R ##.###.###/####-##")
		Else
			cDescCgc  := Transform(Subs(cDescCgc,1,11),"@R ###.###.###-##")+Space(4)
		Endif

		If nTamEtiq == 1
			nCont:= nCont + 1
			cLin[nCont] := cLin[nCont] + "EMPR: "+Left(cDescEmp,30)+" ATIVI:"+cDescAtiv+If(nFunc < 3,Space(8),"")
			nCont:= nCont + 1
			cLin[nCont] := cLin[nCont]+ "END:"+Left(cDescEnd,30)+" C.C:"+SRA->RA_CC+IF(nFunc < 3,Space(8),"")
		Endif

		nCont:= nCont + 1
		wCcto := DescCc(SRA->RA_CC,SRA->RA_FILIAL)
		If nTamEtiq == 1
			cLin[nCont] := cLin[nCont] + "CGC: "+cDescCgc+" "+Space(50-27-Len(Rtrim(wCcto)))+Rtrim(wCcto)+If(nFunc < 3,Space(9),"")
		Else
			cLin[nCont] := cLin[nCont] + "CGC: "+cDescCgc+" "+SRA->RA_CC+"-"+Left(wCcto,If(Len(SRA->RA_CC)==9,13,18))+If(nFunc < 3,Space(9),"")
		Endif

		nCont := nCont + 1
		cLin[nCont] := cLin[nCont] + "   HORARIO DE TRABALHO               INTERVALO"+If(nFunc < 3,Space(10),"")

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Busca o SR6 Horario de Trabalho e Intervalo                  �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		dbSelectArea( "SR6" )
		dbSeek(xFilial( "SR6" ) + SRA->RA_TNOTRAB )
		If !Found()
			wTurno := SPACE(50)
		Endif
		wTurno := SR6->R6_DESC
		nCont := nCont + 1
		cLin[nCont] := cLin[nCont] + wTurno + IF(nFunc < 3,Space(6),"")
		nFunc := nFunc + 1
		nCont := 1
		dbSelectArea( "SRA" )
		dbSkip()
	Enddo

	If lEnd
		Exit
	EndIF

	If cLin[1] # NIL
		For X := 1 To If(nTamEtiq == 1,8,6)
			@ LI, 0 PSAY cLin[X]
			IF X == 1
				@ Li, 0 PSAY cLinha1
				@ Li, 0 PSAY cLinha1
			Endif
			Li := Li + 1
		Next X
	Endif
	IF nTipFor == 2   // Se For Cartao de Ponto Salta para a Impressao do Proximo
		Li := Li + nNumLin
	Elseif nTamEtiq == 1
		Li := Li + 1
	Elseif nTamEtiq == 2
		Li := Li + 2
	Endif
	If Li > 70
		@ Li,0 PSAY " "
		Li := 1
		SetPrc(1,1)
	Endif
Enddo
If nTamEtiq == 2
	@ Li,0 PSAY cOitavo_D
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Termino do Relatorio                                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
dbSelectArea( "SRA" )
If nOrdem == 4
	RetIndex( "SRA" )
Endif
dbSetOrder(1)
If nOrdem == 4
	fErase( cArqNtx + OrdBagExt() )
Endif

Set Device To Screen

If aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel)
Endif

MS_FLUSH()
Return

*--------------------------*
Static Function Check_Imp()
*--------------------------*
cExpand_A := Chr(14)
cEspand_D := Chr(20)
cSexto_A  := Chr(27)+"0"
cSexto_D  := Chr(27)+"0"
cOitavo_A := Chr(27)+"0"
cOitavo_D := Chr(27)+"2"
cExpoen_A := Chr(27)+"S"+Chr(0)
cExpoen_D := Chr(27)+"T"
cIndice_A := Chr(27)+"S"+Chr(0)
cIndice_D := Chr(27)+"T"

If nColunas <= 2
	cNormal_A := AvalImp(132)
	cNormal_D := AvalImp(132)
	cCompri_A := AvalImp(132)
	cCompri_D := AvalImp(132)
Else
	cNormal_A := AvalImp(220)
	cNormal_D := AvalImp(220)
	cCompri_A := AvalImp(220)
	cCompri_D := AvalImp(220)
Endif
Return( .T. )

*---------------------------------*
// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> Function TesteEtq
Static Function TesteEtq()
*---------------------------------*

Local XW
Local MZ

cDescEmp  := Replicate("X",30)
cDescCgc  := Replicate("9",19)
cDescEnd  := Replicate("X",30)
cDescAtiv := "9999"
cDescFunc := Replicate("X",10)

lTeste := .T.

While lTeste
	nCont := 1
	nCol  := 0
	While nCont <= nColunas
		@ Li,nCol PSAY cCompri_A +"CHAPA:"+SPACE(18)+"CATEG:XXXXXXXXXXX XXX/99"
		nCont := nCont + 1
		nCol  := nCol + 57
	Enddo
	For XW := 1 To 2
		Vez := IIF(nCont == 5, 4 , Iif(nCont == 4 , 3 , Iif(nCont == 3 , 2 , 1)))
		Ini := 001
		For MZ := 1 To Vez
			Ini:=Iif(MZ==1,1,Iif(MZ==2,48,Iif(MZ==3,97,146)))
			@ Li,Ini PSAY cCompri_A + Space(6) + cNormal_A + cExpand_A + "99999" + cEspand_D + cCompri_A + Space(20)
		Next
	Next

	Li := Li + 1
	nCol := 0
	nCont:= 1
	While nCont <= nColunas
		@ Li,nCol PSAY "NOME:"+SRA->RA_NOME+" MATR.:"+SRA->RA_MAT
		nCol := nCol + 56
		nCont := nCont + 1
	Enddo

	Li := Li + 1
	nCol := 0
	nCont:= 1
	While nCont <= nColunas
		@ Li,nCol PSAY "FUNCAO:"+cDescFunc+" CTPS:"+SRA->RA_NUMCP+"/"+SRA->RA_SERCP
		nCol := nCol + 56
		nCont := nCont + 1
	Enddo

	If nTamEtiq == 1
		Li := Li + 1
		nCol := 0
		nCont:= 1
		While nCont <= nColunas
			@ Li,nCol PSAY "EMPR: "+cDescEmp+" ATIVID:"+cDescAtiv
			nCol := nCol + 56
			nCont := nCont + 1
		Enddo
		Li := Li + 1
		nCol := 0
		nCont:= 1
		While nCont <= nColunas
			@ Li,nCol PSAY "END.:"+cDescEnd+' CCUSTO:9999'
			nCol := nCol + 56
			nCont := nCont + 1
		Enddo
	Endif

	Li := Li + 1
	nCol := 0
	nCont:= 1
	While nCont <= nColunas
		cDescCcto := Replicate("X",24)
		@ Li,nCol PSAY "CGC: "+cDescCgc + Space(50-26-len(Rtrim(cDescCcto)))+Rtrim(cDescCcto)
		nCol := nCol + 56
		nCont := nCont + 1
	Enddo

	Li := Li + 1
	nCol := 0
	Soma := 1
	While Soma <= Vez
		@ Li,nCol PSAY "   HORARIO DE TRABALHO               INTERVALO"
		nCol := nCol + 56
		Soma := Soma + 1
	Enddo

	nCol := 0
	Li := Li + 1
	nCont:= 1
	While nCont <= nColunas
		cDescTurn := Replicate("X",51)
		@ Li,nCol PSAY Subst(cDescTurn,1,30)+Subst(cDescTurn,31,22)
		nCol := nCol + 56
		nCont := nCont + 1
	Enddo

	IF nTipFor == 2   // se for cartao salta para o proximo
		LI := Li + nNumLin
	Elseif nTamEtiq == 1
		LI := Li + 2
	Elseif nTamEtiq == 2
		LI := Li + 3
	Endif

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Testa impressao                                              �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	fImpTeste(cString)

Enddo
Return Li
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿯ImpTeste 튍utor  쿝.H. - Natie        � Data �  11/29/01   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿟esta impressao de Formulario Teste                         볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP5                                                        볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static function fImpTeste(cString)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Descarrega teste de impressao                                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
MS_Flush()
fInicia(cString)
Check_Imp()

Pergunte("GPR30A",.T.)
lTeste:= If(mv_par01 = 1 ,.F. , .T. )

Return lTeste

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿯Inicia   튍utor  쿝.H.Natie           � Data �  11/12/01   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿔nicializa Impressao                                        볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP5                                                        볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

static Function fInicia(cString)

If nLastKey == 27
	Return .F.
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Return .F.
Endif

Return  .T.
