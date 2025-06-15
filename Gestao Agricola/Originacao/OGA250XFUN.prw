#INCLUDE "OGA250XFUN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*============================================================
** {Protheus.doc} OGA250XFUN
Essa rotina tem por objetivo agrupar as fun��es do OGA250.
@since.:    17/05/2016
@Uso...:    SIGAAGR - Origina��o de Gr�os
===============================================================*/

/** {Protheus.doc} OGA250GERO
FUNCAO PARA GERAR ROMANEIO QUANDO ENTIDADE FOR TIPO PROPRIA

@param.:    Nil
@author:    Ana Laura Olegini
@since.:    17/05/2016
@Uso...:    SIGAAGR - Origina��o de Gr�os
@type function
*/
Function OGA250GERO( lGrava, cFilEnt )
	Local lContinua 	:= .T.
	Local aCposCab 		:= {}	//Vetor para receber dados do cabe�alho do romaneio
	Local aCposDet 		:= {}	//Vetor para receber dados dos itens do romaneio
	Local aAux			:= {}	//Auxiliar
	Local lAlgodao 		:= If(Posicione("SB5",1,fwxFilial("SB5")+NJJ->NJJ_CODPRO,"B5_TPCOMMO")== '2',.T.,.F.)
	Local aArea			:= GetArea()
	Local cQry 			:= ""
	Local cQryNJM 		:= ""
	Local cQryNJK 		:= ""
	Local cQryNJ0 		:= ""
	Local cAliasQry		:= NIL     // Retorna o pr�ximo Alias dispon�vel
	Local cAliasNJM		:= GetNextAlias()     // Retorna o pr�ximo Alias dispon�vel
	Local cAliasNJK   	:= GetNextAlias() 
	Local cAliasNJ0   	:= GetNextAlias() 
	Local cTipoNJJENT 	:= ""

	If cFilAnt != cFilEnt
		//================================================================================
		// CABECALHO DO ROMANEIO
		//================================================================================
		If NJJ->NJJ_TIPO == "2"	//2= REMESSA PARA DEPOSITO
			cTipoNJJENT :=  "3"	//3=ENTRADA PARA DEPOSITO
		ElseIf NJJ->NJJ_TIPO == "3"	//3=ENTRADA PARA DEPOSITO
			cTipoNJJENT :=  "2"	//2= REMESSA PARA DEPOSITO
		ElseIf NJJ->NJJ_TIPO == "4"	//4=VENDA
			cTipoNJJENT :=  "5" //5=COMPRA
		ElseIf NJJ->NJJ_TIPO == "5"	//5=COMPRA
			cTipoNJJENT :=  "4"	//4=VENDA
		ElseIf NJJ->NJJ_TIPO == "6"	//6=DEVOLUCAO DE DEPOSITO
			cTipoNJJENT :=  "7"	//7=DEVOLUCAO DE REMESSA
		ElseIf NJJ->NJJ_TIPO == "7"	//7=DEVOLUCAO DE REMESSA
			cTipoNJJENT :=  "6"	//6=DEVOLUCAO DE DEPOSITO
		ElseIf NJJ->NJJ_TIPO == "8"	//8=DEVOLUCAO DE COMPRA
			cTipoNJJENT :=  "9"	//9=DEVOLUCAO DE VENDA
		ElseIf NJJ->NJJ_TIPO == "9"	//9=DEVOLUCAO DE VENDA
			cTipoNJJENT :=  "8"	//8=DEVOLUCAO DE COMPRA
		EndIf

		aAdd( aCposCab, { 'NJJ_TIPO' , cTipoNJJENT	} )

		//================================================================================
		// ENTIDADE DO ROMANEIO
		//================================================================================
		cQryNJ0 := " SELECT NJ0_CODENT, NJ0_LOJENT "
		cQryNJ0 +=   " FROM "+ RetSqlName("NJ0") + " NJ0 "
		cQryNJ0 +=  " WHERE NJ0.D_E_L_E_T_ = '' "
		cQryNJ0 +=    " AND NJ0.NJ0_FILIAL = '" + fwxFilial("NJ0",cFilEnt) + "' "
		cQryNJ0 +=    " AND NJ0.NJ0_CODCRP = '" + NJJ->NJJ_FILIAL  + "'"
		cQryNJ0 := ChangeQuery(cQryNJ0)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryNJ0),(cAliasNJ0),.T.,.T.)

		dbSelectArea(cAliasNJ0)
		(cAliasNJ0)->(dbGoTop())
		If  ((cAliasNJ0))->(!Eof())
			aAdd( aCposCab, { 'NJJ_CODENT'	, (cAliasNJ0)->NJ0_CODENT })
			aAdd( aCposCab, { 'NJJ_LOJENT'	, (cAliasNJ0)->NJ0_LOJENT })

			//================================================================================
			// Valida��o para verificar se ja foi gerado o romaneio, para n�o entrar em loop,
			// gerando outro romaneio proprio sempre que confirma um romaneio proprio
			//================================================================================
			cAliasQry	:= GetNextAlias() 
			cQry := " SELECT NJJ_CODROM "
			cQry +=   " FROM "+ RetSqlName("NJJ") + " NJJ "
			cQry +=  " WHERE NJJ.D_E_L_E_T_ = '' "
			cQry +=    " AND NJJ.NJJ_FILIAL = '" + cFilEnt + "'"
			cQry +=    " AND NJJ.NJJ_TIPO = '" + cTipoNJJENT + "'"
			cQry +=    " AND NJJ.NJJ_DOCSER = '" + NJJ->NJJ_DOCSER  + "'"
			cQry +=    " AND NJJ.NJJ_DOCNUM = '" + NJJ->NJJ_DOCNUM  + "'"
			cQry +=    " AND NJJ.NJJ_CODENT = '" + (cAliasNJ0)->NJ0_CODENT  + "'"
			cQry +=    " AND NJJ.NJJ_LOJENT = '" + (cAliasNJ0)->NJ0_LOJENT  + "'"
			cQry := ChangeQuery(cQry)
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),(cAliasQry),.T.,.T.)
			dbSelectArea(cAliasQry)
			(cAliasQry)->(dbGoTop())
			If  ((cAliasQry))->(!Eof())
				(cAliasQry)->(dbCloseArea())
				(cAliasNJ0)->(dbCloseArea())
				Return .T.  // ja gerou/ja existe, sai da fun��o
			EndIF
			(cAliasQry)->(dbCloseArea())
		Else
			AutoGrLog( STR0003 )		//"A Entidade utilizada realiza a gera��o de Romaneio em outra Filial."
			AutoGrLog( STR0004 )		//"Favor verificar cadastros."
			AutoGrLog( "" )
			AutoGrLog( STR0015 + fwxFilial("NJJ") + STR0016 + fwxFilial("NJJ",cFilEnt) )	//"Favor verificar cadastros."
			(cAliasNJ0)->(dbCloseArea())
			MostraErro()
			Return !lGrava //se n�o grava mostra como alerta e prossegue, se grava ai trava n�o gerando o romaneio
		EndIF
		(cAliasNJ0)->(dbCloseArea())

		//================================================================================
		// DADOS DO ROMANEIO
		//================================================================================		
		aAdd( aCposCab, { 'NJJ_CODSAF'	, NJJ->NJJ_CODSAF })
		aAdd( aCposCab, { 'NJJ_CODPRO'	, NJJ->NJJ_CODPRO })
		aAdd( aCposCab, { 'NJJ_LOCAL'	, NJJ->NJJ_LOCAL  })
		If .NOT. lAlgodao
			aAdd( aCposCab, { 'NJJ_TABELA'	, NJJ->NJJ_TABELA })
		EndIf
		aAdd( aCposCab, { 'NJJ_PSSUBT'	, NJJ->NJJ_PSSUBT })
		If NJJ->NJJ_TPFORM == "2" .AND. (FWIsInCallStack("AGRA500") .OR. FWIsInCallStack("GFEA523"))
			aAdd( aCposCab, { 'NJJ_QTDFIS'	, NJJ->NJJ_QTDFIS })
			aAdd( aCposCab, { 'NJJ_VLRUNI'	, NJJ->NJJ_VLRUNI })
		EndIf
		aAdd( aCposCab, { 'NJJ_OBS'		, STR0001 + NJJ->NJJ_FILIAL + STR0002 + NJJ->NJJ_CODROM }) //"ORIGEM FILIAL:"#" ROMANEIO: "

		If FWIsInCallStack("AGRA500") .OR. FWIsInCallStack("GFEA523")
			aAdd( aCposCab, { 'NJJ_ORIGEM'	,  "AGRA500"})
			aAdd( aCposCab, { 'NJJ_TOETAP'	,  NJJ->NJJ_TOETAP})
		EndIf

		If !Empty(NJJ->NJJ_PLACA)
			cAliasQry	:= GetNextAlias() 
			cQry := " SELECT DA3.DA3_PLACA AS PLACAENT"
			cQry +=   " FROM "+ RetSqlName("DA3") + " DA3 "
			cQry +=  " WHERE DA3.D_E_L_E_T_ = '' "
			cQry +=    " AND DA3.DA3_FILIAL = '" + fwxFilial("DA3",cFilEnt) + "'"  //BUSCA NA OUTRA FILIAL
			cQry +=    " AND DA3.DA3_PLACA = '" + NJJ->NJJ_PLACA  + "' "
			cQry := ChangeQuery(cQry)
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),(cAliasQry),.T.,.T.)

			dbSelectArea(cAliasQry)
			(cAliasQry)->(dbGoTop())
			If  ((cAliasQry))->(!Eof()) .AND. !EMPTY( (cAliasQry)->PLACAENT )
				aAdd( aCposCab, { 'NJJ_PLACA'	, (cAliasQry)->PLACAENT })
			EndIF
			(cAliasQry)->(dbCloseArea())
		EndIf

		If !Empty(NJJ->NJJ_CODMOT) .and. fwxFilial("DA4") != FWxFilial("DA4",cFilEnt)
			cAliasQry	:= GetNextAlias() 
			cQry := " SELECT DA4X.DA4_COD AS CODMOTENT " //Busca codigo do motorista cadastrado na filial da variavel cFilEnt
			cQry +=   " FROM "+ RetSqlName("DA4") + " DA4 "
			cQry +=   " LEFT OUTER JOIN "+ RetSqlName("DA4") + " DA4X ON DA4X.D_E_L_E_T_ = '' AND DA4X.DA4_FILIAL = '"+FWxFilial("DA4",cFilEnt)+"' "
			cQry +=   " AND ( (DA4X.DA4_CGC = DA4.DA4_CGC AND DA4.DA4_CGC != '') OR (DA4X.DA4_NUMCNH = DA4.DA4_NUMCNH AND DA4.DA4_NUMCNH != '') OR (DA4X.DA4_REGCNH = DA4.DA4_REGCNH AND DA4.DA4_REGCNH != '' ) ) "
			cQry +=  " WHERE DA4.D_E_L_E_T_ = '' "
			cQry +=    " AND DA4.DA4_FILIAL = '" + fwxFilial("DA4") + "' "  
			cQry +=    " AND DA4.DA4_COD = '" + NJJ->NJJ_CODMOT  + "' "
			cQry := ChangeQuery(cQry)
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),(cAliasQry),.T.,.T.)

			dbSelectArea(cAliasQry)
			(cAliasQry)->(dbGoTop())
			If  ((cAliasQry))->(!Eof()) .and. !Empty((cAliasQry)->CODMOTENT)
				aAdd( aCposCab, { 'NJJ_CODMOT'	, (cAliasQry)->CODMOTENT })
			EndIF
			(cAliasQry)->(dbCloseArea())
		Else
			aAdd( aCposCab, { 'NJJ_CODMOT'	, NJJ->NJJ_CODMOT })
		EndIf

		If !Empty(NJJ->NJJ_CODTRA) .and. fwxFilial("SA4") != FWxFilial("SA4",cFilEnt)
			cAliasQry	:= GetNextAlias() 
			cQry := " SELECT SA4X.A4_COD AS CODTRAENT " //Busca codigo da transportadora cadastrada na filial da variavel cFilEnt
			cQry +=   " FROM "+ RetSqlName("SA4") + " SA4 "
			cQry +=   " LEFT OUTER JOIN "+ RetSqlName("SA4") + " SA4X ON SA4X.D_E_L_E_T_ = '' AND SA4X.A4_FILIAL = '"+FWxFilial("SA4",cFilEnt)+"'  "
			cQry +=   " AND ( (SA4X.A4_COD = SA4.A4_COD AND SA4X.A4_CGC = SA4.A4_CGC) OR (SA4X.A4_COD != SA4.A4_COD AND SA4.A4_CGC != '' AND SA4X.A4_CGC = SA4.A4_CGC  ) ) "
			cQry +=  " WHERE SA4.D_E_L_E_T_ = '' "
			cQry +=    " AND SA4.A4_FILIAL = '" + fwxFilial("SA4") + "' "  
			cQry +=    " AND SA4.A4_COD = '" + NJJ->NJJ_CODTRA  + "' "
			cQry := ChangeQuery(cQry)
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),(cAliasQry),.T.,.T.)

			dbSelectArea(cAliasQry)
			(cAliasQry)->(dbGoTop())
			If  ((cAliasQry))->(!Eof()) .and. !Empty((cAliasQry)->CODTRAENT)
				aAdd( aCposCab, { 'NJJ_CODTRA'	, (cAliasQry)->CODTRAENT })
			EndIF
			(cAliasQry)->(dbCloseArea())
		Else
			aAdd( aCposCab, { 'NJJ_CODTRA'	, NJJ->NJJ_CODTRA })
		EndIf
		
		If NJJ->NJJ_TPFORM == "1" .AND. !EMPTY(NJJ->NJJ_DOCNUM) .AND. !EMPTY(NJJ->NJJ_DOCSER)
			aAdd( aCposCab, { 'NJJ_TPFORM'	, "2" }) 
			aAdd( aCposCab, { 'NJJ_DOCNUM'	, NJJ->NJJ_DOCNUM }) 
			aAdd( aCposCab, { 'NJJ_DOCSER'	, NJJ->NJJ_DOCSER }) 
			aAdd( aCposCab, { 'NJJ_DOCEMI'	, NJJ->NJJ_DOCEMI }) 
			aAdd( aCposCab, { 'NJJ_DOCESP'	, NJJ->NJJ_DOCESP }) 
			aAdd( aCposCab, { 'NJJ_QTDFIS'	, NJJ->NJJ_QTDFIS })
			aAdd( aCposCab, { 'NJJ_VLRUNI'	, NJJ->NJJ_VLRUNI })
		ENDIF

		If !Empty(NJJ->NJJ_NFPSER)
			aAdd( aCposCab, { 'NJJ_NFPSER' 	, NJJ->NJJ_NFPSER })	//Serie da NF do Produtor
		EndIf
		If !Empty(NJJ->NJJ_NFPNUM)
			aAdd( aCposCab, { 'NJJ_NFPNUM'	, NJJ->NJJ_NFPNUM })	//Numero da NF do Produtor
		EndIf


		//================================================================================
		// ITENS DO ROMANEIO
		//================================================================================
		cQryNJM := " SELECT * "
		cQryNJM +=   " FROM "+ RetSqlName("NJM") + " NJM "
		cQryNJM +=  " WHERE NJM.D_E_L_E_T_ = '' "
		cQryNJM +=    " AND NJM.NJM_FILIAL = '" + NJJ->NJJ_FILIAL + "'"
		cQryNJM +=    " AND NJM.NJM_CODROM = '" + NJJ->NJJ_CODROM  + "'"
		cQryNJM +=    " AND NJM.NJM_CODENT = '" + NJJ->NJJ_CODENT  + "'"
		cQryNJM +=    " AND NJM.NJM_LOJENT = '" + NJJ->NJJ_LOJENT  + "'"
		cQryNJM := ChangeQuery(cQryNJM)
		//-- VERIFICA SE EXISTE - SE SIM APAGA TABELA TEMP
		If Select(cAliasNJM) <> 0
			(cAliasNJM)->(dbCloseArea())
		EndIf
		//-- DEFINE UM ARQUIVO DE DADOS COMO UMA AREA DE TRABALHO DISPONIVEL NA APLICACAO
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryNJM),(cAliasNJM),.T.,.T.)

		dbSelectArea(cAliasNJM)
		(cAliasNJM)->(dbGoTop())
		While ((cAliasNJM))->(!Eof())
			aAdd( aAux, { 'NJM_ITEROM' 	, (cAliasNJM)->NJM_ITEROM } )
			aAdd( aAux, { 'NJM_CODSAF'	, (cAliasNJM)->NJM_CODSAF } )
			aAdd( aAux, { 'NJM_CODPRO'	, (cAliasNJM)->NJM_CODPRO } )
			aAdd( aAux, { 'NJM_LOCAL'	, (cAliasNJM)->NJM_LOCAL  } )
			aAdd( aAux, { 'NJM_QTDFCO'	, (cAliasNJM)->NJM_QTDFCO } )
			aAdd( aAux, { 'NJM_PERDIV'	, (cAliasNJM)->NJM_PERDIV } )
			(cAliasNJM)->( dbSkip() )
		EndDo

		aAdd( aCposDet, aAux )

		//================================================================================
		// CLASSIFICACAO DO ROMANEIO
		//================================================================================
		/*  //COMENTADO POIS ROMANEIO SEM PESAGEM A QTD FISICA E FISCAL S�O AS MESMAS ASSIM AO GERAR UM ROMANEIO DE ENTRADA N�O FAZ SENTIDO APLICAR DESCONTO NOVAMENTE
		cQryNJK := " SELECT * "
		cQryNJK +=   " FROM "+ RetSqlName("NJK") + " NJK "
		cQryNJK +=  " WHERE NJK.D_E_L_E_T_ = '' "
		cQryNJK +=    " AND NJK.NJK_FILIAL = '" + NJJ->NJJ_FILIAL + "'"
		cQryNJK +=    " AND NJK.NJK_CODROM = '" + NJJ->NJJ_CODROM  + "'"
		cQryNJK := ChangeQuery(cQryNJK)
		//-- DEFINE UM ARQUIVO DE DADOS COMO UMA AREA DE TRABALHO DISPONIVEL NA APLICACAO
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryNJK),(cAliasNJK),.T.,.T.)
		
		aAux:= {}
		dbSelectArea(cAliasNJK)
		(cAliasNJK)->(dbGoTop())
		While ((cAliasNJK))->(!Eof())
			aAdd( aAux, { (cAliasNJK)->NJK_CODDES 	, (cAliasNJK)->NJK_PERDES   } )
			(cAliasNJK)->( dbSkip() )
		EndDo
		(cAliasNJK)->( DbCloseArea())
		*/
		//================================================================================
		If !OGA250EXRO( 'NJJ', 'NJM' , 'NJK' , aCposCab, aCposDet, aAux, lGrava, cFilEnt )
			lContinua := .F.
		EndIf
		
	EndIf

	RestArea(aArea)

Return(lContinua)

/** {Protheus.doc} Import
Importa��o dos dados - Cria um novo romaneio
@param: 	Nil
@return:	Nil
@author: 	Emerson Coelho
@since: 	17/05/2016
@Uso: 		OGX155 
*/ 
Static Function OGA250EXRO( cMaster, cDetail, cDetail2, aCpoMaster, aCpoDetail, aNJKDetail, lGrava, cFilEnt )
	Local oModel, oAux, oStruct
	Local nI 		:= 0
	Local nJ        := 0
	Local nX        := 0
	Local nPos 		:= 0
	Local nItErro 	:= 0
	Local aAux 		:= {}
	Local lContinua	:= .T.
	Local lAux 		:= .T.
	Local cFunName	:= FunName()
	Local aAreaAtu := GetArea()
	Local aAreaNJJ := NJJ->(GetArea())

	Local cFilOri	:= cFilAnt	//--SALVA A FILIAL LOGADA ANTES DE REALIZAR A TROCA DA FILIAL DA ENTIDADE

	//--ALTERA A FILIAL CORRENTE PARA A FILIAL DA ENTIDADE
	//================================
	cFilAnt := cFilEnt
	//================================

	dbSelectArea( cDetail )
	dbSetOrder( 1 )
	dbSelectArea( cMaster )
	dbSetOrder( 1 )

	// Aqui ocorre o inst�nciamento do modelo de dados (Model)
	// Neste exemplo instanciamos o modelo de dados do fonte COMP022_MVC
	// que � a rotina de manuten��o de musicas
	SetFunName('OGA251')  // Para o sistema Entender que � um romaneio sem Pesagem
	If FWIsInCallStack("AGRA500")
		oModel	:= FWLoadModel( 'AGRA500' )
	Else
		oModel := FWLoadModel( 'OGA250' )
	EndIf
	// Temos que definir qual a opera��o deseja: 3 � Inclus�o / 4 � Altera��o / 5 - Exclus�o
	oModel:SetOperation( 3 )

	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	oModel:Activate()

	// Instanciamos apenas a parte do modelo referente aos dados de cabe�alho
	oAux   := IIF(FWIsInCallStack("AGRA500"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" )) //Protecao para usar funcao via AGRA500
	cModel := IIF(FWIsInCallStack("AGRA500"), "AGRA500_NJJ", "NJJUNICO") //Protecao para usar funcao via AGRA500

	// Obtemos a estrutura de dados do cabe�alho
	oStruct := oAux:GetStruct()
	aAux := oStruct:GetFields()
	If lContinua
		For nI := 1 To Len( aCpoMaster )
			// Verifica se os campos passados existem na estrutura do cabe�alho
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoMaster[nI][1] ) } ) ) > 0
				// � feita a atribui��o do dado aos campo do Model do cabe�alho
				If !( lAux := oModel:SetValue( cModel, aCpoMaster[nI][1],aCpoMaster[nI][2] ) )
					// Caso a atribui��o n�o possa ser feita, por algum motivo (valida��o, por exemplo)
					// o m�todo SetValue retorna .F.
					lContinua := .F.
					Exit
				EndIf
			EndIf
		Next
	EndIf

	If lContinua
		// Instanciamos apenas a parte do modelo referente aos dados do item
		oAux   := IIF(FWIsInCallStack("AGRA500") , oModel:GetModel( "AGRA500_NJM" ), oModel:GetModel( "NJMUNICO" )) //Protecao para usar funcao via AGRA500
		cModel := IIF(FWIsInCallStack("AGRA500") , "AGRA500_NJM", "NJMUNICO") //Protecao para usar funcao via AGRA500
	
		// Obtemos a estrutura de dados do item
		oStruct := oAux:GetStruct()
		aAux := oStruct:GetFields()

		For nI := 1 To Len( aCpoDetail )
			// Inclu�mos uma linha nova
			// ATEN��O: O itens s�o criados em uma estrutura de grid (FORMGRID), portanto j� � criada uma primeira linha
			//branco automaticamente, desta forma come�amos a inserir novas linhas a partir da 2� vez
			If nI > 1
				// Inclu�mos uma nova linha de item
				If ( nItErro := oAux:AddLine() ) <> nI
					// Se por algum motivo o m�todo AddLine() n�o consegue incluir a linha, // ele retorna a quantidade de linhas j� // existem no grid. Se conseguir retorna a quantidade mais 1
					lContinua := .F.
					Exit
				EndIf
			EndIf
			For nJ := 1 To Len( aCpoDetail[nI] )
				// Verifica se os campos passados existem na estrutura de item
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0
					If !( lAux := oModel:SetValue( cModel, aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )
						// Caso a atribui��o n�o possa ser feita, por algum motivo (valida��o, por exemplo)
						// o m�todo SetValue retorna .F.
						lContinua := .F.
						nItErro := nI
						Exit
					EndIf
				EndIf
			Next
			If !lContinua
				Exit
			EndIf
		Next
		/**Classifica��o*************************************************************************************/
		oAux   := oModel:GetModel( "NJKUNICO" )
		cModel :=  "NJKUNICO"

		For nI := 1 To Len( aNJKDetail )
	
				For nX := 1 To  oAux:GetQTDLine() 
					oAux:GoLine(nX)
					If oAux:GetValue("NJK_CODDES") == aNJKDetail[nI][1]

						If !( lAux := oAux:SetValue("NJK_PERDES", aNJKDetail[nI][2] ) )
							lContinua := .F.
							nItErro := nI
							Exit
						EndIf

					Endif
				Next	
			
			If !lContinua
				Exit
			EndIf
		Next
	EndIf
	/************************************************************************************/

	If lContinua
		// Faz-se a valida��o dos dados, note que diferentemente das tradicionais "rotinas autom�ticas"
		// neste momento os dados n�o s�o gravados, s�o somente validados.
		If ( lContinua := oModel:VldData() )
			// Se o dados foram validados faz-se a grava��o efetiva dos
			// dados (commit)
			If lGrava
				oModel:CommitData()
			EndIf
		EndIf
	EndIf
	If !lContinua
		// Se os dados n�o foram validados obtemos a descri��o do erro para gerar
		// LOG ou mensagem de aviso
		aErro := oModel:GetErrorMessage()
		// A estrutura do vetor com erro �:
		// [1] identificador (ID) do formul�rio de origem
		// [2] identificador (ID) do campo de origem
		// [3] identificador (ID) do formul�rio de erro
		// [4] identificador (ID) do campo de erro
		// [5] identificador (ID) do erro
		// [6] mensagem do erro
		// [7] mensagem da solu��o
		// [8] Valor atribu�do
		// [9] Valor anterior
		AutoGrLog( STR0003 )		//"A Entidade utilizada realiza a gera��o de Romaneio em outra Filial."
		AutoGrLog( STR0004 )		//"Favor verificar cadastros."
		AutoGrLog( "" )
		AutoGrLog( STR0005 + ' [' + AllToChar( aErro[1] ) + ']' )		//"Id do formul�rio de origem: "
		AutoGrLog( STR0006 + ' [' + AllToChar( aErro[2] ) + ']' )		//"Id do campo de origem.....: "
		AutoGrLog( STR0007 + ' [' + AllToChar( aErro[3] ) + ']' )		//"Id do formul�rio de erro..: "
		AutoGrLog( STR0008 + ' [' + AllToChar( aErro[4] ) + ']' )		//"Id do campo de erro.......: "
		AutoGrLog( STR0009 + ' [' + AllToChar( aErro[5] ) + ']' )		//"Id do erro................: "
		AutoGrLog( STR0010 + ' [' + AllToChar( aErro[6] ) + ']' )		//"Mensagem do erro..........: "
		AutoGrLog( STR0011 + ' [' + AllToChar( aErro[7] ) + ']' )		//"Mensagem da solu��o.......: "
		AutoGrLog( STR0012 + ' [' + AllToChar( aErro[8] ) + ']' )		//"Valor atribu�do...........: "
		AutoGrLog( STR0013 + ' [' + AllToChar( aErro[9] ) + ']' )		//"Valor anterior............: "
		If nItErro > 0
			AutoGrLog( STR0014 + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' )	//"Erro no Item..............: "
		EndIf
		MostraErro()
	EndIf
	// Desativamos o Model
	oModel:DeActivate()

	SetFunName(cFunName) //Retorna para o programa de origem

	//--RETORNA COM A FILIAL DE ORIGEM
	//================================
	cFilAnt := cFilOri
	//================================
	RestArea(aAreaNJJ)
	RestArea(aAreaAtu)
Return lContinua

/*/{Protheus.doc} OG250XENTFIL
//TODO Pela Filial e a op��o da tabela de consulta, retorna um array com o codigo e loja da entidade e o codigo e loja do cliente/fornecedor
@author claudineia.reinert
@since 21/09/2018
@version 1.0
@return ${cCodEnt,cLojEnt,cCliFor,cLoja}, ${Codigo a entidade, loja da entidade, codigo do cliente/fornecedor, loja do cliente/fornecedor}
@param cFilRom, characters, filial do romaneio
@param nOpc, numeric, numero da op��o para busca na tabela de cliente ou fornecedor, sendo 1=SA1(cliente), 2=SA2(Fornecedor)
@type function
/*/
Function OG250XENTFIL(cFilRom, nOpc)
	Local aAreaAtu	:= GetArea()
	Local aRet 		:= {}
	Local cCGC 		:= ""
	Local cCliFor 	:= ""
	Local cLoja 	:= ""
	Local cCodEnt 	:= ""
	Local cLojEnt 	:= ""
	Local nOrderNJ0 := IIF(nOpc = 1, 3, 4)

	dbSelectArea("SM0")
	SM0->( dbSetOrder(1) )
	SM0->( dbGoTop() )
	While !SM0->( Eof() )
		If AllTrim(SM0->M0_CODFIL) == AllTrim(cFilRom)
			cCGC   := SM0->M0_CGC
			Exit
		EndIf
		SM0->( dbSkip() )
	EndDo

	If !Empty(cCGC)
		If nOpc = 1
			dbSelectArea("SA1")
			SA1->(dbSetOrder(3))
			If SA1->(dbSeek(xFilial("SA1",SM0->M0_CODFIL)+cCGC))
				cCliFor 	:= SA1->A1_COD
				cLoja 		:= SA1->A1_LOJA
			EndIf
		ElseIf nOpc = 2
			SA1->(dbSelectArea("SA2"))
			SA1->(dbSetOrder(3))
			If SA1->(dbSeek(xFilial("SA2",SM0->M0_CODFIL)+cCGC))
				cCliFor 	:= SA2->A2_COD
				cLoja 		:= SA2->A2_LOJA
			EndIf
		EndIf
	EndIf

	DbSelectArea("NJ0")
	NJ0->( dbSetOrder( nOrderNJ0 ) )
	If NJ0->( dbSeek( xFilial( "NJ0" ) + cCliFor + cLoja ) )
		cCodEnt := NJ0->NJ0_CODENT
		cLojEnt := NJ0->NJ0_LOJENT
	EndIf

	aRet := {cCodEnt, cLojEnt, cCliFor, cLoja}

	RestArea(aAreaAtu)

Return aRet
