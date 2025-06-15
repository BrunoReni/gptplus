/*/{PROTHEUS.DOC} LOCA010.PRW
ITUP BUSINESS - TOTVS RENTAL
ROTINA PARA GERAR PEDIDO DE VENDA E NOTA FISCAL DE REMESSA
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "loca010.ch" 

FUNCTION LOCA010(LROMANEIO)
LOCAL   AAREA      	:= GETAREA()
LOCAL 	_LGERA	   	:= .T.
Local	lProcessa	:= .F.

//PRIVATE _LROMANEIO := .F. 
PRIVATE _LTUDOOK   := .F. 
PRIVATE CAVISO     := "" 
PRIVATE CPROJET    := FP0->FP0_PROJET 
PRIVATE _CFILAUX   // FRANK 07/10/2020 - FILIAL PARA GERACAO DA NOTA DE REMESSA SEM SER VIA ROMANEIO
PRIVATE aFPYTransf := {} // Deve ser private e ser�o utilizadas no LOCM006
PRIVATE aFPZTransf := {} // Deve ser private e ser�o utilizadas no LOCM006

DEFAULT LROMANEIO  := .F.

_LROMANEIO := LROMANEIO

If GetMV("MV_GERABLQ",,"N") == "N"
	Help(Nil,	Nil,STR0081+alltrim(upper(Procname())),; //"RENTAL: "
	Nil,STR0082,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsist�ncia nos dados."
	{STR0102}) //"O par�metro MV_GERABLQ est� com conte�do = N impossibilitando o envio das notas de remessa."
	RETURN .F.	
EndIf

IF FUNNAME() <> "LOCA029" .AND. !SUPERGETMV("MV_LOCX008",.F.,.F.) .AND. SUPERGETMV("MV_LOCX071",.F.,.T.)	// GERA NF DE REMESSA PELA TELA DE ORCAMENTO? | ROMANEIO HABILITADO?
	//Ferramenta Migrador de Contratos
	/*If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
		cLocErro := STR0001+CRLF
	Else
		MSGALERT(STR0001 , STR0002) //"Nota de remessa dever� ser gerada somente pela rotina de Romaneio."###"Aten��o!"
	EndIf
	_LGERA := .F.*/
	If !(Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C")
		MSGALERT(STR0001 , STR0002) //"Nota de remessa dever� ser gerada somente pela rotina de Romaneio."###"Aten��o!"
		_LGERA := .F.
	EndIf
ENDIF

IF EXISTBLOCK("CLIBLOQ")  .AND.  _LGERA 
	If EXECBLOCK("CLIBLOQ" , .T. , .T. , {FP0->FP0_CLI , FP0->FP0_LOJA , .T.}) 
	//IF U_CLIBLOQ(FP0->FP0_CLI , FP0->FP0_LOJA , .T. /*EXIBE MSG?*/) 
		RESTAREA(AAREA) 
		_LGERA := .F. 
	ENDIF 
ENDIF 

IF !(VALTYPE(_LROMANEIO) == "L")
	LROMANEIO := .F. 
ENDIF 

_LROMANEIO := LROMANEIO 

IF _LGERA .AND. EXISTBLOCK("LOCA012") 			// --> PONTO DE ENTRADA PARA VALIDACAO DE GERACAO DA NF DE REMESSA.
	_LGERA := EXECBLOCK("LOCA012" , .T. , .T. , NIL) 
ENDIF 

IF _LGERA
	//Ferramenta Migrador de Contratos
	If Type("lLocAuto") == "L" .And. lLocAuto
		lProcessa	:= .T.
	Else
		lProcessa	:=MSGYESNO(OEMTOANSI(STR0003 + SUPERGETMV("MV_LOCX248",.F.,STR0004) + "?"),STR0005) //"Deseja gerar NF de Remessa para este "###"PROJETO"###"Gera Remessa"
		//lProcessa	:= MsgYesNo(OemToAnsi("Deseja gerar NF de Remessa para este " + SuperGetMv("LC_NOMPROJ",.F.,"Projeto") + "?"),"Gera Remessa")
	EndIf
	IF lProcessa
		PROCESSA({|| GERPED() } , STR0006 , STR0007 , .T.) //"PROCESSANDO..."###"AGUARDE..."
		IF _LTUDOOK
			If !(Type("lLocAuto") == "L" .And. lLocAuto)
				MSGINFO(CAVISO , OEMTOANSI(STR0002))  //"Aten��o!"
			EndIf
		ELSE 
			//Ferramenta Migrador de Contratos
			If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
				cLocErro := cAviso+CRLF 
			Else
				MSGALERT(CAVISO , OEMTOANSI(STR0002))  //"Aten��o!"
			EndIf
		ENDIF 
	ENDIF
ENDIF

RETURN NIL



// ======================================================================= \\
STATIC FUNCTION NFREMLB()
// ======================================================================= \\
// --> ROTINA PARA MOVIMENTA��O DE BEM EM LOTE.
LOCAL NOPC      := ""
LOCAL CRECNO    := ""
LOCAL _AREMESSA := {}
Local aAreaFQ3	:= {}
LOCAL LRET      := .F.
//LOCAL LTUDOFAM  := .F.
LOCAL NJANELAA  := 385
LOCAL NJANELAL  := 1103
LOCAL NLBTAML   := 540
LOCAL NLBTAMA   := 160
LOCAL _NX
Local LTODOS      := .F.               

PRIVATE LUMAOPCAO  := .F.
PRIVATE LMARCAITEM := .T.
PRIVATE OLISREM 

_AREMESSA := RETREM() 

//Ferramenta Migrador de Contratos
If Type("lLocAuto") == "L" .And. lLocAuto
	aAreaFQ3 := FQ3->(GetArea())
	For _NX := 1 To Len(_aRemessa)
		//Migrador - diversos clientes para faturar
		If FPA->(FieldPos("FPA_XMIGCL")) .and. FPA->(FieldPos("FPA_XMIGLJ"))
			//gera somente para a FQ2 posicionada (foi posicinada no Migrador)
			FQ3->(DbSetOrder(3)) //FQ3_FILIAL+FQ3_AS
			If FQ3->(DbSeek(xFilial("FQ3") + _aRemessa[_NX][15] )) .And. FQ2->FQ2_NUM == FQ3->FQ3_NUM
				_aRemessa[_NX][1]	:= .T.
				nOpc := "1"
			Else
				_aRemessa[_NX][1]	:= .F.
			EndIf
		Else
			_aRemessa[_NX][1]	:= .T.
			nOpc := "1"
		EndIf
	Next _NX
	RestArea(aAreaFQ3)
Else
	DEFINE MSDIALOG ODLGREM TITLE STR0008 FROM 010,005 TO NJANELAA,NJANELAL PIXEL//OF OMAINWND //"GERA NF REMESSA"
		@ 0.5,0.7 LISTBOX OLISREM FIELDS ;
						HEADER  " ",STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018,STR0019,STR0020 SIZE NLBTAML,NLBTAMA ON DBLCLICK; //"PRODUTO"###"BEM"###"OBRA"###"SEQ."###"FAM�LIA"###"DESCRI��O"###"DESCRI��O CENTRAB"###"NF REMESSA"###"NF RETORNO"###"QUANTIDADE"###"AS"###"FIL.REMESSA"
						(_AREMESSA  := MARCAITEM(OLISREM:NAT,_AREMESSA,LUMAOPCAO,LMARCAITEM,_LROMANEIO), OLISREM:REFRESH(),;
						IIF(( ! VERARRAY(_AREMESSA)), OFILBUT:DISABLE() , OFILBUT:ENABLE()))
		
		// 28/10/2022 - Jose Eulalio - SIGALOC94-537 - Funcionalidades do LOCA029 que no momento n�o est�o sendo apresentadas
		/*IF _LROMANEIO
			OLISREM:LREADONLY := .T.
		EndIF*/
		
		SETARRAY(_AREMESSA)
		
		// REMOVIDO POR FRANK EM 06/10/20
		//@ 158,008 CHECKBOX OTUDOFAM VAR LTUDOFAM SIZE 270,12 PROMPT "SELECIONAR TODOS" OF ODLGREM PIXEL ON CLICK (_AREMESSA := MARCATUDO(_AREMESSA,LTUDOFAM),;
		//                   IIF(( ! VERARRAY(_AREMESSA)), OFILBUT:DISABLE() , OFILBUT:ENABLE()),;
		//                   OLISREM:REFRESH())
		
		@ 172,007 BUTTON OFILBUT PROMPT STR0021  SIZE 55,12 OF ODLGREM PIXEL ;  //"GERAR NF REMESSA"
				ACTION (   IIF(LOCA010X(_aRemessa) , (NOPC := "1", ODLGREM:END()  ), NIL )  )
		
		//@ 172,007 BUTTON OFILBUT PROMPT "GERAR NF REMESSA"  SIZE 55,12 OF ODLGREM PIXEL ; 
		//          ACTION (   IIF(LOCA010X() , NOPC := "1" , NIL ) , ODLGREM:END() )
		

		@ 172,070 BUTTON OCANBUT PROMPT STR0022      SIZE 55,12 OF ODLGREM PIXEL ACTION (ODLGREM:END()) //"CANCELAR"
		//@ 172,117 BUTTON OFILTRO PROMPT "FILTRO"        SIZE 50,12 OF ODLGREM PIXEL ACTION (_AREMESSA := LBFILTRO(_AREMESSA) , SETARRAY(_AREMESSA)) 
		//@ 172,172 BUTTON OCLEAR  PROMPT "LIMPAR FILTRO" SIZE 50,12 OF ODLGREM PIXEL ACTION (_AREMESSA := RETREM()            , SETARRAY(_AREMESSA)) 
		// 28/10/2022 - Jose Eulalio - SIGALOC94-537 - Funcionalidades do LOCA029 que no momento n�o est�o sendo apresentadas
		@ 174,130 CHECKBOX LTODOS  PROMPT STR0103 SIZE 70,10 OF ODLGREM PIXEL ON CLICK MarcarRegi(.T. , @_AREMESSA ) //"Marca/Desmarca" 
		IF _LROMANEIO
			oDlgrem:aControls[4]:lReadOnlY := .T.
		EndIf
	ACTIVATE MSDIALOG ODLGREM CENTERED 
EndIf

IF NOPC == "1"
	CRECNO := VERFAM(_AREMESSA) 
	IF ITENSPED(CRECNO,.T.) 
		LRET := .T. 
	ENDIF 
ENDIF 

RETURN {LRET , CRECNO} 



// ======================================================================= \\
STATIC FUNCTION LBFILTRO(AARRAY)
// ======================================================================= \\
// --> REALIZA FILTRO DOS ITENS A SEREM FATURADOS.

LOCAL NOPC       := ""
LOCAL ODLG
LOCAL OFILTRO
LOCAL OCANBUT
LOCAL AAUX       := {}
LOCAL CFAMI      := SPACE(TAMSX3("T9_CODFAMI")[1])
LOCAL CCENT      := SPACE(TAMSX3("HB_NOME")[1])
LOCAL CDESC      := SPACE(TAMSX3("T9_NOME")[1])
LOCAL NZ         := 0 
//LOCAL CPICTURE := ""
//LOCAL CF3 

DEFAULT AARRAY := {}

DEFINE MSDIALOG ODLG TITLE STR0023 FROM 0,0 TO 025,050 OF OMAINWND //"FILTRO NF REMESSA"
	@ 007,007 SAY   OSAYFAM VAR STR0024 SIZE 250,12 OF ODLG PIXEL //"PREENCHA OS CAMPOS QUE DESEJA PESQUISAR NA TELA DE ITENS ATIVA!"
	
	@ 035,007 SAY   OSAYFAM VAR STR0025           SIZE  80,12 OF ODLG PIXEL  //"FAMILIA: "
	@ 046,007 MSGET CFAMI       F3 "ST6"              SIZE  50,12 OF ODLG PIXEL /*VALID ! VAZIO() WHEN CONDI��O PICTURE CPICTURE */
	
	@ 075,007 SAY   OSAYCEN VAR STR0026 SIZE  80,12 OF ODLG PIXEL  //"DESCRI��O CENTRAB: "
	@ 086,007 MSGET CCENT                             SIZE 120,12 OF ODLG PIXEL /* F3 "NG11" VALID ! VAZIO() /*WHEN CONDI��O PICTURE CPICTURE */
	
	@ 105,007 SAY   OSAYDES VAR STR0027     SIZE  80,12 OF ODLG PIXEL  //"DESCRI��O BEM: "
	@ 116,007 MSGET CDESC                             SIZE 120,12 OF ODLG PIXEL /*F3 CF3 VALID ! VAZIO() /*WHEN CONDI��O PICTURE CPICTURE */
	
	@ 145,007 SAY   OSAYNFR VAR STR0028        SIZE  80,12 OF ODLG PIXEL  //"NF REMESSA: "
	@ 156,007 MSGET CNFREM                            SIZE 120,12 OF ODLG PIXEL /*F3 CF3 VALID ! VAZIO() /*WHEN CONDI��O PICTURE CPICTURE */
	
	@ 172,062 BUTTON OFILTRO PROMPT STR0029         SIZE  50,12 OF ODLG PIXEL ACTION (NOPC := "1",ODLG:END()) //"FILTRAR"
	@ 172,007 BUTTON OCANBUT PROMPT STR0022        SIZE  50,12 OF ODLG PIXEL ACTION (ODLG:END()) //"CANCELAR"
ACTIVATE MSDIALOG ODLG CENTERED

IF NOPC == "1"
	IF ! EMPTY(CFAMI)
	 //	CAUX += "('"+ALLTRIM(CFAMI)+"') $ ALLTRIM(AARRAY[NZ][4]) "
		FOR NZ := 1 TO LEN(AARRAY)
			IF UPPER(ALLTRIM(CFAMI)) $ UPPER(ALLTRIM(AARRAY[NZ][6]))
				AADD(AAUX, AARRAY[NZ])
			ENDIF
		NEXT NZ 
	ENDIF
	IF ! EMPTY(CCENT)
	 //	CAUX += IIF( ! EMPTY(CAUX),  " .AND. ('"+ALLTRIM(CCENT)+"') $ ALLTRIM(AARRAY[NZ][5])" , "('"+ALLTRIM(CCENT)+"') $ ALLTRIM(AARRAY[NZ][5])" ) 
		FOR NZ := 1 TO LEN(AARRAY)
			IF UPPER(ALLTRIM(CCENT)) $ UPPER(ALLTRIM(AARRAY[NZ][8]))
				IF ASCAN(AAUX, {|X| X[11] == AARRAY[NZ,11] }) = 0
					AADD(AAUX, AARRAY[NZ])
				ENDIF
			ENDIF
		NEXT NZ 
	ENDIF
	IF ! EMPTY(CDESC)
	 //	CAUX += IIF( ! EMPTY(CAUX),  " .AND. ('"+ALLTRIM(CDESC)+"') $ ALLTRIM(AARRAY[NZ][6])" , "('"+ALLTRIM(CDESC)+"') $ ALLTRIM(AARRAY[NZ][6])" )
		FOR NZ := 1 TO LEN(AARRAY)
			IF UPPER(ALLTRIM(CDESC)) $ UPPER(ALLTRIM(AARRAY[NZ][7]))
				IF ASCAN(AAUX, {|X| X[11] == AARRAY[NZ][11] }) = 0
					AADD(AAUX, AARRAY[NZ])
				ENDIF
			ENDIF
		NEXT NZ
	ENDIF
	IF ! EMPTY(CNFREM)
	 //	CAUX += IIF( ! EMPTY(CAUX),  " .AND. ('"+ALLTRIM(CDESC)+"') $ ALLTRIM(AARRAY[NZ][6])" , "('"+ALLTRIM(CDESC)+"') $ ALLTRIM(AARRAY[NZ][6])" )
		FOR NZ := 1 TO LEN(AARRAY)
			IF UPPER(ALLTRIM(CNFREM)) $ UPPER(ALLTRIM(AARRAY[NZ][9]))
				IF ASCAN(AAUX, {|X| X[11] == AARRAY[NZ][11] }) = 0
					AADD(AAUX, AARRAY[NZ])
				ENDIF
			ENDIF
		NEXT NZ
	ENDIF
	IF LEN(AAUX) > 0
		AARRAY := AAUX
	ENDIF
ENDIF

RETURN AARRAY



// ======================================================================= \\
STATIC FUNCTION MARCAITEM(NAT , _AARRAY , LUMAOPCAO , LMARCAITEM , _LROMANEIO) 
// ======================================================================= \\
// --> MARCA E DESMARCA UM �NICO ITEM.
/*
LOCAL NPOS := ASCAN( _AARRAY , { |X| X[1] == .T. } )

IF VALTYPE("LUMAOPCAO") == "L" .AND. LUMAOPCAO
	LMARCAITEM := .F.
ENDIF

IF EXISTBLOCK("TEMROMAN") 							// --> PONTO DE ENTRADA PARA VERIFICAR SE O REGISTRO QUE EST� SENDO MARCADO TEM ROMANEIO OU N�O.
	LTEM := EXECBLOCK("TEMROMAN",.T.,.T.,{.F., _AARRAY, NAT, NPOS, .F.})
	IF !LTEM
	   MSGSTOP("N�O � POSS�VEL MARCAR ESSE ITEM, POIS ELE N�O TEM ROMANEIO." , "GPO - GERNFREM.PRW") 
	   RETURN _AARRAY
	ENDIF
ENDIF

IF NPOS > 0
	IF ALLTRIM(_AARRAY[NPOS][4]) <> ALLTRIM(_AARRAY[NAT][4])
		_AARRAY[NAT][1] := .F.
	ELSE
		IF _AARRAY[NAT][13]
			_AARRAY[NAT][1] := !_AARRAY[NAT][1]
		ELSE
			_AARRAY[NAT][1] := .F.
		ENDIF
	ENDIF
ELSE
	IF _AARRAY[NAT][13]
		_AARRAY[NAT][1] := !_AARRAY[NAT][1]
	ELSE
		_AARRAY[NAT][1] := .F.
	ENDIF
ENDIF
*/
// 28/10/2022 - Jose Eulalio - SIGALOC94-537 - Funcionalidades do LOCA029 que no momento n�o est�o sendo apresentadas
If !_LROMANEIO
	// DESATIVEI AS DEMAIS OP��ES PARA DEIXAR SEMPRE COMO MARCADO PARA GERAR A NF DE REMESSA
	// FRANK EM 06/10/20
	IF _AARRAY[NAT][1]
		_AARRAY[NAT][1] := .F.
	ELSE
		_AARRAY[NAT][1] := .T.
	ENDIF
ENDIF
//MSGALERT("N�O � FACULTADO A EXCLUS�O DE UM ITEM PARA A GERA��O DA NOTA DE REMESSA.","ATEN��O!")

RETURN _AARRAY



// ======================================================================= \\
STATIC FUNCTION MARCATUDO(_AARRAY , LMARCATUDO) 
// ======================================================================= \\
// --> MARCA E DESMARCA UM TODOS OS ITENS.

LOCAL CAUX   := ""
LOCAL NPOS   := ASCAN( _AARRAY , { |X| X[1] == .T. } )
LOCAL NX     := 0
LOCAL LTEM   := .T.
LOCAL LMARK  := .T.
LOCAL LFIRST := .T.
Local _TEMROMAN := EXISTBLOCK("TEMROMAN")

FOR NX := 1 TO LEN(_AARRAY)
	IF _TEMROMAN //EXISTBLOCK("TEMROMAN") 						// --> PONTO DE ENTRADA PARA VERIFICAR SE O REGISTRO QUE EST� SENDO MARCADO TEM ROMANEIO OU N�O.
		LTEM   := EXECBLOCK("TEMROMAN",.T.,.T.,{.F., _AARRAY, NX, NPOS,IIF(LFIRST,.T.,.F.)})
		LFIRST := .F.
		IF !LTEM
           LMARK := .F.
		ELSE
		   LMARK := .T.
		ENDIF
	ENDIF

	IF NPOS > 0
		IF ALLTRIM(_AARRAY[NPOS][4]) <> ALLTRIM(_AARRAY[NX][4])
			_AARRAY[NX,1] := .F.
		ELSE
			IF _AARRAY[NX][13]
			   IF LMARK
				  _AARRAY[NX][1] := LMARCATUDO
			   ENDIF
			ELSE
				_AARRAY[NX][1] := .F.
			ENDIF
		ENDIF
	ELSE
		IF EMPTY(CAUX)
			CAUX := ALLTRIM(_AARRAY[NX][4])
		ENDIF
		IF CAUX <> ALLTRIM(_AARRAY[NX][4])
			_AARRAY[NX][1] := .F.
		ELSE
			IF _AARRAY[NX][13]
				IF LMARK
					_AARRAY[NX][1] := LMARCATUDO
				ENDIF
			ELSE
				_AARRAY[NX][1] := .F.
		    ENDIF
	    ENDIF
	ENDIF
NEXT NX 

RETURN _AARRAY



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���PROGRAMA  � VERARRAY  � AUTOR � IT UP BUSINESS     � DATA � 14/10/2016 ���
�������������������������������������������������������������������������͹��
���DESCRICAO � VERIFICA SE O ARRAY POSSUI ALGUM REGISTRO MARCADO COMO .T. ���
�������������������������������������������������������������������������͹��
���USO       � ESPECIFICO GPO                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION VERARRAY(_AARRAY)

LOCAL   _LRET := .F.
LOCAL   _NW   := 0 

FOR _NW := 1 TO LEN(_AARRAY)
	IF _AARRAY[_NW][1]
		_LRET := .T.
		EXIT
	ENDIF
NEXT _NW 

RETURN _LRET



// ======================================================================= \\
STATIC FUNCTION SETARRAY(_AREMESSA)
// ======================================================================= \\

LOCAL OOK := LOADBITMAP(GETRESOURCES(),"LBOK")
LOCAL ONO := LOADBITMAP(GETRESOURCES(),"LBNO")
Local _nX

For _nX := 1 to len(_aremessa)
	_AREMESSA[_nX][01] := .T.
Next

OLISREM:SETARRAY(_AREMESSA)
OLISREM:BLINE := { || {IIF( _AREMESSA[OLISREM:NAT][01],OOK,ONO),;	// " ",
							_AREMESSA[OLISREM:NAT][02],;         	// "PRODUTO",
							_AREMESSA[OLISREM:NAT][03],;         	// "BEM",
							_AREMESSA[OLISREM:NAT][04],;         	// "OBRA",
							_AREMESSA[OLISREM:NAT][05],;         	// "SEQ LOC",
							_AREMESSA[OLISREM:NAT][06],;         	// "FAM�LIA",
							_AREMESSA[OLISREM:NAT][07],;         	// "DESCRI��O BEM",
							_AREMESSA[OLISREM:NAT][08],;         	// "DESCRI��O CENTRAB",
							_AREMESSA[OLISREM:NAT][09],;         	// "NF REMESSA",
							_AREMESSA[OLISREM:NAT][10],;			// "NF RETORNO"
							_AREMESSA[OLISREM:NAT][14],;			// QUANTIDADE FRANK 13/08/20
							_AREMESSA[OLISREM:NAT][15],;            // AS FRANK 07/20/20
							_AREMESSA[OLISREM:NAT][16]}}        	// FILIAL DA NOTA DE REMESSA
OLISREM:REFRESH()

RETURN



// ======================================================================= \\
STATIC FUNCTION RETREM()
// ======================================================================= \\

LOCAL   _ARET    := {}
LOCAL   _LMARK   := .T.
LOCAL   _CGRPACE := ""
LOCAL   _NX
LOCAL	CALIASX1
LOCAL   CQUERYX
LOCAL	_lPRocX
LOCAL	_cFilTMP
Local   _MV_GERNFS := SUPERGETMV("MV_GERNFS",,.T.)
Local 	lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integra��o com M�dulo de Loca��es SIGALOC

IF SBM->(FIELDPOS("BM_XACESS")) > 0
	_CGRPACE := LOCA00189()
ELSE
	_CGRPACE := SUPERGETMV("MV_LOCX014",.F.,"")
ENDIF

ZAGTMP->(DBGOTOP())

IF ZAGTMP->(EOF())
	IF EMPTY(_ARET)
		AADD(_ARET , {.F.,"","","","","","","",,"",0,"",.F.,0,"",""})
	ENDIF
ELSE
	WHILE ZAGTMP->(!EOF())
		_LMARK := .T.
		IF ALLTRIM(ZAGTMP->B1_GRUPO) $ _CGRPACE
			IF ZAGTMP->FPA_QUANT > 0
				_NQTDENV := QTDENV( ZAGTMP->FPA_AS )
				IF ZAGTMP->FPA_QUANT - _NQTDENV > 0
					_LMARK := .T.
				ELSE
					_LMARK := .F.
				ENDIF
			ELSE
				_LMARK := .F.
			ENDIF
		ELSE
			IF EMPTY(ALLTRIM(ZAGTMP->FPA_NFREM))
				_LMARK := .T.
			ELSE
				_LMARK := .F.
			ENDIF
		ENDIF

		// Controle para nao apresentar os itens que ja tem pedido de venda gerado 
		If !_MV_GERNFS //SUPERGETMV("MV_GERNFS",,.T.)
			CALIASX1 := GETNEXTALIAS()
			_cFilTMP := xFilial("SC5")
			If !empty(ZAGTMP->FPA_FILEMI)
				_cFilTMP := ZAGTMP->FPA_FILEMI
			EndIF
			_lProcx := .T.
			//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
			If lMvLocBac
				CQUERYX   := " SELECT COUNT (*) AS REG " + CRLF
				CQUERYX   := "  FROM " + RETSQLNAME("FPZ") + " FPZ " + CRLF
				CQUERYX   += " INNER JOIN " + RETSQLNAME("FPY") + " FPY " + CRLF
				CQUERYX   += " 		ON FPY_FILIAL = FPZ_FILIAL " + CRLF
				CQUERYX   += " 		AND FPY_PEDVEN = FPZ_PEDVEN " + CRLF
				CQUERYX   += " 		AND FPY_PROJET = FPZ_PROJET " + CRLF
				CQUERYX   += " WHERE FPZ_AS <> '' " + CRLF
				CQUERYX   += "   	AND FPZ_AS = '" + ZAGTMP->FPA_AS + "' " + CRLF
				CQUERYX   += " 		AND FPY_STATUS <> '2' " + CRLF
				CQUERYX   += " 		AND FPZ_FILIAL  =  '" + _cFilTMP + "' " + CRLF
				CQUERYX   += " 		AND FPY.D_E_L_E_T_ = ' ' " + CRLF
				CQUERYX   += " 		AND FPZ.D_E_L_E_T_ = ' ' "
			Else
				CQUERYX   := " SELECT count(*) AS REG "
				CQUERYX   += " FROM "+RETSQLNAME("SC6")+" SC6 (NOLOCK) "
				CQUERYX   += " WHERE  C6_FILIAL  =  '"+_cFilTMP+"' "
				CQUERYX   += "   AND  C6_XAS     =  '"+ZAGTMP->FPA_AS+"' "
				CQUERYX   += "   AND  SC6.D_E_L_E_T_ = '' "
			EndIf
			CQUERYX := CHANGEQUERY(CQUERYX) 
			DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERYX),CALIASX1, .F., .T.)
			If (CALIASX1)->REG > 0
				_lProcx := .F.
			EndIF
			(CALIASX1)->(DBCLOSEAREA())
			If !_lPRocx
				ZAGTMP->(dbSkip())
				Loop
			EndIF
		EndIF

		// DEIXAR TODOS J� SELECIONADOS - FRANK EM 06/10/20
		AADD(_ARET , {.T.                 , ; 	// 01 - _AREMESSA[OLISREM:NAT][01],OOK,ONO),;		// " ",
					  ZAGTMP->FPA_PRODUT  , ; 	// 02 - _AREMESSA[OLISREM:NAT][02],;         		// "PRODUTO",
					  ZAGTMP->FPA_GRUA    , ; 	// 03 - _AREMESSA[OLISREM:NAT][03],;         		// "BEM",
					  ZAGTMP->FPA_OBRA    , ; 	// 04 - _AREMESSA[OLISREM:NAT][04],;         		// "OBRA",
					  ZAGTMP->FPA_SEQGRU  , ; 	// 05 - _AREMESSA[OLISREM:NAT][05],;         		// "SEQ LOC",
					  ZAGTMP->T9_CODFAMI  , ; 	// 06 - _AREMESSA[OLISREM:NAT][06],;         		// "FAM�LIA",
					  ZAGTMP->T9_NOME     , ; 	// 07 - _AREMESSA[OLISREM:NAT][07],;         		// "DESCRI��O BEM",
					  ZAGTMP->HB_NOME     , ; 	// 08 - _AREMESSA[OLISREM:NAT][08],;         		// "DESCRI��O CENTRAB",
					  ZAGTMP->FPA_NFREM   , ; 	// 09 - _AREMESSA[OLISREM:NAT][09],;         		// "NF REMESSA",
					  ZAGTMP->FPA_NFRET   , ; 	// 10 - _AREMESSA[OLISREM:NAT][10]}},;      		// "NF RETORNO"
					  ZAGTMP->RECNOZAG    , ;
					  ZAGTMP->T9_CENTRAB  , ;
					  _LMARK              , ;
					  ZAGTMP->FPA_QUANT   , ;
					  ZAGTMP->FPA_AS      , ;    // FRANK 13/08/20
					  ZAGTMP->FPA_FILEMI  } )    // FRANK 13/08/20

		ZAGTMP->(DBSKIP())
	ENDDO
	IF EMPTY(_ARET)
		AADD(_ARET , {.F.,"","","","","","","",,"",0,"",.F.,0,"",""})
	ENDIF
ENDIF

FOR _NX := 1 TO LEN(_ARET)
	IF !_ARET[_NX][13]
		_ARET[_NX][1] := .F.
	ENDIF
NEXT

RETURN _ARET 



// ======================================================================= \\
STATIC FUNCTION VERFAM(_AARRAY)
// ======================================================================= \\

LOCAL NX     := 0 
LOCAL CRECNO := "("

FOR NX:=1 TO LEN(_AARRAY)
	IF _AARRAY[NX][1]
		CRECNO += IIF(LEN(CRECNO)<=1 , ALLTRIM(STR(_AARRAY[NX][11])), ","+ALLTRIM(STR(_AARRAY[NX][11])))
	ENDIF
NEXT NX 
CRECNO += ")"

RETURN CRECNO



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���PROGRAMA  � GERPED    � AUTOR � IT UP BUSINESS     � DATA � 01/09/2016 ���
�������������������������������������������������������������������������͹��
���DESCRICAO � PROGRAMA QUE GERA PEDIDO E FATURA O PROJETO DA ZA0         ���
�������������������������������������������������������������������������͹��
���USO       � ESPECIFICO GPO                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION GERPED() 

LOCAL AAREASC5   := SC5->(GETAREA())
LOCAL AAREASC6   := SC6->(GETAREA())
LOCAL AAREADA3   := DA3->(GETAREA())
LOCAL AAREASA1	 := SA1->(GETAREA())
LOCAL AAREASF4	 := SF4->(GETAREA())
LOCAL ACAMPOSSC5 := {}
LOCAL ACAMPOSSC6 := {}
LOCAL CTESRF     := SUPERGETMV("MV_LOCX084"  ,.F.,"509") 
LOCAL CTESLF     := SUPERGETMV("MV_LOCX083",.F.,"503") 
LOCAL CSERIE     := SUPERGETMV("MV_LOCX201",.F.,"001") 
LOCAL CNATUREZ   := SUPERGETMV("MV_LOCX066",.F.,"300000") 
LOCAL CGRPAND    := ""
LOCAL AFILSST9   := {}
LOCAL _CDESCRI   := ""
LOCAL CFILAUX    := ""
LOCAL AAUXC6     := {}
LOCAL AITENS     := {}
LOCAL AVLDLPAD   := {}
LOCAL ANFREMLB   := {.F.,""}
LOCAL _CARMAZEM  := ""
LOCAL CVEICULO   := ""
LOCAL CITEM      := ""
LOCAL _LCVAL     := SUPERGETMV("MV_LOCX051",.F.,.T.)
LOCAL _NQTD      := 0
LOCAL NY         := 0 
LOCAL _NV        := 0 
LOCAL _NX        := 0 
LOCAL _NT        := 0 
LOCAL aPeso      := {0,0} 
LOCAL AAREAATU   := {} 
LOCAL AAREAST9   := {} 
LOCAL LTEMST20   := .F. 
//LOCAL _CFILREM   := "" // CONTROLE DA FILIAL QUE A NOTA SERA EMITIDA - FRANK - 06/10/2020
//LOCAL _CQUERY  := ""
//LOCAL _CFILOLD	 := CFILANT // FRANK Z FUGA EM 07/10/2020 - CONTROLE DA FILIAL PARA QUANDO TROCAR NA EMISS�O DA NFS
LOCAL _CFILNEW   := CFILANT // FRANK Z FUGA EM 07/10/2020 - VARIAVEL PARA TROCA DA FILIAL NA EMISS�O DA NFS
LOCAL _AZAG
LOCAL _ASZ1
Local _cAviso2   := ""
LOCAL CQUERYX
LOCAL CALIASX := GETNEXTALIAS()
LOCAL _CFILTMP
Local lLOCX304	:= SuperGetMV("MV_LOCX304",.F.,.F.) // Utiliza o cliente destino informado na aba conjunto transportador ser� o utilizado como cliente da nota fiscal de remessa,
Local lCliCjTran:= .F.
Local cCmpUsr	:= SuperGetMv("MV_CMPUSR",.F.,"")
Local cViagem	:= ""
Local _MV_GERNFS := SUPERGETMV("MV_GERNFS",,.T.)
Local _GRVC5OBS := EXISTBLOCK("GRVC5OBS")
Local _GERREMTES := EXISTBLOCK("GERREMTES")
Local _MV_LOC299 := GetMV("MV_LOCX299",,"")
Local _MV_LOCALIZ := getmv("MV_LOCALIZ",,"S")
Local _GERREFLOG := EXISTBLOCK("GERREFLOG")
Local _MV_LOC248 := SUPERGETMV("MV_LOCX248",.F.,STR0004)
Local _GERREMFIM := EXISTBLOCK("GERREMFIM")
Local _lPassa    := .F.
Local lloca10z   := .F.
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integra��o com M�dulo de Loca��es SIGALOC
Local lLoca01001:= .F.
Local aItemFPZ	:= {}
Local aFPZ		:= {}
Local aFPY		:= {}
//Local nY
Local xTemp
Local aAuxFPZ   := {}
Local nPonteiro := 0
Local aFPZOld   := {}
Local aAuxSC6n  := {}
Local aGetInfo	:= {,,,,,,,,,,,}
Local nRegX
Local nQtdItens := 0
Local nMaxItens := 300
Local nX		:= 0
Local nPos		:= 0
Local cTesOld
Local aAreaFQD

PRIVATE _CPEDIDO	:= ""
PRIVATE _CNOTA		:= ""
PRIVATE	LNFREMLB    := SUPERGETMV("MV_LOCX216",.F.,.T.) 	// PAR�METRO PARA ATIVAR O LISTBOX QUE PERMITE SELECIONAR OS ITENS PARA REMESSA
PRIVATE	LNFREMBE	:= SUPERGETMV("MV_LOCX215",.F.,.F.)
PRIVATE	_CDESTIN 	:= SUPERGETMV("MV_LOCX059",.F.,"")		// LISTA DOS E-MAILS QUE RECEBER�O A SOLICITA��O DE TRANSMISS�O DA DANFE
PRIVATE	LMSERROAUTO := .F.
PRIVATE CPROJETO	:= SUPERGETMV("MV_LOCX248",.F.,STR0004) //"PROJETO"
PRIVATE LCLIOBRA	:= SUPERGETMV("MV_LOCX204",.F.,.T.)
PRIVATE ADADOSNF	:= {}
PRIVATE CNUMSC5     := ""

LNFREMBE := .T. // FIXO POR FRANK PARA FUNCIONAMENTO DA TROCA DE FILIAIS 07/10/2020

_LTUDOOK := .F. 

IF EXISTBLOCK("LOCA10Z")
	lloca10z := .T.
ENDIF

IF SBM->(FIELDPOS("BM_XACESS")) > 0
	CGRPAND := LOCA00189()
ELSE
	CGRPAND := SUPERGETMV("MV_LOCX014",.F.,"")
ENDIF

// --> S� GERA QUANDO O TIPO DE SERVI�O � LOCA��O.
IF FP0->FP0_TIPOSE != "L" 
	CAVISO := STR0030+CPROJETO+STR0031  //"ESTA ROTINA � PARA GERAR REMESSA DO PROJETO ["###"] DE LOCA��O !"
	RETURN 
ENDIF 

// --> VALIDA SE EXISTE MESMO O CLIENTE PADR�O DO PROJETO.
SA1->(DBSETORDER(1))
IF SA1->( DBSEEK(XFILIAL("SA1") + FP0->FP0_CLI + FP0->FP0_LOJA) ) 
	IF SA1->A1_RISCO == "E"
		CAVISO := STR0032 + CRLF + CRLF + STR0033 //"CLIENTE COM RISCO 'E'"###"FAVOR ENTRAR EM CONTATO COM SETOR DE CADASTROS."
		RETURN 
	ENDIF 
ELSE 
	CAVISO := STR0034+ FP0->FP0_CLI + "/" + FP0->FP0_LOJA //"ATEN��O: N�O ENCONTRADO CLIENTE: "
	RETURN 
ENDIF 

// --> FUN��O PARA SELE��O DO ITENS DO PROJETO SELECIONADO.
IF ! ITENSPED(,.F.) 
	CAVISO := STR0035  //"ATEN��O, N�O EXISTEM EQUIPAMENTOS A SEREM ENVIADOS!"

	FPA->(dbSetOrder(1))
	FPA->(dbSeek(xFilial("FPA")+FP0->FP0_PROJET))
	While !FPA->(Eof()) .and. FPA->FPA_PROJET == FP0->FP0_PROJET

		// Frank em 02/07/2021 mudan�a do aviso do valor zerado, antes atendia apenas o FPA_PRVUCI, agora
		// valido tamb�m o cadastro de produtos e cadastro de bens
		_lAvisoVlr := .T.
		If FPA->FPA_PRCUNI > 0
			_lAvisoVlr := .F.
		EndIF

		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))
			If SB1->B1_PRV1 > 0
				_lAvisoVlr := .F.
			EndIF
		EndIF

		If !empty(FPA->FPA_GRUA)
			ST9->(dbSetOrder(1))
			If ST9->(dbSeek(xFilial("ST9")+FPA->FPA_GRUA))
				If ST9->T9_VALCPA > 0
					_lAvisoVlr := .F.
				EndIF
			EndIF
		EndIF

		If _lAvisoVlr 
			If !empty(_cAviso2)
				cAviso += "; "
			ENDIF
			_cAviso2 += alltrim(FPA->FPA_PRODUT)
		EndIF
		FPA->(dbSkip())
	EndDo
	If !empty(_cAviso2)
		//Ferramenta Migrador de Contratos
		If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
			cLocErro := STR0036+_cAviso2 +CRLF
		Else
			MsgAlert(STR0036+_cAviso2,STR0037) //"Os seguintes produtos est�o com o valor unit�rio zerado: "###"Aten��o !"
		EndIf
	EndIF

	ZAGTMP->(DBCLOSEAREA()) 
	RETURN
ENDIF

// --> VERIFICA SE EXISTE O STATUS '20' CADASTRADO - MESMA VALIDA��O DO SF2460I.PRW 
AAREAATU := GETAREA() 
AAREAST9 := ST9->(GETAREA()) 
AAREATQY := TQY->(GETAREA()) 

DBSELECTAREA("ST9")														// --> TABELA...: BEM 
DBSETORDER(1) 															// --> INDICE 01: T9_FILIAL + T9_CODBEM 

DBSELECTAREA("TQY")														// --> TABELA...: STATUS DO BEM
DBSETORDER(1) 															// --> INDICE 01: TQY_FILIAL + TQY_STATUS 

IF ST9->(DBSEEK(XFILIAL("ST9")+ZAGTMP->FPA_GRUA)) 
	If !lMvLocBac
		IF TQY->(DBSEEK(XFILIAL("TQY")+ST9->T9_STATUS)) .and. !empty(ST9->T9_STATUS)
				TQY->(DBGOTOP()) 
				WHILE TQY->(!EOF()) 
					IF TQY->TQY_STTCTR == "20" 									// STATUS DE GERAR CONTRATO
						LTEMST20 := .T. 
					ENDIF 
					TQY->(DBSKIP()) 
				ENDDO 
			IF ! LTEMST20 
				//Ferramenta Migrador de Contratos
				If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
					cLocErro := STR0038+CRLF
				Else
					MSGALERT(STR0038, STR0002)  //"Status BEM: N�o foi encontrado o '###' 20 no cadastro de '###'!"###"Favor realizar o cadastro do mesmo para prosseguir."###"Aten��o!"
				EndIf
				RETURN 
			ENDIF 
		ENDIF 
	else
		aAreaFQD := FQD->(GetArea("FQD"))
		FQD->(dbSetOrder(1))
		IF FQD->(DBSEEK(XFILIAL("FQD")+ST9->T9_STATUS)) .and. !empty(ST9->T9_STATUS)
				FQD->(DBGOTOP()) 
				WHILE FQD->(!EOF()) 
					IF FQD->FQD_STAREN == "20" 									// STATUS DE GERAR CONTRATO
						LTEMST20 := .T. 
					ENDIF 
					FQD->(DBSKIP()) 
				ENDDO 
			IF ! LTEMST20 
				//Ferramenta Migrador de Contratos
				If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
					cLocErro := STR0038+CRLF
				Else
					MSGALERT(STR0038, STR0002)  //"Status BEM: N�o foi encontrado o '###' 20 no cadastro de '###'!"###"Favor realizar o cadastro do mesmo para prosseguir."###"Aten��o!"
				EndIf
				FQD->(RestArea(aAreaFQD))
				RETURN 
			ENDIF 
		ENDIF 
		FQD->(RestArea(aAreaFQD))
	EndIF
ENDIF 

RESTAREA(AAREATQY) 
RESTAREA(AAREAST9)
RESTAREA(AAREAATU)

// --> PONTO DE ENTRADA PARA ALTERAR OS DADOS A SEREM FATURADOS.
IF LNFREMLB 
	ANFREMLB := NFREMLB() 
	IF ! ANFREMLB[1] 
		CAVISO := STR0042 //"EMISS�O DE NF DE REMESSA CANCELADA!"
		//Ferramenta Migrador de Contratos
		If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
			cLocErro := CAVISO+CRLF
		EndIf
		ZAGTMP->(DBCLOSEAREA()) 
		RESTAREA(AAREASC5) 
		RESTAREA(AAREASC6) 
		RESTAREA(AAREADA3) 
		RESTAREA(AAREASA1) 
		RETURN
	ENDIF
ENDIF

// --> FUN��O QUE VERFICA AS FILIAS DO CENTRO DE TRABALHO. 
AFILSST9 := NFREMBE(ANFREMLB) 

// FRANK 07/10/20 - TRATAMENTO DA FILIAL PARA GERACAO DO PV E NFS
// O VALOR DEFAULT � A FILIAL ABERTA NO SISTEMA.
IF LEN(AFILSST9) > 0
	_CFILNEW := AFILSST9[1]
ENDIF

_lPassa := .F.
If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
	_lPassa := .T.
EndIF


If lloca10z
	EXECBLOCK("LOCA10Z",.T.,.T.,{})
EndIF

Begin Transaction

DBSELECTAREA("FP1")
WHILE ! ZAGTMP->(EOF()) 

	//soma para garantir menos de 300 itens por pedido
	nQtdItens++ 
	lCliCjTran := .F. //Retorna para valor padr�o
	// Quando o parametro MV_GERNFS for .F. temos que verificar se o pedido j� foi gerado para n�o permitir duplicidade
	// Se houver um pedido de vendas com mesmo numero do contrato C5_XPROJET sem gerar NFS e C5_XTIPFAT = "R"
	// Se a AS for correspondente ao C6_XAS ignorar o registro
	If !_MV_GERNFS //SUPERGETMV("MV_GERNFS",,.T.)
		_lProcX := .T.
		_cFilTMP := xFilial("SC5")
		If !empty(ZAGTMP->FPA_FILEMI)
			_cFilTMP := ZAGTMP->FPA_FILEMI
		EndIF
		CQUERYX   := " SELECT count(*) AS REG "
		CQUERYX   += " FROM "+RETSQLNAME("SC5")+" SC5 (NOLOCK) "
		//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
		If lMvLocBac
			CQUERYX   += "        JOIN "+RETSQLNAME("SC6")+ " SC6 (NOLOCK) ON C6_FILIAL=C5_FILIAL AND C6_NUM=C5_NUM "
			CQUERYX   += "		INNER JOIN  " + RETSQLNAME("FPZ") + " FPZ (NOLOCK) "
			CQUERYX   += "			ON 	FPZ_FILIAL = C6_FILIAL AND "
			CQUERYX   += "				FPZ_PEDVEN = C6_NUM "
			CQUERYX   += " WHERE  	FPZ_FILIAL  =  '"+_cFilTMP+"' "
			CQUERYX   += "   AND  	FPZ_PROJET =  '"+CPROJET+"' "
			CQUERYX   += "	 AND	FPZ_AS = '" + ZAGTMP->FPA_AS + "' "
		Else
			CQUERYX   += "        JOIN "+RETSQLNAME("SC6")+ " SC6 (NOLOCK) ON C6_FILIAL=C5_FILIAL AND C6_NUM=C5_NUM AND C6_XAS='"+ZAGTMP->FPA_AS+"' "
			CQUERYX   += " WHERE  C5_FILIAL  =  '"+_cFilTMP+"' "
			CQUERYX   += "   AND  C5_XPROJET =  '"+CPROJET+"' "
		EndIf
		CQUERYX   += "   AND  C6_NOTA    =  '' "
		CQUERYX   += "   AND  SC5.D_E_L_E_T_ = '' "
		CQUERYX   += "   AND  SC6.D_E_L_E_T_ = '' "
		If lMvLocBac
			CQUERYX   += "   AND  FPZ.D_E_L_E_T_ = '' "
		EndIf
		CQUERYX := CHANGEQUERY(CQUERYX) 
		DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERYX),CALIASX, .F., .T.)
		If (CALIASX)->REG > 0
			_lProcx := .F.
		EndIF
		(CALIASX)->(DBCLOSEAREA())
		If !_lProcX
			cAviso := "J� existe um pedido de vendas que aguarda a nota fiscal de sa�da para este projeto."
			//Ferramenta Migrador de Contratos
			If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
				cLocErro := cAviso+CRLF 
			EndIf
			_lTudoOK := .F.
			//ZAGTMP->(dbSkip())
			//Loop
			Return .F.
		EndIF
	EndIF

	// --> POSICIONA E VALIDA O CADASTRO CLIENTE ATRAV�S DO CLIENTE. 
	FP1->(DBSETORDER(1))
	IF FP1->(MSSEEK( XFILIAL("FP1") + ZAGTMP->FPA_PROJET + ZAGTMP->FPA_OBRA)) 			// --> VALIDA SE TEM CLIENTE NA OBRA ATRAV�S DA ZAG
		//utiliza o cliente do Conjunto Transportador
		If lLOCX304
			//se for romaneio ou vier do migrador com os campos customizados
			//If _LROMANEIO
			If _LROMANEIO .Or. (Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C" .And. (FPA->(FieldPos("FPA_XMIGCL")) .and. FPA->(FieldPos("FPA_XMIGLJ"))))
				cViagem := FQ2->FQ2_VIAGEM
			Else
				cViagem := FQ5->FQ5_VIAGEM
			EndIf
			FQ7->(DbSetOrder(3)) // FQ7_FILIAL + FQ7_VIAGEM
			If FQ7->(DbSeek(xFilial("FQ7") + cViagem))
				If Empty(FQ7->FQ7_LCCDES) .OR. Empty(FQ7->FQ7_LCLDES)
					cAviso := STR0043 + ALLTRIM(ZAGTMP->FPA_PROJET) + STR0044 + AllTrim(ZAGTMP->FPA_OBRA) + " Viagem: " + AllTrim(cViagem) //"ATEN��O: O PROJETO "###" EST� SEM CLIENTE PARA A OBRA: "
					//Ferramenta Migrador de Contratos
					If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
						cLocErro := cAviso + CRLF
					EndIf
					RETURN
				Else
					IF ! SA1->(MSSEEK( XFILIAL("SA1") + FQ7->FQ7_LCCDES + FQ7->FQ7_LCLDES))
						CAVISO := STR0034+ FP0->FP0_CLI + "/" + FP0->FP0_LOJA //"ATEN��O: N�O ENCONTRADO CLIENTE: "
						//Ferramenta Migrador de Contratos
						If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
							cLocErro := CAVISO+CRLF
						EndIf
						RETURN
					else
						lCliCjTran := .T.
					ENDIF
				EndIf
			Else
				/*cAviso := "Aten��o! Viagem " + AllTrim(FQ5->FQ5_VIAGEM) + " n�o encontrada no projeto " + AllTrim(ZAGTMP->FPA_PROJET)
				//Ferramenta Migrador de Contratos
				If Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
					cLocErro := cAviso + CRLF
				EndIf
				RETURN*/
			EndIf
		EndIf

		//se n�o utiliza cliente do Conjunto transportador
		If !lCliCjTran	
			IF EMPTY(FP1->FP1_CLIORI) .OR. EMPTY(FP1->FP1_LOJORI)
				IF LCLIOBRA 		// --> PARAMETRO QUE VERIFICA SE FATURA PELO ZA1 OU PELO ZA0
					CAVISO := STR0043+ ALLTRIM(ZAGTMP->FPA_PROJET) + STR0044 + ZAGTMP->FPA_OBRA //"ATEN��O: O PROJETO "###" EST� SEM CLIENTE PARA A OBRA: "
					//Ferramenta Migrador de Contratos
					If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
						cLocErro := CAVISO+CRLF
					EndIf
					RETURN
				ELSE
					IF ! SA1->(MSSEEK( XFILIAL("SA1") + FP0->FP0_CLI + FP0->FP0_LOJA))
						CAVISO := STR0034+ FP0->FP0_CLI + "/" + FP0->FP0_LOJA //"ATEN��O: N�O ENCONTRADO CLIENTE: "
						//Ferramenta Migrador de Contratos
						If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
							cLocErro := CAVISO+CRLF
						EndIf
						RETURN
					ENDIF
				ENDIF
			ELSE
				IF ! SA1->(MSSEEK( XFILIAL("SA1") + FP1->FP1_CLIORI + FP1->FP1_LOJORI)) 	// --> VALIDA SE O CLIENTE DA OBRA EXISTE
					IF LCLIOBRA 	// --> PARAMETRO QUE VERIFICA SE FATURA PELO ZA1 OU PELO ZA0
						CAVISO := STR0034+ FP1->FP1_CLIORI + "/" + FP1->FP1_LOJORI //"ATEN��O: N�O ENCONTRADO CLIENTE: "
						//Ferramenta Migrador de Contratos
						If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
							cLocErro := CAVISO+CRLF
						EndIf
						RETURN
					ELSE
						IF ! SA1->(MSSEEK( XFILIAL("SA1") + FP0->FP0_CLI + FP0->FP0_LOJA))
							CAVISO := STR0034+ FP0->FP0_CLI + "/" + FP0->FP0_LOJA //"ATEN��O: N�O ENCONTRADO CLIENTE: "
							//Ferramenta Migrador de Contratos
							If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
								cLocErro := CAVISO+CRLF
							EndIf
							RETURN
						ENDIF
					ENDIF
				ENDIF
			ENDIF
		EndIf
	ELSE
		CAVISO := STR0045 + ALLTRIM(ZAGTMP->FPA_OBRA) //"ATEN��O: N�O ENCONTRADA OBRA: "
		//Ferramenta Migrador de Contratos
		If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
			cLocErro := CAVISO+CRLF
		EndIf
		RETURN
	ENDIF

	// --> CRIA ARRAY PARA O CABE�ALHO. 
	IF LEN(ACAMPOSSC5) == 0 	// .OR. (CFILAUX <> ZAGTMP->FILTRAB .AND. LNFREMBE)
		_CTXT := STR0046      + ALLTRIM(FP1->FP1_NOMORI) + CRLF //"OBRA: "
		_CTXT += STR0047  + ALLTRIM(FP1->FP1_ENDORI) + CRLF //"ENDERECO: "
		_CTXT += STR0048    + ALLTRIM(FP1->FP1_BAIORI) + CRLF //"BAIRRO: "
		_CTXT += STR0049 + ALLTRIM(FP1->FP1_MUNORI) + CRLF //"MUNICIPIO: "
		_CTXT += STR0050    + ALLTRIM(FP1->FP1_ESTORI) + CRLF //"ESTADO: "

		IF ! EMPTY(FP1->FP1_CEIORI)
			_CTXT += STR0051   + ALLTRIM(FP1->FP1_CEIORI) + CRLF //"CEI: "
		ENDIF

		// --> PONTO DE ENTRADA PARA ADICIONAR MAIS TEXTO NA VARI�VEL _CTXT
		IF _GRVC5OBS //EXISTBLOCK("GRVC5OBS")
			_CTXT += EXECBLOCK("GRVC5OBS",.T.,.T.,{_CTXT, IIF(LNFREMBE, ZAGTMP->FILTRAB,ZAGTMP->FPA_FILIAL)})
		ENDIF

		If !empty(ZAGTMP->FPA_FILEMI)
			_CFILNEW := ZAGTMP->FPA_FILEMI
		EndIF
  
		// Frank em 05/05/22 - indica se usa tabela de pre�os para a gera��o do SC5
		// � obrigat�rio somente quando a condi��o de pagamento esta amarrada com uma tabela de precos
		_lUsaTab := .F.
		If !empty(ZAGTMP->FPA_CODTAB)
			DA0->(dbSetOrder(1))
			If DA0->(dbSeek(xFilial("DA0")+ZAGTMP->FPA_CODTAB))
				If !empty(DA0->DA0_CONDPG)
					_lUsaTab := .T.
				EndIf
			EndIf
		EndIF
		
		ACAMPOSSC5 := {}
		//AADD(ACAMPOSSC5     , {"C5_FILIAL"  , IIF(LNFREMBE, ZAGTMP->FILTRAB,ZAGTMP->FPA_FILIAL), XA1ORDEM("C5_FILIAL"	) } )
		AADD(ACAMPOSSC5     , {"C5_FILIAL"  , _CFILNEW            , XA1ORDEM("C5_FILIAL"	) } ) // FRANK EM 07/10/2020
		AADD(ACAMPOSSC5     , {"C5_NUM"     , CNUMSC5             , XA1ORDEM("C5_NUM")     } )
		AADD(ACAMPOSSC5     , {"C5_TIPO"    , "N"                 , XA1ORDEM("C5_TIPO")    } )
		IF LCLIOBRA
			AADD(ACAMPOSSC5 , {"C5_CLIENTE"	, SA1->A1_COD         , XA1ORDEM("C5_CLIENTE") } )
			AADD(ACAMPOSSC5 , {"C5_LOJACLI"	, SA1->A1_LOJA        , XA1ORDEM("C5_LOJACLI") } )
		ELSE
			AADD(ACAMPOSSC5 , {"C5_CLIENTE" , FP0->FP0_CLI        , XA1ORDEM("C5_CLIENTE") } )
			AADD(ACAMPOSSC5 , {"C5_LOJACLI" , FP0->FP0_LOJA	      , XA1ORDEM("C5_LOJACLI") } )
		ENDIF
		AADD(ACAMPOSSC5     , {"C5_CLIENT"   , SA1->A1_COD	      , XA1ORDEM("C5_CLIENT")  } )
		AADD(ACAMPOSSC5     , {"C5_LOJAENT"  , SA1->A1_LOJA	      , XA1ORDEM("C5_LOJAENT") } )
		AADD(ACAMPOSSC5     , {"C5_TIPOCLI"  , SA1->A1_TIPO	      , XA1ORDEM("C5_TIPOCLI") } )
		AADD(ACAMPOSSC5     , {"C5_DESC1"    , 0			      , XA1ORDEM("C5_DESC1")   } )
		AADD(ACAMPOSSC5     , {"C5_DESC2"    , 0	              , XA1ORDEM("C5_DESC2")   } )
		AADD(ACAMPOSSC5     , {"C5_DESC3"    , 0		          , XA1ORDEM("C5_DESC3")   } )
		AADD(ACAMPOSSC5     , {"C5_DESC4"    , 0		          , XA1ORDEM("C5_DESC4")   } )
		AADD(ACAMPOSSC5     , {"C5_TPCARGA"  , "1"			      , XA1ORDEM("C5_TPCARGA") } )
		If _lUsaTab
			AADD(ACAMPOSSC5     , {"C5_TABELA"   , ZAGTMP->FPA_CODTAB , XA1ORDEM("C5_TABELA") } )
		EndIf
		AADD(ACAMPOSSC5     , {"C5_CONDPAG"  , ZAGTMP->FPA_CONPAG , XA1ORDEM("C5_CONDPAG") } )
		AADD(ACAMPOSSC5     , {"C5_TPFRETE"  , "F"   	          , XA1ORDEM("C5_TPFRETE") } )
		AADD(ACAMPOSSC5     , {"C5_ESPECI1"  , "MAQUINA"          , XA1ORDEM("C5_ESPECI1") } ) //"MAQUINA"
		AADD(ACAMPOSSC5     , {"C5_NATUREZ"  , CNATUREZ           , XA1ORDEM("C5_NATUREZ") } )
		// [inicio] Jos� Eul�lio - 01/06/2022 - SIGALOC94-156 - Campo de volume e peso na C6.	
		If _LROMANEIO
			aPeso := LOCA02910(_LROMANEIO)
			AADD(ACAMPOSSC5     , {"C5_PESOL"	, aPeso[1]		    , XA1ORDEM("C5_PESOL"  ) } )
			AADD(ACAMPOSSC5     , {"C5_PBRUTO"	, aPeso[2]		    , XA1ORDEM("C5_PBRUTO" ) } )
			If FQ2->(ColumnPos("FQ2_VOLUM1")) > 0
				AADD(ACAMPOSSC5     , {"C5_VOLUME1"	, FQ2->FQ2_VOLUM1	    , XA1ORDEM("C5_VOLUME1" ) } )
			Else
				AADD(ACAMPOSSC5     , {"C5_VOLUME1"	, 1	    , XA1ORDEM("C5_VOLUME1" ) } )
			EndIf
			If FQ2->(ColumnPos("FQ2_MENNOT")) > 0
				AADD(ACAMPOSSC5     , {"C5_MENNOTA" , FQ2->FQ2_MENNOT      , XA1ORDEM("C5_MENNOTA") } )
			EndIf
			If !Empty(cCmpUsr)
				If SC5->(ColumnPos(cCmpUsr)) > 0
					AADD(ACAMPOSSC5     , {cCmpUsr , FQ2->FQ2_OBS      , XA1ORDEM(cCmpUsr) } )
				EndIf
			EndIf
			// [inicio] Jos� Eul�lio - 02/06/2022 - SIGALOC94-345 - #27421 - Campo de obrigatoriedade Tipo de Transporte (lei)
			If FQ2->(ColumnPos("FQ2_TPFRET")) > 0
				AADD(ACAMPOSSC5     , {"C5_TPFRETE" , FQ2->FQ2_TPFRET      , XA1ORDEM("C5_TPFRETE") } )
			EndIf
			If FQ2->(ColumnPos("FQ2_XCODTR")) > 0
				AADD(ACAMPOSSC5     , {"C5_TRANSP" , FQ2->FQ2_XCODTR      , XA1ORDEM("C5_TRANSP") } )
			EndIf
			// [final] Jos� Eul�lio - 02/06/2022 - SIGALOC94-345 - #27421 - Campo de obrigatoriedade Tipo de Transporte (lei)
		else
			//Observa��es e outras informa��es para o pedido de vendas
			If !_lPassa  //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
				If !lLoca01001
					If !LOCA01001(@ACAMPOSSC5,cCmpUsr,@aGetInfo,@lLoca01001)
						Return .F.
					EndIf
				Else
					For nX := 1 To Len (aGetInfo)
						//verifica se tem informa��es
						If !Empty(aGetInfo[nX][1]) 
							//caso j� exista no cabe�alho, atualiza
							nPos	:= Ascan(aCamposSc5,{|X| AllTrim(X[1])==AllTrim(aGetInfo[nX][1])})
							If nPos > 0
								aCamposSc5[nPos][2] := aGetInfo[nX][2]
							Else
								Aadd(aCamposSc5  , aGetInfo[nX] )
							EndIf
						EndIf
					Next nX
				EndIf
			EndIf
		EndIf
		// [final] Jos� Eul�lio - 01/06/2022 - SIGALOC94-156 - Campo de volume e peso na C6.
		// removido da 94
		//IF SC5->(FIELDPOS("C5_OBSNF"))   > 0 
		//	AADD(ACAMPOSSC5 , {"C5_OBSNF"    , _CTXT	          , XA1ORDEM("C5_OBSNF")   } )
		//ENDIF
		//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
		If !lMvLocBac
			IF SC5->(FIELDPOS("C5_XPROJET")) > 0 
				AADD(ACAMPOSSC5 , {"C5_XPROJET"  , CPROJET		      , XA1ORDEM("C5_XPROJET") } )
			ENDIF
			IF SC5->(FIELDPOS("C5_XTIPFAT")) > 0 
				AADD(ACAMPOSSC5 , {"C5_XTIPFAT"  , "R"		          , XA1ORDEM("C5_XTIPFAT") } )
			ENDIF
			IF SC5->(FIELDPOS("C5_XOBRA"))   > 0
				AADD(ACAMPOSSC5 , {"C5_XOBRA"    , FP1->FP1_OBRA      , XA1ORDEM("C5_XOBRA")   } )
			ENDIF
			IF SC5->(FIELDPOS("C5_OBRA"))    > 0
				AADD(ACAMPOSSC5 , {"C5_OBRA"     , FP1->FP1_OBRA      , XA1ORDEM("C5_OBRA")    } )
			ENDIF
		else
			//Cabe�alho da Tabela de Pedido de Venda x Loca��o
			// no caso de alterar a estrutura do array precisa alterar tamb�m o locm006
			aFPY := {}
			Aadd(aFPY, {"FPY_FILIAL"	, _CFILNEW			,	NIL })
			Aadd(aFPY, {"FPY_PEDVEN"	, CNUMSC5			,	NIL })
			Aadd(aFPY, {"FPY_PROJET"	, CPROJET			,	NIL })
			Aadd(aFPY, {"FPY_TIPFAT"	, "R"				,	NIL })
			Aadd(aFPY, {"FPY_STATUS "	, "1"				,	NIL }) //1=Pedido Ativo;2=Pedido Cancelado
			If _LROMANEIO
				Aadd(aFPY, {"FPY_IT_ROM", FQ2->FQ2_NUM				,	NIL })
			EndIf
			aFPYTransf := aFPY
		EndIf

	ENDIF

	// --> CRIA ARRAY PARA OS ITENS DO PEDIDO. 
	_CDESCRI := ALLTRIM(ZAGTMP->B1_DESC)
	_CDESCRI += " ("+ ALLTRIM(ZAGTMP->FPA_GRUA)
	_CDESCRI += IIF(! EMPTY(ZAGTMP->T9_SERIE), " - " + ALLTRIM(ZAGTMP->T9_SERIE) + ")" , ")" )

	AITENS := {}

	CITEM := SOMA1(CITEM) 
	CITEM := IIF(LEN(CITEM)==1 , "0"+CITEM , CITEM) 
	// --> CRIA ARRAY PARA OS ITENS
	//AADD(AITENS,{"C6_FILIAL"	, IIF(LNFREMBE, ZAGTMP->FILTRAB, ZAGTMP->FPA_FILIAL), XA1ORDEM("C6_FILIAL")}) 	// FILIAL
	AADD(AITENS,{"C6_FILIAL"	, _CFILNEW                          , XA1ORDEM("C6_FILIAL")}) 	// FILIAL - FRANK 07/10/2020
	AADD(AITENS,{"C6_ITEM"		, CITEM                             , XA1ORDEM("C6_ITEM"   )}) 					// ITENS
	AADD(AITENS,{"C6_NUM"		, CNUMSC5                           , XA1ORDEM("C6_NUM"    )}) 					// NUMERO DO PEDIDO
	AADD(AITENS,{"C6_PRODUTO"	, ZAGTMP->FPA_PRODUT				, XA1ORDEM("C6_PRODUTO")}) 					// MATERIAL
	AADD(AITENS,{"C6_UM"		, ZAGTMP->B1_UM                     , XA1ORDEM("C6_UM"     )}) 					// UNIDADE DE MEDIDA
	AADD(AITENS,{"C6_DESCRI"	, _CDESCRI                          , XA1ORDEM("C6_DESCRI" )}) 					// DESCRI��O DO PRODUTO
	// Frank em 27/12/2022 chamado 618
	// Inicio [618]
	cTesOld := CTESLF
	If FPA->(FIELDPOS( "FPA_TESREM" )) > 0
		nRegX := FPA->(Recno())
		FPA->(dbGoto(ZAGTMP->RECNOZAG))
		If !empty(FPA->FPA_TESREM)
			CTESLF := FPA->FPA_TESREM
		EndIF
		FPA->(dbGoto(nRegX))
	EndIF
	// Fim [618]
	IF _GERREMTES //EXISTBLOCK("GERREMTES") 						// --> PONTO DE ENTRADA PARA ALTERA��O DA TES.
		CTESLF := EXECBLOCK("GERREMTES",.T.,.T.,{CTESLF})
	ENDIF
	AADD(AITENS,{"C6_TES"		, CTESLF                            , XA1ORDEM("C6_TES"    )}) 					// TES
	CTESLF := cTesOld
	AADD(AITENS,{"C6_ENTREG"	, DDATABASE 						, XA1ORDEM("C6_ENTREG" )}) 					// DATA DA ENTREGA
	AADD(AITENS,{"C6_DESCONT"	, 0                                 , XA1ORDEM("C6_DESCONT")}) 					// PERCENTUAL DE DESCONTO
	AADD(AITENS,{"C6_COMIS1"	, 0                                 , XA1ORDEM("C6_COMIS1" )}) 					// COMISSAO VENDEDOR
	IF LCLIOBRA
		AADD(AITENS,{"C6_CLI"	, SA1->A1_COD                       , XA1ORDEM("C6_CLI"    )}) 					// CLIENTE
		AADD(AITENS,{"C6_LOJA"	, SA1->A1_LOJA                      , XA1ORDEM("C6_LOJA"   )}) 					// LOJA DO CLIENTE
	ELSE
		AADD(AITENS,{"C6_CLI"	, FP0->FP0_CLI                      , XA1ORDEM("C6_CLI"    )}) 					// CLIENTE
		AADD(AITENS,{"C6_LOJA"	, FP0->FP0_LOJA                     , XA1ORDEM("C6_LOJA"   )}) 					// LOJA DO CLIENTE
	ENDIF
	IF ZAGTMP->VALREM > 0 
		NVALPROD := NOROUND(ZAGTMP->VALREM ,2) 
	ELSE 
		IF ZAGTMP->B1_PRV1 > 0 
			NVALPROD := NOROUND(ZAGTMP->B1_PRV1,2) 
		ELSE 
			NVALPROD := 0 
		ENDIF 
	ENDIF 
	IF NVALPROD <= 0 
		CAVISO := STR0053 +"'"+ ALLTRIM(ZAGTMP->FPA_PRODUT) +"'"+ STR0054 + CRLF + STR0055 //"O ITEM '"###"' EST� COM O VALOR ZERADO."###"FAVOR VERIFICAR O CADASTRO DE PRODUTO (B1_PRV1) OU CADASTRO DO BEM (T9_VALCPA), SE FOR O CASO! "
		//Ferramenta Migrador de Contratos
		If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
			cLocErro := CAVISO+CRLF
		EndIf
		RETURN
	ENDIF

	// --> CASO PERTEN�A AO GRUPO QUE � CADASTRADO NO PAR�METRO PERMITE A OP��O DE SELECIONAR O ARMAZ�M COM SALDO
	IF ALLTRIM(ZAGTMP->B1_GRUPO) $ @(ALLTRIM(CGRPAND))

		IF ZAGTMP->FPA_QUANT > 0
			_NQTD := ZAGTMP->FPA_QUANT - QTDENV( ZAGTMP->FPA_AS )
		ENDIF

		IF _NQTD <= 0
			CAVISO := STR0056+ALLTRIM(ZAGTMP->FPA_PRODUT)+STR0057+CRLF+STR0058 //"O PRODUTO "###" POSSUI QUANTIDADE MENOR OU IGUAL A ZERO."###"A ROTINA GERA NF DE REMESSA SER� ENCERRADA!"
			//Ferramenta Migrador de Contratos
			If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
				cLocErro := CAVISO+CRLF
			EndIf
			ZAGTMP->(DBCLOSEAREA())
			RESTAREA(AAREASC5)
			RESTAREA(AAREASC6)
			RESTAREA(AAREADA3)
			RESTAREA(AAREASA1)
			RETURN
		ENDIF

		AVLDLPAD := VLDLPAD( _NQTD ) 

		/*
		IF AVLDLPAD[1]
			_CARMAZEM := AVLDLPAD[2]
		ELSE 			// --> CASO N�O TENHA SALDO PARA UM ITEM A SER FATURADO PARA REMESSA A ROTINA SER� INTERROMPIDA N�O GERANDO NENHUM FATURAMENTO
			CAVISO := STR0056+ALLTRIM(ZAGTMP->FPA_PRODUT)+STR0059+CRLF+STR0058 //"O PRODUTO "###" N�O POSSUI SALDO EM ESTOQUE SUFICIENTE."###"A ROTINA GERA NF DE REMESSA SER� ENCERRADA!"
			ZAGTMP->(DBCLOSEAREA())
			RESTAREA(AAREASC5)
			RESTAREA(AAREASC6)
			RESTAREA(AAREADA3)
			RESTAREA(AAREASA1)
			RETURN
		 //	_CARMAZEM := ZAGTMP->B1_LOCPAD
		ENDIF
		*/

		If empty(ZAGTMP->FPA_LOCAL)
			_CARMAZEM := ZAGTMP->B1_LOCPAD
		Else
			_CARMAZEM := ZAGTMP->FPA_LOCAL
		EndIF

		AADD(AITENS,{"C6_QTDVEN"	, _NQTD					, XA1ORDEM("C6_QTDVEN"	)}) // QUANTIDADE
		AADD(AITENS,{"C6_PRCVEN"	, NVALPROD				, XA1ORDEM("C6_PRCVEN"	)}) // PRECO DE VENDA / VALOR FRETE
		AADD(AITENS,{"C6_PRUNIT"	, NVALPROD				, XA1ORDEM("C6_PRUNIT"	)}) // PRECO UNIT�RIO / VALOR FRETE
		AADD(AITENS,{"C6_VALOR"	    , NVALPROD*_NQTD		, XA1ORDEM("C6_VALOR"	)}) // VALOR TOTAL DO ITEM
		IF _MV_GERNFS //SUPERGETMV("MV_GERNFS",,.T.)
			AADD(AITENS,{"C6_QTDLIB"	, _NQTD					, XA1ORDEM("C6_QTDLIB"	)}) // QUANTIDADE LIBERADA
		EndIF
		// Frank em 28/07/2021
		//AADD(AITENS,{"C6_LOCAL"		, _CARMAZEM				, XA1ORDEM("C6_LOCAL"	)}) // ARMAZEM PADRAO
		If empty(ZAGTMP->FPA_LOCAL)
			AADD(AITENS,{"C6_LOCAL"		, ZAGTMP->B1_LOCPAD		, XA1ORDEM("C6_LOCAL"	)}) // ARMAZEM PADRAO
		Else
			AADD(AITENS,{"C6_LOCAL"		, ZAGTMP->FPA_LOCAL		, XA1ORDEM("C6_LOCAL"	)}) // ARMAZEM PADRAO
		EndIF
	ELSE
		_NQTD := 1

		AADD(AITENS,{"C6_QTDVEN"	, _NQTD					, XA1ORDEM("C6_QTDVEN"	)}) // QUANTIDADE
		AADD(AITENS,{"C6_PRCVEN"	, NVALPROD				, XA1ORDEM("C6_PRCVEN"	)}) // PRECO DE VENDA / VALOR FRETE
		AADD(AITENS,{"C6_PRUNIT"	, NVALPROD				, XA1ORDEM("C6_PRUNIT"	)}) // PRECO UNIT�RIO / VALOR FRETE
		AADD(AITENS,{"C6_VALOR"	    , NVALPROD				, XA1ORDEM("C6_VALOR"	)}) // VALOR TOTAL DO ITEM
		IF _MV_GERNFS //SUPERGETMV("MV_GERNFS",,.T.)
			AADD(AITENS,{"C6_QTDLIB"	, _NQTD					, XA1ORDEM("C6_QTDLIB"	)}) // QUANTIDADE LIBERADA
		EndIf
		// Frank em 28/07/2021
		If empty(ZAGTMP->FPA_LOCAL)
			AADD(AITENS,{"C6_LOCAL"		, ZAGTMP->B1_LOCPAD		, XA1ORDEM("C6_LOCAL"	)}) // ARMAZEM PADRAO
		Else
			AADD(AITENS,{"C6_LOCAL"		, ZAGTMP->FPA_LOCAL		, XA1ORDEM("C6_LOCAL"	)}) // ARMAZEM PADRAO
		EndIF
	ENDIF

	IF LEN(ALLTRIM(TRANSFORM(NVALPROD*_NQTD,GETSX3CACHE("C6_VALOR","X3_PICTURE")))) > GETSX3CACHE("C6_VALOR","X3_TAMANHO")
		CAVISO := STR0060 + CVALTOCHAR(LEN(ALLTRIM(TRANSFORM(NVALPROD*_NQTD,GETSX3CACHE("C6_VALOR","X3_PICTURE"))))) + STR0061 + ALLTRIM(TRANSFORM(NVALPROD*_NQTD,GETSX3CACHE("C6_VALOR","X3_PICTURE"))) + "." //"O TAMANHO DOS CAMPOS DE VALORES DO PEDIDO DE VENDA S�O INFERIORES A "###". N�O SENDO POSS�VEL GERAR O PEDIDO DE VENDA COM VALOR "
		//Ferramenta Migrador de Contratos
		If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
			cLocErro := CAVISO+CRLF
		EndIf
		ZAGTMP->(DBCLOSEAREA())
		RESTAREA(AAREASC5)
		RESTAREA(AAREASC6)
		RESTAREA(AAREADA3)
		RESTAREA(AAREASA1)
		RETURN
	ENDIF

	IF SC6->(FIELDPOS( "C6_XCCUSTO" )) > 0
		AADD(AITENS,{"C6_XCCUSTO"	, ZAGTMP->FPA_CUSTO		, XA1ORDEM("C6_XCCUSTO"	)}) // CENTRO DE CENTRO ZAG
	ENDIF

	// Integra��o do SIGALOC com o RM
	// Frank Zwarg Fuga em 16/09/21
	If  !empty(_MV_LOC299) // !empty(GetMV("MV_LOCX299",,""))
		AADD(AITENS,{"C6_CC"	, ZAGTMP->FPA_CUSTO		, XA1ORDEM("C6_CC"	)}) // CENTRO DE CENTRO ZAG
	EndIf

	IF SC6->(FIELDPOS("C6_XAS")) > 0
		AADD(AITENS,{"C6_XAS"		, ZAGTMP->FPA_AS		, XA1ORDEM("C6_XAS"		)})  // AS
	ENDIF
	IF SC6->(FIELDPOS("C6_CLVL")) > 0 .AND. _LCVAL
		AADD(AITENS,{"C6_CLVL"		, ZAGTMP->FPA_AS		, XA1ORDEM("C6_CLVL"	)})  // CLASSE DE VALOR
	ENDIF
	IF SC6->(FIELDPOS("C6_XBEM")) > 0
		AADD(AITENS,{"C6_XBEM"		, ZAGTMP->FPA_GRUA		, XA1ORDEM("C6_XBEM"	)})  // BEM
	ENDIF
	
	// Controle do endere�amento - Frank 28/07/2021
	// [ inicio - controle de endere�amento ]
	// https://tdn.totvs.com/display/public/PROT/PEST06504+-+Atividade+do+controle+de+numero+de+serie
	_cNumSer := ZAGTMP->FPA_GRUA
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+ZAGTMP->FPA_PRODUT))

	// Identifica��o do local padr�o de estoque
	If empty(ZAGTMP->FPA_LOCAL) // n�o informado na loca��o o local de estoque
		// utilizar o default informado no cadastro de produtos
		_cLocaPad := ZAGTMP->B1_LOCPAD
	Else
		_cLocaPad := ZAGTMP->FPA_LOCAL
	EndIF

	IF SC6->(FIELDPOS("C6_FROTA")) > 0
		AADD(AITENS,{"C6_FROTA"	,_cNumSer       , XA1ORDEM("C6_FROTA"	)}) 
	ENDIF

	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+CTESLF))

	If _MV_LOCALIZ == "S" .and. SB1->B1_LOCALIZ == "N" .and. !empty(_cNumSer) .and. SF4->F4_ESTOQUE == "S"
		// Neste caso levaremos apenas para o SC6 o n�mero de s�rie da FPA.
		// N�o precisa encontrar o endere�amento na SBF.
		//IF SC6->(FIELDPOS("C6_NUMSERI")) > 0 
		//	AADD(AITENS,{"C6_NUMSERI"	,_cNumSer       , XA1ORDEM("C6_NUMSERI"	)}) 
		//ENDIF

		IF SC6->(FIELDPOS("C6_FROTA")) > 0
			AADD(AITENS,{"C6_FROTA"	,_cNumSer       , XA1ORDEM("C6_FROTA"	)}) 
		ENDIF
	ElseIf _MV_LOCALIZ == "S" .and. SB1->B1_LOCALIZ == "S" .and. SF4->F4_ESTOQUE == "S"
		If empty(_cNumSer)
			// Neste caso n�o foi informado o n�mero de s�rie
			// Ent�o vamos encontrar o local de endere�amento na SBF pelo produto/local que tenha o saldo necess�rio e levar o
			// endere�amento para a SC6
			SBF->(dbSetOrder(2))
			If !SBF->(dbSeek(xFilial("SBF")+ZAGTMP->FPA_PRODUT+_cLocaPAd))
				MsgAlert(STR0093+alltrim(ZAGTMP->FPA_PRODUT)+STR0094+_cLocaPAd,STR0037) //"N�o foi localizado na tabela de endere�amento o produto: "###" no local de estoque: "###"Aten��o!"
				ADADOSNF   := {}
				ACAMPOSSC5 := {}
				ACAMPOSSC6 := {}
				AITENS     := {}
				RESTAREA(AAREASC5)
				RESTAREA(AAREASC6)
				RESTAREA(AAREADA3)
				RESTAREA(AAREASA1)
				_LTUDOOK := .F.
				cAviso := STR0092 // "Processo de gera��o do pedido de remessa bloqueado."
				Return .F.
			Else
				_cLocaEnd := ""
				// Tental localizar um endere�o que atenda na totalidade a quantidade da FPA
				//verifica somente se TES controla estoque, solicita��o do Lui em 09/11/2021 - CHAMADO #27587
				SF4->(DBSETORDER(1))
				If SF4->( MSSEEK(XFILIAL("SF4") + CTESLF, .F. ) ) .And. SF4->F4_ESTOQUE == "S"
					While !SBF->(Eof()) .and. SBF->BF_PRODUTO == ZAGTMP->FPA_PRODUT .and. SBF->BF_LOCAL == _cLocaPad
						If SBF->BF_QUANT - SBF->BF_EMPENHO >= _NQTD	
							_cLocaEnd := SBF->BF_LOCALIZ
							exit
						EndIF
						SBF->(dbSkip())
					EndDo
					If empty(_cLocaEnd)
						MsgAlert(STR0095+ZAGTMP->FPA_PRODUT,STR0096)  //"N�o foi localizado um endere�o de estoque com a quantidade necess�ria para o produto: "###"N�o h� um endere�o com o total necess�rio."
						ADADOSNF   := {}
						ACAMPOSSC5 := {}
						ACAMPOSSC6 := {}
						AITENS     := {}
						RESTAREA(AAREASC5)
						RESTAREA(AAREASC6)
						RESTAREA(AAREADA3)
						RESTAREA(AAREASA1)
						_LTUDOOK := .F.
						cAviso := STR0092 //"Processo de gera��o do pedido de remessa bloqueado."
						Return .F.
					EndIF
				EndIf
				RestArea(AAREASF4)
				IF SC6->(FIELDPOS("C6_NUMSERI")) > 0 
					AADD(AITENS,{"C6_NUMSERI"	,_cNumSer       , XA1ORDEM("C6_NUMSERI"	)}) 
				ENDIF

				IF SC6->(FIELDPOS("C6_FROTA")) > 0
					AADD(AITENS,{"C6_FROTA"	,_cNumSer       , XA1ORDEM("C6_FROTA"	)}) 
				ENDIF

				AADD(AITENS,{"C6_LOCALIZ"	,_cLocaEnd  , XA1ORDEM("C6_LOCALIZ"	)}) 
			EndIF
		Else
			// Neste caso foi informado o n�mero de s�rie
			// Ent�o vamos encontrar o local de endere�amento na SBF produto/local/NS que tenha o saldo necess�rio e levar
			// o endere�amento para a SC6
			// levar em considera��o a mensagem de que existem saldos parciais que atendem o todo avisar e n�o deixar gerar o pv
			SBF->(dbSetOrder(2))
			If !SBF->(dbSeek(xFilial("SBF")+ZAGTMP->FPA_PRODUT+_cLocaPAd))
				MsgAlert(STR0093+alltrim(ZAGTMP->FPA_PRODUT)+STR0094+_cLocaPAd,STR0040) //"N�o foi localizado na tabela de endere�amento o produto: "###" no local de estoque: "###"Aten��o!"
				ADADOSNF   := {}
				ACAMPOSSC5 := {}
				ACAMPOSSC6 := {}
				AITENS     := {}
				RESTAREA(AAREASC5)
				RESTAREA(AAREASC6)
				RESTAREA(AAREADA3)
				RESTAREA(AAREASA1)
				_LTUDOOK := .F.
				cAviso := STR0092 //"Processo de gera��o do pedido de remessa bloqueado."
				Return .F.
			Else
				_cLocaEnd := ""
				// Tental localizar um endere�o que atenda na totalidade a quantidade da FPA
				//verifica somente se TES controla estoque, solicita��o do Lui em 09/11/2021 - CHAMADO #27587
				SF4->(DBSETORDER(1))
				If SF4->( MSSEEK(XFILIAL("SF4") + CTESLF, .F. ) ) .And. SF4->F4_ESTOQUE == "S"
					While !SBF->(Eof()) .and. SBF->BF_PRODUTO == ZAGTMP->FPA_PRODUT .and. SBF->BF_LOCAL == _cLocaPad
						If alltrim(SBF->BF_NUMSERI) == alltrim(_cNumSer)
							If SBF->BF_QUANT - SBF->BF_EMPENHO >= _NQTD	
								_cLocaEnd := SBF->BF_LOCALIZ
								exit
							EndIF
						EndIF
						SBF->(dbSkip())
					EndDo
					If empty(_cLocaEnd)
						_nTempSld := 0	
						_cMsgSld  := ""
						SBF->(dbSeek(xFilial("SBF")+ZAGTMP->FPA_PRODUT+_cLocaPAd))
						While !SBF->(Eof()) .and. SBF->BF_PRODUTO == ZAGTMP->FPA_PRODUT .and. SBF->BF_LOCAL == _cLocaPad
							If !empty(SBF->BF_NUMSERI)
								_nTempSld += (SBF->BF_QUANT - SBF->BF_EMPENHO)
								_cMsgSld  += alltrim(SBF->BF_NUMSERI)+" "
								If _nTempSld >= _NQTD	
									exit
								EndIF
							EndIF
							SBF->(dbSkip())
						EndDo
						If _nTempSld >= _NQTD	
							MsgAlert(STR0097+_cMsgSld,STR0098) //"Os seguintes equipamentos precisam ser inseridos na aba loca��o: "###"N�o h� um endere�o com o total necess�rio."
						Else
							MsgAlert(STR0099,STR0100) //"N�o existe saldo nos itens endere�ados para esta quantidade."###"N�o h� um endere�o com o total necess�rio."
						EndIF
						ADADOSNF   := {}
						ACAMPOSSC5 := {}
						ACAMPOSSC6 := {}
						AITENS     := {}
						RESTAREA(AAREASC5)
						RESTAREA(AAREASC6)
						RESTAREA(AAREADA3)
						RESTAREA(AAREASA1)
						_LTUDOOK := .F.
						cAviso := STR0092 //"Processo de gera��o do pedido de remessa bloqueado."
						Return .F.
					EndIF
				EndIf
				RestArea(AAREASF4)
				IF SC6->(FIELDPOS("C6_NUMSERI")) > 0 
					AADD(AITENS,{"C6_NUMSERI"	,_cNumSer       , XA1ORDEM("C6_NUMSERI"	)}) 
				ENDIF

				IF SC6->(FIELDPOS("C6_FROTA")) > 0
					AADD(AITENS,{"C6_FROTA"	,_cNumSer       , XA1ORDEM("C6_FROTA"	)}) 
				ENDIF

				AADD(AITENS,{"C6_LOCALIZ"	,_cLocaEnd  , XA1ORDEM("C6_LOCALIZ"	)}) 
			EndIf
		EndIF
	ElseIf _MV_LOCALIZ == "N" .and. SB1->B1_LOCALIZ == "S" .and. SF4->F4_ESTOQUE == "S" 
		// Neste caso independente de ser infomado o NS 
		// Vamos encontrar o local de endere�amento pelo produto/armazem na SBF que tenha o saldo necess�rio e levar o
		// endere�amento para a SC6
		// n�o levaremos o n�mero de s�rie para a sc6.

		SBF->(dbSetOrder(2))
		If !SBF->(dbSeek(xFilial("SBF")+ZAGTMP->FPA_PRODUT+_cLocaPAd))
			MsgAlert(STR0093+alltrim(ZAGTMP->FPA_PRODUT)+STR0094+_cLocaPAd,STR0040) //"N�o foi localizado na tabela de endere�amento o produto: "###" no local de estoque: "###"Aten��o!"
			ADADOSNF   := {}
			ACAMPOSSC5 := {}
			ACAMPOSSC6 := {}
			AITENS     := {}
			RESTAREA(AAREASC5)
			RESTAREA(AAREASC6)
			RESTAREA(AAREADA3)
			RESTAREA(AAREASA1)
			_LTUDOOK := .F.
			cAviso := STR0092 //"Processo de gera��o do pedido de remessa bloqueado."
			Return .F.
		Else
			_cLocaEnd := ""
			// Tental localizar um endere�o que atenda na totalidade a quantidade da FPA
			//verifica somente se TES controla estoque, solicita��o do Lui em 09/11/2021 - CHAMADO #27587
			SF4->(DBSETORDER(1))
			If SF4->( MSSEEK(XFILIAL("SF4") + CTESLF, .F. ) ) .And. SF4->F4_ESTOQUE == "S"
				While !SBF->(Eof()) .and. SBF->BF_PRODUTO == ZAGTMP->FPA_PRODUT .and. SBF->BF_LOCAL == _cLocaPad
					If SBF->BF_QUANT - SBF->BF_EMPENHO >= _NQTD	
						_cLocaEnd := SBF->BF_LOCALIZ
						exit
					EndIF
					SBF->(dbSkip())
				EndDo
				If empty(_cLocaEnd)
					MsgAlert(STR0095+ZAGTMP->FPA_PRODUT,STR0096) //"N�o foi localizado um endere�o de estoque com a quantidade necess�ria para o produto: "###"N�o h� um endere�o com o total necess�rio."
					ADADOSNF   := {}
					ACAMPOSSC5 := {}
					ACAMPOSSC6 := {}
					AITENS     := {}
					RESTAREA(AAREASC5)
					RESTAREA(AAREASC6)
					RESTAREA(AAREADA3)
					RESTAREA(AAREASA1)
					_LTUDOOK := .F.
					cAviso := STR0092 //"Processo de gera��o do pedido de remessa bloqueado."
					Return .F.
				EndIF
			EndIf
			RestArea(AAREASF4)
			IF SC6->(FIELDPOS("C6_NUMSERI")) > 0 
				AADD(AITENS,{"C6_NUMSERI"	,_cNumSer       , XA1ORDEM("C6_NUMSERI"	)}) 
			ENDIF
			IF SC6->(FIELDPOS("C6_FROTA")) > 0
				AADD(AITENS,{"C6_FROTA"	,_cNumSer       , XA1ORDEM("C6_FROTA"	)}) 
			ENDIF
			AADD(AITENS,{"C6_LOCALIZ"	,_cLocaEnd  , XA1ORDEM("C6_LOCALIZ"	)}) 
		
		EndIF
	EndIF
	// Fim controle de enderecamento

	// [inicio] Jos� Eul�lio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
	If 	_LROMANEIO .And.	FQ3->(ColumnPos("FQ3_OBSCCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSCON")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFIS")) > 0 ;
			.And. SC6->(ColumnPos("C6_OBSCCMP")) > 0 .And. SC6->(ColumnPos("C6_OBSCONT")) > 0 .And. SC6->(ColumnPos("C6_OBSFISC")) > 0 .And. SC6->(ColumnPos("C6_OBSFCMP")) > 0
		AADD(AITENS,{"C6_OBSCCMP"		, ZAGTMP->FQ3_OBSCON	, XA1ORDEM("C6_OBSCCMP"	)})  // TITULO OBS CONTRIBUINTE
		AADD(AITENS,{"C6_OBSCONT"		, ZAGTMP->FQ3_OBSCCM		, XA1ORDEM("C6_OBSCONT"	)})  // OBS CONTRIBUINTE
		AADD(AITENS,{"C6_OBSFCMP"		, ZAGTMP->FQ3_OBSFCM		, XA1ORDEM("C6_OBSFCMP"	)})  // TITULO OBS FISCO
		AADD(AITENS,{"C6_OBSFISC"		, ZAGTMP->FQ3_OBSFIS		, XA1ORDEM("C6_OBSFISC"	)})  // OBS FISCO
	EndIf
	
	nPonteiro ++
	AADD(AITENS,{"NPONTEIRO", nPonteiro	, "999" })  // controle para o momento da montagem do array por filial
	
	// [final] Jos� Eul�lio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
	AADD(ACAMPOSSC6, AITENS )

	// --> VERIFICA SE EXISTE UM VE�CULO NAS LINHAS DA ZAG PARA ADICIONAR NO CABE�ALHO.
	IF EMPTY(CVEICULO)  .AND.  !EMPTY(ZAGTMP->FPA_PLACAI) 
		DA3->(DBSETORDER(3)) 
		IF DA3->( DBSEEK(XFILIAL("DA3") + ZAGTMP->FPA_PLACAI) ) 
			CVEICULO := DA3->DA3_COD
		ENDIF
	ENDIF

	IF _GERREFLOG //EXISTBLOCK("GERREFLOG") 						// --> PONTO DE ENTRADA PARA ALTERA��O DA TES.
	   EXECBLOCK("GERREFLOG",.T.,.T.,{ZAGTMP->FPA_GRUA, NVALPROD, ZAGTMP->FPA_PRODUT})
	ENDIF

	//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
	If lMvLocBac
		// no caso de alterar a estrutura do array precisa alterar tamb�m o locm006
		xTemp := ""
		For nY:=1 to len(aItens)
			If alltrim(aItens[nY][1]) == "C6_FILIAL"
				xTemp := aItens[nY][2]
			EndIF
		Next
		Aadd(aItemFPZ, {"FPZ_FILIAL"	, xTemp		,	NIL })
		xTemp := ""
		For nY:=1 to len(aItens)
			If alltrim(aItens[nY][1]) == "C6_NUM"
				xTemp := aItens[nY][2]
			EndIF
		Next
		Aadd(aItemFPZ, {"FPZ_PEDVEN"	, xTemp		, 	NIL })
		Aadd(aItemFPZ, {"FPZ_PROJET"	, CPROJET 			,	NIL }) 
		xTemp := ""
		For nY:=1 to len(aItens)
			If alltrim(aItens[nY][1]) == "C6_ITEM"
				xTemp := aItens[nY][2]
			EndIF
		Next
		Aadd(aItemFPZ, {"FPZ_ITEM"		, xTemp 		,	NIL }) 
		Aadd(aItemFPZ, {"FPZ_AS"		, ZAGTMP->FPA_AS	, 	NIL })
		//Aadd(aItemFPZ, {"FPZ_ROMAN"	, ""				,	NIL })
		Aadd(aItemFPZ, {"FPZ_EXTRA"		, "N"				,	NIL })
		Aadd(aItemFPZ, {"FPZ_FROTA"		, ZAGTMP->FPA_GRUA	,	NIL })
		//Aadd(aItemFPZ, {"FPZ_PERLOC"	, _cPerloc			,	NIL })
		Aadd(aItemFPZ, {"FPZ_CCUSTO"	, ZAGTMP->FPA_CUSTO	,	NIL })
		Aadd(aItemFPZ, {"NPONTEIRO"     , nPonteiro   	    ,	NIL })

		Aadd(aFPZ,Aclone(aItemFPZ))
		aItemFPZ := {}

	EndIf

	ZAGTMP->(DBSKIP())


	//se for final de arquivo ou quebra de nota, gera pedido
	If ZAGTMP->(EOF()) .Or.  nQtdItens >= nMaxItens

		nQtdItens := 0

//ENDDO
		If lMvLocBac
			aFPZTransf := aFPZ
		EndIF

		// --> CASO TENHA ALGUM VE�CULO INSERE NO CABE�ALHO DO PEDIDO. 
		IF ! EMPTY(CVEICULO)
			AADD( ACAMPOSSC5, {"C5_VEICULO"	, CVEICULO, XA1ORDEM("C5_VEICULO") } )
		ENDIF

		IF EXISTBLOCK("GERREMC5")
			//ACAMPOSSC5 := U_GERREMC5( ACAMPOSSC5 )
			ACAMPOSSC5 := EXECBLOCK("GERREMC5" , .T. , .T. , {ACAMPOSSC5}) 
		ENDIF

		// --> ORDENA O ARRAY DO CABE�ALHO DE ACORDO COM A ORDEM DO CAMPO
		ASORT(ACAMPOSSC5,,,{|X,Y| X[3]<Y[3]})
		// --> TRANSFORMA A ORDEM DO CAMPO EM NULO PARA RESPEITAR O PADR�O DO EXECAUTO
		FOR _NV := 1 TO LEN(ACAMPOSSC5)
			ACAMPOSSC5[_NV][3] := NIL
		NEXT _NV

		// --> ACERTO DO ARRAY DE ITENS
		FOR NY := 1 TO LEN(ACAMPOSSC6)
			// ORDENA O ARRAY DO CABE�ALHO DE ACORDO COM A ORDEM DO CAMPO
			ASORT(ACAMPOSSC6[NY],,,{|X,Y| X[3]<Y[3]})
			// TRANSFORMA A ORDEM DO CAMPO EM NULO PARA RESPEITAR O PADR�O DO EXECAUTO
			FOR _NV := 1 TO LEN(ACAMPOSSC6[NY])
				ACAMPOSSC6[NY][_NV][3] := NIL
			NEXT _NV
		NEXT NY

		// --> TRATATIVAS PARA A GERA��O DO PEDIDO DE VENDA. 
		IF LEN(AFILSST9) > 0 .OR. (LNFREMBE .AND. LEN(AFILSST9) > 1)
			_NPFILC6 := ASCAN(ACAMPOSSC6[1],{|X| ALLTRIM(X[1])=="C6_FILIAL"})
			_NPITC6  := ASCAN(ACAMPOSSC6[1],{|X| ALLTRIM(X[1])=="C6_ITEM"})
			_NPNUMC6 := ASCAN(ACAMPOSSC6[1],{|X| ALLTRIM(X[1])=="C6_NUM"})
			_NPFILC5 := ASCAN(ACAMPOSSC5   ,{|X| ALLTRIM(X[1])=="C5_FILIAL"})
			_NPNUMC5 := ASCAN(ACAMPOSSC5   ,{|X| ALLTRIM(X[1])=="C5_NUM"})
			CFILAUX  := CFILANT
		//	BEGIN TRANSACTION

				aFPZOld := aFPZTransf
				FOR _NT := 1 TO LEN(AFILSST9) // GRAVA DE ACORDO COM AS FILIAIS EXISTENTES

					AAUXC6  := {}
					aAuxFPZ := {}
					CITEM  := "0" 
					nPos   := 0
					For _NX := 1 TO LEN(ACAMPOSSC6[1])
						If alltrim(aCamposSC6[1][_nX][1]) == "NPONTEIRO"
							nPos := _nX
							Exit
						EndIF
					Next


					FOR _NX := 1 TO LEN(ACAMPOSSC6)
						CITEM := SOMA1(CITEM) 
						CITEM := IIF(LEN(CITEM)==1 , "0"+CITEM , CITEM)  
						IF ACAMPOSSC6[_NX][_NPFILC6][2] == AFILSST9[_NT] .OR. !LNFREMBE
							ACAMPOSSC6[_NX][_NPITC6][2]  := CITEM			// STRZERO( LEN( AAUXC6 ) + 1, 2, 0 ) 
							ACAMPOSSC6[_NX][_NPNUMC6][2] := CNUMSC5
							AADD(AAUXC6, ACLONE( ACAMPOSSC6[_NX] ) )

							nPonteiro2 := aCamposSC6[_nX][19][2]
							For nY := 1 to len(aFPZTransf)
								nPonteiro1 := aFPZTransf[nY][9][2]
								If nPonteiro1 == nPonteiro2
									AADD(aAuxFPZ, ACLONE( aFPZTransf[nY] ) )
									aAuxFPZ[len(aAuxFPZ)][4][2] := cItem
								EndIf
							Next


						ENDIF
					NEXT _NX 
					aFPZTransf := aAuxFPZ

					// remover do aAuxc6 a coluna nponteiro
					aAuxSC6n := {}
					For _nX := 1 to len(aAuxC6)
						aItens := {}
						For nY := 1 to len(aAuxC6[_nX])
							If alltrim(aAuxC6[_nX][nY][01]) <> "NPONTEIRO"
								Aadd(aItens, {aAuxC6[_nX][nY][01], aAuxC6[_nX][nY][02], aAuxC6[_nX][nY][03] })
							EndIF
						NExt
						Aadd(aAuxSC6n,Aclone(aItens))
					Next
					aAuxC6 := aAuxSC6n

					ACAMPOSSC5[_NPFILC5][2] := AFILSST9[_NT] 
					_AZAG := FPA->(GETAREA())
					_ASZ1 := FQ3->(GETAREA())
					IF LNFREMBE 
						CFILANT := AFILSST9[_NT]

						// FRANK 07/10/2020 - VALIDAR SE A CLASSE DE VALOR EXISTE
						//LOCA01307(ALLTRIM(STATICCALL(GRCONTR,CODCLVAL,ZAGTMP->FPA_PROJET))+"T","1", SUBSTR(FP0->FP0_CLINOM,1,25),'')
						//LOCA01307(ALLTRIM(STATICCALL(GRCONTR,CODCLVAL,ZAGTMP->FPA_PROJET))    ,"2", SUBSTR(FP0->FP0_CLINOM,1,25),STATICCALL(GRCONTR,CODCLVAL,ZAGTMP->FPA_PROJET))+"T")

					ENDIF
					CNUMSC5 := XSC5NUM()
					ACAMPOSSC5[_NPNUMC5][2] := CNUMSC5 
					IF ! EMPTY(CNUMSC5)
						// --> GRAVA USANDO O EXECAUTO
						PROCESSA({|| EXECPV(ACAMPOSSC5,AAUXC6,LNFREMBE) }, STR0062 + CNUMSC5, STR0007, .T.)  //"PROCESSANDO PEDIDO DE VENDA "###"AGUARDE..."
						IF EMPTY(_CPEDIDO)
							CAVISO := STR0063 + _MV_LOC248 + " "+ALLTRIM(CPROJET)+" !" + CRLF //"N�O FOI POSS�VEL GERAR O PEDIDO DE VENDA PARA O "###"PROJETO"
						//	DISARMTRANSACTION()
							LOOP
						ELSE
							CAVISO   := STR0064+_CPEDIDO+"]."  //"GERADO O PEDIDO DE REMESSA: ["
						ENDIF

						// --> GERA A NOTA
						// A PARTIR DE 23/12/2020 EM ALGUNS CASOS A NOTA FISCAL N�O DEVE SER GERADA LOGO NA SEQUENCIA DO PEDIDO DE VENDAS
						// FRANK 23/12/2020
						IF _MV_GERNFS //SUPERGETMV("MV_GERNFS",,.T.)
						PROCESSA({|| GRAVANFS( _CPEDIDO,CTESRF,CTESLF,CSERIE ) } , STR0065 + _CPEDIDO , STR0007 , .T.)  //"PROCESSANDO NF P/ O PEDIDO DE VENDA "###"AGUARDE..."
						IF EMPTY( _CNOTA )
							CAVISO := STR0066+_CPEDIDO+"]"  //"N�O FOI POSS�VEL FATURAR O PEDIDO DE REMESSA ["
						//	DISARMTRANSACTION()
						ELSE

							IF _GERREMFIM //EXISTBLOCK("GERREMFIM") 		// --> PONTO DE ENTRADA NO FINAL DA GERA��O DA NOTA FISCAL DE REMESSA.
								EXECBLOCK("GERREMFIM",.T.,.T.,{_CNOTA,_CPEDIDO,ACAMPOSSC5,ACAMPOSSC6})
							ENDIF
							RESTAREA(_AZAG)
							RESTAREA(_ASZ1)
							_LTUDOOK := .T. 
							CAVISO   := STR0064+_CPEDIDO+"]." +CRLF + STR0067+_CNOTA+"] !"  //"GERADO O PEDIDO DE REMESSA: ["###"GERADA A NF DE REMESSA: ["
						ENDIF

						// --> FUN��O PARA MANDAR E-MAIL
						IF ! EMPTY( _CDESTIN )
							XMAILNF(ADADOSNF[3],ADADOSNF[4])
						ENDIF
						ENDIF
					ENDIF

					aFPZTransf := aFPZOld

				NEXT _NT

		//	END TRANSACTION
			CFILANT := CFILAUX
		ELSE
			CAVISO := STR0068  //"N�O EXISTEM ITENS APTOS A GERAR NF DE REMESSA, FAVOR SELECIONAR OUTRA REMESSA."
		ENDIF

		ADADOSNF   := {}
		ACAMPOSSC5 := {}
		ACAMPOSSC6 := {}
		AITENS     := {}
		aFPZ     	:= {}
		aFPy     	:= {}
		aItemFPZ   	:= {}

	EndIf

ENDDO

End Transaction

RESTAREA(AAREASC5)
RESTAREA(AAREASC6)
RESTAREA(AAREADA3)
RESTAREA(AAREASA1)

RETURN 



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���PROGRAMA  � XSC5NUM   � AUTOR � IT UP BUSINESS     � DATA � 04/08/2019 ���
�������������������������������������������������������������������������͹��
���DESCRICAO � VALIDA O PR�XIMO NUMERO DO PV					          ���
�������������������������������������������������������������������������͹��
���USO       � ESPECIFICO GPO                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION XSC5NUM()

CNUMSC5	:= GETSXENUM("SC5","C5_NUM")
WHILE .T.
	IF SC5->( DBSEEK(XFILIAL("SC5") + CNUMSC5) )
		CONFIRMSX8()
		CNUMSC5 := GETSXENUM("SC5","C5_NUM")
		LOOP
	ELSE
		EXIT
	ENDIF
ENDDO

ROLLBACKSXE()

RETURN CNUMSC5



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���PROGRAMA  � EXECPV    � AUTOR � IT UP BUSINESS     � DATA � 04/08/2016 ���
�������������������������������������������������������������������������͹��
���DESCRICAO � GERA O PEDIDO DE VENDA PARA O PROJETO POSICIONADO          ���
�������������������������������������������������������������������������͹��
���USO       � ESPECIFICO GPO                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION EXECPV(_ACABEC , _AITENS , LNFREMBE) 

IF LEN(_ACABEC) > 0 .AND. LEN(_AITENS) > 0
	INCPROC(STR0069) //"AGUARDE... GERANDO PEDIDO DE VENDA E FATURANDO..."

	//SetRotInteg("MATA410") // integracao rm
	If !empty(GetMV("MV_LOCX299",,""))
		SetRotInteg("MATA410")
	EndIf
	MSEXECAUTO({|X,Y,Z| MATA410(X,Y,Z)} , _ACABEC , _AITENS , 3) 
	IF LMSERROAUTO
		MOSTRAERRO()
		ROLLBACKSX8()
		RETURN .F.
	ELSE
		_CPEDIDO := CNUMSC5
		CONFIRMSX8()
		IF RECLOCK("SC5",.F.) 
			SC5->C5_ORIGEM := "LOCA010" 
			SC5->(MSUNLOCK()) 
		ENDIF 

	ENDIF 
ELSE
	MSGSTOP(STR0070 , STR0002)  //"N�o existem registros para gera��o do contrato!"###"Aten��o!"
	RETURN .F.
ENDIF

RETURN



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���PROGRAMA  � GRAVANFS  � AUTOR � IT UP BUSINESS     � DATA � 04/08/2016 ���
�������������������������������������������������������������������������͹��
���DESCRICAO � LIBERA O PEDIDO E GERA O DOCUMENTO (NOTA FISCAL) DE SAIDA  ���
�������������������������������������������������������������������������͹��
���USO       � ESPECIFICO GPO                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION GRAVANFS( _CPEDIDO , CTESRF , CTESLF , CSERIE ) 

LOCAL AAREAANT  := GETAREA()
LOCAL AAREASC5  := SC5->(GETAREA()) 
LOCAL AAREASC6  := SC6->(GETAREA()) 
LOCAL AAREASC9  := SC9->(GETAREA()) 
LOCAL AAREASE4  := SE4->(GETAREA()) 
LOCAL AAREASB1  := SB1->(GETAREA()) 
LOCAL AAREASB2  := SB2->(GETAREA()) 
LOCAL AAREASF4  := SF4->(GETAREA()) 
LOCAL APVLNFS   := {}
LOCAL CROT      := "" 
LOCAL CQUERY
LOCAL CALIASQRY := GETNEXTALIAS()
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integra��o com M�dulo de Loca��es SIGALOC
//LOCAL AITENS  := {}

CROT := PROCNAME()

PERGUNTE("MT460A",.F.)

SC5->( DBSETORDER(1) ) //C5_FILIAL + C5_NUM
SC6->( DBSETORDER(1) ) //C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
SC9->( DBSETORDER(1) ) //C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO

CQUERY   := " SELECT DISTINCT C5_NUM "
CQUERY   += " FROM "+RETSQLNAME("SC5")+" SC5 (NOLOCK) "
//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
If lMvLocBac
	CQUERY   += "        JOIN "+RETSQLNAME("SC6")+ " SC6 (NOLOCK) ON C6_FILIAL=C5_FILIAL AND C6_NUM=C5_NUM "
	CQUERY   += "		INNER JOIN  " + RETSQLNAME("FPZ") + " FPZ (NOLOCK) "
	CQUERY   += "			ON 	FPZ_FILIAL = C6_FILIAL  AND "
	CQUERY   += "				FPZ_PEDVEN = C6_NUM "
	CQUERY   += " WHERE FPZ_FILIAL  =  '"+SC5->C5_FILIAL+"' "
	CQUERY   += "   AND FPZ_PROJET =  '"+CPROJET+"' "
	CQUERY   += "	AND	FPZ_PEDVEN = '" + SC5->C5_NUM + "' "
Else
	CQUERY   += "        JOIN "+RETSQLNAME("SC6")+ " SC6 (NOLOCK) ON C6_FILIAL=C5_FILIAL AND C6_NUM=C5_NUM "
	CQUERY   += " WHERE  C5_FILIAL  =  '"+XFILIAL("SC5")+"' "
	CQUERY   += "   AND  C5_NUM     =  '"+ _CPEDIDO +"' "
	CQUERY   += "   AND  C5_XPROJET =  '"+CPROJET+"' "
EndIf
CQUERY   += "   AND  C6_NOTA    =  '' "
CQUERY   += "   AND  C6_BLOQUEI =  '' "
//CQUERY += "   AND  C6_TES     IN ('"+CTESLF+"','"+CTESRF+"') "
CQUERY   += "   AND  SC5.D_E_L_E_T_ = '' "
CQUERY   += "   AND  SC6.D_E_L_E_T_ = '' "
If lMvLocBac
	CQUERY   += "   AND  FPZ.D_E_L_E_T_ = '' "
EndIf
//CONOUT("[GERNFREM.PRW] # CQUERY(1): " + CQUERY) 
CQUERY := CHANGEQUERY(CQUERY) 
DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERY),CALIASQRY, .F., .T.)

WHILE ! (CALIASQRY)->( EOF() ) 
	_CPEDIDO := (CALIASQRY)->C5_NUM
	IF SC5->( MSSEEK(XFILIAL("SC5") + _CPEDIDO, .F. ) )
		IF SC9->( DBSEEK( XFILIAL("SC9")+_CPEDIDO ) )
			WHILE !SC9->(EOF()) .AND. SC9->C9_PEDIDO == _CPEDIDO
				IF SC6->( DBSEEK( XFILIAL("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO ) )

					SE4->(DBSETORDER(1))
					SE4->( MSSEEK(XFILIAL("SE4") + SC5->C5_CONDPAG, .F. ) )

					// --> POSICIONA NO PRODUTO
					SB1->(DBSETORDER(1))
					SB1->( MSSEEK(XFILIAL("SB1") + SC6->C6_PRODUTO, .F. ) )

					// --> POSICIONA NO SALDO EM ESTOQUE
					SB2->(DBSETORDER(1))
					SB2->( MSSEEK(XFILIAL("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL, .F. ) )

					// --> POSICIONA NO TES
					CTES := SC6->C6_TES
					SF4->(DBSETORDER(1))
					SF4->( MSSEEK(XFILIAL("SF4") + CTES, .F. ) )

					_NPRCVEN := SC9->C9_PRCVEN

					// --> MONTA ARRAY PARA GERAR A NOTA FISCAL
					AADD( APVLNFS , { SC9->C9_PEDIDO   , ;
					                  SC9->C9_ITEM     , ;
					                  SC9->C9_SEQUEN   , ;
					                  SC9->C9_QTDLIB   , ;
					                  _NPRCVEN         , ;
					                  SC9->C9_PRODUTO  , ;
					                  .F.              , ;
					                  SC9->( RECNO() ) , ;
					                  SC5->( RECNO() ) , ;
					                  SC6->( RECNO() ) , ;
					                  SE4->( RECNO() ) , ;
					                  SB1->( RECNO() ) , ;
					                  SB2->( RECNO() ) , ;
					                  SF4->( RECNO() ) } ) 
				ENDIF
				SC9->(DBSKIP()) 
			ENDDO 
		ENDIF
	ENDIF
	(CALIASQRY)->(DBSKIP())
ENDDO
(CALIASQRY)->(DBCLOSEAREA())

DBSELECTAREA("SC9")

IF ! EMPTY(APVLNFS) 
	//CONOUT(STR0071) //"GERANDO NOTA FISCAL DE SAIDA"
	_CNOTA := MAPVLNFS(APVLNFS , CSERIE , .F. , .F. , .F. , .T. , .F. , 0 , 0 , .T. , .F.) 
	//CONOUT(STR0072+_CNOTA) //"NOTA FISCAL: "
	IF SD2->D2_PEDIDO == _CPEDIDO  .AND.  SD2->D2_DOC == _CNOTA 
		ADADOSNF := {SD2->D2_PEDIDO , SD2->D2_ITEMPV , SD2->D2_DOC , SD2->D2_SERIE} 
	ELSE 
		// ADCIONAR UMA BUSCA PARA VERIFICAR SE O PEDIDO EXISTE EM ALGUMA NOTA DA TABELA, CASO DESPOSICIONE....
	ENDIF
ENDIF

If lMvLocBac
	FPY->(dbSetOrder(1))
	If FPY->(dbSeek(xFilial("SC5") + SD2->D2_PEDIDO))
		If RecLock("FPY",.F.)
			FPY->FPY_IT_ROM := FQ2->FQ2_NUM	// Recebe Numero do romaneio.
			FPY->(MsUnLock())
		EndIf
	EndIf
EndIf

IF SF2->(FIELDPOS("F2_IT_ROMA")) > 0
	IF RECLOCK("SF2",.F.)
		SF2->F2_IT_ROMA := FQ2->FQ2_NUM	// RECEBE NUMERO DO ROMANEIO.
		SF2->(MSUNLOCK())
	ENDIF
ENDIF

// --> RETORNA AS AREAS ORIGINAIS
RESTAREA( AAREASF4 )
RESTAREA( AAREASB2 )
RESTAREA( AAREASB1 )
RESTAREA( AAREASE4 )
RESTAREA( AAREASC9 )
RESTAREA( AAREASC6 )
RESTAREA( AAREASC5 )
RESTAREA( AAREAANT )

RETURN



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���PROGRAMA  � XMAILNF   � AUTOR � IT UP BUSINESS     � DATA � 04/08/2016 ���
�������������������������������������������������������������������������͹��
���DESCRICAO � ENVIA E-MAIL CASO SEJA LOCA��O E O PARAMETRO "MV_LOCX059"  ���
���          � ESTEJA PREENCHIDO.                                         ���
�������������������������������������������������������������������������͹��
���USO       � ESPECIFICO GPO                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION XMAILNF(_CNOTA,CSERIE)

_CMSG := STR0073+ _CNOTA + STR0074 + CSERIE + "<BR />" //"FOI GERADA A NF: "###" - S�RIE: "
_CMSG += STR0075+CEMPANT+STR0076 + CFILANT + "<BR />" //"EMPRESA: "###" - FILIAL: "
_CMSG += SUPERGETMV("MV_LOCX248",.F.,STR0004) + ": "+ALLTRIM(CPROJET)+STR0077+ALLTRIM(FP0->FP0_CLINOM) + "<BR /><BR />" //"PROJETO"###" - CLIENTE: "
_CMSG += "<B>"+STR0078+"</B><BR /><BR /><BR />" //"<B>FAVOR TRANSMITIR A NF</B><BR /><BR /><BR />"
_CMSG += "<I>"+STR0079+"</I>" //"<I>MENSAGEM AUTOM�TICA, N�O RESPONDER</I>"

//U_ENVMAIL( _CDESTIN , ,STR0080 , _CMSG , "" ) //"SOLICITA��O DE TRANSMISS�O DE NF"

RETURN



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���PROGRAMA  � XA1ORDEM  � AUTOR � IT UP BUSINESS     � DATA � 04/08/2016 ���
�������������������������������������������������������������������������͹��
���DESCRICAO � VERIFICA A ORDEM DOS CAMPOS NO X3				          ���
�������������������������������������������������������������������������͹��
���USO       � ESPECIFICO GPO                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION XA1ORDEM(CCAMPO)

LOCAL AAREASX3 := (LOCXCONV(1))->(GETAREA())

(LOCXCONV(1))->(DBSETORDER(2))
(LOCXCONV(1))->(DBSEEK(CCAMPO))
CRET := &(LOCXCONV(4))

RESTAREA(AAREASX3)

RETURN CRET



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���PROGRAMA  � NFREMBE   � AUTOR � IT UP BUSINESS     � DATA � 04/08/2016 ���
�������������������������������������������������������������������������͹��
���DESCRICAO � VERIFICA AS FILIAIS EXISTENTES NO CAMPO T9_CENTRAB         ���
�������������������������������������������������������������������������͹��
���USO       � ESPECIFICO GPO                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION NFREMBE(ANFREMLB) 
LOCAL _AAREA 		:= GETAREA()
LOCAL AFILS 		:= {}
LOCAL _LENCONTRA 	:= .F.
LOCAL _NX
LOCAL _CTEMP

IF _LROMANEIO
	FQ3->(DBSETORDER(1))
	FQ3->(DBSEEK(XFILIAL("FQ3")+FQ2->FQ2_NUM))
	WHILE !FQ3->(EOF()) .AND.FQ3->FQ3_FILIAL = XFILIAL("FQ3") .AND. FQ3->FQ3_NUM == FQ2->FQ2_NUM
		_LENCONTRA 	:= .F.
		FPA->(DBSETORDER(3))
		IF FPA->(DBSEEK(XFILIAL("FPA")+FQ3->FQ3_AS+FQ3->FQ3_VIAGEM))
			FOR _NX:=1 TO LEN(AFILS)
				IF !EMPTY(FPA->FPA_FILEMI)
					IF AFILS[_NX] == FPA->FPA_FILEMI
						_LENCONTRA := .T.
					ENDIF
				ELSE
					IF AFILS[_NX] == CFILANT
						_LENCONTRA := .T.
					ENDIF
				ENDIF
			NEXT
			IF !_LENCONTRA
				IF !EMPTY(FPA->FPA_FILEMI)
					AADD( AFILS, FPA->FPA_FILEMI)
				ELSE
					AADD( AFILS, CFILANT)
				ENDIF
			ENDIF
		ENDIF
		FQ3->(DBSKIP())
	ENDDO
ELSE
	_CTEMP := STRTRAN(ANFREMLB[2],"(","")
	_CTEMP := STRTRAN(_CTEMP,")","")
	_CTEMP := VAL(_CTEMP)
	FPA->(DBGOTO(_CTEMP))
	IF FPA->(EOF())
		_CFILAUX := CFILANT
	ELSE
		_CFILAUX := FPA->FPA_FILEMI
	ENDIF
	AADD( AFILS, _CFILAUX)
ENDIF
/*
IF SELECT("ST9TMP") > 0
	ST9TMP->(DBCLOSEAREA())
ENDIF
XCQUERY     := " SELECT DISTINCT  " + CRLF
XCQUERY     += " CASE WHEN ISNULL(ST9.T9_CENTRAB,'') = '' THEN FPA_FILIAL ELSE             " + CRLF
XCQUERY     += " ISNULL(SUBSTRING(ST9.T9_CENTRAB,1," + CVALTOCHAR(LEN(CFILANT)) + "),FPA_FILIAL) END FILS " + CRLF
XCQUERY     += " FROM "+RETSQLNAME("FPA")+" ZAG " + CRLF
IF _LROMANEIO
	XCQUERY += " INNER JOIN "+RETSQLNAME("FQ3")+" SZ1 ON  SZ1.FQ3_FILIAL  = ZAG.FPA_FILIAL " + CRLF
	XCQUERY +=                                      " AND SZ1.FQ3_PROJET  = ZAG.FPA_PROJET  AND  SZ1.FQ3_VIAGEM = ZAG.FPA_VIAGEM " + CRLF 
	XCQUERY +=                                      " AND SZ1.FQ3_OBRA    = ZAG.FPA_OBRA    AND  SZ1.FQ3_AS     = ZAG.FPA_AS     " + CRLF 
	XCQUERY +=                                      " AND SZ1.D_E_L_E_T_ = '' " + CRLF 
	XCQUERY += " INNER JOIN "+RETSQLNAME("FQ2")+" SZ0 ON  SZ1.FQ3_FILIAL  = SZ0.FQ2_FILIAL  " + CRLF
	XCQUERY +=                                      " AND SZ1.FQ3_NUM     = SZ0.FQ2_NUM      AND  SZ1.FQ3_ASF    = SZ0.FQ2_ASF     " + CRLF 
	XCQUERY +=                                      " AND SZ0.D_E_L_E_T_ = ''             " + CRLF
ENDIF
XCQUERY     += " INNER JOIN "+RETSQLNAME("FQ5")+" DTQ ON  DTQ.FQ5_AS     = ZAG.FPA_AS     " + CRLF
XCQUERY     +=                                      " AND DTQ.FQ5_STATUS = '6'            " + CRLF
XCQUERY     +=                                      " AND DTQ.D_E_L_E_T_ = ''             " + CRLF
XCQUERY     += " LEFT  JOIN "+RETSQLNAME("ST9")+" ST9 ON  ST9.T9_CODBEM  = ZAG.FPA_GRUA   " + CRLF
XCQUERY     +=                                      " AND ST9.D_E_L_E_T_ = ''             " + CRLF
XCQUERY     += " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON  SB1.B1_COD     = ZAG.FPA_PRODUT " + CRLF
XCQUERY     +=                                      " AND SB1.D_E_L_E_T_ = ''             " + CRLF
XCQUERY     += " WHERE  ZAG.FPA_FILIAL =  '"+XFILIAL("FPA")+"' " + CRLF
XCQUERY     += "   AND  ZAG.FPA_PROJET =  '"+CPROJET+"' "        + CRLF
XCQUERY     += "   AND  ZAG.FPA_AS     <> '' " + CRLF
XCQUERY     += "   AND  ZAG.FPA_NFREM  =  '' " + CRLF
XCQUERY     += "   AND  ZAG.D_E_L_E_T_ =  '' " + CRLF
IF ANFREMLB[1]
	XCQUERY += "   AND  ZAG.R_E_C_N_O_ IN "+ANFREMLB[2]+" " + CRLF
ENDIF
CONOUT("[GERNFREM.PRW] # XCQUERY(2): " + XCQUERY) 
XCQUERY := CHANGEQUERY(XCQUERY) 
IF EXISTBLOCK("NFREMQR2") 							// --> PONTO DE ENTRADA PARA ALTERA��O/INCLUS�O DE CONDI��ES DA QUERY PARA GERA��O DA NOTA FISCAL DE REMESSA.
	XCQUERY := EXECBLOCK("NFREMQR2",.T.,.T.,{XCQUERY, ANFREMLB })
ENDIF
TCQUERY XCQUERY NEW ALIAS "ST9TMP"

ST9TMP->(DBGOTOP())
WHILE ! ST9TMP->(EOF())
	AADD( AFILS, ST9TMP->FILS)
	ST9TMP->(DBSKIP())
ENDDO
*/

RESTAREA(_AAREA)
RETURN AFILS



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���PROGRAMA  � ITENSPED  � AUTOR � IT UP BUSINESS     � DATA � 04/08/2016 ���
�������������������������������������������������������������������������͹��
���DESCRICAO � VERIFICA AS FILIAIS EXISTENTES NO CAMPO T9_CENTRAB         ���
�������������������������������������������������������������������������͹��
���USO       � ESPECIFICO GPO                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION ITENSPED(CRECNO , LTRUE)

LOCAL LRET := .F.

IF SELECT("ZAGTMP") > 0
	ZAGTMP->(DBCLOSEAREA())
ENDIF
CQUERY     := " SELECT DISTINCT "
CQUERY     += "        FPA_PROJET , FPA_FILIAL , FPA_PRODUT , FPA_PREDIA , FPA_VRHOR  , FPA_AS , FPA_CODTAB ,FPA_FILEMI , " + CRLF 
CQUERY     += "        FPA_VRHOR * FPA_PREDIA HORPREDIA , "                               + CRLF 
CQUERY     += "        ISNULL(ST9.T9_VALCPA  , 0 )                         VALREM     , " + CRLF 
CQUERY     += "        FPA_GRUA   , FPA_OBRA   , FPA_SEQGRU , FPA_AS     , FPA_CACAMB , FPA_QUANT , FPA_CONPAG  , " + CRLF 
CQUERY     += "        FPA_CARAC  , FPA_CUSTO  , FPA_PLACAI , FPA_NFREM  , FPA_NFRET  , ZAG.R_E_C_N_O_ RECNOZAG , " + CRLF 
CQUERY     += "        FPA_LOCAL, " + CRLF 
CQUERY     += "        ISNULL(SUBSTRING(ST9.T9_CENTRAB,1,4),FPA_FILIAL) FILTRAB       , " + CRLF 
CQUERY     += "        ISNULL(ST9.T9_NOME    , B1_DESC)                    T9_NOME    , " + CRLF 
CQUERY     += "        ISNULL(ST9.T9_CODFAMI , '')                         T9_CODFAMI , " + CRLF 
CQUERY     += "        ISNULL(ST9.T9_SERIE   , '')                         T9_SERIE   , " + CRLF 
CQUERY     += "        ISNULL(ST9.T9_VALCPA  , 0 )                         T9_VALCPA  , " + CRLF 
CQUERY     += "        ISNULL(SHB.HB_NOME    , '')                         HB_NOME    , " + CRLF 
CQUERY     += "        B1_DESC    , B1_PRV1    , B1_UM      , B1_LOCPAD  , B1_GRUPO   , " + CRLF 
// [inicio] Jos� Eul�lio - 01/06/2022 - SIGALOC94-156 - Campo de volume e peso na C6.
CQUERY     += "        B1_PESO  ,B1_PESBRU,   " + CRLF 
// [Final] Jos� Eul�lio - 01/06/2022 - SIGALOC94-156 - Campo de volume e peso na C6.
// [inicio] Jos� Eul�lio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
If _LROMANEIO .And. FQ3->(ColumnPos("FQ3_OBSCCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSCON")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFCM")) > 0 .And. FQ3->(ColumnPos("FQ3_OBSFIS")) > 0
	CQUERY +=      " 	SZ1.FQ3_OBSCCM, SZ1.FQ3_OBSCON, SZ1.FQ3_OBSFCM, SZ1.FQ3_OBSFIS, "
	CQUERY +=      " 	SZ1.FQ3_QTD, " //Jos� Eul�lio - 01/06/2022 - SIGALOC94-156 - Campo de volume e peso na C6.
EndIf
// [final] Jos� Eul�lio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
CQUERY     += "        ISNULL(ST9.T9_CENTRAB , FPA_FILIAL)                 T9_CENTRAB "   + CRLF
CQUERY     += " FROM "+RETSQLNAME("FPA")+" ZAG " + CRLF
IF _LROMANEIO
	CQUERY += "        INNER JOIN "+RETSQLNAME("FQ3")+" SZ1 ON  SZ1.FQ3_FILIAL  = ZAG.FPA_FILIAL       AND  SZ1.FQ3_PROJET  =  ZAG.FPA_PROJET " + CRLF
	CQUERY += "                                             AND SZ1.FQ3_VIAGEM  = ZAG.FPA_VIAGEM       AND  SZ1.FQ3_OBRA    =  ZAG.FPA_OBRA   " + CRLF
	CQUERY += "                                             AND SZ1.FQ3_AS      = ZAG.FPA_AS           AND  SZ1.D_E_L_E_T_ =  '' "             + CRLF
	CQUERY += "        INNER JOIN "+RETSQLNAME("FQ2")+" SZ0 ON  SZ1.FQ3_FILIAL  = SZ0.FQ2_FILIAL        AND  SZ1.FQ3_NUM     =  SZ0.FQ2_NUM "     + CRLF
	CQUERY += "                                             AND SZ1.FQ3_ASF     = SZ0.FQ2_ASF           AND  SZ0.D_E_L_E_T_ =  '' AND SZ0.FQ2_NUM = '"+FQ2->FQ2_NUM+"' " + CRLF
ENDIF
CQUERY     += "        INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON  SB1.B1_COD     = ZAG.FPA_PRODUT       AND  SB1.D_E_L_E_T_ = '' "              + CRLF
CQUERY     += "        INNER JOIN "+RETSQLNAME("FQ5")+" DTQ ON  DTQ.FQ5_AS     = ZAG.FPA_AS           AND  DTQ.FQ5_STATUS =  '6' "            + CRLF
CQUERY     += "                                             AND DTQ.FQ5_GUINDA = FPA_GRUA             AND  DTQ.D_E_L_E_T_ =  '' "             + CRLF
CQUERY     += "        LEFT  JOIN "+RETSQLNAME("ST9")+" ST9 ON  ST9.T9_CODBEM  = ZAG.FPA_GRUA         AND  ST9.T9_CODBEM  <> '' "             + CRLF
CQUERY     += "                                             AND ST9.D_E_L_E_T_ = '' "                                                         + CRLF
CQUERY     += "        LEFT  JOIN "+RETSQLNAME("SHB")+" SHB ON  SHB.HB_FILIAL  = '"+XFILIAL("SHB")+"' AND  SHB.HB_COD     =  ST9.T9_CENTRAB " + CRLF
CQUERY     += "                                             AND SHB.D_E_L_E_T_ = '' "                                                         + CRLF
CQUERY     += " WHERE  ZAG.FPA_FILIAL =  '"+XFILIAL("FPA")+"' " + CRLF
CQUERY     += "   AND  ZAG.FPA_PROJET =  '"+CPROJET       +"' " + CRLF
CQUERY     += "   AND  ZAG.FPA_AS     <> ''  "                  + CRLF
//CQUERY     += "   AND  ZAG.FPA_PRCUNI > 0 "                     + CRLF

// Frank - controle para n�o trazer as notas de remessa ja geradas - 21/09/21
CQUERY     += "   AND  ZAG.FPA_NFREM = ''  "                  + CRLF

CQUERY     += "   AND  ZAG.FPA_TIPOSE =  'L' "                  + CRLF
IF EXISTBLOCK("NFREMQRY") 							// --> PONTO DE ENTRADA PARA ALTERA��O/INCLUS�O DE CONDI��ES DA QUERY PARA GERA��O DA NOTA FISCAL DE REMESSA.
	CQUERY := EXECBLOCK("NFREMQRY" , .T. , .T. , {CQUERY}) 
ENDIF
CQUERY     += "   AND  ZAG.D_E_L_E_T_ =  '' "                   + CRLF
IF LNFREMLB .AND. LTRUE
	CQUERY += "   AND  ZAG.R_E_C_N_O_ IN "+CRECNO+" "           + CRLF
ENDIF
CQUERY     += " ORDER BY ZAG.FPA_OBRA , ZAG.FPA_SEQGRU "        + CRLF
//CONOUT("[GERNFREM.PRW] # CQUERY(3): " + CQUERY) 
CQUERY := CHANGEQUERY(CQUERY) 
//MEMOWRITE("C:\ERRONANFREM.SQL", CQUERY) 
TCQUERY CQUERY NEW ALIAS "ZAGTMP" 

ZAGTMP->(DBGOTOP()) 

IIF( ZAGTMP->(EOF()) , LRET := .F. , LRET := .T. ) 

RETURN LRET 



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���PROGRAMA  � VLDLPAD   � AUTOR � IT UP BUSINESS     � DATA � 04/08/2016 ���
�������������������������������������������������������������������������͹��
���DESCRICAO � IDENTIFICA OS LOCAIS COM SALDO PARA O PRODUTO              ���
�������������������������������������������������������������������������͹��
���USO       � ESPECIFICO GPO                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION VLDLPAD( _NQTD )

LOCAL   ARET      := {}
LOCAL   LLOCPAD   := SUPERGETMV("MV_LOCX214",.F.,.T.) // .T. = INNER JOIN PARA UTILIZAR APENAS ARMAZ�M PADR�O OU .F. = LEFT JOIN PARA UTILIZAR QUALQUER ARMAZ�M DISPON�VEL.
LOCAL   CLOCPAD   := IIF(LLOCPAD , "INNER" , "LEFT")
LOCAL   _CARMAZEM := ""

DEFAULT _NQTD     := ZAGTMP->FPA_QUANT

IF SELECT("TRBSB2") > 0
	TRBSB2->(DBCLOSEAREA())
ENDIF
_CQUERY := " SELECT ISNULL(B1_LOCPAD,'') B1_LOCPAD , B2_LOCAL , B2_QATU " + CRLF
_CQUERY += " FROM " + RETSQLNAME("SB2") + " SB2 "                         + CRLF
_CQUERY += "      "+CLOCPAD+" JOIN "+RETSQLNAME("SB1")+" SB1 ON  SB1.B1_FILIAL  = '" + XFILIAL("SB1") + "' " + CRLF
_CQUERY += "                                                 AND SB1.B1_COD     = B2_COD  AND  SB1.B1_LOCPAD = B2_LOCAL " + CRLF
_CQUERY += "                                                 AND SB1.D_E_L_E_T_ = '' " + CRLF
_CQUERY += " WHERE  B2_FILIAL = '" + XFILIAL("SB2") + "'      " + CRLF
_CQUERY += "   AND  B2_COD    = '" + ZAGTMP->FPA_PRODUT + "'  " + CRLF
_CQUERY += "   AND  B2_QATU	 >= '" + STR(_NQTD) + "'          " + CRLF
_CQUERY += "   AND  B2_LOCAL <> ''                            " + CRLF
_CQUERY += "   AND  SB2.D_E_L_E_T_ = ''                       " + CRLF
_CQUERY += " ORDER BY B1_LOCPAD DESC , B2_QATU DESC , B2_LOCAL " 
//CONOUT("[GERNFREM.PRW] # _CQUERY(4): " + _CQUERY) 
_CQUERY := CHANGEQUERY(_CQUERY) 
TCQUERY _CQUERY NEW ALIAS "TRBSB2"

TRBSB2->(DBGOTOP())

IF TRBSB2->(!EOF())
	WHILE TRBSB2->(!EOF())
		IF EMPTY(_CARMAZEM)
			_CARMAZEM := TRBSB2->B2_LOCAL
			EXIT
		ENDIF
		TRBSB2->(DBSKIP())
	ENDDO
	IF ! EMPTY(_CARMAZEM)
		ARET := {.T.,_CARMAZEM}
	ELSE
		ARET := {.F.,_CARMAZEM}
	ENDIF
ELSE
	ARET := {.F.,_CARMAZEM}
ENDIF
TRBSB2->(DBCLOSEAREA())

RETURN ARET



// ======================================================================= \\
STATIC FUNCTION QTDENV( _CAS )
// ======================================================================= \\

LOCAL   _AAREAOLD := GETAREA()
LOCAL   _NRET     := .T.
LOCAL   _CQUERY   := ""
Local 	lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integra��o com M�dulo de Loca��es SIGALOC

IF SELECT("TRBQTD") > 0
	TRBQTD->(DBCLOSEAREA())
ENDIF
_CQUERY := " SELECT SUM(C6_QTDVEN) QTD" + CRLF
_CQUERY += " FROM " + RETSQLNAME("SC6") + " SC6 (NOLOCK) " + CRLF
//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
If lMvLocBac
	_CQUERY += "        INNER JOIN " + RETSQLNAME("FPY") + " FPY (NOLOCK) " + CRLF
	_CQUERY += "			ON  FPY_FILIAL  = C6_FILIAL "              		+ CRLF
	_CQUERY += "            AND FPY_PEDVEN     = SC6.C6_NUM   "             + CRLF
	_cQuery += "            AND FPY_TIPFAT = 'R' "
	_cQuery += "            AND FPY_STATUS <> '2' "
	_CQUERY += "        INNER JOIN " + RETSQLNAME("FPZ") + " FPZ (NOLOCK) " + CRLF
	_CQUERY += "			ON  FPZ_FILIAL  = C6_FILIAL "              		+ CRLF
	_CQUERY += "            AND FPZ_PEDVEN     = SC6.C6_NUM   "             + CRLF
	_CQUERY += "            AND FPZ_PROJET     = FPY_PROJET   "             + CRLF
Else
	_CQUERY += "        INNER JOIN " + RETSQLNAME("SC5") + " SC5 (NOLOCK) ON  SC5.C5_FILIAL  = '" + XFILIAL("SC5") + "' "              + CRLF
	_CQUERY += "                                                          AND SC5.C5_NUM     = SC6.C6_NUM  AND  SC5.C5_XTIPFAT = 'R' " + CRLF
	_CQUERY += "                                                          AND SC5.D_E_L_E_T_ = '' "                                    + CRLF
EndIf
_CQUERY += " WHERE  SC6.C6_FILIAL  =  '" + XFILIAL("SC6") + "' " 	+ CRLF
If lMvLocBac	
	_CQUERY += "   	AND FPZ_AS     =  '" + _CAS + "' "           	+ CRLF
	_CQUERY += "   	AND FPZ_AS     <> '' "                       	+ CRLF
	_CQUERY += "	AND FPY_TIPFAT = 'R' " 							+ CRLF
	_CQUERY += "    AND FPY.D_E_L_E_T_ = '' "                       + CRLF
else
	_CQUERY += "   AND  SC6.C6_XAS     =  '" + _CAS + "' "           + CRLF
	_CQUERY += "   AND  SC6.C6_XAS     <> '' "                       + CRLF
EndIf
_CQUERY += "   AND  SC6.C6_BLQ NOT IN ('R','S') "                + CRLF
_CQUERY += "   AND  SC6.D_E_L_E_T_ =  '' "
//CONOUT("[GERNFREM.PRW] # _CQUERY(5): " + _CQUERY) 
_CQUERY := CHANGEQUERY(_CQUERY) 
TCQUERY _CQUERY NEW ALIAS "TRBQTD"

IF TRBQTD->(!EOF())
	_NRET := TRBQTD->QTD
ENDIF

TRBQTD->(DBCLOSEAREA())

RESTAREA( _AAREAOLD )

RETURN _NRET


// Frank Zwarg Fuga - 09/07/21
// Rotina para n�o permitir na gera��o da nota de remessa duas obras diferentes
Function LOCA010X(_aRemessa)
Local _nX
Local _cTemp
Local _lRet := .T.

For _nX := 1 to len(_aRemessa)
	If _aRemessa[_nX,1]
		If empty(_cTemp)
			_cTemp := _aRemessa[_nX,4]
		EndIF
		If !empty(_cTemp) .and. _aRemessa[_nX,4] <> _cTemp
			_lRet := .F.
			Exit
		EndIF
	EndIF
Next
If !_lRet
	Help(Nil,	Nil,STR0081+alltrim(upper(Procname())),; //"RENTAL: "
	Nil,STR0082,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsist�ncia nos dados."
	{STR0083}) //"N�o podem ser selecionados itens de obras diferentes."
	RETURN .F.
EndIF


If MSGYESNO(OEMTOANSI(STR0084), STR0008) //"DESEJA MESMO GERAR NF DE REMESSA PARA OS ITENS SELECIONADOS?"###"GERA NF REMESSA"
	_lRet := .T.
Else
	_lRet := .F.
EndIF
Return _lRet


// Funcao para a chamada da rotina XMailNF que atualmente � static.
// Frank Z Fuga em 28/03/2022
Function LOCA010Y(_cNotax, _cSeriex)
Return XMailNF(_cNotax, _cSeriex)

//------------------------------------------------------------------------------
/*/{Protheus.doc} MarcarRegi
Marca ou Desmarca todas as linhas do ListBox
@author Jose Eulalio
@since 28/10/2022
/*/
//------------------------------------------------------------------------------
Static Function MarcarRegi(lTodos , _aRemessa)
Local nI        := 0 
Local lMarcados := _aRemessa[OLISREM:NAT,1]

For nI := 1 TO LEN(_aRemessa)
	_aRemessa[nI,1] := !lMarcados
Next nI 

oLisRem:Refresh()
oDlgRem:Refresh()
		
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA01001
Observa��es e outras informa��es para o pedido de vendas
@author Jose Eulalio
@since 29/03/2023
/*/
//------------------------------------------------------------------------------
Function LOCA01001(aCamposSc5,cCmpUsr,aGetInfo,lLoca01001)
Local cObserv	:= ""
Local cEspecie	:= "MAQUINA   "
Local cCpoTit	:= ""
Local xCpoValue
Local nLinha	:= 0
Local nCol01	:= 10
Local nCol02	:= 80
Local nCol03	:= 120
Local nCol04	:= 150
Local nSizeH	:= 172
Local nSizeW	:= 300
Local nMultW	:= 10 //multiplo da largura
Local aFrete	:= {STR0104,STR0105,STR0106,STR0107,STR0108,STR0109,""} //C=CIF;F=FOB;T=Por conta terceiros;R=Por conta remetente;D=Por conta destinat�rio;S=Sem frete
Local aAreaFP1	:= FP1->(GetArea())
Local aLoca010A	:= {}
Local aTamCampo	:= {}
Local lNfeDest	:= SuperGetMv("MV_NFEDEST", .F., .F.)	
Local lCmpUsr	:= .F.
Local lContinua	:= .T.
Local lLoca010A	:= ExistBlock("LOCA010A")
Local oDlgObs
Local oContainer
Local oGet01
Local oGet02
Local oCombo03
Local oTMultiget04
Local oGet05
Local oGet06
Local oGet07
Local oGet08
Local oGet09
Local oGet10
Local oGet11
Local oGet12
Local bConfirm
Local bSair

Default aCamposSc5 	:= {}
Default cCmpUsr 	:= SuperGetMv("MV_CMPUSR",.F.,"")

//Para passar apenas uma vez na fun��o
lLoca01001 := .T.

//Carrega objeto da interface
oDlgObs  := FwDialogModal():New() 

oDlgObs:SetTitle(STR0110) //'Informa��es para a Nota Fiscal'

//Valida��es e atualiza��o das informa��es
bConfirm := {|| lContinua := fInfoNfOk(aGetInfo,@aCamposSc5,cCmpUsr,cObserv), IF(lContinua,oDlgObs:oOwner:End(),NIL) }
bSair    := {|| lContinua := !(Iif(MsgYesNo( STR0111,STR0022),oDlgObs:oOwner:End(),NIL)), IF(!lContinua,cAviso:=STR0112,NIL) } //'Deseja cancelar a Emiss�o de Remessa neste momento ? ' ### 'Cancelar' ### "Opera��o cancelada!"

//Verifica se tem campo de usu�rio e se ele existe
lCmpUsr	:= !Empty(cCmpUsr) .And. SC5->(FieldPos(cCmpUsr)) > 0

//adiciona altura caso tenha observa��es	
If lCmpUsr
	nSizeH += 103
EndIf

// caso parametro de cliente retirada ativo
If lNfeDest
	nSizeH += 25
EndIf

//caso ponto de entrada para novo campo exista
If lLoca010A
	nSizeH += 25
EndIf

//Seta a largura e altura da janela em pixel
oDlgObs:SetPos(000, 000)
oDlgObs:SetSize(nSizeH, nSizeW)

oDlgObs:EnableFormBar( .T. )
oDlgObs:SetCloseButton( .F. )
oDlgObs:SetEscClose( .F. )
oDlgObs:CreateDialog()
oDlgObs:CreateFormBar()

oDlgObs:AddButton( STR0022, bSair, STR0022, , .T., .F., .T., ) //Cancelar
oDlgObs:AddCloseButton(bConfirm	, STR0113		) //'Confirmar'

//monta container
oContainer := TPanel():New( ,,, oDlgObs:getPanelMain() )
oContainer:Align := CONTROL_ALIGN_ALLCLIENT

//linha 01
nLinha := 05
//transportadora 01
aTamCampo := TamSx3("C5_TRANSP")
aGetInfo[1] := {"C5_TRANSP" 	, Space(aTamCampo[1])     , XA1ORDEM("C5_TRANSP") } 
oGet01 		:= TGet():New( nLinha,nCol01,{|x| if(PCount()>0,aGetInfo[1][2]:=x,aGetInfo[1][2]) 	 },oContainer,aTamCampo[1] * nMultW ,011,"",{||ValidTransp(aGetInfo[1][2]) },0,,,.T.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aGetInfo[1][2]",,,,,,,"Transportadora ",1 )
oGet01:cF3 	:= "SA4"
//formula 02	
aTamCampo := TamSx3("C5_MENNOTA")
aGetInfo[2] := {"C5_MENNOTA" 	, SPACE( aTamCampo[1] )     , XA1ORDEM("C5_MENNOTA") } 
oGet02 		:= TGet():New( nLinha,nCol02,{|x| if(PCount()>0,aGetInfo[2][2]:=x,aGetInfo[2][2]) },oContainer,200,011,"",{||ValidFormu(aGetInfo[2][2])},0,,,.T.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aGetInfo[2][2]",,,,,,,"Formula ",1 )
oGet02:cF3 	:= "SM4"

nLinha += 25


//Observa��o, 04
// somente se o parametro MV_CMPUSR estiver preenchido e com um campo valido
If lCmpUsr
	cObserv := ""
	aGetInfo[4] := {cCmpUsr 	, cObserv    , XA1ORDEM(cCmpUsr) } 
	oTMultiget04 := TMultiget():new(nLinha,nCol01, {| u | if( pCount() > 0, cObserv := u, cObserv ) },  oContainer, 280, 92,,,,,,.T.,,,,,,,,,,,, "Observa��es", 1 )
	nLinha += 103
Else
	aGetInfo[4] := {"" 	, ""    , NIL } 
ENDIF

// tipo de transporte 03 aFrete[2] == "F"
aTamCampo := TamSx3("C5_TPFRETE")
aGetInfo[3] := {"C5_TPFRETE" 	, aFrete[2]     , XA1ORDEM("C5_TPFRETE") } 
oCombo03	:= TComboBox():New(nLinha,nCol01,{|u|if(PCount()>0,aGetInfo[3][2]:=u,aGetInfo[3][2])},aFrete,aTamCampo[1] * 65,14,oContainer,,,,,,.T.,,,,,,,,,'aGetInfo[3][2]',"Tipo Frete",1)
//volume 05
aTamCampo := TamSx3("C5_VOLUME1")
aGetInfo[5] := {"C5_VOLUME1"	, 1	    , XA1ORDEM("C5_VOLUME1" ) }
oGet05 := TGet():New( nLinha,nCol02,{| u | if( pCount() > 0, aGetInfo[5][2] := u, aGetInfo[5][2] ) },oContainer,aTamCampo[1] * (nMultW / 2),011,"@E 99999",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aGetInfo[5][2] "	,,,,,,,"Volume ",1 )
//especie 06
aTamCampo := TamSx3("C5_ESPECI1")
aGetInfo[6] := {"C5_ESPECI1"  , cEspecie          , XA1ORDEM("C5_ESPECI1") }  //"MAQUINA"
oGet06 := TGet():New( nLinha,nCol04,{| u | if( pCount() > 0, aGetInfo[6][2] := u, aGetInfo[6][2] ) },oContainer,aTamCampo[1] * (nMultW / 2),011,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aGetInfo[6][2]",,,,,,,"Especie ",1 )

nLinha += 25
//calcula o peso
aPeso := CalcPeso()
//peso bruto 07
aTamCampo := TamSx3("C5_PESOL")
aGetInfo[7] :=  {"C5_PESOL"	, aPeso[1]		    , XA1ORDEM("C5_PESOL"  ) } 
oGet07 := TGet():New( nLinha,nCol01,{| u | if( pCount() > 0, aGetInfo[7][2] := u, aGetInfo[7][2] ) },oContainer,aTamCampo[1] * (nMultW / 2),011,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"aPeso[2]"	,,,,,,,"Peso Bruto ",1 )
//peso liquido 08
aTamCampo := TamSx3("C5_PBRUTO")
aGetInfo[8] :=  {"C5_PBRUTO"	, aPeso[2]		    , XA1ORDEM("C5_PBRUTO" ) } 
oGet08 := TGet():New( nLinha,nCol02,{| u | if( pCount() > 0, aGetInfo[8][2] := u, aGetInfo[8][2] ) },oContainer,aTamCampo[1] * (nMultW / 2),011,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"aPeso[1]"	,,,,,,,"Peso Liquido ",1 )

//cliente retirada caso parametro ativo
If lNfeDest
	nLinha += 25
	// cliente retirada 09
	aTamCampo := TamSx3("C5_CLIRET")
	aGetInfo[9] := {"C5_CLIRET"   , Space(aTamCampo[1])	      , XA1ORDEM("C5_CLIRET")  } 
	oGet09 := TGet():New( nLinha,nCol01,{| u | if( pCount() > 0, aGetInfo[9][2] := u, aGetInfo[9][2] ) },oContainer,aTamCampo[1] * nMultW,011,"",{||ValidCli(aGetInfo[9][2])},0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aGetInfo[9][2]"	,,,,,,,"Cliente Retirada ",1 )
	oGet09:cF3 	:= "SA1"
	//loja retirada 10
	aTamCampo := TamSx3("C5_LOJARET")
	aGetInfo[10] := {"C5_LOJARET"   , Space(aTamCampo[1])	      , XA1ORDEM("C5_LOJARET")  } 
	oGet10 := TGet():New( nLinha,(TamSx3("C5_CLIRET")[1] * nMultW) + nMultW + 2,{| u | if( pCount() > 0, aGetInfo[10][2] := u, aGetInfo[10][2] ) },oContainer,aTamCampo[1] * nMultW,011,"",{||ValidCli(aGetInfo[9][2],aGetInfo[10][2])},0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aGetInfo[10][2]"	,,,,,,,"Loja ",1 )
else
	aGetInfo[9]  := {""   , ""	      , NIL  } 
	aGetInfo[10] := {""   , ""	      , NIL  } 
EndIf

nLinha += 25
//cliente entrega 11
aTamCampo := TamSx3("C5_CLIENT")
aGetInfo[11] := {"C5_CLIENT"   , FP1->FP1_CLIDES	      , XA1ORDEM("C5_CLIENT")  } 
oGet11 := TGet():New( nLinha,nCol01,{| u | if( pCount() > 0, aGetInfo[11][2] := u, aGetInfo[11][2] ) },oContainer,aTamCampo[1] * nMultW,011,"",{||ValidCli(aGetInfo[11][2])},0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aGetInfo[11][2]"	,,,,,,,"Cliente Entrega ",1 )
oGet11:cF3 	:= "SA1"
//loja entrega 12
aTamCampo := TamSx3("C5_LOJAENT")
aGetInfo[12] := {"C5_LOJAENT"   , FP1->FP1_LOJDES	      , XA1ORDEM("C5_LOJAENT")  } 
oGet12 := TGet():New( nLinha,(TamSx3("C5_CLIENT")[1] * nMultW) + nMultW + 2,{| u | if( pCount() > 0, aGetInfo[12][2] := u, aGetInfo[12][2] ) },oContainer,aTamCampo[1] * nMultW,011,"",{||ValidCli(aGetInfo[11][2],aGetInfo[12][2])},0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aGetInfo[nTamArray][12]"	,,,,,,,"Loja ",1 )

//adiciona um campo na FwDialogModal pelo PE LOCA010A
If lLoca010A
	//Formato do Retonno 
	//aLoca010A[1] ==> nome do campo na SC5
	//aLoca010A[2] ==> descri��o a ser apresentada
	//aLoca010A[3] ==> valor pre carregado no campo
	//aLoca010A[4] ==> Consulta Padr�o
	aLoca010A := ExecBlock("LOCA010A")
	If ValType(aLoca010A) == "A"
		//verifica se o campo existe e � da SC5
		If "C5_" $ aLoca010A[1] .And. SC5->(FieldPos(aLoca010A[1])) > 0
			aCpoInfo := FWSX3Util():GetFieldStruct( aLoca010A[1] )
			//monta de acordo com a tipagem
			If !Empty(aLoca010A[2])
				cCpoTit := aLoca010A[2]
			Else
				cCpoTit := aCpoInfo[1]
			EndIf 
			//pega o valor pre carregado
			If !Empty(aLoca010A[3])
				xCpoValue := aLoca010A[3]
			EndIf 
			nLinha += 25
			//carrega o array de dados
			Aadd(aGetInfo,{aLoca010A[1] 	, xCpoValue     , XA1ORDEM(aLoca010A[1]) } )
			//monta o objeto
			If aCpoInfo[2] == "C" .Or. aCpoInfo[2] == "N" .Or. aCpoInfo[2] == "D"
				aTamCampo := TamSx3(aLoca010A[1] )
				oGet013 		:= TGet():New( nLinha,nCol01,{|x| if(PCount()>0,aGetInfo[13][2]:=x,aGetInfo[13][2]) 	 },oContainer,aTamCampo[1] * nMultW,011,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aGetInfo[13][2]",,,,,,,cCpoTit,1 )
				oGet013:cF3 	:= aLoca010A[4]
			//ElseIf aCpoInfo[2] == "M" //campo memo n�o aparece no FieldPos
				//oGet013 := TMultiget():new(nLinha,nCol01, {| u | if( pCount() > 0, aGetInfo[13][2] := u, aGetInfo[13][2] ) },  oContainer, 280, 14,,,,,,.T.,,,,,,,,,,,, cCpoTit, 1 )
			EndIf
		EndIf
	Endif
EndIf

oDlgObs:Activate()

RestArea(aAreaFP1)

Return lContinua

//------------------------------------------------------------------------------
/*/{Protheus.doc} fInfoNfOk
Valida��es e atualiza��o das informa��es
@author Jose Eulalio
@since 29/03/2023
/*/
//------------------------------------------------------------------------------
Static Function fInfoNfOk(aGetInfo,aCamposSc5,cCmpUsr,cObserv)
Local nX	:= 0
Local nPos	:= 0
Local lRet	:= .T.

//valida��es de transportadora
lRet := ValidTransp(aGetInfo[1][2]) 

//valida formula
If lRet
	lRet := ValidFormu(aGetInfo[2][2])
EndIf

//valida cliente retirada
If lRet .And. !Empty(aGetInfo[9][2])
	lRet := ValidCli(aGetInfo[9][2],aGetInfo[10][2])
EndIf

//valida ciente entrega
If lRet .And. !Empty(aGetInfo[11][2])
	lRet := ValidCli(aGetInfo[11][2],aGetInfo[12][2])
EndIf

//atualiza cabe�alho
If lRet
	For nX := 1 To Len (aGetInfo)
		//verifica se tem informa��es
		If !Empty(aGetInfo[nX][1]) 
			//observa��o
			If aGetInfo[nX][1] == cCmpUsr
				aGetInfo[nX][2] := cObserv
			EndIf
			//caso j� exista no cabe�alho, atualiza
			nPos	:= Ascan(aCamposSc5,{|X| AllTrim(X[1])==AllTrim(aGetInfo[nX][1])})
			If nPos > 0
				aCamposSc5[nPos][2] := aGetInfo[nX][2]
			Else
				Aadd(aCamposSc5  , aGetInfo[nX] )
			EndIf
		EndIf
	Next nX
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidTransp
Valida��o da Transpor tadora
@author Jose Eulalio
@since 30/03/2023
/*/
//------------------------------------------------------------------------------
Static Function ValidTransp(cTransp)
Local lRet := .T.
Local aAreaSA4	:= SA4->(GetArea())

//localiza transportadora
If !Empty(cTransp)
	SA4->(DbSetOrder(1))
	lRet := SA4->(DbSeek(xFilial("SA4") + AllTrim(cTransp)))
EndIf

If !lRet
	Help(NIL, NIL, "LOCA010_01", NIL, STR0114, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0115}) //"Registro n�o localizado" ### "Informe um c�digo para Transportadora v�lido"
EndIf

RestArea(aAreaSA4)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidFormu
Valida��o das formulas
@author Jose Eulalio
@since 30/03/2023
/*/
//------------------------------------------------------------------------------
Static Function ValidFormu(cFormula)
Local lRet := .T.
Local aAreaSA4	:= SM4->(GetArea())

//localiza formula
If !Empty(cFormula)
	SM4->(DbSetOrder(1))
	lRet := SM4->(DbSeek(xFilial("SM4") + AllTrim(cFormula)))
EndIf

If !lRet
	Help(NIL, NIL, "LOCA010_02", NIL, STR0114, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0116}) //"Registro n�o localizado" ### "Informe um c�digo de F�rmula v�lido"
EndIf

RestArea(aAreaSA4)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidCli
Valida��o dos clientes
@author Jose Eulalio
@since 30/03/2023
/*/
//------------------------------------------------------------------------------
Static Function ValidCli(cCliTransp,cLojTransp)
Local lRet 			:= .T.
Local aAreaSA4		:= SA4->(GetArea())

Default cLojTransp	:= ""

//localiza cliente
If !Empty(cCliTransp+cLojTransp)
	SA1->(DbSetOrder(1))
	lRet := SA1->(DbSeek(xFilial("SA1") + AllTrim(cCliTransp+cLojTransp)))
EndIf

If !lRet
	Help(NIL, NIL, "LOCA010_03", NIL, STR0114, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0117}) //"Registro n�o localizado" ### "Informe um c�digo para Cliente v�lido"
EndIf

RestArea(aAreaSA4)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CalcPeso
Retorna peso bruto e liquido de acordo com Cadastro de Produtos SB1
@author Jose Eulalio
@since 30/03/2023
/*/
//------------------------------------------------------------------------------
Static Function CalcPeso()
Local cGrpAnd
Local nPeso		:= 0
Local nPesBru	:= 0
Local nQuant	:= 0
Local aAreaZAG	:= ZAGTMP->(GetArea())

//verifica se produto est� no grupo de acessorio
IF SBM->(FIELDPOS("BM_XACESS")) > 0
	cGrpAnd := LOCA00189()
ELSE
	cGrpAnd := SUPERGETMV("MV_LOCX014",.F.,"")
ENDIF

//roda os itens a serem gerados para pegar o peso bruto e liquido
While !ZAGTMP->(Eof()) 
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+ZAGTMP->FPA_PRODUT))
	IF AllTrim(ZAGTMP->B1_GRUPO) $ (AllTrim(cGrpAnd))
		IF ZAGTMP->FPA_QUANT > 0
			nQuant := ZAGTMP->FPA_QUANT - QTDENV( ZAGTMP->FPA_AS )
		ENDIF
	Else
		nQuant := 1
	EndIf
	nPeso	+= nQuant * SB1->B1_PESO
	nPesBru	+= nQuant * SB1->B1_PESBRU
	ZAGTMP->(dbSkip())
EndDo

RestArea(aAreaZAG)
//devolve para o topo
ZAGTMP->(DbGoTop())

Return {nPeso,nPesBru}
