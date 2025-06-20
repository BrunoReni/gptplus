#INCLUDE "GFEA057.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
// SonarQube - CA1003: Uso n�o permitido de chamada de API em LOOP
Static s_ESPDF4 := SuperGetMv('MV_ESPDF4',,"") // Esp�cie de Subcontrata��o

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA057

Confirma��o/Desconfirma��o e cancelamento de pr�-faturas

@author Jorge Matos Valcanaia
@since 27/10/09
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA057()
	Local CFILTRO

	Private oBrowse

	If !Pergunte("GFEA057",.T.)
		Return
	EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GWJ")									// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA057")				  			// Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetDescription(STR0001)	    					// Descri��o do browse //"Aprova��o e Cancelamento de Pr�-faturas"
	oBrowse:AddLegend( "GWJ_SIT=='1'", "GRAY" , STR0002 )  	// Legenda //"Pendente"
	oBrowse:AddLegend( "GWJ_SIT=='2'", "BLUE" , STR0003 )  	// Legenda //"Enviada"
	oBrowse:AddLegend( "GWJ_SIT=='3'", "GREEN", STR0004 )  	// Legenda //"Confirmada"
	oBrowse:AddLegend( "GWJ_SIT=='4'", "RED"  , STR0005 )	// Legenda //"Cancelada"

	cCond := ""
	CFILTRO := "GWJ_FILIAL >= '" + MV_PAR01 + "'.AND. GWJ_FILIAL <= '" + MV_PAR02 + "' .AND. GWJ_CDTRP >= '" + MV_PAR03 + "' .AND. GWJ_CDTRP <= '" + MV_PAR04 + "' .AND. GWJ_NRPF >= '" + MV_PAR05 + "' .AND. GWJ_NRPF <= '" + MV_PAR06 +"'"

	If MV_PAR07 == 1	// Considera pendentes
		cCond += "1"
	EndIf
	IF MV_PAR08 == 1	// Considera enviadas
		cCond += "2"
	EndIf
	IF MV_PAR09 == 1	// Considera confirmadas
		cCond += "3"
	EndIf

	cFiltro += " .AND. GWJ_SIT $ '" + cCond + "'"

	oBrowse:SetFilterDefault(CFILTRO) // Filtro para n�o mostrar Pr�-faturas com condi��o pendente

	oBrowse:Activate()

Return(Nil)

//-------------------------------------------------------------------

Static Function MenuDef()
	Local aRotina := {}

	//-------------------------------------------------------------------
	// Adiciona bot�es do browse
	//-------------------------------------------------------------------
	ADD OPTION aRotina TITLE STR0006 ACTION "AxPesqui"        OPERATION 1  ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA057" OPERATION 2  ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0008 ACTION "GFEA057CON()"    OPERATION 11 ACCESS 0 //"Confirmar"
	ADD OPTION aRotina TITLE STR0009 ACTION "GFEA057DCO()"    OPERATION 12 ACCESS 0 //"Desfaz Confirm"
	ADD OPTION aRotina TITLE STR0010 ACTION "GFEA057CAN()"    OPERATION 13 ACCESS 0 //"Cancelar"
	ADD OPTION aRotina TITLE STR0025 ACTION "GFEA057PAR()"    OPERATION 14 ACCESS 0 //"Par�metros"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStructGWJ := FWFormStruct(1,"GWJ")

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost   Code-Block de valida��o do formul�rio de edi��o
	// bCommit Code-Block de persist�ncia do formul�rio de edi��o
	// bCancel Code-Block de cancelamento do formul�rio de edi��o
	oModel := MPFormModel():New("GFEA057", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)

	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost        Code-Block de valida��o do formul�rio de edi��o
	// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
	oModel:AddFields("GFEA057_GWJ", Nil, oStructGWJ,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GWJ_FILIAL", "GWJ_NRPF"})

Return oModel

Static Function ViewDef()
	Local oView  := Nil
	Local oModel := FWLoadModel("GFEA057")

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.
	oView:AddField( "GFEA057_GWJ", FWFormStruct(2,"GWJ"), /*cLinkID*/ )
	// cID		  	Id do Box a ser utilizado
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER", 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA057_GWJ", "MASTER" )

Return oView

//-------------------------------------------------------------------------------------------------
// Esta fun��o faz as valida��es do bot�o Confirma��o e se tudo estiver certo confirma a Pr�-fatura
//-------------------------------------------------------------------------------------------------
Function GFEA057CON()
	Local nPCImp
	Local nVLImp
	Local cEspDC
	Local cDtEmDC
	Local cUFOrig
	Local oModelIn
	Local nBaseImp
	Local oModelGW3
	Local oModelGW4
	Local nVlFrete   := 0
	Local nCountDC   := 0
	Local nTotal     := 0
	Local nQT_VOL	 := 0	// Quantidade de Volumes
	Local nPESO_REAL := 0   // Peso Real
	Local nPESO_CUBA := 0   // Peso Cubado
	Local nVOLUME	 := 0   // Volume
	Local nVALOR	 := 0   // Valor dos Itens
	Local nFRET_UNID := 0	// Frete Unidade
	Local nFRET_VAL	 := 0	// Frete Valor
	Local nTAXAS     := 0	// Taxas
	Local nVAL_PEDA	 := 0	// Valor do Ped�gio
	Local aErro      := {}
	Local aErros     := {}
	Local lRet       := .T.
	Local lRetPE     := .T.
	Local lUnitiz	 := .F. // Possui Unitizador (GWB)
	Local lCTECont   := .F.
	Local cLogOption := "3"
	Local cGWFFil    := GetNextAlias()
	Local s_GFEA0571 := ExistBlock("GFEA0571")
	Local lCont      := .F.

	Private GFEResult
	Private GFELog057

	GWJ->( dbSetOrder(1) )
	If GWJ->GWJ_SIT <> "2"
		If GWJ->GWJ_SIT == "3"
			Help( ,, 'HELP',, STR0011, 1, 0,) //'Essa Pr�-fatura j� foi Confirmada'
		ElseIf GWJ->GWJ_SIT == "4"
			Help( ,, 'HELP',, STR0012, 1, 0,) //'Essa Pr�-fatura n�o pode ser confirmada, pois esta com situa��o cancelada'
		Else // GWJ->GWJ_SIT == "1"
			Help( ,, 'HELP',, 'Essa Pr�-fatura ainda n�o foi Enviada.' , 1, 0,)
		EndIf
	Else
		If s_GFEA0571
			lRetPE := ExecBlock("GFEA0571 ",.F.,.F.)
		EndIf

		If lRetPE
			If !IsBlind()
				If MsgYesNo(STR0013) //"Deseja confirmar Pr�-fatura?"
					lCont := .T.
				EndIf
			Else
				lCont := .T.
			EndIf

			If lCont
				RecLock('GWJ')
				GWJ->GWJ_SIT    := "3"
				GWJ->GWJ_DTAPR  := DDATABASE
				GWJ->GWJ_HRAPR  := TIME()
				GWJ->GWJ_USUAPR := cUserName
				GWJ->( MsUnLock() )

				If SuperGetMV("MV_TPGERA",,"2") == "1"
					GFEACTBPRE( GWJ->GWJ_FILIAL , GWJ->GWJ_NRPF )
				EndIf

				If SuperGetMV('MV_GFEI15',,'1') == '2' //Integra��o automatica Financeiro
					oModelIn := FWLoadModel("GFEA055")
					GFEA055X(.T.,oModelIn)
					oModelIn:DeActivate()
					oModelIn:Destroy()
				EndIf

				/* Facilita a entrada de documentos de frete
				Cria automaticamente, com base no C�lculo do Frete, os Docs Frete para o v�nculo destes	fretes com uma Fatura */
				If GFXCP12127("GU3_SUBCON")	.And. GFXCP12127("GUT_SUBCON")
					GU3->(dbSetOrder(1))
					GU3->(dbSeek(xFilial("GU3") + GWJ->GWJ_CDTRP))
					If GU3->GU3_SUBCON == '2' // 2=Conforme UF
						// Relaciona c�lculos da pr�-fatura para verificar se empresa pode transitar apenas com CT-e da contratante
						GWF->( dbSetOrder(3) )
						GWF->( dbSeek(GWJ->GWJ_FILIAL+GWJ->GWJ_NRPF) )
						While !GWF->( Eof() ) .And. GWF->GWF_FILPRE == GWJ->GWJ_FILIAL .And. GWF->GWF_NRPREF == GWJ->GWJ_NRPF
							cUFOrig := Posicione("GU7", 1, xFilial("GU7") + GWF->GWF_CIDORI, "GU7_CDUF")
							GUT->(dbSetOrder(1))
							GUT->(dbSeek(xFilial("GUT") + cUFOrig))
							If GUT->GUT_SUBCON == '2' // 2=Opcional
								lCTECont := .T.
								Exit
							EndIf

							GWF->( dbSkip() )
						EndDo

						If lCTECont // Transportadora s� pode transitar com o CT-e da empresa contratante
							If MsgYesNo("Sistema parametrizado para cria��o autom�tica de documentos de frete. Confirma?")
								If !Empty(s_ESPDF4)
									GFELog057 := GFELog():New("Confirma_Pre_Fatura", "Pr�-Fatura - Cria��o autom�tica de Doc Frete", cLogOption )
									GFEResult := GFEViewProc():New()
	
									// Relaciona c�lculos da pr�-fatura para cria��o autom�tica do Doc Frete
									cQuery := "SELECT * "
									cQuery += "FROM " + RetSQLName("GWF") + " GWF "
									cQuery += "WHERE GWF.GWF_FILIAL = '" + GWJ->GWJ_FILIAL + "' "
									cQuery += " AND GWF.GWF_NRPREF = '" + GWJ->GWJ_NRPF + "' "
									cQuery += " AND	GWF.D_E_L_E_T_ = ''

									cQuery := ChangeQuery(cQuery)
									dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cGWFFil, .F., .T.)

									(cGWFFil)->( dbGoTop() )
									While !(cGWFFil)->( Eof() )
										cUFOrig := Posicione("GU7", 1, xFilial("GU7") + (cGWFFil)->GWF_CIDORI, "GU7_CDUF")
										GUT->(dbSetOrder(1))
										GUT->(dbSeek(xFilial("GUT") + cUFOrig))
										If GUT->GUT_SUBCON == '2' // 2=Opcional
											// Cria Doc Frete utilizando dados do c�lculo e esp�cie parametrizada nos Par�metros do M�dulo (MV_ESPDF4)
											oModelGW3 := FWLoadModel( "GFEA065" )
											oModelGW4 := oModelGW3:getModel("GFEA065_GW4")

											nTotal++

											oModelGW3:SetOperation( 3 )
											oModelGW3:Activate()

											GFELog057:Add("[" + cValToChar(nTotal) + "] Criando Documento de Frete: " + AllTrim((cGWFFil)->GWF_NRCALC) )
											GFELog057:Add("> Pr�-Fatura.: " + AllTrim((cGWFFil)->GWF_NRPREF), 1)
											GFELog057:Add("> Filial.: " + AllTrim((cGWFFil)->GWF_FILIAL), 1)
											GFELog057:Add("> Esp�cie: " + AllTrim(s_ESPDF4), 1)
											GFELog057:Add("> Emissor: " + (cGWFFil)->GWF_TRANSP, 1)
											GFELog057:Add("> N�mero.: " + (cGWFFil)->GWF_NRCALC, 1)
											GFELog057:Add("> Dt.Emis: " + DTOS(DDATABASE), 1)
											GFELog057:Save()

											oModelGW3:SetValue("GFEA065_GW3",'GW3_FILIAL' , AllTrim((cGWFFil)->GWF_FILIAL) )	// Filial
											oModelGW3:SetValue("GFEA065_GW3",'GW3_CDESP'  , AllTrim(s_ESPDF4) )					// Esp�cie
											oModelGW3:SetValue("GFEA065_GW3",'GW3_EMISDF' , AllTrim((cGWFFil)->GWF_TRANSP) )	// Emissor Documento
											oModelGW3:SetValue("GFEA065_GW3",'GW3_NRDF'   , AllTrim((cGWFFil)->GWF_NRCALC) )	// N�mero Documento
											oModelGW3:SetValue("GFEA065_GW3",'GW3_DTEMIS' , DDATABASE )  						// Data de Emiss�o
											oModelGW3:SetValue("GFEA065_GW3",'GW3_TPDF'   , AllTrim((cGWFFil)->GWF_TPCALC) )	// Tipo do Documento
											oModelGW3:SetValue("GFEA065_GW3",'GW3_DTENT'  , DDATABASE ) 						// Data de Entrada
											oModelGW3:SetValue("GFEA065_GW3",'GW3_SIT' 	  , '3' ) 		// 3=Aprovado sistema	// Situa��o
											oModelGW3:SetValue("GFEA065_GW3",'GW3_ORIGEM' , '4' ) 		// 4=Sistema			// Origem
											oModelGW3:SetValue("GFEA065_GW3",'GW3_CDREM'  , AllTrim((cGWFFil)->GWF_EMIREM) )	// Remetente
											oModelGW3:SetValue("GFEA065_GW3",'GW3_CDDEST' , AllTrim((cGWFFil)->GWF_EMIDES) )	// Destinat�rio

											oModelGW3:SetValue("GFEA065_GW3",'GW3_TPIMP'  , (cGWFFil)->GWF_IMPOST ) 			// Tipo de Imposto
											oModelGW3:SetValue("GFEA065_GW3",'GW3_TRBIMP' , (cGWFFil)->GWF_TPTRIB ) 			// Tipo de Tributa��o

											nVlFrete := 0
											GWI->(dbSetOrder(1))
											GWI->(dbSeek(xFilial("GWI")+ (cGWFFil)->GWF_NRCALC ))
											While !GWI->( Eof() ) .And. xFilial("GWI")+(cGWFFil)->GWF_NRCALC == GWI->GWI_FILIAL+GWI->GWI_NRCALC
												GV2->(dbSetOrder(1))
												GV2->(dbSeek(xFilial("GV2")+GWI->GWI_CDCOMP))	// GV2 - Componente de Frete
												If GWI->GWI_TOTFRE == "1"
													nVlFrete += GWI->GWI_VLFRET		// Valor Total do Frete

													Do Case
														Case GV2->GV2_CATVAL == "1"  // 1=Frete Unidade
															nFRET_UNID += GWI->GWI_VLFRET
														Case GV2->GV2_CATVAL == "2"  // 2=Frete Valor
															nFRET_VAL += GWI->GWI_VLFRET
														Case GV2->GV2_CATVAL == "3"  // 3=Taxas
															nTAXAS += GWI->GWI_VLFRET
														Case GV2->GV2_CATVAL == "4"  // 4=Valor do Pedagio
															nVAL_PEDA += GWI->GWI_VLFRET
													EndCase
												EndIf

												GWI->( dbSkip() )
											EndDo

											nVlFrete += (cGWFFil)->GWF_VLAJUS	// Valor do Ajuste do frete

											oModelGW3:SetValue("GFEA065_GW3", 'GW3_FRPESO', nFRET_UNID ) // Frete unidade
											oModelGW3:SetValue("GFEA065_GW3", 'GW3_FRVAL' , nFRET_VAL )  // Frete Valor
											oModelGW3:SetValue("GFEA065_GW3", 'GW3_TAXAS' , nTAXAS ) 	 // Taxas
											oModelGW3:SetValue("GFEA065_GW3", 'GW3_PEDAG' , nVAL_PEDA )  // Valor do Ped�gio
											oModelGW3:SetValue("GFEA065_GW3", 'GW3_VLDF'  , nVlFrete ) 	 // Valor do documento

											GWH->(dbSetOrder(1))
											If GWH->(dbSeek(xFilial("GWH")+(cGWFFil)->GWF_NRCALC ))
												While !GWH->( Eof() ) .And. GWH->GWH_FILIAL+GWH->GWH_NRCALC == xFilial("GWH")+(cGWFFil)->GWF_NRCALC

													GW1->(dbSetOrder(1))
													If GW1->(dbSeek(xFilial("GW1")+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC))
														GWB->(dbSetOrder(2))
														GWB->(dbSeek(xFilial("GWB")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
														While !GWB->( Eof() ) .And. GWB->GWB_FILIAL+GWB->GWB_CDTPDC+GWB->GWB_EMISDC+GWB->GWB_SERDC+GWB->GWB_NRDC == ;
															                        xFilial("GWB")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC
															lUnitiz := .T.
															nQT_VOL := nQT_VOL + GWB->GWB_QTDE

															GUG->(dbSetOrder(1))
															If GUG->(dbSeek(xFilial("GUG")+GWB->GWB_CDUNIT))
																nVOLUME := nVOLUME + GUG->GUG_VOLUME*GWB->GWB_QTDE
															EndIf

															GWB->(dbSkip())
														EndDo
													EndIf

													GWH->(dbSkip())
												EndDo
											EndIf

											cQuery := "SELECT SUM(GW8_PESOR) AS TOT_PESOR, SUM(GW8_PESOC) AS TOT_PESOC, SUM(GW8_VALOR) AS TOT_VALOR "
											If !lUnitiz
												cQuery += ", SUM(GW8_QTDE) AS TOT_QTDE, SUM(GW8_VOLUME) AS TOT_VOLUME "
											EndIf
											cQuery += "FROM " + RetSQLName("GW8") + " GW8 "
											cQuery += "INNER JOIN " + RetSQLName("GWH") + " GWH "
											cQuery += " ON GW8_FILIAL = GWH_FILIAL "
											cQuery += " AND GW8_CDTPDC = GWH_CDTPDC "
											cQuery += " AND GW8_EMISDC = GWH_EMISDC "
											cQuery += " AND GW8_SERDC  = GWH_SERDC "
											cQuery += " AND GW8_NRDC   = GWH_NRDC "
											cQuery += " AND GW8.D_E_L_E_T_ = '' "
											cQuery += "WHERE GWH_FILIAL = '" + (cGWFFil)->GWF_FILIAL + "' "
											cQuery += " AND GWH_NRCALC = '" + (cGWFFil)->GWF_NRCALC + "' "
											cQuery += " AND GWH.D_E_L_E_T_ = '' "

											cAliTotGW8 := GetNextAlias()
											cQuery := ChangeQuery(cQuery)
											dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliTotGW8, .F., .T.)

											(cAliTotGW8)->( dbGoTop() )
											While !(cAliTotGW8)->(Eof())
												If !lUnitiz
													nQT_VOL := nQT_VOL + (cAliTotGW8)->TOT_QTDE
													nVOLUME := nVOLUME + (cAliTotGW8)->TOT_VOLUME
												EndIf

												nPESO_REAL += (cAliTotGW8)->TOT_PESOR
												nPESO_CUBA += (cAliTotGW8)->TOT_PESOC
												nVALOR     += (cAliTotGW8)->TOT_VALOR

												(cAliTotGW8)->(dbskip())
											Enddo
											(cAliTotGW8)->( dbCloseArea() )

											oModelGW3:SetValue("GFEA065_GW3", 'GW3_QTVOL',  nQT_VOL ) 	  // Quantidade de volumes
											oModelGW3:SetValue("GFEA065_GW3", 'GW3_PESOR',  nPESO_REAL )  // Peso Real
											oModelGW3:SetValue("GFEA065_GW3", 'GW3_PESOC',  nPESO_CUBA )  // Peso Cubado
											oModelGW3:SetValue("GFEA065_GW3", 'GW3_VOLUM',  nVOLUME ) 	  // Volume
											oModelGW3:SetValue("GFEA065_GW3", 'GW3_VLCARG', nVALOR ) 	  // Valor dos itens

											If Trim((cGWFFil)->GWF_TPTRIB) == '2'
												oModelGW3:SetValue("GFEA065_GW3",'GW3_BASIMP', 0 )   // Base Imposto
												oModelGW3:SetValue("GFEA065_GW3",'GW3_PCIMP' , 0 )   // Percentual Imposto
												oModelGW3:SetValue("GFEA065_GW3",'GW3_VLIMP' , 0 )   // Valor Imposto

											Else
												If (cGWFFil)->GWF_IMPOST == "1" 		//ICMS
													nBaseImp := (cGWFFil)->GWF_BASICM
													nPCImp   :=  (cGWFFil)->GWF_PCICMS
													nVLImp   :=	 (cGWFFil)->GWF_VLICMS
												Elseif (cGWFFil)->GWF_IMPOST == "2" 	//ISS
													nBaseImp := (cGWFFil)->GWF_BASISS
													nPCImp 	 := (cGWFFil)->GWF_PCISS
													nVLImp 	 := (cGWFFil)->GWF_VLISS
												EndIf

												oModelGW3:SetValue("GFEA065_GW3",'GW3_BASIMP', nBaseImp ) // Base Imposto
												oModelGW3:SetValue("GFEA065_GW3",'GW3_PCIMP' , nPCImp )   // Percentual Imposto
												oModelGW3:SetValue("GFEA065_GW3",'GW3_VLIMP' , nVLImp )   // Valor Imposto
											EndIf

											nCountDC := 0
											GFELog057:Add( CRLF + "  - Documentos de Carga")

											GWH->( dbSetOrder(1) )
											GWH->( dbSeek((cGWFFil)->GWF_FILIAL + (cGWFFil)->GWF_NRCALC) )

											While !GWH->(Eof()) .And. GWH->GWH_FILIAL == (cGWFFil)->GWF_FILIAL .And. GWH->GWH_NRCALC  == (cGWFFil)->GWF_NRCALC
												nCountDC++

												GFELog057:Add(" #" + cValToChar(nCountDC) + " - Filial: " + Alltrim(GWH->GWH_FILIAL) + ", Emissor: " + Alltrim(GWH->GWH_EMISDC) + ", S�rie: " + Alltrim(GWH->GWH_SERDC) + ", N�mero: " + Alltrim(GWH->GWH_NRDC) + ", Tipo DC: " + Alltrim(GWH->GWH_CDTPDC), 2)

												If nCountDC > 1
													oModelGW4:addLine()
												EndIf

												// Carrega os dados do doc carga relacionado ao doc frete
												oModelGW4:SetValue('GW4_FILIAL', AllTrim(GWH->GWH_FILIAL) )  // Filial Doc Carga
												oModelGW4:SetValue('GW4_EMISDC', AllTrim(GWH->GWH_EMISDC) )  // Emissor Doc Carga

												cEspDC := Posicione("GW1",1,xFilial("GW1")+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC, "GW1_DSESP")

												oModelGW4:SetValue('GW4_CDESP ', AllTrim(cEspDC) ) 			// Esp�cie Doc Carga
												oModelGW4:SetValue('GW4_SERDC' , AllTrim(GWH->GWH_SERDC ) )	// S�rie Doc Carga
												oModelGW4:SetValue('GW4_NRDC'  , AllTrim(GWH->GWH_NRDC)   )	// N�mero Doc Carga
												oModelGW4:SetValue('GW4_TPDC'  , AllTrim(GWH->GWH_CDTPDC) )

												cDtEmDC := Posicione("GW1",1,xFilial("GW1")+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC, "GW1_DTEMIS")
												oModelGW4:SetValue('GW4_DTEMIS', cDtEmDC ) 		        	// Data Emiss�o Doc Carga

												GWH->( dbSkip() )
											EndDo

											If oModelGW3:VldData()     // Indica se o modelo foi carregado com sucesso
												lRet := oModelGW3:CommitData() // Grava a folha de dados do obj
												if lRet
													GFELog057:NewLine()
													GFELog057:Add("** " + "Documento(s) de Frete " + AllTrim((cGWFFil)->GWF_NRCALC) + " gerado com sucesso." + CRLF, 1)
												EndIf

											Else
												// Recupera as mensagens de erro
												If !Empty(aErro)
													aAdd(aErro, oModelGW3:GetErrorMessage())
												Else
													aErro := oModelGW3:GetErrorMessage()
												EndIf

												aAdd(aErros, aErro)

												GFELog057:NewLine()
												GFELog057:Add("** " + "Erro na inclus�o do documento de frete: '" + AllTrim((cGWFFil)->GWF_NRCALC) + "'. Motivo: " + aErro[6] + CRLF, 1)
												GFEResult:AddErro("Erro na inclus�o do documento de frete: '" + AllTrim((cGWFFil)->GWF_NRCALC) + "'. Motivo: " + aErro[6] + CRLF)
											EndIf

											oModelGW3:DeActivate()

											GFELog057:NewLine()
											GFELog057:Add(Replicate(".", 120))
											GFELog057:NewLine()
											GFELog057:Save()
										EndIf

										(cGWFFil)->( dbSkip() )
									EndDo

									(cGWFFil)->(dbCloseArea())

									If !Empty(aErros)
										GFEResult:Show("Cria��o autom�tica de Documentos de Frete", "Documentos", "Erros",;
										"Ocorreram erros na gera��o de um ou mais documentos. Clique no bot�o 'Erros' para mais detalhes."+ CRLF +;
										"Arquivo de log gerado em: '" + GFELog057:cFullFile)
									Else
										GFEResult:Add("Documento(s) de Frete gerado(s) com sucesso." )
										GFEResult:Add("" )
										GFEResult:Show("Cria��o autom�tica de Documentos de Frete", "Documentos", "Erros",;
													   "Arquivo de log gerado em: '" + GFELog057:cFullFile)
									EndIf

									GFELog057:EndLog()
								Else
									Help( ,, 'HELP',, "Esp�cie Documento de Frete Subcontrata��o n�o informada.", 1, 0 ,,,,,, {"Preencha o campo 'Esp�cie Doc Frete Subcontrata��o' em Par�metros do M�dulo (GFEX000)"})
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA057DCO
	Essa fun��o faz as valida��es do bot�o Desfazer Confirma��o e se tudo estiver certo Desfaz a Confirma��o
@author
@since 
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA057DCO()
	Local lCont := .F.

	dbSelectArea("GWJ")
	dbSetOrder(1)

	If (SuperGetMv("MV_GFEPF1",,'1') == '1' .AND. GWJ->GWJ_SIT == "3") .OR.;
		(SuperGetMv("MV_GFEPF1",,'1') == '2' .AND. (GWJ->GWJ_SIT == "2" .OR. GWJ->GWJ_SIT == "3") )
		If Alltrim(GWJ->GWJ_NRFAT) <> ""
			Help( ,, 'HELP',, STR0014, 1, 0,) //'Essa Pr�-fatura n�o pode ser desfeita pois j� esta vinculada a uma Fatura de Frete'
			Return .F.
		EndIf
	EndIf

	If GWJ->GWJ_SIT <> "3"
		Help( ,, 'HELP',, STR0015, 1, 0,) //'Somente Pr�-faturas com situa��o confirmada podem ser desfeitas'
	Else
		If !IsBlind()
			If MsgYesNo(STR0016) //"Deseja Desfazer Confirma��o da Pr�-fatura?"
				lCont := .T.
			EndIf
		Else
			lCont := .T.
		EndIf

		If lCont
			RecLock('GWJ')
			GWJ->GWJ_SIT    := "2"
			GWJ->GWJ_DTAPR  := STOD("  /  /  ")
			GWJ->GWJ_HRAPR  := ""
			GWJ->GWJ_USUAPR := ""
			GWJ->( MsUnLock() )

			GFEA057EMC(GWJ->GWJ_FILIAL, GWJ->GWJ_NRPF)
		EndIf
	EndIf

Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA057CAN()
Abre uma janela de confirma��o do cancelamento da pr�-fatura
Se estiver integrado com o ERP (SIT_FIN = 4), altera a situa��o para SITFIN para 5 e o cancelamento � feito no retorno (GFEA057DEL)
De outra forma, continua com o processo de cancelamento.

@sample
GFEA057CAN()

@author Israel Alcantara Possoli
@since 23/08/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA057CAN()
	Local oDlg
	Local cTexto1
	
	dbSelectArea("GWJ")
	dbSetOrder(1)

	If (SuperGetMv("MV_GFEPF1",,'1') == '1' .AND. GWJ->GWJ_SIT == "3") .OR.;
	   (SuperGetMv("MV_GFEPF1",,'1') == '2' .AND. (GWJ->GWJ_SIT == "2" .OR. GWJ->GWJ_SIT == "3") )
		If Alltrim(GWJ->GWJ_NRFAT) <> ""
			Help( ,, 'HELP',, STR0017, 1, 0,) //'Essa Pr�-fatura est� vinculada a uma Fatura de Frete a mesma n�o pode ser cancelada'
			Return .F.
		EndIf
	EndIf

	If GWJ->GWJ_SIT == "4"
		Help( ,, 'HELP',, STR0018, 1, 0,) //'Est� Pr�-fatura j� foi cancelada'
		Return .F.
	EndIf

	If GWJ->GWJ_SITFIN == "4"
		Help( ,, 'HELP',, "A Pr�-fatura est� Atualizada no Financeiro. Primeiramente a Pr�-fatura deve ser desatualizada para ent�o poder ser cancelada.", 1, 0,)
		Return .F.
	EndIf

	If GWJ->GWJ_SITFIN == "5"
		Help( ,, 'HELP',, "A Pr�-fatura est� Pendente de Desatualiza��o no Financeiro, aguarde retorno.", 1, 0,)
		Return
	EndIf

	If GWJ->GWJ_SITFIN == "2"
		Help( ,, 'HELP',, "N�o � poss�vel cancelar a Pr�-fatura, pois, est� Pendente no Financeiro", 1, 0,)
		Return .F.
	EndIf

	If !IsBlind()
		DEFINE MSDIALOG oDlg TITLE "Cancelamento de Pr�-fatura" From 4,0 To 16,60 OF oMainWnd //"Cancelamento de Pr�-fatura"

		@ 4, 006  SAY "Motivo do Cancelamento:" SIZE 70,7 PIXEL OF oDlg //"Motivo do Cancelamento:"

		oTMultiget1 := TMultiget():New(13,06,{|u|if(Pcount()>0,cTexto1:=u,cTexto1)},oDlg,225,60,,,,,,.T.)

		oButtonOK :=tButton():New(75,5,STR0021,oDlg, {|| If(GFEACANPF(cTexto1),oDlg:End(),NIL)},25,10,,,,.T.) //'OK'
		oButtonCanc :=tButton():New(75,35,STR0022,oDlg,{|| oDlg:End()},25,10,,,,.T.) //'Cancelar'

		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		GFEACANPF("Cancelamento Automa��o de Teste.")
	EndIf

Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEACAN()
Processo principal de cancelamento da pr�-fatura

@sample
GFEACAN()

@author Israel Alcantara Possoli
@since 23/08/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEACANPF(cMotivo)
	Local lRet    := .T.
	Local nI      := 0
	Local aPreFat := {}

	If !Empty(cMotivo)
		// Seleciona os c�lculos que ser�o desvinculados
		dbSelectArea("GWF")
		GWF->( dbSetOrder(3) )
		GWF->( dbSeek(GWJ->GWJ_FILIAL+GWJ->GWJ_NRPF) )
		While !GWF->( Eof() ) .And. GWF->GWF_FILPRE == GWJ->GWJ_FILIAL .And. GWF->GWF_NRPREF == GWJ->GWJ_NRPF
			AAdd(aPreFat, GWF->(RecNo()))
			dbSelectArea("GWF")
			GWF->( dbSkip() )
		EndDo

		// Efetiva a desvincula��o dos c�lculos
		If Len(aPreFat) > 0
			For nI := 1 To Len(aPreFat)
				dbSelectArea("GWF")
				dbGoTo(aPreFat[nI])

				RecLock("GWF", .F.)
					GWF->GWF_FILPRE := ""
					GWF->GWF_NRPREF := ""
				MsUnLock("GWF")
			Next
		EndIf

		RecLock('GWJ', .F. )
		GWJ->GWJ_MOTCAN := cMotivo
		GWJ->GWJ_SIT    := "4"
		GWJ->GWJ_DTCANC := DDATABASE
		GWJ->GWJ_HRCAN  := TIME()
		GWJ->GWJ_USUCAN := cUserName
		MsUnLock('GWJ')

		// Elimina��o dos movimentos cont�beis
		GFEA057EMC(GWJ->GWJ_FILIAL, GWJ->GWJ_NRPF)

		If !IsBlind()
			MsgInfo(STR0026, "") //"Pr�-fatura cancelada com sucesso."
		EndIf
	Else
		Help( ,, 'HELP',, STR0023, 1, 0,) //'Informe um motivo para o cancelamento'
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA057EMC()
Elimina��o dos movimentos cont�beis da pr�-fatura

@sample
GFEA057EMC()

@author Israel Alcantara Possoli
@since 21/08/2012
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA057EMC(cFil, cNrPf)
	dbSelectArea("GWK")
	GWK->( dbSetOrder(1) )
	GWK->( dbSeek( cFil + cNrPf ) )
	While !GWK->( Eof() ) .And. GWK->GWK_FILIAL == cFil .And. GWK->GWK_NRPF == cNrPf
		RecLock("GWK",.F.)
		dbDelete()
		MsUnLock("GWK")

		GWK->( dbSkip() )
	EndDo
Return

//----------------------------------------------------------------
// Verifica se o n�mero do transportador final e menor que o final
//----------------------------------------------------------------
Function GFEA057VX1(nPar)
	Local lret := .T.

	If nPar == 3 .OR. nPar == 4
		If posicione("GU3",1,xFilial("GU3")+If(nPar == 3,MV_PAR03,MV_PAR04),"GU3_TRANSP") == "2"
			Help( ,, 'HELP',, STR0024, 1, 0,) //'O c�digo informado n�o � de um transportador'
			lRet := .F.
		EndIf
	EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA057PAR

fun��o que executa a tela de parametros do brownse

@author Jorge Matos Valcanaia
@since 16/12/10
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA057PAR()
	Local cCond   := ""
	Local cFiltro := ""

	If !Pergunte("GFEA057",.T.)
		Return .F.
	Else
		If MV_PAR07 == 1	// Considera pendentes
			cCond += "1"
		EndIf
		If MV_PAR08 == 1	// Considera enviadas
			cCond += "2"
		EndIf
		If MV_PAR09 == 1	// Considera confirmadas
			cCond += "3"
		EndIf

		cFiltro := "GWJ_FILIAL >= '" + MV_PAR01 + "'.AND. GWJ_FILIAL <= '" + MV_PAR02 + "' .AND. GWJ_CDTRP >= '" + MV_PAR03 + "' .AND. GWJ_CDTRP <= '" + MV_PAR04 + "' .AND. GWJ_NRPF >= '" + MV_PAR05 + "' .AND. GWJ_NRPF <= '" + MV_PAR06 +"'
		cFiltro += " .AND. GWJ_SIT $ '"+cCond+"'"

		oBrowse:SetFilterDefault(cFiltro)

		dbSelectArea("GWJ")
		dbGoTop()
	EndIf

Return
