#INCLUDE "loca036.ch" 
#INCLUDE "PROTHEUS.CH"

/*/{PROTHEUS.DOC} LOCA036.PRW
ITUP BUSINESS - TOTVS RENTAL
MONTA AHEADER PARA GETDADOS FUNCOES UTILIZADAS EM DIVERSOS FONTES PARA MONTAR AHEADER E ACOLS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.  
/*/

FUNCTION LOCA036(CALIAS , AFIELDS , LSOCPOS)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� PAR헜ETROS DA FUN플O:                                                   �
//�   CALIAS  -> ALIAS DA TABELA                                            �
//�   AFIELDS -> ARRAY  COM CAMPOS QUE NAO DEVEM SER DESCONSIDERADOS        �
//�   LSOCPOS -> L�GICO QUE DETERMINA QUE O RETORNO VIR� TB OS CAMPOS       �
//�                                                                         �
//� RETORNO DA FUNCAO                                                       �
//�   ARRAY FORMADO POR: ARRAY COM O AHEADER, QUANT. DE CAMPOS USADOS E A   �
//�                      MATRIZ S� COM OS CAMPOS, QUANDO SOLICITADO         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

LOCAL AHEADER 	:= {}
LOCAL ACAMPOS   := {}
LOCAL COLDALIAS := ALIAS()
LOCAL ASAVSX3 	:= { (LOCXCONV(1))->( INDEXORD() ), (LOCXCONV(1))->( RECNO() ) }
LOCAL NUSAD	  	:= 0

REGTOMEMORY(CALIAS,.F.)

// AJUSTA OS PARAMETROS NECESS핾IOS COM SUAS OP합ES DEFAULT
DEFAULT AFIELDS := {}
DEFAULT LSOCPOS := .F.

// SETA A 핾EA DO SX3, �NDICE E EXECUTA O SEEK NO CALIAS
DBSELECTAREA("SX3")
DBSETORDER(1)
DBSEEK(CALIAS)

// LOOP PARA MONTAGEM DO AHEADER
WHILE (LOCXCONV(1))->( ! EOF() ) .AND. GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") == CALIAS                     
	IF X3USO( &(LOCXCONV(3)) ) .AND. CNIVEL >= GetSx3Cache(&(LOCXCONV(2)),"X3_NIVEL") .AND. ASCAN( AFIELDS , {|X| ALLTRIM(X) == ALLTRIM( GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO")  ) } ) == 0      
		// VERIFICA SE O RETORNO TER� OS CAMPOS
		IF LSOCPOS
			AADD( ACAMPOS, ALLTRIM( GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO") ) )
		ENDIF
		
		AADD( AHEADER, { ALLTRIM(X3TITULO()) , ;
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO")       , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE")     , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO")     , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL")     , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_VALID")       , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_USADO")       , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO")        , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_F3")          , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT")     , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX")        , ;   
		                 GetSx3Cache(&(LOCXCONV(2)),"X3_RELACAO")     , } )   
		
		NUSAD ++
		// ELIMINO VALID QUE ESTA COM PROBLEMA//
		IF GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO") $ "DTR_CODVEI"	
		    AHEADER[NUSAD][6]:=""   // ORIGINAL - VAZIO() .OR. (EXISTCPO('DA3') .AND. TMSA240VLD())                                                                               
	    ENDIF
	ENDIF
	
	DBSELECTAREA("SX3")
	DBSKIP()
ENDDO

// RESTAURA O AMBIENTE DO SX3 E A 핾EA SELECIONADA ANTERIORMENTE
DBSETORDER( ASAVSX3[1] )
DBGOTO( ASAVSX3[2] )
DBSELECTAREA( COLDALIAS )

RETURN { AHEADER , NUSAD , ACAMPOS } 



/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴敲굇
굇튡ROGRAMA  � ACOLS_LOCF� AUTOR � IT UP CONSULTORIA  � DATA � 30/06/2007 볍�
굇勁袴袴袴袴曲袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴묽�
굇튒ESCRICAO � MONTA AHEADER PARA GETDADOS FUNCOES UTILIZADAS EM DIVERSOS 볍�
굇�          � FONTES PARA MONTAR AHEADER E ACOLS                         볍�
굇�          � CHAMADA: LOCT004.PRW / LOCT005.PRW / LOCT060.PRW           볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧SO       � ESPECIFICO GPO                                             볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
FUNCTION LOCA03601( CALIAS , AHEADER , NOPC , NORD , CCHAVE , BCOND , BLINHA , LQUERY ) 

#DEFINE _X3CONTEXTO 10
LOCAL ACOLS    := {}
LOCAL ARECNOS  := {}
LOCAL AAREAAUX := {}
LOCAL AAREAATU := GETAREA()
LOCAL NLOOP    := 0
LOCAL NHEAD    := LEN(AHEADER) 
LOCAL CVARTMP 

REGTOMEMORY(CALIAS,.F.)

CACAO := IIF(NOPC==1 , STR0001 , IIF(NOPC==3 , STR0002 , STR0003))  //"- VISUALIZAR"###"- ALTERAR"###"- EXCLUIR"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� PAR헜ETROS DA FUN플O:                                                   �
//�   CALIAS -> ALIAS DA TABELA                                             �
//�   AHEADER  -> MATRIZ COM O CABE�ALHO DE CAMPOS (AHEADER)                  �
//�   NOPC   -> SEGUE A MESMA L�GICA DAS OP합ES DA MATRIZ AROTINA           �
//�   NORD   -> ORDEM DO �NDICE DE CALIAS                                   �
//�   CCHAVE -> CHAVE PARA O SEEK DE POSICIONAMENTO EM CALIAS               �
//�   BCOND  -> CONDI플O DO `DO WHILE`                                      �
//�   BLINHA -> CONDI플O DE FILTRO (SELE플O) DE REGISTROS                   �
//�   LQUERY -> VARIAVEL LOGICA QUE INDICA SE O ALIAS � UMA QUERY           �
//�                                                                         �
//� RETORNO DA FUNCAO                                                       �
//�   ARRAY COM:                                                            �
//�   ELEMENTO [1] - ARRAY DO ACOLS                                         �
//�   ELEMENTO [2] - ARRAY DOS RECNOS DA TABELA                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

// AJUSTA OS PARAMETROS NECESS핾IOS COM SUAS OP합ES DEFAULT
DEFAULT CALIAS := ALIAS()
DEFAULT CCHAVE := ""
DEFAULT NOPC   := 3
DEFAULT NORD   := 1
DEFAULT BCOND  := {|| .T.}
DEFAULT BLINHA := {|| .T.}
DEFAULT LQUERY := .F.

// ARMAZENA AREA ORIGINAL DO ARQUIVO A SER UTILIZADO NA MONTAGEM DO ACOLS
AAREAAUX := (CALIAS)->(GETAREA())

IF !NOPC == 3  			// INCLUS홒

	DBSELECTAREA(CALIAS)
	DBCLEARFILTER()
	IF LQUERY
		DBGOTOP()
	ELSE
		DBSETORDER(NORD)
		DBSEEK(CCHAVE)
	ENDIF
	
	// MONTA O ACOLS
	WHILE !EOF() .AND. EVAL( BCOND )
		IF EVAL(BLINHA)
			AADD( ACOLS, {} )
			FOR NLOOP := 1 TO NHEAD
				// VERIFICA SE O CAMPO � APENAS VIRTUAL
				IF AHEADER[ NLOOP, _X3CONTEXTO ] == "V"
					IF AHEADER[ NLOOP ][ 2 ] == "DTR_NOMMOT"
					   CVARTMP  := POSICIONE("DA4",1,XFILIAL("DA4")+FIELDGET( FIELDPOS("DTR_CODMOT")),"DA4_NOME" )
					ELSE
					    CVARTMP := CRIAVAR( AHEADER[ NLOOP ][ 2 ] )
				    ENDIF
				ELSE 
			        IF FUNNAME(0)=="LOCA047" .AND. ALLTRIM(AHEADER[ NLOOP ][ 2 ]) == "ZA7_QTD"
                       CVARTMP := FIELDGET( FIELDPOS( AHEADER[ NLOOP, 2] ) ) - FIELDGET( FIELDPOS( "ZA7_QJUE" ) )
			        ELSE 
			           CVARTMP := FIELDGET( FIELDPOS( AHEADER[ NLOOP, 2] ) ) 
				    ENDIF
				ENDIF
				// ACRESCENTA DADOS � MATRIZ
				AADD( ACOLS[ LEN(ACOLS) ], CVARTMP )
			NEXT NLOOP
			
			// ACRESCENTA A ACOLS A VARI햂EL L�GICA DE CONTROLE DE DELE플O DA LINHA
			AADD( ACOLS[ LEN(ACOLS) ], .F. )
			
			// ACRESCENTA A ARECNOS O N�MERO DO REGISTRO
			IF LQUERY
				AADD( ARECNOS, (CALIAS)->R_E_C_N_O_)
			ELSE
				AADD( ARECNOS, (CALIAS)->(RECNO()) )
			ENDIF
		ENDIF
		(CALIAS)->(DBSKIP())
	ENDDO

ELSE     

	AADD( ACOLS, {} )
	FOR NLOOP := 1 TO NHEAD
		AADD( ACOLS[LEN(ACOLS)], CRIAVAR( AHEADER[NLOOP, 2] ) )
	NEXT NLOOP
	AADD( ACOLS[LEN(ACOLS)] , .F.)
	AADD( ARECNOS , {} )                                     	

ENDIF

// RESTAURA AREA ORIGINAL DO ARQUIVO UTILIZADO NA MONTAGEM DO ACOLS
RESTAREA(AAREAAUX)

// RESTAURA AREA ORIGNAL DA ENTRADA DA ROTINA
RESTAREA(AAREAATU)

RETURN { ACOLS , ARECNOS } 
