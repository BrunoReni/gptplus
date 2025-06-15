#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA461FIN.CH"

//-------------------------------------------------------------------------
/*/	{Protheus.doc} MATA461FIN
Tabela intermediaria FKW Natureza de Rendimentos - Projeto REINF - FAT/CRM

@param nOpc		3-Inclusao/5-Exclusao
@param aNatRend Dados da Natureza de Rendimento do item do Pedido de Venda
@param aRecSE1	Dados dos titulos a receber gerados

@author juan.bartha
@since 30/12/2022
@version 12
@type function
/*/
//-------------------------------------------------------------------------

Function A461FKW(nOpc,aNatRend,aRecSE1)

	Local aArea		:= GetArea()
	Local aDados	:= {}
	Local cChaveTit	:= ""
	Local nI		:= 0
	Local nX		:= 0
	Local nPerc		:= 0
	Local nValor	:= 0
	Local nBase		:= 0
	Local nPercSusp	:= 0
	Local nVlrSusp	:= 0
	Local nBaseSusp	:= 0
	Local cNumProc	:= 0
	Local cTpProc	:= 0
	Local cIndSusp	:= 0

	Local lRatIRRF	:= IIF(nOpc == 3, aRecSE1[1] > aRecSE1[2][1][7], .F.)
	Local nPercRat 	:= IIF(nOpc == 3,(aNatRend[1]/aRecSE1[1]), 0)
	Local cFilSE1	:= xFilial("SE1")
	Local cFilFKW 	:= xFilial("FKW")

	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))

	DbSelectArea("SD2")
	SD2->(DbSetOrder(1))

	If nOpc == 3 //Inclusao
		
		//Gera dados para a tabela intermediaria a partir dos titulos (SE1) x Natureza de rendimentos
		For nI := 1 To Len(aRecSE1[2])
			
			cChaveTit := FINGRVFK7("SE1", cFilSE1+"|"+aRecSE1[2][nI][1]+"|"+aRecSE1[2][nI][2]+"|"+aRecSE1[2][nI][3]+"|"+aRecSE1[2][nI][4]+"|"+aRecSE1[2][nI][5]+"|"+aRecSE1[2][nI][6])
			
			For nX := 1 To Len(aNatRend[2])

				If aNatRend[2][nX][2] > 0

					If lRatIRRF
						nPerc	:= (aNatRend[2][nX][2] / aNatRend[1]) * 100
						nValor	:= (aRecSE1[2][nI][7] * nPercRat) * (nPerc/100)
						nBase	:= (aRecSE1[2][nI][8] * nPercRat) * (nPerc/100)

						If !Empty(aNatRend[3])
							nPercSusp 	:= (aNatRend[4][nX][2] / aNatRend[3]) * 100
							nVlrSusp	:= (nValor * aNatRend[4][nX][4])/100
							nBaseSusp	:= (nBase * aNatRend[4][nX][4])/100
							cNumProc	:= aNatRend[4][nX][5]
							cTpProc		:= aNatRend[4][nX][6]
							cIndSusp	:= aNatRend[4][nX][7]
						EndIf
					ElseIf aRecSE1[2][nI][7] > 0 //Valida se o titulo possui valor de IRRF para calculo
						nPerc	:= (aNatRend[2][nX][2] / aNatRend[1]) * 100
						nValor	:= aNatRend[2][nX][2]
						nBase	:= aNatRend[2][nX][3]

						If !Empty(aNatRend[3])
							nPercSusp 	:= (aNatRend[4][nX][2] / aNatRend[3]) * 100
							nVlrSusp	:= (nValor * aNatRend[4][nX][4])/100
							nBaseSusp	:= (nBase * aNatRend[4][nX][4])/100
							cNumProc	:= aNatRend[4][nX][5]
							cTpProc		:= aNatRend[4][nX][6]
							cIndSusp	:= aNatRend[4][nX][7]
						EndIf
					EndIf

					If aRecSE1[2][nI][7] > 0 //Valida se o titulo possui valor de IRRF para gravar na FKW
						If !Empty(aNatRend[3])
							aadd(aDados,{cFilFKW,cChaveTit,"IRF",aNatRend[2][nX][1],nPerc,nBase,nValor,nBaseSusp,nVlrSusp,cNumProc,cTpProc,cIndSusp,nPercSusp})
						Elseif Empty(aNatRend[3])
							aadd(aDados,{cFilFKW,cChaveTit,"IRF",aNatRend[2][nX][1],nPerc,nBase,nValor,0,0,"","","",0})
						Endif
					EndIf

				Endif

			Next nX

		Next nI

		If Len(aDados) > 0 .And. FindFunction("F070Grv") //gravacao na tabela intermediaria
			F070Grv(aDados,3,"2")
		Endif
			
	Elseif nOpc == 5 //Exclusao

		//Exclusão da tabela intermediaria a partir dos titulos (SE1)
		For nI := 1 To Len(aRecSE1)
			SE1->(DbGoTo(aRecSE1[nI]))
			
			If Empty(SE1->E1_TITPAI) //Somente Titulos da NF
				cChaveTit := FINGRVFK7("SE1", cFilSE1+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA)
				
				aadd(aDados,{cFilFKW,cChaveTit})
			Endif
		Next nI

		If Len(aDados) > 0 .And. FindFunction("F070Grv") //gravacao na tabela intermediaria
			F070Grv(aDados,5,"2")
		Endif
		
	Endif

	RestArea(aArea)

Return

//-------------------------------------------------------------------------------
/*/	{Protheus.doc} MATA461FIN

Tela Clientes x Processos Ref. (MVC) - Projeto REINF - FAT/CRM

Interface para informacao dos valores de IRRF para Naturezas de Rendimento
que possuem Suspensão Judicial amarrados ao cadastro do cliente - Projeto REINF

@param cAlias 	Sigla da tabela
@param nOpc		3-Inclusao/4-Alteracao/5-Exclusao
@param nReg 	Numero do recno do registro do cliente

@author juan.bartha
@since 03/01/2023
@version 12
@type function
/*/
//-------------------------------------------------------------------------------

Function CRMANatRen(cAlias, nReg, nOpc)

	Local aArea 	:= GetArea()
	Local oModel	:= Nil
	Local cMemory	:= IIF(M->A1_COD == Nil,"SA1->","M->")

	Default cAlias  := Alias()
	Default nReg	:= (cAlias)->(RecNo())
	Default nOpc	:= 4

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona a entidade                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( cAlias )
	MsGoto( nReg )

	oModel := FWLoadModel("MATA461FIN")
	oModel:SetOperation(nOpc)
	oModel:GetModel("AQZMASTER"):bLoad := {|| {xFilial("AQZ"),&(cMemory+"A1_COD"),&(cMemory+"A1_LOJA"),&(cMemory+"A1_NOME")}}
	oModel:Activate() 

	oView := FWLoadView("MATA461FIN")
	oView:SetModel(oModel)
	oView:SetOperation(nOpc) 
				
	oExecView := FWViewExec():New()
	oExecView:SetTitle(STR0001)//Processos
	oExecView:SetView(oView)
	oExecView:SetModal(.F.)
	oExecView:SetCloseOnOK({|| .T. })
	oExecView:SetOperation(nOpc)
	oExecView:OpenView(.T.)

	RestArea(aArea)
	aSize(aArea,0)


Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Cria o objeto comtendo a estrutura , relacionamentos das tabelas envolvidas 

@sample		ModelDef()

@author		Juan Bartha
@since		03/01/2023
@version	12              
/*/
//------------------------------------------------------------------------------

Static Function ModelDef()

	Local oModel 		:= Nil
	Local bAvCpoCab		:= {|cCampo| AllTrim(cCampo)+"|" $ "AQZ_FILIAL|AQZ_CLIENT|AQZ_LOJA|"}
	Local bAvCpoItm		:= {|cCampo| AllTrim(cCampo)+"|" $ "AQZ_NUMPRO|AQZ_TIPO|AQZ_PERIRF|AQZ_INDSUS|"}
	Local oStructCab 	:= FWFormStruct(1,"AQZ",bAvCpoCab)
	Local oStructItem 	:= FWFormStruct(1,"AQZ",bAvCpoItm)
	Local aGatilhAQZ	:= {}
	Local nX			:= 0

	oStructCab:AddField(STR0002		,; 	// [01] C Titulo do campo (Nome do Cliente)
						STR0002		,; 	// [02] C ToolTip do campo //"Tipo de Entidade"(Nome do Cliente)
						"A1_NOME" 	,; 	// [03] C identificador (ID) do Field
						"C" 		,; 	// [04] C Tipo do campo
						40 			,; 	// [05] N Tamanho do campo
						0 			,; 	// [06] N Decimal do campo
						Nil 		,; 	// [07] B Code-block de validação do campo
						Nil			,; 	// [08] B Code-block de validação When do campo
						Nil			,; 	// [09] A Lista de valores permitido do campo
						Nil 		,; 	// [10] L Indica se o campo tem preenchimento obrigatório
						Nil			,;  // [11] B Code-block de inicializacao do campo
						Nil 		,; 	// [12] L Indica se trata de um campo chave
						Nil			,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
						Nil )

	oModel := MPFormModel():New("MATA461FIN",/*bPreValidacao*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)
	
	//Criação de Gatilho
	aAdd(aGatilhAQZ, FWStruTrigger(	"AQZ_NUMPRO",;        							//Campo Origem
									"AQZ_TIPO",;          							//Campo Destino
									"GMat461Fin('AQZ_TIPO')",;    					//Regra de Preenchimento
									.F.,;                 							//Irá Posicionar?
									"",;               								//Alias de Posicionamento
									0,;                   							//Índice de Posicionamento
									'',;											//Chave de Posicionamento
									NIL,;                 							//Condição para execução do gatilho
									"001"))                							//Sequência do gatilho
	
	aAdd(aGatilhAQZ, FWStruTrigger(	"AQZ_NUMPRO",;        							//Campo Origem
									"AQZ_INDSUS",;          						//Campo Destino
									"GMat461Fin('AQZ_INDSUS') ",;    				//Regra de Preenchimento
									.F.,;                 							//Irá Posicionar?
									"",;               								//Alias de Posicionamento
									0,;                   							//Índice de Posicionamento
									'',;											//Chave de Posicionamento
									NIL,;                 							//Condição para execução do gatilho
									"002"))                							//Sequência do gatilho
	
    //Percorrendo os gatilhos e adicionando na Struct
    For nX := 1 To Len(aGatilhAQZ)
        oStructItem:AddTrigger(  aGatilhAQZ[nX][01],; //Campo Origem
                           		aGatilhAQZ[nX][02],; //Campo Destino
                            	aGatilhAQZ[nX][03],; //Bloco de código na validação da execução do gatilho
                            	aGatilhAQZ[nX][04])  //Bloco de código de execução do gatilho
    Next
	
	oModel:AddFields("AQZMASTER",/*cOwner*/,oStructCab,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	oModel:AddGrid("AQZCONTDET","AQZMASTER",oStructItem,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

	oModel:SetPrimaryKey({"AQZ_FILIAL","AQZ_CLIENT","AQZ_LOJA","AQZ_NUMPRO","AQZ_TIPO","AQZ_INDSUS"})

	oModel:GetModel("AQZCONTDET"):SetOptional( .T. )
	oModel:GetModel("AQZCONTDET"):SetUniqueLine({"AQZ_NUMPRO","AQZ_TIPO","AQZ_INDSUS"})
	oModel:GetModel("AQZCONTDET"):SetMaxLine(9999)

	oModel:SetRelation("AQZCONTDET",{ {"AQZ_FILIAL","AQZ_FILIAL"},{"AQZ_CLIENT","AQZ_CLIENT"},{"AQZ_LOJA","AQZ_LOJA"}},AQZ->( IndexKey(1)))

Return(oModel)


//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Monta o objeto que irá permitir a visualização da interfece grafica,
com base no Model

@sample		ViewDef()
@return	    oView - bojeto de visualizacao da interface grafica.

@author		Juan Bartha
@since		03/01/2023
@version	12             
/*/
//------------------------------------------------------------------------------

Static Function ViewDef()

	Local oView 		:= Nil
	Local oModel		:= FwLoadModel("MATA461FIN")
	Local bAvCpoCab		:= {|cCampo| AllTrim(cCampo)+"|" $ "AQZ_FILIAL|AQZ_CLIENT|AQZ_LOJA|"}
	Local bAvCpoItm		:= {|cCampo| AllTrim(cCampo)+"|" $ "AQZ_NUMPRO|AQZ_TIPO|AQZ_PERIRF|AQZ_INDSUS|"}
	Local oStructCab 	:= FWFormStruct(2,"AQZ",bAvCpoCab)
	Local oStructItem 	:= FWFormStruct(2,"AQZ",bAvCpoItm)

	oStructCab:AddField("A1_NOME" 	,;	// [01] C Nome do Campo
						"05" 		,; 	// [02] C Ordem
						STR0002		,; 	// [03] C Titulo do campo//"Entidade" (Nome do Cliente)
						STR0002		,; 	// [04] C Descrição do campo//"Tipo de Entidade" (Nome do Cliente)
						{} 	   		,; 	// [05] A Array com Help
						"C" 		,; 	// [06] C Tipo do campo
						"@!" 		,; 	// [07] C Picture
						Nil 		,; 	// [08] B Bloco de Picture Var
						Nil 		,; 	// [09] C Consulta F3
						.F. 		,;	// [10] L Indica se o campo é evitável
						Nil 		,; 	// [11] C Pasta do campo
						Nil 		,;	// [12] C Agrupamento do campo
						Nil 		,; 	// [13] A Lista de valores permitido do campo (Combo)
						Nil 		,;	// [14] N Tamanho Maximo da maior opção do combo
						Nil 		,;	// [15] C Inicializador de Browse
						Nil 		,;	// [16] L Indica se o campo é virtual
						Nil 		,;
						Nil			,;
						Nil			,;
						Nil			,;
						Nil			,;
						Nil) 

	// Alterando a propriedade dos campos, para nao ser editaveis
	oStructCab:SetProperty("AQZ_CLIENT",MVC_VIEW_CANCHANGE,	.F.	)
	oStructCab:SetProperty("AQZ_LOJA"  ,MVC_VIEW_CANCHANGE, .F. )
	oStructCab:SetProperty("A1_NOME"   ,MVC_VIEW_CANCHANGE, .F. )

	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField("VIEW_MST",oStructCab,"AQZMASTER")
	oView:AddGrid("VIEW_AQZ",oStructItem, "AQZCONTDET")

	oView:CreateHorizontalBox("VIEW_TOP",20)
	oView:SetOwnerView("VIEW_MST","VIEW_TOP")

	oView:CreateHorizontalBox("VIEW_DET",80)  
	oView:SetOwnerView("VIEW_AQZ","VIEW_DET")

Return(oView)

Function GMat461Fin(cCDomin) 

	Local cResult := ""

	If !Empty(M->AQZ_NUMPRO)
		If cCDomin == "AQZ_TIPO"
			cResult := CCF->CCF_TIPO
		ElseIf cCDomin == "AQZ_INDSUS"
			cResult := CCF->CCF_INDSUS
		EndIf
	EndIf

Return cResult
