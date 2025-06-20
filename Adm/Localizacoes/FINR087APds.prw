#include "protheus.ch"
#include "Birtdataset.ch"
#include "finr087a.ch"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �FINR087APds�Autor  �Jesus Pe�aloza         �Data  �31/05/14  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Data set de Pagos de Recibos de Cobro en formato birt        ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                             ���
��������������������������������������������������������������������������Ĵ��
���        ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
��������������������������������������������������������������������������Ĵ��
���Programador �Data    �BOPS   � Motivo da Alteracao                      ���
��������������������������������������������������������������������������Ĵ��
���            �        �       �                                          ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
dataset F087Pds
	title STR0026 //"Pagos - Recibos de Cobro"
	description STR0026 //"Pagos - Recibos de Cobro"
	PERGUNTE "FINR087A"
columns
	define column RECIB like EL_RECIBO
	define column SERIE like EL_SERIE
	define column BANCO like A6_NOME
	define column NUMER type character size 30   label STR0027 //"Numero"
	define column IMPOR type character size 20   label STR0028 //"Importe"
	define column IMPTO type character size 20   label STR0029 //"Importe Pagos"
	If cPaisLoc == 'ARG'
		define column REVIS type character size 20  label STR0014 //"Revision"
	EndIf

If cPaisLoc == 'ARG'
	define query "SELECT RECIB, SERIE, BANCO, NUMER, IMPOR, IMPTO, REVIS FROM %WTable:1% "
Else
	define query "SELECT RECIB, SERIE, BANCO, NUMER, IMPOR, IMPTO FROM %WTable:1% "
EndIf

process dataset

	Local cWTabAlias
	Local cnt       := 0
	Local lVersao   := .F.
	Local cReci     := ''
	Local cRecf     := ''
	Local cSerie	  := ''
	Local cRevision := ''
	Local cRevi     := ''
	Local cRevf     := ''
	Local cSerief   := ''
	Local cRecibo   := ''
	Local cPagBan   := ''
	Local cPagNum   := ''
	Local cPagImp   := ''
	Local nTotalf   := 0
	Local nTotalfa  := 0
	Local cQuery    := ''
	Local cImpor    := ''
	Local cCheque   := ''
	Local cEfecti   := ''
	Local cTransf   := ''
	Local cTempF    := CriaTrab(Nil, .F.)

	If ::isPreview()
	Endif


	IF cPaisLoc == 'MEX'
		cReci  := self:execParamValue("MV_PAR01")
		cRecf  := self:execParamValue("MV_PAR02")
		cSerie := self:execParamValue("MV_PAR03")
	else
		cReci  := self:execParamValue("MV_PAR01")
		cRecf  := self:execParamValue("MV_PAR02")
		cRevi  := self:execParamValue("MV_PAR03")
		cRevf  := self:execParamValue("MV_PAR04")
		cSerie := self:execParamValue("MV_PAR05")

		dbSelectArea("SEL")
		If SEL->(FieldPos("EL_VERSAO")) > 0
			lVersao := .T.
		EndIf
	EndIf

	cQuery := "SELECT EL_RECIBO, EL_SERIE, EL_TIPODOC, EL_NUMERO, EL_VALOR, EL_BCOCHQ, EL_AGECHQ, EL_CTACHQ, "
	If lVersao
		cQuery += "EL_VERSAO, "
	EndIf
	cQuery += "EL_CLIORIG, EL_LOJORIG , EL_BANCO, EL_AGENCIA, EL_CONTA "
	cQuery += "FROM "+RetSqlName("SEL")+" SEL, "+RetSqlName("SA1")+" SA1 "
	cQuery += "WHERE EL_CLIORIG = A1_COD AND EL_LOJORIG = A1_LOJA "
	cQuery += "AND EL_FILIAL = '"+xFilial("SEL")+"' "
	cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery += "AND EL_RECIBO BETWEEN '"+cReci+"' AND '"+cRecf+"' AND EL_SERIE = '"+cSerie+"' "
	If lVersao
		cQuery += "AND EL_VERSAO BETWEEN '"+cRevi+"' AND '"+cRevf+"' "
	EndIf
	cQuery += "AND EL_TIPODOC NOT IN ('TB', 'RA', 'RS', 'RI', 'RB', 'RG') "
	cQuery += "AND SEL.D_E_L_E_T_ = '' "
	cQuery += "AND SA1.D_E_L_E_T_ = '' "
	cQuery += "ORDER BY EL_RECIBO, EL_NUMERO "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempF,.T.,.T.)
	TCSetField(cTempF, "EL_EMISSAO", "D")
	TCSetField(cTempF, "EL_DTVCTO", "D")

   cWTabAlias := ::createWorkTable()
   chkFile(cTempF)
	(cTempF)->(dbGoTop())

	dbSelectArea("SA6")
	SA6->(dbSetOrder(1))
	While (!(cTempF)->(EOF()))
		cRecibo  := (cTempF)->EL_RECIBO
		cSerief  := (cTempF)->EL_SERIE
		cPagBan := ''
		cPagNum := ''
		cPagImp := ''
		cCheque  := ''
		cEfecti  := ''
		cTransf  := ''
		cRevision := ''
		nTotalf  := 0
		nTotalfa := 0
		While ((cTempF)->EL_RECIBO == cRecibo .and. !(cTempF)->(EOF()))
			cnt++
			If SA6->(dbSeek(xFilial("SA6")+(cTempF)->EL_BANCO+(cTempF)->EL_AGENCIA+(cTempF)->EL_CONTA))
				cPagBan := Alltrim(SA6->A6_NOME)
			EndIf

			If lVersao
				cRevision := (cTempF)->EL_VERSAO
			EndIf
			cPagNum := Alltrim((cTempF)->EL_TIPODOC)+" "+Alltrim((cTempF)->EL_NUMERO)
			nTotalf  := (cTempF)->EL_VALOR
			nTotalfa += nTotalf
			cPagImp := Alltrim(Transform(nTotalf, "@E 999,999,999.99"))
			cImpor := Extenso(nTotalfa)
			RecLock(cWTabAlias, .T.)
			(cWTabAlias)->RECIB := cRecibo
			(cWTabAlias)->SERIE := cSerief
			(cWTabAlias)->BANCO := cPagBan
			(cWTabAlias)->NUMER := cPagNum
			(cWTabAlias)->IMPOR := cPagImp
			(cWTabAlias)->IMPTO := Transform(nTotalfa, "@E 999,999,999.99")
			If lVersao
				(cWTabAlias)->REVIS := cRevision
			EndIf
			(cWTabAlias)->(MsUnlock())
			(cTempF)->(dbSkip())
		EndDo
	EndDo
	(cTempF)->(dbCloseArea())
Return .T.
