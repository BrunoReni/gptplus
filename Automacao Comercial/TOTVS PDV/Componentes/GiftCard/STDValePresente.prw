#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} STDEstorVP
Estorna valor do vale presente

@param  cVale  Codigo do vale presente
@param  nValor Valor do vale presente
@author  Varejo
@version P1180
@since   06/01/2015
@return  lRet
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDEstorVP(cVale, nValor)

Local aArea		:= GetArea()	// Guarda area corrente
Local lRet			:= .F.			// Retorno

Default cVale 	:= ""

cVale := AllTrim(cVale)

DbSelectArea("MDD")
DbSetOrder(1)	//MDD_FILIAL+MDD_CODIGO

If DbSeek(xFilial("MDD")+cVale)
	RecLock( "MDD", .F. )
	
	If SuperGetMV("MV_LJBXPAR",,.F.)
		MDD->MDD_STATUS := '5'
		MDD->MDD_SALDO := MDD->MDD_SALDO + nValor
	Else
		MDD->MDD_STATUS := '2'
	EndIf
	
	MsUnLock()
	lRet := .T.
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STDEstorVP
Valida e chama a fun��o para executar o estorno do vale presente

@param  cNumSale  Codigo da venda
@author  Varejo
@version P1180
@since   07/01/2015
@return  lRet
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDExecEstorVP(cNumSale)

Local lRet	:= .F.	// Retorno

DbSelectArea("SL4")
DbSetOrder(1) //L4_FILIAL + L4_NUM

DbSeek( xFilial("SL4") + cNumSale )

While !EOF() .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial("SL4") + cNumSale

	If AllTrim(SL4->L4_FORMA) == 'VP'
		lRet := STBRemoteExecute("STDEstorVP" ,{SL4->L4_CODVP,SL4->L4_VALOR}, NIL,.F.)
	EndIf
	
	SL4->(dbSkip())
	
End	

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STDGetMinMaxVP
Retorna um array contendo o valor minimo e maximo de venda do vale presente

@param  cCodProduto  codigo do produto
@author  Varejo
@version P1180
@since   14/01/2015
@return  aRes valor minino e maximo vale presente
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDGetMinMaxVP(cCodProduto)

Local aRes			:= {} 
Local lMDDTipo		:= MDD->(ColumnPos("MDD_TIPO"))>0 

Default cCodProduto := ""

DbSelectArea("MDD")
DbSetOrder(1) //MDD_FILIAL + MDD_CODIGO + MDD_SERIR + MDD_DOCR + MDD_PDVR

If DbSeek( xFilial("MDD") + cCodProduto )
	aRes := {MDD->MDD_VALDE, MDD->MDD_VALATE,iIf(lMDDTipo,MDD->MDD_TIPO,"P"), MDD->MDD_PROD}
EndIf
	
Return aRes

//-------------------------------------------------------------------
/*{Protheus.doc} STDGGiftCard
Retorna o conteudo do campo B1_VALEPRE que indica se o produto � vale presente

@param  cCodProduto - codigo do produto
@author  Varejo
@version P1180
@since   24/02/2015
@return  cRet conteudo do campo B1_VALEPRE ("1" -Sim / "2" - N�o
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDGGiftCard(cCodProd)
Local cRet	:= ""
Local aArea := SB1->(GetArea())

SB1->(DBSetOrder(1)) //FILIAL + CODIGO
If SB1->(DBseek(xFilial("SB1") + cCodProd))
	cRet := AllTrim(SB1->B1_VALEPRE) //1-Sim /2->Nao	
EndIf

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} STDVldVP
Valida se o Vale Presente j� foi adicionado no carrinho

@param   cCodVP C�digo do vale presente
@author  Varejo
@version P1180
@since   11/05/2015
@return  lRet
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDVldVP(cCodVP,cTipoVp)

Local cNum	:= STDGPBasket("SL1","L1_NUM") //numero da venda
Local lRet	:= .F.

Default cCodVP	:=	""
Default cTipoVp	:= "P"

If cCodVP <> "" .And. !(cTipoVp == "C")

	DbSelectArea("SL2")
	DbSetOrder(1)	//L2_FILIAL + L2_NUM + L2_ITEM + L2_PRODUTO
	
	/*Busca por todos produtos da venda*/
	If DbSeek( xFilial("SL2") + cNum )
		While !EOF()
			/*Valida se o vale presente informado ja foi registrado*/
			If SL2->L2_VALEPRE == cCodVP
				lRet := .T.
			EndIf
			DbSkip()
		EndDo
	EndIf
	
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STDIsVP
Verifica se o produto � vale presente

@param   nCodProd C�digo do produto
@author  Varejo
@version P1180
@since   11/05/2015
@return  lRet
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDIsVP(cCodProd)

Local lRet	:= .F.

Default cCodProd := 0

If !Empty(cCodProd)

	DbSelectArea("SB1")
	DbSetOrder(1)	//B1_FILIAL + B1_COD
	
	If DbSeek(xFilial("SB1") + cCodProd)
		
		If SB1->B1_VALEPRE == "1"
			lRet := .T.
		EndIf
	Else
		lRet := .F.
	EndIf
Else
	lRet := .F.	
EndIf	

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STDExistVP
Verifica se existe vale presente na venda

@param  
@author  Varejo
@version P1180
@since   10/06/2015
@return  
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDExistVP()

Local cNum		:= STDGPBasket("SL1","L1_NUM") //numero da venda
Local lRet		:= .F.
Local cSL2Fil	:= ""

DbSelectArea("SL2")
DbSetOrder(1)	//L2_FILIAL + L2_NUM + L2_ITEM + L2_PRODUTO
cSL2Fil := xFilial("SL2")
If SL2->(DbSeek( cSL2Fil + cNum ))
	While SL2->(!EOF()) .And. cSL2Fil + cNum == SL2->(L2_FILIAL+L2_NUM) 
		If !Empty(SL2->L2_VALEPRE)
			lRet := .T.
		EndIf
		DbSkip()
	EndDo
EndIf

Return lRet