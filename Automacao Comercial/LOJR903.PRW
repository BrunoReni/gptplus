#INCLUDE "LOJR903.ch"

Static _aRetCodigo := NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJR903
Relatorio de Pedidos N�o Integrados e-commerce CiaShop
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample LOJR903()
/*/
//-------------------------------------------------------------------
Function LOJR903()

local oReport //Objeto Relatorio
local cPerg  := 'LJ903' //Pergunte
local cAlias := getNextAlias() //Alias da Query

Pergunte(cPerg, .F.)

oReport := Lj903RDef(cAlias, cPerg)

oReport:printDialog()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj903RDef
Relatorio de Pedidos N�o Integrados e-commerce CiaShop - Cria��o da estrutura do relat�rio
@param   	cAlias - Alias
@param   	cPerg - Pergunta
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj903RDef(cAlias,cPerg)
/*/
//-------------------------------------------------------------------
Static Function Lj903RDef(cAlias,cPerg)

local cTitle  := STR0001 //"Relat�rio de Pedido n�o Integrados"
local cHelp   := STR0002 +; //"Permite gerar um relat�rio para visualizar os pedidos n�o integrados "
STR0003 //"devido h� problemas na integra��o entre o Protheus e a Loja Virtual."

local oReport
local oSection1

oReport	:= TReport():New('LOJR903',cTitle,cPerg,{|oReport|Lj903RPrt(oReport,cAlias)},cHelp)

//Primeira se��o
oSection1 := TRSection():New(oReport,STR0004,{"MGM","MGU"},{}) //"Pedidos"

TRCell():New(oSection1,"MGM_DATA"    , "MGM", STR0005,,15) //"Data"
TRCell():New(oSection1,"MGU_PEDECO" , "MGU", STR0006,,12) //"Num. Pedido Loja Virtual"
TRCell():New(oSection1,"MGU_METENT" , "MGU", STR0007) //"M�t. Entrega"
TRCell():New(oSection1,"MGU_METPGT" , "MGU", STR0008)         //"M�t. Pagamento"
TRCell():New(oSection1,"MGU_CODCLI"  , "MGU", STR0009)         //"C�digo Cliente"
TRCell():New(oSection1,"MGU_NOMENT"  , "MGU", STR0010)         //"Nome Cliente"
TRCell():New(oSection1,"MGU_TOTAL"   , "MGU", STR0011) //"Valor"
TRCell():New(oSection1,"MGU_FRETE"   , "MGU", STR0012) //"Frete"
TRCell():New(oSection1,"Lj903ErrD"   ,      , STR0013,,60,,{|| Lj903ErrD(cAlias)}) //"Descri��o do Problema"

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj902RPrt
Relatorio de Pedidos N�o Integrados e-commerce CiaShop - Montagem dos dados do relat�rio
@param   	oReport - Objeto Report
@param   	cAlias - Alias
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj905RPrt(oReport,cAlias)
/*/
//+--------------------------------------
Static Function Lj903RPrt(oReport,cAlias)

local oSection1b := oReport:Section(1) //Secao do Relatorio

oSection1b:BeginQuery()

BeginSQL Alias cAlias
	
	Column MGM_DATA as Date
	
	SELECT MGM2.MGM_DATA, MGU3.MGU_PEDECO, MGU3.MGU_METENT, MGU3.MGU_METPGT, MGU3.MGU_MOTERR,
		MGU3.MGU_CODCLI, MGU3.MGU_NOMENT, MGU3.MGU_TOTAL, MGU3.MGU_FRETE
	FROM
	(SELECT X.*
	FROM	
	(
		SELECT MGU1.MGU_PEDECO, MAX(MGM.MGM_SEQ) AS SEQ,   
		( SELECT COUNT(1) AS CONTA
			FROM %Table:MGU% MGU2
			WHERE MGU2.MGU_FILIAL = %xFilial:MGU%
			AND MGU2.MGU_PEDECO = MGU1.MGU_PEDECO
			AND MGU2.MGU_CONFIR = '1'
			AND MGU2.%NotDel%		
		) AS CONTA
		
		FROM %Table:MGU% MGU1
		
		INNER JOIN %Table:MGM% MGM
		ON MGM_FILIAL = MGU1.MGU_FILIAL
		AND MGM_SEQ = MGU1.MGU_SEQ
		AND MGM_SERVIC = 'LOJA901A'
		AND MGM.%NotDel%              		
		WHERE MGU1.MGU_FILIAL = %xFilial:MGU%
		AND MGU1.MGU_CONFIR = '0'
		AND MGM.MGM_DATA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
		AND MGU1.%NotDel% 
	GROUP BY MGU_PEDECO) X
	WHERE X.CONTA = 0	) Y,
	%Table:MGU% MGU3,
	%Table:MGM% MGM2,
	WHERE MGU3.MGU_SEQ = Y.SEQ 
	AND MGU3.MGU_PEDECO = Y.MGU_PEDECO
	AND MGU3.MGU_FILIAL = %xFilial:MGU% 
	AND MGU3.%NotDel% 
	AND MGM2.MGM_SEQ = Y.SEQ
	AND MGM2.MGM_FILIAL = %xFilial:MGM% 
 	AND MGM2.%NotDel% 
	ORDER BY MGM_DATA
	
EndSQL

oSection1b:EndQuery() 


oReport:SetMeter((cAlias)->(LastRec()))

oSection1b:Print()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj903ErrD
Relatorio de Pedidos N�o Integrados e-commerce CiaShop - Descricao do Erro
@param   	cAlias - Alias
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj903ErrD(cAlias
/*/
//-------------------------------------------------------------------
Static function Lj903ErrD(cAlias)

local cRet     := ""
local cCodErro := AllTrim((cAlias)->MGU_MOTERR) //Codigo do Erro

if !Empty(cCodErro)
	cRet := Lj903DErr(cCodErro)
endif

return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj903DErr
Gera a descri��o do Codigo de Erro
@param   	cCodErro - Codigo do Erro
@retun		cRet - Descri��o do Erro
@author  Varejo
@version 	P11.8
@since   	13/07/2015
@obs     
@sample  Lj903DErr(cCodErro)
/*/
//-------------------------------------------------------------------
 Function Lj903DErr(cCodErro)
 
 Local cRet := ""
 Local nCodErro := 0
 Local nTamErro := 25
 
 
 cCodErro := AllTrim(cCodErro)
 
 If !Empty(cCodErro)
 	cRet := STR0014 + "[" + AllTrim(cCodErro) + "]"
 	If _aRetCodigo = NIL
 		_aRetCodigo := Array(nTamErro)
			_aRetCodigo[1]  := STR0015 //"Cliente n�o encontrado"
			_aRetCodigo[2]  := STR0016 //"CPF do pedido diferente do CPF do cadastro do cliente"
			_aRetCodigo[3]  := STR0017 //"Documento inv�lido"
			_aRetCodigo[4]  := STR0018 //"Transportadora n�o cadastrada"
			_aRetCodigo[5]  := STR0019 //"M�todo de pagamento n�o cadastrado"
			_aRetCodigo[6]  := STR0020 //"Produto n�o cadastrado"
			_aRetCodigo[7]  := STR0034  //"TES n�o informada"
			_aRetCodigo[8]  := STR0022 //"Vendedor (Promoter) n�o cadastrado"
			_aRetCodigo[9]  := STR0028 //"Forma de pagamento inv�lida"
			_aRetCodigo[10]  := STR0029 // "Problemas na gera��o do Pedido de Venda"    			
			_aRetCodigo[11]  := STR0030 //"Problemas na gera��o do Or�amento" 
			_aRetCodigo[12]  := STR0031 //"Problemas na gera��o do T�tulo de Contas a Receber"   
			_aRetCodigo[13]  :=  STR0032 //"Problemas na gera��o do T�tulo de Contas a Pagar da Taxa Administrativa"
			_aRetCodigo[14]  :=  STR0033// "Problema na gera��o de Endere�o de Entrega do Cliente"
			_aRetCodigo[15]  :=  STR0035 // "Problema na gera��o de Reserva do Pedido"
			_aRetCodigo[16]  :=  STR0036 // "N�o localizados pagamentos(SL4) associados ao or�amento"
			_aRetCodigo[17]  := STR0037 //Problemas ao desfazer reserva pois pedido n�o foi feito	
			_aRetCodigo[18]  :=  STR0038 // "Existe mais de um armaz�m vinculado a um item"
			_aRetCodigo[19]  :=  STR0039 // "Existe mais de uma filial vinculada a um Pedido"
			_aRetCodigo[20]  := STR0040 //"Filial n�o cadastrada"
			_aRetCodigo[21]  := STR0041 //"Armaz�m n�o cadastrado ERP"
			_aRetCodigo[22]  := STR0044 //"Valor de venda do item Tributado pelo IPI inv�lido. Verifque configura��o de IPI na TES do item."
			_aRetCodigo[23]  := STR0043//"M�todo de Pagamento n�o homologado pelo Protheus"
			_aRetCodigo[24]  := STR0045// "Anteriormente, houve uma falha no processamento deste pedido, por�m j� foi emitido documento de sa�da. Realize a exclus�o do documento de sa�da, associado ao pedido para reprocessar este pedido e-commerce devidamente."
 			_aRetCodigo[25]  := STR0046// "TES n�o encontrada. Verifique o cadastro de TES Inteligente ou Produtos ou o par�metro MV_TESSAI"
 	
 	EndIf
 	
 	nCodErro := Val(cCodErro)
 	
 	If nCodErro > 0 .AND. nCodErro <= nTamErro
 		cRet := _aRetCodigo[nCodErro]
 	EndIf
 	
  EndIf
 
 Return cRet 
 