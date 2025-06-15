#INCLUDE "loca070.ch"  
/*/{PROTHEUS.DOC} LOCA070.PRW
ITUP BUSINESS - TOTVS RENTAL
VALIDA��O DO CAMPO T9_STATUS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "TOTVS.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

FUNCTION LOCA070()
LOCAL LRET := .T.
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integra��o com M�dulo de Loca��es SIGALOC

If !lMvLocBac
	TQY->(DBSETORDER(1))
	IF TQY->(DBSEEK(XFILIAL("TQY") + ST9->T9_STATUS))
		CSTSATU := TQY->TQY_STTCTR
		IF CSTSATU == "70" .OR. CSTSATU == "00" .OR. EMPTY(CSTSATU)
			IF TQY->(DBSEEK(XFILIAL("TQY") + M->T9_STATUS))
				CSTSNEW := TQY->TQY_STTCTR
				IF CSTSNEW <> "00" .AND. !EMPTY(CSTSNEW)
					MSGALERT(STR0001 + ALLTRIM(TQY->TQY_STATUS) + " - " + ALLTRIM(TQY->TQY_DESTAT) , STR0002)  //"N�O � POSS�VEL ALTERAR PARA O STATUS "###"GPO - VALSTST9.PRW"
					LRET := .F.
				ENDIF
			ENDIF
		ENDIF
	ENDIF
else
	FQD->(DBSETORDER(1))
	IF FQD->(DBSEEK(XFILIAL("FQD") + ST9->T9_STATUS))
		CSTSATU := FQD->FQD_STAREN
		IF CSTSATU == "70" .OR. CSTSATU == "00" .OR. EMPTY(CSTSATU)
			IF FQD->(DBSEEK(XFILIAL("FQD") + M->T9_STATUS))
				CSTSNEW := FQD->FQD_STAREN
				IF CSTSNEW <> "00" .AND. !EMPTY(CSTSNEW)
					MSGALERT(STR0001 + ALLTRIM(FQD->FQD_STATQY) + " - " + ALLTRIM( Posicione("TQY",1,xFilial("TQY")+_cStsNew,"TQY_DESTAT") ) , STR0002)  //"N�O � POSS�VEL ALTERAR PARA O STATUS "###"GPO - VALSTST9.PRW"
					LRET := .F.
				ENDIF
			ENDIF
		ENDIF
	ENDIF
EndIF

RETURN LRET



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���PROGRAMA  � WHNSTST9  � AUTOR � IT UP BUSINESS     � DATA � 20/06/2019 ���
�������������������������������������������������������������������������͹��
���DESCRICAO � WHEN DO CAMPO T9_STATUS                                    ���
���          � CHAMADA: WHEN - CAMPO T9_STATUS                            ���
�������������������������������������������������������������������������͹��
���USO       � ESPECIFICO GPO                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION LOCA07001() 
LOCAL LRET := .T.
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integra��o com M�dulo de Loca��es SIGALOC

IF !lMvLocBac
	TQY->(DBSETORDER(1))
	IF TQY->(DBSEEK(XFILIAL("TQY") + ST9->T9_STATUS))
		CSTSATU := TQY->TQY_STTCTR
		IF CSTSATU <> "70" .AND. CSTSATU <> "00" .AND. !EMPTY(CSTSATU)
			LRET := .F.
		ENDIF
	ENDIF
else
	FQD->(DBSETORDER(1))
	IF FQD->(DBSEEK(XFILIAL("FQD") + ST9->T9_STATUS))
		CSTSATU := FQD->FQD_STAREN
		IF CSTSATU <> "70" .AND. CSTSATU <> "00" .AND. !EMPTY(CSTSATU)
			LRET := .F.
		ENDIF
	ENDIF
EndIF

RETURN LRET
