#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBXSAL.CH"
#INCLUDE "CTBXFUNC.CH"
#INCLUDE "FileIO.CH"
#include "tbiconn.ch"
#Include "TopConn.ch"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪勘�
北矲un噭o    � CTBFMTCOL� Autor � Axel D韆z	                      � Data � 09.03.10	潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪幢�
北矰escri噭o � Cria arquivo de trabalho para gera玢o e prepara玢o dos dados para os 潮�
北�          � relat髍ios em meio magn閠icos no Formato 1001...5002.                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � CTBFMTCOL(cPlanoRef,dDataIni,dDataFin,cMoeda,nLimite,nColuna,        潮�
北�			 � ,cEntCont,cTipDoc,cDocumen,cDocEst,cCodDoc,aLimSec,lFirst)	        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   � Area de trabalho (FMT<1001>).                                        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Gen閞ico                                                  			潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpC1 = Pano Referencial                                   		    潮�
北�          � ExpD1 = Data Inicial                                        		    潮�
北�          � ExpD2 = Data Final                                          		    潮�
北�          � ExpC2 = Moeda		                                     		    潮�
北�          � ExpN1 = Valor Limite Inferior.                              		    潮�
北�          � ExpN2 = Quantidade de Colunas dos saldos a imprimir.        		    潮�
北�          � ExpC3 = Entidade Contabeis para processamento.		       		    潮�
北�          � ExpC4 = Tipo Documento para valores abaixo do limite.       		    潮�
北�          � ExpC5 = Documento para valores abaixo do limite.            		    潮�
北�          � ExpC6 = Tipo de Documento para estrangeiros.                		    潮�
北�          � ExpC7 = Documento para estrageiros.	                       		    潮�
北�          � ExpA1 = Limite Secundarios.                                		    潮�
北�          � ExpL1 = Flag para filtrar registros ja gerados.             		    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
/*/

Function CTBFMTCOL(cPlanoRef,dDataIni,dDataFin,cMoeda,nLimite,nColunas,cEntCont,cTipDoc,cDocumen,cDocEst,cCodDoc,aLimSec,lFirst)
Local aSaveArea  := GetArea()
Local aTamCodPla := TamSX3("CVD_CODPLA")
Local aTamCtaRef := TamSX3("CVD_CTAREF")
Local aTamTipo00 := If(cPaisLoc == "COL",TamSX3("CV0_TIPO00"),{2,0,"C"})
Local aTamTipDoc := If(cPaisLoc $ "COL|EQU|PER",TamSX3("A1_TIPDOC"),{2,0,"C"})
Local aTamNrDoc  := TamSX3("CV0_CODIGO")
Local aTamPNome  := TamSX3("A1_NOME")
Local aTamSNome  := If(cPaisLoc == "COL",TamSX3("A1_NOMEPES"),{20,0,"C"})
Local aTamPSobr  := If(cPaisLoc == "COL",TamSX3("A1_NOMEMAT"),{20,0,"C"})
Local aTamSSobr  := If(cPaisLoc == "COL",TamSX3("A1_NOMEMAT"),{20,0,"C"})
Local aTamRazao  := TamSX3("A1_NOME")
Local aTamEnder  := TamSX3("A1_END")
Local aTamMunic  := TamSX3("A1_COD_MUN")
Local aTamEstad  := TamSX3("A1_EST")
Local aTamPais   := TamSX3("A1_PAIS")
Local aTamSldCrd := TamSX3("QL7_CREDIT")
Local aTamPart   := TamSX3("CVC_PARTIC")

Local cPriNome := ""
Local cSegNome := ""
Local cPriSobr := ""
Local cSegSobr := ""
Local cRazao   := ""
Local cEnd     := ""
Local cCod_Mun := ""
Local cEstado  := ""
Local cPais    := ""
Local cNrDoc   := ""
Local cCpoVal  := ""
Local cCpoDB   := ""
Local cCpoCR   := ""
Local aCtbMoeda   := {}
Local aCampos     := {}
Local lImpAntLP   := (!Empty(MV_PAR08) .And. MV_PAR08==1)	// Posici髇 Ant. Ganan./Perd.
Local dDataLP     := IIf(lImpAntLP,MV_PAR09,CtoD(""))		// Fecha Ganancias/P閞didas
Local nCntEstran  := 0
Local cNrDocEstra := ""
Local nPercPart   := 0.00
Local nI          := 0
Local cNumDoc     := ""
Local cFilCV0     := xFilial("CV0")
Local cTpSald	  := "1"  // Recoge el tipo de saldo a utilizar para colombia (NIIF y COLGAAP)
Local lColNoExist := .F.
Local cNrDocAux	  := ""
Local cPersona    := ""
Local lContinua   := .F.

Private  __oTmpFMT := nil

DEFAULT cTipDoc   := ""
DEFAULT cDocumen  := ""
DEFAULT cDocEst   := ""
DEFAULT cCodDoc   := ""
DEFAULT cEntCont  := "1"
DEFAULT cMoeda    := ""
DEFAULT lFirst    := .T.
	// Parametro Creado para Colombia, tipo de saldo.
	If cPaisLoc == "COL"
		cTpSald := SuperGetMV("MV_COLTPSL", .F., "1") // Tipo de Saldo Colombia para la generacion del Informe
	EndIf

	// Retorna Decimais
	aCtbMoeda := CTbMoeda(cMoeda)
	nDecimais := aCtbMoeda[5]
	dMinData  := CTOD("")
	cArqAux   := "FMT"+AllTrim(cPlanoRef)

	If !lFirst
		RestArea(aSaveArea)
		Return(cArqAux)
	EndIf

	// Verifica passagem de parametros
	cDocEst		:= PadR(cDocEst,aTamTipDoc[1])	// Ajusta longitud para no alterar c骴igo que no se ejecutar� en caso de pruebas
	cNrDocEstra := If(Empty(cCodDoc),"444444001",cCodDoc)
	cMoeda      := If(Empty(cMoeda),"01",cMoeda)

	AADD(aCampos,{ "PLANOREF"	, "C", aTamCodPla[1], 0 })  				// Codigo Plano Referencial
	AADD(aCampos,{ "CTAREF"		, "C", aTamCtaRef[1], 0 })  				// Codigo da Conta Referencial
	AADD(aCampos,{ "TIPO3"		, "C", aTamTipo00[1], 0 })  				// Tipo do Documento
	AADD(aCampos,{ "TIPODOC" 	, "C", aTamTipDoc[1], 0 })					// Tipo do Documneto
	AADD(aCampos,{ "NRDOC"		, "C", aTamNrDoc[1]	, 0 })					// Numero do Documento
	AADD(aCampos,{ "DV"         , "C", 01           , 0 })                  // Digito Verificador do Documento
	AADD(aCampos,{ "PRINOME"	, "C", aTamPNome[1]	, 0 }) 	 				// Primeiro Nome
	AADD(aCampos,{ "SEGNOME"	, "C", aTamPSobr[1]	, 0 })  				// Segundo Nome
	AADD(aCampos,{ "PRISNOME"	, "C", aTamSSobr[1]	, 0 })  				// Primeiro Sobrenome
	AADD(aCampos,{ "SEGSNOME"	, "C", aTamSNome[1]	, 0 })					// Segundo Sobrenome
	AADD(aCampos,{ "RAZAO"		, "C", aTamRazao[1]+10 , 0 })	 				// Nome ou Razao Social
	AADD(aCampos,{ "ENDERECO"	, "C", aTamEnder[1] , 0 })					// Endereco
	AADD(aCampos,{ "MUNICIPIO"	, "C", aTamMunic[1] , 0 })					// Municipio
	AADD(aCampos,{ "ESTADO"		, "C", aTamEstad[1] , 0 })					// Estado
	AADD(aCampos,{ "PAIS"		, "C", aTamPais[1]  , 0 })					// Pais
	AADD(aCampos,{ "VALORPAG"	, "N", aTamSldCrd[1]+9, aTamSldCrd[2]+2 })	// Valor Pago
	AADD(aCampos,{ "VALORDED"	, "N", aTamSldCrd[1]+9, aTamSldCrd[2]+2 })	// Valor Dedu玢o
	AADD(aCampos,{ "PERCPART"	, "N", aTamPart[1]  , aTamPart[2] })		// Percentual de Participa玢o.
	AADD(aCampos,{ "NOMARQ"		, "C", 08		    , 0 })					// Nome do Arquivo.
	AADD(aCampos,{ "EMAIL"		, "C", 50		    , 0 })					// Nome do Arquivo.

	For nI := 3 To nColunas //jgr
		AADD(aCampos,{ "VALOR"+StrZero(nI,2)	, "N", aTamSldCrd[1]+9, aTamSldCrd[2]+2 })	// Valor colunas 03 a n  (conf. CVD_COLUNA)
	Next

	//Crea tabla temporal
	__oTmpFMT := FWTemporaryTable():New(cArqAux)
	__oTmpFMT:SetFields( aCampos )
	__oTmpFMT:AddIndex("T1", {"PLANOREF","CTAREF","TIPODOC","NRDOC","PRINOME","SEGNOME","PRISNOME","SEGSNOME"})
	__oTmpFMT:AddIndex("T2", {"NOMARQ","PLANOREF","CTAREF","TIPODOC","NRDOC","PRINOME","SEGNOME","PRISNOME","SEGSNOME"})
	__oTmpFMT:Create()

	cArqPlan := CTBPlaRef(,,,,cPlanoRef,,,dDataIni,dDataFin,cMoeda,cTpSald,lImpAntLP,dDataLP,.T.,nColunas,cEntCont,,,,,) // Tipo Saldo = 1

	CV0->(dbSetOrder(2))    //Entidades //CV0_FILIAL+CV0_CODIGO
	SA1->(dbSetOrder(3))    //Clientes //A1_FILIAL+A1_CGC
	SA2->(dbSetOrder(3))    //Fornecedores //A2_FILIAL+A2_CGC
	SRA->(dbSetOrder(5))    //Assalariados //RA_FILIAL+RA_CIC
	CVC->(dbSetOrder(2))	//Participantes //CVC_FILIAL+CVC_CGC

	(cArqPlan)->(dbGoTop())

	While (cArqPlan)->(!Eof())
	    cPriNome  := ""
	    cSegNome  := ""
	    cPriSobr  := ""
	    cSegSobr  := ""
	    cRazao    := ""
	    cEnd      := ""
	    cCod_Mun  := ""
	    cEstado   := ""
	    cPais     := ""
	    cTipoDoc  := ""
	    cNrDoc    := ""
	    nPercPart := 0.00
	    cEmail    := ""

		If ! AllTrim((cArqPlan)->PLANOREF) $ "1004|1011"
			cPriNome := IIf(Empty((cArqPlan)->ENTCTB), "", STR0012) //"Desconocido"
		   	cSegNome := cPriNome
		   	cPriSobr := cPriNome
			cSegSobr := cPriNome
		   	cEnd     := "                    "
		   	cCod_Mun := "       "
		   	cEstado  := "   "
		   	cPais    := "   "
		   	cNrDoc   := AllTrim((cArqPlan)->ENTCTB)
			cRazao   := STR0013 //"Entidad 05 No identificado"
			cTipoDoc := "ENT"

		 	If CV0->(MsSeek(cFilCV0+(cArqPlan)->ENTCTB)) // FILIA+CODIGO
				cPersona := IIf(cPaisLoc == "COL" .And. CV0->CV0_TIPO00 == "03", "F", "J")
		 		If cPaisLoc == "COL" .And. CV0->CV0_TIPO00 == "01" //Clientes
					cRazao   := STR0014 //"Entidad Cliente No Identificado"
					cTipoDoc := "CLI"
		 			If !Empty(CV0->CV0_COD) .And. !Empty(CV0->CV0_LOJA)
		 				If SeekCTE(CV0->CV0_COD, CV0->CV0_LOJA, @cNumDoc)
							cPriNome := QryCte->A1_NOMEPRI
							cSegNome := QryCte->A1_NOMEPES
							cPriSobr := QryCte->A1_NOMEMAT
							cSegSobr := QryCte->A1_NOMEPAT
							cRazao   := QryCte->A1_NOME
			    		   	cEnd     := QryCte->A1_END
			    	   		cCod_Mun := QryCte->A1_COD_MUN
			    	  	 	cEstado  := QryCte->A1_EST
			    	   		cPais    := QryCte->A1_PAIS
			    	   		cTipoDoc := QryCte->A1_TIPDOC
			    	   		// Se selecciona el numero de documento NIT/CEDULA
			    	   		If AllTrim(QryCte->A1_TIPDOC) == "31"
			    	   			cNrDoc  := QryCte->A1_CGC
			    	   		Else
			    	   			cNrDoc  := QryCte->A1_PFISICA
			    	   		Endif
			    	   		cEmail	 := QryCte->A1_EMAIL
						 	cPersona := QryCte->A1_PESSOA
			    	   		If ExistBlock("DIGVERCOL")
				    			cNrDoc   := ExecBlock("DIGVERCOL",.F.,.F.,{"QryCte",cNrDoc})
				    		EndIf
				    	EndIf
				    	QryCte->(dbclosearea())
				    	SA1->(dbSetOrder(3))//Clientes //A1_FILIAL+A1_CGC
		    		EndIf
				ElseIf cPaisLoc == "COL" .And. CV0->CV0_TIPO00 == "02" //Proveedores
					cRazao   := STR0015 //"Entidad Proveedor No Identificado"
					cTipoDoc := "PRO"
					IF!Empty(CV0->CV0_COD) .And. !Empty(CV0->CV0_LOJA)
		     			IF SeekPRO(CV0->CV0_COD, CV0->CV0_LOJA)
							cPriNome := QryPro->A2_NOMEPRI
							cSegNome := QryPro->A2_NOMEPES
							cPriSobr := QryPro->A2_NOMEMAT
							cSegSobr := QryPro->A2_NOMEPAT
							cRazao   := QryPro->A2_NOME
				    	   	cEnd     := QryPro->A2_END
			    		   	cCod_Mun := QryPro->A2_COD_MUN
			    		   	cEstado  := QryPro->A2_EST
			    	   		cPais    := QryPro->A2_PAIS
			    	   		cTipoDoc := QryPro->A2_TIPDOC
				    	   	// Se selecciona el numero de documento NIT/CEDULA
				    	   	If AllTrim(QryPro->A2_TIPDOC) == "31"
				    	   		cNrDoc  := QryPro->A2_CGC
				    	   	Else
				    	   		cNrDoc  := QryPro->A2_PFISICA
				    	   	Endif
				    	   	cEmail	 := QryPro->A2_EMAIL
						 	cPersona := QryPro->A2_PESSOA
				    	   	If ExistBlock("DIGVERCOL")
				    			cNrDoc   := ExecBlock("DIGVERCOL",.F.,.F.,{"QryPro",cNrDoc})
		    		   		EndIf
			 			EndIF
			 			QryPro->(dbclosearea())
			 			SA2->(dbSetOrder(3))//Fornecedores //A2_FILIAL+A2_CGC
		 			EndIF
		 		ElseIf cPaisLoc == "COL" .And. CV0->CV0_TIPO00 == "03"  // EMPLEADOS
					cRazao   := STR0016 //"Entidad Empleado No Identificado"
					cTipoDoc := "EMP"
		 			IF!Empty(CV0->CV0_COD)
			 			If SeekEMPL((cArqPlan)->ENTCTB)
			 				cPriNome := QryEmpl->RA_PRINOME
			    	   		cSegNome := QryEmpl->RA_SECNOME
		    		   		cPriSobr := QryEmpl->RA_PRISOBR
		    		   		cSegSobr := QryEmpl->RA_SECSOBR
		    	   			cRazao   := ""
			    	   		cEnd	 := QryEmpl->RA_ENDEREC
		    		   		cCod_Mun := QryEmpl->RA_MUNICIP
		    		   		cEstado  := QryEmpl->RA_ESTADO
		    	   			cPais    := ""
		   	   				cTipoDoc := QryEmpl->RA_TPCIC
			    	   		cNrDoc   := QryEmpl->RA_CIC
				    	   	cEmail	 := QryEmpl->RA_EMAIL
				    	   	If ExistBlock("DIGVERCOL")
				    			cNrDoc   := ExecBlock("DIGVERCOL",.F.,.F.,{"SRA",cNrDoc})
				    		EndIf
		    			EndIf

			 			QryEmpl->(dbclosearea())
			 			SRA->(dbSetOrder(5))//Empleados //RA_FILIAL+RA_CIC
		    		EndIf
	       		ElseIf cPaisLoc == "COL" .And. CV0->CV0_TIPO00 == "04" // PARTICIPANTES
					cRazao   := STR0017 //"Entidad Participantes No Identificado"
					cTipoDoc := "PAR"
	       			IF!Empty(CV0->CV0_COD)
		       			If SeekPar((cArqPlan)->ENTCTB)
							cPriNome  := QryPar->CVC_NOME
							cSegNome  := QryPar->CVC_2NOME
							cPriSobr  := QryPar->CVC_1SNOME
							cSegSobr  := QryPar->CVC_2SNOME
							cRazao    := QryPar->CVC_NOME
		    	   			cEnd	  := QryPar->CVC_END
			    	   		cCod_Mun  := QryPar->CVC_CODMUN
		    		   		cEstado   := QryPar->CVC_UF
		    		   		cPais     := ""
		   	   				cTipoDoc  := QryPar->CVC_TIPDOC
		    	   			cNrDoc    := QryPar->CVC_CGC
			    	   	    nPercPart := QryPar->CVC_PARTIC
			    	   	    cEmail	  := ""
						 	cPersona  := QryPar->CVC_TIPO
			    	   	    If ExistBlock("DIGVERCOL")
				    			cNrDoc   := ExecBlock("DIGVERCOL",.F.,.F.,{"CVC",cNrDoc})
				    		EndIf
		    			EndIf
		    			QryPar->(dbclosearea())
			 			CVC->(dbSetOrder(2)) //Participantes //CVC_FILIAL+CVC_CGC
			 		EndIf
	       		EndIf

				If cPersona == "F"
					cRazao   := ""
				Else
					cPriNome := ""
					cSegNome := ""
					cPriSobr := ""
					cSegSobr := ""
				EndIf

	        EndIf
	    EndIf

	  	nValorPago:= ((cArqPlan)->VLRATUDB01 - (cArqPlan)->VLRATUCR01)
		//Verificar Limite M韓imo. Aplica a cualquier plan, siempre que se defina l韒ite

        If  AllTrim((cArqPlan)->PLANOREF) $ "FMT1009|FMT1008"
            nValorPago	 += ((cArqPlan)->VLRANTDB01-(cArqPlan)->VLRANTCR01)
        EndIF

		If abs(nValorPago) < nLimite
			cRazao   := Upper(STR0018) //"Cuant韆s menores"
			cNrDoc   := cDocumen
			cTipoDoc := cTipDoc
			cPriNome := ""
			cSegNome := ""
			cPriSobr := ""
			cSegSobr := ""
			cEnd	 := SM0->(Trim(M0_ENDENT) + Trim(" " + M0_COMPENT))
			cCod_Mun := SM0->M0_CODMUN
			cEstado  := ""
			cPais    := ""
		EndIf

		cTipoDoc := AllTrim(cTipoDoc)

		If AllTrim((cArqPlan)->PLANOREF) $ "1001|1002|1006|1007|1008|1009|1010" .AND. SuperGetMv("MV_MMEXTE",.T.,.T.)
			If cTipoDoc $ SuperGetMv("MV_COLTIPD",.T.,"")
				cTipoDoc := "42"
			EndIF

			If cTipoDoc $ "42|43" .AND. cNrDoc <> cDocumen
				cEnd      := ""
	    		cCod_Mun  := ""
	    		cEstado   := ""
			EndIf

			//Registro para Beneficiarios Estrangerios, Documento n鉶 identificado.
			If cTipoDoc == "43" .AND. cNrDoc <> cDocumen
				If nCntEstran > 0
					cNrDocEstra := cNrDocEstra += Space(aTamNrDoc[1])
					cPriNome := cPriNome + Space(aTamPNome[1])
					cSegNome := cSegNome + Space(aTamSNome[1])
					cPriSobr := cPriSobr + Space(aTamPSobr[1])
					cSegSobr := cSegSobr + Space(aTamSSobr[1])

					cSeek := (cArqPlan)->PLANOREF+(cArqPlan)->CTAREF+cDocEst+Subs(cNrDocEstra,1,aTamNrDoc[1])+Subs(cPriNome,1,aTamPNome[1])
					cSeek += Subs(cSegNome,1,aTamSNome[1])+Subs(cPriSobr,1,aTamPSobr[1])+Subs(cSegSobr,1,aTamSSobr[1])
			    	If ! (cArqAux)->(dbSeek(cSeek))
			   			cNrDocEstra := Soma1(alltrim(cNrDocEstra))
					EndIf
		   		EndIf
				cNrDoc   := cNrDocEstra
		   		cTipoDoc := cDocEst
		   		nCntEstran ++
			EndIf
		EndIf

		//Acumular Valores para um Unico Beneficiario.
		cTipoDoc := AllTrim(cTipoDoc)	// Alltrim() por si se reasign�
		lAppend := .T.
		If cNrDoc == cNrDocEstra .and. cTipoDoc == AllTrim(cDocEst)  // Revisa si es del extrangero //42,43
			cNrDocEstra := cNrDocEstra += Space(aTamNrDoc[1])
			cPriNome := cPriNome + Space(aTamPNome[1])
			cSegNome := cSegNome + Space(aTamSNome[1])
			cPriSobr := cPriSobr + Space(aTamPSobr[1])
			cSegSobr := cSegSobr + Space(aTamSSobr[1])

			cSeek := (cArqPlan)->PLANOREF+(cArqPlan)->CTAREF+cDocEst+Subs(cNrDocEstra,1,aTamNrDoc[1])+Subs(cPriNome,1,aTamPNome[1])
			cSeek += Subs(cSegNome,1,aTamSNome[1])+Subs(cPriSobr,1,aTamPSobr[1])+Subs(cSegSobr,1,aTamSSobr[1])
	    Else
	    	If AllTrim((cArqPlan)->PLANOREF) $ "1004|1011"
	    		cSeek := (cArqPlan)->PLANOREF+(cArqPlan)->CTAREF
	    	Else
	    		If cTipoDoc <> "31"
	    			cNrDocAux := cNrDoc
	    		Else
	    			cNrDocAux := Left(AllTrim(cNrDoc), Len(AllTrim(cNrDoc))-1)  // Quita en DV
	    		EndIf
	    		cSeek := (cArqPlan)->PLANOREF+(cArqPlan)->CTAREF+PadR(cTipoDoc,aTamTipDoc[1])+Subs(cNrDocAux,1,aTamNrDoc[1])
		    EndIf
		EndIf

		lAppend := !(cArqAux)->(dbSeek(cSeek))
		cCpoVal:= "VALOR"+STRZERO(VAL((cArqPlan)->COLUNA),2,0)
		cCpoDB := "VLRATUDB"+STRZERO(VAL((cArqPlan)->COLUNA),2,0)
		cCpoCR := "VLRATUCR"+STRZERO(VAL((cArqPlan)->COLUNA),2,0)

	   	If lAppend
	   		RecLock(cArqAux,lAppend)
				(cArqAux)->PLANOREF	 := (cArqPlan)->PLANOREF
				(cArqAux)->CTAREF	 := (cArqPlan)->CTAREF
				(cArqAux)->TIPO3	 := If(cPaisLoc == "COL",CV0->CV0_TIPO00,"")
				(cArqAux)->TIPODOC	 := cTipoDoc
				IF !(cTipoDoc == "31")
					// Los Campos Nombres, apellidos no som obligatorios
					(cArqAux)->RAZAO	 := cRazao
					(cArqAux)->NRDOC	 := cNrDoc
				Else
					(cArqAux)->RAZAO	 := cRazao
					(cArqAux)->DV	 	 := RIGHT(ALLTRIM(cNrDoc),1)
					(cArqAux)->NRDOC	 := LEFT(ALLTRIM(cNrDoc),LEN(ALLTRIM(cNrDoc))-1) // QUITA DIGITO VERIFICACION
				EndIf
				(cArqAux)->ENDERECO	 := cEnd
				(cArqAux)->PRINOME	 := cPriNome
				(cArqAux)->SEGNOME	 := cSegNome
				(cArqAux)->PRISNOME	 := cPriSobr
				(cArqAux)->SEGSNOME	 := cSegSobr
				(cArqAux)->MUNICIPIO := Subs(cCod_Mun,3,3)
				(cArqAux)->ESTADO	 := If(Empty(cEstado),Subs(cCod_Mun,1,2),cCod_Mun)
				(cArqAux)->PAIS		 := If(Empty(cPais),"169",cPais)
				(cArqAux)->EMAIL	 := CEmail
				If STRZERO(VAL((cArqPlan)->COLUNA),2,0) == "01"
					If CARQAUX $ "FMT1009|FMT1008"
						(cArqAux)->VALORPAG	 += (NoRound((cArqPlan)->VLRATUDB01-(cArqPlan)->VLRATUCR01 +;
												 	    (cArqPlan)->VLRANTDB01-(cArqPlan)->VLRANTCR01,2))
					Else
						(cArqAux)->VALORPAG	+= NoRound(((cArqPlan)->VLRATUDB01-(cArqPlan)->VLRATUCR01),2)
					EndIF
				ElseIf STRZERO(VAL((cArqPlan)->COLUNA),2,0) == "02"
					(cArqAux)->VALORDED	 := NoRound(((cArqPlan)->VLRATUDB01-(cArqPlan)->VLRATUCR01),2)
				Else

					IF (cArqAux)->(FieldPos(cCpoVal)) > 0
						(cArqAux)->(&cCpoVal)	 += NoRound(((cArqPlan)->VLRATUDB01-(cArqPlan)->VLRATUCR01),2)
					EndIf
				EndIf

				(cArqAux)->PERCPART  := nPercPart
			(cArqAux)->(MsUnLock())
		Else
	   		RecLock(cArqAux,.F.)
				(cArqAux)->ENDERECO	 := cEnd
				(cArqAux)->MUNICIPIO := Subs(cCod_Mun,3,3)
				(cArqAux)->ESTADO	 := If(Empty(cEstado),Subs(cCod_Mun,1,2),cCod_Mun)
				(cArqAux)->PAIS		 := If(Empty(cPais),"169",cPais)
				(cArqAux)->EMAIL		 := CEmail
				If STRZERO(VAL((cArqPlan)->COLUNA),2,0) == "01"
					If CARQAUX $ "FMT1009|FMT1008"
						(cArqAux)->VALORPAG	 += (NoRound((cArqPlan)->VLRATUDB01-(cArqPlan)->VLRATUCR01 +;
												 	    (cArqPlan)->VLRANTDB01-(cArqPlan)->VLRANTCR01,2))
					Else
						(cArqAux)->VALORPAG	+= NoRound(((cArqPlan)->VLRATUDB01-(cArqPlan)->VLRATUCR01),2)
					EndIF
				ElseIf STRZERO(VAL((cArqPlan)->COLUNA),2,0) == "02"
					(cArqAux)->VALORDED	+= NoRound(((cArqPlan)->VLRATUDB01-(cArqPlan)->VLRATUCR01),2)
				Else
					IF (cArqAux)->(FieldPos(cCpoVal)) > 0
						(cArqAux)->(&cCpoVal)+= NoRound(((cArqPlan)->VLRATUDB01-(cArqPlan)->VLRATUCR01),2)
					EndIf
				EndIf
			(cArqAux)->(MsUnLock())
		EndIf
		(cArqPlan)->(dbSkip())
	EndDo

	nCntRec   := 0.00
	nTotalRec := mv_par07
	cNomFile  := cNomArq
	AADD(aNomArq,cNomFile)

	(cArqAux)->(dbGoTop())
	While (cArqAux)->(!Eof())
		// Valida si los campos de valores est醤 en cero
		lContinua := ((cArqAux)->(VALORPAG <> 0 .Or. VALORDED <> 0))
		If !lContinua
			For nI := 3 to nColunas
				cCpoVal := "VALOR" + StrZero(nI,2)
				If (cArqAux)->(FieldPos(cCpoVal)) > 0
					lContinua := lContinua .Or. ((cArqAux)->(FieldGet(FieldPos(cCpoVal))) <> 0)
				EndIf
			Next nX
			If !lContinua
				// Suprimir registro para no informar
				RecLock(cArqAux,.F.)
				(cArqAux)->(dbDelete())
				MsUnLock()
				(cArqAux)->(dbSkip())
				Loop
			EndIf
		EndIf

		nCntRec++
		If nCntRec > nTotalRec
			nCntRec  := 1
			cNomFile := Soma1(cNomFile)
	        AADD(aNomArq,cNomFile)
			EncInfFMT(cPlanoRef,"MV_FMTCONS",cNomFile,.F.)
	    EndIf
		RecLock(cArqAux,.F.)
			(cArqAux)->NOMARQ := cNomFile
		MsUnLock()
		(cArqAux)->(dbSkip())
	EndDo
	(cArqAux)->(dbGoTop())
	(cArqAux)->(dbSetOrder(2)) //NOMARQ+PLANOREF+CTAREF+TIPODOC+NRDOC+PRINOME+SEGNOME+PRISNOME+SEGSNOME

RestArea(aSaveArea)
Return(cArqAux)


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯退屯屯屯脱屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砈eekPar    篈utor  矼icrosiga       � Data �  10/05/2019    罕�
北掏屯屯屯屯拓屯屯屯屯屯褪屯屯屯拖屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Funcion para buscar los PARTICIPANTES en base a la entidad 罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北  Creada por Axel Diaz
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static function SeekPar(cEntidad)
Local lRet    := .T.
Local cQryPar := ""

	cQryPar := "SELECT CVC_NOME,CVC_2NOME,CVC_1SNOME,CVC_2SNOME ,CVC_NOME,CVC_END,CVC_CODMUN, "
	cQryPar += "CVC_UF,CVC_TIPDOC,CVC_CGC,CVC_PARTIC,CVC_TIPO FROM "
	cQryPar += RetSqlName("CVC") + " CVC "
	cQryPar += " WHERE CVC_FILIAL = '"+xFilial("CVC")+"' "
	cQryPar += "  AND CVC_CGC = '" + cEntidad + "' "
	cQryPar += "  AND D_E_L_E_T_ = ' ' "
	cQryPar := ChangeQuery(cQryPar)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryPar),"QryPar",.T.,.F.)
	lRet := !QryPar->(EOF())

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯退屯屯屯脱屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砈eekEMPL    篈utor  矼icrosiga       � Data �  10/05/2019    罕�
北掏屯屯屯屯拓屯屯屯屯屯褪屯屯屯拖屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Funcion para buscar los EMPLEADOS en base a la entidad     罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北  Creada por Axel Diaz
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static function SeekEMPL(cEntidad)
Local lRet    := .T.
Local cQryEmpl := ""

	cQryEmpl := "SELECT RA_NOME,RA_PRINOME,RA_SECNOME,RA_PRISOBR,RA_SECSOBR, "
	cQryEmpl += "RA_ENDEREC,RA_MUNICIP,RA_ESTADO,RA_TPCIC,RA_CIC,RA_EMAIL FROM "
	cQryEmpl += RetSqlName("SRA") + " SRA "
	cQryEmpl += " WHERE RA_FILIAL = '"+xFilial("SRA")+"' "
	cQryEmpl += "  AND RA_CIC = '" + cEntidad + "' "
	cQryEmpl += "  AND D_E_L_E_T_ = ' ' "
	cQryEmpl := ChangeQuery(cQryEmpl)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryEmpl),"QryEmpl",.T.,.F.)
	lRet := !QryEmpl->(EOF())

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯退屯屯屯脱屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砈eekPro    篈utor  矼icrosiga          � Data �  11/26/12   罕�
北掏屯屯屯屯拓屯屯屯屯屯褪屯屯屯拖屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Funcion para buscar los proveedores en base a la Cod Provedor
               y tienda                                                   罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static function SeekPro(cProvee, cLoja)
Local lRet    := .T.
Local cQryPro := ""

	cQryPro := "SELECT A2_NOMEPRI,A2_NOMEPES,A2_NOMEMAT,A2_NOMEPAT,A2_NOME,A2_END,A2_COD_MUN, "
	cQryPro += "A2_EST,A2_PAIS,A2_TIPDOC,A2_PFISICA,A2_CGC,A2_EMAIL,A2_PESSOA FROM "
	cQryPro += RetSqlName("SA2") + " SA2 "
	cQryPro += " WHERE A2_FILIAL = '"+xFilial("SA2")+"' "
	cQryPro += " AND A2_COD = '" + cProvee + "' "
	cQryPro += " AND A2_LOJA = '" + cLoja + "' "
	cQryPro += "  AND D_E_L_E_T_ = ' ' "
	cQryPro := ChangeQuery(cQryPro)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryPro),"QryPro",.T.,.F.)
	lRet := !QryPro->(EOF())

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯退屯屯屯脱屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砈eekCte    篈utor  矼icrosiga          � Data �  11/26/12   罕�
北掏屯屯屯屯拓屯屯屯屯屯褪屯屯屯拖屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Funcion para buscar los clientes en base a la entidad      罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static function SeekCte(cCliente, cLoja, cNumDoc)

	Local lRet		:= .T.
	Local cQryCte	:= ""
	Local cFilSA1	:= xFilial("SA1")

	Default cCliente	:= ""
	Default cLoja		:= ""

	cQryCte := "SELECT A1_NOMEPRI, A1_NOMEPES, A1_NOMEMAT, A1_NOMEPAT, A1_NOME, A1_END, A1_COD_MUN, A1_EST, A1_PAIS, "
	cQryCte += "A1_TIPDOC, A1_PFISICA, A1_CGC, A1_EMAIL, A1_PESSOA "
	cQryCte += "FROM " + RetSqlName("SA1") + " SA1 "
	cQryCte += "WHERE A1_FILIAL = '" + cFilSA1 + "' "
	cQryCte += "AND A1_COD = '" + cCliente + "' "
	cQryCte += "AND A1_LOJA = '" + cLoja + "' "
	cQryCte += "AND D_E_L_E_T_ = ' '"
	cQryCte := ChangeQuery(cQryCte)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCte),"QryCte",.T.,.F.)

	If (lRet := !QryCte->(EOF()))
		If AllTrim(QryCte->A1_TIPDOC) == "31"
			cNumDoc := QryCte->A1_CGC
		Else
			cNumDoc := QryCte->A1_PFISICA
		Endif
	EndIf

Return lRet


/*/
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un噮o    � CTBSalEnt()	� Autor � Jos� Lucas 				  � Data � 04.03.10 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri噮o � Devolve saldos diarios e mensais correpondente as tabelas		    潮�
北�          � QL6 e QL7.                                                 			潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � CTBSalEnt(dDataIni,dDataFin,cMoeda,cTpSaldo,lImpAntLP,dDataLP,		潮�
北�			 � cEntCont,cConta,cCusto,cItem,cCLVL,c5Ent)							潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪幢�
北砇etorno   � aSaldosRet[nQualSaldo]									  			潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Generico                                                   			潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpD1 = Data Inicial	                                    		    潮�
北�          � ExpD2 = Data Final                                          			潮�
北�          � ExpC1 = Moeda                                             		    潮�
北�          � ExpC2 = Tipo de Saldo                                     		    潮�
北�          � ExpL1 = lImpAntLP	                                     		    潮�
北�          � ExpD3 = dDataLP		                                     		    潮�
北�          � ExpC3 = cEntCont		                                     		    潮�
北�          � ExpC4 = cConta Contabil                                     		    潮�
北�          � ExpC5 = cCusto		                                     		    潮�
北�          � ExpC6 = cItem		                                     		    潮�
北�          � ExpC7 = cCLVL		                                     		    潮�
北�          � ExpC8 = c5Ent		                                     		    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function CTBSalEnt(dDataIni,dDataFin,cMoeda,cTpSaldo,lImpAntLP,dDataLP,cEntCont,cConta,cCusto,cItem,cCLVL,c5Ent)

Local aSaveArea	  := GetArea()
Local aSaldos	  := {}
Local nQualSaldo  := 1

DEFAULT cEntCont  := "1"
DEFAULT cConta    := ""
DEFAULT cCusto    := ""
DEFAULT cItem     := ""
DEFAULT cCLVL     := ""
DEFAULT lImpAntLP := .F.
DEFAULT dDataLP   := CTOD("  /  /  ")

cTpSaldo 	:= Iif(cTpSaldo == Nil,"1",cTpSaldo)

If nQualSaldo > 0
	If Month(dDataFin) - Month(dDataIni) > 0
	    //Calcular o Saldo de QL7
		aSaldoCVX := CTBSalCol(dDataIni,dDataFin,cMoeda,cTpSaldo,lImpAntLP,dDataLP,cEntCont,cConta,cCusto,cItem,cCLVL,c5Ent)
	    aSaldos := aSaldoCVX
	Else
		//Calcular o Saldo de QL7
		aSaldoCVX := CTBSalCol(dDataIni,dDataFin,cMoeda,cTpSaldo,lImpAntLP,dDataLP,cEntCont,cConta,cCusto,cItem,cCLVL,c5Ent)
	    aSaldos := aSaldoCVX
    EndIf
EndIf



//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Retorno:                                             �
//� [1][1] Saldo do Per韔do (com sinal).                 �
//� [1][2] Debito no Per韔do.                            �
//� [1][3] Credito no Per韔do.                           �
//� [1][4] Saldo Atual Devedor.                          �
//� [1][5] Saldo Atual Credor.                           �
//� [1][6] Saldo Anterior (com sinal).                   �
//� [1][7] Saldo Anterior Devedor.                       �
//� [1][8] Saldo Anterior Credor.                        �
//� [2]	   Conta Cont醔il.				                 �
//� [3]	   Centro de Custos.				             �
//� [4]	   Item Contabil.		            		     �
//� [5]	   Codigo da Conta Cont醔il.	                 �
//� [6]	   5 Entidade Contabil (N.I.T.)                  �
//� [7]	   Nivel                                         �
//� [8]	   DC                                            �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
//    [1][1]    [1][2]    [1][3]    [1][4]      [1][5]   [1][6]     [1][7]     [1][8]      [2]   [3]   [4]    [5]   [6]    [7]   [8]
//{{nSaldoAtu,nSaldoDeb,nSaldoCrd,nSldAtuDeb,nSldAtuCrd,nSaldoAnt,nSldAntDeb,nSldAntCrd},cConta,cCusto,cItem,cCLVL,c5Ent,IdNivel,DC}
RestArea(aSaveArea)
Return aSaldos



/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪勘�
北矲un噭o    矯TBSalCol  � Autor � Jos� Lucas		              � Data � 05.03.10	潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪幢�
北矰escri噭o � Saldos Di醨ios - QL7.	                                   			潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矯TBSalCol(dDataIni,dDataFin,cMoeda,cTpSaldo,lImpAntLP,dDataLP,cEntCont 潮�
北�			 |,cConta,cCusto,cItem,cCLVL,c5Ent)										潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   硔nSaldoAtu,nSaldoDeb,nSaldoCrd,nSldAtuDeb,nSldAtuCrd,nSaldoAnt,       潮�
北�			 � nSldAntDeb,nSldAntCrd}                                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Generico                                                  			潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpD1 = Data Inicial	                                    		    潮�
北�          � ExpD2 = Data Final                                          		    潮�
北�          � ExpC1 = Moeda                                             		    潮�
北�          � ExpC2 = Tipo de Saldo                                     		    潮�
北�          � ExpL1 = lImpAntLP	                                     		    潮�
北�          � ExpD3 = dDataLP		                                     		    潮�
北�          � ExpC3 = cEntCont		                                     		    潮�
北�          � ExpC4 = cConta Contabil                                     		    潮�
北�          � ExpC5 = cCusto		                                     		    潮�
北�          � ExpC6 = cItem		                                     		    潮�
北�          � ExpC7 = cCLVL		                                     		    潮�
北�          � ExpC8 = c5Ent		                                     		    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
Static Function CTBSalCol(dDataIni,dDataFin,cMoeda,cTpSaldo,lImpAntLP,dDataLP,cEntCont,cConta,cCusto,cItem,cCLVL,c5Ent)

Local aSaveArea	 := QL7->(GetArea())
Local aSaveAnt	 := GetArea()
Local nSaldoDeb	 := 0.00 //  Debito na Data
Local nSaldoCrd	 := 0.00 //  Credito na Data
Local nSldAntDeb := 0.00 //  Saldo Anterior Devedor
Local nSldAntCrd := 0.00 //  Saldo Anterior Credor
Local nSldAtuDeb := 0.00 //  Saldo Atual Devedor
Local nSldAtuCrd := 0.00 //  Saldo Atual Credor
Local aSaldoAtu	 := {0,0,0,0,0} // Saldo Atual (com sinal, ) Nivel 1,2,3,4,5
Local aSaldoAnt  := {0,0,0,0,0} // Saldo Anterior (com sinal, ) Nivel: Contabilidad,Centro Costo,Iten Contable,Clvl,Ente 5
Local aSaldoDeb	 := {0,0,0,0,0}
Local aSaldoCrd	 := {0,0,0,0,0}
Local aSldAntDeb := {0,0,0,0,0}
Local aSldAntCrd := {0,0,0,0,0}
Local aSldAtuDeb := {0,0,0,0,0}
Local aSldAtuCrd := {0,0,0,0,0}
Local aTamSaldo  := TamSX3("QL7_CREDIT")
Local cTabla     := RetSqlName("QL7")
Local cFilEsp    := xFilial("QL7")
Local cCodConta  := ""
Local cCodCusto  := ""
Local cCodItem   := ""
Local cCodCLVL   := ""
Local cCod5Ent   := ""
Local aSaldos    := {}
Local aParPerAnt := {}
Local aParSaldo  := {}

Static cQryPerAnt
Static cQrySaldo

cTpSaldo	:= Iif( Empty( cTpSaldo),"1",cTpSaldo)
dDataLp		:= Iif( dDataLP ==Nil,CTOD("  /  /  "),dDataLP)
lImpAntLP	:= Iif( lImpAntLP == Nil,.F.,lImpAntLP)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Processar Query para obter a data anterior, qdo n鉶 houver saldo no intervalo.    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

DbSelectArea("QL7")
Dbsetorder(1) //QL7_FILIAL+DTOS(QL7_DATA)+QL7_ENT05+QL7_CLVL+QL7_ITEM+QL7_CCUSTO+QL7_CONTA+QL7_MOEDA+QL7_TPSALD+QL7_LP

If cQryPerAnt == Nil
	cQryPerAnt := "SELECT MIN(QL7_DATA) QL7_DATA "
	cQryPerAnt += " FROM " + cTabla + " QL7 "
	cQryPerAnt += " WHERE "
	cQryPerAnt += "	QL7_FILIAL = ? "
	cQryPerAnt += " AND QL7_DATA < ? "
	cQryPerAnt += " AND QL7_CONTA = ? "
	If cPaisLoc == "COL" .and. "5" $ cEntCont
		cQryPerAnt += " AND QL7_ENT05 <> ' ' "
	EndIf
	cQryPerAnt += " AND QL7_MOEDA = ? "
	cQryPerAnt += " AND QL7_TPSALD = ? "
	cQryPerAnt += " AND D_E_L_E_T_ = ' ' "
	If lImpAntLP
		cQryPerAnt += " AND NOT (QL7_LP = 'Z' AND ((QL7_DTLP <> ' ' AND QL7_DTLP >= ?) OR (QL7_DTLP = ' ' AND QL7_DATA >= ?)))"
	EndIf
	cQryPerAnt := ChangeQuery(cQryPerAnt)
EndIf

aAdd(aParPerAnt, cFilEsp)
aAdd(aParPerAnt, DTOS(dDataIni))
aAdd(aParPerAnt, cConta)
aAdd(aParPerAnt, cMoeda)
aAdd(aParPerAnt, cTpSaldo)
If lImpAntLP
	aAdd(aParPerAnt, DTOS(dDataLP))
	aAdd(aParPerAnt, DTOS(dDataLP))
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry2(,,cQryPerAnt,aParPerAnt),"SLDANT",.T.,.F.)

TcSetField("SLDANT","QL7_DATA" 	  ,"D",08,0)

DbSelectArea("SLDANT")
SLDANT->(DbGoTop())
dDatIniAnt := SLDANT->QL7_DATA
SLDANT->(DbCloseArea())

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Processar Query para obter os Saldos da tabela QL7.                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

DbSelectArea("QL7")
Dbsetorder(3) //QL7_FILIAL+QL7_CONTA+QL7_CCUSTO+QL7_ITEM+QL7_CLVL+QL7_ENT05+QL7_MOEDA+QL7_TPSALD+DTOS(QL7_DATA)+QL7_LP

If cQrySaldo == Nil
	cQrySaldo := "SELECT "
	cQrySaldo += "QL7_DATA, "
	cQrySaldo += "QL7_CONTA, "
	cQrySaldo += "QL7_CCUSTO, "
	cQrySaldo += "QL7_ITEM, "
	cQrySaldo += "QL7_CLVL, "
	cQrySaldo += "QL7_ENT05, "
	cQrySaldo += "QL7_DEBITO, "
	cQrySaldo += "QL7_CREDIT "
	cQrySaldo += "FROM " + cTabla + " QL7 "
	cQrySaldo += " WHERE "
	cQrySaldo += " QL7_FILIAL = ? "
	cQrySaldo += " AND QL7_DATA BETWEEN ? AND ? "
	cQrySaldo += " AND QL7_CONTA = ? "
	If cPaisLoc == "COL" .and. "5" $ cEntCont
		cQrySaldo += " AND QL7_ENT05 <> ' ' "
	EndIf
	cQrySaldo += " AND QL7_MOEDA = ? "
	cQrySaldo += " AND QL7_TPSALD = ? "
	cQrySaldo += " AND D_E_L_E_T_ = ' ' "
	If lImpAntLP
		cQrySaldo += " AND NOT (QL7_LP = 'Z' AND ((QL7_DTLP <> ' ' AND QL7_DTLP >= ?) OR (QL7_DTLP = ' ' AND QL7_DATA >= ?)))"
	EndIf
	cQrySaldo += " ORDER BY QL7_CONTA,QL7_ENT05 "
	cQrySaldo := ChangeQuery(cQrySaldo)
EndIf

aAdd(aParSaldo, cFilEsp)
If Empty(dDatIniAnt) .OR. !UPPER(CARQAUX) $ "FMT1008|FMT1009"
	aAdd(aParSaldo, DTOS(dDataIni))
Else
	aAdd(aParSaldo, DTOS(dDatIniAnt))
EndIf
aAdd(aParSaldo, DTOS(dDataFin))
aAdd(aParSaldo, cConta)
aAdd(aParSaldo, cMoeda)
aAdd(aParSaldo, cTpSaldo)
If lImpAntLP
	aAdd(aParSaldo, DTOS(dDataLP))
	aAdd(aParSaldo, DTOS(dDataLP))
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry2(,,cQrySaldo,aParSaldo),"SLDQL7",.T.,.F.)

TcSetField("SLDQL7","QL7_DATA" 	  ,"D",08,0)
TcSetField("SLDQL7","QL7_DEBITO"  ,"N",aTamSaldo[1],aTamSaldo[2])
TcSetField("SLDQL7","QL7_CREDIT"  ,"N",aTamSaldo[1],aTamSaldo[2])

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Percorrer arquivo resultado da Query e totalizar valores em aSaldo.               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
DbSelectArea("SLDQL7")
SLDQL7->(dbGoTop())

While SLDQL7->(!Eof())

	aSaldoAtu[1] := 0.00
	aSaldoDeb[1] := 0.00
	aSldAtuDeb[1] := 0.00
	aSldAtuCrd[1] := 0.00
	aSldAntDeb[1] := 0.00
	aSldAntCrd[1] := 0.00


	aSaldoAtu[2] := 0.00
	aSaldoDeb[2] := 0.00
	aSldAtuDeb[2] := 0.00
	aSldAtuCrd[2] := 0.00
	aSldAntDeb[2] := 0.00
	aSldAntCrd[2] := 0.00

	aSaldoAtu[3] := 0.00
	aSaldoDeb[3] := 0.00
	aSldAtuDeb[3] := 0.00
	aSldAtuCrd[3] := 0.00
	aSldAntDeb[3] := 0.00
	aSldAntCrd[3] := 0.00

	aSaldoAtu[4] := 0.00
	aSaldoDeb[4] := 0.00
	aSldAtuDeb[4] := 0.00
	aSldAtuCrd[4] := 0.00
	aSldAntDeb[4] := 0.00
	aSldAntCrd[4] := 0.00

	aSaldoAtu[5]  := 0.00
	aSaldoDeb[5]  := 0.00
	aSaldoCrd[5]  := 0.00
	aSldAtuDeb[5] := 0.00
	aSldAtuCrd[5] := 0.00
	aSldAntDeb[5] := 0.00
	aSldAntCrd[5] := 0.00

	cCodConta := SLDQL7->QL7_CONTA
	cCod5Ent  := SLDQL7->QL7_ENT05

	While SLDQL7->(!Eof()) .AND. SLDQL7->QL7_CONTA == cCodConta .AND. SLDQL7->QL7_ENT05 == cCod5Ent
		//Compor o Saldo Nivel 05 -> 5a. Entidade Contabil

		If SLDQL7->QL7_DATA < dDataIni

			aSldAntDeb[5] += SLDQL7->QL7_DEBITO
			aSldAntCrd[5] += SLDQL7->QL7_CREDIT

			nSldAntDeb += SLDQL7->QL7_DEBITO
			nSldAntCrd += SLDQL7->QL7_CREDIT

		Else
			aSaldoDeb[5] += SLDQL7->QL7_DEBITO
			aSaldoCrd[5] += SLDQL7->QL7_CREDIT
			aSldAtuDeb[5] += SLDQL7->QL7_DEBITO
			aSldAtuCrd[5] += SLDQL7->QL7_CREDIT

			nSaldoDeb += SLDQL7->QL7_DEBITO
			nSaldoCrd += SLDQL7->QL7_CREDIT
			nSldAtuDeb += SLDQL7->QL7_DEBITO
			nSldAtuCrd += SLDQL7->QL7_CREDIT

		EndIf

		SLDQL7->(dbSkip())
	End

	If "5" $ cEntCont
		aSaldoAtu[5] := aSaldoDeb[5] - aSaldoCrd[5]
		aSaldoAnt[5] := aSldAntDeb[5] - aSldAntCrd[5]
		If 	aSaldoAnt[5] <> 0 .OR. aSaldoAtu[5] <>0
			AADD(aSaldos,{{aSaldoAtu[5],aSaldoDeb[5],aSaldoCrd[5],aSldAtuDeb[5],aSldAtuCrd[5],aSaldoAnt[5],aSldAntDeb[5],aSldAntCrd[5]},;
						cCodConta,cCodCusto,cCodItem,cCodCLVL,cCod5Ent,"5","DC"})
		EndIf
	EndIf

	//Compor o Saldo do Nivel 01 -> Conta Cont醔il
	aSaldoDeb[1]  += nSaldoDeb
	aSaldoCrd[1]  += nSaldoCrd
	aSldAntDeb[1] += nSldAntDeb
	aSldAntCrd[1] += nSldAntCrd
	aSldAtuDeb[1] += nSldAtuDeb
	aSldAtuCrd[1] += nSldAtuCrd

	aSaldoAtu[1] := aSaldoDeb[1] - aSaldoCrd[1]
	aSaldoAnt[1] := aSldAntDeb[1] - aSldAntCrd[1]
	AADD(aSaldos,{{aSaldoAtu[1],aSaldoDeb[1],aSaldoCrd[1],aSldAtuDeb[1],aSldAtuCrd[1],aSaldoAnt[1],aSldAntDeb[1],aSldAntCrd[1]},;
					cCodConta,"","","","","1","DC"})

	nSaldoDeb := 0
	nSaldoCrd := 0
	nSldAntDeb := 0
	nSldAntCrd := 0
	nSldAtuDeb := 0
	nSldAtuCrd := 0

End

SLDQL7->(dbCloseArea())
QL7->(RestArea(aSaveArea))

RestArea(aSaveAnt)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Retorno:                                             �
//� [1] Saldo Atual (com sinal)   (nSaldoAtu)            �
//� [2] Debito na Data            (nSaldoDeb)            �
//� [3] Credito na Data           (nSaldoCrd)            �
//� [4] Saldo Atual Devedor       (nSldAtuDeb)           �
//� [5] Saldo Atual Credor        (nSldAtuCrd)           �
//� [6] Saldo Anterior (com sinal)(nSaldoAnt)            �
//� [7] Saldo Anterior Devedor    (nSldAntDeb)           �
//� [8] Saldo Anterior Credor     (nSldAntCrd)           �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
//      [1]       [2]      [3]       [4]         [5]       [6]       [7]         [8]
//{{nSaldoAtu,nSaldoDeb,nSaldoCrd,nSldAtuDeb,nSldAtuCrd,nSaldoAnt,nSldAntDeb,nSldAntCrd},cConta,cCusto,cItem,cCLVL,c5Ent}
Return aSaldos


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北砅rogram   矯tPlanoRef � Autor � Jose Lucas         	   		� Data � 05.03.10  潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escri噮o 矴erar Arquivo Temporario para Plano de Contas Referencial.           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砈intaxe   � CtPlanoRef(oMeter,oText,oDlg,lEnd,cPlanoRef,cCtaRefIni,cCtaRefFin,  潮�
北�			 � dDataIni,dDataFin,cMoeda,cTpSaldo,lImpAntLP,dDataLP,,lColunas,	   潮�
北�			 � nColunas,cEntCont,cCusto,cItem,cCLVL,c5Ent)						   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   � Area de trabalho (FMT<1001>).                                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北� Uso      � Gen閞ico                                                  		   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   � Alias do arquivo de trabalho.                                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros� 01-oMeter      = Controle da regua                                  潮�
北�          � 02-oText       = Controle da regua                                  潮�
北�          � 03-oDlg        = Janela                                             潮�
北�          � 04-lEnd        = Controle da regua -> finalizar                     潮�
北�          � 05-cPlanoRef    = Codigo do Plano Referencial.                       潮�
北�          � 06-CtaRefIni   = Conta Referencial Inicial.                         潮�
北�          � 07-CtaRefFin   = Conta Referencial Final.                           潮�
北�          � 08-dDataIni    = Data Inicial de Processamento.                     潮�
北�          � 09-dDataFin    = Data Final de Processamento.                       潮�
北�          � 10-cMoeda      = Moeda			                                   潮�
北�          � 11-cTpSaldo    = Tipo de Saldo a serem processados                  潮�
北�          � 12-lImpAntLP   = Se imprime lancamentos Lucros e Perdas             潮�
北�          � 13-dDataLP     = Data da ultima Apuracao de Lucros e Perdas         潮�
北�          � 14-lColunas    = Identicador de mais de uma coluna.                 潮�
北�          � 15-nColunas    = Numero de Colunas de Saldo.                        潮�
北�          � 16-cEntCont    = Entidade Contabeis para Calculo de Saldo.          潮�
北�          � 17-cCusto      = Centro de Custos.                                  潮�
北�          � 18-cItem       = Item Contabil.                                     潮�
北�          � 19-cCLVL       = Classe de Valor.                                   潮�
北�          � 20-c5Ent       = Codigo da 5o. Entidade Contabil.                   潮�
北�          � 21-oTabTmp     = Objeto da Tabela Temporaria (FWTemporaryTable).    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
Static Function CTBPlaRef(oMeter,oText,oDlg,lEnd,cPlanoRef,cCtaRefIni,cCtaRefFin,dDataIni,dDataFin,cMoeda,cTpSaldo,lImpAntLP,dDataLP,lColunas,nColunas,cEntCont,cCusto,cItem,cCLVL,c5Ent,oTabTmp)

Local aTamCodPla	:= TamSX3("CVD_CODPLA")
Local aTamCtaRef    := TamSX3("CVD_CTAREF")
Local aTamDscCta    := TamSX3("CVN_DSCCTA")
Local aTamMoeda     := TamSX3("CTO_MOEDA")
Local aTamSldCrd	:= TamSX3("QL7_CREDIT")
Local aTamConta     := TamSX3("CVD_CONTA")
Local aTamCusto     := TamSX3("CTT_CUSTO")
Local aTamItem  	:= TamSX3("CTD_ITEM")
Local aTamCLVL  	:= TamSX3("CTH_CLVL")
Local aTam5Ent      := TamSX3("CV0_CODIGO")
Local aTamCol       := TamSX3("CVD_COLUNA")
Local aCtbMoeda		:= {}
Local aSaveArea 	:= GetArea()
Local aCampos       := {}
Local cQryTotal		:= ""
Local nCount		:= 0
Local cArqAux		:= GetNextAlias()
Local cColuna       := "01"
Local cBusca        :=""
Local _lNewReg      := .T.
Local lFMT1001		:= cPaisLoc == "COL" .And. AllTrim(cPlanoRef) $ "1001/1003/1005/1006/1007/1008/1009/1010/1012"
Local nLenTpSald	:= TamSX3("QL7_TPSALD")[1]

DEFAULT cCtaRefIni  := Space(TamSX3("CVD_CTAREF")[1])
DEFAULT cCtaRefFin  := Replicate("Z",TamSX3("CVD_CTAREF")[1])
DEFAULT cMoeda      := "01"
DEFAULT cCusto		:= ""
DEFAULT cItem 		:= ""
DEFAULT cCLVL		:= ""
DEFAULT c5Ent		:= ""

//Variaveis para atualizar a regua desde as rotinas de geracao do arquivo temporario
Private oMeter1 	:= oMeter
Private oText1 		:= oText

If lFMT1001
	aTam5Ent := TamSX3("QL7_ENT05")
EndIf

cTpSaldo := PadR(cTpSaldo,nLenTpSald)	// Necesario para Query en Oracle; CTSaldEnt() -> CTSaldoQL7()
aTamSldCrd[1] := aTamSldCrd[1] + 9

// Retorna Decimais
aCtbMoeda 	:= CTbMoeda(cMoeda)
nDecimais 	:= aCtbMoeda[5]
dMinData 	:= CTOD("")

AADD(aCampos,{ "PLANOREF"	, "C", aTamCodPla[1], 0 })  				// Codigo Plano Referencial
AADD(aCampos,{ "CTAREF"		, "C", aTamCtaRef[1], 0 })  				// Codigo da Conta Referencial
AADD(aCampos,{ "DESCCTA"	, "C", aTamDscCta[1], 0 })  				// Descricao da Conta
AADD(aCampos,{ "DATAINI" 	, "D", 08			, 0 })					// Data Inicial do Movimento
AADD(aCampos,{ "DATAFIN"	, "D", 08			, 0 })					// Data Final do Movimento
AADD(aCampos,{ "MOEDA"		, "C", aTamMoeda[1]	, 0 }) 	 				// Numero da Moeda
AADD(aCampos,{ "TPSALDO"	, "C", 02			, 0 })  				// Tipo de Saldo
AADD(aCampos,{ "VLRATUDB01"	, "N", aTamSldCrd[1], aTamSldCrd[2] })  	// Saldo Debito Atual 1o. Per韔do
AADD(aCampos,{ "VLRATUCR01"	, "N", aTamSldCrd[1], aTamSldCrd[2] })		// Saldo Credito Atual 1o. Per韔do
AADD(aCampos,{ "VLRANTDB01"	, "N", aTamSldCrd[1], aTamSldCrd[2] })	 	// Saldo Debito Anterior 1o. Per韔do
AADD(aCampos,{ "VLRANTCR01"	, "N", aTamSldCrd[1], aTamSldCrd[2] })		// Saldo Credito Anterior 1o. Per韔do

If lColunas
	For nCount := 2 To nColunas
		cCpoAtuDb := "VLRATUDB"+StrZero(nCount,2)
		cCpoAtuCr := "VLRATUCR"+StrZero(nCount,2)
		cCpoAntCr := "VLRANTCR"+StrZero(nCount,2)
		cCpoAntDb := "VLRANTDB"+StrZero(nCount,2)

		AADD(aCampos,{ cCpoAtuDb	, "N", aTamSldCrd[1], aTamSldCrd[2] })
		AADD(aCampos,{ cCpoAtuCr	, "N", aTamSldCrd[1], aTamSldCrd[2] })
		AADD(aCampos,{ cCpoAntDb	, "N", aTamSldCrd[1], aTamSldCrd[2] })
		AADD(aCampos,{ cCpoAntCr	, "N", aTamSldCrd[1], aTamSldCrd[2] })
	Next nCount
EndIf

AADD(aCampos,{ "CONTACTB"	, "C", aTamConta[1] , 0 }) 			 		// Saldo Anterior
AADD(aCampos,{ "CCUSTO"		, "C", aTamCusto[1]	, 0 })  				// Saldo Anterior Debito
AADD(aCampos,{ "ITEMCTB"	, "C", aTamItem[1] 	, 0 })  				// Saldo Anterior Credito
AADD(aCampos,{ "CLVALOR"	, "C", aTamCLVL[1] 	, 0 })   				// Debito
AADD(aCampos,{ "ENTCTB"		, "C", aTam5Ent[1] 	, 0 })  				// eh de nivel 1 -> usado como
AADD(aCampos,{ "COLUNA"		, "C", aTamCol[1]	, 0 })  				//

oTabTmp := FWTemporaryTable():New(cArqAux)
oTabTmp:SetFields(aCampos)
oTabTmp:AddIndex("1",{"PLANOREF","CTAREF","CONTACTB","CCUSTO","ITEMCTB","CLVALOR","ENTCTB"})
oTabTmp:AddIndex("2",{"PLANOREF","CTAREF", "ENTCTB"})
oTabTmp:Create()

If FunName() <> "CTBR195" .or. (FunName() == "CTBR195" .and. !lImpAntLP)
	cQryTotal := ""
	cQryTotal += "SELECT COUNT(*) TOTALREC "
	cQryTotal += "FROM "
	cQryTotal += RetSqlName("CVD") + " CVD "
	cQryTotal += " WHERE CVD_FILIAL = '"+xFilial("CVD")+"' "
	cQryTotal += "  AND CVD_CODPLA = '" + cPlanoRef + "' "
	cQryTotal += "  AND CVD_CTAREF BETWEEN '" + cCtaRefIni + "' AND '" + cCtaRefFin + "' "
	cQryTotal += "  AND D_E_L_E_T_ = ' ' "

	cQryTotal := ChangeQuery(cQryTotal)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryTotal),"QRYTOT",.T.,.F.)
	TcSetField("QRYTOT","TOTALREC",	"N", 08, 0)

	QRYTOT->(DbGoTop())
	nTotalRec := QRYTOT->TOTALREC
	QRYTOT->(DbCloseArea())

	BEGINSQL ALIAS "PLANREF"
		SELECT CVD.CVD_CODPLA, CVD.CVD_CTAREF, CVD.CVD_ENTREF, CVD.CVD_CONTA, CVD.CVD_CUSTO, CVD.CVD_COLUNA
		FROM %TABLE:CVD% CVD
		WHERE CVD.CVD_FILIAL = %xfilial:CVD%
			AND CVD.CVD_CODPLA = %Exp:cPlanoRef%
			AND CVD.CVD_CTAREF BETWEEN %Exp:cCtaRefIni% AND %Exp:cCtaRefFin%
			AND CVD.%NOTDEL%
		ORDER BY %Order:CVD,2%
	ENDSQL

	DbSelectArea("PLANREF")
	PLANREF->(dbGoTop())

	If lFMT1001
		(cArqAux)->(DbSetOrder(2)) //PLANOREF+CTAREF+ENTCTB
	EndIf

	While PLANREF->(!Eof())

		CVD->(DbSetOrder(2)) //CVD_FILIAL+CVD_CODPLA+CVD_CTAREF+CVD_CONTA+CVD_VERSAO
		If CVD->(DbSeek(xFilial("CVD")+PLANREF->CVD_CODPLA+PLANREF->CVD_CTAREF+PLANREF->CVD_CONTA))
			cColuna := CVD->CVD_COLUNA
		EndIf

		CVN->(DbSetOrder(2)) //CVN_FILIAL+CVN_CODPLA+CVN_CTAREF+CVN_VERSAO
		CVN->(DbSeek(xFilial("CVN")+PLANREF->CVD_CODPLA+PLANREF->CVD_CTAREF+PLANREF->CVD_CONTA))

		cConta  := PLANREF->CVD_CONTA

		aSaldos := CTBSalEnt(dDataIni,dDataFin,cMoeda,cTpSaldo,lImpAntLP,dDataLP,cEntCont,cConta,cCusto,cItem,cCLVL,c5Ent)

		If Len(aSaldos) > 0
			For nCount := 1 To Len(aSaldos)
				If aSaldos[nCount][7] $ cEntCont

					If lFMT1001
						cBusca :=	PLANREF->CVD_CODPLA + ;
									PLANREF->CVD_CTAREF + ;
									If(Empty(c5Ent), aSaldos[nCount][6], c5Ent)
					Else
						cBusca :=	PLANREF->CVD_CODPLA + ;
									PLANREF->CVD_CTAREF + ;
									"                    " + ;
									IIf(Empty(cCusto), aSaldos[nCount][3], cCusto) + ;
									IIf(Empty(cItem), aSaldos[nCount][4], cItem) + ;
									IIf(Empty(cCLVL), aSaldos[nCount][5], cCLVL) + ;
									If(Empty(c5Ent), aSaldos[nCount][6], c5Ent)
					EndIf

				   	_lNewReg := .T.

				   	If (cArqAux)->(dbSeek(cBusca))
						While (cArqAux)->(!Eof()) .AND. cBusca == (cArqAux)->(PLANOREF+CTAREF)+ ;
																IIf(lFMT1001, (cArqAux)->(ENTCTB), (cArqAux)->(CONTACTB+CCUSTO+ITEMCTB+CLVALOR+ENTCTB))

							If (cArqAux)->COLUNA == cColuna
								RecLock(cArqAux,.F.)
								(cArqAux)->VLRATUDB01	+= aSaldos[nCount][1][4]		//nSldAtuDeb
								(cArqAux)->VLRATUCR01	+= aSaldos[nCount][1][5]	  	//nSldAtuCrd
								(cArqAux)->VLRANTDB01	+= aSaldos[nCount][1][7]    	//nSldAntDeb
								(cArqAux)->VLRANTCR01	+= aSaldos[nCount][1][8]  		//nSldAntCrd
								(cArqAux)->(MsUnLock())
								_lNewReg := .F.
							EndIf
							 (cArqAux)->(dbSkip())
				   		EndDo
				   	EndIf

					If _lNewReg
						RecLock(cArqAux,.T.)
							(cArqAux)->PLANOREF		:= PLANREF->CVD_CODPLA
							(cArqAux)->CTAREF		:= PLANREF->CVD_CTAREF
							(cArqAux)->DESCCTA		:= CVN->CVN_DSCCTA
							(cArqAux)->DATAINI		:= dDataIni
							(cArqAux)->DATAFIN		:= dDataFin
							(cArqAux)->MOEDA		:= cMoeda
							(cArqAux)->TPSALDO		:= cTpSaldo
							(cArqAux)->VLRATUDB01	:= aSaldos[nCount][1][4]		//nSldAtuDeb
							(cArqAux)->VLRATUCR01	:= aSaldos[nCount][1][5]	  	//nSldAtuCrd
							(cArqAux)->VLRANTDB01	:= aSaldos[nCount][1][7]    	//nSldAntDeb
							(cArqAux)->VLRANTCR01	:= aSaldos[nCount][1][8]  		//nSldAntCrd
							(cArqAux)->CONTACTB	:= "                    "//PLANREF->CVD_CONTA
							(cArqAux)->CCUSTO   := If(Empty(cCusto),aSaldos[nCount][3],cCusto)
							(cArqAux)->ITEMCTB  := If(Empty(cItem) ,aSaldos[nCount][4],cItem)
							(cArqAux)->CLVALOR  := If(Empty(cCLVL) ,aSaldos[nCount][5],cCLVL)
							(cArqAux)->ENTCTB   := If(Empty(c5Ent) ,aSaldos[nCount][6],c5Ent)
							(cArqAux)->COLUNA   := cColuna
						(cArqAux)->(MsUnLock())
					EndIf
				EndIf
			Next nCount
		EndIf
	PLANREF->(dbSkip())
	End
	PLANREF->(dbCloseArea())
EndIf

dbSelectArea(cArqAux)
dbSetOrder(1) //PLANOREF + CTAREF + CONTACTB + CCUSTO + ITEMCTB + CLVALOR + ENTCTB

RestArea(aSaveArea)
Return cArqAux
