/*/{PROTHEUS.DOC} LOCA062.PRW  
ITUP BUSINESS - TOTVS RENTAL
GERA��O DE LOG DE FATURAMENTO
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "TOTVS.CH"   
#INCLUDE "TOPCONN.CH" 

FUNCTION LOCA062(_CFILFAT,_CPEDVEN,_CITEM,_CFILORI,_CPROJET,_CAS,_LCANCEL,_LEXCLUI)
LOCAL _AAREAOLD  := GETAREA()
/*

LOCAL _AAREASC6  := SC6->(GETAREA())
LOCAL _AAREASF2  := SF2->(GETAREA())
LOCAL _AAREAZAG  := FPA->(GETAREA())
//LOCAL _AAREAZFL  := ZFL->(GETAREA())
LOCAL _CQUERY    := ""
LOCAL _CPROCNAME := "" 
LOCAL _CORIGEM   := FUNNAME()
LOCAL _NX
Local _LOGFAT_ := EXISTBLOCK("LOGFAT_")
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integra��o com M�dulo de Loca��es SIGALOC
Local cAs := ""

DEFAULT _CFILORI   := ""
DEFAULT _CPROJET   := ""
DEFAULT _CAS       := ""
DEFAULT _LCANCEL   := .F.
DEFAULT _LEXCLUI   := .F.

_CPROCNAME := UPPER(ALLTRIM(PROCNAME(0))) 

FOR _NX := 1 TO 20
	DO CASE
	CASE UPPER(ALLTRIM(PROCNAME(_NX))) $ "LOCA021"
		_CORIGEM := "LOCA021"
		EXIT
	CASE UPPER(ALLTRIM(PROCNAME(_NX))) $ "LOCA021"
		_CORIGEM := "LOCA021"
		EXIT
	ENDCASE
NEXT _NX 

IF SELECT("TRBZFL") > 0
	TRBZFL->(DBCLOSEAREA())
ENDIF
_CQUERY := " SELECT   ZFL.R_E_C_N_O_ ZFLRECNO "                  + CRLF
_CQUERY += " FROM " + RETSQLNAME("ZFL") + " ZFL "                + CRLF
_CQUERY += " WHERE    ZFL.ZFL_FILIAL = '" + XFILIAL("ZFL") + "'" + CRLF
_CQUERY += "   AND    ZFL.ZFL_FILFAT = '" + _CFILFAT       + "'" + CRLF
_CQUERY += "   AND    ZFL.ZFL_NUMPED = '" + _CPEDVEN       + "'" + CRLF
_CQUERY += "   AND    ZFL.ZFL_ITEMPV = '" + _CITEM         + "'" + CRLF
_CQUERY += "   AND    ZFL.D_E_L_E_T_ = ''"                       + CRLF
_CQUERY += " ORDER BY ZFL_CANCEL , ZFL_NUMPED DESC , ZFL_ITEMPV , ZFLRECNO DESC " 
TCQUERY _CQUERY NEW ALIAS "TRBZFL"

DBSELECTAREA("ZFL")
ZFL->(DBSETORDER(1))

IF TRBZFL->(EOF()) .AND. !_LCANCEL .AND. !_LEXCLUI

	IF RECLOCK("ZFL",.T.)
		ZFL->ZFL_FILIAL := XFILIAL("ZFL")
		ZFL->ZFL_FILFAT := _CFILFAT
		ZFL->ZFL_NUMPED := _CPEDVEN
		ZFL->ZFL_ITEMPV := _CITEM

		DBSELECTAREA("FPA")
		FPA->(DBSETORDER(6))
		IF FPA->(DBSEEK(_CFILORI + _CPROJET + _CAS)) .AND. !EMPTY(ALLTRIM(_CPROJET))
			ZFL->ZFL_FILORI := FPA->FPA_FILIAL
			ZFL->ZFL_PROJET := FPA->FPA_PROJET
			ZFL->ZFL_AS     := FPA->FPA_AS
		ENDIF
		
		DBSELECTAREA("SC6")
		SC6->(DBSETORDER(1))
		IF SC6->(DBSEEK(_CFILFAT + _CPEDVEN + _CITEM))
		
			ZFL->ZFL_PRODUT := SC6->C6_PRODUTO
			ZFL->ZFL_VLUNIT := SC6->C6_PRCVEN
			ZFL->ZFL_QUANT  := SC6->C6_QTDVEN
			ZFL->ZFL_VALOR  := SC6->C6_VALOR

			//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
			If lMvLocBac
				ZFL->ZFL_CODBEM := FPA->FPA_GRUA
				FPZ->(dbSetOrder(1))
				If FPZ->(dbSeek(xFilial("SC6") + SC6->C6_NUM))
					ZFL->ZFL_AS := FPZ->FPZ_AS
					cAs := FPZ->FPZ_AS
				EndIf
			Else
				ZFL->ZFL_CODBEM := SC6->C6_XBEM
				cAs := SC6->C6_XAS
			EndIf
			
			DBSELECTAREA("SF2")
			SF2->(DBSETORDER(1))
			IF SF2->(DBSEEK(SC6->C6_FILIAL + SC6->C6_NOTA + SC6->C6_SERIE))
				ZFL->ZFL_NOTA   := SF2->F2_DOC
				ZFL->ZFL_SERIE  := SF2->F2_SERIE
				ZFL->ZFL_EMISSA := SF2->F2_EMISSAO
			ENDIF
			
			IF EMPTY(ALLTRIM(ZFL->ZFL_AS))
				ZFL->ZFL_AS := cAs
			ENDIF
		ENDIF
		
		//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
		If lMvLocBac
			ZFL->ZFL_TIPFAT := ALLTRIM(GETADVFVAL("TQY", "TQY_TIPFAT",_CFILFAT + _CPEDVEN,1,""))
		Else
			ZFL->ZFL_TIPFAT := ALLTRIM(GETADVFVAL("SC5", "C5_XTIPFAT",_CFILFAT + _CPEDVEN,1,""))
		EndIf
		
		ZFL->ZFL_USERID := __CUSERID
		ZFL->ZFL_USER   := USRRETNAME(__CUSERID)
		ZFL->ZFL_ORIGEM := _CORIGEM
		ZFL->ZFL_DATA   := DATE()
		ZFL->ZFL_HORA   := TIME()
		ZFL->ZFL_CANCEL := STOD("")
	
		ZFL->(MSUNLOCK())
	ENDIF
		
	IF _LOGFAT_ //EXISTBLOCK("LOGFAT_")
		//U_LOGFAT_()
		EXECBLOCK("LOGFAT_" , .T. , .T. , {}) 
	ENDIF
	
ELSE
	
	WHILE TRBZFL->(!EOF())
	
		ZFL->(DBGOTO(TRBZFL->ZFLRECNO))
		
		IF _LEXCLUI
			IF RECLOCK("ZFL",.F.)
				ZFL->(DBDELETE())
			
				ZFL->(MSUNLOCK())
			ENDIF
		ELSE
			IF RECLOCK("ZFL",.F.)
				IF EMPTY(ALLTRIM(ZFL->ZFL_PROJET)) .AND. !EMPTY(ALLTRIM(_CPROJET))
					DBSELECTAREA("FPA")
					FPA->(DBSETORDER(6))
					IF FPA->(DBSEEK(_CFILORI + _CPROJET + _CAS))
						ZFL->ZFL_FILORI := FPA->FPA_FILIAL
						ZFL->ZFL_PROJET := FPA->FPA_PROJET
						ZFL->ZFL_AS     := FPA->FPA_AS
						ZFL->ZFL_CODBEM := FPA->FPA_GRUA
					ENDIF
				ENDIF
				
				IF !EMPTY(ALLTRIM(ZFL->ZFL_NOTA)) .AND. _LCANCEL
					ZFL->ZFL_CANCEL := GETADVFVAL("SFT", "FT_DTCANC",ZFL->ZFL_FILFAT + "S" + ZFL->ZFL_SERIE + ZFL->ZFL_NOTA,1,"")
				ENDIF
				
				DBSELECTAREA("SC6")
				SC6->(DBSETORDER(1))
				IF SC6->(DBSEEK(_CFILFAT + _CPEDVEN + _CITEM))
					ZFL->ZFL_PRODUT := SC6->C6_PRODUTO
					//ZFL->ZFL_CODBEM := SC6->C6_XBEM
					ZFL->ZFL_VLUNIT := SC6->C6_PRCVEN
					ZFL->ZFL_QUANT  := SC6->C6_QTDVEN
					ZFL->ZFL_VALOR  := SC6->C6_VALOR
			
					IF !EMPTY(ALLTRIM(SC6->C6_NOTA))
						DBSELECTAREA("SF2")
						SF2->(DBSETORDER(1))
						IF SF2->(DBSEEK(SC6->C6_FILIAL + SC6->C6_NOTA + SC6->C6_SERIE))
							ZFL->ZFL_NOTA   := SF2->F2_DOC
							ZFL->ZFL_SERIE  := SF2->F2_SERIE
							ZFL->ZFL_EMISSA := SF2->F2_EMISSAO
						ENDIF
					ENDIF
				
					IF EMPTY(ALLTRIM(SC6->C6_NOTA))
						IF !EMPTY(ALLTRIM(ZFL->ZFL_NOTA)) .AND. _LCANCEL
							ZFL->ZFL_CANCEL := GETADVFVAL("SFT", "FT_DTCANC",ZFL->ZFL_FILFAT + "S" + ZFL->ZFL_SERIE + ZFL->ZFL_NOTA,1,"")
						ENDIF
					ELSE
						ZFL->ZFL_CANCEL := STOD("")
					ENDIF
				ENDIF
				
				ZFL->ZFL_USERID := __CUSERID
				ZFL->ZFL_USER   := USRRETNAME(__CUSERID)
				ZFL->ZFL_DATA   := DATE()
				ZFL->ZFL_HORA   := TIME()
			
				ZFL->(MSUNLOCK())
			ENDIF
			
			IF _LOGFAT_ //EXISTBLOCK("LOGFAT_")
				//U_LOGFAT_()
				EXECBLOCK("LOGFAT_" , .T. , .T. , {}) 
			ENDIF
		ENDIF
		
		TRBZFL->(DBSKIP())
	ENDDO

ENDIF

TRBZFL->(DBCLOSEAREA())

RESTAREA( _AAREAZFL )
RESTAREA( _AAREAZAG )
RESTAREA( _AAREASF2 )
RESTAREA( _AAREASC6 )

*/
RESTAREA( _AAREAOLD )
RETURN
