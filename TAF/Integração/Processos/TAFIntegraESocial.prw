#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFINTEGRAESOCIAL.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE TAMMAXXML 400000  //Tamanho da String de erro

Static aTAFCodErr := TAFCodErr()
Static lGerouST2  := .F.         //Variavel utilizada para identificar se o TafPrepInt gerou a TAFST2 na integra��o com o GPE.
Static __cEvtosTab := ""
Static __cEvtosMen := ""
Static __cEvtosEve := ""
Static __cEvtosTot := ""
Static __lLaySimplif := Nil  

//-----------------------------------------------------------------
/*/{Protheus.doc} TafPrepInt

API de integra��o do xml do eSocial para o TOTVS Automa��o Fiscal

@Param
	cEmpEnv 	- Empresa do registro no ERP
	cFilEnv 	- Filial do registro no ERP
	cXml		- String contendo o XML no formato do Layout do eSocial
	cKey		- Chave do registro
	cTpInteg	- Tipo da integra��o ( "1" = Online ; "2" = Banco-a-banco ; "3" - Chamada TAFAINTEG; 4 - Chamada dentro de fun��es do TAF )
	cEvento		- C�digo do Evento que est� sendo enviado ( Exemplo: S1010, S1020, S1030, etc.. )
	cXERPAlias	- Alias da tabela TAFXERP ( log de integra��o do TAF )
	cTicket		- C�digo do Ticket ( lote ) que o registro est� sendo integrado
	cStatQueue	- Indica se o registro ser� considerado na fila de integra��o. Informe 'F' para que seja
				  considerado. Enviar como par�metro para que seja retornado o status de Fila. Se mantiver
				  'F' � porque o registro foi processado com sucesso ou permanece na fila, se retornar
				  'R' � porque o erro de integra��o foi impeditivo para manter o registro na fila.
	aStsInteg	- Array para o retorno das mensagens/status de Integra��o (passagem por refer�ncia)
				  [1] - logico - determina se a mensagem � de uma integra��o bem sucedida
				  [2] - caracter - status do registro (codigo utilizado na TAFXERP)
				   	 	1 - Incluido
				   	 	2 - Alterado
				   	 	3 - Excluido
				   	 	4 - Aguardando na Fila
				   	 	8 - Filhos Duplicado
				   	 	9 - Erro
				  [3] - Codigo do Erro
				  [4] - Descri��o da Mensagem de Integra��o
	Obs: A utiliza��o deste par�metro (por refer�ncia) substitui a necessidade de avaliar o retorno da fun��o.
	Foi criado esse par�metro ao inves de alterar o retorno da fun��o por causa do legado.
	lExcluiObjs - Determina se deve ser executado a fun��o DelClassIntf para a limpeza das variaveis de interface.
	cOwner		-
	cFilTran	- 
	cPredeces	- 
	cComplem	- 
	cGrpTran	- 
	lGrpDest	- 
	lXmlIdERP	- Determina se deve utilizar o ID do XML gerado pelo ERP caso a tag exista.
	cEvtOri		- Evento de origem (Usado na gra��o dos totalizadores)
	lMigrador 	- Identifica se a origem da chamada � o Migrador.
	lDepGPE		- Identifica se trata-se de um ajuste de Dependentes para funcion�rios transferidos

@Return
	aErros	- Array contendo os erros encontrados durante a integra��o que impediram
			  a importa��o do registro. Se estiver vazio o registro foi integrado com sucesso.

@author Rodrigo Aguilar
@since 05/2015
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TafPrepInt( cEmpEnv as character, cFilEnv as character, cXml as character, cKey as character, cTpInteg as character,;
			cEvento as character, cXERPAlias as character, cTicket as character, cStatQueue as character, aStsInteg as array,;
			lExcluiObjs as logical, cOwner as character, cFilTran as character, cPredeces as character, cComplem as character,;
			cGrpTran as character, lGrpDest as logical, lXmlIdERP as logical, cEvtOri as character, lMigrador as logical,;
			lDepGPE as logical, cMatrC9V as character, lLaySmpTot as logical, cAliEvtOri as character, nRecEvtOri as numeric,;
			cFilPrev as character )

	Local aErros		as array
	Local aRet			as array
	Local aEvtTafRt		as array
	Local aSM0Area		as array
	Local cFilOri		as character
	Local cLayout		as character
	Local cTagEvt		as character
	Local cAliasReg		as character
	Local cErroXERP		as character
	Local cCodErroXERP	as character
	Local cStatusXERP	as character
	Local cTagMain		as character
	Local cOper			as character
	Local cQry			as character
	Local cStatsPrd		as character
	Local cCodErrPr		as character
	Local cErroPrd		as character
	Local cXmlID		as character
	Local cGPExERP      as character
	Local cFilTranERP   as character
	Local cGrpSigaMat	as character
	Local cFilBKP		as character
	Local cEmpBKP		as character
	Local cBancoDB    	as character
	Local cAliasQry		as character
	Local cAmbEsocial	as character
	Local nRecnoXERP	as numeric
	Local nTafRecno		as numeric
	Local nRecNoDestino as numeric
	Local nOpc			as numeric
	Local lIntTaf		as logical
	Local lIntGPE		as logical
	Local lIntMDT		as logical
	Local lIntOnline	as logical
	Local lErroXErp		as logical
	Local lProcGrp		as logical
	Local lGrTAFST2     as logical
	Local lIntTotzd		as logical
	Local lOperTransf	as logical
	Local lExclCMJ		as logical
	Local lProcessa     as logical
	Local oXml			as object
	Local oTransf		as object

	Private oHMControl	as object

	Default aStsInteg	:= {}
	Default cEmpEnv		:= ""
	Default cFilEnv		:= ""
	Default cXml		:= ""
	Default cKey		:= ""
	Default cTpInteg	:= ""
	Default cEvento		:= ""
	Default cXERPAlias	:= ""
	Default cTicket		:= ""
	Default cStatQueue	:= ""
	Default cOwner		:= ""
	Default cFilTran	:= ""
	Default cPredeces	:= ""
	Default cComplem	:= ""
	Default cEvtOri		:= ""
	Default cGrpTran	:= ""
	Default cAliEvtOri	:= ""
	Default lGrpDest	:= .F.
	Default lXmlIdERP  	:= .F. 
	Default lMigrador	:= .F. 
	Default lDepGPE		:= .F.
	Default lExcluiObjs	:= .T.
	Default lLaySmpTot  := taflayEsoc("S_01_00_00")
	Default nRecEvtOri	:= 0
	Default cFilPrev	:= ""

	aErros			:= {}
	aRet			:= {}
	aEvtTafRt		:= {}
	aSM0Area		:= SM0->(GetArea())
	cFilOri			:= ""
	cLayout			:= ""
	cTagEvt			:= ""
	cAliasReg		:= ""
	cErroXERP		:= ""
	cCodErroXERP	:= ""
	cStatusXERP		:= ""
	cTagMain		:= ""
	cOper			:= ""
	cQry			:= ""
	cStatsPrd		:= ""
	cCodErrPr		:= ""
	cErroPrd		:= ""
	cXmlID			:= ""
	cGPExERP      	:= ""
	cFilTranERP   	:= ""
	cGrpSigaMat		:= ""
	cFilBKP			:= cFilAnt
	cEmpBKP			:= cEmpAnt
	cBancoDB    	:= TCGetDB()
	cAliasQry		:= GetNextAlias()
	cAmbEsocial		:= GetNewPar("MV_TAFAMBE", "")
	lIntTaf			:= GetNewPar("MV_INTTAF", "N") == "S"
	lIntGPE			:= GetNewPar("MV_RHTAF", .F.)
	lIntMDT			:= GetNewPar("MV_NG2ESOC", "2") == "1"
	nRecnoXERP		:= 0
	nTafRecno		:= 0
	nRecNoDestino	:= 0
	nOpc			:= 3
	lIntOnline		:= .F.
	lErroXErp		:= .F.
	lProcGrp		:= .F.
	lGrTAFST2     	:= .F.
	lIntTotzd		:= .F. 
	lOperTransf		:= .F. 
	lExclCMJ		:= .F.
	lProcessa     	:= .T. 
	oXml			:= Nil
	oTransf			:= Nil 
	oHMControl		:= Nil

	TafCacheLayESoc("S_01_00_00")
	classificaEventos()

	aStsInteg 	:= Array(4)
	
	//Identifica uma Integra��o de Totalizador atraves do Job5 
	If (Right(Alltrim(cEvento),4) $ __cEvtosTot) .And. cTpInteg == "4"
		lIntTotzd := .T.
	EndIf 

	lIntOnline 	 := ( cTpInteg == '1' .Or. cTpInteg == "4" )

	//Valores Default do array de status/mensagens
	aStsInteg[1] := .T.
	aStsInteg[2] := '0'
	aStsInteg[3] := '000000'
	aStsInteg[4] := ''

	DbSelectArea("C1E")
	C1E->(Dbgotop())
	If (lIntTaf .Or. lIntGPE .Or. lIntMDT) .And. ("C1E")->(EOF()) 
		aErros :=  { "Antes de efetuar a integra��o entre m�dulos, execute o Wizard de Configura��o do TAF." } 
		Final("Antes de efetuar a integra��o entre m�dulos, favor configurar o SIGATAF.")
	Else

		If lIntGPE .And. cOwner == "GPE"

			cFilAnt := cFilEnv
			
			If cTpInteg == "3"
				
				// Caso a integra��o venha do GPE, ser� necess�rio o envio da TAFKEY.
				If (IsInCallStack("GPEA240") .Or. IsInCallStack("GPEM026B"))
					If !Empty( cKey )
						lGrTAFST2 := .T.
					Else
						aAdd( aErros, "TAFKEY n�o informado. Para essa opera��o � obrigat�rio o envio da TAFKEY!" )
						lProcessa := .F.
					EndIf
				Else
					lGrTAFST2 := .T.
				EndIf
			EndIF
			
			If lGrTAFST2
			
				cFilEnv := FTafGetFil(AllTrim(cEmpEnv)+AllTrim(cFilEnv),,,.T.)
				cFilEnv := AllTrim(Posicione('C1E',3,xFilial('C1E') + Padr( cFilEnv, TamSX3( "C1E_FILTAF" )[1] ) + "1", 'C1E_CODFIL'))
				
				cFilTaf := cFilEnv 
				
				If !Empty(cFilTran)
					cFilTranERP := FTafGetFil(AllTrim(cEmpEnv)+AllTrim(cFilTran),,,.T.)
					cFilTranERP := AllTrim(Posicione('C1E',3,xFilial('C1E') + Padr( cFilTran, TamSX3( "C1E_FILTAF" )[1] ) + "1", 'C1E_CODFIL'))
				EndIf
				
				aErros     := GeraTAFST2( cFilTaf, cXml, @cKey, @cTicket, cEvento, cPredeces, cComplem, cFilTranERP, @cGPExERP )
				
				cXERPAlias := cGPExERP
				
				If !Empty(aErros)
					lProcessa := .F.
				Else
					lGerouST2 := .T.
				EndIf
				
				lIntOnline := .F.
			EndIf
			
		EndIf
		
		If lProcessa
			//Integra��o Banco a Banco
			if !lIntOnline
			
				//Chamada da TAFAINTEG, ou seja, a informa��o deve ser integrada
				if cTpInteg $ '2|3'
			
					//Alimento cLayout com o registro da tabela TAFST2
					cLayout	:=	right( alltrim( cEvento ), 4 )
			
					//Busco o c�digo da Empresa+Filial Gravada na TAFST2
					cFilOri := alltrim( cFilEnv )
					cKey    := alltrim( cKey )
					cTicket := alltrim( cTicket )
			
					if cTpInteg == '2'
						eSocExtST1( cLayout , cXml , cEmpEnv + cFilOri , cKey , cTicket )
					endif
				endif
			//Integra��o Nativa
			else
				//** Este ponto foi refatorado por que est� condicao s� cai se for integracao ONLINE, neste sentido nao tem 
				// por que ter condicionais para outros tipos de integracao		
				cLayout	:= Right(AllTrim(cEvento), 4)
				cFilOri := Iif(cTpInteg == "4", AllTrim(cFilEnv), AllTrim(cEmpEnv) + AllTrim(cFilEnv))
				cFilTaf := FTafGetFil(cFilOri,,, .T.)
 
				if Empty(cGrpTran) 
					SM0->(MsSeek(AllTrim(cEmpEnv) + PADR(cFilTaf,FWSizeFilial())))
					cEmpAnt := SM0->M0_CODIGO
					cFilAnt := SM0->M0_CODFIL
				endIf 

			endif
		
			If !lProcGrp //Se estiver verdadeiro j� foi executado para a transferencia de grupo de empresas com a empresa destino
				
				BEGIN TRANSACTION
				
				//Tiro os espa�os em branco no inicio e final do XML e armazeno na vari�vel
				cXml := EncodeUtf8(alltrim( cXml ))
				
				if !Empty( cFilOri ) .and. cTpInteg <> '2' .Or. (cOwner == "GPE" .And. (!Empty(cGrpTran) .And. AllTrim(cEmpEnv) != AllTrim(cGrpTran)))
				
					// -----------------------------------------------------------------------------------------------------------------------------------------------------
					//Busco o Nome da fun��o que ser� utilizada na integra��o
					aEvtTafRt	:=  TAFRotinas("S-"+cLayout,4,.F.,2)
					// -----------------------------------------------------------------------------------------------------------------------------------------------------
					// --> Migrar a atribui��o de cFunction para o retorno do TAFRotinas; eliminar a fun��o xTafFunLay().
					//	Isso j� havia sido feito na entrega do requisito de valida��o <tpAmb>, por�m n�o foi mergeado corretamente e esse ajuste foi realizado durante TS.
					//	Para n�o correr o risco de parar a integra��o, se manteve a fun��o xTafFunLay().
					// **********************************
					cTagMain   :=  "/" + aEvtTafRt[9]
					// cFunction :=	aEvtTafRt[7]
					// **********************************
					cFunction	:=	xTAFFunLay( cLayout,, @cTagEvt )
					// -----------------------------------------------------------------------------------------------------------------------------------------------------
				
					//Verifica se a fun��o existe no RPO
					if findfunction( cFunction )

						//Caso seja poss�vel Parsear o XML fa�o a integra��o dos dados
						If eSocialParserXml(cXml,@oXML,lIntOnline) 

							//Para os Layouts Iniciais temos a quebra do XML de acordo com a opera��o, conforme abaixo:
							if cLayout $ __cEvtosTab
				
								//Tomar cuidado, pois � case sensitive.
								if oXml:xPathHasNode( "/" + oXML:cPath + cTAGEvt + "/inclusao" )
									nOpc := 3 //Opera��o de Inclus�o
				
								elseIf oXml:xPathHasNode( "/" + oXML:cPath + cTAGEvt + "/alteracao" )
									nOpc := 4 //Opera��o de Altera��o
				
								elseIf oXml:xPathHasNode( "/" + oXML:cPath + cTAGEvt + "/exclusao" )
									nOpc := 5 //Opera��o de Exclus�o
								endIf
				
							else
				
								//Tratamento para que quando se trate de eventos mensais/periodicos seja encontrado o caminho correto da TAG
								//de retifica��o
								cLayEven := 'S-'+cLayout
								cTAGEvt := '/' + TAFRotinas(cLayEven,4,.F.,2)[9]
				
								//Para os eventos mensais e eventuais, o que indica que � uma altera��o ou inclus�o
								//� a tag indRetificacao, ent�o fa�o as devidas verifica��es para atribuir valor ao nOpc.
								//Importante: Para esses eventos, a exclus�o � feita atrav�s do evento S-3000.
								cTagRetif := "/" + oXML:cPath + cTAGEvt + "/ideEvento/indRetif"
				
								If oXml:xPathHasNode( cTagRetif )
									If oXml:xPathGetNodeValue( cTagRetif ) == "1"
										nOpc := 3
									ElseIf oXml:xPathGetNodeValue( cTagRetif ) == "2"
										nOpc := 4
									EndIf
								EndIf
							endIf
			
							//Verifica��o se o ambiente esta configurado certo
							If oXml:xPathHasNode( "/" + oXML:cPath + cTagMain + "/ideEvento/tpAmb" ) .and. !empty( cAmbEsocial ) .and. oXml:xPathGetNodeValue( "/" + oXML:cPath + cTagMain + "/ideEvento/tpAmb" ) <> cAmbEsocial
								aErros := { "Erro de Ambiente do eSocial - O tipo de Ambiente enviado na tag <tpAmb> difere-se do Ambiente configurado no TAF." }
							ElseIf !Empty(cPredeces) .And. !lMigrador

								If 'S-' + cLayout $ "S-2230" .AND. TAFColumnPos("CM6_TAFKEY")   
									CM6->(DbSetOrder( 11 ))
									If CM6->(DbSeek( Xfilial("CM6") + Padr( cPredeces,	 TamSX3( "CM6_TAFKEY" )[1] ) + "1"))
										nTafRecno := CM6->( Recno() )
										cStatsPrd := '1'
										TAFConOut("Registro com tafkey do predecessor na tabela CM6")
									Else
										nTafRecno := 0
									EndIf
								EndIf

								If nTafRecno == 0
									//Query para buscar informa��es do registro predecessor
									cQry += "SELECT TAFRECNO, TAFSTATUS, TAFCODERR,  "

									If cBancoDB <> "INFORMIX"

										cQry += " CAST( TAFERR AS CHAR(1024)) TAFERR,"

									EndIf

									cQry += " R_E_C_N_O_ RECNO"
									cQry += " FROM TAFXERP TAFXERP "
									cQry += " WHERE TAFXERP.TAFKEY = '" + cPredeces + "' "
									cQry += " AND TAFXERP.D_E_L_E_T_ = '' "
									cQry += " ORDER BY TAFXERP.R_E_C_N_O_ DESC "
					
									cQry := ChangeQuery(cQry)
					
									DbUseArea(.T., "TOPCONN", TcGenQry(,, cQry), cAliasQry, .F., .T.)
					
									DbSelectArea(cAliasQry)
									(cAliasQry)->(dbGoTop())

									nTafRecno	:= (cAliasQry)->TAFRECNO
									cStatsPrd	:= (cAliasQry)->TAFSTATUS
									cCodErrPr	:= (cAliasQry)->TAFCODERR

									If cBancoDB == "INFORMIX" 
									
										FOpnTabTAf("TAFXERP", "TAFXERP")
										TAFXERP->(DBGoTo((cAliasQry)->RECNO))

										cErroPrd := AllTrim(TAFXERP->TAFERR)

									Else
										cErroPrd 	:= (cAliasQry)->TAFERR
									EndIf							
								
									lErroXErp := !Empty(cCodErrPr)

									If nTafRecno > 0 .AND. 'S-' + cLayout $ "S-2230" 
										TAFConOut("Registro com predecessor na tabela TAFXERP")
									EndIf

								EndIf

								//Verifico se o registro predecessor se encontra na TAFXERP
								If nTafRecno == 0 .AND. (cAliasQry)->(EOF()) 
									cCodErroXERP	:= "000030" //Registro n�o integrado devido erro de Predecess�o. Duplo clique para mais informa��es!
									aErros 		    := { "Erro de Predecess�o. N�o foi poss�vel encontrar o registro predecessor '" + Alltrim(cPredeces) + "' na tabela TAFXERP." }
									cErroXERP 		:= aErros[1]
								//Verifico se o registro predecessor se encontra integrado com sucesso
								ElseIf !cStatsPrd $ "1|2|3|" .OR. lErroXErp
									//Monto a mensagem de erro de predecess�o
									cErroPrd := Alltrim(cCodErrPr) + ": " + Alltrim(cErroPrd)
				
									cCodErroXERP	:= "000030" //Registro n�o integrado devido erro de Predecess�o. Duplo clique para mais informa��es!
									aErros 		:= { "Erro de Predecess�o. O registro predecessor '" + Alltrim(cPredeces) + "' n�o foi integrado devido ao seguinte erro: '" + cErroPrd + "'" }
									cErroXERP 		:= aErros[1]
								Else

									TafHMControl(@oHMControl, 'S-' + cLayout )

									If lXmlIdERP
										cXmlID := oXml:xPathGetAtt( "/" + oXML:cPath + cTagMain, "Id" )	
									EndIf 

									aRet := &(cFunction + "( cLayout, @nOpc, cFilOri, oXml, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpEnv, cFilEnv, cXmlID,cEvtOri,lMigrador, lDepGPE,cKey,,lLaySmpTot)")
									aErros	   := aRet[02]
								Endif
		
								(cAliasQry)->(DbCloseArea())
		
							Else
								TafHMControl(@oHMControl, 'S-' + cLayout )

								If lXmlIdERP
									cXmlID := oXml:xPathGetAtt( "/" + oXML:cPath + cTagMain, "Id" )
								EndIf 

								if cOwner == "GPE" .and. cLayout $ "2200|2300" .and. (!empty(cGrpTran) .or. !empty(cFilTran)) 
									oTransf := analisaTransferencia(oXML,cEmpEnv,cFilEnv,cOwner,cGrpTran,cFilTran,cLayout,aEvtTafRt[10],cMatrC9V)
									
									TAFConOut("Parametros da transferencia")
									TAFConOut(CRLF + oTransf:getJson())
									
									if oTransf != Nil 
										if !oTransf:isTransferGroup()
											if oTransf:thereIsError()
												cCodErroXERP := oTransf:getErrorCode()
												aAdd(aErros,oTransf:getErrorDescription())
											else 

												cGrpSigaMat := iif(empty(cGrpTran),cEmpEnv,cGrpTran)

												if SM0->(MsSeek(PADR(cGrpSigaMat,2) + PADR(cFilTran,FWSizeFilial())))
													cEmpAnt := SM0->M0_CODIGO
													cFilAnt := SM0->M0_CODFIL
												else
													cCodErroXERP := '000009'
													aAdd(aErros,'Filial de Transfer�ncia n�o encontrada no arquivo de empresa')
												endif 
											endif 
		
											cFilOri := Alltrim(cEmpEnv) + AllTrim(cFilTran) //trocar pela fun��o que busca a filial do ERP
											cFilTran := ""
										endIf 

										lOperTransf := .T. 
									else
										cCodErroXERP := '000009'
										aAdd(aErros,'A Classe TafTransfTrab n�o foi encontrada no reposit�rio de dados.')
									endIf 
								endif

								If len(aErros) == 0

									If (lOperTransf .And. oTransf:isTransferGroup())
										aRet := StartJob("TafGrpThr",GetEnvServer(),.T.,cFunction,cLayout,@nOpc,cFilOri,cXml,cOwner,cFilTran,cGrpTran,cEmpEnv,cFilEnv,cXmlID,cEvtOri,lDepGPE,cKey,cMatrC9V,oTransf:getJson(),lIntOnline)
										nRecNoDestino := aRet[03]
									Else 
										aRet := &(cFunction + "(cLayout, @nOpc, cFilOri, oXml, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpEnv, cFilEnv, cXmlID, cEvtOri, lMigrador, lDepGPE, cKey, cMatrC9V, lLaySmpTot, @lExclCMJ, oTransf, cXml, cAliEvtOri, nRecEvtOri, cFilPrev)")
									EndIf 

									if aRet[01] 
										if lOperTransf 
											gravaRastroTransf(oTransf,nRecNoDestino)
											if oTransf:thereIsError()
												cCodErroXERP := oTransf:getErrorCode()
												aAdd(aErros,oTransf:getErrorDescription())
												DisarmTransaction()
											endIf  
										endIf
									else
										if cLayout $ "2200|2300" 
											//O controle de transa��o foi retirado  dos fontes TAFA278 e TAFA279 por conta do processo de transfer�ncia
											//J� tem um BENGIN TRANSACTION aqui na TafprepInt, quando h� transfer�ncia o processo s� acaba ap�s a func�o gravaRastroTransf
											//desta maneira mesmo se a fun��o Grv retornar True ainda pode ser necess�rio dar um rollback na transa��o
											DisarmTransaction() 
										endIf 
										aErros := aRet[02]
									endIf 
								endIf 

								if oTransf != Nil 
									freeObj(oTransf)
								endIf 
							endIf

							//Monta a mensagem que ser� gravada na TAFXERP ou retornada ao SIGAGPE ( quando integra��o online ) e o status que ser� registrado na TAFXERP
							If len( aErros ) > 0
				
								//Tratamento de erro para o evento de afastamento (S-2230)
								If !Empty(cPredeces) .AND. Empty(cCodErroXERP) .AND. Alltrim(cEvento) == "S-2230" .AND. cStatQueue == "F"
									cCodErroXERP := "000031"
									cErroXERP := aErros[1]
								EndIf
		
								//Ignoro a busca do c�digo, se o erro estiver relacionado a predeces�o ou regras do afastamento
								If !cCodErroXERP $ "000030|000031|"
									cCodErroXERP := eSoc2ErrInt( upper(aErros[ 1 ] ), @cErroXERP )
								EndIf
		
								If Empty( cCodErroXERP )
				
									If upper( substr( aErros[ 1 ] , 1 , 3 ) ) == 'DIC' // Verifica��o para valida��o de ambiente desatualizado
				
										cCodErroXERP := "000006" //"Ambiente Desatualizado, o cadastro referente ao evento n�o existe no reposit�rio de dados do ambiente."
				
									Else
										cCodErroXERP := "000009"// "Registro n�o integrado. Duplo clique para mais informa��es!"
										cErroXERP := aErros[1]
									EndIf
								EndIf
				
								getQueueProc( @cStatusXERP , @cStatQueue , cCodErroXERP )
				
								If !lIntOnline
									TafGrvTick( cXERPAlias , "1" , cKey , cTicket , , , cStatusXERP , cCodErroXERP  , cErroXERP )
									lGerouST2 := .F.
								EndIf
				
								aStsInteg[1] := .F.
							Else
				
								//|Funcao para verificar o status atual do registro a ser manutenido,  |
								//|retornando o codigo da operacao que sera realizada na sequencia   	 |
								//|Opcoes de retorno do nOpc:												 |
								//|3 - Inclus�o																 |
								//|4 - Alterar, registro nao transmitido									 |
								//|5 - Excluir, registro nao transmitido	     							 |
								//|6 - Alterar, registro ja transmitido  							 		 |
								//|7 - Excluir, registro ja transmitido								 	 |
								//|9 - Nenhuma Opera��o Realizada                          				 |
				
								//Opera��o de Altera��o
								if nOpc == 4 .Or. nOpc == 6
									cOper := '2'
				
								//Opera��o de Inclus�o
								elseif nOpc == 3
									cOper := '1'
				
								//Opera��o de Exclus�o
								elseif nOpc == 5 .Or. nOpc == 7
									cOper := '3'
				
								//Filhos Duplicados
								elseif nOpc == 8
									cOper := '8'
				
								//Nenhuma Opera��o Realizada
								else
									cOper := '9'
				
								endif
				
								// -----------------------------------------------------------------------------------------------------------------------------------------------------
								// --> Migrar a atribui��o de cAliasReg para o retorno do TAFRotinas; eliminar a fun��o xTafFunLay().
								//	Isso j� havia sido feito na entrega do requisito de valida��o <tpAmb>, por�m n�o foi mergeado corretamente e esse ajuste foi realizado durante TS.
								//	Para n�o correr o risco de parar a integra��o, se manteve a fun��o xTafFunLay().
								// **********************************
								// //cAliasReg  := aEvtTafRt[3]
								// **********************************
								cAliasReg  := xTAFFunLay( cLayout, 4 )
								// -----------------------------------------------------------------------------------------------------------------------------------------------------
				
								nRecnoXERP := (cAliasReg)->( Recno() )
				
								if cOper <> '8' .and. cOper <> '9'
									if !lIntOnline
										TafGrvTick( cXERPAlias, "1", cKey, cTicket, cAliasReg, nRecnoXERP, cOper,,,,, lExclCMJ  )
										cStatQueue := ''
									endif
				
									aStsInteg[1] := .T.
									cStatusXERP := cOper
									cCodErroXERP := ""
									cErroXERP := ""
								else
				
									//Opera��o Incorreta
									if cOper == '9'
										cCodErroXERP := "000007"
										cErroXERP := 'XML Solicita uma opera��o incorreta na base de dados do TAF, verifique o cadastro.'
									else
										cCodErroXERP := "000008"
										cErroXERP := 'A informa��o que esta sendo integrada j� se encontra no TAF. Existem TAG�s do XML com chave duplicada que s�o impeditivos para a integra��o.'
									endif
				
									if !lIntOnline
				
										getQueueProc( @cStatusXERP , @cStatQueue , cCodErroXERP )
										TafGrvTick( cXERPAlias, "1", cKey, cTicket,,, cStatusXERP , cCodErroXERP )
									else
				
										aAdd( aErros, 'ERRO[' + cCodErroXERP + ']: ' + cErroXERP )
									endif
				
									aStsInteg[1] := .F.
								endif
				
							Endif
						Else

							If Empty( cXml ) 
								cCodErroXERP := "000032"
								cErroXERP    := STR0037 //"N�o foi poss�vel realizar o Parser no arquivo."	
							Else 
								cCodErroXERP := "000001"
								cErroXERP := oXML:Error()
							EndIf 

							getQueueProc( @cStatusXERP , @cStatQueue , cCodErroXERP )
				
							if !lIntOnline
								TafGrvTick( cXERPAlias, "1", cKey, cTicket,,, cStatusXERP , cCodErroXERP )
							else
								//Alimento o Array de Erro quando o Parser n�o � realizado por erro no XML
								aAdd( aErros, 'ERRO[' + cCodErroXERP +']: ' + cErroXERP )
							endif
				
							aStsInteg[1] := .F.
						Endif
				
					//Tratamento para caso n�o exista a fun��o de integra��o do cadastro compilada no RPO
					else
				
						cCodErroXERP := "000006"
						cErroXERP := "Fun��o " + cFunction + " n�o encontrada no Reposit�rio de dados do ambiente."
						getQueueProc( @cStatusXERP , @cStatQueue , cCodErroXERP )
				
						if !lIntOnline
							TafGrvTick( cXERPAlias, "1", cKey, cTicket,,, cStatusXERP , cCodErroXERP )
						else
							aAdd( aErros, "ERRO[" + cCodErroXERP +"]: " + cErroXERP)
						endif
				
						aStsInteg[1] := .F.
					endIf
				
				elseif cTpInteg <> '2'
				
					cCodErroXERP := "000002"
					cErroXERP := "Filial n�o cadastrada no Cadastro de Complemento de Empresa do TAF."
					getQueueProc( @cStatusXERP , @cStatQueue , cCodErroXERP )
		
					if !lIntOnline
						TafGrvTick( cXERPAlias, "1", cKey, cTicket,,, cStatusXERP , cCodErroXERP )
					else
						aAdd( aErros, 'ERRO[' + cCodErroXERP + ']: ' + cErroXERP )
					endif
					aStsInteg[1] := .F.
				
				endif
				
				END TRANSACTION
		
			endIf
		
			aStsInteg[2] := cStatusXERP
			If cCodErroXERP != Nil
				aStsInteg[3] := cCodErroXERP
			EndIf
			If cErroXERP != Nil
				aStsInteg[4] := cErroXERP
			EndIf
			
			If oXml != Nil 
				FreeObj(oXml)
			Endif
			/*
			oXml := Nil
			
			If lExcluiObjs
				delClassIntF()
			EndIf */
		
			//Quando a Tabela � compartilhada est� desposicionando o cEmpAnt e cFilAnt
			RestArea(aSM0Area)
			cFilAnt	:=	cFilBKP
			cEmpAnt	:=	cEmpBKP
		EndIf
	Endif

	If !Empty(cGPExERP)
		(cGPExERP)->(DbCloseArea())
	EndIf

	If lIntGPE .And. cOwner == "GPE"
		cFilAnt	:=	cFilBKP
		cEmpAnt	:=	cEmpBKP
	EndIf

return ( aErros )

//--------------------------------------------------------------------
/*/{Protheus.doc} eSocialParserXml
Realizar o Parser do XML e-Social 

@param cXML - Xml eSocial
@param oXML - Objeto XML (refer�ncia)
@param lIntOnline - Indica se a Integra��o � Online

@Return lParser - Indica se o Parser foi bem sucedido 

@Author Evandro dos Santos Oliveira
@Since 20/04/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function eSocialParserXml(cXml,oXML,lIntOnline)

	Local cBancoDB := Upper(AllTrim(TcGetDB()))
	Local lParser := .F.

	If  !Empty( cXml )

		oXML := tXmlManager():New()

		If cBancoDB == "ORACLE" .And. !Empty(cXml) 
			cXml := StrTran(cXml,Chr(13),"")
			cXml := StrTran(cXml,Chr(10),"")

			//Tratamento para integra��o Oracle onde o XML vem com o �ltimo caracter faltando
			If Substr( Alltrim( cXml ), Len( cXml ), 1 ) <> ">"
				cXml += ">"
			EndIf
		EndIf

		lParser :=  oXML:Parse( FTrocaPath(cXml,"eSocial") )

		If !lIntOnline
			oXml:bDecodeUtf8 := .T.
		EndIf
	EndIf 
	
Return lParser

//--------------------------------------------------------------------
/*/{Protheus.doc} classificaEventos
Realiza a Separa��o dos evento de acordo com o seu tipo 

@Return Nil

@Author Evandro dos Santos Oliveira
@Since 20/04/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
static Function classificaEventos()

	local aRotinasTAF := {}
	local nRot := 0

	if empty(__cEvtosTab)

		aRotinasTAF := TAFRotinas(,,.T.,2)

		for nRot := 1 To Len(aRotinasTAF)
			//Para permitir a compatibilidade do fonte tive que tirar o S- dos enventos
			//Algumas linhas fazer a integra��o sem o -
			If aRotinasTAF[nRot][4] != 'TAUTO' .and. !Empty(aRotinasTAF[nRot][4])
				do Case 
					case aRotinasTAF[nRot][12] == "C"
						__cEvtosTab += right(alltrim(aRotinasTAF[nRot][4]),4) + "|" 
					case aRotinasTAF[nRot][12] == "M"
						__cEvtosMen += right(alltrim(aRotinasTAF[nRot][4]),4) + "|" 
					case aRotinasTAF[nRot][12] == "E"
						__cEvtosEve += right(alltrim(aRotinasTAF[nRot][4]),4) + "|" 
					case aRotinasTAF[nRot][12] == "T"
						__cEvtosTot += right(alltrim(aRotinasTAF[nRot][4]),4) + "|"
				end Case
			endIf 
		next nRot 
	endIf 

	aRotinasTAF := {} 

return Nil 


//--------------------------------------------------------------------
/*/{Protheus.doc} TAFGeraS3000
Funcao de gera��o do evento do e-Social S-3000(Exclus�o de Eventos)

@Param  aCampos -> Campos a serem gravado na CMJ
		cEvento -> Nome do evento de exclus�o

@Return .T.

@Author Vitor Henrique Ferreira
@Since 30/10/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFGeraS3000(aCampos, cEvento)

	Local nI	:= 0
	Local cMsg	:= STR0002 + cEvento + STR0003

	Default aCampos	:= {}
	Default cEvento	:= ""

	If !Aviso( STR0001, cMsg, { STR0004, STR0005 }, 1 ) == 2 //"Ao exclui-lo sera gerado um evento de exclus�o(S-3000), para o "cEvento". Deseja realmente realizar a exclus�o do item ?" ##"Excluir" ##"Manter"
		DbselectArea('CMJ')
		If RecLock( 'CMJ', .T. )
			For nI := 1 to Len(aCampos)
				CMJ->&(aCampos[nI][1]) := aCampos[nI][2]
			Next
			CMJ->( MsUnlock() )
		EndIf

		CMJ->(dbCloseArea())
	EndIf


Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} xTafVExc
Cria uma interface para a exclus�o do registro S-3000 e realiza
as valida��es e manuten��es necess�rias no envento gerador.

@Param  cAlias	- Alias do Browse
		 nReg 	- Registro posicionado no Browse
		 nOpc	- Opera��o de Manuten��o

@Return Nil

@Author Evandro dos Santos Oliveira
@Since 12/11/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Function xTafVExc(cAlias, nReg, nOpc)

	Local cTitulo		:= 'Exclus�o de Evento'
	Local cNmFun		:= Iif(FindFunction("TafSeekRot"), TafSeekRot(cAlias), FunName())
	Local cEvento		:= ""
	Local cTpEvt		:= ""
	Local cTrab			:= ""
	Local cCpf			:= ""
	Local cNis			:= ""
	Local cIdEv			:= ""
	Local cMens			:= STR0028
	Local cChave		:= ""
	Local cProtUl		:= ""
	Local cIdTrab		:= C9V->C9V_ID
	Local cCpoFilial	:= ""
	Local cCpoProtPn	:= ""
	Local cAliasQry		:= ""
	Local cQuery		:= ""
	Local cProtPn   	:= ""
	Local cAliasCMJ		:= ""
	Local cSelect   	:= ""
	Local cFrom     	:= ""
	Local cWhere    	:= ""
	Local cFilBKP		:= cFilAnt
	Local aTable		:= {}
	Local cTpEven		:= ""
	Local cDescEv       := ""
	Local cProctr		:= ""
	Local cCpfTrb		:= ""
	Local cRecib		:= ""
	Local cPerApu		:= ""

	Local aEvtEx		:= {}
	Local aTafRotn		:= TAFRotinas( cNmFun,1,.F.,2)
	Local aArea			:= GetArea()
	Local aAreaC9V		:= Nil
	Local aAreaV7J		:= Nil
	Local aAreaT62		:= Nil
	Local aOpcoes		:= {}
	Local aDadEvent		:= {}

	Local nOper			:= 3
	Local nValor		:= 1
	Local nRegOrig		:= nReg
	Local nOpcSelec		:= 0
	Local nRet			:= 0
	Local nInd			:= Iif(aTafRotn[4] $ "S-2410|S-2416|S-2418|S-2420", 2, 1)
	Local nOption		:= 0

	Local lView		 	:= .F.
	Local lOk		 	:= .F.
	Local lRegras	 	:= .T.
	Local lExclus	 	:= .T.
	Local lTransf	 	:= .F.
	Local lFuncAtivo 	:= .T. 

	local oModel		:= Nil
	Local oModelT1U		:= Nil
	Local oModelT1V		:= Nil
	Local oModelT0F		:= Nil
	Local oModelCMJ		:= Nil
	Local oModelV7J		:= Nil

	Local nCM0Recno
	Local dDataDesl 
	Local aDeslig 		:= {}


	Private nRecno		:= nReg
	Private aSX9Rel 	:= {}

	Default cAlias		:= ""
	Default nReg		:= 0
	Default nOpc		:= 1

	TafCacheLayESoc("S_01_00_00")

	//Controle se o evento � extempor�neo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	If cNmFun $ "TAFA278|TAFA279" //Cadastro do Trabalhador

		cEvento := Substr(C9V->C9V_NOMEVE,1,1) + "-" + Substr(C9V->C9V_NOMEVE,2)

		If cEvento == "S-2200"

			If TAFColumnPos( "C9V_IDTRAN" ) .And. C9V->C9V_ATIVO == "2" .And. C9V->C9V_IDTRAN <> ''
				lTransf := .T.
			Else
				If !lGoExtemp
					cAlias	:= "C9V"

					aAdd(aOpcoes, STR0029) //Verifica se tem o S2200

					DbSelectArea("T1U")	
					If RetUltAtivo( 'T1U', C9V->C9V_ID + "1", 2 )	//Verifica se tem o S2205 e posiciona na ultima altera��o
						aAdd(aOpcoes, STR0030)
					EndIf
					
					DbSelectArea("T1V")	
					If RetUltAtivo( 'T1V', C9V->C9V_ID + "1", 2 )	//Verifica se tem o S2206 e posiciona na ultima altera��o
						aAdd(aOpcoes, STR0031)
					EndIf
					
				Else
					If cAlias == "T1U"
						aAdd(aOpcoes, STR0030)
					ElseIf cAlias == "T1V"
						aAdd(aOpcoes, STR0031)
					EndIf
				EndIf

				If !Isblind()
					nOpcSelec := SelecOpc(aOpcoes,,"2",cTitulo,cMens,@lOk )
					cNmFun		:= ""
				Else
					If cNmFun == 'TAFA278'
						nOpcSelec := 2
						lOk := .T.
					EndIf
				EndIf

				If nOpcSelec == 2 .or. nOpcSelec == 8 //S2200
					cNmFun := "TAFA278"
				ElseIf nOpcSelec == 4 //S-2205
					cNmFun  := "TAFA275"
					cAlias  := "T1U"
					cEvento := "S-2205"
				ElseIf nOpcSelec == 5 //S-2206
					cNmFun := "TAFA276"
					cAlias := "T1V"
					cEvento := "S-2206"
				EndIf
			EndIf
			
		ElseIf cEvento == "S-2300"

			If TAFColumnPos( "C9V_IDTRAN" ) .And. C9V->C9V_ATIVO == "2" .And. !Empty(C9V->C9V_IDTRAN)
				lTransf := .T.
			Else
				If !lGoExtemp

					aAdd(aOpcoes, STR0032) // S-2300

					DbSelectArea("T0F")
					If RetUltAtivo( 'T0F', C9V->C9V_ID + "1", 2 ) //Verifica se tem o S-2306
						aAdd(aOpcoes, STR0033)
					EndIf

					DbSelectArea("T1U")
					If RetUltAtivo( 'T1U', C9V->C9V_ID + "1", 2 ) //Verifica se tem o S-2205
						aAdd(aOpcoes, STR0030)
					EndIf
				Else
					If cAlias == "T0F"
						aAdd(aOpcoes, STR0033)
					EndIf
				EndIf

				If!Isblind()
					nOpcSelec := SelecOpc(aOpcoes,,"2",cTitulo,cMens,@lOk )
					cNmFun	:= ""
				Else
					If cNmFun == 'TAFA279'
						nOpcSelec := 2
						lOk := .T.
					EndIf
				EndIf

				If nOpcSelec == 3 .or. nOpcSelec == 9 //S-2300
					cNmFun := "TAFA279"
				ElseIf nOpcSelec == 4 //S-2205
					cNmFun  := "TAFA275"
					cAlias  := "T1U"
					cEvento := "S-2205"
				ElseIf nOpcSelec == 6 //S-2306
					cNmFun := "TAFA277"
					cAlias := "T0F"
					cEvento := "S-2306"
				EndIf
			EndIf
		EndIf

		If lOk .And. !Empty(cNmFun)

			cCpf	:= &(cAlias+"->"+cAlias+"_CPF")

			If !__lLaySimplif
				If FindFunction("TAF250Nis")
					cNis	:= TAF250Nis(C9V->C9V_FILIAL, C9V->C9V_ID, C9V->C9V_NIS)
				Else
					cNis	:= C9V->C9V_NIS
				EndIf
			EndIf

			nReg 	:= (cAlias)->(Recno())

			if nOpc == 1
				cProtUl := PADR(AllTrim(&(cAlias+"->"+cAlias+"_PROTUL")),GetSx3Cache("C9V_PROTUL","X3_TAMANHO"))
			Elseif nOpc == 2 .or. nOpc == 3
				cProtUl := PADR(AllTrim(&(cAlias+"->"+cAlias+"_PROTPN")),GetSx3Cache("C9V_PROTPN","X3_TAMANHO"))
			Endif
			cTrab	 := cAlias + "_ID"
			nRecno	 := nReg

		Else
			lRegras := .F.
		EndIf

	ElseIf cNmFun $ "TAFA592|TAFA593|TAFA594|TAFA595"

		If !lGoExtemp

			aOpcoes := TAF591Events("xTafVExc")

		Else

			If cAlias == "V76"
				aAdd( aOpcoes, "S-2416 Benef�cio - Altera��o" )
			ElseIf cAlias == "V77"
				aAdd( aOpcoes, "S-2418 Reativa��o de Benef�cio" )
			ElseIf cAlias == "V78"
				aAdd( aOpcoes, "S-2420 Benef�cio - T�rmino" )
			EndIf

		EndIf

		If !Empty(aOpcoes)

			If !isBlind()
				nOption := TAF591OptBen(aOpcoes, , cTitulo, cMens, @lOk )
			Else

				If cAlias == "V75"

					cNmFun := "TAFA592"
					cEvento := "S-2410"

				ElseIf cAlias == "V76"

					cNmFun := "TAFA593"
					cEvento := "S-2416"

				ElseIf cAlias == "V77"

					cNmFun := "TAFA594"
					cEvento := "S-2418"

				ElseIf cAlias == "V78"

					cNmFun := "TAFA595"
					cEvento := "S-2420"

				EndIf

				If !Empty(cNmFun)
					lOk := .T.
				EndIf

			EndIf

			If nOption == 9 
				cNmFun := "TAFA592"
				cAlias := "V75"
				cEvento := "S-2410"
			ElseIf nOption == 10 
				cNmFun := "TAFA593"
				cAlias := "V76"
				cEvento := "S-2416"
			ElseIf nOption == 11
				cNmFun := "TAFA594"
				cAlias := "V77"
				cEvento := "S-2418"
			ElseIf nOption == 12
				cNmFun := "TAFA595"
				cAlias := "V78"
				cEvento := "S-2420"
			EndIf

			If lOk .And. !Empty(cNmFun)

				cCpf	:= &(cAlias+"->"+cAlias+"_CPFBEN")
				nReg 	:= (cAlias)->(Recno())
				
				If nOpc == 1
					cProtUl := PADR(AllTrim(&(cAlias+"->"+cAlias+"_PROTUL")),GetSx3Cache("C9V_PROTUL","X3_TAMANHO"))
				ElseIf nOpc == 2 .or. nOpc == 3
					cProtUl := PADR(AllTrim(&(cAlias+"->"+cAlias+"_PROTPN")),GetSx3Cache("C9V_PROTPN","X3_TAMANHO"))
				EndIf

				cTrab	 := cAlias + "_ID"
				nRecno	 := nReg

			Else
				lRegras := .F.
			EndIf

		Else
				
			Aviso( STR0008, "N�o � poss�vel desfazer a exclus�o do evento S-3000 Transmitido ou Aceito RET.", { STR0010 }, 2 )

		EndIf

	 ElseIf cNmFun $ "TAFA610"
	 	lOk := .T.
	 	cEvento := aTafRotn[4]
		
	 	aAreaV7J	:= V7J->(GetArea())
	 	cCpf		:= V7J->V7J_CPF
	 	RestArea(aAreaV7J)

	Else
		lOk := .T.
		cEvento := aTafRotn[4]
		cTrab   := aTafRotn[3]+"->"+aTafRotn[11]
		If cEvento $ "|S-2210|S-2220|S-2240|"
			cCpf    := 	SubStr(GatMatSST(&cTrab,.F.,cAlias),1,11)
		ElseIf cEvento $ "S-1207"
			aAreaT62	:= T62->(GetArea())
			cCpf	:= AllTrim(Posicione("T62",5,xFilial("T62", &(cAlias+"->"+cAlias+"_FILIAL"))+&cTrab + '1',"T62_CPF"))
			RestArea(aAreaT62)
		ElseIf !(cEvento $ "|S-1280|S-2190|S-1220|S-1270|S-1250|S-1260|S-1295|TAUTO|S-1300|")
			If cEvento $ "S-2300|S-2399"
				cCpf	:= AllTrim(Posicione("C9V",16,xFilial("C9V", &(cAlias+"->"+cAlias+"_FILIAL"))+&cTrab + 'S2300' + '1',"C9V_CPF"))
			ElseIf __lLaySimplif .And. cEvento $ "S-1200"
				If &(cAlias+"->"+cAlias+"_ORIEVE") $ "S2190"
					cCpf	:= AllTrim(Posicione("T3A",3,xFilial("T3A", &(cAlias+"->"+cAlias+"_FILIAL"))+&cTrab + '1',"T3A_CPF"))
				Else
					cCpf	:= AllTrim(Posicione("C9V",2,xFilial("C9V", &(cAlias+"->"+cAlias+"_FILIAL"))+&cTrab + '1',"C9V_CPF"))
				EndIf
			ElseIf !(cEvento $ "S-2400|S-2405")
				cCpf	:= AllTrim(Posicione("C9V",2,xFilial("C9V", &(cAlias+"->"+cAlias+"_FILIAL"))+&cTrab + '1',"C9V_CPF"))
			EndIf

			If !(cEvento $ "S-1210|S-2400|S-2405") .AND. !__lLaySimplif
				If FindFunction("TAF250Nis")
					cNis	:= TAF250Nis(C9V->C9V_FILIAL, C9V->C9V_ID, C9V->C9V_NIS)
				Else
					cNis	:= C9V->C9V_NIS
				EndIf
			EndIf

			If Empty( &cTrab ) .And. cEvento == "S-1200"
				cCpf := C91->C91_CPF
				If !__lLaySimplif
					If FindFunction("TAF250Nis")
						cNis	:= TAF250Nis(C9V->C9V_FILIAL, C9V->C9V_ID, C9V->C9V_NIS)
					Else
						cNis	:= C9V->C9V_NIS
					EndIf
				EndIf
			EndIf

			If Empty( cCpf ) .And. cEvento $ "S-2400|S-2405"
				cCpf := V73->V73_CPFBEN
			EndIf

		Endif
		IF nOpc == 1
			cProtUl := PADR(AllTrim(&(cAlias+"->"+cAlias+"_PROTUL")),GetSx3Cache(cAlias+"_PROTUL","X3_TAMANHO"))
		ElseIF nOpc == 2 .or. nOpc == 3
			cProtUl := PADR(AllTrim(&(cAlias+"->"+cAlias+"_PROTPN")),GetSx3Cache(cAlias+"_PROTPN","X3_TAMANHO"))
		Endif
	Endif

	If !lTransf .And. lOk

		cTpEvt	 := aTafRotn[12]
		dbSelectArea("C8E")
		C8E->(dbSetorder(2))
		If msSeek( xFilial("C8E") + cEvento )
			cDescEv := C8E->C8E_DESCRI
			cIdEv 	:= C8E->C8E_ID
		Endif
		C8E->( DbCloseArea() )

		cFilAnt := &(cAlias+"->"+cAlias+"_FILIAL")
		//Se selecionado op��o 1 no menu(Excluir)
		If nOpc == 1
			If &(cAlias+"->"+cAlias+"_STATUS") $ '4' .AND. &(cAlias+"->"+cAlias+"_EVENTO") <> "E" .And. cEvento <> "TAUTO"
				If cEvento == "S-2190"
				/*	+-------------------------------------------------------------------------+
					| **Regra Evento 2190									         		  |
					| N�o � poss�vel a exclus�o de evento de admiss�o preliminar se j� houver |
					| evento de admiss�o S-2200 referenciando esta mesma admiss�o. Neste caso |
					| � necess�rio excluir, primeiramente, o evento de admiss�o "definitivo"  |
					| (S-2200), para, em seguida, excluir o evento de admiss�o "preliminar".  |
					+-------------------------------------------------------------------------+ */
					C9V->( DbSetOrder(3) )
					If C9V->( MsSeek(xFilial("T3A", &(cAlias+"->"+cAlias+"_FILIAL"))+ T3A->T3A_CPF +"1") )
						If C9V->C9V_STATUS $ '246'

							aDeslig := TafGetDesligamentos( T3A->T3A_CPF, T3A->T3A_MATRIC, .T.)

							If Len(aDeslig) > 0

								//O primeiro item sempre � o ultimo desligamento
								dDataDesl := STOD(aDeslig[2])
								If  dDataDesl > T3A->T3A_DTADMI
									lFuncAtivo := .F.
								EndIf 
							
							Else 							
								C9V->( DbSetOrder(12))
								If C9V->( MsSeek(xFilial("T3A", &(cAlias + "->" + cAlias + "_FILIAL")) + T3A->T3A_CPF + T3A->T3A_MATRIC + "1" ) )
									lFuncAtivo := .F.
								Else									
									C9V->( DbSetOrder(20) )
									If C9V->( MsSeek(xFilial("T3A", &(cAlias + "->" + cAlias + "_FILIAL")) + T3A->T3A_CPF + T3A->T3A_MATRIC + "S2300" + "1" ) )
										lFuncAtivo := .F.
									EndIf
								EndIf
							Endif 

							If !lFuncAtivo
								Aviso( STR0008, STR0011 + CRLF + STR0012 , { STR0010 } , 2 ) 	//"Exclus�o de eventos n�o cadastrais"
																								//# "N�o � poss�vel excluir o evento de admiss�o preliminar por que existe um
																								//registro de admiss�o/cadastro vinculado a esse funcionario "
																								//# "A��o: Excluir primeiramente o evento de Admiss�o (2200)"
																								// ou evento de cadastro do Trabalhador sem vinculo - TSV (2300)
								lRegras := .F.
							EndIf 

						EndIf
					EndIf
				EndIf   

				If cEvento == "S-2300"
				/*	+-------------------------------------------------------------------------+
					| **Regra Evento 2300									         		    	|
					| A exclus�o do evento s2300 n�o pode ser feita caso j� houver		  		|
					| outro evento trabalhista posterior para o mesmo CPF/V�nculo.				|
					+-------------------------------------------------------------------------+*/
					aAreaC9V	:= C9V->(GetArea())


					DBSelectArea("T92")
					T92->(DBSetOrder(3))
					// Verifica se existe existe evento de termino para o trabalhador S-2399
					If T92->(DBSeek(xFilial("T92", &(cAlias+"->"+cAlias+"_FILIAL"))+ C9V->C9V_ID + "1"))
						If !(T92->T92_STATUS $ "7")
							Aviso( STR0008, STR0020 + CRLF + STR0021 , { STR0010 } , 2 ) 	//"Exclus�o de eventos n�o cadastrais"
																							//# "N�o � permitido realizar a exclus�o do registro do
																							//trabalhador sem v�nculo (s2300), pois existem outros
																							//eventos trabalhistas vinculados para o mesmo CPF."
																							//# "A��o: Excluir primeiramente o evento Altera��o
																							//Contratual (2306) ou T�rmino (2399)."

							lRegras := .F.
						EndIf
					EndIf

					RestArea(aAreaC9V)
				EndIf

				If (cEvento == "S-3000" .And. CMJ->CMJ_STATUS $ ( "2|4" )) .OR. (cEvento == "S-3500" .And. V7J->V7J_STATUS $ ( "2|4" ))
					If isBlind()
						lRegras := .F.
					Else
						Aviso("Exclus�o de eventos n�o cadastrais", "Esse registro ja foi transmitido, portando n�o pode ser exclu�do.")
						lRegras := .F.
					EndIf
				EndIf

				dbSelectArea(cAlias)
				dbGoto(nReg)

				If lRegras
					If TafAtualizado(,cNmFun)
					 	If !(cNmFun $ "TAFA609|TAFA608|")
							If  isBlind() .OR. MsgYesNo(STR0006 + CRLF + STR0007) //"Ao Confirmar essa a��o ser� exibido uma interface para inclus�o de um registro S-3000 (Exclus�o) para este evento." # "Confirma a A��o ?"

								//Carrego no modelo as informa��es do evento de exclus�o para o trabalhador
								If GerEventEx(cEvento, cIdEv, cAlias, cDescEv, cCpf, cNis, nReg, nOper, cTpEvt, cProtUl, !isBlind())
									If cEvento == "S-2200"

										//Pesquisa o Evento Ativo
										dbSelectArea("T1U")
										dbSetOrder(2) //FILIAL + ID + ATIVO
										If T1U->( msSeek( xFilial("T1U", &(cAlias+"->"+cAlias+"_FILIAL")) + cIdTrab + '1' ) )
											While T1U->(!Eof()) .And. (cIdTrab + '1') == T1U->( T1U_ID + T1U_ATIVO )

												//Caso o registro ja tenha sido transmitido eu gero o evento de exclus�o S-3000 para S-2205
												If T1U->T1U_STATUS == '4'
													cEvento := "S-2205"
													cProtUl := PADR(AllTrim(T1U->T1U_PROTUL),GetSx3Cache("T1U_PROTUL","X3_TAMANHO"))
													nReg	:= T1U->( Recno() )

													dbSelectArea("C8E")
													dbSetorder(2)
													If msSeek( xFilial("C8E") + cEvento )
														cIdEv  := C8E->C8E_ID
														cDescEv:= C8E->C8E_DESCRI
													Endif

													//Gero o evento de exclus�o para o evento S-2205
													GerEventEx(cEvento, cIdEv, 'T1U', cDescEv, cCpf, cNis, nReg, nOper, cTpEvt, cProtUl, .F.)

												Else
													//Se n�o apaga o registro ativo da base
													oModelT1U:= FWLoadModel("TAFA275")
													oModelT1U:DeActivate()
													oModelT1U:Activate()

													oModelT1U:LoadValue( "MODEL_T1U","T1U_FILIAL", T1U->T1U_FILIAL )
													oModelT1U:LoadValue( "MODEL_T1U","T1U_ID"    , T1U->T1U_ID )
													oModelT1U:LoadValue( "MODEL_T1U","T1U_VERSAO", T1U->T1U_VERSAO )

													FwFormCommit( oModelT1U )

													fwFormCancel( oModelT1U )
													FreeObj( oModelT1U )
												Endif

												T1U->( dbSkip() )
											Enddo
										Endif

										//Pesquisa o Evento Ativo
										dbSelectArea("T1V")
										T1V->(dbSetOrder(2)) //FILIAL + ID + ATIVO
										If T1V->( msSeek( xFilial("T1V", &(cAlias+"->"+cAlias+"_FILIAL")) + cIdTrab + '1' ) )
											While T1V->(!Eof()) .And. (cIdTrab + '1') == T1V->( T1V_ID + T1V_ATIVO )

												//Caso o registro ja tenha sido transmitido eu gero o evento de exclus�o S-3000 para S-2206
												If T1V->T1V_STATUS == '4'
													cEvento := "S-2206"
													cProtUl := PADR(AllTrim(T1V->T1V_PROTUL),GetSx3Cache("T1V_PROTUL","X3_TAMANHO"))
													nReg	:= T1V->( Recno() )

													dbSelectArea("C8E")
													dbSetorder(2)
													If msSeek( xFilial("C8E", &(cAlias+"->"+cAlias+"_FILIAL")) + cEvento )
														cIdEv  := C8E->C8E_ID
														cDescEv:= C8E->C8E_DESCRI
													Endif

													//Gero o evento de exclus�o para o evento S-2206
													GerEventEx(cEvento, cIdEv,'T1V', cDescEv, cCpf, cNis, nReg, nOper, cTpEvt, cProtUl, .F.)

												Else

													//Se n�o apaga o registro ativo da base
													oModelT1V:= FWLoadModel("TAFA276")
													oModelT1V:DeActivate()
													oModelT1V:Activate()

													oModelT1V:LoadValue( "MODEL_T1V","T1V_FILIAL", T1V->T1V_FILIAL )
													oModelT1V:LoadValue( "MODEL_T1V","T1V_ID"    , T1V->T1V_ID )
													oModelT1V:LoadValue( "MODEL_T1V","T1V_VERSAO", T1V->T1V_VERSAO )

													FwFormCommit( oModelT1V )

													fwFormCancel( oModelT1V )
													FreeObj( oModelT1V )
												Endif

												T1V->( dbSkip() )
											Enddo
										Endif

									ElseIF cEvento == "S-2300"

										//Pesquisa o Evento Ativo
										dbSelectArea("T0F")
										T0F->(dbSetOrder(2)) //FILIAL + ID + ATIVO
										If T0F->( msSeek( xFilial("T0F", &(cAlias+"->"+cAlias+"_FILIAL")) + cIdTrab + '1' ) )
											While T0F->(!Eof()) .And. (cIdTrab + '1') == T0F->( T0F_ID + T0F_ATIVO )

												//Caso o registro ja tenha sido transmitido eu gero o evento de exclus�o S-3000 para S-2306
												If T0F->T0F_STATUS == '4'
													cEvento := "S-2306"
													cProtUl := PADR(AllTrim(T0F->T0F_PROTUL),GetSx3Cache("T1V_PROTUL","X3_TAMANHO"))
													nReg	:= T0F->( Recno() )

													dbSelectArea("C8E")
													dbSetorder(2)
													If msSeek( xFilial("C8E", &(cAlias+"->"+cAlias+"_FILIAL")) + cEvento )
														cIdEv  := C8E->C8E_ID
														cDescEv:= C8E->C8E_DESCRI
													Endif

													//Gero o evento de exclus�o para o evento S-2306
													GerEventEx(cEvento, cIdEv, 'T0F', cDescEv, cCpf, cNis, nReg, nOper, cTpEvt, cProtUl, .F.)

												Else

													//Se n�o apaga o registro ativo da base
													oModelT0F:= FWLoadModel("TAFA277")
													oModelT0F:DeActivate()
													oModelT0F:Activate()

													oModelT0F:LoadValue( "MODEL_T0F","T0F_FILIAL", T0F->T0F_FILIAL )
													oModelT0F:LoadValue( "MODEL_T0F","T0F_ID"    , T0F->T0F_ID )
													oModelT0F:LoadValue( "MODEL_T0F","T0F_VERSAO", T0F->T0F_VERSAO )

													FwFormCommit( oModelT0F )

													fwFormCancel( oModelT0F )
													FreeObj( oModelT0F )
												Endif

												T0F->( dbSkip() )
											Enddo
										Endif
									Endif
								Endif
							EndIf
						Else
							If isBlind() .OR. MsgYesNo(STR0038)

								If cEvento == "S-2500"
									V9U->( dbGoTo(( nReg)))
									cProctr := V9U->V9U_NRPROC
									cCpf    := V9U->V9U_CPFTRA
									cRecib  := V9U->V9U_PROTUL

								ElseIf cEvento == "S-2501" 
									V7C->( dbGoTo(( nReg)))
									cProctr := V7C->V7C_NRPROC
									cPerApu := V7C->V7C_PERAPU
									cCpf    := ""
								EndIf

								Ger3500(cEvento, cIdEv, cDescEv, cCpf, nReg, cTpEvt, cProtUl, !isBlind(), cProctr, cPerApu )
								
							EndIf
						EndIf
					EndIf
				EndIf
			ElseIf &(cAlias+"->"+cAlias+"_STATUS") $ '2|6'
					If !isBlind()
						Aviso( STR0008, STR0019, {STR0010}, 1 )	//"Exclus�o de eventos n�o cadastrais"
															//# "N�o � possivel realizar a exclus�o
															//de um evento que esta aguardando o retorno do fisco."
					Else
						TAFConOut ( STR0008 +' '+ STR0019 +' '+ STR0010)										
					EndIf
			ElseIf &(cAlias+"->"+cAlias+"_STATUS") == '7'
					If !isBlind()
						Aviso( STR0008, STR0027, {STR0010}, 1 )	//"Exclus�o de eventos n�o cadastrais"
															//# "N�o � poss�vel realizar a exclus�o de um evento
															//que j� foi exclu�do e validado pelo RET."
					Else
						TAFConOut ( STR0008 +' '+ STR0019 +' '+ STR0010)										
					EndIf
			Else
				If cEvento == "S-2200"
					aArea := C8B->(GetArea())
					DBSelectArea( "C8B" )
					C8B->(dbSetorder(3))

					lExstASO := C8B->(MsSeek(xFilial("C8B", &(cAlias+"->"+cAlias+"_FILIAL")) + CUP->CUP_CODASO + "1" ) )

					If lExstASO
						If MsgYesNo(STR0024 + CRLF + STR0025 + CRLF + STR0026) //"Foi encontrado um Atestado de Sa�de Ocupacional (ASO) vinculado a esse registro de Admiss�o de Trabalhador (S-2200)."			     														  //"Ao excluir o trabalhador, o registro da ASO tamb�m ser� exclu�do!" / "Confirma a Exclus�o?"
							If RecLock("C8B",.F.)
								C8B->(DbDelete())
								C8B->(MsUnlock())
							EndIf
							lExclus := .T.
						Else
							lExclus := .F.
						EndIf
					EndIf
					RestArea(aArea)
				EndIf

				//---------------------------------------------------------------------------------------------------
				// Tratamento para nao permitir a exclusao do S-3000 gerado pela rotina origem do evento (periodicos
				// ou n�o periodicos), o processo padr�o ser� utilizar a op��o "Desfazer Exclus�o" na rotina origem
				//---------------------------------------------------------------------------------------------------
				If lExclus .And. cEvento $ 'S-3000|S-3500'

					//-----------------------------
					// Obtem o evento (ex: S-2299)
					//-----------------------------

					If cEvento == 'S-3000'
						cEvento := GetADVFVal("C8E","C8E_CODIGO",XFilial("C8E", &(cAlias+"->"+cAlias+"_FILIAL")) + CMJ->CMJ_TPEVEN,1,"") //C8E_FILIAL+C8E_ID
					ElseIf cEvento == 'S-3500'
						cEvento := GetADVFVal("C8E","C8E_CODIGO",XFilial("C8E", &(cAlias+"->"+cAlias+"_FILIAL")) + V7J->V7J_TPEVEN,1,"") //C8E_FILIAL+C8E_ID
					EndIf

					If cEvento $ "S-1200|S-1202|S-1207|S-1210|S-1250|S-1260|S-1270|S-1280|S-1300|S-2190|S-2210|S-2220|S-2230|S-2231|S-2240|S-2241|S-2245|S-2250|S-2298|S-2299|S-2400|S-3000|S-2260|S-2399|S-2400|S-2405|S-2410|S-2416|S-2418|S-2420|S-3500|S-2500|S-2501"

						//--------------------------
						// Obtem os dados do evento
						//--------------------------
						
						aDadEvent := TAFRotinas(cEvento, 4, .F., 2)

						cCpoFilial := aDadEvent[3] + "_FILIAL" //Campo da filial
						cCpoProtPn := aDadEvent[3] + "_PROTPN" //Campo do pen�ltimo protocolo

						//---------------------------------------------------
						// Avalia se os campos existem na base para consulta
						//---------------------------------------------------
						If TAFColumnPos(cCpoProtPn)

							//-------------------------------------------------------------------------
							// Query para localizar se protocolo do S-3000 � originado de outra rotina
							//-------------------------------------------------------------------------
							cAliasQry := GetNextAlias()

							cQuery := " SELECT " + aDadEvent[3] + "_PROTPN "
							cQuery += " FROM " + RetSQLName(aDadEvent[3])
							cQuery += " WHERE "
							cQuery +=      cCpoFilial + " = '" + XFilial(aDadEvent[3], &(cAlias+"->"+cAlias+"_FILIAL")) + "' "

							If  aDadEvent[4] $ 'S-2500|S-2501'
								cQuery += "    AND " + cCpoProtPn + " = '" + V7J->V7J_NRRECI + "' "
							Else
								cQuery += "    AND " + cCpoProtPn + " = '" + CMJ->CMJ_NRRECI + "' "
							EndIf

							cQuery += "    AND D_E_L_E_T_ = ' ' "

							DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry )

							If (cAliasQry)->(!EOF())
								lExclus := .F.
								Help(" ",1,"xTafVExc",,'N�o � possivel excluir o registro por meio desta rotina.',1,0,,,,,,{'Utilize a op��o "Desfazer Exclus�o" na rotina de manuten��o deste evento (' + aDadEvent[1] + ').'})
							EndIf

							(cAliasQry)->(DBCloseArea())

						EndIf

						ASize(aDadEvent,0)
						aDadEvent := Nil

					EndIf

				EndIf

				If lExclus	.AND. !cNmFun == "TAFA421"

					If cNmFun == "TAFA257"
						nCM0Recno := CM0->(Recno())
					EndIf

					oModel:= FWLoadModel(cNmFun)
					oModel:SetOperation( 5 )

					If cNmFun != "TAFA609"
						oModel:Activate()
					EndIf

					If cNmFun == "TAFA257"
						CM0->(DbGoTo(nCM0Recno))
					EndIf

					If isBlind()
						nValor = 0
					Else
						If cEvento == "TAUTO"
							nValor:=FWExecView(cTitulo,cNmFun,5,,{|| .T. },,,,,,,oModel )
						Else
							nValor:=FWExecView(cTitulo,cNmFun,5,,{|| .T. },{|| TafDisableSX9( cAlias ) },,,,,,oModel )
						Endif  
						TafEnableSX9( cAlias ) 
					Endif

					IF nValor == 0

						If (cNmFun == "TAFA256" .OR. cNmFun == "TAFA278" .OR. cNmFun == "TAFA279") .AND. Empty(&(cAlias+"->"+cAlias+"_VERANT"))

							//Caso seja um dos eventos do trabalhador deleto tamb�m o registro ORIGI.
							oModel:DeActivate()
							dbSelectArea(cAlias)
							dbGoTo(nRegOrig)
							oModel:= FWLoadModel(cNmFun)
							oModel:SetOperation( 5 )
							oModel:Activate()

							FwFormCommit( oModel )

						Else
							
							dbSelectArea(cAlias)
							dbGoTo(nRegOrig)

						EndIf

						cChave := &(cAlias+"->"+cAlias+"_ID") + &(cAlias+"->"+cAlias+"_VERANT")
						FwFormCommit( oModel )
						TAFRastro(cAlias,nInd,cChave, .T., .T. ,IIF(Type("oBrw") == "U", Nil, oBrw) )

					EndIf
				EndIf

			EndIf

		//Se selecionado op��o 2(Desfazer exclus�o) ou 3(Visualizar Exclus�o) no menu
		ElseIf nOpc == 2 .Or.  nOpc == 3

			nOper := IIf (nOpc == 2,MODEL_OPERATION_DELETE,1)

			// C�digo do registro de sxclus�o S-1200
			dbSelectArea("C8E")
			C8E->(DbSetOrder(2))
			If C8E->(DbSeek( xFilial('C8E')  + cEvento ))        
				cTpEven := C8E->C8E_ID
			EndIf

			If  !(cEvento $ "S-2500|S-2501|")

				dbSelectArea("CMJ")
				CMJ->(dbSetOrder(2))
			If CMJ->(MsSeek(xFilial("CMJ", &(cAlias+"->"+cAlias+"_FILIAL")) + cTpEven + cProtUl + "1"))
			
				If CMJ->CMJ_TPEVEN <> "000037"
					If lRegras
						If CMJ->CMJ_EVENTO == "E"
							Aviso( STR0008, STR0013, { STR0010 }, 2 ) //"Evento j� Excluido anteriormente"
						ElseIf nOpc == 2 .AND. CMJ->CMJ_STATUS $ '246'
							Aviso( STR0008, "N�o � poss�vel desfazer a exclus�o do evento S-3000 Transmitido ou Aceito RET." /*STR0014*/, { STR0010 }, 2 ) //"N�o foi possivel desfazer a exclus�o por que o evento j� foi transmitido"
						Else
							// Para a exclus�o exibo a mensagem de confirma��o
							If nOpc == 2
								//"Ao confirmar essa a��o ser� exibida uma interface para a exclus�o do evento S-3000 vinculado a esse registro."
								//# "Confirma essa a��o ? "
								If !isBlind() .AND. (lOk := MsgYesNo(STR0015 + CRLF + STR0016) )
									lView := .T.
								Else
									lView := .F.
								EndIf
							Else
								lView := .T.
							EndIf
							If lOk
								If lView						
									nRet := FWExecView(cTitulo,"TAFA269", nOper,,{||.T.}, ,,,,,,oModelCMJ )
								Else

									oModelCMJ := FWLoadModel( "TAFA269" )
									oModelCMJ:SetOperation( nOper )
									oModelCMJ:Activate( )
									FwFormCommit( oModelCMJ )
								EndIf

								If nRet == 0 .And. nOper == 5
									
									//-- Se estiver realizando a exclus�o pela rotina TAFA269
									If cAlias == "CMJ"

										//-- Busco meu evento correspondente com a exclus�o me retornando o Alias do mesmo
										cProtPn := CMJ->CMJ_NRRECI
										aEvtEx := Posicione("C8E",1,xFilial("C8E", &(cAlias+"->"+cAlias+"_FILIAL"))+CMJ->CMJ_TPEVEN,"C8E->C8E_CODIGO")
										aEvtEx := TAFRotinas(aEvtEx, 4, .F., 2)
										aTable := aEvtEx[3]

										cAliasCMJ := GetNextAlias()
											
											//-- Realizo Query para buscar meu evento que est� Aguardando Exclus�o para estar Desfazendo o mesmo
											cSelect := "*"
											cFrom	:= RetSqlName(aTable)
											cWhere	:= aTable + "_FILIAL = '"+ xFilial(aTable) +"' "
											cWhere	+= " AND " + aTable + "_STATUS = '6' "
											cWhere	+= " AND " + aTable + "_EVENTO = 'E' "
											cWhere	+= " AND " + aTable + "_PROTPN = '" + cProtPn + "' "
											cWhere	+= " AND D_E_L_E_T_= '' "
											
											cSelect  := "%" + cSelect  + "%"
											cFrom    := "%" + cFrom    + "%"
											cWhere   := "%" + cWhere   + "%"
											
											BeginSql Alias cAliasCMJ
												SELECT
													%Exp:cSelect%
												FROM
													%Exp:cFrom%
												WHERE
													%EXP:cWhere%
											EndSql

										//-- Pego RECNO de referencia para estar deletando o mesmo e estar restaurando o evento anterior
										nRegRef := ( cAliasCMJ )->R_E_C_N_O_

										(cAliasCMJ)->(DbCloseArea())

										dbSelectArea(aEvtEx[3])
										dbGoTo(nRegRef)

										cChave := &(aEvtEx[3]+"->"+aEvtEx[3]+"_ID") + &(aEvtEx[3]+"->"+aEvtEx[3]+"_VERANT")
										oModel := FWLoadModel(aEvtEx[1])
										oModel:SetOperation(5)
										oModel:Activate()
										FwFormCommit( oModel )
										TAFRastro(aEvtEx[3],nInd,cChave, .T.,.T., IIF(Type("oBrw") == "U", Nil, oBrw))

										
									Else							
										dbSelectArea(cAlias)
										dbGoTo(nReg)

										cChave := &(cAlias+"->"+cAlias+"_ID") + &(cAlias+"->"+cAlias+"_VERANT")
										oModel := FWLoadModel(cNmFun)
										oModel:SetOperation(5)
										oModel:Activate()
										FwFormCommit( oModel )
										TAFRastro(cAlias,nInd,cChave, .T.,.T., IIF(Type("oBrw") == "U", Nil, oBrw))
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				Else
					If !isBlind()
						Aviso("Exclus�o de eventos n�o cadastrais", "N�o � poss�vel desfazer a exclus�o do evento S-3000 Transmitido ou Aceito RET.")
					EndIf
				EndIf
			Else
					Aviso( STR0008, STR0017 , { STR0010 } , 2 ) //"N�o h� registro de exclus�o relacionado a este registro"
				EndIf
			Else
				//****DESFAZER EXCLUS�O E VISUALIZAR REGISTRO ECLUIDO PARA S-2501 E S-2500****//
				V7J->(dbSetOrder(2))
				If V7J->(MsSeek(xFilial("V7J", &(cAlias+"->"+cAlias+"_FILIAL")) + cTpEven + Padr(alltrim(cProtUl) ,TamSX3("V7J_NRRECI")[1]) + "1"))
					If V7J->V7J_EVENTO == "E"
						Aviso( STR0008, STR0013, { STR0010 }, 2 ) //"Evento j� Excluido anteriormente"
					ElseIf nOpc == 2 .AND. V7J->V7J_STATUS $ '2|4|6'
						Aviso( STR0008, "N�o � poss�vel desfazer a exclus�o do evento S-3500 Transmitido ou Aceito RET." /*STR0014*/, { STR0010 }, 2 ) //"N�o foi possivel desfazer a exclus�o por que o evento j� foi transmitido"
					Else
						// Para a exclus�o exibo a mensagem de confirma��o
						If nOpc == 2
							//"Ao confirmar essa a��o ser� exibida uma interface para a exclus�o do evento S-3500 vinculado a esse registro."
							//# "Confirma essa a��o ? "
							If !isBlind() .AND. (lOk := MsgYesNo(STR0039 + CRLF + STR0016) )
								lView := .T.
							Else
								lView := .F.
							EndIf
						Else
							lView := .T.
						EndIf
						
						If lOk
							If lView						
								nRet := FWExecView(cTitulo,"TAFA610", nOper,,{||.T.}, ,,,,,,oModelV7J )
							EndIf

							If nRet == 0 .And. nOper == 5
														
								dbSelectArea(cAlias)
								dbGoTo(nReg)

								cChave := &(cAlias+"->"+cAlias+"_ID") + &(cAlias+"->"+cAlias+"_VERANT")
								oModel := FWLoadModel(cNmFun)
								oModel:SetOperation(5)
								oModel:Activate()
								FwFormCommit( oModel )
								TAFRastro(cAlias,nInd,cChave, .T.,.T., IIF(Type("oBrw") == "U", Nil, oBrw))
								
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		cFilAnt	:=	cFilBKP
	ElseIf lOk
		Aviso( STR0008, "Este Funcion�rio encontra-se transferido, portanto n�o poder� ser exclu�do nessa Filial." , { STR0010 } , 2 ) //"N�o h� registro de exclus�o relacionado a este registro"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGetStat

Retorna status do registro no TAF

@Param
	cEvento	   - Evento do eSocial a que se refere o registro
	cChave	   - Chave de busca do registro
	cEmpEnv    - Empresa do registro no ERP
	cFilEnv    - Filial do registro no ERP
	nChaveEsp  - Indice especifico para uma busca diferenciada(caso n�o tenha utiliza o indice do TAFROTINAS)
	cPerApu    - Compet�ncia de apura��o
	lCheckDesl - Indica se ser� verificado se o trabalhador est� desligado.

@Return

	cStatus	- Status do registro:
			"-1": Registro n�o encontrado na base do TAF
			" ": Registro encontrado no TAF - n�o submetido ao processo de valida��o
			"0": Registro encontrado no TAF - v�lido
			"1": Registro encontrado no TAF - inv�lido
			"2": Registro encontrado no TAF - transmitido e aguardando retorno do Governo
			"3": Registro encontrado no TAF - transmitido e n�o autorizado ( retornado com erro )
			"4": Registro encontrado no TAF - transmitido e autorizado
			"6": Registro encontrado no TAF - pendente de exclus�o no Governo ( S-3000 )
			"7": Registro encontrado no TAF - exclus�o validada pelo Governo ( S-3000 )

@author Anderson Costa
@since 05/11/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFGetStat(cEvento as character, cChave as character, cEmpEnv as character,; 
			cFilEnv as character, nChaveEsp as numeric, cPerApu as character, lCheckDesl as logical)

	Local aChave		as array
	Local aFldsIndex	as array
	Local aRotina		as array
	Local cAlias		as character
	Local cFldsIndex	as character
	Local cCampo		as character
	Local cChaveAux		as character
	Local cStatus		as character
	Local nTam			as numeric
	Local nPosChave		as numeric
	Local nIndice		as numeric
	Local nI			as numeric

	Default cEvento		:= ""
	Default cChave		:= ""
	Default cPerApu     := ""
	Default	cEmpEnv		:= cEmpAnt
	Default	cFilEnv		:= cFilAnt
	Default lCheckDesl  := .F.
	Default nChaveEsp	:= 0

	aChave		:= {}
	aFldsIndex	:= {}
	aRotina		:= {}
	cAlias		:= ""
	cFldsIndex	:= ""
	cCampo		:= ""
	cChaveAux	:= ""
	cStatus		:= "-1"
	nTam		:= 0
	nPosChave	:= 0
	nIndice		:= 0
	nI			:= 0

	// Obtem dados do evento
	aRotina := TAFRotinas(cEvento,4,.F.,2)
	cEvento := StrTran(cEvento,"-","")

	If Len(aRotina) > 0

		If cEvento $ "S2250|S2210|S2220|S2221|S2240|S2245"
			aChave := StrTokArr(cChave,";")
		Else
			aChave := Str2Arr(cChave,";",.F.)
		EndIf

		// Verifica a integridade da chave recebida
		If Len( aChave ) > 0

			cAlias := aRotina[3]
			If nChaveEsp == 0
				nIndice := aRotina[10]
			Else
				nIndice := nChaveEsp
			EndIf

			If TafIndexInDic(cAlias, nIndice, .T.)
				(cAlias)->(DbSetOrder(nIndice))

				cFldsIndex := (cAlias)->(IndexKey())

				cFldsIndex := StrTran(cFldsIndex , "DTOS(" , "")
				cFldsIndex := StrTran(cFldsIndex , "STR("  , "")
				cFldsIndex := StrTran(cFldsIndex , ")"     , "")
				aFldsIndex := Str2Arr(cFldsIndex , "+")

				//nPosChave contra o Indexador do array aChave
				nPosChave := 1

				For nI:= 1 To Len(aFldsIndex)

					// Tratamento para retirar possiveis "virgulas" deixadas pela Fun��o STR
					aFldsIndex[nI] := IIf((nPosAux := AT(",",aFldsIndex[nI])) > 0,Substr(aFldsIndex[nI],1,nPosAux-1),aFldsIndex[nI])
					cCampo := AllTrim(aFldsIndex[nI])

					// Monta a chave de busca levando em considera��o o tamanho dos campos
					If cCampo == cAlias + "_FILIAL"
						cChaveAux += FTafGetFil( AllTrim( cEmpEnv ) + AllTrim( cFilEnv ) , , cAlias, .T. ) //PadR(xFilial(cAlias), TamSX3(cAlias + "_FILIAL")[1])
					ElseIf cCampo == cAlias + "_NOMEVE"
						cChaveAux += cEvento
						nPosChave++
					ElseIf cCampo == cAlias + "_IDTRAB" .OR. cCampo == cAlias + "_TRABAL" .OR. cCampo == cAlias + "_FUNC" .OR. cCampo == cAlias + "_IDFUNC"
						If	Len(aChave) >= 2
							cChvTrab  := aChave[nPosChave] + aChave[nPosChave+1]					
							nTam  	  := TamSX3("C9V_CPF")[1] + TamSX3("C9V_MATRIC")[1]
							cChaveAux += Posicione("C9V",12,FTafGetFil(AllTrim(cEmpEnv)+AllTrim(cFilEnv),,"C9V", .T.)+ PadR(cChvTrab,nTam) + "1","C9V_ID")
							//Quando a chave possui CPF+MATRIC eu incremeto mais um na posi��o do campo, pois a Chave CPF+MATRIC pertence � um �nico campo no TAF _IDTRAB
							//nX := nI + 2
							nPosChave++
						EndIf
					ElseIf cCampo == cAlias + "_ATIVO"
						cChaveAux += "1"
						nPosChave++
					ElseIf cCampo == "C9V_CATCI" //Busca o Id TAF referente ao c�digo oficial da categoria
						cChaveAux += Posicione("C87",2,FTafGetFil(AllTrim(cEmpEnv)+AllTrim(cFilEnv),,"C87", .T.)+PadR(aChave[nPosChave], TamSX3("C87_CODIGO")[1]) ,"C87_ID")
						nPosChave++
					ElseIf cCampo == "C8R_IDTBRU" //Busca o Id TAF referente ao estabelecimento pertencente a rubrica
						cChaveAux += Padr(Posicione("T3M",2,FTafGetFil(AllTrim(cEmpEnv)+AllTrim(cFilEnv),,"T3M", .T.)+PadR(aChave[nPosChave], TamSX3(cCampo)[1]) ,"T3M_ID"),TamSX3(cCampo)[1])
						nPosChave++
					ElseIf cCampo == "V3C_CODTCA" .And. IsInCallStack("TRMA100")
						cChaveAux += Posicione("V2M", 2, xFilial("V2M")+PadR(aChave[1], TamSX3("V2M_CODIGO")[1]), "V2M_ID")
						nPosChave++
					Else
						If nPosChave <= Len(aChave)
							cChaveAux += PadR(aChave[nPosChave], TamSX3(cCampo)[1])
							nPosChave++
						EndIf
					EndIf

				Next nI

				If (cAlias)->(dbSeek(cChaveAux))
				
					If lCheckDesl .And. cEvento $ "S2200|S2300"
					
						If ChkDeslig( C9V->C9V_FILIAL, C9V->C9V_ID, C9V->C9V_NOMEVE, cPerApu )
							cStatus := "-2" // Caso seja verificado que o funcion�rio est� desligado, ser� retornado o status -2.
						Else
							cStatus := ( cAlias )->&( cAlias + "_STATUS")
						EndIf
						
					Else
						cStatus := ( cAlias )->&( cAlias + "_STATUS")
					EndIf
					
				ElseIf cEvento $ "S2300"
					(cAlias)->(DbSetOrder(4))

					nPosChave := 1
					cChaveAux := FTafGetFil(AllTrim(cEmpEnv) + AllTrim(cFilEnv),, cAlias, .T.)
					cChaveAux += aChave[nPosChave]
					cChaveAux += "TAUTO"
					cChaveAux += "1"

					If (cAlias)->(dbSeek(cChaveAux))
						cStatus := (cAlias)->&(cAlias + "_STATUS")
					EndIf
				EndIf

			Endif
		EndIf
	EndIf

Return cStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} FTrocaPath
Troca a Startpath do XML
Essa fun��o foi criada para permitir que os Erp's possam mandar
a StartPath com namespace, por quest�es de performace n�o foi utilizado
as fun��es XPathGetRootNsList e XPathRegisterNsList para identificar os
namespaces e registra-los.
@author evandro.oliveira
@since 03/02/2016
@version 1.0
@param cXml, character, (Xml a ser avaliado)
@param cPath, character, (StartPath (Tag Inicial) que deve substituir a atual)
@return ${cXmlRet}, ${Xml com a StartPath alterada }
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Function FTrocaPath(cXml,cPath)

	Local nStart	:= 0
	Local cXmlRet	:= ""

	nStart := AT(">",cXml)
	cXmlRet := "<" + cPath + Substr(cXml,nStart,Len(cXml)-(nStart-1))

Return cXmlRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GerEventEx

Fun��o utilizada para gerar as informa��es de exclus�o no modelo
@Param:

@author Paulo Santana
@since 23/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function GerEventEx(cEvento, cIdEv, cAlias, cDescEv, cCpf, cNis, nReg, nOper, cTpEvt, cProtUl, lExecView)

	Local oModelCMJ		:= Nil
	Local lReturn		:= .F.
	Local nRet			:= 0
	Local cTitulo		:= "Exclus�o de Evento"

	Private _cEvent		:= ""

	Default cEvento		:= ""
	Default cIdEv		:= ""
	Default cAlias		:= ""
	Default cDescEv		:= ""
	Default cCpf		:= ""
	Default cNis		:= ""
	Default nReg		:= 0
	Default nOper		:= 0
	Default cTpEvt		:= ""
	Default cProtUl		:= ""
	Default lExecView	:= .F.

	_cEvent := cEvento

	TafCacheLayESoc("S_01_00_00")

	dbSelectArea("CMJ")
	CMJ->(dbSetOrder(2))
	If MsSeek(xFilial("CMJ")+cIdEv+PADR(AllTrim(&(cAlias+"->"+cAlias+"_PROTUL")),GetSx3Cache(cAlias+"_PROTUL","X3_TAMANHO"))+"1")
		Aviso( STR0008 , STR0009, { STR0010} , 2 ) //"Exclus�o de eventos n�o cadastrais" # "J� existe um regitro de exclus�o vinculado a este registro" # "Fechar
	Else

		dbSelectArea(cAlias)
		dbGoto(nReg)

		oModelCMJ := FWLoadModel("TAFA269")
		oModelCMJ:SetOperation( 3 )
		oModelCMJ:Activate()

		oModelCMJ:LoadValue("MODEL_CMJ","CMJ_FILIAL"	 ,xFilial("CMJ") )
		oModelCMJ:LoadValue("MODEL_CMJ","CMJ_VERSAO"	 ,xFunGetVer())
		oModelCMJ:LoadValue("MODEL_CMJ","CMJ_ID"		 ,GetSx8Num( "CMJ", "CMJ_ID" ))
		oModelCMJ:LoadValue("MODEL_CMJ","CMJ_TPEVEN"	 ,cIdEv)
		oModelCMJ:LoadValue("MODEL_CMJ","CMJ_DTPEVE"	 ,cDescEv)
		If cEvento <> "S-2190"
			oModelCMJ:LoadValue("MODEL_CMJ","CMJ_CPF" ,cCpf)
			If (!cEvento $ "S-1210|S-2231|S-2400|S-2405|S-2410|S-2416|S-2418|S-2410") .AND. !__lLaySimplif
				oModelCMJ:LoadValue("MODEL_CMJ","CMJ_NIS" ,cNis)
			EndIf 
		Else
			oModelCMJ:LoadValue("MODEL_CMJ","CMJ_CPF"	 ,&(cAlias+"->"+cAlias+"_CPF"))
		EndIf

		If AllTrim(cTpEvt) == "M"
			If !__lLaySimplif .OR. (__lLaySimplif .AND. cEvento $ "S-1200|S-1202|S-1207|S-1280|S-1300")
				oModelCMJ:LoadValue("MODEL_CMJ", "CMJ_INDAPU", &(cAlias + "->" + cAlias + "_INDAPU"))
			EndIf

			oModelCMJ:LoadValue("MODEL_CMJ", "CMJ_PERAPU", &(cAlias + "->" + cAlias + "_PERAPU"))
		EndIf

		oModelCMJ:LoadValue("MODEL_CMJ","CMJ_REGREF"	,nReg)
		oModelCMJ:LoadValue("MODEL_CMJ","CMJ_NRRECI"	,cProtUl)
		oModelCMJ:LoadValue("MODEL_CMJ","CMJ_EVENTO"	,'I')
		If lExecView
			nRet := FWExecView(cTitulo,"TAFA269", nOper,,{||.T.}, ,,,,,,oModelCMJ )
			lReturn := Iif( nRet == 0,.T.,.F. )
		Else
			oModelCMJ:LoadValue("MODEL_CMJ","CMJ_LOGOPE"	,'1')
			FwFormCommit( oModelCMJ )

			GerarExclusao(cEvento, cProtUl, .T.)

			lReturn := .T.
		Endif

	EndIf

Return( lReturn )

//-------------------------------------------------------------------
/*/{Protheus.doc} Ger3500

Fun��o utilizada para gerar as informa��es de exclus�o no modelo
@Param:

@author Alexandre de Lima.
@since 18/10/2022
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Ger3500( cEvento as character, cIdEv as character, cDescEv as character, cCpf as character,;
						nReg as numeric, cTpEvt as character, cProtUl as character, lExecView as logical,;
						cProctr as character, cPerApu as character )

	Local cAlias    as character
	Local cTitulo   as character
	Local lReturn   as logical
	Local nRet      as numeric
	Local oModelV7J as object

	Private _cEvent as character

	Default cEvento   := ""
	Default cIdEv     := ""
	Default cDescEv   := ""
	Default cCpf      := ""
	Default nReg      := 0
	Default cTpEvt    := ""
	Default cProtUl   := ""
	Default lExecView := .F.
	Default cProctr   := ""
	Default cPerApu   := ""

	cAlias            := "V7J"
	cTitulo           := "Exclus�o de Evento"
	lReturn           := .F.
	nRet              := 0
	oModelV7J         := Nil

	_cEvent           := cEvento
	
	V7J->(dbSetOrder(2))
	If MsSeek(xFilial("V7J") + cIdEv + PADR(AllTrim(&(cAlias + "->" + cAlias + "_PROTUL")), GetSx3Cache(cAlias + "_PROTUL", "X3_TAMANHO")) + "1")
		Aviso( STR0008, STR0009, { STR0010}, 2 ) //"Exclus�o de eventos n�o cadastrais" # "J� existe um regitro de exclus�o vinculado a este registro" # "Fechar
	Else

		dbSelectArea(cAlias)
		dbGoto(nReg)

		oModelV7J := FWLoadModel("TAFA610")
		oModelV7J:SetOperation( 3 )
		oModelV7J:Activate()

		oModelV7J:LoadValue( "MODEL_V7J", "V7J_FILIAL", xFilial("V7J") 	 )
		oModelV7J:LoadValue( "MODEL_V7J", "V7J_VERSAO", xFunGetVer()	 )
		oModelV7J:LoadValue( "MODEL_V7J", "V7J_ID"	  , TAFGeraID("TAF") )
		oModelV7J:LoadValue( "MODEL_V7J", "V7J_TPEVEN", cIdEv 			 )
		oModelV7J:LoadValue( "MODEL_V7J", "V7J_DTPEVE", cDescEv 		 )
		oModelV7J:LoadValue( "MODEL_V7J", "V7J_NRRECI", Alltrim(cProtUl) )
		oModelV7J:LoadValue( "MODEL_V7J", "V7J_PROCTR", Alltrim(cProctr) )
		oModelV7J:LoadValue( "MODEL_V7J", "V7J_CPF"	  , cCpf			 )
		oModelV7J:LoadValue( "MODEL_V7J", "V7J_PERAPU", cPerApu			 )	

		If lExecView
			nRet := FWExecView( cTitulo, "TAFA610", 3,,{||.T.}, ,,,,,, oModelV7J )
			lReturn := Iif( nRet == 0, .T., .F. )

		Else 
			oModelV7J:LoadValue("MODEL_V7J", "V7J_LOGOPE", '1')
			FwFormCommit( oModelV7J )

			Gerar3500( cEvento, cProtUl, .T.)

			lReturn := .T.

		Endif

	EndIf

Return( lReturn )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFMsgIncons

Tratativa de mensagem de inconsist�ncia para exibi��o no Monitor de Integra��o.

Mensagens de integra��o inconsistentes:
- Campos chave e obrigat�rios em branco
- Campos com consulta padr�o que n�o s�o encontrados na base de dados

@Param	cInconMsg	- Mensagem com inconsist�ncia
		nSeqErrGrv	- N�mero sequencial que indica a quantidade de erros
		nLinha		- Linha da inconsist�ncia
		aMessage	- Array com estrutura de informa��es da ocorr�ncia:
						[n][01] Coluna da inconsist�ncia
						[n][02] Nome do campo que ocorreu a inconsist�ncia
						[n][03] Valor do campo que ocorreu a inconsist�ncia
		lGetIdInt	- Indica se a Function foi chamada pelo FGetIdInt do eSocial ou pela integra��o comum
		cNmTag		- Nome da Tag que ocorreu a inconsist�ncia
		cValorTag	- Valor da tag que ocorreu a inconsist�ncia

@Author	Vitor Siqueira
@Since		19/04/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFMsgIncons( cInconMsg, nSeqErrGrv, nLinha, aMessage, lGetIdInt, cNmTag, cValorTag , cMsgType , cRegStatus,cNmTag2, cValorTag2 )

	Local cEnter       := Chr( 13 ) + Chr( 10 )
	Local nI           := 0
	Local cSpecialKey  := ""

	Default cInconMsg  := ""
	Default nSeqErrGrv := 0
	Default nLinha     := 0
	Default aMessage   := {}
	Default lGetIdInt  := .F.
	Default cValorTag  := ""
	Default cNmTag     := ""
	Default cMsgType   := ''
	Default cRegStatus := ''

	If Len( cInconMsg ) <= TAMMAXXML

		If !Empty( cInconMsg )
			cInconMsg += cEnter + cEnter
		EndIf

		nSeqErrGrv += 1

		//Verifica se a Function foi chamada pelo eSocial ou pela integra��o comum
		If lGetIdInt

			//Monta a mensagem de acordo coma regra da fila de integra��o. � utilizado quando, apesar do registro de chave estrangeira j� existir no TAF, seu STATUS n�o � de registro transmitido = '4', o que impede que os eventos
			//relacionados sejam integrados .
			If cMsgType == 'queue'

				cRegStatus := getTafDStatus( cRegStatus )

				cInconMsg +=	"Erro " + AllTrim( Str( nSeqErrGrv ) ) + ' - ' //cEnter
				cInconMsg +=	"Fila de Integra��o: O valor '" + AllTrim( cValorTag ) + "'"
				cInconMsg +=	" informado na tag " + AllTrim( cNmTag )
				cInconMsg +=	" existe na base de dados, mas est� atualmente com status " + cRegStatus

			ElseIf cMsgType == 'chvComposta'

				cInconMsg +=	"Erro " + AllTrim( Str( nSeqErrGrv ) ) + ' - ' //cEnter
				cInconMsg +=	"O valor '" + AllTrim( cValorTag ) + "'"
				cInconMsg +=	" informado na tag " + AllTrim( cNmTag )
				cInconMsg +=	" somado ao valor '" + AllTrim( cValorTag2 ) + "'"
				cInconMsg +=	" informado na tag " + AllTrim( cNmTag2 )
				cInconMsg +=	" � uma chave composta e a sua combina��o n�o corresponde "
				cInconMsg +=	" a nenhum registro do cadastro na base de dados. "

			ElseIf cMsgType == 'idDuplicado'

				cSpecialKey := GetPvProfString(GetEnvServer(),"SpecialKey","",getAdv97())

				cInconMsg +=	"Erro " + AllTrim(Str(nSeqErrGrv)) + ' - ' //cEnter
				cInconMsg +=    "Inconsist�ncia no License Server. Verifique o controle de numera��o da tabela " + cValorTag2 
				cInconMsg +=    " - Filial: " + cFilAnt + " - ID: " + cValorTag + " - SpecialKey: " + cSpecialKey
				cInconMsg +=    ". Chave do Numerador: " + cSpecialKey + xFilial(cValorTag2) + RetSqlName(cValorTag2) + " "
				cInconMsg +=    ". Para mais Informa��es Acessar: http://tdn.totvs.com/x/rd3-Fg "

			ElseIf cMsgType == 'idTabRubr'

				cInconMsg +=	"Erro " + AllTrim( Str( nSeqErrGrv ) ) + ' - ' //cEnter
				cInconMsg +=	"O valor '" + xGetMatric( cValorTag ) + "'"
				cInconMsg +=	" informado na tag " + AllTrim( cNmTag )
				cInconMsg +=	" n�o esta relacionado com o valor " + AllTrim( cValorTag2 ) 
				cInconMsg +=	" informado na tag " + AllTrim( cNmTag2 ) +  " na base de dados."

			Else

				cInconMsg +=	"Erro " + AllTrim( Str( nSeqErrGrv ) ) + ' - ' //cEnter
				cInconMsg +=	"O valor '" + xGetMatric( cValorTag ) + "'"
				cInconMsg +=	" informado na tag " + AllTrim( cNmTag )
				cInconMsg +=	" n�o existe na base de dados."

			EndIf

		Else

			cInconMsg += "Erro " + AllTrim( Str( nSeqErrGrv ) ) + " - Linha: " + AllTrim( Str( nLinha ) ) + ' - ' //cEnter

			For nI := 1 to Len( aMessage )

				If nI == 1
					cInconMsg += "O valor '" + AllTrim( aMessage[nI,3] ) + "'"
				Else
					cInconMsg += " somado ao valor '" + AllTrim( aMessage[nI,3] ) + "'"
				EndIf

				cInconMsg += " informado na coluna " + AllTrim( aMessage[nI,1] )
				cInconMsg += " para o campo " + AllTrim( Eval( { || SX3->( MsSeek( AllTrim( aMessage[nI,2] ) ) ), X3Descric() } ) ) + " ( " + AllTrim( aMessage[nI,2] ) + " )"
			
			Next nI

			cInconMsg += " n�o existe na base de dados."

		EndIf
	EndIf

Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} eSoc2ErrInt

Fun��o criada para fazer o de/para dos erros criados nas fun��es GRV() do eSocial com os erros utilizados no gerenciador de integra��o.
Durante o desenvolvimento da fila de integra��o foi iniciado um trabalho de padroniza��o desses c�digos, visto que a rela��o sendo 1x1 n�o existe
a necessidade deste de/para, ou seja, os erros do TAFTICKET (fun��o TafCodErr) podem ser utilizados dentro da GRV().
Ap�s todas fun��es Grv() terem sido padronizadas, ou seja, o de/para possuic�digos id�nticos, essa fun��o se faz desnecess�ria e pode ser removida do fluxo de integra��o do eSocial.

// **************************************************************************************************************
// 			N�O CRIAR NOVOS C�DIGOS NESTA FUN��O. UTILIZE OS C�DIGOS DE FORMA PADRONIZADA.
// **************************************************************************************************************

@Param	cErro	- Erro do eSocial a ser convertido para o erro de integra��do - TAFCodErr()

@Author	Luccas Curcio
@Since	19/05/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
static function eSoc2ErrInt( cErro, cErroXERP )

	local cErroDePara	:=	''
	local aErros		:= {}
	local nPosErr		:=	0

	Local aParseErro	:= StrTokArr( cErro, "|" )
	Local cAlsMsg		:= ""
	Local cXErrLog		:= ""

	If 	Len(aParseErro) > 1
		cErro 		:= aParseErro[1]
		cAlsMsg 	:= aParseErro[2]
		cXErrLog 	:= aParseErro[3]
	EndIf	
	// **************************************************************************************************************
	// N�O CRIAR NOVOS C�DIGOS NESTA FUN��O. LEIA O CABE�ALHO DESTA FUN��O E UTILIZE OS C�DIGOS DE FORMA PADRONIZADA.
	// **************************************************************************************************************

	aErros 		:= { 	{ 'ERRO01' , "Verifica��o para valida��o da integra��o 2230, Existe um registro com essa mesma chave e com data t�rmino em branco'" } ,;
						{ '000010' , "Verifica��o para valida��o da integra��o 2205/2006, Para a integra��o dos eventos de altera��o S-2205 (Altera��o de Dados Cadastrais do Trabalhador) ou S-2206 (Altera��o de Contrato de Trabalho), � necess�rio que exista o evento S-2200 (Cadastramento Inicial do V�nculo) ou S-2200 (Admiss�o de Trabalhador) correspondente ao evento de altera��o do trabalhador." } ,;
						{ '000011' , "Verifica��o para valida��o da integra��o 2306, Para a integra��o do evento de altera��o S-2305 (Trabalhador Sem V�nculo - Altera��o Contratual) ou t�rmino S-2399 (Trabalhador Sem V�nculo - T�rmino), � necess�rio que exista o evento S-2300 (Trabalhador Sem V�nculo - In�cio) correspondente ao evento de altera��o ou t�rmino do trabalhador sem v�nculo." } ,;
						{ '000012' , "Verifica��o para valida��o da integra��o 2205/2006, O evento de altera��o do trabalhador integrado, S-2205 (Altera��o de Dados Cadastrais do Trabalhador) ou S-2206 (Altera��o de Contrato de Trabalho), possui um evento pai S-2200 (Cadastramento Inicial do V�nculo) ou S-2200 (Admiss�o de Trabalhador) com inconsist�ncia ou n�o validado pelo RET." } ,;
						{ '000013' , "Verifica��o para valida��o da integra��o 2306, O evento de altera��o ou t�rmino do trabalhador sem v�nculo integrado, S-2305 (Trabalhador Sem V�nculo - Altera��o Contratual) ou S-2399 (Trabalhador Sem V�nculo - T�rmino), possui o evento pai S-2300 (Trabalhador Sem V�nculo - In�cio) com inconsist�ncia ou n�o validado pelo RET." } ,;
						{ 'ERRO15' , "Verifica��o para valida��o de Eventos N�o Peri�dicos, Existem campos da chave que n�o foram enviados na mensagem, n�o foi poss�vel realizar a integra��o deste registro" } ,;
						{ 'ERRO16' , "Verifica��o para valida��o de Eventos N�o Peri�dicos, Ocorreu um erro interno do sistema durante a integra��o deste registro, tente novamente" } ,;
						{ 'ERRO17' , "Verifica��o para valida��o de Eventos N�o Peri�dicos, N�o � poss�vel integrar um evento de Altera��o quando houver uma Finaliza��o ativa.'" } ,;
						{ 'ERRO18' , "Verifica��o para valida��o de Eventos N�o Peri�dicos, N�o � poss�vel integrar este evento, pois existe um 'Cancelamento' ativo para este Afastamento." } 	,;
						{ 'ERRO19' , IIf(FindFunction("TafTableTag"),TafTableTag(cAlsMsg, cXErrLog ),"Verifica��o de chave duplicada, Erro de chave duplicada, favor verificar as informa��es que est�o sendo integradas. ")  } 																																	,;
						{ '000023' , "O evento de altera��o ou t�rmino do trabalhador sem v�nculo integrado, S-2305 (Trabalhador Sem V�nculo - Altera��o Contratual) ou S-2399 (Trabalhador Sem V�nculo - T�rmino), possui o evento pai S-2300 (Trabalhador Sem V�nculo - In�cio) aguardando retorno do Governo." } ,;
						{ '000024' , "O evento de altera��o do trabalhador integrado, S-2205 (Altera��o de Dados Cadastrais do Trabalhador) ou S-2206 (Altera��o de Contrato de Trabalho), possui um evento pai S-2100 (Cadastramento Inicial do V�nculo) ou S-2200 (Admiss�o de Trabalhador) com inconsist�ncia ou n�o validado pelo RET." } ,;
						{ '000025' , "N�o � permitido a integra��o deste evento, enquanto outro tiver pendente de transmiss�o." } ,;
						{ '000026' , "Verifica��o para valida��o de integra��o S-3000, Exclus�o direta de Evento - A chave do evento enviado no S-3000 n�o estava transmitida ao Governo." } ,;
						{ '000027' , "N�o � permitido a integra��o deste evento, enquanto o outro estiver como n�o autorizado ( retornado com erro pelo ret )"},;
						{ '000028' , "Para a integra��o do evento de t�rmino S-2399 (Trabalhador Sem V�nculo - T�rmino), � necess�rio que exista o evento S-2300 (Trabalhador Sem V�nculo - In�cio) correspondente ao evento de t�rmino do trabalhador sem v�nculo."}}
			
	if ( nPosErr := aScan( aErros , {|x| x[ 1 ] == allTrim( cErro ) } ) ) > 0
		If aErros[ nPosErr  , 1 ] == '000026'
			cErroDePara := "000026"
		Else
		cErroDePara := "000009"
		EndIf
		
		cErroXERP   := aErros[ nPosErr  , 2 ]
	endif

	If nPosErr == 0
		if ( nPosErr := aScan( aTAFCodErr , {|x|x[1] == AllTrim(cErro) } ) ) > 0
			cErroDePara := aTAFCodErr[nPosErr ,1]
			cErroXERP   := aTAFCodErr[nPosErr ,2]
		endif
	endif

return cErroDePara

//-------------------------------------------------------------------
/*/{Protheus.doc} getQueueProc

Retorna o status que ser� registrado no log da TAFXERP e o status do registro
em rela��o a fila de integra��o.
Enviar os par�metros cStatusXERP e cStatQueue como refer�ncia.

@Param	cStatusXERP	- Status que ser� registrado na tabela TAFXERP
		cStatQueue	- Status que ser� retornado para a fila de integra��o
		cCodErroXERP- C�digo de erro conforme a fun��o TAFCodErr()

@Author	Luccas Curcio
@Since	19/05/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
static function getQueueProc( cStatusXERP , cStatQueue , cCodErroXERP )

	Default cStatQueue := ""

	cStatusXERP := '9'

	//Quando se tratar de fila de integra��o, define neste momento se o registro permanece na Fila ou � rejeitado
	If cStatQueue == 'F'
		If aScan( aTAFCodErr , { |x| x[ 1 ] == cCodErroXERP .and. x[ 3 ] == 'Q' } ) > 0
			cStatusXERP := '4'
		Else
			cStatusXERP	:= '9'
			cStatQueue		:= 'R'
		EndIf
	ElseIf cCodErroXERP == '000030'
		cStatusXERP := '7'
	Else
		cStatusXERP := '9'
	EndIf

	//---------------------------------
	//	Exce��es - STATUS TAFXERP
	//---------------------------------
	// C�digo de erro 000002 -> Filial n�o encontrada: Status '8'
	if cCodErroXERP == "000002"
		cStatusXERP := '8'

	// C�digo de erro 000026 -> Exclus�o direta de Evento: Status '5'
	elseif cCodErroXERP == "000026"
		cStatusXERP := '5'
	endif

return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} eSocExtST1

Extrai informa��es da chamada online - TAFPrepInt - na tabela TAFST1

@param cLayout - Registro do layout sem o prefixo. Ex: 1010, 1020
@param cXml - Mensagem de integra��o
@param cFilOri - Filial de origem da integra��o
@param cKey - Chave do registro de integra��o
@param cTicket - Lote do registro de integra��o
@param cSeq - c�digo sequencial para integra��o

@Author	Luccas Curcio
@Since
@Version 1.0
/*/
//-------------------------------------------------------------------
static function eSocExtST1( cLayout , cXml , cFilOri , cKey , cTicket , cSeq )

	local lRet		:= .T.
	local lFOpnTab	:= findFunction( "FOpnTabTAf" )
	local cAliasST1	:= 'TAFST1'

	default cSeq := '001'

	//--------------------------------------------------------------
	// Cria conex�o com a tabela TAFST1
	//--------------------------------------------------------------
	//Carrega estrutura da tabela
	if lFOpnTab
		lRet		:= FOpnTabTAf( cAliasST1 , cAliasST1 )
	else
		lRet := .F.

		if isBlind()
			TAFConOut( STR0035 ) //'Tabela TAFST1 n�o localizada ou n�o existente. Execute o Wizard de Configura��o do TAF.'
		else
			Alert( STR0035 ) //'Tabela TAFST1 n�o localizada ou n�o existente. Execute o Wizard de Configura��o do TAF.'
		endif

	endIf

	if lRet

		if recLock( cAliasST1 , .T. )
			TAFST1->TAFFIL		:= cFilOri
			TAFST1->TAFCODMSG	:= '2'
			TAFST1->TAFSEQ		:= cSeq
			TAFST1->TAFTPREG	:= 'S-' + cLayout
			TAFST1->TAFKEY		:= cKey
			TAFST1->TAFMSG		:= cXml
			TAFST1->TAFSTATUS	:= '1'
			TAFST1->TAFDATA		:= dDataBase
			TAFST1->TAFHORA		:= Time()
			TAFST1->TAFTICKET	:= cTicket

			msUnLock()

			dbCommit()
		endif

	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xFTelReinf
Fun��o para tratamento do campo de telefone dos layout da Reinf

@author evandro.oliveira
@since 20/02/2017
@version 1.0
@param cValor - Valor do campo telefone (deve conter o DDD)
@param nCampo - determina se o retorno deve ser o DDD ou o Telefone
		1 - DDD
		2 - Telefone
@return cRet - Valor Formatado
@example
01123256699 - o Retorno para o DDD seria 011 e para o telefone 23256699
1123256699 - o Retorno para o DDD seria 11 e para o telefonoe 23256699
/*/
//-------------------------------------------------------------------
Function xFTelReinf(cValor,nCampo)

	Local cRet := ""
	Default nCampo := 1


	//O DDD pode ser 3 posi��es porem o primeiro digito deve ser 0
	if nCampo == 1
		cRet := iif(SUBSTR(AllTrim(cValor),1,1)=='0',SUBSTR(AllTrim(cValor),1,3),SUBSTR(AllTrim(cValor),1,2))"
	elseif nCampo == 2
		cRet := iif(SUBSTR(AllTrim(xA),1,1)=='0',SUBSTR(AllTrim(xA),4),SUBSTR(AllTrim(xA),3))
	endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TafHMControl
Fun��o para a cria��o do hashmap do cotrole de exclus�o de TAGS

@author fabio.santana
@since 29/12/2017
@version 1.0
@param

@return aRet - HashMap
/*/
//-------------------------------------------------------------------
Function TafHMControl(oHMControl,cLayout)

	Local lAlsT93 := TAFAlsInDic( 'T93' )
	Local cCodEvento  := Posicione("C8E",2,xFilial("C8E")+cLayout,"C8E->C8E_ID")

	//HashMap que carrega os dados das tabelas T93 e T94 usadas no controle de exclus�o de tags
	oHMControl := Nil

	If lAlsT93
		//Verifico se o evento informado esta na tabela de controle
		If T93->(DbSeek( xFilial( "T93" ) + cCodEvento ))

			oHMControl := HMNew()

			//Monta a tabela filho, adiciono somente as informa��es da tabela Pai - T93
			HMAdd( oHMControl, {AllTrim(T93->T93_EVENTO),;
								T93->T93_EVENTO,;
								"",;
								"",;
								"",;
								T93->T93_ATIVO	,;
								T93->T93_PADRAO},;
								1,3)

			//Monta o HashMap com as informa��es da tabela de controle - Tabela filho - T94
			If T94->(DbSeek( xFilial( "T94" ) + cCodEvento ))
				While T94->( !Eof() ) .And. T94->T94_EVENTO == cCodEvento
					HMAdd( oHMControl, {AllTrim(T94->T94_EVENTO)+AllTrim(T94->T94_NODE),;
										T94->T94_EVENTO	,;
										T94->T94_NODE  	,;
										T94->T94_PROPRI	,;
										T94->T94_EXCLUI	,;
										T93->T93_ATIVO	,;
										T93->T93_PADRAO},;
										1,3)
					T94->( DbSkip() )
				EndDo
			EndIf
		Else
			//Caso n�o encontre o evento na tabela de controle T93, destroi o objeto.
			oHMControl := Nil
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafGrpThr

Executa uma nova thread para processar transferencia de 
grupo de emoresas.

@Param cEmp       -> Empresa para processamento da thread
       cFil       -> Filial para processamento da thread

@Return ( aErros )

@Author Leonardo Kichitaro
@Since  31/08/2018
@Version 1.0
/*/
//-------------------------------------------------------------------

Function TafGrpThr(cFunction,cLayout,nOpc,cFilOri,cXml,cOwner,cFilTran,cGrpTran,cEmpEnv,cFilEnv,cXmlID,cEvtOri,lDepGPE,cKey,cMatrC9V,cJsonTransf,lIntOnline)

	Local aRet := {}
	Local oXML := Nil 
	Local cFilErp := ""
	Local nRecNoC9V := 0 

	RPCSetType( 3 )
	RPCSetEnv(cGrpTran,cFilTran,,,"TAF","TafGrpThr")

	oTransf	:= TafTransfTrab():New(cJsonTransf)
	eSocialParserXml(cXml,@oXML,lIntOnline) 
	cFilErp := cGrpTran + AllTrim(cFilTran) //No GPE o c�digo � sempre o Grupo + Filial, por�m o correto era esse c�digo j� ser passado pelo ERP na TafprepInt
	
	Begin Transaction //Como estou em outra Thread preciso controlar uma nova transa��o
	aRet := &(cFunction + "(cLayout,@nOpc,cFilErp,oXml,cOwner,,'',@nRecNoC9V,'',cGrpTran,cEmpEnv,cFilEnv,cXmlID,cEvtOri,.F.,lDepGPE,cKey,cMatrC9V,.F.,.F.,oTransf)")
	If !aRet[1]
		DisarmTransaction()
	EndIf 
	End Transaction

	aAdd(aRet,nRecNoC9V)

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TafSeekRot
Fun��o para defini��o do nome da fun��o em uso

@author douglas.heydt	
@since 27/08/2018
@version 1.0
@param

@return cRotina
/*/
//-------------------------------------------------------------------
Function TafSeekRot(cAlias)
	
	Local cRotina := ""
	Local aRotina := TAFRotinas(,,,2)  
	Local nPosRot := aScan( aRotina , { | aX | AllTrim( aX[ 3 ] ) == cAlias } )

	cRotina := aRotina[nPosRot,1]

	If cAlias == "C91"

		If C91->C91_NOMEVE == "S1200"
			cRotina := "TAFA250"
		ElseIf C91->C91_NOMEVE == "S1202"
			cRotina := "TAFA413"
		EndIf

	ElseIf cAlias == "C9V"

		If C9V->C9V_NOMEVE == "S2200"
			cRotina := "TAFA278"
		ElseIf C9V->C9V_NOMEVE == "S2300"
			cRotina := "TAFA279"
		ElseIf C9V->C9V_NOMEVE == "TAUTO"
			cRotina := "TAFA473"
		EndIf

	ElseIf cAlias == "V73"

		If V73->V73_NOMEVE == "S2400"
			cRotina := "TAFA589"
		ElseIf V73->V73_NOMEVE == "S2405"
			cRotina := "TAFA590"
		EndIf

	EndIf
	
	If Empty(cRotina)
		cRotina := FunName()
	EndIf

Return cRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} GeraTAFST2
Gera TAFST2 � partir da integra��o via GPE.

@author  leandro.dourado
@since 	 10/10/2018
@version 1.0

@return cRotina
/*/
//-------------------------------------------------------------------
Static Function GeraTAFST2( cFilTaf, cXml, cTafKey, cTicket, cEvento, cPredeces, cComplem, cFilTran, cGPExERP )

	Local lGrava      := .T.
	Local aErro       := {}
	Local cAliasST2   := ""

	Default cFilTaf   := ""
	Default cXml      := ""
	Default cTafKey   := ""
	Default cTicket   := ""
	Default cEvento   := ""
	Default cPredeces := ""
	Default cComplem  := ""
	Default cFilTran  := ""
	Default cGPExERP  := ""

	cTafKey := AllTrim(cTafKey)
	cTicket := AllTrim(cTicket)

	If !Empty(cXML) .And. IsUTF8(cXML)
		cXML := RemoveUTF8(cXML)
		cXML := DeCodeUTF8(cXML)
		
		If cXML == Nil
			lGrava := .F.
		EndIf
	EndIf

	If lGrava
		If Empty(cTafKey)
			cTafKey := AllTrim(FWUUId("GPETAF"))
		EndIf
		
		If Empty(cTicket)
			cTicket := AllTrim(FWUUId("GPETAF"))
		EndIf
		
		If !TafChkKey( cFilTaf, cEvento, cTafKey )
			lGrava := .F.
			aAdd( aErro, "O TAFKEY " + cTafKey + " j� existe na TAFST2 e encontra-se pendente de processamento ou em processamento." )
		EndIf
	EndIf

	If lGrava
		cAliasST2 := GetNextAlias()
		cGPExERP  := GetNextAlias()
		
		If TAFTabInteg("TAFXERP",cGPExERP,@aErro)
			If TAFTabInteg("TAFST2",cAliasST2,@aErro) .And. RecLock( cAliasST2, .T.)
				(cAliasST2)->TAFFIL     := cFilTaf 
				(cAliasST2)->TAFCODMSG  := "2"	
				(cAliasST2)->TAFSEQ     := "001"
				(cAliasST2)->TAFTPREG   := cEvento
				(cAliasST2)->TAFKEY     := cTafKey
				(cAliasST2)->TAFMSG     := cXML
				(cAliasST2)->TAFSTATUS  := "3"
				(cAliasST2)->TAFIDTHRD  := StrZero( ThreadID(), 10 )
				(cAliasST2)->TAFTICKET  := cTicket
				(cAliasST2)->TAFDATA    := dDataBase
				(cAliasST2)->TAFHORA    := Time(  )
				(cAliasST2)->TAFFILTRAN := cFilTran
				(cAliasST2)->TAFOWNER   := "GPE"
				(cAliasST2)->TAFPRIORIT := "5"
				(cAliasST2)->TAFSTQUEUE := ""
				(cAliasST2)->TAFREGPRED := cPredeces
				(cAliasST2)->TAFCOMP    := cComplem
				(cAliasST2)->(MsUnlock())
			Else
				aAdd( aErro, "Erro na Criacao/Abertura da tabela TAFST2." )
			EndIf
		Else
			aAdd( aErro, "Erro na Criacao/Abertura da tabela TAFXERP." )
		EndIf
		(cAliasST2)->(DbCloseArea())
	EndIf
 
Return aErro

//----------------------------------------------------------------------------
/*/{Protheus.doc} isUTF8 
Verifica se o Xml est� com codifica��o UTF-8

@param cXml - Xml do Evento

@return logico - valor booleano

@author Evandro dos Santos O. Teixeira
@since 11/05/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function isUTF8(cXml)
Return ('ENCODING="UTF-8"' $ Upper(cXml))

//----------------------------------------------------------------------------
/*/{Protheus.doc} RemoveUTF8 
Retira a Identifica��o de codifica��o UTF8 do inicio do XML.
� realizado este tratamento para que os Xmls fiquem na TAFST2 iguais idependente
da tecnologia utilizada na integra��o.

@param cXml - Xml do Evento

@return cXmlRet - Xml Sem a Tag de Encode.

@author Evandro dos Santos O. Teixeira
@since 11/05/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function RemoveUTF8(cXml)

	Local nStart 	:= 0
	Local cXmlRet 	:= ""

	nStart := AT(">",cXml) 
	cXmlRet := Substr(cXml,nStart+1,Len(cXml)-(nStart))
	cXmlRet := StrTran(cXmlRet,Chr(13),"")
	cXmlRet := StrTran(cXmlRet,Chr(10),"")
	
Return cXmlRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGetST2GPE
Retorna se houve a gera��o da TAFST2 a partir do GPE.

@author  leandro.dourado
@since 	 17/10/2018
@version 1.0

@return lGerouST2
/*/
//-------------------------------------------------------------------
Function TAFGetST2GPE()

Return lGerouST2

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkDeslig
Verifica se o trabalhador foi desligado. 
Caso seja informado o per�odo de apura��o, a rotina avaliar� se o per�odo � anterior ao desligamento.

@author  leandro.dourado
@since 	 20/12/2018
@version 1.0

@return lRet, Logical, Indica verdadeiro caso o trabalhador informado esteja desligado
/*/
//-------------------------------------------------------------------
Static Function ChkDeslig( cFilTrab, cIdTrab, cEvento, cPerApu )
	Local aArea     := GetArea()
	Local lRet      := .F.
	Local cAliasDes := ""
	Local nIndex    := 0
	Local cCpoTrab  := ""
	Local cCpoDtDes := ""
	Local dFrtDt	:= CtoD("")

	Default cPerApu := ""

	If !Empty(cPerApu)
		cPerApu := StrTran(cPerApu,'-','')
		dFrtDt	:= CtoD("01/" + SubStr(cPerApu,5,2) + "/" + SubStr(cPerApu,1,4))
	EndIf

	If cEvento == "S2200"

		cAliasDes := "CMD"
		nIndex    := 5 //CMD_FILIAL+CMD_FUNC+CMD_ATIVO
		cCpoTrab  := "CMD_FUNC"
		cCpoDtDes := "CMD->CMD_DTDESL"
		
	ElseIf cEvento == "S2300"

		cAliasDes := "T92"
		nIndex    := 3 //T92_FILIAL+T92_TRABAL+T92_ATIVO
		cCpoTrab  := "T92_TRABAL"
		cCpoDtDes := "T92->T92_DTERAV"
		
	EndIf

	If cEvento $ "S2200|S2300"	
		
		DbSelectArea(cAliasDes)
		(cAliasDes)->(DbSetOrder(nIndex))

		If (cAliasDes)->(DbSeek(xFilial(cAliasDes,cFilTrab) + Padr( cIdTrab, TamSX3(cCpoTrab)[1] ) + "1" )) .And.;
			&((cAliasDes) + '->' + cAliasDes + '_STATUS') == "4" .And.; 
			&((cAliasDes) + '->' + cAliasDes + '_PROTUL') <> Space(TamSX3( cAliasDes + "_PROTUL" )[1])
	
			If Empty(dFrtDt) .Or. (!Empty(dFrtDt) .And. dFrtDt > &(cCpoDtDes))
				lRet := .T.
			EndIf
		
		EndIf

	EndIf

	RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TafEnableSX9
Rotina respons�vel por habilitar o SX9 em casos especificos.
@author  TOTVS
@since   21-05-2019
@version version
/*/
//-------------------------------------------------------------------

Function TafEnableSX9( cTab )

	Local lRet  	:= .T.
	Local aArea 	:= GetArea()
	Local aSX9Area  := SX9->(GetArea())
	Local aEstrut	:= (aSX9Area[1])->( DbStruct() )
	Local nZ   		:= 0

	/*2� Habilito todos os relacionamentos da tabela que tiverem apenas o campo cAlias_ID no campo X9_EXPDOM*/
	For nZ := 1  To Len(aSX9Rel)
		(aSX9Area[1])->(DbGoTo(aSX9Rel[nZ][1]))

		If (aSX9Area[1])->(!EOF())
			RecLock(aSX9Area[1], .F.)
				(aSX9Area[1])->&(aEstrut[11][1]) := aSX9Rel[nZ][2]
			MsUnlock()
		EndIf    
	Next nZ

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TafDisableSX9
Rotina respons�vel por desabilitar o SX9 em casos especificos.

@author  TOTVS
@since   21-05-2019
@version version
/*/
//-------------------------------------------------------------------

Function TafDisableSX9( cTab )

	Local lRet      := .T.
	Local aArea     := GetArea()
	Local aSX9Area  := SX9->(GetArea())
	Local aEstrut	:= (aSX9Area[1])->( DbStruct() )
	Local aRelacao 	as array
	Local cEnable	:= '_ENABLE'
	Local lRetif		:= .T.

	//Verifica se � uma retifica��o
	If FieldPos(cTab + '_VERANT') > 0 .And. Empty((cTab)->&(cTab + '_VERANT'))
		lRetif := .F.
	EndIf

	If lRetif
		Begin Transaction

			/* 2� Salvo todos os status do SX9 para restaurar depois. */
			(aSX9Area[1])->(DbSetOrder(1))
			If (aSX9Area[1])->(DbSeek(cTab))
				While (aSX9Area[1])->(!Eof()) .And. (aSX9Area[1])->&(aEstrut[1][1]) == cTab
					If AllTrim((aSX9Area[1])->&(aEstrut[4][1])) == cTab+"_ID" ;
					.OR. 	AllTrim((aSX9Area[1])->&(aEstrut[4][1])) == cTab + "_ID+" + cTab + "_ATIVO" ;
						.OR. ( cTab == "C9V" .AND. AllTrim((aSX9Area[1])->&(aEstrut[4][1])) == "C9V_CPF+C9V_ATIVO" );
						.OR. ( cTab == 'C92' .AND. AllTrim((aSX9Area[1])->&(aEstrut[4][1])) == 'C92_NRINSC+C92_ATIVO');
						.OR. ( cTab == 'T0Q' .AND. AllTrim((aSX9Area[1])->&(aEstrut[4][1])) == 'T0Q_FILIAL+T0Q_ID+T0Q_VERSAO+T0Q_CODAMB')

						FWSX9Util():SearchX9Paths( cTab, (aSX9Area[1])->&(aEstrut[3][1]), @aRelacao )

						If Len(aRelacao) > 0 .And. ( (aSX9Area[1])->&( SubStr(aSX9Area[1],2) + cEnable) == "S" )
							aAdd(aSX9Rel,{ (aSX9Area[1])->&('(Recno())') , (aSX9Area[1])->&( SubStr(aSX9Area[1],2) + cEnable) })
							
							/* 3� Desabilito o SX9 de todos os registros relacionados ao Alias. */
							RecLock(aSX9Area[1], .F.) 
								(aSX9Area[1])->&(aEstrut[11][1]) := "N"
							MsUnlock()
						EndIf
					EndIf
					(aSX9Area[1])->(DbSkip())
				End
			EndIf

		End Transaction
	EndIf
	RestArea(aArea)
	RestArea(aSX9Area)

Return lRet

/*/{Protheus.doc} TafAjustDeps
	Rotina desenvolvida para que possibilite ao SIGAGPE
	ajuste os dependentes do registro criado na C9V que
	possibilita a inclus�o do S-2206 de transfer�ncia.
	@type  Function
	@author Diego Santos
	@since 27-09-2019
	@version 1.0
	@return return, Nil, N�o h� retorno para esta fun��o
/*/
Function TafAjustDeps( oModel, oDados, cEvento, cFonte, cAlias, cInconMsg, aIncons, nSeqErrGrv )

	Local aArea 		:= GetArea()
	Local nTamModel 	:= 0
	Local nJ 			:= 0
	Local nOpc			:= 4
	Local cCabecTrab 	:= Iif( cEvento == "S2300", "/eSocial/evtTSVInicio/trabalhador", "/eSocial/evtAdmissao/trabalhador" )
	Local cCodEvent  	:= Posicione("C8E",2,xFilial("C8E")+cEvento,"C8E->C8E_ID")
	Local cOwner		:= ""
	Local lEmpty    	:= .F.

	//1� Passo - Verificar se trata-se de um registro criado para o correto funcionamento do S-2206/S-2306.
	If !Empty(&(cAlias+"->"+cAlias+"_IDTRAN")) .And. Empty(&(cAlias+"->"+cAlias+"_DTTRAN"))

		//2� Passo - Carrego o Modelo
		FCModelInt( cAlias, cFonte, @oModel, nOpc, ,.F. )

		If cFonte == "TAFA278"

			cC9YPath := cCabecTrab + "/dependente"
			nTamModel := oModel:GetModel("MODEL_C9Y"):Length()

			//3� Passo - Deleto todas as linhas do Modelo de Dependentes
			For nJ := 1 to nTamModel
				oModel:GetModel( "MODEL_C9Y" ):GoLine(nJ)
				oModel:GetModel( "MODEL_C9Y" ):DeleteLine()
			Next nJ

			//4� Passo - Atualizo o sub-Modelo de dependentes com o valor enviado pelo SIGAGPE.
			//Rodo o XML parseado para gravar as novas informacoes no GRID ( Dependentes )
			nJ	:= 1					
			While oDados:XPathHasNode( cCabecTrab + "/dependente[" + cValToChar(nJ)+ "]" )

				If nOpc == 4 .Or. nJ > 1
					oModel:GetModel( "MODEL_C9Y" ):lValid:= .T.
					oModel:GetModel( "MODEL_C9Y" ):AddLine()
				EndIf
							
				If TafXNode( oDados, cCodEvent, cOwner, (cC9YPath + "[" + cValToChar(nJ) + "]/tpDep"), cC9YPath + "/tpDep")	
					oModel:LoadValue( "MODEL_C9Y", "C9Y_IDDEP", StrZero(nJ,6) )
					oModel:LoadValue( "MODEL_C9Y", "C9Y_TPDEP", FGetIdInt( "tpDep", "", cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/tpDep" ,,,,@cInconMsg, @nSeqErrGrv,,, @lEmpty ) )				
				EndIf
						
				If TafXNode( oDados, cCodEvent, cOwner, (cC9YPath + "[" + cValToChar(nJ) + "]/nmDep"), cC9YPath + "/nmDep")
					oModel:LoadValue("MODEL_C9Y", "C9Y_NOMDEP", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/nmDep", "C", .F., @aIncons, .F., '', '',, @lEmpty ) )
				EndIf
						
				If TafXNode( oDados, cCodEvent, cOwner, (cC9YPath + "[" + cValToChar(nJ) + "]/dtNascto"), cC9YPath + "/dtNascto")
					oModel:LoadValue( "MODEL_C9Y", "C9Y_DTNASC", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/dtNascto", "D", .F., @aIncons, .F., '' ,'',, @lEmpty ) )
				EndIf
				
				//Verifico se foi enviado as TAGs no XML
				If oDados:XPathHasNode( cC9YPath + "[" + cValToChar(nJ)+ "]" )
						
					If TafXNode( oDados, cCodEvent, cOwner, (cC9YPath + "[" + cValToChar(nJ) + "]/cpfDep"), cC9YPath + "/cpfDep" )
						oModel:LoadValue( "MODEL_C9Y", "C9Y_CPFDEP", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/cpfDep"  , "C", .F., @aIncons, .F., '', '' ) )
					EndIf
							
					If TafXNode( oDados, cCodEvent, cOwner, (cC9YPath + "[" + cValToChar(nJ) + "]/depIRRF"), cC9YPath + "/depIRRF" )
						oModel:LoadValue( "MODEL_C9Y", "C9Y_DEPIRF", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/depIRRF" ),2 ), "C", .T., @aIncons, .F., '', '' ) )
					EndIf
							
					If TafXNode( oDados, cCodEvent, cOwner, (cC9YPath + "[" + cValToChar(nJ) + "]/depSF"), cC9YPath + "/depSF" )
						oModel:LoadValue( "MODEL_C9Y", "C9Y_DEPSFA", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/depSF" ),2 ), "C", .T., @aIncons, .F., '', '' ) )
					EndIf
					
					If TafXNode( oDados, cCodEvent, cOwner, (cC9YPath + "[" + cValToChar(nJ) + "]/incTrab"), cC9YPath + "/incTrab" )
						oModel:LoadValue( "MODEL_C9Y", "C9Y_INCTRB", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/incTrab" ),2 ), "C", .T., @aIncons, .F., '', '' ) )
					EndIf
				
				EndIf
											
				nJ++
			EndDo		

		ElseIf cFonte == "TAFA279"

			nTamModel := oModel:GetModel( "MODEL_T2F" ):Length()		

			//3� Passo - Deleto todas as linhas do Modelo de Dependentes
			For nJ := 1 to oModel:GetModel( "MODEL_T2F" ):Length()
				oModel:GetModel( "MODEL_T2F" ):GoLine( nJ )
				oModel:GetModel( "MODEL_T2F" ):DeleteLine()
			Next nJ

			//4� Passo - Atualizo o sub-Modelo de dependentes com o valor enviado pelo SIGAGPE.
			//Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Dependentes )
			nJ := 1
			While oDados:XPathHasNode( cCabecTrab + "/dependente[" + cValToChar(nJ)+ "]" )

				If nOpc == 4 .Or. nJ > 1
					oModel:GetModel( "MODEL_T2F" ):lValid:= .T.
					oModel:GetModel( "MODEL_T2F" ):AddLine()
				EndIf

				oModel:LoadValue( "MODEL_T2F", "T2F_IDDEP" , StrZero(nJ,6) )
				if oDados:XPathHasNode(cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/tpDep")
					oModel:LoadValue( "MODEL_T2F", "T2F_TPDEP" , FGetIdInt( "tpDep", "", cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/tpDep",,,,@cInconMsg, @nSeqErrGrv))
				EndIf
				if oDados:XPathHasNode(cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/nmDep")
					oModel:LoadValue( "MODEL_T2F", "T2F_NOMDEP", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/nmDep"                              , "C", .F., @aIncons, .F. ) )
				EndIf
				if oDados:XPathHasNode( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/dtNascto")
					oModel:LoadValue( "MODEL_T2F", "T2F_DTNASC", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/dtNascto"                             , "D", .F., @aIncons, .F. ) )
				EndIf
				if oDados:XPathHasNode( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/cpfDep" )
					oModel:LoadValue( "MODEL_T2F", "T2F_CPFDEP", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/cpfDep"                               , "C", .F., @aIncons, .F. ) )
				EndIf
				if oDados:XPathHasNode(cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/depIRRF")
					oModel:LoadValue( "MODEL_T2F", "T2F_DEPIRF", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/depIRRF" ) ,2), "C", .T., @aIncons, .F. ) )
				EndIf
				if oDados:XPathHasNode( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/depSF")
					oModel:LoadValue( "MODEL_T2F", "T2F_DEPSFA", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/depSF"   ) ,2), "C", .T., @aIncons, .F. ) )
				EndIf
				if oDados:XPathHasNode(cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/incTrab")
					oModel:LoadValue( "MODEL_T2F", "T2F_INCTRB", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nJ) + "]/incTrab"  ) ,2) , "C", .T., @aIncons, .F. ) )
				EndIf

				nJ++
			End

		EndIf 

	Else
		cInconMsg := "N�o ser� poss�vel ajustar os dependentes de um funcion�rio n�o transferido."
	EndIf

	RestArea(aArea)

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} xTafVExc
Cria uma interface para a exclus�o do registro S-3000 e realiza
as valida��es e manuten��es necess�rias no envento gerador.

@Param  cCpf		- Cpf do Trabalhador 
		cMatricula  - Matricula do Trabalhador
		lLast 		- Indica que o retorno dever� ser somente do ultimo
			      	Afastamento

@Return a2399
		Se lLast == .T. 
			a2399[1] := Id Funcionario
			a2399[2] := Data de Desligamento
			a2399[3] := Motivo do Desligamento
			a2399[4] := C9V_NOMEVE (nome do evento do trabalhador)

		Se lLast == .F. 
			a2399[n]
			a2399[n][1] := Id do Funcion�rio
			a2399[n][1][2]
			a2399[n][1][2][y][1] := Data de Desligamento 
			a2399[n][1][2][y][2] := Motivo do Desligamento
			a2399[n][1][2][y][3] := C9V_NOMEVE (nome do evento do trabalhador)

@Author Evandro dos Santos Oliveira
@Since 16/07/2020
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TafGetDesligamentos(cCpf,cMatricula,lLast)

	Local cSql := ""
	Local a2399 := {}
	Local nPosAf := 0

	Default cCpf := ""
	Default cMatricula := ""
	Default lLast := .F. 

	cSql := ""

	cSql := " SELECT ID_FUNC, MOT_DESLIG, DT_DESLIG, NOME_EVENTO FROM ( "
	cSql += " SELECT DISTINCT CMD.CMD_FUNC ID_FUNC, "
	cSql += " CMD.CMD_MOTDES MOT_DESLIG, "
	cSql += " CMD.CMD_DTDESL DT_DESLIG, "
	cSql += " C9V.C9V_NOMEVE NOME_EVENTO "
	cSql += " FROM " + RetSqlName("CMD") + " CMD"
	cSql += " INNER JOIN " + RetSqlName("C9V") + " C9V ON CMD.CMD_FUNC = C9V.C9V_ID " 

	If !Empty(cCpf)

		cCpf := AllTrim(cCpf)
		cCpf := PadR(cCpf,GetSx3Cache("C9V_CPF","X3_TAMANHO"))
		cSql += " AND C9V.C9V_CPF = '" + cCpf + "'"
	EndIf 

	If !Empty(cMatricula)

		cMatricula := xGetMatric(cMatricula)
		cMatricula := PadR(cMatricula,GetSx3Cache("C9V_MATRIC","X3_TAMANHO"))
		cSql += " AND C9V.C9V_MATRIC = '" + cMatricula + "'"
	EndIf 

	cSql += " AND C9V.C9V_STATUS = '4' "
	cSql += " AND C9V.C9V_ATIVO = '1' "
	cSql += " AND C9V.D_E_L_E_T_ = ' ' " 
	cSql += " WHERE CMD.CMD_ATIVO = '1' "
	cSql += " AND CMD.CMD_STATUS = '4' "
	cSql += " AND CMD.D_E_L_E_T_ = ' ' "

	cSql += " UNION ALL "

	cSql += " SELECT DISTINCT T92.T92_TRABAL ID_FUNC, "
	cSql += " T92.T92_MOTDES MOT_DESLIG, "
	cSql += " T92.T92_DTERAV DT_DESLIG, "
	cSql += " C9V.C9V_NOMEVE NOME_EVENTO "
	cSql += " FROM " + RetSqlName("T92") + " T92"
	cSql += " INNER JOIN " + RetSqlName("C9V") + " C9V ON T92.T92_TRABAL = C9V.C9V_ID " 

	If !Empty(cCpf)

		cCpf := AllTrim(cCpf)
		cCpf := PadR(cCpf,GetSx3Cache("C9V_CPF","X3_TAMANHO"))
		cSql += " AND C9V.C9V_CPF = '" + cCpf + "'"
	EndIf 

	cSql += " AND C9V.C9V_STATUS = '4' "
	cSql += " AND C9V.C9V_ATIVO = '1' "
	cSql += " AND C9V.D_E_L_E_T_ = ' ' " 
	cSql += " WHERE T92.T92_ATIVO = '1' "
	cSql += " AND T92.T92_STATUS = '4' "
	cSql += " AND T92.D_E_L_E_T_ = ' ' "

	cSql += " ) TMP "
	cSql += " ORDER BY DT_DESLIG DESC "

	TCQuery cSql New Alias 'rsAf'

	If lLast .And. rsAf->(!Eof())

		a2399 := {rsAf->ID_FUNC,;
				  rsAf->DT_DESLIG,;
				  rsAf->MOT_DESLIG,;
				  rsAf->NOME_EVENTO}
	Else 

		While rsAf->(!Eof())

			If Len(a2399) > 0		
				nPosAf := aScan(a2399,{|a|a[1] == rsAf->ID_FUNC})
			EndIf 

			If nPosAf == 0
				aAdd(a2399,{rsAf->ID_FUNC,	{{;
											rsAf->DT_DESLIG,;
											rsAf->MOT_DESLIG,;
											rsAf->NOME_EVENTO;
											}};
							};
					)
			Else 
				aAdd(a2399[nPosAf][2],{;
									rsAf->DT_DESLIG,;
									rsAf->MOT_DESLIG,;
									rsAf->NOME_EVENTO;
									};
					)
			EndIf

			nPosAf := 0
			rsAf->(dbSkip())
		EndDo 
	EndIf 

	rsAf->(dbCloseArea())

Return a2399 

//--------------------------------------------------------------------
/*/{Protheus.doc} TafCacheLayESoc
Realiza o cache da fun��o TafLayESoc

@Param  cVersaoEsocial - Vers�o do Layout e-social

@Return 

@Author Evandro dos Santos Oliveira
@Since 12/04/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TafCacheLayESoc(cVersaoEsocial)

	If __lLaySimplif == Nil 
		__lLaySimplif := TafLayESoc(cVersaoEsocial)
	EndIf 

Return __lLaySimplif 

//--------------------------------------------------------------------
/*/{Protheus.doc} analisaTransferencia
Fun��o respons�vel por analisar os dados da transfer�ncia entre GPE x TAF 
e criar o objeto TafTransfTrab, esse objeto grava todos as informa��es 
necess�rias para o processo.

@Param oXML - Objeto XML 
@Param cEmpEnv - Grupo de Origem 
@Param cFilEnv - Filial de Origem 
@Param cOwner - ERP dono da Mensagem
@Param cGrpTran - Grupo de Destino (Transfer�ncia)
@Param cFilTran - Filial de Destino (Transfer�ncia)
@Param cLayout - Nome do Evento
@Param nIndChv - Indice da Chave
@Param cMatrC9V - Matricula do Trabalhador na Filial de Origem

@Return oTransf - Objeto com os dados de Transfer�ncia

@Author Evandro dos Santos Oliveira
@Since 20/04/2021
@Version 1.0
/*/
//---------------------------------------------------------------------
static Function analisaTransferencia(oXML,cEmpEnv,cFilEnv,cOwner,cGrpTran,cFilTran,cLayout,nIndChv,cMatrC9V)

	local cMatricula 	:= ""
	local cCpf 			:= ""
	local cIdCateg 		:= ""
	local cDtInicio 	:= ""
	local nTamFil 		:= 0
	local nTamCpf 		:= 0
	local nTamMat 		:= 0
	local nPosEmp 		:= 0
	local nTamCateg		:= 0
	local cChvOri 		:= ""
	local cChvDest		:= ""
	local cCNPJOri 		:= ""
	local cCNPJDest 	:= ""
	local cInconMsg		:= ""
	local cCodCateg		:= ""
	local cMatOrig		:= ""
	local aSM0 			:= {}
	local lTransfGrp	:= .T. 
	local lMesmaBase	:= .F. 
	local oTransf		:= Nil 
	
	default cLayout := "2200"

	if !TAFFindClass("TafTransfTrab")
		return Nil 
	endIf 

	aSM0 	:= FWLoadSM0()
	oTransf	:= TafTransfTrab():New()

	nPosEmp := aScan(aSM0,{|e|e[1] == cEmpEnv .And. AllTrim(e[2]) == AllTrim(cFilEnv)})
	if nPosEmp > 0 
		cCNPJOri := AllTrim(aSM0[nPosEmp][18])
	endif 

	nPosEmp := 0

	if Empty(cGrpTran) .Or. AllTrim(cEmpEnv) == AllTrim(cGrpTran) 
		lTransfGrp := .F. // Transfer�ncia para o mesmo grupo
		nPosEmp := aScan(aSM0,{|e|e[1] == cEmpEnv .And. AllTrim(e[2]) == AllTrim(cFilTran)})
	else 
		lTransfGrp := .T. 
		nPosEmp := aScan(aSM0,{|e|e[1] == cGrpTran .And. AllTrim(e[2]) == AllTrim(cFilTran)})
	endif 

	if nPosEmp > 0 
		cCNPJDest := AllTrim(aSM0[nPosEmp][18])
	endif 

	if Empty(cCNPJDest)
		oTransf:setErrorTransfer(.T.,"000009","Filial " + cFilTran + " n�o encontrada no arquivo de empresas.")
		Return oTransf 
	endIf 
	 
	//Analisa se as filiais tem a mesma base de CNPJ 
	lMesmaBase := (Substr(cCNPJOri,1,8) == Substr(cCNPJDest,1,8))
	nTamFil := FWSizeFilial()
	nTamCpf := GetSx3Cache("C9V_CPF","X3_TAMANHO")

	if AllTrim(cLayout) == "2200"
	
		if oXML:XPathHasNode("/eSocial/evtAdmissao/vinculo/matricula")
			cMatricula := oXML:XPathGetNodeValue("/eSocial/evtAdmissao/vinculo/matricula")
		endIf

		if oXML:XPathHasNode("/eSocial/evtAdmissao/trabalhador/cpfTrab")
			cCpf := oXML:XPathGetNodeValue("/eSocial/evtAdmissao/trabalhador/cpfTrab")
		endIf

		nTamMat := GetSx3Cache("C9V_MATRIC","X3_TAMANHO")	

		If Empty(cMatrC9V)
			cMatOrig := getMatFilOrig(cFilEnv,cCpf,"S2200")
		Else 
			cMatOrig := cMatrC9V
		EndIf 

		cChvOri  := PADR(cFilEnv,nTamFil)  + PADR(cCpf,nTamCpf) + PADR(cMatOrig,nTamMat) + "S22001"
		cChvDest := PADR(cFilTran,nTamFil) + PADR(cCpf,nTamCpf) + PADR(cMatricula,nTamMat) + "S22001"

	else 
		
		if oXML:XPathHasNode("/eSocial/evtTSVInicio/trabalhador/cpfTrab")
			cCpf := AllTrim(oXML:XPathGetNodeValue("/eSocial/evtTSVInicio/trabalhador/cpfTrab"))
		endIf

		if oXML:XPathHasNode("/eSocial/evtTSVInicio/infoTSVInicio/matricula")
			cMatricula := AllTrim(oXML:XPathGetNodeValue("/eSocial/evtTSVInicio/infoTSVInicio/matricula"))
		endIf 

		if oXML:XPathHasNode("/eSocial/evtTSVInicio/infoTSVInicio/codCateg")
			cCodCateg := Alltrim(oXML:XPathGetNodeValue("/eSocial/evtTSVInicio/infoTSVInicio/codCateg"))
			cIdCateg  := FGetIdInt("codCateg","",cCodCateg,,,,@cInconMsg) 
		endIf 

		if oXML:XPathHasNode("/eSocial/evtTSVInicio/infoTSVInicio/dtInicio")
			cDtInicio := StrTran(AllTrim(oXML:XPathGetNodeValue("/eSocial/evtTSVInicio/infoTSVInicio/dtInicio")),"-",'')
		endIf 

		if TafColumnPos("C9V_MATTSV")
			nTamMat := GetSx3Cache("C9V_MATTSV","X3_TAMANHO")
		endIf 
		nTamCateg := GetSx3Cache("C9V_CATCI","X3_TAMANHO")

		if Empty(cMatricula) .And. !__lLaySimplif

			cChvOri  := PADR(cFilEnv,nTamFil)  + PADR(cCpf,nTamCpf) + PADR(cIdCateg,nTamCateg) + cDtInicio 
			cChvDest := PADR(cFilTran,nTamFil)  + PADR(cCpf,nTamCpf) + PADR(cIdCateg,nTamCateg) + cDtInicio 
		elseif nTamMat > 0 

			If Empty(cMatrC9V)
				cMatOrig := getMatFilOrig(cFilEnv,cCpf,"S2300")
			Else 
				cMatOrig := cMatrC9V
			EndIf 

			cChvOri  := PADR(cFilEnv,nTamFil)   + PADR(cCpf,nTamCpf) + PADR(cMatOrig,nTamMat) + PADR(cIdCateg,nTamCateg) + cDtInicio 
			cChvDest := PADR(cFilTran,nTamFil)  + PADR(cCpf,nTamCpf) + PADR(cMatricula,nTamMat) + PADR(cIdCateg,nTamCateg) + cDtInicio 
		else 
			oTransf:setErrorTransfer(.T.,"000009","O Ambiente est� configurado para simplifica��o por�m n�o possui o campo C9V_MATTSV para a filial: " + cFilEnv)
			return oTransf
		endIf 
	endIf 

	dbSelectArea("C9V")
	C9V->(dbSetOrder(nIndChv)) 
	if C9V->(MsSeek(cChvOri)) .And. Empty(cInconMsg)

		if AllTrim(C9V->C9V_NOMEVE) != 'S'+ AllTrim(cLayout)
			oTransf:setErrorTransfer(.T.,"000009","O tipo de evento utilizado na transfer�ncia diverge do registro localizado no cadastro. Chave: " + cChvOri)
			return oTransf
		endIf 

		oTransf:setReceipt(AllTrim(C9V->C9V_PROTUL))
		oTransf:setStatus(C9V->C9V_STATUS)
		oTransf:setTransferGroup(lTransfGrp)
		oTransf:setSameBaseCNPJ(lMesmaBase)
		oTransf:setOriginKey(cChvOri)
		oTransf:setDestinyKey(cChvDest)
		oTransf:setIndKey(nIndChv)
		oTransf:setOrigGroup(cEmpEnv)
		oTransf:setDestGroup(cGrpTran)
		oTransf:setOrigBranch(cFilEnv)
		oTransf:setDestBranch(cFilTran)
	else 

		oTransf:setErrorTransfer(.T.,"000009")
		if Empty(cInconMsg) 
			oTransf:setErrorDescription("Trabalhador n�o localizado na filial de Origem: " + cFilEnv)
		else
			oTransf:setErrorDescription(cInconMsg)	
		endIf 
	endIf 

return oTransf

//--------------------------------------------------------------------
/*/{Protheus.doc} getMatFilOrig
Retorna a Matricula do �ltimo v�nculo correspondente ao trabalhador
e tipo de evento

@Param cFil - Filial de Pesquisa
@Param cCpf - CPF do trabalhador
@Param cNomeEvt - Nome do Evento 
grupos (grupo de destino)

@Return Nil 

@Author Evandro dos Santos Oliveira
@Since 20/04/2021
@Version 1.0
/*/
//---------------------------------------------------------------------
static function getMatFilOrig(cFil as character,cCpf as character,cNomeEvt as character)

	local cMatricula as character
	local cSql 		 as character

	cMatricula := ""
	cSql	   := ""

	cSql := " SELECT C9V_MATRIC MAT2200, C9V_MATTSV MAT2300, R_E_C_N_O_ RECNO "
	cSql += " FROM " + RetSqlName("C9V")
	cSql += " WHERE C9V_FILIAL = '" + cFil  + "'" 
	cSql += " AND C9V_CPF = '" + cCpf + "'" 
	cSql += " AND C9V_NOMEVE = '" + cNomeEvt + "'" 
	cSql += " AND C9V_ATIVO = '1' "
	cSql += " AND D_E_L_E_T_ = ' ' " 
	cSql += " ORDER BY R_E_C_N_O_ DESC "
	
	TCQuery cSql New Alias 'rsMatC9V'

	if cNomeEvt == "S2200"
		cMatricula := rsMatC9V->MAT2200
	else 
		cMatricula := rsMatC9V->MAT2300
	endIf 

	rsMatC9V->(dbCloseArea())

return cMatricula

//--------------------------------------------------------------------
/*/{Protheus.doc} gravaRastroTransf
Realiza a grava��o dos dados de rastro na filial de origem; No caso de
uma transfer�ncia de grupo � relizado tbm a ativa��o do registro do
grupo/filial de destino. 

@Param oTransf - Objeto com os dados de Transfer�ncia
@Param nRecNoDestino - Recno do Registro Criado em uma transfer�ncia entre
grupos (grupo de destino)

@Return Nil 

@Author Evandro dos Santos Oliveira
@Since 20/04/2021
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function gravaRastroTransf(oTransf,nRecNoDestino)

	Local cSql := ""

	Default nRecNoC9V := 0

	C9V->(dbSetOrder(oTransf:getIndKey()))
	If C9V->(MsSeek(oTransf:getOriginKey()))
		RecLock("C9V",.F.)
		C9V->C9V_IDTRAN := oTransf:getDestinyKey()
		C9V->C9V_DTTRAN := Date()
		C9V->(MsUnlock())

		If oTransf:isTransferGroup()
			//Foi criado um registro no grupo de destino com o campo de ativo igual a 0, desta forma se acontecer algum problema
			//na transa��o da thread principal o registro criado na thread do grupo de destino ficar� inv�lido

			/* Op��o para acesso em outro grupo de Empresa
			EmpOpenFile("C9VA","C9V",oTransf:getIndKey(),.T.,oTransf:getDestGroup(), @cModoC9V )
			C9VA->(dbGoTo(nRecNoDestino))

			RecLock('C9VA',.F.)
			C9VA->C9V_ATIVO = '1' 
			C9VA->(MsUnlock())
			EmpOpenFile("C9VA","C9V",oTransf:getIndKey(),.F.,oTransf:getDestGroup(), @cModoC9V )
			*/

			If nRecNoDestino > 0
				cSql := " UPDATE C9V" + oTransf:getDestGroup() + '0'
				cSql += " SET C9V_ATIVO = '1' "
				cSql += " WHERE R_E_C_N_O_ = " + cValToChar(nRecNoDestino)
			Else 
				oTransf:setErrorTransfer(.T.,"000009","N�o foi poss�vel ativar o registro transferido para o grupo " + oTransf:getDestGroup() + ". RecNo n�o retornado.")
			EndIf 
			
			If TCSQLExec(cSql) < 0
        		oTransf:setErrorTransfer(.T.,"000009","N�o foi poss�vel ativar o registro transferido para o grupo " + oTransf:getDestGroup() + ". " + TCSQLError()) 
        	EndIf 
			
		EndIf 
	Else
		oTransf:setErrorTransfer(.T.,"000009","Chave n�o encontrada para a grava��o do rastro da transfer�ncia.")
	EndIf 

Return Nil

/*/{Protheus.doc} TafAlteSocial
	Indica o campo que foi alterado e n�o segue o versionamento de retifica��o
	@type  Function
	@author Silas Gomes
	@since 06/03/2023
	/*/
Function TafAlteSocial( cCampo as character, aGrava as array )

	Local uVal1       as character
	Local uVal2       as character
	Local lRet        as logical
	Local nX          as numeric
	
	Default cCampo := ""
	Default aGrava := {}

	uVal1          := ""
	uVal2          := ""
	lRet           := .F.
	nX             := 0	

	For nX := 1 To Len( aGrava )

		uVal1          := &(M->aGrava[nX][1])
		uVal2          := aGrava[nX][2]

		If aGrava[nX][1] == cCampo .AND. uVal1 <> uVal2 
			lRet := .T.

		ElseIf uVal1 <> uVal2
			lRet := .F.
			Exit
			
		EndIf
		
	Next 

Return lRet
