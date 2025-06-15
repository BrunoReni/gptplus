#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STWRsnLtSl
Motivo de Venda Perdida

@param   nItemLine			Linha do Item na Venda
@param   oReasons             Objeto motivo de venda perdida
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWRsnLtSl( nItemLine , oReasons )

Local cItemCod			:= ""					// Codigo Produto
Local nAmount				:= 1					// Quantidade
Local cCodCli				:= ""					// Codigo do Cliente
Local cStoreCli			:= ""					// Loja do Cliente
Local cSeller				:= ""					// Codigo Vendedor
Local dDate				:= dDataBase			// Data da nao venda
Local aRetInterface		:= {}					// Armazena retorno da interface
Local aRet				:= {}					// Array de retorno
Local nPosSel				:= 0					// Posicao do objeto selecionado
Local cCodReason			:= ""					// Codigo do motivo

Default nItemLine 		:= 0					// Linha do Item na Venda
Default oReasons			:= Nil					// objeto motivo de desconto

ParamType 0 Var nItemLine	As Numeric		Default 0

If SuperGetMv("MV_LJMVPE") .AND. oReasons <> Nil // Usa Movimento de Venda Perdida? 

	nPosSel := oReasons:GetPos()
	If nPosSel > 0
		cCodReason :=  SubStr(oReasons:aItems[nPosSel],1,TamSX3("MBR_MOTIVO")[1])
	EndIf	

	If nItemLine > 0 .AND. !Empty(cCodReason)
		
		cItemCod 		:= STBTaxRet( nItemLine , "IT_PRODUTO" )
		nAmount 		:= STBTaxRet( nItemLine , "IT_QUANT"	)
		cSeller		:= STDGPBasket("SL2","L2_VEND",nItemLine)
		cCodCli		:= STDGPBasket("SL1","L1_CLIENTE")
		cStoreCli		:= STDGPBasket("SL1","L1_LOJA")
		
		STDAddLostSale( 	nItemLine	, cItemCod 	, nAmount		, cCodCli 			, ;
							cStoreCli	, cSeller		, dDate		, cCodReason		)	
   
	
	EndIf   
	
EndIf

Return Nil

