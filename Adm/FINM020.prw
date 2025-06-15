#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH' 

STATIC aDeParaFK2	:= FINLisCpo('FK2')
STATIC aDeParaFK5	:= FINLisCpo('FK5')
STATIC aRecSE5		:= {}
STATIC nSaveSx8   	:= 0
STATIC __lTemFKY    As Logical
STATIC __lPccBx     As Logical
Static __nFpFK5		As Numeric
Static __nFpSE5		As Numeric

Function FINM020()

Return

/*/{Protheus.doc}ModelDef
Cria��o do Modelo de dados - Baixa a Pagar.
@author William Matos Gundim Junior
@since  14/03/2014
@version 12
/*/
Static Function ModelDef()
	Local oModel 	 As Object
	Local oCab		 As Object
	Local oStruFKA   As Object
	Local oStruFK2   As Object
	Local oStruFK3   As Object
	Local oStruFK4   As Object
	Local oStruFK5   As Object
	Local oStruFK6   As Object
	Local oStruFK8   As Object
	Local oStruFK9   As Object
	Local oStruFKY   As Object
	Local aRelacFKA  As Array
	Local aRelacFK2  As Array
	Local aRelacFK3  As Array
	Local aRelacFK4  As Array
	Local aRelacFK5  As Array
	Local aRelacFK6  As Array
	Local aRelacFK8  As Array
	Local aRelacFK9  As Array
	Local aRelacFKY  As Array
	Local cProc	     As Character
	Local aCamposFK5 As Array
	Local nX 		 As Numeric
	Local cChave	 As Character   

	oModel 	 	:= MPFormModel():New('FINM020' ,/*{|oModel| FINM020Pre(oModel)}*/,{|oModel| FINM020Pos(oModel)}, {|oModel| FINM020Grv(oModel)},/*bCancel*/ )
	oCab	 	:= FWFormModelStruct():New()
	oStruFKA   	:= FWFormStruct(1,'FKA') //
	oStruFK2   	:= FWFormStruct(1,'FK2') //
	oStruFK3   	:= FWFormStruct(1,'FK3') //
	oStruFK4   	:= FWFormStruct(1,'FK4') //
	oStruFK5   	:= FWFormStruct(1,'FK5') //
	oStruFK6   	:= FWFormStruct(1,'FK6') //
	oStruFK8   	:= FWFormStruct(1,'FK8') //
	oStruFK9   	:= FWFormStruct(1,'FK9') //
	oStruFKY   	:= FWFormStruct(1,'FKY') 
	aRelacFKA  	:= {}
	aRelacFK2  	:= {}
	aRelacFK3  	:= {}
	aRelacFK4  	:= {}
	aRelacFK5  	:= {}
	aRelacFK6  	:= {}
	aRelacFK8  	:= {}
	aRelacFK9  	:= {}
	aRelacFKY  	:= {}
	cProc	    := ""
	aCamposFK5 	:= FK5->(DbStruct())
	nX 		 	:= 0  
	cChave	 	:= SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)   


	If __lTemFKY == NIL
		__lTemFKY := AliasInDic("FKY")
	Endif

	If __lPccBx  == NIL
		__lPccBx:= SuperGetMv("MV_BX10925",.T.,"2") == "1"
	EndIf

	//Migra o registro de SE5 posicionado que ainda n�o foi migrado
	If SE5->E5_MOVFKS <> 'S' .AND. SE5->( !EOF() ) .and. !Empty(cChave)
		FINXSE5(SE5->(Recno()), 2)
	Endif

	nSaveSx8 := GetSX8Len()

	//Criado master falso para a alimenta��o dos detail.
	oCab:AddTable('MASTER',,'MASTER')

	FIN030Master(oCab)

	//Salva os dados na SE5.
	oStruFK6:AddField("FK6_GRVSE5","","FK6_GRVSE5","L",1,0,/*bValid*/,/*When*/,{.T.,.F.},.F.,/* */,/*Key*/,.F.,.T.,)

	For nX := 1 To Len(aCamposFK5)
		oStruFK5:SetProperty(aCamposFK5[nX][1], MODEL_FIELD_OBRIGAT, .F.)
	Next nX

	//Chama a cria��o do cProc
	cProc:= FINProcFKs(SE5->E5_IDORIG, "FK2", SE5->E5_SEQ)

	oCab:SetProperty( 'IDPROC', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "'" + cProc + "'" ) )
	oStruFK6:SetProperty( "FK6_GRVSE5", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, '.T.' ) )

	oStruFK2:SetProperty( 'FK2_IDFK2' , MODEL_FIELD_OBRIGAT, .F.)
	oStruFK2:SetProperty( 'FK2_NATURE', MODEL_FIELD_OBRIGAT, .F.)
	oStruFK5:SetProperty( 'FK5_NATURE', MODEL_FIELD_OBRIGAT, .F.)
	oStruFK3:SetProperty( "FK3_IDRET" , MODEL_FIELD_OBRIGAT, .F.)
	oStruFK4:SetProperty( "FK4_IDORIG", MODEL_FIELD_OBRIGAT, .F.)
	oStruFK3:SetProperty( "FK3_VALOR" , MODEL_FIELD_OBRIGAT, .F.)//Ret, a obrig., pois o calc IRPF, se n�o atinge o valor min ret o % � 0
	oStruFKA:SetProperty( 'FKA_IDFKA' , MODEL_FIELD_OBRIGAT, .F.)
	oStruFKA:SetProperty( 'FKA_IDPROC', MODEL_FIELD_OBRIGAT, .F.)
	oStruFK6:SetProperty( 'FK6_IDFK6' , MODEL_FIELD_OBRIGAT, .F.)
	oStruFK2:SetProperty( 'FK2_VALOR' , MODEL_FIELD_OBRIGAT, .F.)
	//Retira a valida��o dos campos abaixo.
	//Valida��o original: Positivo()
	//No entanto corre��o monet�ria pode ser negativa.
	oStruFK2:SetProperty("FK2_VALOR"  , MODEL_FIELD_VALID , {||.T.})
	oStruFK6:SetProperty("FK6_VALCAL" , MODEL_FIELD_VALID , {||.T.} )
	oStruFK6:SetProperty("FK6_VALMOV" , MODEL_FIELD_VALID , {||.T.} )

	//Cria os modelos relacionados.
	oModel:AddFields('MASTER', /*cOwner*/, oCab , , ,{|o|{}} )
	oModel:AddGrid('FKADETAIL','MASTER'	  ,oStruFKA) 
	oModel:AddGrid('FK5DETAIL','FKADETAIL',oStruFK5)
	oModel:AddGrid('FK2DETAIL','FKADETAIL',oStruFK2) 
	oModel:AddGrid('FK8DETAIL','FK5DETAIL',oStruFK8)
	oModel:AddGrid('FK9DETAIL','FK5DETAIL',oStruFK9)
	oModel:AddGrid('FK3DETAIL','FK2DETAIL',oStruFK3)
	oModel:AddGrid('FK4DETAIL','FK3DETAIL',oStruFK4)
	oModel:AddGrid('FK6DETAIL','FK2DETAIL',oStruFK6)

	If __lTemFKY
		oModel:AddGrid('FKYDETAIL','FK2DETAIL',oStruFKY)
	Endif

	//Preenchimento opcional. - FK2, FKA s�o obrigat�rias na fun��o de grava��o.
	oModel:GetModel( 'MASTER'):SetOnlyQuery(.T.)
	oModel:GetModel('FK2DETAIL'):SetOptional( .T. )
	oModel:GetModel('FKADETAIL'):SetOptional( .T. )
	oModel:GetModel('FK3DETAIL'):SetOptional( .T. )
	oModel:GetModel('FK4DETAIL'):SetOptional( .T. )
	oModel:GetModel('FK5DETAIL'):SetOptional( .T. )
	oModel:GetModel('FK6DETAIL'):SetOptional( .T. )
	oModel:GetModel('FK8DETAIL'):SetOptional( .T. )
	oModel:GetModel('FK9DETAIL'):SetOptional( .T. )

	If __lTemFKY
		oModel:GetModel('FKYDETAIL'):SetOptional( .T. )
	Endif

	oModel:SetPrimaryKey( {} )

	//Cria relacionamentos FKA->MASTER
	aAdd(aRelacFKA,{'FKA_FILIAL','xFilial("FKA")'})
	aAdd(aRelacFKA,{'FKA_IDPROC','IDPROC'}) 
	oModel:SetRelation('FKADETAIL', aRelacFKA , FKA->(IndexKey(2)))

	//Cria relacionamento FK2->FKA
	aAdd(aRelacFK2,{'FK2_FILIAL','xFilial("FK2")'})
	aAdd(aRelacFK2,{'FK2_IDFK2','FKA_IDORIG'})
	oModel:SetRelation('FK2DETAIL', aRelacFK2 , FK2->(IndexKey(1)))

	//Cria relacionamentos FK5->FKA.
	aAdd(aRelacFK5,{'FK5_FILIAL','xFilial("FK5")'})
	aAdd(aRelacFK5,{'FK5_IDMOV','FKA_IDORIG'})
	oModel:SetRelation( 'FK5DETAIL', aRelacFK5 , FK5->(IndexKey(1)))

	//Cria relacionamentos FK6->FKA. 
	aAdd(aRelacFK6,{'FK6_FILIAL','xFilial("FK6")'})
	aAdd(aRelacFK6,{'FK6_IDORIG','FKA_IDORIG'})
	oModel:SetRelation( 'FK6DETAIL', aRelacFK6 , FK6->(IndexKey(1)))

	//Cria relacionamentos FK3->FK2.
	aAdd(aRelacFK3,{'FK3_FILIAL','xFilial("FK3")'})
	aAdd(aRelacFK3,{'FK3_TABORI',"'FK2'"})
	aAdd(aRelacFK3,{'FK3_IDORIG','FKA_IDORIG'})
	oModel:SetRelation( 'FK3DETAIL', aRelacFK3 , FK3->(IndexKey(2)))

	//Cria relacionamentos FK4->FK3.
	aAdd(aRelacFK4,{'FK4_FILIAL','xFilial("FK4")'})
	aAdd(aRelacFK4,{'FK4_IDORIG','FKA_IDORIG'    })
	oModel:SetRelation( 'FK4DETAIL', aRelacFK4 , FK4->(IndexKey(1)))

	//Cria relacionamentos FK8->FK5.
	aAdd(aRelacFK8,{'FK8_FILIAL','xFilial("FK8")'})
	aAdd(aRelacFK8,{'FK8_IDMOV','FKA_IDORIG'})
	oModel:SetRelation( 'FK8DETAIL', aRelacFK8 , FK8->(IndexKey(1)))

	//Cria relacionamentos FK9->FK5.
	aAdd(aRelacFK9,{'FK9_FILIAL','xFilial("FK9")'})
	aAdd(aRelacFK9,{'FK9_IDMOV','FKA_IDORIG'})
	oModel:SetRelation( 'FK9DETAIL', aRelacFK9 , FK9->(IndexKey(1)))

	//Cria relacionamentos FKY->FK4.
	If __lTemFKY
		aAdd(aRelacFKY,{'FKY_FILIAL','xFilial("FKY")'})
		aAdd(aRelacFKY,{'FKY_IDFK2','FKA_IDORIG'})
		oModel:SetRelation( 'FKYDETAIL', aRelacFKY , FKY->(IndexKey(3)))
	Endif

Return oModel

/*/{Protheus.doc}FINM020Grv
Grava��o do modelo e de outras entidades.
@param oModel - Modelo de dados
@author William Matos Gundim Junior
@since  04/04/2014
@version 12
/*/
Function FINM020Grv(oModel As Object)
	Local oFK2			As Object
	Local oFK3			As Object
	Local oFK4			As Object
	Local oFK5			As Object
	Local oFK6			As Object
	Local oFK8  		As Object
	Local oFK9	 		As Object
	Local oFKA			As Object
	Local oFKY			As Object
	Local nOper 		As Numeric
	Local nOperSE5  	As Numeric
	Local cHistCan  	As Character 
	Local cLA			As Character 
	Local lRet			As Logical
	Local nX			As Numeric
	Local nY			As Numeric
	Local nK			As Numeric
	Local nZ			As Numeric
	Local nPos			As Numeric
	Local aValMaster 	As Array
	Local aAux			As Array
	Local cVetAux		As Character 
	Local aCamposFK2 	As Array
	Local aCamposFK3 	As Array
	Local aCamposFK4 	As Array
	Local aCamposFK5 	As Array
	Local aCamposFK6 	As Array
	Local aCamposFK9 	As Array
	Local aCamposFK8 	As Array
	Local aAuxFK2		As Array
	Local aAuxFK3		As Array
	Local aAuxFK4		As Array
	Local aAuxFK5		As Array
	Local aAuxFK6		As Array
	Local aAuxFK8		As Array
	Local aAuxFK9		As Array
	Local aAuxFKY		As Array
	Local aOldFK6		As Array
	Local aOldFK3		As Array
	Local aOldFK4		As Array
	Local cAux			As Character 
	Local nPosFK2		As Numeric
	Local aSE5			As Array 	
	Local nCountSE5 	As Numeric
	Local cCart			As Character 
	Local cIdFK2		As Character 
	Local nLen			As Numeric
	Local nTamFKA		As Numeric
	Local nTamE5Cpos 	As Numeric
	Local lCmpFK2 		As Logical
	Local nValBx    	As Numeric
	Local cChave    	As Character 
	Local aTpImp    	As Array
	Local aDadosFK2 	As Array
	Local nImpBx    	As Numeric
	Local lMotBxMov 	As Logical
	Local cTpImp    	As Character 
	Local aImpSusp  	As Array
	Local nVa 			As Numeric
	Local lIRRFBaixa	As Logical
	Local lRatIRPF		As Logical
	Local nlimFK3		As Numeric
	Local nBaseTot    	As Numeric
	Local nImpRet    	As Numeric
	Local aRatIRPF		As Array
	Local aRatFKW		As Array
	Local lGravouFk4 	As Logical

	oFK2		:= oModel:GetModel('FK2DETAIL')
	oFK3		:= oModel:GetModel('FK3DETAIL')
	oFK4		:= oModel:GetModel('FK4DETAIL')
	oFK5		:= oModel:GetModel('FK5DETAIL')	
	oFK6		:= oModel:GetModel('FK6DETAIL')
	oFK8  		:= oModel:GetModel('FK8DETAIL')
	oFK9	 	:= oModel:GetModel('FK9DETAIL')
	oFKA		:= oModel:GetModel('FKADETAIL')
	oFKY		:= nil
	nOper 		:= oModel:GetOperation()
	nOperSE5  	:= oModel:GetValue('MASTER','E5_OPERACAO')
	cHistCan  	:= oModel:GetValue('MASTER','HISTMOV')
	cLA			:= oModel:GetValue('MASTER','E5_LA')
	lRet		:= .T.
	nX			:= 0
	nY			:= 0
	nK			:= 0
	nZ			:= 0
	nPos		:= 0
	aValMaster	:= {}
	aAux		:= {}
	cVetAux		:= ''
	aCamposFK2	:= FK2->(DbStruct())
	aCamposFK3	:= FK3->(DbStruct())
	aCamposFK4	:= FK4->(DbStruct())
	aCamposFK5	:= FK5->(DbStruct())
	aCamposFK6	:= FK6->(DbStruct())
	aCamposFK9	:= FK9->(DbStruct())
	aCamposFK8	:= FK8->(DbStruct())
	aAuxFK2		:= {}
	aAuxFK3		:= {}
	aAuxFK4		:= {}
	aAuxFK5		:= {}
	aAuxFK6		:= {}
	aAuxFK8		:= {}
	aAuxFK9		:= {}
	aAuxFKY		:= {}
	aOldFK6		:= {}
	aOldFK3		:= {}
	aOldFK4		:= {}
	cAux		:= ""  
	nPosFK2		:= 0    
	aSE5		:= {}	 	
	nCountSE5 	:= SE5->(Fcount())
	cCart		:= "P" 
	cIdFK2		:= ""
	nLen		:= 0
	nTamFKA		:= 0
	nTamE5Cpos 	:= 0
	lCmpFK2 	:= FK2->(FieldPos("FK2_DTDISP")) > 0 .and. FK2->(FieldPos("FK2_DTDIGI")) > 0 
	nValBx    	:= 0
	cChave    	:= xFilial("SE2",SE2->E2_FILORIG) + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
	aTpImp    	:= {}
	aDadosFK2 	:= {}
	nImpBx    	:= 0
	lMotBxMov 	:= (SuperGetMv("MV_MB10925",.t.,"2") == "1")
	cTpImp    	:= ""
	aImpSusp  	:= {}
	nVa 		:= 0
	lIRRFBaixa	:= .F.
	lRatIRPF	:= .F.
	nlimFK3		:= 0
	nBaseTot	:= 0
	nImpRet		:= 0
	aRatIRPF	:= {}
	aRatFKW		:= {}
	lGravouFk4  := .F.
	aRecSE5		:= {}
	
	If cPaisLoc == 'BRA'
		lIRRFBaixa  := SA2->A2_CALCIRF == "2"
		If lIRRFBaixa .And. (SA2->A2_TIPO = "F" .Or. (SA2->A2_TIPO = "J" .And. SA2->A2_IRPROG = "1"))
			aRatIRPF:= Fm020IrAlu()
			lRatIRPF := Len(aRatIRPF)>1
		EndIf
	EndIf

	If __lTemFKY
		oFKY := oModel:GetModel('FKYDETAIL')
	Endif


	If __nFpFK5 == NIL
		__nFpFK5 := FK5->(FieldPos("FK5_MSUIDT"))
	EndIf	
	If __nFpSE5 == NIL
		__nFpSE5 := SE5->(FieldPos("E5_MSUIDT"))
	EndIf	

	If !Empty(oModel:GetValue('MASTER','E5_CAMPOS'))
		aValMaster := Separa(oModel:GetValue('MASTER','E5_CAMPOS'),'|')
		nTamE5Cpos := Len(aValMaster)
	EndIf

	If nOper == MODEL_OPERATION_INSERT

		If oModel:GetValue( 'MASTER', 'NOVOPROC' )
			oModel:SetValue( 'MASTER', 'IDPROC', FINFKSID('FKA','FKA_IDPROC') )
		Endif

		If oModel:GetValue("MASTER", "E5_GRV")
			//Grava SE5 com os valores da SE2 - Baixas a Pagar.
			For nX := 1 To oFKA:Length()
				
				//Posiciona na FKA do Model
				oFKA:GoLine(nX)
				oFKA:SetValue( 'FKA_IDFKA', FWUUIDV4() )
				
				If !oFK2:IsEmpty()
					RecLock("SE5",.T.)
					E5_FILIAL	:= xFilial("SE5")
					E5_TABORI	:= "FK2"
					E5_IDORIG	:= oFKA:GetValue('FKA_IDORIG', nX)
					E5_MOVFKS	:= 'S'	// Campo de controle para migra��o dos dados.	
					
					If oFKA:GetValue('FKA_TABORI') == "FK2"
						E5_DATA	  := oFK2:GetValue("FK2_DATA")
						nValBx	  := oFK2:GetValue("FK2_VALOR")
						If !oFK6:IsEmpty()	
							For nZ := 1 To oFK6:Length()
								oFK6:GoLine(nZ)
								If !(oFK6:GetValue("FK6_TPDOC") $ "DC|D2|CM|VM|C2")
									nVa  -= oFK6:GetValue("FK6_VALMOV")
								ElseIf oFK6:GetValue("FK6_TPDOC") $ "DC|D2"
									nVa  += oFK6:GetValue("FK6_VALMOV")
								EndIf
							Next nZ
						EndIf
						aDadosFK2 := {oFKA:GetValue('FKA_IDORIG'), oFK2:GetValue("FK2_DATA"), oFK2:GetValue("FK2_VALOR"), oFK2:GetValue("FK2_MOTBX"), nVa}			 
					EndIf
					
					If nTamE5Cpos > nK
						nK++
					
						cVetAux := aValMaster[nK]   //Valor recibo do E5_CAMPOS.
						//aAux := aClone(&(cVetAux))
						//Substituida a macro da cVetAux devido a possibilidade de existirem caracteres especiais em campos texto (hist�ricos, benefici�rio)
						//Grava os campos complementares da SE5
						FGrvCpoSE5(cVetAux,aAux)
					Endif
		
					FinGrvSE5(aCamposFK2,aDeParaFK2,oFK2)
					SE5->(MsUnlock())
					
					/*
					* Armazena os recnos gravados no commit do Modelo de Dados
					*/
					aAdd(aRecSE5,SE5->(Recno()))
					
					oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))

					If lCmpFK2
						oFK2:SetValue("FK2_DTDISP", SE5->E5_DTDISPO)
						oFK2:SetValue("FK2_DTDIGI", SE5->E5_DTDIGIT)
					EndIf

					nPosFK2 := nX

					//Gravacao dos impostos retidos e/ou suspensos na tabela FKY, ja proporcionalizados por natureza de rendimento (REINF - Bloco 40)
					If __lTemFKY .And. Len(aDadosFK2) > 0 .And. !SE2->E2_TIPO $ MVPAGANT .And. FindFunction("GetPropImp")
						//Localiza impostos que sofreram retencao e tambem que sofreram isencoes/suspencoes parciais	
						If !oFK3:IsEmpty()	.and. !lRatIRPF
							nlimFK3 := oFK3:Length()
							For nZ := 1 To nlimFK3
								oFK3:GoLine(nZ)			
								If !oFK4:IsEmpty()	
									nImpBx += oFK4:GetValue("FK4_VALOR")
									cTpImp := oFK4:GetValue("FK4_IMPOS")
									If Alltrim(cTpImp) $ "IRF|PIS|COF|CSL"
										aAdd( aTpImp, cTpImp) 
										aAdd( aAuxFKY , GetPropImp( cChave, cTpImp, oFK4:GetValue("FK4_IDFK4"), oFK3:GetValue("FK3_BASIMP"), oFK4:GetValue("FK4_VALOR"), aDadosFK2[3],, aDadosFK2[2], aDadosFK2[4], "FK4") ) 
									Endif			
								Else 
									cTpImp := oFK3:GetValue("FK3_IMPOS")
									If Alltrim(cTpImp) $ "IRF|PIS|COF|CSL"
										aAdd( aTpImp, cTpImp) 
										aAdd( aAuxFKY , GetPropImp( cChave, cTpImp, oFK3:GetValue("FK3_IDFK3"), oFK3:GetValue("FK3_BASIMP"), 0, aDadosFK2[3],, aDadosFK2[2], aDadosFK2[4] , "FK3") ) 
									Endif							
								Endif				
							Next nZ
						Else
							If !Fm020GerI()
								DbSelectArea("FKW")
								FKW->(DbSetOrder(3)) //FKW_FILIAL+FKW_IDDOC+FKW_TPIMP+FKW_CGC
								If FKW->(DBSeek(xFilial("FKW", oFK2:GetValue("FK2_FILORI")) + oFK2:GetValue("FK2_IDDOC") + "SEMIMP" ) )
									aAdd( aAuxFKY , GetPropImp( cChave, "SEMIMP", FKW->FKW_IDFKW, aDadosFK2[3]+aDadosFK2[5], 0, aDadosFK2[3],, aDadosFK2[2], aDadosFK2[4], "FKW" ) )
								EndIf
							EndIf
						Endif

						If lRatIRPF
							nBaseTot:= 0
							nImpRet	:= 0
							If !oFK3:IsEmpty()
								nlimFK3 := oFK3:Length()
							EndIf
							For nZ:= 1 to Len(aRatIRPF)
								If nlimFK3 > 0
									lGravouFk4 := .F.
									For nY := 1 To nlimFK3
										oFK3:GoLine(nY)
										If oFK4:SeekLine({{"FK4_IMPOS", "IRF"},{"FK4_CGC", aRatIRPF[nZ][3]+SPACE(3)}})
											Aadd(aRatFKW,{aRatIRPF[nZ][3],aRatIRPF[nZ][4],aRatIRPF[nZ][6],oFK4:GetValue("FK4_IDFK4"), "FK4"})
											nBaseTot += oFK3:GetValue("FK3_BASIMP")
											nImpBx	 += oFK4:GetValue("FK4_VALOR")
											nImpRet	 += aRatIRPF[nZ][6]+aRatIRPF[nZ][7]
											lGravouFk4 := .T.
											Exit
										EndIf
									Next nY
								EndIf
																
								If !lGravouFk4
									DbSelectArea("FKW")
									FKW->(DbSetOrder(3)) //FKW_FILIAL+FKW_IDDOC+FKW_TPIMP+FKW_CGC
									If FKW->(DBSeek(xFilial("FKW", oFK2:GetValue("FK2_FILORI")) + oFK2:GetValue("FK2_IDDOC") + "IRF   "+aRatIRPF[nZ][3] ) )
										Aadd(aRatFKW,{aRatIRPF[nZ][3],aRatIRPF[nZ][4],aRatIRPF[nZ][6],,})
									EndIf
									nBaseTot += aRatIRPF[nZ][5]
								EndIf 
							Next nZ

							If Len(aRatFKW)>0
								aAdd( aTpImp, "IRF   ") //Grava��o de IRPF rateado por CPF, que n�o atingiu o valor minimo de reten��o
								aAdd( aAuxFKY , GetPropImp( cChave, "IRF   ", "", nBaseTot, nImpRet, aDadosFK2[3],, aDadosFK2[2], aDadosFK2[4], "",aRatFKW) )
							EndIf
						EndIf

						//Verifica impostos que nao sofreram retencao devido a isencao/suspensao total 
						If !FwIsInCallStack("FINA241") .And. !FwIsInCallStack("FINA590")
							If !lMotBxMov .Or. ( lMotBxMov .And. MovBcoBx( aDadosFK2[4], .T. ) ) //Respeita configura��o do MV_MB10925, assim grava FKY somente se o cenario do parametro permitir
								aImpSusp := GetImpNRet( cChave, "SE2","1") //Retorna listagem de impostos que possuem registro na tabela FKG ou FKW
								
								If Len(aImpSusp) > 0
									//Se estiver vindo da compensa��o, verifica se o PA a ser compensado � respons�vel pela reten��o dos impostos
									If FwIsInCallStack("FINA340") .and. FindFunction("F340RecPA")
										nRecnoPA := F340RecPA()
										
										If nRecnoPA > 0
											cTpImp := VerifCmpPA(nRecnoPA, lIRRFBaixa)
										EndIf
									Else
										cTpImp := ""
										If lIRRFBaixa
											cTpImp += "IRF"
										EndIf 
										If __lPccBx 
											If !Empty(cTpImp)
												cTpImp +="|"
											EndIf	
											cTpImp += "PIS|COF|CSL"
										EndIf
									EndIf
									
									If !Empty(cTpImp)
										For nZ := 1 To Len(aImpSusp)
											//Verifica se tem PCC ou IR na FKG que nao sofreram retencao, se sim grava FKY como imposto totalmente n�o retido
											If Alltrim( aImpSusp[nZ] ) $ cTpImp .And. aScan( aTpImp, aImpSusp[nZ] ) == 0
												aAdd( aAuxFKY , GetPropImp( cChave, aImpSusp[nZ],,,, aDadosFK2[3], nImpBx, aDadosFK2[2], aDadosFK2[4] ) )
											Endif
										Next nZ
									EndIf
								EndIf
							Endif
						EndIf

						//Grava a tabela FKY
						If Len(aAuxFKY) > 0
							FinGrvFKY( aDadosFK2[1], oFKY, aAuxFKY ) 
						Endif
							
						//Limpa valores da memoria.
						aSize(aAuxFKY, 0) 
						aSize(aDadosFK2, 0)
						aSize(aImpSusp, 0)	
					Endif
						
				Endif
		
				If !oFK5:IsEmpty()
					RecLock("SE5",.F.)
					FinGrvSE5(aCamposFK5,aDeParaFK5,oFK5)
					SE5->(MsUnlock())			
				Endif

			Next nX

			FwFreeArray(aAuxFKY)
			FwFreeArray(aDadosFK2)
			FwFreeArray(aImpSusp)

		Endif

		//Posiciona na FKA do Model
		If nPosFK2 > 0
			oFKA:GoLine(nPosFK2)
		Endif

		//Gravo valores acessorios (Juros, Multa, Desconto etc)
		If !oFK6:IsEmpty()
			FinGrvFK6('FK2', aAux)
		EndIf

	ElseIf nOper == MODEL_OPERATION_UPDATE 

		//Atualiza os campos na SE5.
		RecLock("SE5",.F.)
		For nX := 1 To Len(aCamposFK5)
			If oFK5:IsFieldUpdated(aCamposFK5[nX][1])  //Retorna se campo foi atualizado.
				If ( nPos := aScan(aDeParaFK5,{|x| AllTrim( x[1] ) ==  aCamposFK5[nX][1] } ) ) > 0  
					SE5->(FieldPut(FieldPos(aDeParaFK5[nPos,2]) , oFK5:GetValue(aCamposFK5[nX][1])))
				EndIf
			EndIf
		Next nX
		
		//Valores passados pelo E5_CAMPOS.
		For nX := 1 To Len(aValMaster) 
			//Grava valores na SE5 passados pelo campo MEMO.
			cVetAux := aValMaster[nX]   //Valor recibo do E5_CAMPOS.
			//aAux := aClone(&(cVetAux))
			//Substituida a macro da cVetAux devido a possibilidade de existirem caracteres especiais em campos texto (hist�ricos, benefici�rio)
			//Grava os campos complementares da SE5
			FGrvCpoSE5(cVetAux,aAux)	
		Next nX
		
		SE5->(MsUnlock())
		oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))

		nTamFKA := oFKA:Length()
		
		If nOperSE5 > 0

			//Grava SE5 com os valores da SE2 - Baixas a Pagar.
			For nY := 1 To nTamFKA
				
				//Posiciona na FKA do Model
				oFKA:GoLine(nY)

				oFK2 := oModel:GetModel('FK2DETAIL')
				//Movimento bancario
				oFK5 := oModel:GetModel('FK5DETAIL')

				//Impostos Calculados
				oFK3 := oModel:GetModel('FK3DETAIL')			
				//Impostos Retidos
				oFK4 := oModel:GetModel('FK4DETAIL')			
				//Valores Acessorios (Multa, Juros etc)
				oFK6 := oModel:GetModel('FK6DETAIL')

				If !oFK2:IsEmpty()
					aAuxFK2 := {}
					For nX := 1 To Len(aCamposFK2)	
						aAdd( aAuxFK2 , oFK2:GetValue(aCamposFK2[nX][1]) ) 
					Next nX

					//Grava informa��es na tabela FKH para integra��o com o TAF (FINA987) - Exclus�o de titulos
					cIdFK2 := FWUUIDV4()		//IdFK2 do registro de estorno
					
					//Deleta registros da proporcionalizacao de impostos por natureza de rendimento (FKY)
					If __lTemFKY .and. cPaisLoc == "BRA" 
						FinDelFKY(oFK2:GetValue('FK2_IDFK2')) 
					EndIf	

					//Estorno de valores acessorios (Juros, Multa etc)
					If !oFK6:IsEmpty()
						aOldFK6 := {}
						For nK := 1 To oFK6:Length()
							oFK6:GoLine(nK)					
							aAuxFK6 := {}						
							For nX := 1 To Len(aCamposFK6)	
								aAdd( aAuxFK6 , oFK6:GetValue(aCamposFK6[nX][1]) ) 
							Next nX
							aadd (aOldFK6, aAuxFK6)
						Next nK
					Endif
					
					//Estorno de valores impostos calculados
					If !oFK3:IsEmpty()
						aOldFK3 := {}
						For nK := 1 To oFK3:Length()
							oFK3:GoLine(nK)					
							aAuxFK3 := {}						
							For nX := 1 To Len(aCamposFK3)	
								aAdd( aAuxFK3 , oFK3:GetValue(aCamposFK3[nX][1]) ) 
							Next nX
							aadd (aOldFK3, aAuxFK3)
						Next nK
					Endif
					
					//Estorno de valores impostos retidos
					If !oFK4:IsEmpty()
						aOldFK4 := {}
						For nK := 1 To oFK4:Length()
							oFK4:GoLine(nK)					
							aAuxFK4 := {}						
							For nX := 1 To Len(aCamposFK4)	
								aAdd( aAuxFK4 , oFK4:GetValue(aCamposFK4[nX][1]) ) 
							Next nX
							aadd (aOldFK4, aAuxFK4)
						Next nK
					Endif

					cCart := oFK2:GetValue('FK2_RECPAG')

					//Estorno impostos
					If !oFK3:IsEmpty()
						FinEstFK34(aOldFK3, aOldFK4)
					Endif

					//Estorno na FK2
					nLen := oFKA:Length()
					If oFKA:AddLine() == nLen + 1
						oFKA:SetValue( 'FKA_IDFKA', FWUUIDV4() )
						oFKA:SetValue( 'FKA_IDORIG', cIdFk2)		
						oFKA:SetValue( 'FKA_TABORI', 'FK2')					

						For nX := 1 To Len(aCamposFK2)		
							oFK2:LoadValue( aCamposFK2[nX][1], aAuxFK2[nX] )					
						Next nX								

						oFK2:SetValue('FK2_TPDOC', 'ES')
						oFK2:SetValue('FK2_HISTOR', cHistCan)
						oFK2:SetValue('FK2_RECPAG', If(cCart == "P","R","P"))
						oFK2:SetValue('FK2_DATA', dDataBase)
						
						if lCmpFK2
							oFK2:SetValue("FK2_DTDISP", dDataBase)
							oFK2:SetValue("FK2_DTDIGI", dDataBase)
						EndIf

						//Estorno valores acessorios (Juros, Multa, Desconto etc)
						If Len(aOldFK6) > 0
							FinEstFK6( cCart, aOldFK6 )
						EndIf		
						
						//Estorno impostos
						If Len(aOldFK3) > 0
							FGrvEstFks(aOldFK3, aOldFK4)
						Endif			

					EndIf			
				Endif

				If !oFK5:IsEmpty()		
					aAuxFK5 := {}
					aAuxFK8 := {}
					aAuxFK9 := {}
					
					For nX := 1 To Len(aCamposFK5)	
						aAdd( aAuxFK5 , oFK5:GetValue(aCamposFK5[nX][1]) ) 
					Next nX
					
					For nX := 1 To Len(aCamposFK8)	
						aAdd( aAuxFK8 , oFK8:GetValue(aCamposFK8[nX][1]) ) 
					Next nX
					
					For nX := 1 To Len(aCamposFK9)	
						aAdd( aAuxFK9 , oFK9:GetValue(aCamposFK9[nX][1]) ) 
					Next nX

					cCart := oFK5:GetValue('FK5_RECPAG')

					//Estorno na FK5
					nLen := oFKA:Length()
					If oFKA:AddLine() == nLen + 1
						oFKA:SetValue( 'FKA_IDFKA', FWUUIDV4() )
						oFKA:SetValue( 'FKA_IDORIG', FWUUIDV4() )		
						oFKA:SetValue( 'FKA_TABORI', 'FK5')										
						For nX := 1 To Len(aCamposFK5)		
							oFK5:LoadValue( aCamposFK5[nX][1], aAuxFK5[nX] )					
						Next nX								
						oFK5:SetValue('FK5_TPDOC', 'ES')
						oFK5:SetValue('FK5_HISTOR', cHistCan)					
						oFK5:SetValue('FK5_RECPAG', If(cCart == "P","R","P"))
						oFK5:SetValue('FK5_DATA', dDatabase)
						oFK5:SetValue('FK5_DTCONC', CTOD("//"))		
						If __nFpFK5	> 0
							oFK5:SetValue('FK5_MSUIDT', "")
						EndIf

						//Grava FK8 e inverte os valores de debito e cr�dito
						If Len(aCamposFK8) > 0	.and. !oFK8:IsEmpty()		
							For nX := 1 To Len(aCamposFK8)		
								oFK8:LoadValue( aCamposFK8[nX][1], aAuxFK8[nX] )					
							Next nX
						
							cAux := oFK8:GetValue( "FK8_DEBITO" )
							oFK8:SetValue( "FK8_DEBITO", oFK8:GetValue( "FK8_CREDIT" ) )
							oFK8:SetValue( "FK8_CREDIT", cAux )
							
							cAux := oFK8:GetValue( "FK8_CCD" )
							oFK8:SetValue( "FK8_CCD", oFK8:GetValue( "FK8_CCC" ) )
							oFK8:SetValue( "FK8_CCC", cAux )
							
							cAux := oFK8:GetValue( "FK8_ITEMD" )
							oFK8:SetValue( "FK8_ITEMD", oFK8:GetValue( "FK8_ITEMC" ) )
							oFK8:SetValue( "FK8_ITEMC", cAux )
							
							cAux := oFK8:GetValue( "FK8_CLVLDB" )
							oFK8:SetValue( "FK8_CLVLDB", oFK8:GetValue( "FK8_CLVLCR" ) )
							oFK8:SetValue( "FK8_CLVLCR", cAux )
							
							cAux := AllTrim( oFK8:GetValue( "FK8_TPLAN" ) )
							cAux := Iif( cAux == "1", "2", Iif( cAux == "2", "1", "3" ) )
							oFK8:SetValue( "FK8_TPLAN", cAux )
						Endif
			
						For nX := 1 To Len(aCamposFK9)		
							oFK9:SetValue( aCamposFK9[nX][1], aAuxFK9[nX] )					
						Next nX	
					EndIf			
				Endif
			Next nY

			//Atualiza a SE5 - Mov. Bancaria conforme a opera��o.
			Do Case
				Case nOperSE5 == 1 //Exclus�o(Atualiza SITUACA = 'C') 
					RecLock("SE5",.F.)
					E5_SITUACA := 'C'
					SE5->(MsUnlock())
					oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))

				Case nOperSE5 == 2 //	Estorno
					//Obtenho os dados do registro a ser estornado
					For nX := 1 to nCountSE5
						AAdd( aSE5, Iif(nX==2/*data*/ .And. ValType(SE5->( FieldGet(nX))) == "D",dDatabase,SE5->( FieldGet(nX)) ) )
					Next
					// Grava o registro de estorno
					RecLock("SE5" ,.T.)
					For nX := 1 to nCountSE5
						If nX <> __nFpSE5
							SE5->( FieldPut( nX,aSE5[nX]))
						EndIf
					Next
					SE5->E5_FILIAL	:= xFilial("SE5")
					SE5->E5_TIPODOC	:= 'ES'
					SE5->E5_TABORI	:= "FK2"
					SE5->E5_IDORIG	:= cIdFK2
					SE5->E5_MOVFKS	:= 'S'	// Campo de controle para migra��o dos dados.
					SE5->E5_RECPAG	:= If(cCart == "P","R","P")
					SE5->E5_HISTOR	:= cHistCan
					SE5->E5_LA		:= cLa
					SE5->E5_DATA	:= dDatabase
					SE5->E5_DTDIGIT	:= dDatabase
					SE5->E5_DTDISPO	:= dDatabase
					SE5->E5_RECONC	:= ''
					SE5->(MsUnlock())
					oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))
					
				Case nOperSE5 >= 3 //Exclui registro. 
					RecLock("SE5", .F.)
					SE5->(dbDelete())
					SE5->(MsUnlock())
					oModel:SetValue("MASTER","E5_RECNO",SE5->(Recno()))
			End Case
		EndIf
	EndIf

	lRet := FwFormCommit( oModel ) 

	If lRet
		//Confirma os valores incrementais da GetSx8Num()
		While (GetSx8Len() > nSaveSx8)
			ConfirmSX8()			
		EndDo
	Endif

	nSaveSx8 := 0

Return lRet


/*/{Protheus.doc}FINM020Pos
Pos validacao do modelo e de outras entidades.
@param oModel - Modelo de dados
@author William Matos Gundim Junior
@since  04/04/2014
@version 12
/*/
Function FINM020Pos( oModel )

Local lRet := .T.

Return lRet

/*/{Protheus.doc} FIM020RSE5
Fun��o que retornar os Recnos dos SE5 gravados no commit do Modelo de Dados.
@author Marylly Ara�jo Silva
@since  12/05/2014
@version 12
/*/
Function FIM020RSE5()
Return aRecSE5

//----------------------------------------------------------------------------------
/*/{Protheus.doc} VerifCmpPA
Fun��o para retornar os impostos que n�o est�o configurados para reten��o
no PA da compensa��o, para tratamento de grava��o da FKY (REINF)

@param nRecnoPA, numeric, Recno do PA no processo de compensa��o
@param lIRRFBaixa, Logical, indica se reten��o do IRRF � na baixa.
@return cRet, String com os impostos que n�o est�o configurados para reten��o no PA
		
@author pedro.alencar
@since 24/09/2019
@version 12.1.27
/*/
//----------------------------------------------------------------------------------
Static Function VerifCmpPA( nRecnoPA As Numeric, lIRRFBaixa As Logical )
	Local cRet As Char
	Local aAreaSE2 As Array
	Local aAreaSED As Array
	Local aAreaSA2 As Array
	Local cNatPA As Char
	Local cFornPA As Char
	Local cLojaPA As Char
	Local lPARtIRF As Logical
	Local lPARtPIS As Logical
	Local lPARtCOF As Logical
	Local lPARtCSL As Logical
	
	Default nRecnoPA := 0
	Default lIRRFBaixa := .F.

	lPARtIRF := .F.
	lPARtPIS := .F.
	lPARtCOF := .F.
	lPARtCSL := .F.
	cRet 	 := ""
	
	//Posiciona no recno do PA para pegar a natureza e o fornecedor
	aAreaSE2 := SE2->( GetArea() )
	SE2->( dbGoTo(nRecnoPA) )
	
	cNatPA := SE2->E2_NATUREZ
	cFornPA := SE2->E2_FORNECE
	cLojaPA := SE2->E2_LOJA
	
	RestArea(aAreaSE2)
	FwFreeArray(aAreaSE2)
	
	//Posiciona a SED para ver se a natureza do PA calcula os impostos
	aAreaSED := SED->( GetArea() )
	SED->( dbSetOrder(1) ) //ED_FILIAL+ED_CODIGO	
	If SED->( MsSeek( FWxFilial("SED") + cNatPA ) )
		lPARtIRF := ( SED->ED_CALCIRF == "S" )
		lPARtPIS := ( SED->ED_CALCPIS == "S" )
		lPARtCOF := ( SED->ED_CALCCOF == "S" )
		lPARtCSL := ( SED->ED_CALCCSL == "S" )
	EndIf
	
	RestArea(aAreaSED)
	FwFreeArray(aAreaSED)
	
	If lPARtIRF .Or. lPARtPIS .Or. lPARtCOF .Or. lPARtCSL
		//Posiciona a SA2 para ver se o fornecedor recolhe os impostos
		aAreaSA2 := SA2->( GetArea() )
		SA2->( dbSetOrder(1) ) //A2_FILIAL+A2_COD+A2_LOJA
		If SA2->( MsSeek( FWxFilial("SA2") + cFornPA + cLojaPA ) )
			lPARtIRF := lPARtIRF .And. ( SA2->A2_CALCIRF == "2" )
			lPARtPIS := lPARtPIS .And. ( SA2->A2_RECPIS == "2" )
			lPARtCOF := lPARtCOF .And. ( SA2->A2_RECCOFI == "2" )
			lPARtCSL := lPARtCSL .And. ( SA2->A2_RECCSLL == "2" )
		EndIf
		
		RestArea(aAreaSA2)
		FwFreeArray(aAreaSA2)
	EndIf
	
	If !lPARtIRF .And. lIRRFBaixa
		cRet +="IRF"
	Endif
	If __lPccBx
		If !lPARtPIS
			cRet += "|PIS"
		Endif
		If !lPARtCOF
			cRet += "|COF"
		Endif
		If !lPARtCSL
			cRet += "|CSL"
		Endif
	EndIf

Return cRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} Fm020GerI
Retorna se o fornecedor e natureza est�o configurados para reter
algum dos impostos liberados para serem utilizados no Complemento de Imposto

@return lRet, Logical, define se o t�tulo � passivel de reten��o de impostos.

@since  29/12/2022
@version P12
@author P�mela Bernardo
/*/
//-------------------------------------------------------------------
Static Function Fm020GerI()

    Local lRet   	As Logical
    Local lSeekED   As Logical
	Local lSeekA2   As Logical
	Local aAreaSED	As Array 
	Local aAreaSA2	As Array 

	lRet   		:= .F.
    lSeekED 	:= .F.
	lSeekA2 	:= .F.
	aAreaSED	:= SED->(GETAREA())
	aAreaSA2	:= SA2->(GETAREA())


    //Posiciona na Natureza
    SED->(DBSetOrder(1))
    lSeekED := SED->( DBSeek(xFilial('SED') + SE2->E2_NATUREZ  ) )

    SA2->(DBSetOrder(1))
    lSeekA2 := SA2->(DBSeek(xFilial('SA2')+SE2->E2_FORNECE+SE2->E2_LOJA))


    If lSeekED .and. lSeekA2
		If (SED->ED_CALCIRF == 'S' .and. SA2->A2_CALCIRF $ "1|2" ) .or. (SED->ED_CALCPIS == 'S' .and.  SA2->A2_RECPIS == '2') .or. ;
			(SED->ED_CALCCOF == 'S' .and. SA2->A2_RECCOFI == '2') .or. (SED->ED_CALCCSL == 'S' .and. SA2->A2_RECCSLL == '2')
			lRet := .T.
		Endif
    EndIf

	RestArea(aAreaSED)
	RestArea(aAreaSA2)

Return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} Fm020IrAlu
Verifica o rateio de CPF para IRPF

@return aRet, retorna um array com os dados de calculo de rateio de IRPF

@since  12/01/2022
@version P12
@author P�mela Bernardo
/*/
//-------------------------------------------------------------------
Static Function Fm020IrAlu()
	Local aRet As Array

	aRet := {}

	Do CASE
		CASE FwIsInCallStack("FINA080") .and. FindFunction('F080RatIr')
			aRet := F080RatIr() 
		CASE FwIsInCallStack("FINA090") .and. FindFunction('F090RatIr')	
			aRet := F090RatIr() 
		CASE FwIsInCallStack("FINA241") .and. FindFunction('F241RatIr')	
			aRet := F241RatIr() 
		CASE FwIsInCallStack("FINA340") .and. FindFunction('F340RatIr')	
			aRet := F340RatIr() 
		CASE FwIsInCallStack("FINA590") .and. FindFunction('F241RatIr')	
			aRet := F241RatIr() 
	ENDCASE	

Return aRet

