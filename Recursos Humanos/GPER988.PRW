#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "IMPCAT.CH"

Function GPER988()        // incluido pelo assistente de conversao do AP5 IDE em 05/07/00
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= {"RA_NOME", "RA_MAE", "RA_NASC", "RA_SEXO", "RA_ESTCIVI", "RJ_DESC", "RA_DTCPEXP", "RA_UFCP", "RA_DTRGEXP", "RA_RGEXP", "RA_RGUF", "RA_NUMCP", "RA_SERCP",;
						"RA_RG", "RA_PIS", "RA_ENDEREC", "RA_BAIRRO", "RA_MUNICIP", "RA_ESTADO", "RA_CEP", "RA_TELEFON"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CDESC1  ,CDESC2  ,CDESC3    ,CSTRING ,MV_PAR31 ,MV_PAR32")
SetPrvt("MV_PAR33,MV_PAR34,LCABECALHO,ARETURN ,NOMEPROG ,ALINHA"  )
SetPrvt("NLASTKEY,CPERG   ,NTAMANHO  ,LI      ,AINFO    ,LEND"    )
SetPrvt("CFILANTE,CTIT    ,WNREL     ,NORDEM  ,CFIL     ,CMAT"    )
SetPrvt("NTIPCAT ,DCOMOBI ,NAPOSEN   ,NAREA   ,DDTACI   ,CHRACI"  )
SetPrvt("CHRTRAB ,NTIPO   ,NAFAST    ,DULTDIA ,NLOCACI  ,CESPLOC" )
SetPrvt("CPARCOR ,CAGECAU ,CD01SIT   ,CD02SIT ,CD03SIT  ,CD04SIT" )
SetPrvt("NREGPOL ,NHOUMOR ,CNOMTES   ,CENDTES ,CBAITES  ,CMUNTES" )
SetPrvt("CUFTES  ,CTELTES ,CNOTES2   ,CENTES2 ,CBATES2  ,CMUTES2" )
SetPrvt("CUFTES2 ,CTLTES2 ,ADRIVER   ,CEMPNOM ,CEMPEND  ,CEMPCGC" )
SetPrvt("CCNAE   ,CBAIRRO ,CCEP      ,CMUNICI ,CUF      ,CTELEFO" )
SetPrvt("CCOMOBI ,CSEXO   ,CDESSEX   ,CESTCIV ,CDESFUN  ,CFILPRV" )
SetPrvt("CDESFIL ,CDTCPEXP,CUFCP     ,CDTRGEXP,CRGEXP   ,CRGUF"   )
SetPrvt("CDESTIP ,CDESLOC ,CCOMPAC   ,CNORMAL ,CCEICGC  ,CUFCEI" )
SetPrvt("CMUNCEI ,NSALARIOMES,NSALMES,NSALHORA,NSALDIA  ,AROTEIRO")
SetPrvt("ACODFOL ")

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿛rograma  � IMPCAT   � Autor � R.H. - Marina Shimano � Data � 14.06.00 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Relatorio CAT (Comunicacao de Acidente do Trabalho)        낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � IMPCAT                                                     낢�
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
cDesc1:= STR0001				//"Comunicacao de Acidente do Trabalho - CAT"
cDesc2:= STR0002				//"Ser� impresso de acordo com os parametros solicitados pelo"
cDesc3:= STR0003				//"usuario."
cString:='SRA' 				    //--alias do arquivo principal (Base)
MV_PAR31:=0
MV_PAR32:=0
MV_PAR33:=0
MV_PAR34:=0

lCabecalho:=.T.

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis Private(Basicas)                            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aReturn	:={STR0004,1,STR0005,2,2,1,'',1 }	//"Zebrado"###"Administra놹o"
NomeProg:='IMPCAT'
aLinha	:={}
nLastKey:=0
cPerg	:='IMPCAT'
nTamanho:="M"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis Utilizadas na funcao Principal do Programa         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Li		:= 0
aInfo	:={}
lEnd	:=.F.
cFilAnte:= Replicate("!", FWGETTAMFILIAL)
/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
� Variaveis utilizadas na fSalInc() - Remuneracao do Mes       �
| Consulta IOB : TR-20030508111605  08/05/03                   |
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸*/
aRoteiro:= {}
aCodFol	:= {}

//Tratamento de acesso a Dados Sens�veis
If lBlqAcesso
	//"Dados Protegidos- Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Saiba mais em {link documenta豫o centralizadora}"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Return
EndIf

If !FP_CODFOL(@aCodFol)
	Return
Endif

/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
� Variaveis de Acesso do Usuario                               �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸*/
cAcessaSRA	:= &( " { || " + ChkRH( "IMPCAT" , "SRA" , "2" ) + " } " )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica as perguntas selecionadas                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Pergunte('IMPCAT',.F.)



cTit:= STR0006		//"Comunicacao de Acidente do Trabalho - CAT"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
wnrel:="IMPCAT" 	//-- Nome Default do relatorio em Disco.
wnrel:=SetPrint(cString,WnRel,cPerg,cTit,cDesc1,cDesc2,cDesc3,.F.,,,nTamanho)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Carregando variaveis MV_PAR?? para Variaveis do Sistema.     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

cFil    := MV_PAR01					//  Filial
cMat    := MV_PAR02					//  Matricula
nTipCat := MV_PAR03					//  Tipo de CAT		1-Inicial    2-Reabertura    3-Comunicacao de Obito
dComObi := MV_PAR04					//  Data de comunicacao de obito
nAposen := MV_PAR05					//  Aposentado
nArea   := MV_PAR06					//  Area (Urbana ou Rural)
dDtAci  := MV_PAR07					//  Data do Acidente
cHrAci  := MV_PAR08					//  Hora do Acidente
cHrTrab := MV_PAR09					//  Apos qtas. horas trabalhadas
nTipo   := MV_PAR10					//  Tipo 1- Tipico 2- Doenca 3- Trajeto
nAfast  := MV_PAR11					//  Houve Afastamento  1- Sim 2-Nao
dUltDia := MV_PAR12					//  Ultimo dia trabalhado
nLocAci := MV_PAR13					//  Local do Acidente
cEspLoc := MV_PAR14					//  Especific.Local do Acidente
cParCor := MV_PAR15					//  Parte(S) do corpo atingida(S)
cAgeCau := MV_PAR16					//  Agente Causador
cD01Sit := MV_PAR17					//  Descr01 Situacao gerad. do Acidente/Doenca
cD02Sit := MV_PAR18					//  Descr02 Situacao gerad. do Acidente/Doenca
cD03Sit := MV_PAR19					//  Descr03 Situacao gerad. do Acidente/Doenca
cD04Sit := MV_PAR20					//  Descr04 Situacao gerad. do Acidente/Doenca
nRegPol := MV_PAR21					//  Houve registro policial  1- Sim 2-Nao
nHouMor := MV_PAR22					//  Houve Morte  1- Sim 2-Nao
cNomTes := MV_PAR23					//  Nome Testemunha 1
cEndTes := MV_PAR24					//  Endereco (Rua/Av/No./Compl.)
cBaiTes := MV_PAR25					//  Bairro/Cep	Testemunha 1
cMunTes := MV_PAR26					//  Municipio	Testemunha 1
cUfTes  := MV_PAR27					//  UF			Testemunha 1
cTelTes := MV_PAR28					//  Telefone 	Testemunha 1
cNoTes2 := MV_PAR29					//  Nome Testemunha 2
cEnTes2 := MV_PAR30					//  Endereco (Rua/Av/No./Compl.)
cBaTes2 := MV_PAR31					//  Bairro/Cep Testemunha 2
cMuTes2 := MV_PAR32					//  Municipio  Testemunha 2
cUfTes2 := MV_PAR33					//  UF         Testemunha 2
cTlTes2 := MV_PAR34					//  Telefone   Testemunha 2
nVias	:= MV_PAR35					//  Numero de vias a imprimir

If nLastKey == 27
	Return Nil
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return Nil
Endif

lEND:= .F.
wnrel:= "IMPCAT"
cString:= "SRA"

RptStatus({|lEnd| fImpCat()})
Return

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿔MPCAT    튍utor  쿘icrosiga           � Data �  06/02/03   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿛rocessa informacoes para Impressao doi CAT                 볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � Especifico                                                 볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function fImpCat()


/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿞etar impressora                                                       �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
@ 0,0 PSAY AvalImp(132)

dbSelectArea("SRA")
dbSetOrder(1)
If !dbSeek(cFil+cMat)
	Help("",1,"NOFUNC")
	Return
EndIf

/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿎onsiste Filiais e Acessos                                             �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
IF !( SRA->RA_FILIAL $ fValidFil() .and. Eval( cAcessaSRA ) )
	dbSelectArea("SRA")
	Return( NIL )
EndIf

If	!fInfo(@aInfo,SRA->RA_FILIAL)
	Help("",1,"NOEMPRY")
	Return
Endif

cEmpNom := SubStr(aInfo[03]+Space(60),1,60)
cEmpEnd := SubStr(aInfo[04] + Space(48) , 1 , 48 )
cEmpCgc := SubStr(aInfo[08],1,2 ) + "." + SubStr( aInfo[08],3,3 ) + "." + SubStr( aInfo[08],6,3 ) + "/" + SubStr( aInfo[08],9,4 ) + "-" + SubStr( aInfo[08],13,2 )	//cInss   := Substr( aInfo[09],1,14)
cCnae   := SubStr(aInfo[16] + Space(07) , 1 , 07 )
cBairro := SubStr(aInfo[13] + Space(15) , 1 , 15 )
cCep    := SubStr(aInfo[07] + Space(08) , 1 , 08 )
cMunici := SubStr(aInfo[05] + Space(20) , 1 , 20 )
cUf     := SubStr(aInfo[06] + Space(02) , 1 , 02 )
cTelefo := SubStr(aInfo[10] + Space(14) , 1 , 14 )
cCeiCgc	:= Space(14)
cUfCei 	:= Space(2)
cMunCei	:= Space(20)

/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿔mpressao data de comunicacao de obito                                 �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
cComObi:= If(nTipCat ==3, DTOC(dComObi), "        ")
/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Verifica se Masculino ou Feminino                                     �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
cSexo := SubStr(SRA->RA_SEXO,1,1)
If cSexo =="M"
	cSexo :="[1]"
Else
	cSexo :="[3]"
EndIf
cDesSex:=" 1-Masc. 3-Fem."
/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Verifica Estado Civil                                                 �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
cEstCiv := SRA->RA_ESTCIVI
If cEstCiv =="S"
	cEstCiv :="[1] Solteiro  "
ElseIf cEstCiv == "C"
	cEstCiv :="[2] Casado    "
ElseIf cEstCiv == "V"
	cEstCiv :="[3] Viuvo     "
ElseIf cEstCiv =="D"
	cEstCiv :="[4] Sep.Judic."
Else
	cEstCiv :="[5] Outro     "
EndIf

/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Verifica Descricao da Funcao                                          �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
dbSelectArea("SRJ")
dbSetOrder(1)
cDesFun := "                    "
dbSeek(xFilial("SRJ", SRA->RA_FILIAL)+SRA->RA_CODFUNC)
If TYPE("SRJ->RJ_FUNCAO") != "U" .And. !Empty(SRJ->RJ_FUNCAO)
	cDesFun := SRJ->RJ_DESC
EndIf
dbSelectArea("SRA")


/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Filiacao a Prev. Social                                               �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
cFilPrv := SRA->RA_CATFUNC
If cFilPrv == "P" .AND. SRA->RA_VIEMRAI == "80"
   cDesFil := "[7]Seg.Especial "
ElseIf cFilPrv == "A"
   cDesFil := "[2]Trab.Avulso  "
Else
   cDesFil := "[1]Empregado    "
EndIf

/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Data Emissao da Carteira Profissional                                 �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
cDtCpExp := "        "
If TYPE("SRA->RA_DTCPEXP") #"U" .And. !Empty(SRA->RA_DTCPEXP)
   cDtCpExp := DTOC(SRA->RA_DTCPEXP)
EndIf

/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� UF da Carteira Profissional                                           �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
cUfCp := "  "
If TYPE("SRA->RA_UFCP") #"U" .And. !Empty(SRA->RA_UFCP)
   cUfCp := SRA->RA_UFCP
EndIf
/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Data Emissao do RG                                                    �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
cDtRgExp := "        "
If TYPE("SRA->RA_DTRGEXP") != "U" .And. !Empty(SRA->RA_DTRGEXP)
   cDtRgExp := DTOC(SRA->RA_DTRGEXP)
EndIf

/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Orgao Expedicao do RG                                                 �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
cRgExp := "      "
If TYPE("SRA->RA_RGEXP") #"U" .And. !Empty(SRA->RA_RGEXP)
   cRgExp := SRA->RA_RGEXP
EndIf

/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� UF do RG                                                              �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
cRgUf := "  "
If TYPE("SRA->RA_RGUF") #"U" .And. !Empty(SRA->RA_RGUF)
   cRgUf := SRA->RA_RGUF
EndIf

/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Tipo de Acidente                                                      �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
If nTipo ==1
   cDesTip := "[1] Tipico "
ElseIf nTipo ==2
   cDesTip := "[2] Doenca "
ElseIf nTipo ==3
   cDesTip := "[3] Trajeto"
EndIf

/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Local do Acidente                                                     �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
If nLocAci ==1
   cDesLoc := "[1]Estab.Empregadora        "
Elseif nLocAci ==2
   cDesLoc := "[2]Empresa onde presta serv."
	/*
	旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	� Deve-se informar, neste caso ,  o CGC/CNPJ da empresa onde ocorreu ou acidente �
	읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸*/
	dbSelectArea("CTT")
	If dbSeek( xFilial("CTT") + SRA->RA_CC )
		cCeiCgc	:= CTT->CTT_CEI
		cUfCei 	:= CTT->CTT_ESTADO
		cMunCei	:= CTT->CTT_MUNIC
	Endif
	DBCloseArea()
Elseif nLocAci ==3
   cDesLoc := "[3]Via publica              "
Elseif nLocAci ==4
   cDesLoc := "[4]Area Rural               "
Elseif nLocAci ==5
   cDesLoc := "[5]Outros                   "
Else
   cDesLoc := "                            "
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Remuneracao Mensal - Verif.se Existe Incorporacao de Salario �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
nSalarioMes:= nSalMes:=nSalHora:=nSalDia:= 0
fSalInc(@nSalarioMes,@nSalMes,@nSalHora,@nSalDia)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Imprime CAT                                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If lCabecalho
	Cabec()
	lCabecalho := .F.
Endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Imprimir Corpo do Relatorio                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Set Device To Printer
Return Nil


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿔MPCAT    튍utor  쿘icrosiga           � Data �  06/02/03   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝otina de Impressao do Comunicado de Acidente de Trabalho   볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � Especifico                                                 볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function Cabec()

Local nImprVias	:= 0

Set Device To Printer

@ 00,00 PSAY AvalImp(132)

For nImprVias := 1 to nVias
	@ 01,01 PSAY "+-------------------------------------------------------------------------------------------------------------------------------+"
	@ 02,01 PSAY "|                      PREVIDENCIA SOCIAL                     " + STR0007 +Space(2)+ "[1]"+ Space(48)+ "|" //"|01.Emitente"
	@ 03,01 PSAY "|             INSTITUTO NACIONAL DE SEGURO SOCIAL             " + STR0008 //"|1-Empregador 2-Sindicato 3-Medico 4-Segur./Depend. 5-Aut.publica|"
	@ 04,01 PSAY "|           COMUNICACAO DE ACIDENTE DO TRABALHO - CAT         " + STR0009 +Space(2)+ "["+ Str(nTipCat,1)+"]"+ Space(45)+ "|" //"|02.Tipo de CAT"
	@ 05,01 PSAY "|                                                             " + STR0010 + cComObi + Space(04)+ "|"// "|1-Inicial    2-Reabertura    3-Comunicacao de Obito:"
	@ 06,01 PSAY STR0011  //"+--- EMPREGADOR ----------------------------------------------------------------------------------------------------------------+"
	@ 07,01 PSAY STR0012  //"|   |03. Razao Social / Nome                                            04. Inscricao                      05. CNAE             |"
	@ 08,01 PSAY "|   |   " + cEmpNom + Space(07) + "[1]CGC/CNPJ  "+ cEmpCgc +Space(5)+ cCnae +Space(10)+"|"
	@ 09,01 PSAY STR0013  //"|   |06.Endereco                                      Bairro          CEP      07.Municipio		         08.UF 09.Telefone      |"
	@ 10,01 PSAY "|   |   " + cEmpEnd + Space(02)+ cBairro+Space(01) + cCep +Space(05)+ cMunici +Space(01)+ cUf +Space(04)+cTelefo +"|"
	@ 11,01 PSAY STR0014  //"|   +--- ACIDENTADO ------------------------------------------------------------------------------------------------------------+"
	@ 12,01 PSAY STR0015 + SubStr(SRA->RA_NOME + Space(30), 1 ,30)+ Space(16) +STR0016 + SubStr(SRA->RA_MAE + Space(30), 1 ,30)+ Space(06) + " |" //"|10.Nome do Acidentado: " //"11. Nome da Mae: "
	@ 13,01 PSAY STR0017  //"|   |12.Nascimento	 13.Sexo			14.Estado Civil		15.CTPS			Serie		Emissao		16.UF		17.Remun.Mensal    |"
	@ 14,01 PSAY "|   |   " + DtoC(SRA->RA_NASC)+ Space(06)+ cSexo + cDesSex +Space(5)+cEstCiv +Space(05)+ SRA->RA_NUMCP + Space(02);
	                    + SRA->RA_SERCP + Space(04)+ cDtCpExp + Space(09)+ cUFCp+Space(06)+ Transform(nSalMes,"@E 999,999,999.99")
	@ 14,129 PSAY "|"
	@ 15,01 PSAY STR0018  //"|   |18.Identidade		Emissao		Orgao Exp.		19.UF		20.PIS/PASEP/NIT											   |"
	@ 16,01 PSAY "|   |   " + SRA->RA_RG + Space(04) + cDtRgExp +Space(08)+ cRGExp+ SPACE(09)+ cRgUf + Space(10)+ Transform(SRA->RA_PIS,"@R 999.999.999-99")+Space(43)+ " |"
	@ 17,01 PSAY STR0019  //"|   |21.Endereco (Rua/Av./No./Compl.)                   Bairro          Cep      23.Municipio            23.UF 24.Telefone            |"
	@ 18,01 PSAY "|   |   " + SubStr(SRA->RA_ENDEREC,1,30)+Space(05)+ SRA->RA_BAIRRO +Space(04)+ SRA->RA_CEP +Space(08)+ SRA->RA_MUNICIP + SPACE(3)+SRA->RA_ESTADO +Space(05)+ SRA->RA_TELEFON + "|"
	@ 19,01 PSAY STR0020  //"|   |25.Nome da Ocupacao             26.CBO             27.Filiacao INSS            28.Aposentado?                29.Area         |"
	@ 20,01 PSAY "|   |   " + cDesFun+ Space(11)+ Substr(fCodCBO(SRA->RA_FILIAL,SRA->RA_CODFUNC,dDataBase)+Space(6),1,6) + Space(14)+cDesFil +Space(11)+" [" +Str(nAposen,1)+"]"+ Space(1)+STR0033+Space(4)+ " ["+Str(nArea,1)+"]"+Space(1)+STR0034 + " |"
	@ 21,01 PSAY STR0021 //"|   +--- ACIDENTE OU DOENCA ----------------------------------------------------------------------------------------------------+"
	@ 22,01 PSAY STR0022  //"|   |30.Data Acidente      31.Hr Acidente    32.Hrs Trabalhadas      33.Tipo        34.Houve Afastamento?    35.Ultimo dia Trab.|"
	@ 23,01  PSAY "| E |   " + DtoC(dDtAci)+Space(14)+ cHrAci+Space(13)+ cHrTrab+Space(17)+ cDesTip+Space(04)+ "["+Str(nAfast,1)+"]"+ STR0033+Space(11)+ If(nAfast=1, DtoC(dUltDia) ,"___/___/___" )
	@ 23,129 PSAY "|"
	@ 24,01 PSAY STR0023  //"|   |36.Local Acidente                    37.Especificacao Local          38.Cgc                39.UF      40.Municipio         |"
	@ 25,01 PSAY "| N |   " + cDesLoc+ Space(09)+ cEspLoc +Space(2) + cCeiCgc +Space(8) + cUfCei+ Space(07)+ cMunCei + "|"
	@ 26,01 PSAY STR0024 + cParCor +Space(9)+ STR0025 + cAgeCau+Space(6) + "|"//"|   |41.Parte do corpo atingida                                        42.Agente Causador                                       |"
	@ 27,01 PSAY STR0026  //"|   |43.Descricao da Situacao Geradora do Acidente ou doenca                             44.Houve Registro Policial             |"
	@ 28,01 PSAY "|   |   " + cD01Sit + cD02Sit+Space(24) + "["+Str(nRegPol,1)+"]"+ Space(1)+STR0033 +Space(21)+ "|"
	@ 29,01 PSAY "| E |   " + cD03Sit + cD04Sit+Space(21)+STR0027+ " ["+Str(nHouMor,1)+"]"+Space(1)+ STR0033 +Space(06)+ " |"  //"45.Houve Morte?                        |"
	@ 30,01 PSAY STR0028  //"|   +--- TESTEMUNHAS -----------------------------------------------------------------------------------------------------------+"
	@ 31,01 PSAY STR0029 + cNomTes +Space(84)+ "|" //"|46.Nome: "
	@ 32,01 PSAY STR0030  //"|   |47.Endereco                              Bairro\CEP              48.Municipio               49.UF         Telefone         |"
	@ 33,01 PSAY "|   |   " + cEndTes + Space(8) + cBaiTes+ Space(2) + cMuntes + Space(4) + cUfTes + Space(09) + cTelTes +" |"
	@ 34,01 PSAY STR0031 + cNoTes2 +Space(83)+ " |" //'|50.Nome: '
	@ 35,01 PSAY STR0032  //"|   |51.Endereco                              Bairro/CEP              52.Municipio               53.UF         Telefone         |"
	@ 36,01 PSAY "|   |   " + cEnTes2 + Space(8) +cBates2 + Space(2)+ cMuTes2 + Space(4) + cUfTes2 + Space(09) + cTlTes2 +" |"
	@ 37,01 PSAY "|   +---------------------------------------------------------------------------------------------------------------------------+"
	@ 38,01 PSAY STR0035  //"|   |                __________________________________          ________________________________________                       |"
	@ 39,01 PSAY STR0036  //"|   |                          Local e Data                          Assinatura e carimbo do Emitente                          |"
	@ 40,01 PSAY STR0037  //"+--- ATENDIMENTO --------------------------------------------------------------------------------------------------------------+"
	@ 41,01 PSAY STR0038  //"| A |54.Unidade de Atendimento Medico                                                    55.Data              56.Hora           |"
	@ 42,01 PSAY STR0039  //"| T |                                                                                       ___/___/___          ___:___        |"
	@ 43,01 PSAY STR0040  //"| E |57.Houve Internacao?  58.Duracao Provavel do Tratamento   59.Devera o acidentado afastar-se do trabalho durante tratamento?|"
	@ 44,01 PSAY STR0041  //"| S |  [ ] 1-Sim 2-Nao                   ______________Dias       [ ] 1-Sim 2-Nao                                               |"
	@ 45,01 PSAY STR0042  //"| T +--- LESAO -----------------------------------------------------------------------------------------------------------------+"
	@ 46,01 PSAY STR0043  //"| A |60.Descricao e Natureza da Lesao                                                                                           |"
	@ 47,01 PSAY STR0044  //"| D |                                                                                                                           |"
	@ 48,01 PSAY STR0045  //"| O +--- DIAGNOSTICO -----------------------------------------------------------------------------------------------------------+"
	@ 49,01 PSAY STR0046  //"|   |61.Diagnostico Provavel                                                                               |62.CID-10           |"
	@ 50,01 PSAY STR0047  //"| M |                                                                                                      |                    |"
	@ 51,01 PSAY STR0048  //"| E |                                                                                                      |                    |"
	@ 52,01 PSAY STR0049  //"| D |63.Observacoes ------------------------------------------------------------------------------------------------------------+"
	@ 53,01 PSAY STR0050  //"| I |                                                                                                                           |"
	@ 54,01 PSAY STR0051  //"| C +---------------------------------------------------------------------------------------------------------------------------+"
	@ 55,01 PSAY "| O |               __________________________________          ________________________________________                        |"
	@ 56,01 PSAY STR0052  //"|   |                        Local e Data                       Assinatura e carimbo do Medico com CRM                          |"
	@ 57,01 PSAY STR0053  //"+-------------------------------------------------------------------------------------------------------------------------------+"
	@ 58,01 PSAY STR0054  //"|   |64.Recebida em   65.Cod. da Unidade   66.No.CAT   |NOTAS:1- A inexatidao das declaracoes desta comunicacao implicara nas   |"
	@ 59,01 PSAY STR0055  //"| I | ___/___/___      _______________      __________ |         sancoes previstas nos arts.171 e 299 do Codigo Penal.          |"
	@ 60,01 PSAY STR0056  //"| N |68.Matricula do Servidor                          |      2- A comunicacao de acidente do trabalho devera ser feita ate o   |"
	@ 61,01 PSAY STR0057  //"| S |  _____________  ________________________________ |         1o. dia util apos o acidente,sob pena de multa na forma previs-|"
	@ 62,01 PSAY STR0058  //"| S |    Matricula        Assinatura do Servidor       |         ta no art. 22 da Lei no. 8.213/91.                             |"
	@ 63,01 PSAY STR0059  //"+-------------------------------------------------------------------------------------------------------------------------------+"
	@ 64,01 PSAY STR0060  //"A COMUNICACAO DO ACIDENTE E OBRIGATORIA, MESMO NO CASO EM QUE NAO HAJA AFASTAMENTO DO TRABALHO.                                  "
Next nImprVias

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Termino do Relatorio.                                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
dbSelectArea( 'SRA' )
RetIndex('SRA')
dbSetOrder(1)

dbSelectArea( 'SRJ' )
dbSetOrder(1)

Set Device To Screen
If aReturn[5] == 1
	Set Printer To
	dbCommit()
	OurSpool(WnRel)
Endif
MS_Flush()

Return Nil
