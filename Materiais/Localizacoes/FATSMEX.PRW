#include "Protheus.ch"
#include "topconn.ch"

 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  FATSMEX   ºAutor  ³Luis Eduardo Enríquez Mata                        º Data ³  18/10/2022   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ XML de Documentos Electrónicos de Entrada                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT - Facturación                                                                     º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                       ACTUALLIZACIONES SUFRIDAS DESDE LA CONStrUCCIÓN INICIAL                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador           ³ Data       ³ BOPS        ³ Motivo de Alteración                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                      ³ 99/99/9999 ³ DMINA-XXXXX ³                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} FATSMEX
Genera el XML para Documentos de tipo Salida (NF/NDC)
@type function
@author luis.enríquez
@since 31/10/2022
@version 1.0
@param cFilSF2, caracter, Filial de tabla SF2
@param cSerie, caracter, Serie del Documento
@param cDocumento, caracter, Número de Folio del Documento
@param cCliente, caracter, Código de Cliente del Documento
@param cLoja, caracter, Código de Tienda del Documento
@return Nil
@example
FATSMEX(cFilSF2, cSerie, cDocumento, cCliente, cLoja)
@see (Usado en FATSMEX.PRW)
/*/
Function FATSMEX(cFilSF2, cSerie, cDocumento, cCliente, cLoja)
	Local aAreaSF2:= SF2->(GetArea())
	Local cXML    := ""
	Local cFecEmi := ""
	Local cFechaD := ""
	Local cNomXML := ""
	Local lDocTras:= .F.
	Local lFacGlo := .F.
	Local lCartaP := .F.
	Local lComExt := .F.
	Local lLeyFis := .F.
	Local lGenExp := .F.
	Local lDatoT  := .F.
	Local cFormaP := ""
	Local cCtrl   := (chr(13)+chr(10))
	Local cCadOri := ""
	Local cSepara := "|"
	Local aSM0    := {}
	Local cMoeSAT := ""
	Local cSello  := ""
	Local cCert   := IIf(FindFunction("FATXMICERT"),FATXMICERT(),"")  //Leer Certidicado 
	Local nImpInc := 0
	Local nTotBon := 0
	Local cDesCondP  := ""
	Local cMetPagO   := ""
	Local nDesCPorte := 0
	Local nImpCPorte := 0
	Local aDatosRec  := {}
	Local cCFDICPG   := SuperGetMV("MV_CFDICPG", .F., "")
	Local lCompComE  := SuperGetMV("MV_CFDIEXP",.F.,.F.)
	Local lCadCon    := SuperGetMV("MV_COCONSO", .F., "") == "S"
	Local cCliRegF   := ""
	Local cAI0MPago  := ""
	Local cFilAI0    := xFilial("AI0")
	Local nDecTot    := 2
	Local cVerCFDI   := "4.0"
	Local cFPago     := ""
	Local cValSubT   := ""
	Local cMoneda    := ""
	Local cTpoCam    := ""
	Local cExporta   := "01"
	Local cDescto    := ""
	Local cTpoComp   := ""
	Local cValTot    := ""
	Local cImpLoc    := ""
	Local cComExt    := ""
	Local cLeyFis    := ""
	Local aDatosCE   := {}
	Local aDatosCli  := {}
	Local cFilSA1    := xFilial("SA1")
	Local aDetComE   := {}
	Local lCpoConUNi := SF2->(FieldPos("F2_CONUNI")) > 0
	Local cPFisica   := ""
	Local aEmiCE     := {}
	Local aF3I       := {}
	Local lFuncF3I   := FindFunction("FATXVALF3I")

	Default cFilSF2    := xFilial("SF2") 
	Default cSerie     := ""
	Default cDocumento := ""
	Default cCliente   := ""
	Default cLoja      := ""

	aSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , { "M0_CGC", "M0_NOMECOM", "M0_DSCCNA", "M0_CEPENT", "M0_ENDCOB", "M0_CODZOSE", "M0_CODMUN"} )

	DbSelectArea("SF2")
	SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If SF2->(MsSeek(cFilSF2 + cDocumento + cSerie + cCliente + cLoja))

		//Nombre del XML
		cNomXML := &(GetNewPar("MV_CFDNAF2","Lower(AllTrim(SF2->F2_ESPECIE)) + '_' + Lower(AllTrim(SF2->F2_SERIE)) + '_'  + Lower(AllTrim(SF2->F2_DOC)) + '.xml'"))

		//Documento de Traslado
		lDocTras := AllTrim(SF2->F2_TIPODOC) == "21"

		//Documento de Venta Global
		lFacGlo := SF2->F2_GLOBAL == '1'

		//Documento con Complemento de Carta Porte
		lCartaP := SF2->(ColumnPos("F2_TPCOMPL")) > 0 .And. AllTrim(SF2->F2_TPCOMPL) == "S"

		lComExt := lCompComE .And. !Empty(SF2->F2_TIPOPE)

		lDatoT := (lComExt .Or. lCartaP) .And. lDocTras

		//Documento con Complemento de Comercio Exterior
		cExporta := IIf(SF2->F2_CVEPED != "A1" .Or. Alltrim(SF2->F2_TIPOPE) == "3", "04", "02")
		lGenExp  := IIf(cExporta == "04" .And. (Empty(SF2->F2_CERORI) .Or. Empty(SF2->F2_INCOTER) .Or. Empty(SF2->F2_SUBDIV) .Or. Empty(SF2->F2_TCUSD) .Or. Empty(SF2->F2_TOTUSD)), .F., .T.)
		lComExt  := lComExt  .And. lGenExp

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		If SA1->(MsSeek(cFilSA1 + cCliente + cLoja)) 
			aAdd(aDatosCli,IIf(lDatoT,AllTrim(aSM0[1][2]),Alltrim(SA1->A1_CGC))) 
			aAdd(aDatosCli,IIf(lDatoT,AllTrim(aSM0[2][2]),Alltrim(SA1->A1_NOME)))
			aAdd(aDatosCli,IIf(lDatoT,AllTrim(aSM0[4][2]),Alltrim(SA1->A1_CEP)))
			aAdd(aDatosCli,SA1->A1_END)
			aAdd(aDatosCli,SA1->A1_NR_END)
			aAdd(aDatosCli,SA1->A1_NROINT)
			aAdd(aDatosCli,SA1->A1_BAIRRO)
			aAdd(aDatosCli,SA1->A1_MUN)
			aAdd(aDatosCli,SA1->A1_EST)
			aAdd(aDatosCli,SA1->A1_PAIS)
			aAdd(aDatosCli,SA1->A1_CEP)
			cPFisica := SA1->A1_PFISICA
		EndIf
		
		If lComExt
			aAdd(aDatosCE,SF2->F2_TRASLA) 
			aAdd(aDatosCE,SF2->F2_TIPOPE)
			aAdd(aDatosCE,SF2->F2_CVEPED) 
			aAdd(aDatosCE,SF2->F2_CERORI) 
			aAdd(aDatosCE,SF2->F2_NUMCER) 
			aAdd(aDatosCE,SF2->F2_EXPCONF) 
			aAdd(aDatosCE,SF2->F2_INCOTER) 
			aAdd(aDatosCE,SF2->F2_SUBDIV)
			aAdd(aDatosCE,SF2->F2_OBSCE)
			aAdd(aDatosCE,SF2->F2_TCUSD)
			aAdd(aDatosCE,SF2->F2_TOTUSD)
		EndIf

		//Forma de Pago
		cFormaP := IIf(SF2->(ColumnPos("F2_TPDOC")) > 0,AllTrim(SF2->F2_TPDOC),cAI0MPago)

		//Total de Bonificaciones
		nTotBon := fSumBC(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA)

		nDecTot := IIf(lDocTras,0,2)

		//Monedas
		DbSelectArea("CTO")
		CTO->(DbSetOrder(1)) //CTO_FILIAL+CTO_MOEDA
		If CTO->(MsSeek(xFilial("CTO") + Strzero(SF2->F2_MOEDA,2)))
			cMoeSAT := AllTrim(CTO->CTO_MOESAT)
		EndIf		

		//Condición de Pago
		DbSelectArea("SE4")
		SE4->(DbSetOrder(1)) //E4_FILIAL+E4_CODIGO
		If SE4->(MsSeek(xFilial("SE4") + SF2->F2_COND))
			cDesCondP := AllTrim(SE4->E4_DESCRI)
			cMetPagO  := AllTrim(SE4->E4_MPAGSAT)
		EndIf

		//Fecha
		If FindFunction("zh_FechaHoraUTC") .And. !Empty(cCFDICPG)
			cFechaD := zh_FechaHoraUTC(AllTrim(cCFDICPG),AllTrim(aSM0[4][2]),SF2->F2_EMISSAO,SF2->F2_HORA)
		Else
			cFecEmi := DtoS(SF2->F2_EMISSAO)
			cFechaD := Left(cFecEmi,4) + "-" + SubStr(cFecEmi,5,2)+ "-" + Right(cFecEmi,2)
			cFechaD += "T" + SF2->F2_HORA
		EndIf

		//Impuestos del Documento
		fImptosD(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,lDocTras,"SD2",lFacGlo,@nImpInc,lCartaP,@nDesCPorte, @nImpCPorte, @aDetComE)

		//Complementos del Cliente
		If FindFunction("FATXCOMPCL")
			FATXCOMPCL(cFilAI0,SF2->F2_CLIENTE,SF2->F2_LOJA,@cCliRegF,@cAI0MPago)
		EndIf
		
		//Geración de Cadena Original
		cCadOri := cSepara + cSepara
		//Version
		cCadOri += cVerCFDI + cSepara
		//Serie
		cCadOri += AllTrim(SF2->F2_SERIE) + cSepara
		//Folio
		cCadOri += AllTrim(SF2->F2_DOC) + cSepara
		//Fecha
		cCadOri += AllTrim(cFechaD) + cSepara
		//FormaPago
		If !lDocTras
			cFPago := IIf(lFacGlo,FormPagGlo(SF2->F2_DOC,SF2->F2_SERIE),IIf(Empty(cFormaP) .Or. cMetPagO == "PPD","99",cFormaP))
			cCadOri += cFPago + cSepara
		EndIf
		//NoCertificado
		cCadOri += AllTrim(SF2->F2_CERTFOL) + cSepara
		//CondicionesDePago
		If !lDocTras
			cCadOri += CFDCarEsp(cDesCondP) + cSepara
		EndIf
		//Subtotal
		cValSubT := AllTrim(IIf(lDocTras,Str(0),Str((SF2->(F2_VALMERC+F2_FRETE+F2_SEGURO+F2_DESPESA) + nTotBon + SF2->F2_DESCONT) - nImpInc - nDesCPorte,14,nDecTot)))
		cCadOri += cValSubT + cSepara

		//Descuento
		If !lDocTras .And. SF2->F2_DESCONT > 0
			cDescto := AllTrim(Str(SF2->F2_DESCONT,14,2))
			cCadOri +=  cDescto + cSepara
		EndIf
		
		//Moneda
		cMoneda := IIf(lDocTras,"XXX",cMoeSAT)
		cCadOri += cMoneda + cSepara

		//TipoCambio
		If !lDocTras
			cTpoCam := IIf(cMoeSAT <> "MXN", AllTrim(Str(SF2->F2_TXMOEDA,14,2)), "1")
			cCadOri += cTpoCam + cSepara
		EndIf

		//Total
		cValTot := AllTrim(IIf(lDocTras,Str(0),Str(IIf(GetSx3Cache("F2_VALBRUT","X3_DECIMAL") <= 2,SF2->F2_VALBRUT,Round(SF2->F2_VALBRUT,2)) + nTotBon - nDesCPorte,14,nDecTot)))
		cCadOri += cValTot + cSepara

		//TipoDeComprobante
		cTpoComp := IIf(AllTrim(SF2->F2_ESPECIE) == "NF",IIf(lDocTras, "T", "I" ), "E")
		cCadOri += cTpoComp + cSepara

		//Exportacion
		cCadOri += cExporta + cSepara
		
		//MetodoPago
		If !lDocTras
			cCadOri += cMetPagO + cSepara
		EndIf
		//LugarExpedicion
		cCadOri += CFDCarEsp(AllTrim(aSM0[4][2])) + cSepara

		//CFDI RELACIONADOS
		If FindFunction("FATXFOLREL")
			If !Empty(SF2->F2_RELSAT) .Or. (!Empty(SF2->F2_SERMAN) .Or. !Empty(SF2->F2_DOCMAN))
				If !(lCartaP .And. lDocTras)
					cCadOri += FATXFOLREL("S",.T.)
				EndIf
			EndIf
		EndIf
		
		//DATOS DEL EMISOR
		If FindFunction("FATXMIEMIS")
			cCadOri += FATXMIEMIS(aSM0, .T., cSepara)
		EndIf

		If AllTrim(SF2->F2_ESPECIE) <> "NDI"
			//DATOS DEL RECEPTOR
			If FindFunction("FATXMIRECE")
				aAdd(aDatosRec,AllTrim(SF2->F2_USOCFDI)) //Uso CFDI
				aAdd(aDatosRec,IIf(lDatoT,AllTrim(aSM0[3][2]),cCliRegF))   //Régimen Fiscal
				aAdd(aDatosRec,Alltrim(SF2->F2_IDTRIB)) //NumRegIdTrib
				aAdd(aDatosRec,IIf(!Empty(SF2->F2_RESIDE),AllTrim(Posicione("SYA",1,xFilial("SYA")+SF2->F2_RESIDE,"YA_CCESAT")),"")) //ResidenciaFiscal
				
				cCadOri += FATXMIRECE(aSM0,SF2->F2_CLIENTE,SF2->F2_LOJA,.T.,cSepara, lDocTras, lComExt, lCartaP, lFacGlo, aDatosRec, aDatosCli, lDatoT)
			EndIf

			//Conceptos
			cCadOri += fXMLFUN("CO",.T.,lDocTras,lCartaP)

			//Total de Impuestos
			cCadOri += fXMLFUN("TI",.T.,lDocTras)

			//Impuestos Locales
			cImpLoc := fXMLFUN("IL",.T.,lDocTras)

			If !Empty(cImpLoc)
				cCadOri += cImpLoc
			EndIf
			
			//Comercio Exterior
			If FindFunction("FATXCOMEXT") .And. lComExt
				aAdd(aEmiCE,CFDCarEsp(AllTrim(aSM0[5][2]))) //M0_ENDCOB
				aAdd(aEmiCE,IIf(!Empty(aSM0[4][2]),CFDCarEsp(AllTrim(ObtColSAT("S015",AllTrim(aSM0[6][2])+ALLTRIM(aSM0[4][2]),1,9,1,4))),"")) //M0_CEPENT //M0_CODZOSE
				aAdd(aEmiCE,IIf(!Empty(aSM0[7][2]),AllTrim(aSM0[7][2]),"")) //M0_CODMUN
				If lFuncF3I 					
					aF3I := FATXVALF3I("S004","Codigo",AllTrim(aSM0[4][2]))
				EndIf
				aAdd(aEmiCE,IIf(Len(aF3I) > 2,CFDCarEsp(aF3I[2]),"")) //M0_CEPENT
				aAdd(aEmiCE,"MEX") 
				aAdd(aEmiCE,AllTrim(aSM0[4][2])) //M0_CEPENT

				cComExt := FATXCOMEXT(.T., aDatosCE, cSepara, aEmiCE, aDatosCli, aDatosRec, aDetComE)
			EndIf

			If !Empty(cComExt)
				cCadOri += cComExt
			EndIf

			//Documento con Complemento de Leyendas Fiscales (IMMEX)
			lLeyFis := FindFunction("FATXLEYFIS") .And. lComExt .And. lCpoConUNi .And. (!Empty(cImpLoc) .or. !Empty(cComExt)) .And. !Empty(SF2->F2_CONUNI) .And. Alltrim(SF2->F2_ESPECIE) == "NF" .And. SA1->A1_CONTRBE == "1"

			//Leyendas Fiscales
			If lLeyFis
				cCadOri += FATXLEYFIS(.T., cPFisica, cSepara, SF2->F2_CONUNI)
			EndIf

			cCadOri += cSepara
		EndIf

		//Encriptación de la Cadena Original
		If FindFunction("FATXMISECA")
			If lCadCon
				ConOut("Cadena Original " + Alltrim(SF2->F2_SERIE) + "-" + Alltrim(SF2->F2_DOC) + ": " + cCadOri)
			EndIf
			cSello := FATXMISECA(cCadOri)
		EndIf

		//Geración de XML
		cXML := '<?xml version="1.0" encoding="UTF-8"?>' + cCtrl
		cXML += '<cfdi:Comprobante'
		cXML += ' xmlns:cfdi="http://www.sat.gob.mx/cfd/4"'
		//Impuestos Locales
		If !Empty(cImpLoc)
			cXML += ' xmlns:implocal="http://www.sat.gob.mx/implocal"'
		EndIf
		//Leyendas Fiscales
		If lLeyFis
			cXML += ' xmlns:leyendasFisc="http://www.sat.gob.mx/leyendasFiscales"'
		EndIf
		cXML += ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
		cXML += ' xsi:schemaLocation="http://www.sat.gob.mx/cfd/4 http://www.sat.gob.mx/sitio_internet/cfd/4/cfdv40.xsd' + IIf(!Empty(cImpLoc),'http://www.sat.gob.mx/implocal','') 
		If lLeyFis
			cXML += ' http://www.sat.gob.mx/leyendasFiscales http://www.sat.gob.mx/sitio_internet/cfd/leyendasFiscales/leyendasFisc.xsd'
		EndIf
		If lComExt
			cXML += ' http://www.sat.gob.mx/ComercioExterior11 http://www.sat.gob.mx/sitio_internet/cfd/ComercioExterior11/ComercioExterior11.xsd'			
		EndIf
		cXML += '"'
		If lComExt
			cXML += ' xmlns:cce11="http://www.sat.gob.mx/ComercioExterior11"'
		EndIf
		cXML += ' Version="' + cVerCFDI + '"'
		cXML += ' Serie="' + AllTrim(SF2->F2_SERIE) + '"'
		cXML += ' Folio="' + AllTrim(SF2->F2_DOC) + '"'
		cXML += ' Fecha="' + AllTrim(cFechaD) + '"'
		cXML += ' Sello="' + cSello + '"'
		If !lDocTras
			cXML += ' FormaPago="' + cFPago + '"'
		EndIf
		cXML += ' NoCertificado="' + AllTrim(SF2->F2_CERTFOL) + '"'
		cXML += ' Certificado="' + cCert + '"'
		If !lDocTras
			cXML += ' CondicionesDePago="' +  CFDCarEsp(cDesCondP) + '"'
		EndIf
		cXML += ' SubTotal="' + cValSubT + '"'
		If !lDocTras .And. SF2->F2_DESCONT > 0
			cXML += ' Descuento="' + cDescto + '"'
		EndIf
		cXML += ' Moneda="' + cMoneda + '"'
		If !lDocTras
			cXML += ' TipoCambio="' + cTpoCam + '"'
		EndIf
		cXML += ' Total="' + cValTot +  '"'
		cXML += ' TipoDeComprobante="' + cTpoComp + '"'
		cXML += ' Exportacion="' + cExporta + '"'

		If !lDocTras
			cXML += ' MetodoPago="' +  cMetPagO + '"' 
		EndIf
		cXML += ' LugarExpedicion="' + CFDCarEsp(AllTrim(aSM0[4][2])) + '"'
		cXML += '>' + cCtrl

		//CFDI RELACIONADOS
		If FindFunction("FATXFOLREL")
			If !Empty(SF2->F2_RELSAT) .Or. (!Empty(SF2->F2_SERMAN) .Or. !Empty(SF2->F2_DOCMAN))
				If !(lCartaP .And. lDocTras)
					cXML += FATXFOLREL("S",.F.) + cCtrl
				EndIf
			EndIf
		EndIf

		//DATOS DEL EMISOR
		If FindFunction("FATXMIEMIS")
			cXML += FATXMIEMIS(aSM0, .F., cSepara)
		EndIf

		If AllTrim(SF2->F2_ESPECIE) <> "NDI"
			//DATOS DEL RECEPTOR
			If FindFunction("FATXMIRECE")
				cXML += FATXMIRECE(aSM0,SF2->F2_CLIENTE,SF2->F2_LOJA,.F.,cSepara, lDocTras, lComExt, lCartaP, lFacGlo, aDatosRec, aDatosCli, lDatoT)
			EndIf
		EndIf

		//Conceptos
		cXML += fXMLFUN("CO",.F.,lDocTras,lCartaP)

		//Total de Impuestos
		cXML += cCtrl + fXMLFUN("TI",.F.,lDocTras)

		//COMPLEMENTOS

		//Impuestos Locales
		cImpLoc := fXMLFUN("IL",.F.,lDocTras)

		//Comercio Exterior
		If FindFunction("FATXCOMEXT") .And. lComExt
			cComExt := FATXCOMEXT(.F., aDatosCE, "", aEmiCE, aDatosCli, aDatosRec, aDetComE)
		EndIf

		//Leyendas Fiscales
		If lLeyFis
			cLeyFis := FATXLEYFIS(.F., cPFisica, "", SF2->F2_CONUNI)
		EndIf

		If !Empty(cImpLoc) .Or. !Empty(cComExt) .Or. !Empty(cLeyFis)
			cXML += '	<cfdi:Complemento>' + cCtrl
			cXML += IIf(!Empty(cImpLoc),cImpLoc,"")
			cXML += IIf(!Empty(cComExt),cComExt,"")
			cXML += IIf(!Empty(cLeyFis),cLeyFis,"")
			cXML += '	</cfdi:Complemento>' + cCtrl
		EndIf

		cXML += '</cfdi:Comprobante>'
	EndIf

	//Creación del XML
	If FindFunction("FATXMICREA") .And. !Empty(cXML)
		FATXMICREA(cXML, cNomXML)
	EndIf

	RestArea(aAreaSF2)
Return Nil
