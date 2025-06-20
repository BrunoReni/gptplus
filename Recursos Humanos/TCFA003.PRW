#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCFA003.CH"
/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � TCFA003  � Autor � Marinaldo de Jesus    � Data �20/12/2001�
�����������������������������������������������������������������������Ĵ
�Descri��o � Geracao de senhas para o Terminal de Consultas             �
�����������������������������������������������������������������������Ĵ
�Sintaxe   � TCFA003()                                                  �
�����������������������������������������������������������������������Ĵ
�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             �
�����������������������������������������������������������������������Ĵ
�Programador � Data   � BOPS �  Motivo da Alteracao                     �
�����������������������������������������������������������������������Ĵ
�Cecilia Car.�24/07/14�TQEA22�Incluido o fonte da 11 para a 12 e efetua-� 
�            �        �      �da a limpeza.                             � 
�������������������������������������������������������������������������*/
Function TCFA003()

Local aArea		:= GetArea()
Local aAreaSRA	:= {}
Local aSays		:= {}
Local aButtons	:= {}
Local cTCFSDoc	:= SuperGetMv( "MV_TCFSDOC" , .F. , "1" ) // '1' = Utiliza CPF   '2'= Utiliza RG
Local cDescSDoc:= AllTrim( RetTitle( If( cTCFSDoc=="2", "RA_RG", "RA_CIC" ) ) )
Local nOpca	:= 0.00
Local oDlg

Private cCadastro := OemtoAnsi( STR0001 ) //"Gera����o de Senhas para os funcion�rios"

IF ( ChkVazio("SRA") )
	
	aAreaSRA := SRA->( GetArea() )
	
	aAdd(aSays,OemToAnsi( STR0002 ) ) //"Este programa gera as senhas dos funcion�rios para consulta no Terminal - (RH OnLine)."
	aAdd(aSays,OemToAnsi( STR0003 ) ) //"A senha � formada da seguinte forma: "

	If cPaisLoc == "BRA"
		aAdd(aSays,OemToAnsi( STR0004 ) ) //"Ano de Nascimento do Funcion�rio + Dia Admiss�o + D�gito do CPF."
		aAdd(aSays,OemToAnsi( STR0006 ) ) //"Ex.: Um funcion�rio nascido em 20/11/66, admitido em 14/09/90 e"
		aAdd(aSays,OemToAnsi( STR0005 ) ) //"com CPF 123732768-55, a senha gerada ser�: ** 661455 ** "
	Else
		aAdd(aSays,OemToAnsi( STR0007 + cDescSDoc + '.') ) //"Ano de Nascimento do Funcion�rio + Dia Admiss�o + 2 �ltimos d�gitos do campo "
		aAdd(aSays,OemToAnsi( STR0006 ) ) //"Ex.: Um funcion�rio nascido em 20/11/66, admitido em 14/09/90 e"
		aAdd(aSays,OemToAnsi( STR0008 + cDescSDoc + STR0009 ) ) //"com "XXXX" 123732768-55, a senha gerada ser�: ** 661455 ** "
	EndIf

	aAdd(aButtons, { 5,.T.,{|| Pergunte("TCFPAS",.T. ) } } )
	aAdd(aButtons, { 1,.T.,{|o| nOpca := 1,IF( gpconfOK() , FechaBatch() , nOpca := 0 ) } } )
	aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
	FormBatch( cCadastro, aSays, aButtons,,, If(cPaisLoc<>"BRA",580,) )

	IF ( nOpcA == 1 )
		Processa( { || TCFA003Gera() } )
	EndIF

	RestArea( aAreaSRA )
	
EndIF

RestArea( aArea )

Return( NIL )

/*
������������������������������������������������������������������������Ŀ
�Fun��o    �TCFA003Gera� Autor � Marinaldo de Jesus    � Data �20/12/2001�
������������������������������������������������������������������������Ĵ
�Descri��o � Geracao de senhas                                        	 �
������������������������������������������������������������������������Ĵ
� Uso      � TCFA003                                                     �
��������������������������������������������������������������������������*/
Static Function TCFA003Gera()

Local bEval		:= { |e| &(e) }
Local cExclui	:= "" 
Local cFim		:= ""
Local cSenha	:= ""
Local lRet		:= .T.
Local lTCFA03FIL:= ExistBlock("TCFA03FIL")
Local cDocOfic	:= ""
Local cTCFSDoc	:= SuperGetMv( "MV_TCFSDOC" , .F. , "1" ) // '1' = Utiliza CPF   '2'= Utiliza RG

Private cInicio := ""

/*
�����������������������������������������������������������������������Ŀ
�Carrega Pergunte														�
�������������������������������������������������������������������������*/
Pergunte("TCFPAS",.F.)

/*
�����������������������������������������������������������������������Ŀ
�Carregando mv_par para variaveis do Sistema.                           �
�������������������������������������������������������������������������*/
Private cFilDe		:= mv_par01				//Filial De
Private cFilAte		:= mv_par02				//Filial Ate
Private cMatDe		:= mv_par03				//Matricula De
Private cMatAte		:= mv_par04				//Matricula Ate
Private cNomeDe		:= mv_par05				//Nome De
Private cNomeAte	:= mv_par06				//Nome Ate
Private dAdmissDe	:= mv_par07				//Admissao De
Private dAdmissAte	:= mv_par08				//Admissao Ate
Private cSituacao	:= mv_par09				//Situacaoes
Private cCategoria	:= mv_par10				//Categorias
Private lClearPassW := ( mv_par11 == 2 )	//Gerar ou Limpar

/*
�����������������������������������������������������������������������Ŀ
�Bloco que definira a Consistencia da Parametrizacao dos Intervalos sele�
�cionados nas Perguntas De? Ate?.                                       �
�������������������������������������������������������������������������*/
cExclui := cExclui + "(RA_FILIAL  < cFilDe     .or. RA_FILIAL  > cFilAte    ).or."
cExclui := cExclui + "(RA_MAT     < cMatDe     .or. RA_MAT     > cMatAte    ).or." 
cExclui := cExclui + "(RA_NOME    < cNomeDe    .or. RA_NOME    > cNomeAte   ).or." 
cExclui := cExclui + "(RA_ADMISSA  < dAdmissDe .or. RA_ADMISSA > dAdmissAte ).or." 
cExclui := cExclui + "!(RA_SITFOLH$cSituacao)  .or. !(RA_CATFUNC$cCategoria)"

/*
����������������������������������������������������������������������Ŀ
� Carrega a Regua de Processamento									   �
������������������������������������������������������������������������*/
ProcRegua( SRA->(RecCount() ) )

/*
����������������������������������������������������������������������Ŀ
� Posiciona no Primeiro Registro Selecionado nos Parametros De/Ate     �
������������������������������������������������������������������������*/
dbSelectArea("SRA")
SRA->( dbSetOrder(01) )
SRA->( dbSeek( cFilDe + cMatDe , .T. ) )
cInicio	:= "RA_FILIAL + RA_MAT"
cFim	:= cFilAte + cMatAte

While SRA->( !Eof() .and. Eval( bEval , cInicio ) <= cFim )

    /*
	���������������������������������������������������Ŀ
	� Aborta o Processamento                            �
	�����������������������������������������������������*/
	IncProc()

	/*
	�����������������������������������������������������������������������Ŀ
	�Consiste Intervalo das Perguntas De? Ate?                              �
	�������������������������������������������������������������������������*/
	IF SRA->( Eval( bEval , cExclui ) )
		SRA->( dbSkip() )
		Loop
	EndIF
	
	//PE para filtrar funcionarios na geracao de senhas
    If lTCFA03FIL
		lRet := ExecBlock("TCFA03FIL", .F., .F.)
		If( ValType(lRet) <> "L", lRet := .T., )	    
    EndIf
    
    If lRet

		If cTCFSDoc == "2"
			cDocOfic := SRA->RA_RG
		Else
			cDocOfic := SRA->RA_CIC
		EndIf
		/*
		�����������������������������������������������������������������������Ŀ
		�Grava a Senha Padrao ou Limpa o Conteudo do campo RA_SENHA             �
		�������������������������������������������������������������������������*/
		IF !lClearPassW .And. Empty(SRA->RA_SENHA)
			cSenha	:= SRA->( Substr( Dtos( RA_NASC ) , 3 , 2 ) + Substr( Dtos( RA_ADMISSA ) , -2 ) + Substr( AllTrim( cDocOfic ) , -2 ) )
			Reclock("SRA",.F.)
			SRA->RA_SENHA := Embaralha(cSenha,0) 
			SRA->( Msunlock() )
		ElseIF ( lClearPassW )
			Reclock("SRA",.F.)
			SRA->RA_SENHA := Space( Len( SRA->RA_SENHA ) )
			SRA->( Msunlock() )
		EndIF
			
	EndIf	

	SRA->( dbSkip() )

End While

Return( NIL )
