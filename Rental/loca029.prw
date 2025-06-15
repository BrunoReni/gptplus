#include "loca029.ch" 
#include "topconn.ch"
#include "fwmvcdef.ch"
#include "apwizard.ch"
#include "protheus.ch"  

/*LOCA029.PRW
ITUP BUSINESS - TOTVS RENTAL
TELA DE MANUTEN��O DO ROMANEIO
FRANK ZWARG FUGA
03/12/2020
*/

function loca029(_casf)
local _lc029cor   := existblock("LC029COR")
private ccadastro := STR0001 //"romaneio"
private arotina   := {}
private aentidade := {}
private cromax	  := "" // c�digo do romaneio para uso no pondo de entrada mt103fim - frank 29/10/20
private _nzuc     := 0  // recno da zuc (conjunto transportador) usado no ponto de entrada mt103fim, gernfret e a103devol - frank 02/11/20

	aadd( aentidade, { "FQ2", { "FQ2_NUM" }, { || FQ2->FQ2_NUM } } )

	aadd( arotina , { STR0002, "AXPESQUI"   , 0, 1, 0, NIL } ) //"Pesquisar"
	aadd( arotina , { STR0003, "AXALTERA"   , 0, 4, 0, NIL } ) //"Manuten��o"
	aadd( arotina , { STR0004, "AXVISUAL"   , 0, 2, 0, NIL } ) //"Visualizar"
	aadd( arotina , { STR0005, "LOCA02901"  , 0, 4, 0, NIL } ) //"Equip/Insumos"
	aadd( arotina , { STR0006, "LOCR004"    , 0, 2, 0, NIL } ) //"Imprimir"
	aadd( arotina , { STR0007, "MSDOCUMENT" , 0, 4, 0, NIL } ) //NECESS�RIO USAR O PE FTMSREL  //"Banco de informa��o"
	aadd( arotina , { STR0008, "LOCA026"    , 0, 4, 0, .F. } ) //"Protocolo entrega Fis."
	aadd( arotina , { STR0009, "LOCA025"    , 0, 4, 0, .F. } ) //"Avalia��o"
	aadd( arotina , { STR0010, "LOCA02903"  , 0, 2, 0, NIL } ) //"Emiss�o NF"
	aadd( arotina , { STR0011, "LOCA02907"  , 0, 2, 0, NIL } ) //"Legenda"

	acores := { {"LOCA02908() == 1", "BR_VERDE"    },; 
				{"LOCA02908() == 2", "BR_AMARELO"  },;
				{"LOCA02908() == 3", "BR_AZUL"     },;
				{"LOCA02908() == 4", "BR_VERMELHO" }}

	// DJALMA  - TRATAR NO CARD 350 - SPRINT 3.4 - ORGUEL - Legenda no romaneio (chamado 29564)
	// CRIAR UM EXECBLOCK PARA UM NOVO TRATAMENTO DO ACORES
	if _lc029cor
		acores := EXECBLOCK("LC029COR",.T.,.T.,{ACORES})
	endif  

	dbselectarea("FQ2")
	FQ2->(dbsetorder(1))
	FQ2->(dbgotop())
	mbrowse(6,1,22,75,"FQ2",,,,,, acores)

return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���PROGRAMA  � loca02901 � AUTOR � IT UP BUSINESS     � DATA � 10/08/2016 ���
�������������������������������������������������������������������������͹��
���DESCRI��O � EQUIPAMENTOS DO ROMANEIO.                                  ���
���          � CHAMADA: MENU - "EQUIP/INSUMOS"                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
function loca02901()
local osz1
private arotina := {}
                     
	OSZ1 := FWMBROWSE():NEW()       
	OSZ1:SETALIAS( "FQ3" )
	OSZ1:SETDESCRIPTION( STR0013 + ALLTRIM(FQ2->FQ2_NUM) ) //"EQUIPAMENTOS DO ROMANEIO - "

	// LEGENDA
	IF ST6->( FIELDPOS("T6_XGRUPO") ) > 0	
		OSZ1:ADDLEGEND("ALLTRIM(POSICIONE('ST6',1,XFILIAL('ST6') + FQ3_FAMBEM,'T6_XGRUPO')) == '1'", "GREEN"  , STR0015		) //"GERADOR"
		OSZ1:ADDLEGEND("ALLTRIM(POSICIONE('ST6',1,XFILIAL('ST6') + FQ3_FAMBEM,'T6_XGRUPO')) == '2'", "BLUE"   , STR0017   		) //"CABO"
		OSZ1:ADDLEGEND("ALLTRIM(POSICIONE('ST6',1,XFILIAL('ST6') + FQ3_FAMBEM,'T6_XGRUPO')) == '3'", "VIOLET" , STR0019		) //"QTA/QTM"
		OSZ1:ADDLEGEND("ALLTRIM(POSICIONE('ST6',1,XFILIAL('ST6') + FQ3_FAMBEM,'T6_XGRUPO')) == '4'", "ORANGE" , STR0021	) //"TRANSFORMADOR"
		OSZ1:ADDLEGEND("ALLTRIM(POSICIONE('ST6',1,XFILIAL('ST6') + FQ3_FAMBEM,'T6_XGRUPO')) == '5'", "GRAY"   , STR0023		) //"ACESS�RIO"
		OSZ1:ADDLEGEND("!EMPTY(FQ3_ORDEM)"                                                         , "RED"    , STR0025         ) //"INSUMO"
	ELSE
		//OSZ1:ADDLEGEND("ALLTRIM(FQ3_FAMBEM) $ ALLTRIM(GETMV('MV_LOCX009'))", "GREEN" , DESMFAM(GETMV("MV_LOCX009")))
		//OSZ1:ADDLEGEND("ALLTRIM(FQ3_FAMBEM) $ ALLTRIM(GETMV('MV_LOCX010'))", "BLUE"  , DESMFAM(GETMV("MV_LOCX010")))
		//OSZ1:ADDLEGEND("ALLTRIM(FQ3_FAMBEM) $ ALLTRIM(GETMV('MV_LOCX011'))", "VIOLET", DESMFAM(GETMV("MV_LOCX011")))
		//OSZ1:ADDLEGEND("ALLTRIM(FQ3_FAMBEM) $ ALLTRIM(GETMV('MV_LOCX012'))", "ORANGE", DESMFAM(GETMV("MV_LOCX012")))
		//OSZ1:ADDLEGEND("ALLTRIM(FQ3_FAMBEM) $ ALLTRIM(GETMV('MV_LOCX013'))", "GRAY"  , DESMFAM(GETMV("MV_LOCX013")))
		//OSZ1:ADDLEGEND("!EMPTY(FQ3_ORDEM)"                                , "RED"   , "INSUMO"                   )
	ENDIF

	OSZ1:SETFILTERDEFAULT( "FQ3_FILIAL = FQ2->FQ2_FILIAL .AND. FQ3_NUM = FQ2->FQ2_NUM .AND. FQ3_ASF = FQ2->FQ2_ASF " )
	OSZ1:DISABLEDETAILS()
	
	aadd( AROTINA, { STR0002 , "AXPESQUI"  , 0 , 1 , 0 , NIL } ) //"PESQUISAR"
	aadd( AROTINA, { STR0003 , "AXALTERA"  , 0 , 4 , 0 , NIL } ) //"MANUTEN��O"
	aadd( AROTINA, { STR0004 , "AXVISUAL"  , 0 , 2 , 0 , NIL } ) //"VISUALIZAR"
	aadd( AROTINA, { STR0026 , "LOCA02905" , 0 , 5 , 0 , NIL } ) //"EXCLUIR"
	aadd( AROTINA, { STR0011 , "LOCA02902" , 0 , 7 , 0 , .F. } ) //"LEGENDA"

	//PONTO DE ENTRADA para manipular as op��es 
	If ExistBlock("LOCA029C")	// Ponto de Entrada para inclusao de botoes no custo extra.
		AROTINA := ExecBlock("LOCA029C",.t.,.t.,{AROTINA})
	Endif

	osz1:activate()

return

// Controle da Legenda
function loca02902()
local _alegenda := {}

	if ST6->( FIELDPOS("T6_XGRUPO") ) > 0								// --> EXCLUSIVO TECNOGERA - O PADR�O UTILIZA OS PAR�METROS MV_LOCX009, 02, 03, 04 E 05.
		AADD(_ALEGENDA, {"BR_VERDE"  , DESMFAM("1")}) 					// GERADOR
		AADD(_ALEGENDA, {"BR_AZUL"   , DESMFAM("2")}) 					// CABO
		AADD(_ALEGENDA, {"BR_VIOLETA", DESMFAM("3")}) 					// QTA/QTM
		AADD(_ALEGENDA, {"BR_LARANJA", DESMFAM("4")}) 					// TRANSFORMADOR
		AADD(_ALEGENDA, {"BR_CINZA"  , DESMFAM("5")}) 					// ACESS�RIO
	else
		//AADD(_ALEGENDA, {"BR_VERDE"  , DESMFAM(GETMV("MV_LOCX009"))}) 	// GERADOR
		//AADD(_ALEGENDA, {"BR_AZUL"   , DESMFAM(GETMV("MV_LOCX010"))}) 	// CABO
		//AADD(_ALEGENDA, {"BR_VIOLETA", DESMFAM(GETMV("MV_LOCX011"))}) 	// QTA/QTM
		//AADD(_ALEGENDA, {"BR_LARANJA", DESMFAM(GETMV("MV_LOCX012"))}) 	// TRANSFORMADOR
		//AADD(_ALEGENDA, {"BR_CINZA"  , DESMFAM(GETMV("MV_LOCX013"))}) 	// ACESS�RIO
	endif
		
	brwlegenda( STR0027, STR0011, _ALEGENDA) //"STATUS"###"LEGENDA"

return nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���PROGRAMA  � DESMFAM   � AUTOR � IT UP BUSINESS     � DATA � 11/08/2016 ���
�������������������������������������������������������������������������͹��
���DESCRICAO � DESMEMBRA O CONTE�DO SEPARADO POR PONTO E VIRGULA EM ARRAY.���
�������������������������������������������������������������������������͹��
���USO       � ESPECIFICO GPO                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function DESMFAM(_CFAMILIA)
local _cret     := ""
local _cquery   := ""
local _afamilia := {}
local _nx

	DEFAULT _cfamilia := ""

	IF ST6->( fieldpos("T6_XGRUPO") ) > 0								// --> EXCLUSIVO TECNOGERA - O PADR�O UTILIZA OS PAR�METROS MV_LOCX009, 02, 03, 04 E 05.
		_cquery := " SELECT T6_CODFAMI , T6_NOME"
		_cquery += " FROM " + retsqlname("ST6") + " ST6"
		_cquery += " WHERE  T6_FILIAL  = '" + xfilial("ST6") + "'"
		_cquery += " AND  T6_XGRUPO  = '" + _cfamilia + "'"
		_cquery += " AND  ST6.D_E_L_E_T_ = ''"
		_cquery += " ORDER BY T6_CODFAMI "
		IF select("TRBST6") > 0
			TRBST6->(dbclosearea())
		ENDIF
		_cQuery := changequery(_cQuery) 
		tcquery _cquery new alias "TRBST6"

		while TRBST6->(!eof())
			if empty(_cret)
				_cret := alltrim(TRBST6->T6_NOME)
			else
				_cret += "/" + alltrim(TRBST6->T6_NOME)
			endif
			TRBST6->(dbskip())
		enddo
		TRBST6->(dbclosearea())
	else
		_afamilia := strtokarr(alltrim(_cfamilia),";")
		
		for _nx := 1 to len(_afamilia)
			if empty(_cret)
				_cret := alltrim(posicione("ST6",1,xfilial("ST6") + _afamilia[_nx],"T6_NOME"))
			else
				_cret += "/" + alltrim(posicione("ST6",1,xfilial("ST6") + _afamilia[_nx],"T6_NOME"))
			endif
		next
	endif

return _cret

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������������������������������������
���programa  � loc051a   � autor � it up business     � data � 07/11/2016 ���
���������������������������������������������������������������������������
���descricao � emiss�o nf para chamar as rotina de remessa e retorno.     ���
���          � chamada: menu - "emiss�o nf"                               ���
���������������������������������������������������������������������������
���uso       � especifico gpo                                             ���
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
function loca02903(calias,nreg,nopc)
local aareaza0 := FP0->(getarea())
local lret     := .t.
local lsz1     := .f.
local lformpropr	:= .f. //jos� eul�lio - 03/06/2022 - sigaloc94-346 - #27421 - nf de retorno apresentar o formul�rio quando for formul�rio pr�prio = sim.

	if lret
		if FP0->(msseek( xfilial("FP0")+FQ2->FQ2_PROJET ) )
			if FQ2->FQ2_TPROMA == "0" 							// romaneio de remessa
				if loca02906(FQ2->FQ2_NUM,FQ2->FQ2_TPROMA) 	// valida se o romaneio teve nf vinculada
					if lret
						LOCA010(.T.)
					endif
				endif
			elseif FQ2->FQ2_TPROMA == "1" 						// romaneio de retorno
				if LOCA02906(FQ2->FQ2_NUM,FQ2->FQ2_TPROMA) 	// valida se o romaneio teve nf vinculada
					if lret

						// verificar se existe z1 sem nota emitida
						lsz1 := .f.
						FQ3->(dbsetorder(1))
						FQ3->(dbseek(xfilial("FQ3")+FQ2->FQ2_NUM))
						while !FQ3->(eof()) .and. FQ3->FQ3_FILIAL == xfilial("FQ3") .and. FQ3->FQ3_NUM == FQ2->FQ2_NUM
							if empty(FQ3->FQ3_NFRET)
								lsz1 := .t.
								exit
							endif
							FQ3->(dbskip())
						enddo
						if !lsz1
							msgalert(STR0028,STR0029) //"todos os romaneios j� foram processados."###"aten��o!"
							restarea(aareaza0)
							return
						endif

						_nzuc := LOCA02909()
						if _nzuc > 0
							if empty(getmv("MV_LOCX299",,"")) // indica se existe integracao com o rm - frank 04/10/22
								lformpropr := msgyesno(STR0030 , STR0031)  //"retorno da nf ser� via formul�rio pr�prio?"###"gpo - loc05102.prw"
								LOCA01101(calias,nreg,nopc,fq2->fq2_num,lformpropr)
							else
								LOCA76R()
							endif
						endif
					endif
				endif
			endif
		endif
	endif

	restarea(aareaza0)

return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������������������������������������
���programa  � marcarregi� autor � it up business     � data � 30/06/2007 ���
���������������������������������������������������������������������������
���descricao � fun��o auxiliar do listbox, serve para marcar e desmarcar  ���
���          � os itens.                                                  ���
���������������������������������������������������������������������������
���uso       � especifico gpo                                             ���
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

static function marcarregi(ltodos)
local ni        := 0 
local lmarcados := _asz1[ofilos:nat,1]

	if ltodos
		lmarcados := ! lmarcados
		for ni := 1 to len(_asz1)
			_asz1[ni,1] := lmarcados
		next ni 
	else
		_asz1[ofilos:nat,1] := !lmarcados
	endif

	ofilos:refresh()
	odlgfil:refresh()
	
return nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������������������������������������
���programa  � expedins  � autor � it up business     � data � 11/04/2017 ���
���������������������������������������������������������������������������
���descricao � gera o pedido de venda para o romaneio posicionado         ���
���������������������������������������������������������������������������
���uso       � especifico gpo                                             ���
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function expedins(_acabec,_aitens,lnfrembe)
	if len(_acabec) > 0 .and. len(_aitens) > 0
		incproc(STR0078) //"aguarde... gerando pedido de venda e faturando..."
		msexecauto({|x,y,z| mata410(x,y,z)},_acabec,_aitens,3)
		if lmserroauto
			mostraerro()
			rollbacksx8()
			return .f.
		else
			_cpedido := cnumsc5
			confirmsx8()
		endif
	else
		msgstop(STR0079 , STR0031)  //"nao existem registros para gera��o do pedido!"###"gpo - loc05102.prw"
		return .f. 
	endif 
return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������������������������������������
���programa  � grvnfins  � autor � it up business     � data � 11/04/2017 ���
���������������������������������������������������������������������������
���descricao � libera o pedido de venda e gera o documento de sa�da.      ���
���������������������������������������������������������������������������
���uso       � especifico gpo                                             ���
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function grvnfins( _cpedido , ctesrf , cteslf , cserie ) 
// Removido temporariamente
return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������������������������������������
���programa  � xsc5num   � autor � it up business     � data � 04/08/2016 ���
���������������������������������������������������������������������������
���descricao � valida o pr�ximo numero do pv					          ���
���������������������������������������������������������������������������
���uso       � especifico gpo                                             ���
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function xsc5num()
	SC5->( dbsetorder(1) )
	while .t.
		cnumsc5 := getsxenum("SC5","C5_NUM")
		if ! SC5->( dbseek( xfilial("SC5") + cnumsc5 ) )
			exit 
		endif 
		confirmsx8() 
	enddo 	
return cnumsc5 



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������������������������������������
���programa  � xa1ordem  � autor � it up business     � data � 04/08/2016 ���
���������������������������������������������������������������������������
���descricao � verifica a ordem dos campos no x3				          ���
���������������������������������������������������������������������������
���uso       � especifico gpo                                             ���
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static function xa1ordem(ccampo)
local aareasx3 := (locxconv(1))->(getarea()) 
	//dbselectarea("sx3") 
	(locxconv(1))->(dbsetorder(2))
	(locxconv(1))->(dbseek(ccampo)) 
	cret := &(locxconv(4))
	restarea(aareasx3)
return cret 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������������������������������������
���programa  � delins    � autor � it up business     � data � 24/04/2017 ���
���������������������������������������������������������������������������
���descricao � verifica se � possivel deletar o registro    	          ���
���          � chamada: menu - "excluir"                                  ���
���������������������������������������������������������������������������
���uso       � especifico gpo                                             ���
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
function loca02905() 
local lret 		:= .t.
Local cItem		:= FQ3->FQ3_ITEM	
Local cProd		:= FQ3->FQ3_PROD	
Local cEquip	:= FQ3->FQ3_CODBEM	
Local cAS		:= FQ3->FQ3_AS	
Local cProjFq3	:= FQ3->FQ3_PROJET	

	if empty(FQ3->FQ3_NFREM) 
		if existblock("LOCA029A")
			lret := execblock("LOCA029A" , .t. , .t. , {FQ3->(recno())}) 
		endif
		if lret
			if axdeleta("FQ3", FQ3->(recno()), 5 ) == 2
				lret := .t.
			else
				lret := .f.
			endif
		endif
		if existblock("LOCA029B")
			execblock("LOCA029B" , .T. , .T. , {lRet,cItem,cProd,cEquip,cAS,cProjFq3}) 
		endif
	else 
		msgstop(STR0082 , STR0031)  //"n�o � possivel deletar o insumo, pois j� tem nf remessa gerada."###"gpo - loc05102.prw"
	endif   

return

/*
consultoria  : it up business 
desenvolvedor: it up business 
descri��o    : verifica se n�o tem nota de remessa ou retorno gerada para o romaneio. 
retorno      : .t. = n�o tem nota de retorno e/ou remessa
.f. = tem nota de retorno e/ou remessa
*/              

function loca02906(cnumroma,ctipo)
local lret := .f.

	dbselectarea("FQ3")
	FQ3->(dbsetorder(1)) // fq3_filial + fq3_num 
	if FQ3->(dbseek(xfilial("FQ3")+FQ2->FQ2_NUM))
		dbselectarea("FPA")
		dbsetorder(3)
		while FQ3->(!eof()) .and. FQ3->FQ3_NUM == FQ2->FQ2_NUM
			dbselectarea("FPA")
			FPA->(dbsetorder(3)) 	// fpa_filial+fpa_as+fpa_viagem
			if FPA->(dbseek(xfilial("FPA")+FQ3->FQ3_AS+FQ3->FQ3_VIAGEM))
				if ctipo == "0"
					if empty(FPA->FPA_NFREM)
						lret := .t.
					else
						aviso("",STR0083) //"romaneio com nota de remessa gerada."
						return lret
					endif
				elseif ctipo == "1"
					if empty(FPA->FPA_NFRET)
						lret := .t.
					else
						aviso("",STR0084) //"romaneio com nota de retorno gerada."
						return lret
					endif
				endif
			else
				msgalert(STR0085 , STR0031) //"n�o encontrado loca��o para o romaneio informado."###"gpo - loc05102.prw"
				return lret
			endif
			FQ3->(dbskip())
		enddo
	else
		msgalert(STR0086 , STR0031) //"n�o existe item vinculado ao romaneio"###"gpo - loc05102.prw"
		lret := .f.
	endif

return lret


// FRANK Z FUGA EM 25/09/2020
// ROTINA PARA APRESENTACAO DAS LEGENDAS
function loca02907()
local _alegenda := {}

	aadd(_alegenda , {"BR_VERDE", STR0087})  //"romaneio de expedi��o com nf"
	aadd(_alegenda , {"BR_AMARELO", STR0088})  //"romaneio de expedi��o sem nf"
	aadd(_alegenda , {"BR_AZUL", STR0089 })  //"romaneio de retorno com nf"
	aadd(_alegenda , {"BR_VERMELHO", STR0090})  //"romaneio de retorno sem nf"
	If ExistBlock("LOCA029E") //Frank Z Fuga - 18/05/2022 - Chamado 29564 - Novas legendas
		_aLegenda := ExecBlock("LOCA029E" , .T. , .T. , {_aLegenda}) 
	EndIf

	BRWLEGENDA(STR0027 , STR0011 , _ALEGENDA)  //"STATUS"###"LEGENDA"

return


// FRANK ZWARG FUGA - 25/09/2020
// VERIFICAR A LEGENDA PARA A MBROWSE
FUNCTION LOCA02908()
LOCAL _NCOR
LOCAL _AAREA := GETAREA()
// 1 = ROMANEIO EXPEDICAO COM NF
// 2 = ROMANEIO EXPEDICAO SEM NF
// 3 = ROMANEIO RETORNO COM NF
// 4 = ROMANEIO RETORNO SEM NF

	//fpa->(dbsetorder(2))
	//fpa->(dbseek(xfilial("fpa")+fq2->(fq2_projet+fq2_obra+fq2_asf)))

	FQ3->(dbsetorder(1))
	FQ3->(dbseek(xfilial("FQ3")+FQ2->FQ2_NUM))
	if FQ2->FQ2_TPROMA == "0"
		_ncor := 2 // sem nota
	endif
	if FQ2->FQ2_TPROMA == "1"
		_ncor := 4 // sem nota
	endif

	while !FQ3->(eof()) .and. FQ3->FQ3_FILIAL == xfilial("FQ3") .and. FQ2->FQ2_NUM == FQ3->FQ3_NUM
		if !empty(FQ3->FQ3_NFREM) .and. FQ2->FQ2_TPROMA == "0"
			_ncor := 1 // com nota
		endif
		if !empty(FQ3->FQ3_NFRET) .and. FQ2->FQ2_TPROMA == "1"
			_ncor := 3 // com nota
		endif

		FQ3->(dbskip())
	enddo

	If ExistBlock("LOCA029D") //Frank Z Fuga - 18/05/2022 - Chamado 29564 - Novas legendas
		_nCor := ExecBlock("LOCA029D" , .T. , .T. , {_nCor}) 
	EndIf
	restarea(_aarea)

RETURN _NCOR

// identificacao do conjunto transportador para a emissao da nota
// frank z fuga - 02/11/20
function loca02909()
local njanelaa	:= 385 
local njanelal	:= 1103
local _nret     := 0
local ofilbut
local nopc      := 0
local ocanbut
local nlbtaml	:= 540	
local nlbtama	:= 145	
//local lmark     := .f.
local ook    	:= loadbitmap(getresources(),"LBOK")
local ono       := loadbitmap(getresources(),"LBNO") 
local _nx
local _lpode    := .f.
//local nopc      := "0"

private _aconj	:= {}
private ofilconj
private odlgconj

	FQ7->(dbsetorder(2))
	FQ7->(dbseek(xfilial("FQ7")+FQ2->FQ2_PROJET+FQ2->FQ2_OBRA))
	while !FQ7->(eof()) .and. FQ7->(FQ7_FILIAL+FQ7_PROJET+FQ7_OBRA) == XFILIAL("FQ7")+FQ2->FQ2_PROJET+FQ2->FQ2_OBRA
		if FQ7->FQ7_TPROMA == "1" .and. empty(FQ7->FQ7_NFRET)

			// card 398 - sprint bug - frank em 14/07/2022
			if FQ7->FQ7_VIAGEM <> FQ2->FQ2_VIAGEM
				FQ7->( dbskip() )
				loop
			endif

			aadd(_aconj,{ .f.,;
			FQ7->FQ7_PROJET,;
			FQ7->FQ7_OBRA,;
			FQ7->FQ7_SEQGUI,;
			FQ7->FQ7_ITEM,;
			FQ7->FQ7_CC,;
			FQ7->FQ7_PRECUS,;
			FQ7->FQ7_VIAGEM,;
			FQ7->FQ7_DTLIM,;
			FQ7->FQ7_LCCORI,;
			FQ7->FQ7_LCLORI,;
			FQ7->FQ7_LOCCAR,;
			FQ7->FQ7_LCCDES,;
			FQ7->FQ7_LCLDES,;
			FQ7->FQ7_LOCDES,;
			FQ7->FQ7_VIAORI,;
			FQ7->(recno())})

		endif
		FQ7->(dbskip())
	enddo

	if len(_aconj) == 0
		msgalert(STR0091,STR0029) // "nenhum conjunto transportador foi localizado."###"aten��o!"
		return 0
	endif

	define msdialog odlgconj title STR0092 from 010,005 to njanelaa,njanelal pixel // of omainwnd "sele��o do conjunto transportador"

	    @ 0.5,0.7 listbox ofilconj fields header  " ", STR0035, STR0093, STR0094, STR0095, STR0096, STR0097, STR0098, STR0099, STR0100, STR0101, STR0102, STR0103, STR0104, STR0105, STR0106, STR0107 size nlbtaml,nlbtama on dblclick (marcar2()) 
		//"projeto"###"obra"###"loca��o"###"item"###"centro custo"###"prev.custo"###"viagem"###"data limite"###"cliente origem"###"loja origem"###"carregamento"###"cliente destino"###"loja destino"###"descarregamento"###"viagem origem"###"registro"

	    ofilconj:setarray(_aconj)
	    ofilconj:bline := {|| { if( _aconj[ofilconj:nat,1],OOK,ONO),;   
	    _aconj[ofilconj:nat,2],;   	 	   
		_aconj[ofilconj:nat,3],;
		_aconj[ofilconj:nat,4],;
		_aconj[ofilconj:nat,5],;
		_aconj[ofilconj:nat,6],;
		_aconj[ofilconj:nat,7],;
		_aconj[ofilconj:nat,8],;
		_aconj[ofilconj:nat,9],;
		_aconj[ofilconj:nat,10],;
		_aconj[ofilconj:nat,11],;
		_aconj[ofilconj:nat,12],;
		_aconj[ofilconj:nat,13],;
		_aconj[ofilconj:nat,14],;
		_aconj[ofilconj:nat,15],;
		_aconj[ofilconj:nat,16],;
		_aconj[ofilconj:nat,17]}}
		
		@ 172,007 button ofilbut prompt STR0108 size 50,12 of odlgconj pixel ;  //"sele��o"
		action ( iif(msgyesno(oemtoansi(STR0109) , STR0092) , ;  //"deseja mesmo gerar nf retorno para este conjunto transportador?"###"sele��o do conjunto transportador"
		nopc := "1"  , ; 
		nopc := "0") , ; 
		odlgconj:end() ) 
	    @ 172,062 button ocanbut prompt STR0053 size 50,12 of odlgconj pixel action (nopc := "0", odlgconj:end()) //"cancelar"
    activate msdialog odlgconj centered

	if nopc == "1"
		_lpode := .f.
		for _nx := 1 to len(_aconj)
			if _aconj[_nx,1]
				_lpode := .t.
				_nret := _aconj[_nx][17]
				exit
			endif
		next
		if !_lpode
			msgalert(STR0110,STR0029) //"nenhum conjunto transportador foi selecionado."###"aten��o!"
			_nret := 0
		endif
	else
		msgalert(STR0111, STR0029) //"emiss�o da nota cancelada."###"aten��o!"
		_nret := 0
	endif
    
return _nret

// CONTROLE DA SELECAO DOS CONJUNTOS TRANSPORTADORES
static function marcar2()
local lmarcados := _aconj[ofilconj:nat,1]
local _nx       
local _lpode    := .t.

	for _nx := 1 to len(_aconj)
		if _aconj[_nx,1] .and. ofilconj:nat <> _nx
			_lpode := .f.
		endif
	next

	if _lpode
		_aconj[ofilconj:nat,1] := !lmarcados
	else
		msgalert(STR0112, STR0029) //"j� existe uma sele��o de um conjunto transpordador."###"aten��o!"
		_aconj[ofilconj:nat,1] := .f.
	endif

	ofilconj:refresh()
	odlgconj:refresh()
	
return nil

/*/LOCA02910
Retorna o peso dos itens do Romaneio
author Jose Eulalio
since 01/06/2022
/*/
Function LOCA02910(_LROMANEIO)
Local nPeso		:= 0
Local nPesBru	:= 0
Local aArea		:= GetArea()

	Default _LROMANEIO	:= .F.

	If _LROMANEIO 
		// por ser romaneio ja esta posicionado na FQ2
		// rotina chamada do loca010
		FQ3->(dbSetOrder(1))
		FQ3->(dbSeek(xFilial("FQ3")+FQ2->FQ2_NUM))
		While !FQ3->(Eof()) .and. FQ3->(FQ3_FILIAL+FQ3_NUM) == xFilial("FQ3")+FQ2->FQ2_NUM
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+FQ3->FQ3_PROD))
			nPeso	+= FQ3->FQ3_QTD * SB1->B1_PESO
			nPesBru	+= FQ3->FQ3_QTD * SB1->B1_PESBRU
			FQ3->(dbSkip())
		EndDo
	EndIf

	RestArea(aArea)

Return {nPeso,nPesBru}

