#INCLUDE "loca024.ch" 
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"                                                                                                   
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSMGADD.CH"                                                                                                         

/*/{PROTHEUS.DOC} LOCA024.PRW
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

FUNCTION LOCA024()
Local AAREA       := GETAREA() 
Local CFILTRO     := "" 
Local CQRYLEG     := 0 
Local CRET00      := ""
Local CRET10      := ""
Local CRET20      := ""
Local CRET30      := ""
Local CRET40      := ""
Local CRET50      := ""
Local CRET60      := ""
Local CRET70      := ""
Local lMvLocBac	  := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integra��o com M�dulo de Loca��es SIGALOC

Private CCADASTRO := OEMTOANSI(STR0001) //"GERENCIAMENTO DE BENS"
Private AROTINA   := {} 
Private ACORES	  := {}

	/*
	EXEMPLO
	TQY_STATUS	TQY_DESTAT                    	FQ5_STTCTR
	----------  ----------------------------    ----------
	00        	DISPONIVEL                    	00
	DI        	DISPONIVEL (DI)               	00
	10        	CONTRATO GERADO               	10
	20        	NF DE REMESSA GERADA          	20
	30        	EM TRANSITO PARA ENTREGA      	30
	40        	ENTREGUE                      	40
	50        	RETORNO DE LOCACAO            	50
	RL        	RETORNO DE LOCACAO (RL)       	50
	60        	NF DE RETORNO GERADA          	60
	70        	EM MANUTEN��O                 	70
	*/

	IF SELECT("TMPLEG") > 0 
		TMPLEG->( DBCLOSEAREA() ) 
	ENDIF 

	If !lMvLocBac
		CQRYLEG := " SELECT TQY_STATUS , TQY_STTCTR FROM "+ RETSQLNAME("TQY") +" WHERE TQY_STTCTR IN ('00','10','20','30','40','50','60') AND D_E_L_E_T_ = '' "	
		TCQUERY CQRYLEG NEW ALIAS "TMPLEG"
		WHILE TMPLEG->(!EOF())
			IF TMPLEG->TQY_STTCTR = "00" 		// --> 00 - DISPONIVEL               - VERDE 
				CRET00 := CRET00 + TMPLEG->TQY_STATUS + "*" 
			ELSEIF TMPLEG->TQY_STTCTR = "10" 		// --> 10 - CONTRATO GERADO          - AMARELO 
				CRET10 := CRET10 + TMPLEG->TQY_STATUS + "*" 
			ELSEIF TMPLEG->TQY_STTCTR = "20" 		// --> 20 - NF DE REMESSA GERADA     - AZUL 
				CRET20 := CRET20 + TMPLEG->TQY_STATUS + "*" 
			ELSEIF TMPLEG->TQY_STTCTR = "30" 		// --> 30 - EM TRANSITO PARA ENTREGA - CINZA 
				CRET30 := CRET30 + TMPLEG->TQY_STATUS + "*" 
			ELSEIF TMPLEG->TQY_STTCTR = "40" 		// --> 40 - ENTREGUE                 - LARANJA 
				CRET40 := CRET40 + TMPLEG->TQY_STATUS + "*" 
			ELSEIF TMPLEG->TQY_STTCTR = "50" 		// --> 50 - RETORNO DE LOCACAO       - PRETO 
				CRET50 := CRET50 + TMPLEG->TQY_STATUS + "*" 
			ELSEIF TMPLEG->TQY_STTCTR = "60" 		// --> 60 - NF DE RETORNO GERADA     - VERMELHO 
				CRET60 := CRET60 + TMPLEG->TQY_STATUS + "*" 
			ELSEIF TMPLEG->TQY_STTCTR = "70" 		// --> 70 - EM MANUTENCAO            - ******** 
				CRET70 := CRET70 + TMPLEG->TQY_STATUS + "*" 
			ENDIF 
			TMPLEG->(DBSKIP()) 
		ENDDO
	else
		CQRYLEG := " SELECT FQD_STATQY , FQD_STAREN FROM "+ RETSQLNAME("FQD") +" WHERE FQD_STAREN IN ('00','10','20','30','40','50','60') AND D_E_L_E_T_ = '' "	
		TCQUERY CQRYLEG NEW ALIAS "TMPLEG"
		WHILE TMPLEG->(!EOF())
			IF TMPLEG->FQD_STAREN = "00" 		// --> 00 - DISPONIVEL               - VERDE 
				CRET00 := CRET00 + TMPLEG->FQD_STATQY + "*" 
			ELSEIF TMPLEG->FQD_STAREN = "10" 		// --> 10 - CONTRATO GERADO          - AMARELO 
				CRET10 := CRET10 + TMPLEG->FQD_STATQY + "*" 
			ELSEIF TMPLEG->FQD_STAREN = "20" 		// --> 20 - NF DE REMESSA GERADA     - AZUL 
				CRET20 := CRET20 + TMPLEG->FQD_STATQY + "*" 
			ELSEIF TMPLEG->FQD_STAREN = "30" 		// --> 30 - EM TRANSITO PARA ENTREGA - CINZA 
				CRET30 := CRET30 + TMPLEG->FQD_STATQY + "*" 
			ELSEIF TMPLEG->FQD_STAREN = "40" 		// --> 40 - ENTREGUE                 - LARANJA 
				CRET40 := CRET40 + TMPLEG->FQD_STATQY + "*" 
			ELSEIF TMPLEG->FQD_STAREN = "50" 		// --> 50 - RETORNO DE LOCACAO       - PRETO 
				CRET50 := CRET50 + TMPLEG->FQD_STATQY + "*" 
			ELSEIF TMPLEG->FQD_STAREN = "60" 		// --> 60 - NF DE RETORNO GERADA     - VERMELHO 
				CRET60 := CRET60 + TMPLEG->FQD_STATQY + "*" 
			ELSEIF TMPLEG->FQD_STAREN = "70" 		// --> 70 - EM MANUTENCAO            - ******** 
				CRET70 := CRET70 + TMPLEG->FQD_STATQY + "*" 
			ENDIF 
			TMPLEG->(DBSKIP()) 
		ENDDO
	EndIF

	ACORES := { {'ST9->T9_STATUS $ "'+CRET00+'"' , "BR_VERDE"   },;
				{'ST9->T9_STATUS $ "'+CRET10+'"' , "BR_AMARELO" },;
				{'ST9->T9_STATUS $ "'+CRET20+'"' , "BR_AZUL"    },;
				{'ST9->T9_STATUS $ "'+CRET50+'"' , "BR_PRETO"   },;
				{'ST9->T9_STATUS $ "'+CRET60+'"' , "BR_VERMELHO"}}

	AADD( AROTINA, {STR0002, "AXPESQUI"   ,0 , ,1, NIL} )  //"Pesquisar"
	AADD( AROTINA, {STR0003, "LOCA02402"  ,0 , ,6, NIL} )  //"Consulta"
	AADD( AROTINA, {STR0004, "LOCA02401()",0 , ,7, NIL} )  //"Legenda"
	AADD( AROTINA, {STR0005, "LOCR009()"  ,0 , ,7, NIL} )  //"Quadro resumo"

	IF EXISTBLOCK("LC024ROT") 						// --> PONTO DE ENTRADA PARA ALTERA��O DE CORES DA LEGENDA
		aRotina := EXECBLOCK("LC024ROT" , .T. , .T. , {AROTINA}) 
	ENDIF
		
	MBROWSE( , , , , "ST9" , , , , , 02 , ACORES , , , , , , , , CFILTRO ) 
	RESTAREA( AAREA )

RETURN



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���FUN��O	 � LEG009    � AUTOR � IT UP BUSINESS     � DATA � 07/09/2016 ���
�������������������������������������������������������������������������͹��
���DESCRICAO � LEGENDA.                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

FUNCTION LOCA02401()
Local _aLegenda := {}

	AADD(_aLegenda, {"BR_VERDE"   , STR0006})  //"Dispon�vel"
	AADD(_aLegenda, {"BR_AMARELO" , STR0007})  //"Contrato gerado"
	AADD(_aLegenda, {"BR_AZUL"    , STR0008})  //"Remessa gerada"
	AADD(_aLegenda, {"BR_PRETO"   , STR0009})  //"Retorno loca��o"
	AADD(_aLegenda, {"BR_VERMELHO", STR0010})  //"Retorno gerado"

	BRWLEGENDA("STATUS" , STR0004 , _aLegenda) //"LEGENDA"

RETURN

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���FUN��O    � LOC009A   � AUTOR � IT UP BUSINESS     � DATA � 07/09/2016 ���
�������������������������������������������������������������������������͹��
���DESCRICAO � "CONSULTA"                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
//FUNCTION LOCA02402(CALIAS , NREG , NOPC)
FUNCTION LOCA02402(CALIAS , NREG )
Local NOPC		:= 2
Local NUSADO 	:= 0
Local ABUTTONS 	:= {}
Local AFIELD	:= {}
Local APOS 		:= {000,000,080,400}
Local LMEMORIA 	:= .T.
Local LCREATE	:= .T.
Local NSUPERIOR := 081
Local NESQUERDA := 000
Local NINFERIOR := 250
Local NDIREITA 	:= 400
Local CLINOK 	:= "ALLWAYSTRUE"
Local CTUDOOK 	:= "ALLWAYSTRUE"
Local CINICPOS 	:= "FQ4_CODBEM"
Local NFREEZE 	:= 000
Local NMAX 		:= 999
Local CFIELDOK 	:= "ALLWAYSTRUE"
Local CSUPERDEL := ""
Local CDELOK 	:= "ALLWAYSFALSE"
Local AHEADER 	:= {}
Local ACOLS 	:= {}
Local AALTERGDA := {}
Local NX 		:= 0
Local OSIZE
Local NRECNOZZZ := 0
Local CCABEC    := "FQ4_DESTAT#FQ4_STATUS#FQ4_CODBEM#FQ4_CODFAMI#FQ4_TIPMOD#FQ4_FABRIC#FQ4_NOME#FQ4_SUBLOC#FQ4_POSCON#FQ4_CENTRAB#FQ4_NOMTRA#FQ4_OS#FQ4_TPSERV"		
Local lLOCA024A :=  ExistBlock("LOCA024A") 
Local aLoca024A := {}

Private CATELA 	:= ""
Private ODLG
Private OGETD
Private OENCH
Private ATELA[0][0]
Private AGETS[0]

	CALIAS 	:= "FQ4"
	NUSADO  := 0
	AHEADER := {}
	(LOCXCONV(1))->( DBSETORDER(1) )
	(LOCXCONV(1))->( DBSEEK(CALIAS) )
	WHILE !(LOCXCONV(1))->(EOF()).AND.(GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") == CALIAS)
		IF X3USO( &(LOCXCONV(3)) ) .AND. CNIVEL >= GetSx3Cache(&(LOCXCONV(2)),"X3_NIVEL")
			NUSADO++
			AADD(AHEADER , { ALLTRIM(GetSx3Cache(&(LOCXCONV(2)),"X3_TITULO")) ,;      
							GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO") ,;    
							GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE") , ; 
							GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO") ,;  
							GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL") ,; 
							"ALLWAYSTRUE()" , ;
							GetSx3Cache(&(LOCXCONV(2)),"X3_USADO")   ,;   
							GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO")    ,;    
							GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") ,;   
							GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") } )  
			IF ALLTRIM(&(LOCXCONV(2))) $ CCABEC 
				AADD( AFIELD , { X3TITULO()      , ; 
								GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO")   , ;  
								GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO")    , ; 
								GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO") , ;  
								GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL") , ;   
								GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE") , ;  
								GetSx3Cache(&(LOCXCONV(2)),"X3_VALID")   , ; 
								.F.             , ; 
								GetSx3Cache(&(LOCXCONV(2)),"X3_NIVEL")   , ; 
								GetSx3Cache(&(LOCXCONV(2)),"X3_RELACAO") , ; 
								GetSx3Cache(&(LOCXCONV(2)),"X3_F3")      , ;  
								GetSx3Cache(&(LOCXCONV(2)),"X3_WHEN")    , ;  
								.F.             , ;
								.F.             , ;
								GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX")    , ; 
								IIF(! EMPTY(GetSx3Cache(&(LOCXCONV(2)),"X3_FOLDER")) , VAL(GetSx3Cache(&(LOCXCONV(2)),"X3_FOLDER")), GetSx3Cache(&(LOCXCONV(2)),"X3_FOLDER")),;  
								.F.             , ; 
								GetSx3Cache(&(LOCXCONV(2)),"X3_PICTVAR") , ; 
								GetSx3Cache(&(LOCXCONV(2)),"X3_TRIGGER") } ) 
			ENDIF
		ENDIF	
		(LOCXCONV(1))->( DBSKIP() )
	ENDDO
		
	IF NOPC==2 										// INCLUIR	
		ACOLS := {} 
		ST9->( DBGOTO(NREG) )

		IF SELECT("TMPFQ4") > 0
			TMPFQ4->( DBCLOSEAREA() )
		ENDIF 
		CQUERY := " SELECT R_E_C_N_O_ RECNOZZZ, * FROM "+ RETSQLNAME(CALIAS) +" WHERE FQ4_CODBEM = '" + ST9->T9_CODBEM + "' AND D_E_L_E_T_ = '' "	
		TCQUERY CQUERY NEW ALIAS "TMPFQ4"
		
		WHILE TMPFQ4->( ! EOF() )
			IIF( NRECNOZZZ < TMPFQ4->RECNOZZZ , NRECNOZZZ := TMPFQ4->RECNOZZZ , NRECNOZZZ ) 
			AADD(ACOLS,ARRAY(NUSADO+1))
			FOR NX:=1 TO NUSADO
				ACOLS[LEN(ACOLS),NX] := FIELDGET(FIELDPOS( (AHEADER[NX,2]) )) //FIELDGET(FIELDPOS(( "TMPFQ4->" + (AHEADER[1,2])) ))
				//04/10/2022 - Jose Eulalio - SIGALOC94-524 - Formato de data no grid da consulta de gerenciamento de bens
				//converte em Data quando necess�rio
				If TamSx3((AHEADER[NX,2]))[3] == "D"
					ACOLS[LEN(ACOLS),NX] := StoD(ACOLS[LEN(ACOLS),NX])
				EndIf
			NEXT NX 
			ACOLS[LEN(ACOLS),NUSADO+1] := .F.
			TMPFQ4->( DBSKIP() )
		ENDDO
		TMPFQ4->( DBCLOSEAREA() )
	ENDIF 

	//SIGALOC94-690 - Jos� Eulalio - Ponto de Entrada para adicionar campos no Cabe�alho ou Grid
	If lLOCA024A
		aLoca024A 	:= ExecBlock("LOCA024A" , .T. , .T. , {aHeader,aCols}) 
		aHeader		:= aLoca024A[1]
		aCols		:= aLoca024A[2]
	EndIf

	OSIZE := FWDEFSIZE():NEW( .T.)
	OSIZE:ADDOBJECT("CENCH" , 100 , 25 , .T. , .T.) // ENCHOICE
	OSIZE:ADDOBJECT("CGETD" , 100 , 75 , .T. , .T.) // ENCHOICE
	OSIZE:LPROP := .T.
	OSIZE:PROCESS() 								// DISPARA OS CALCULOS 

	(CALIAS)->(DBGOTO(NRECNOZZZ))
	REGTOMEMORY(CALIAS, .F.)

	ODLG := MSDIALOG():NEW(OSIZE:AWINDSIZE[1],OSIZE:AWINDSIZE[2],OSIZE:AWINDSIZE[3],OSIZE:AWINDSIZE[4], CCADASTRO,,,,,,,,,.T.)
	NPOS      := ASCAN( OSIZE:APOSOBJ, { |X| ALLTRIM(X[7]) == "CENCH" } )
	APOS      := { OSIZE:APOSOBJ[NPOS][1],OSIZE:APOSOBJ[NPOS][2],OSIZE:APOSOBJ[NPOS][3],OSIZE:APOSOBJ[NPOS][4], }
	OENCH     := MSMGET():NEW(,,NOPC,/*ACRA*/,/*CLETRAS*/,/*CTEXTO*/,/*ACPOENCH*/,APOS,/*AALTERENCH*/,/*NMODELO*/,/*NCOLMENS*/,/*CMENSAGEM*/, /*CTUDOOK*/,ODLG,/*LF3*/,LMEMORIA,/*LCOLUMN*/,/*CATELA*/,/*LNOFOLDER*/,/*LPROPERTY*/,AFIELD,/*AFOLDER*/,LCREATE,/*LNOMDISTRETCH*/,/*CTELA*/)
			
	NPOS      := ASCAN( OSIZE:APOSOBJ, { |X| ALLTRIM(X[7]) == "CGETD"} )
	NSUPERIOR := OSIZE:APOSOBJ[NPOS][1]
	NESQUERDA := OSIZE:APOSOBJ[NPOS][2]
	NINFERIOR := OSIZE:APOSOBJ[NPOS][3]
	NDIREITA  := OSIZE:APOSOBJ[NPOS][4]
	OGETD     := MSNEWGETDADOS():NEW(NSUPERIOR, NESQUERDA , NINFERIOR , NDIREITA , NOPC , CLINOK  , CTUDOOK ,  CINICPOS   , AALTERGDA , NFREEZE , ; 
										NMAX     , CFIELDOK  , CSUPERDEL , CDELOK   , ODLG , AHEADER , ACOLS   , /*UCHANGE*/ , /*CTELA*/ )
	ODLG:BINIT := {|| ENCHOICEBAR(ODLG , {||ODLG:END()} , {||ODLG:END()},,@ABUTTONS,,,,,.F.)} 
	ODLG:LCENTERED := .T.
	ODLG:ACTIVATE()

RETURN 
