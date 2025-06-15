#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFXFUNDIC.CH"

Static __aAliasInDic
Static __aIdIndex  
Static __lLay0205	:= TafLayESoc("02_05_00")
Static cRetNTrab 	:= ""
Static lLaySimplif	:= TafLayESoc("S_01_00_00")

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFXFUNDIC
Fonte com fun�oes genericas do TAF relacionadas a dicionario de dados

@author Denis R. de Oliveira
@since 13/08/2015
@version 1.0

@Return ( Nil )

/*/       
                                                                                                                              
//---------------------------------------------------------------------
/*/{Protheus.doc} TAFAlsInDic

Indica se um determinado alias est� presente no dicion�rio de dados

@Author	Anderson Costa
@Since		22/07/2015
@Version	1.0

@return lRet  - .T. -> Validacao OK
				  .F. -> Nao Valido

/*/
//---------------------------------------------------------------------
Function TAFAlsInDic(cAlias,lHelp)
Local aArea     := {}
Local aAreaSX2  := {}
Local aAreaSX3  := {}
Local lRet		:= .F.
Local nAt

Default __aAliasInDic := {}

nAt := Ascan( __aAliasInDic, {|x| x[1]==cAlias})

If ( nAt == 0 )
	aArea		:= GetArea()
	aAreaSX2	:= SX2->( GetArea() )
	aAreaSX3	:= SX3->( GetArea() )
	
	DEFAULT lHelp	:= .F.
	
	SX2->( DbSetOrder( 1 ) )
	SX3->( DbSetOrder( 1 ) )
	
	lRet := ( SX2->( dbSeek( cAlias ) ) .And. SX3->( dbSeek( cAlias ) ) )

	Aadd(__aAliasInDic, {cAlias,lRet})
	
	SX3->( RestArea( aAreaSX3 ) )
	SX2->( RestArea( aAreaSX2 ) )
	RestArea( aArea )
Else 
	lRet := __aAliasInDic[nAt][2]
EndIf

If !lRet .And. lHelp
	Help( "", 1, "ALIASINDIC",,cAlias )
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TafColumnPos
Verifica se existe o campo no dicion�rio de dados levando em considera��o a vers�o corrente do release
do cliente.


@Author	Rodrigo Aguilar
@Since		01/12/2015
@Version	1.0

@return lFindCmp ( Indica se o campo existe ou n�o no dicion�rio de dados )

/*/
//---------------------------------------------------------------------
Function TafColumnPos( cCampo )

Local cReleaseAtu := Substr( alltrim( GetRpoRelease() ), 1, 2 )
Local cAliasAtu   := Substr( alltrim( cCampo ), 1, 3 ) 
Local lFindCmp    := .F.

//De acordo com a vers�o corrente do release do cliente utilizo a fun�ao correta para saber se o campo
//existe ou n�o no dicion�rio de dados
if (TAFAlsInDic(cAliasAtu))
	dbSelectArea( cAliasAtu )
	if  cReleaseAtu <> '12'
		lFindCmp := ( FieldPos( cCampo ) > 0 )  
	else
		lFindCmp := ( ColumnPos( cCampo ) > 0 )
	endif
endIf

Return ( lFindCmp )

//---------------------------------------------------------------------
/*/{Protheus.doc} TafIndexInDic
Verifica se existe o indice no dicion�rio de dados e no banco de dados

@param	cAlias		-> Alias da tabela
@param	uIdIndex	-> N�mero ou Id caracter do indice

@Author	Felipe Rossi Moreira
@Since		12/01/2018
@Version	1.0

@return lRet (indica se existe o indice e pode ser usado)

/*/
//---------------------------------------------------------------------

Function TafIndexInDic(cAlias, uIdIndex, lHelp)
Local lRet := .F.
Local cIndex := ""
Local cAliasSQLName := ""

Default lHelp := .F.

if TAFAlsInDic(cAlias, lHelp)
	//Verifica o Id do indice e converte para formato caracter caso num�rico
	if ValType(uIdIndex) == 'C'
		cIndex := uIdIndex
	elseif ValType(uIdIndex) == 'N'
		if uIdIndex > 9
			cIndex := Chr(65+uIdIndex-10)
		else
			cIndex := AllTrim(Str(uIdIndex))
		endif
	endif

	//Nome da tabela no banco para valida��o da exist�ncia do indice no banco de dados
	cAliasSQLName := RetSQLName(cAlias)

	//lRet := !Empty(cIndex) .and. !Empty(Posicione("SIX",1,cAlias+cIndex,"CHAVE")) .and. TcCanOpen(cAliasSQLName,cAliasSQLName+cIndex)

	If TcCanOpen(cAliasSQLName,cAliasSQLName+cIndex)
		lRet := !Empty(cIndex) .and. !Empty(Posicione("SIX",1,cAlias+cIndex,"CHAVE"))
	Else
		DbSelectArea(cAlias)
		lRet := !Empty(cIndex) .and. !Empty(Posicione("SIX",1,cAlias+cIndex,"CHAVE")) .and. TcCanOpen(cAliasSQLName,cAliasSQLName+cIndex)
	EndIf

	If !lRet .And. lHelp
		MsgInfo( STR0069+CRLF+STR0070+cAlias+CRLF+STR0071+cIndex, STR0072 ) //"O seguinte indice n�o est� dispon�vel na dicion�rio de dados:" ## "Tabela: " ## "Indice: " ## "Ambiente Desatualizado!"
	EndIf
endif

Return(lRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGetIdIndex

Fun��o que retorna a ordem do indice do ID conforme alias solicitado

@param	cAliasTAF	-> Alias do TAF
@param	cFieldId	-> Campo considerado ID

@Author		Luccas Curcio
@Since		06/04/2016
@Version	1.0

@return nIdIndex - Ordem do Indice do ID da tabe�a

/*/
//---------------------------------------------------------------------
function TAFGetIdIndex( cAliasTAF , cFieldId )

local	nIdIndex	:=	0
local	nPosIndex	:=	0
local	aAreaSIX	:=	{}
local	nTamFldId	:=	0
local	nTamFldCod	:=	0 //Cria��o da vari�vel que verifica o tamanho que o campo _CODIGO 
Local	cFieldCodi	:=	"_CODIGO" //Cria��o da vari�vel que verifica o nomedo campo que o campo que ser� o �ndice
Local 	nPosic		:= 15

default	__aIdIndex	:=	{}
default	cFieldId	:=	"_ID"


nTamFldId	:=	iif( cFieldId  == "_CHVNF" , 6 , 3 )
nTamFldCod	:= 	iif( cFieldCodi == "_CODIGO" , 7 , 3 )//Defini��o de tamanho da var�vel que receber� o �ndice  

If cAliasTAF $ 'C0A|C8A'
	//Caso o Alias seja C8A / Fpas, modifico o campo pois n�o existe _CODIGO
	If cAliasTAF == "C8A"
		cFieldCodi := "_CDFPAS"
		nTamFldCod := 7
	ElseIf cAliasTAF == "C0A"
		cFieldId := "_CODIGO"
		nTamFldId := 7
	EndIf

ElseIf cAliasTAF $ 'V75|V76|V77|V78'
	nPosic 	 :=  22
	cFieldId := "_VERSAO"
	nTamFldId := 7	
EndIf

//Verifico se ja tenho em cache o indice deste alias
If ( nPosIndex := aScan( __aIdIndex , { |x| x[1] == cAliasTAF } ) ) > 0
	nIdIndex	:=	__aIdIndex[ nPosIndex , 2 ]

Else
	
	aAreaSIX	:=	SIX->( getArea() )
	
	//Caso o alias nao tenha sido utilizado anteriormente, posiciono no primeiro indice do Alias no dicionario SIX
	If SIX->( msSeek( cAliasTAF ) )
	
		//Procuro apenas nos indices do proprio alias
		While SIX->( !eof() ) .and. allTrim( SIX->INDICE ) == ( cAliasTAF )
			
			//Se encontrar algum indice que o segundo campo da chave seja o c�digo posso sair do la�o e utilizar este indice (DSERTAF2-777/DSERTAF2-776 
			//Todas os indices onde o segundo campo � CODIGO come�am com: "XXX_FILIAL+XXX" e depois "_CODIGO" ( XXX_FILIAL+XXX_CODIGO ). Por isso procuro da posicao 11 em diante 
			If cAliasTAF $ ('C3Z|C1A|C6U|C8Z|C8A|CHY|C1U|T71|CUF|CMM') .And. !IsInCallStack("FAtuTabTAF")  
				If substr( SIX->CHAVE , 15 , nTamFldCod ) == cFieldCodi 
					nIdIndex	:=	val( SIX->ORDEM ) 
					//Guardo este alias e chave no array est�tico para agilizar futuras pesquisas do mesmo alias 
					aAdd( __aIdIndex , { cAliasTAF , nIdIndex } ) 
					Exit	 
				Endif 					
			Else			  
				//Se encontrar algum indice que o segundo campo da chave seja ID posso sair do la�o e utilizar este indice
				//Todas os indices onde o segundo campo � ID come�am com: "XXX_FILIAL+XXX" e depois "_ID" ( XXX_FILIAL+XXX_ID ). Por isso procuro da posicao 15 em diante
				If substr( SIX->CHAVE , nPosic , nTamFldId ) == cFieldId
					nIdIndex	:=	val( SIX->ORDEM )
					//Guardo este alias e chave no array est�tico para agilizar futuras pesquisas do mesmo alias
					aAdd( __aIdIndex , { cAliasTAF , nIdIndex } )
					Exit
				Endif
			Endif 
			SIX->( dbSkip() )
		Enddo
	Endif
	
	restArea( aAreaSIX )
	
Endif

Return nIdIndex

//---------------------------------------------------------------------
/*/{Protheus.doc} TafVldAmb
Fun��o tem como objetivo realizar a valida��o do dicion�rio de dados, verificando se o TAF
esta em uma vers�o compat�vel com a execu��o da integra��o Online.

Para a vers�o 12 essa fun��o n�o tem sentido pois sempre que utilizada a integra��o online
o dicion�rio do cliente estar� atualizado devido a execu��o do upddistr, por�m com a nova estrutura��o 
dos fontes o m�dulo SIGAFIS ir� possuir fontes �nicos (MATXFIS, por exemplo), assim devemos manter 
a fun��o para que na vers�o 12 sempre retorne .T., indicando que o dicion�rio est� atualizado.

@Author     Rodrigo Aguilar
@Since       10/10/2016
@Version    1.0

@param cEscopo   - Compatibilidade com a vers�o 11
       cIdentity - Compatibilidade com a vers�o 11 

@return .T. 

/*/
//---------------------------------------------------------------------
Function TafVldAmb( cEscopo , cIdentity )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} TafAmbInvMsg

Retorna mensagem padr�o informando que o ambiente TAF est� desatualizado.

@Return	cMensagem

@Author	Anderson Costa
@Since		01/12/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TafAmbInvMsg()

Local cEnter		
Local cMensagem	
Local cVersion	

cEnter		:=	Chr( 13 ) + Chr( 10 )
cMensagem	:=	""
cVersion	:=	SubStr( GetRpoRelease(), 1, 2 )

cMensagem := STR0001 + cEnter + cEnter //"Inconsist�ncia:"
cMensagem += STR0002 + cEnter + cEnter //"O ambiente do TAF est� com o dicion�rio de dados incompat�vel com a vers�o dos fontes existentes no reposit�rio de dados, este problema ocorre devido a n�o execu��o dos compatibilizadores do produto."

If cVersion == "11"
	cMensagem += STR0003 + cEnter + cEnter //"Ser� necess�rio executar o UPDDISTR e em seguida o UPDTAF com o �ltimo arquivo diferencial ( SDFBRA ) dispon�vel no portal do cliente."
ElseIf cVersion == "12"
	cMensagem += STR0007 + cEnter + cEnter //"Ser� necess�rio executar o UPDDISTR com o �ltimo arquivo diferencial ( SDFBRA ) dispon�vel no portal do cliente."
EndIf

cMensagem += STR0004 + cEnter //"Siga as instru��es do link abaixo para realizar a atualiza��o:"

If cVersion == "11"
	cMensagem += STR0005 + cEnter + cEnter //"http://tdn.totvs.com.br/pages/releaseview.action?pageId=187534210"
ElseIf cVersion == "12"
	cMensagem += STR0008 + cEnter + cEnter //"http://tdn.totvs.com.br/pages/releaseview.action?pageId=198935223"
EndIf

cMensagem += STR0006 + cEnter //"Ap�s seguir os passos acima o acesso ao TAF ser� liberado!"

Return( cMensagem )

//---------------------------------------------------------------------
/*/{Protheus.doc} TafLock
Fun��o criada para realizar a grava��o das tabelas do TAF, ou seja, em termos pr�ticos
ela substitui o RECLOCK(), realizando o controle de concorr�ncia de grava��o na tabela
que sera manutenida.

Conceito:

Grava��o sem lSimpleLock: O pr�prio Reclock() trava o usu�rio na tela dizendo que o registro a ser
alterado est� preso com outro usu�rio, a cada 5 segundos tenta novamente realizar a opera��o e assim
fica at� conseguir efetivar a opera��o.

Grava��o com lSimpleLock: S�o realizadas 5 tentativas de reservar o registro na tabela com simplelock(), tratar
o retorno como da fun��o para saber se o registro est� reservado ou n�o

@Author  Rodrigo Aguilar
@Since   11/11/2016
@Version 1.0

@param cAlias       - Alias a ser gravado/alterado
        lInclui      - .T. - Inclui/ .F. Altera/Exclui 
        lSimpleLock  - Indica se deve realizar o simplelock antes do reclock

@return .T. 

/*/
//---------------------------------------------------------------------
Function TafLock( cAlias, lInclui, lSimpleLock ) 

local lLock  := .F.
local nLock  := 0

//---------------------------------------------------
//Realizo a tentativa de reservar o registro 5 vezes
//---------------------------------------------------
for nLock := 1 to 5
	//Quando o processamento n�o possuir tela verifico com simplelock se conseguirei reservar o Alias
	//a ser reservado e se a opera��o � de Altera��o/Exclus�o	
	if lSimpleLock .and. !lInclui
		if ( lLock := ( cAlias )->( SimpleLock() ) )
			RecLock( cAlias , lInclui )
		endIf
	//Para grava��o em tela apenas realizo a opera��o desejada
	else
		RecLock( cAlias , lInclui )
		lLock := .T.
	endIf
	//Se nao conseguir fazer LOCK, aguarda um 1 segundo e tento de novo, esse tempo vai sendo exponencial a medida que for tentando.
	if !lLock
		Conout( 'TAF - Aguardando libera��o do registro ( concorrencia ) ' +  alltrim( str( nLock ) ) )
		Sleep( 1000 * nLock )
	else
		exit
	endIf
next nLock

Return lLock

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFObrVldEnv

Fun��o que valida o ambiente para gera��o da obriga��o fiscal

@param	aFields -> Campos que devem ser validados
@param	aTables -> Tabelas que devem ser validadas

@author Luccas Curcio
@since 21/11/2016
@version 1.0
/*/
//---------------------------------------------------------------------
function TAFObrVldEnv( aFields, aTables)

local	nX			
local	nOpc		
local	cCmpNoEx	
local	cTblNoEx	
local	cMsg		
local	lRet		

default	aFields	:=	{}
default	aTables	:=	{}

nX		:=	0
nOpc	:=	0
cCmpNoEx:=	""
cTblNoEx:=	""
lRet	:=	.T.
//"O sistema identificou a aus�ncia de componentes neste ambiente que influenciam no resultado final do processo.
//Para mais informa��es sobre a atualiza��o de ambiente acesse: 
//http://tdn.totvs.com/pages/viewpage.action?pageId=198935223."
cMsg := STR0009 + STR0008 + CRLF + CRLF

if !empty( aTables )

	for nX := 1 to len( aTables )
		
		//Verifico se a tabela existe no ambiente. Caso n�o exista adiciono na string que far� o alerta no final da fun��o.
		if !( tafAlsInDic( aTables[ nX ] ) )
			cTblNoEx += aTables[ nX ] + "(" + allTrim( FWX2Nome( aTables[ nX ] ) ) + "), "
		endif
	
	next nX
	
	if !empty( cTblNoEx )

		//Retiro ", " do final da string
		cTblNoEx := subStr( cTblNoEx , 1 , len( cTblNoEx ) - 2 )
	endif
	
	cMsg += STR0010 + CRLF + CRLF + cTblNoEx + CRLF + CRLF //"Tabelas:"

endif

if !empty( aFields )

	for nX := 1 to len( aFields )
		
		//Verifico se o campo existe no ambiente. Caso n�o exista adiciono na string que far� o alerta no final da fun��o.
		if !( tafColumnPos( aFields[ nX ] ) )
			cCmpNoEx += aFields[ nX ] + "(" + allTrim( FWX2Nome( subStr( aFields[ nX ] , 1 , 3 ) ) ) + "), "
		endif
	
	next nX
	
	if !empty( cCmpNoEx )
		//Retiro ", " do final da string
		cCmpNoEx := subStr( cCmpNoEx , 1 , len( cCmpNoEx ) - 2 )
	endif
	
	cMsg += STR0011 + CRLF + CRLF + cCmpNoEx + CRLF + CRLF //"Campos:"

endif

if !empty( cCmpNoEx ) .or. !empty( cTblNoEx )
	nOpc := tafAviso( STR0012 , cMsg  , { STR0013 , STR0014 } , 3 ) //"Ambiente desatualizado" ## "Continuar" ## "Encerrar"
endif

if nOpc == 2
	lRet :=	.F.
endif

return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} CboTpAdmiss()

Fun��o que retorna as op��es do CBO do evento S-2200

@author Ricardo Lovrenovic
@since 07/11/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Function CboTpAdmiss()

	Local cString := ""

	cString := "1=" + STR0015 + ";" 							// "Admiss�o"
	cString += "2=" + IIf(!lLaySimplif, STR0016, STR0180) + ";" // "Transfer�ncia de empresa do mesmo grupo econ�mico" // "Transfer�ncia de empresa do mesmo grupo econ�mico ou transfer�ncia entre �rg�os do mesmo Ente Federativo"
	cString += "3=" + STR0017 + ";" 							// "Transfer�ncia de empresa consorciada ou de cons�rcio"
	cString += "4=" + STR0018 + ";" 							// "Transfer�ncia por motivo de sucess�o, incorpora��o, cis�o ou fus�o"
	cString += "5=" + STR0019 + ";" 							// "Transfer�ncia do empregado dom�stico para outro representante da mesma unidade familiar"
	cString += "6=" + STR0083 + ";" 							// "Mudan�a de CPF"
	
	If lLaySimplif
		cString += "7=" + STR0181 + ";" 						// "Transfer�ncia quando a empresa sucedida � considerada inapta por inexist�ncia de fato"
	EndIf
	
Return cString

//---------------------------------------------------------------------
/*/{Protheus.doc} CboTpRegJ

Fun��o que retorna as op��es do CBO do evento S-2200 e S-2206
Campos: CUP_TPREGJ e T1V_TPREGJ
Tag: tpRegJor
Defini��o: Identifica o regime de jornada do empregado

@author Ricardo Lovrenovic / Felipe Rossi Moreira
@since 07/11/2017 / 21/11/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Function CboTpRegJ()
Local cString 

cString := "1="+STR0020+";" //"Submetidos a Hor�rio de Trabalho (Cap. II da CLT)"
cString += "2="+STR0021+";" //"Atividade Externa especificada no Inciso I do Art. 62 da CLT"
cString += "3="+STR0022+";" //"Fun��es especificadas no Inciso II do Art. 62 da CLT"
cString += "4="+STR0023 //"Teletrabalho, previsto no Inciso III do Art. 62 da CLT"

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} CbotpPgto

Fun��o que retorna as op��es do CBO do evento S-1210
Campos: T3Q_TPPGTO
Tag: tpPgto
Defini��o: Informar o tipo de pagamento

@author Felipe Rossi Moreira
@since 30/11/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Function CbotpPgto()
	Local cString 

	If !lLaySimplif

		cString := "1="+STR0024+";" // "Pagamento de remunera��o, conforme apurado em {dmDev} do S-1200"
		cString += "2="+STR0025+";" // "Pagamento de verbas rescis�rias conforme apurado em {dmDev} do S-2299"
		cString += "3="+STR0026+";" // "Pagamento de verbas rescis�rias conforme apurado em {dmDev} do S-2399"
		cString += "5="+STR0027+";" // "Pagamento de remunera��o conforme apurado em {dmDev} do S-1202"
		cString += "6="+STR0028+";" // "Pagamento de Benef�cios Previdenci�rios, conforme apurado em {dmDev} do S-1207"
		cString += "7="+STR0029+";" // "Recibo de f�rias"
		cString += "9="+STR0030 	// "Pagamento relativo a compet�ncias anteriores ao in�cio de obrigatoriedade dos eventos peri�dicos para o contribuinte"
	
	Else

		cString := "1="+STR0164+";" // "Pagamento de remunera��o, conforme apurado em {ideDmDev} do S-1200"
		cString += "2="+STR0165+";" // "Pagamento de verbas rescis�rias conforme apurado em {ideDmDev} do S-2299"
		cString += "3="+STR0166+";" // "Pagamento de verbas rescis�rias conforme apurado em {ideDmDev} do S-2399"
		cString += "4="+STR0167+";" // "Pagamento de remunera��o conforme apurado em {ideDmDev} do S-1202"
		cString += "5="+STR0168 	// "Pagamento de benef�cios previdenci�rios, conforme apurado em {ideDmDev} do S-1207"

	EndIf

Return cString

//---------------------------------------------------------------------
/*/{Protheus.doc} CboIndCum

Fun��o que retorna as op��es do CBO do evento S-2299
Campos: CMD_INDCUM
Tag: indCumprParc
Defini��o: Indicador de cumprimento de aviso pr�vio:

@author Felipe Rossi Moreira
@since 19/12/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Function CboIndCum()
Local cString 

cString := "0="+STR0031+";" //Cumprimento total
cString += "1="+STR0032+";" //Cumprimento parcial em raz�o de obten��o de novo emprego pelo empregado
cString += "2="+STR0033+";" //Cumprimento parcial por iniciativa do empregador
cString += "3="+STR0034+";" //Outras hip�teses de cumprimento parcial do aviso pr�vio
cString += "4="+STR0035		//Aviso pr�vio indenizado ou n�o exig�vel

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} CboCodAjus

Fun��o que retorna as op��es de combo do c�digo de ajuste 
Campos: T9T_CODAJU
Tag: CodAjuste
Defini��o: C�digo de Ajuste da contribui��o apurada no per�odo

@author anieli.rodrigues
@since 29/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Function CboCodAjus()
	
	Local cString 
	
	cString := "01="+STR0058+";" //Ajuste da CPRB: Ado��o do Regime de Caixa
	cString += "02="+STR0059+";" //Ajuste da CPRB: Diferimento de Valores a recolher no per�odo
	cString += "03="+STR0060+";" //Adi��o de valores Diferidos em Per�odo(s) Anteriores(es)
	cString += "04="+STR0061+";" //Exporta��es diretas
	cString += "05="+STR0062+";" //Transporte internacional de cargas
	cString += "06="+STR0063+";" //Vendas canceladas e os descontos incondicionais concedidos
	cString += "07="+STR0064+";" //IPI, se inclu�do na receita bruta
	cString += "08="+STR0065+";" //ICMS, quando cobrado pelo vendedor dos bens ou prestador dos servi�os na condi��o de substituto tribut�rio
	cString += "09="+STR0066+";" //Receita bruta reconhecida pela constru��o, recupera��o, reforma, amplia��o ou melhoramento da infraestrutura, cuja contrapartida seja ativo intang�vel representativo de direito de explora��o, no caso de contratos de concess�o de servi�os p�blicos
	cString += "10="+STR0067+";" //O valor do aporte de recursos realizado nos termos do art 6 �3 inciso III da Lei 11.079/2004
	cString += "11="+STR0068 //Demais ajustes oriundos da Legisla��o Tribut�ria, estorno ou outras situa��es.

Return(cString)


//---------------------------------------------------------------------
/*/{Protheus.doc} CboIndAqu

Fun��o que retorna as op��es de combo do indicativo de aquisi��o 
Campos: CMT_INDAQU
Tag: indAquis
Defini��o: Indicativo de aquisi��o de produto

@author ricardo.prandi	
@since 08/08/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Function CboIndAqu()
	
	Local cString 
	
	cString := "1="+STR0073+";" //Aquisi��o produtor rural PF
	cString += "2="+STR0074+";" //Aquisi��o produtor rural PF por entidade PAA
	cString += "3="+STR0075+";" //Aquisi��o produtor rural PJ por entidade PAA
	cString += "4="+STR0076+";" //Aquisi��o produtor rural PF - Produ��o Isenta (Lei 13.606/2018)
	cString += "5="+STR0077+";" //Aquisi��o produtor rural PF por entidade PAA - Produ��o Isenta (Lei 13.606/2018)
	cString += "6="+STR0078     //Aquisi��o produtor rural PJ por Entidade PAA - Produ��o Isenta (Lei 13.606/2018)

Return(cString)


//---------------------------------------------------------------------
/*/{Protheus.doc} CboOrdExa

Fun��o que retorna as op��es de combo da Ordem do Exame
Campos: C9W_ORDEXA
Tag: ordExame
Defini��o: Ordem do Exame

@author Karyna.martins
@since 10/01/2019
@version 1.0
/*/
//---------------------------------------------------------------------
Function CboOrdExa()
	
	Local cString 
	
	If __lLay0205
		cString := "1="+STR0082+";" //Inicial		
	Else
		cString := "1="+STR0080+";" //Referencial
	EndIf
	cString += "2="+STR0081+";" //Sequencial
	
	
Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFPic

Ajusta a picture vari�vel dos campos de per�odo dos totalizadores 5003 e 5013, alterandno entre o formato MM-AAAA e AAAA.

@author Leandro.dourado
@since 12/02/2019
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFPic( cCampo )
Local cRet   := ""
Local cValor := ""

If cCampo $ 'V2P_PERAPU|V2Z_PERAPU'
	cValor := StrTran(AllTrim(FWFLDGET(cCampo)),"-","")
	
	If Empty(cValor)
		cValor := AllTrim(&(SubStr(cCampo,1,3) + "->" + cCampo))
	EndIf
	
	cRet := IIF(Len(cValor) == 6, '@R 99-9999', '@R 9999')
EndIf

Return cRet

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} C9VHFil
Consulta Especifica de trabalhadores S-2190, S-2200,S-2205,S-2300 e TAUTO.

@author Henrique Cesar
@since 06/08/2019
@version 1.0

/*/       
//----------------------------------------------------------------------------------------------
Function C9VHFil(cEvtTrab as character, cEvento as character)

	Local aCoord		as array
	Local aWindow		as array
	Local aCols  		as array
	Local aColSizes 	as array
	Local aHeader   	as array
	Local cTitulo   	as character
	Local cQuery 		as character
	Local cAliasquery 	as character
	Local cFiltro		as character
	Local cNome			as character
	Local cCPF			as character
	Local cCall         as character
	Local cFil          as character
	Local lLGPDperm 	as logical
	Local lPerm 		as logical
	Local nX 			as numeric
	Local oListBox		as object
	Local oArea			as object
	Local oList			as object
	Local oButt1 		as object
	Local oButt2 		as object
	Local oButt3 		as object

	Default cEvtTrab 	:= ""
	Default cEvento		:= ""

	Private __cEvtPos	:= ""

	aCoord		:= {}
	aWindow		:= {}
	aCols  		:= {}
	aColSizes 	:= { 35, 80, 25, 15 }
	aHeader   	:= { "ID", "Nome", "CPF", "Evento" }
	cTitulo   	:= "" 
	cQuery 		:= ""
	cNome		:= ""
	cCPF		:= ""
	cAliasquery := GetNextAlias()
	cFiltro		:= Space(50)
	cCall       := "C9VHFil"
	cFil        := cFilant
	lLGPDperm 	:= IIf(FindFunction("PROTDATA"),ProtData(),.T.)
	lC9VDFil	:= IsInCallStack("C9VDFil")
	nX 			:= 0
	oListBox	:= Nil
	oArea		:= Nil
	oList		:= Nil
	oButt1 		:= Nil
	oButt2 		:= Nil
	oButt3 		:= Nil
	

	If Type("cNomEve") == "U" .Or. ValType(cNomEve) == "U"
		cEvento := IIf(IsInCallStack("TAFA413"), "S1202", IIF(IsInCallStack("TAFA608") .Or. IsInCallStack("TAF608Inc") , "S2500", ""))
	Else
		cEvento := cNomEve
	EndIf

	If Upper(ReadVar()) == 'CFILPERG01' .And. Type(ReadVar()) <> 'C'
		CFILPERG01 := Space(TamSX3('C9V_ID')[1])
	EndIf

	cRetNTrab := &(ReadVar())
	
	If Empty(cEvtTrab)
		
		cQuery := " SELECT C9V.C9V_FILIAL Filial, C9V.C9V_ID Id, C9V.C9V_NOME Nome, C9V.C9V_CPF CPF, C9V.C9V_NOMEVE AS EVENTO "
		cQuery += " FROM " + RetSQLName("C9V") + " C9V "
		cQuery += " WHERE C9V.D_E_L_E_T_ = ' ' AND C9V.C9V_FILIAL = '" + xFilial("C9V") + "' AND C9V.C9V_ATIVO = '1' "
		
		If cEvento $ "S1210|S2221|S2230|S2231|S2298|S2299|S2500|S2399" .Or. lC9VDFil
			If cEvento $ "S2231|S2298|S2299"
				cQuery += " AND C9V.C9V_NOMEVE = 'S2200' "
			ElseIf cEvento $ "S2399"
				cQuery += " AND C9V.C9V_NOMEVE = 'S2300' "
			Else
				cQuery += " AND C9V.C9V_NOMEVE <> 'TAUTO' "
			EndIf
		EndIf

		cQuery += " OR C9V.R_E_C_N_O_ IN ( "
		cQuery += " SELECT DISTINCT C9V.R_E_C_N_O_"
		cQuery += " FROM " + RetSQLName("C9V") + " C9V "
		cQuery += " INNER JOIN " + RetSQLName("T1U") + " T1U ON (T1U.T1U_FILIAL = C9V.C9V_FILIAL AND T1U.T1U_ID = C9V.C9V_ID) "
		cQuery += " WHERE T1U.D_E_L_E_T_ = ' ') "

		If !cEvento $ "S1200|S1210"
			If cEvento $ "S2298"
				cQuery += " AND (EXISTS (SELECT CUP.CUP_DTDESL "
				cQuery += "	FROM " + RetSQLName("CUP") + " CUP "
				cQuery += "	WHERE CUP.CUP_FILIAL = C9V.C9V_FILIAL AND CUP.CUP_ID = C9V.C9V_ID AND CUP.CUP_VERSAO = C9V.C9V_VERSAO AND CUP.D_E_L_E_T_ = ' ' AND CUP.CUP_DTDESL <> ' ') "

				cQuery += " OR EXISTS "
			Else
				cQuery += " AND (NOT EXISTS "
			EndIf

			cQuery += " (SELECT CMD.CMD_FUNC "
			cQuery += "	FROM " + RetSQLName("CMD") + " CMD "
			cQuery += "	WHERE CMD.CMD_FILIAL = C9V.C9V_FILIAL AND CMD.CMD_FUNC = C9V.C9V_ID AND CMD.CMD_ATIVO = '1' AND CMD.D_E_L_E_T_ = ' ' )) "
		EndIf	

		cQuery += " UNION "
		cQuery += " SELECT T1U.T1U_FILIAL FILIAL, T1U.T1U_ID ID, T1U.T1U_NOME NOME, T1U.T1U_CPF CPF, C9V.C9V_NOMEVE AS EVENTO "
		cQuery += " FROM " + RetSQLName("T1U") + " T1U "
		cQuery += " INNER JOIN " + RetSQLName("C9V") +  " C9V "  
		cQuery += " ON C9V.C9V_FILIAL = T1U.T1U_FILIAL AND C9V.C9V_ID = T1U.T1U_ID AND C9V.D_E_L_E_T_ = ' '
		
		If cEvento $ "S2231|S2299"
			cQuery += " AND C9V.C9V_NOMEVE = 'S2200' "
		EndIf

		If cEvento $ "S2399"
			cQuery += " AND C9V.C9V_NOMEVE = 'S2300' "
		EndIf

		cQuery += " WHERE T1U.D_E_L_E_T_ = ' ' AND T1U.T1U_FILIAL = '" + xFilial("T1U") + "' AND T1U.T1U_ATIVO = '1'  AND T1U.T1U_DTALT = (SELECT MAX(CPF.T1U_DTALT) FROM " + RetSQLName("T1U") + " CPF WHERE T1U.T1U_CPF = CPF.T1U_CPF ) "

		If lLaySimplif .And. !cEvento $ "S1202|S2500"
			If (cEvento $ "S1210|S2230" .Or. lC9VDFil) .And. !cEvento $ "S2231|S2298|S2299|S2399"
				cQuery += " UNION "
				cQuery += " SELECT V73.V73_FILIAL Filial, V73.V73_ID Id, V73.V73_NOMEB Nome, V73.V73_CPFBEN CPF, V73.V73_NOMEVE EVENTO "
				cQuery += " FROM " + RetSQLName("V73") + " V73 "
				cQuery += " WHERE V73.D_E_L_E_T_ = ' ' AND V73.V73_FILIAL = '" + xFilial("V73") + "' AND V73.V73_ATIVO = '1'  "
				cQuery += " AND V73.V73_NOMEVE <> 'S2405' "

				cTitulo := STR0185 // "Consulta Benefici�rio - S-2190/S-2200/S-2300/S-2400"
			ElseIf cEvento $ "S2298"
				cTitulo := STR0212 // "Consulta Trabalhador Com V�nculo Desligado - S-2200"
			ElseIf cEvento $ "S2231|S2299"
				cTitulo := STR0211 // "Consulta Trabalhador Com V�nculo - S-2200"
			ElseIf cEvento $ "S2399"
				cTitulo := STR0210 // "Consulta Trabalhador Sem V�nculo - S-2300"
			Else
				cTitulo := STR0186 // "Consulta Trabalhador Com/Sem V�nculo - S-2190/S-2200/S-2300/Aut�nomo"
			EndIf

			If !cEvento $ "S2231|S2298|S2299|S2399"
				cQuery += " UNION "
				cQuery += " SELECT T3A.T3A_FILIAL Filial, T3A.T3A_ID Id, 'TRABALHADOR PRELIMINAR' Nome, T3A.T3A_CPF CPF, 'S2190' EVENTO "
				cQuery += " FROM " + RetSQLName("T3A") + " T3A "
				cQuery += " WHERE T3A.D_E_L_E_T_ = ' ' AND T3A.T3A_FILIAL = '" + xFilial("T3A") + "' AND T3A.T3A_ATIVO = '1' AND T3A.T3A_EVENTO <> 'E' "
				cQuery += " AND NOT EXISTS ( "
				cQuery += " SELECT C9V.C9V_ID " 
				cQuery += " FROM " + RetSQLName("C9V") + " C9V "
				cQuery += " INNER JOIN " + RetSQLName("CUP") + " CUP "
				cQuery += " ON CUP.D_E_L_E_T_ = ' ' AND CUP.CUP_ID = C9V.C9V_ID AND CUP.CUP_VERSAO = C9V.C9V_VERSAO "
				cQuery += " WHERE C9V.D_E_L_E_T_ = ' ' AND C9V.C9V_ATIVO = '1' AND C9V.C9V_CPF = T3A.T3A_CPF AND C9V.C9V_MATRIC = T3A.T3A_MATRIC AND (C9V.C9V_CATCI = T3A.T3A_CODCAT OR CUP.CUP_CODCAT = T3A.T3A_CODCAT)) "
			EndIf
		Else
			If (cEvento $ "S1210|S2221|S2230|S2231|S2299" .Or. lC9VDFil) .And. !cEvento $ "S2298"
				cTitulo := STR0187 // "Consulta Benefici�rio - S-2200/S-2300"
			ElseIf cEvento $ "S2298"
				cTitulo := STR0212 // "Consulta Trabalhador Com V�nculo Desligado - S-2200"
			ElseIf cEvento $ "S2500"
				cTitulo := STR0208 // "Consulta Trabalhador Com/Sem V�nculo - S-2200/S-2300"
			ElseIf cEvento $ "S2399"
				cTitulo := STR0210 // "Consulta Trabalhador Sem V�nculo - S-2300"
			Else
				cTitulo := STR0188 // "Consulta Trabalhador Com/Sem V�nculo - S-2200/S-2300/Aut�nomo"
			EndIf
		EndIf

	ElseIf cEvtTrab == "TAUTO"

		cTitulo   := "Consulta Trabalhador Aut�nomo" 
	
		cQuery := " SELECT C9V_FILIAL FILIAL, C9V_ID ID, C9V_NOME NOME, C9V_CPF CPF, C9V_NOMEVE AS EVENTO "
		cQuery += " FROM "+RetSQLName("C9V")+" C9V "
		cQuery += " WHERE C9V.D_E_L_E_T_ = ' ' AND C9V.C9V_FILIAL = '" + xFilial("C9V") + "' AND C9V.C9V_ATIVO = '1' AND C9V.C9V_NOMEVE = 'TAUTO' "

	ElseIf cEvtTrab $ "ORIEVE"
		
		If lLaySimplif .And. !cEvento $ "S1202"
			cTitulo   := "Consulta Trabalhador Com/Sem V�nculo - S2190/S2200/S2300/Aut�nomo" 
		Else
			cTitulo   := "Consulta Trabalhador Com/Sem V�nculo - S2200/S2300/Aut�nomo" 
		EndIf

		If M->C91_ORIEVE $ "S2190"	
			cQuery += " SELECT T3A_FILIAL Filial, T3A_ID Id, 'TRABALHADOR PRELIMINAR' AS Nome, T3A_CPF CPF, 'S2190' as EVENTO "
			cQuery += " FROM "+RetSQLName("T3A")+" T3A "
			cQuery += " WHERE T3A.D_E_L_E_T_ = ' ' AND T3A_FILIAL = '" + xFilial("T3A") + "' AND T3A.T3A_ATIVO = '1' AND T3A.T3A_EVENTO <> 'E' AND T3A.T3A_CPF = '"+ substr(M->C91_DTRABA,1,At(' ',M->C91_DTRABA)-1) + "'"
		Else
			cQuery := " SELECT C9V_FILIAL FILIAL, C9V_ID ID, C9V_NOME NOME, C9V_CPF CPF, C9V_NOMEVE AS EVENTO "
			cQuery += " FROM "+RetSQLName("C9V")+" C9V "
			cQuery += " WHERE C9V.D_E_L_E_T_ = ' ' AND C9V.C9V_FILIAL = '" + xFilial("C9V") + "' AND C9V.C9V_ATIVO = '1' AND  C9V.C9V_CPF = '"+ substr(M->C91_DTRABA,1,At(' ',M->C91_DTRABA)-1) + "'"
		EndIf

	ElseIf cEvtTrab $ "SST|ORGPBL"

		cTitulo   := "Consulta Trabalhador Com/Sem V�nculo (2190/2200/2300/TAUTO) e Trabalhador Preliminar"

	
		cQuery := " SELECT C9V_FILIAL Filial, C9V_ID Id, C9V_NOME Nome, C9V_CPF CPF, C9V_NOMEVE AS EVENTO "
		cQuery += " FROM "+RetSQLName("C9V")+" C9V "
		cQuery += " WHERE C9V.D_E_L_E_T_ = ' ' AND C9V_FILIAL = '" + xFilial("C9V") + "' AND C9V.C9V_ATIVO = '1' OR C9V.R_E_C_N_O_ IN ("
		cQuery += " SELECT DISTINCT C9V.R_E_C_N_O_"
		cQuery += " FROM "+RetSQLName("C9V")+" C9V "
		cQuery += " INNER JOIN "+RetSQLName("T1U")+" T1U ON (T1U.T1U_FILIAL = C9V.C9V_FILIAL AND T1U.T1U_ID = C9V.C9V_ID) "
		cQuery += " WHERE T1U.D_E_L_E_T_ = '') "
		cQuery += " AND NOT EXISTS (SELECT CMD.CMD_FUNC "
		cQuery += "	FROM " + RetSQLName("CMD") + " CMD "
		cQuery += "	WHERE CMD.CMD_FILIAL =  C9V.C9V_FILIAL AND CMD.CMD_FUNC = C9V.C9V_ID AND CMD.CMD_ATIVO = '1' AND CMD.D_E_L_E_T_ = '' ) "
		cQuery += " UNION "
		cQuery += " SELECT T1U_FILIAL FILIAL,T1U_ID ID,T1U_NOME NOME,T1U_CPF CPF, C9V_NOMEVE AS EVENTO "
		cQuery += " FROM " + RetSQLName("T1U") + " T1U "
		cQuery += " INNER JOIN " + RetSQLName("C9V") +  " C9V "  
		cQuery += " ON C9V.C9V_FILIAL = T1U.T1U_FILIAL AND C9V.C9V_ID = T1U.T1U_ID AND C9V.D_E_L_E_T_ = ''
		cQuery += " WHERE  T1U.D_E_L_E_T_ = ' ' AND T1U_FILIAL = '" + xFilial("T1U") + "' AND T1U.T1U_ATIVO = '1'  AND T1U_DTALT = (SELECT MAX(T1U_DTALT) FROM "+RetSQLName("T1U")+" CPF WHERE T1U.T1U_CPF = CPF.T1U_CPF AND T1U.D_E_L_E_T_ = '')

		If cEvtTrab == "SST"
			cQuery += " AND C9V.C9V_NOMEVE IN ('S2200', 'S2300') "
			cQuery += " UNION "
			cQuery += " SELECT T3A_FILIAL FILIAL, T3A_ID ID, 'TRABALHADOR PRELIMINAR' AS NOME, T3A_CPF CPF, 'S2190' AS EVENTO "
			cQuery += " FROM "+RetSQLName("T3A")+" T3A "
			cQuery += " WHERE T3A.D_E_L_E_T_ = '' " 
			cQuery += " AND T3A_FILIAL = '" + xFilial("T3A") + "' " 
			cQuery += " AND T3A.T3A_ATIVO = '1' " 
			cQuery += " AND T3A.T3A_EVENTO <> 'E' "
			cQuery += " AND NOT EXISTS ( "
			cQuery += " SELECT C9V.C9V_ID " 
			cQuery += " FROM " + RetSQLName("C9V") + " C9V "
			cQuery += " INNER JOIN " + RetSQLName("CUP") + " CUP "
			cQuery += " ON CUP.D_E_L_E_T_ = ' ' AND CUP.CUP_ID = C9V.C9V_ID AND CUP.CUP_VERSAO = C9V.C9V_VERSAO "
			cQuery += " WHERE C9V.D_E_L_E_T_ = ' ' AND C9V.C9V_ATIVO = '1' AND C9V.C9V_CPF = T3A.T3A_CPF AND C9V.C9V_MATRIC = T3A.T3A_MATRIC AND (C9V.C9V_CATCI = T3A.T3A_CODCAT OR CUP.CUP_CODCAT = T3A.T3A_CODCAT)) "		
		ElseIf cEvtTrab == "ORGPBL"
			cQuery += " AND C9V.C9V_NOMEVE IN ('S2200') "
		EndIf	 		                                                                                                                                                                        

	EndIf
	
	cQuery := ChangeQuery(cQuery)
	
	QueenWindow(cQuery , cTitulo, , cCall, cEvento, cFil )

Return .T.

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosNTrab
Fun��o para retornar o registro na consulta especifica SXB.
do trabalhador.

@author Henrique Cesar
@since 08/08/2019
@version 1.0

/*/       
//----------------------------------------------------------------------------------------------
//
Function PosNTrab()

Return (cRetNTrab)


//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosicTrab
Fun��o responsavel por realizar o posicionamento no registro selecionado na consulta do trabalhador.

@author Henrique Cesar
@since 06/08/2019
@version 1.0

/*/       
//----------------------------------------------------------------------------------------------

Static Function PosicTrab(cIdTrab as character, cTipo as character, cEvent as character, cFil as character)

	Local aButtons as array 
	Local aEvent   as array
	Local lExec    as logical

	Default cIdTrab:= ""
	Default cTipo  := ""	
	Default cEvent := ""
	Default cFil   := ""

	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	lExec    := .T.
	cRetNTrab := ""

	DbSelectArea("C9V")

	C9V->( DbSetOrder( 1 ) )
	T3A->( DbSetOrder( 3 ) )
    
	If C9V->( DBSeek(xFilial("C9V", cFil )+ cIdTrab)) .AND. (cEvent $ "S2200|S2300|S2205|TAUTO")
		cRetNTrab := C9V->C9V_ID		
	ElseIf cEvent == "S2190" .AND. T3A->( DBSeek(xFilial("T3A", cFil )+ cIdTrab + "1"))
		cRetNTrab := T3A->T3A_ID	
	ElseIf cEvent $ "S2400|S2405"
		V73->( DbSetOrder( 1 ) )
		V73->( DBSeek(xFilial("V73", cFil )+ cIdTrab)) 
		cRetNTrab := V73->V73_ID	
	EndIf
	// Grava o evento	
	cEvtPosic	:= cEvent
	aEvent      := TAFRotinas(strtran(cEvent,"S","S-"),4,.F.,2)

	lExec := MPUserHasAccess(aEvent[20], 1, RetCodUsr())
	
	If cTipo == "1" .AND. lExec

		FWExecView("", aEvent[1], MODEL_OPERATION_VIEW, , { || .T. }, , ,aButtons )
		cRetNTrab := ""

	ElseIf cTipo == "1" .AND. !lExec
		msgAlert(STR0218,STR0219)
	EndIf

Return()

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckFilF
Fun��o responsavel por realizar a pesquisa por Nome e/ou CPF do trabalhador.

@author Henrique Cesar
@since 06/08/2019
@version 1.0

/*/       
//----------------------------------------------------------------------------------------------

Static Function CheckFilF(oListBox,cFiltro)

	Local nPos  	 := 0
	Local lRet  	 := .F.
	Local ni		 := 1
	Local lPosPesq	 := .F.
	Local lCPF 		 := .F.
	Default oListBox := Nil
	Default cFiltro	 := ""

	cFiltro := AllTrim(cFiltro)

	// Faz um scan no objeto para encontrar a posi��o e posicionar no browser
	If Valtype(cFiltro) = "C" .And. !Empty(cFiltro)
		nPos := aScan( oListBox:aArray, {|x| x[2] == cFiltro } )
		If nPos == 0
			nPos := aScan( oListBox:aArray, {|x| x[3] == cFiltro } )
			lCPF := .T.
		EndIf

		If nPos > 0
			oListBox:GoPosition(nPos)
			oListBox:Refresh()
			lRet  := .T.
		EndIf

		// Pesquisa parcial
		If !lRet .and. lCPF
			For ni := 1 to Len(oListBox:aArray)
				lPosPesq := cFiltro $ oListBox:aArray[ni][2]
				If lPosPesq
					Exit
				EndIf
			Next ni
			If lPosPesq
				oListBox:GoPosition(ni)
				oListBox:Refresh()
			EndIf
		EndIf
	EndIf

	If nPos == 0 .And. !lPosPesq
		MsgAlert("N�o foi poss�vel encontrar o trabalhador " + cFiltro + " na pesquisa.")
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} codIncFGTS

Fun��o que retorna as op��es de combo do c�digo de ajuste 
Campos: C8R_CINTFG
Tag: codIncFGTS
Defini��o: C�digo de Ajuste da contribui��o apurada no per�odo

@author jose.riquelmo
@since 13/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function codIncFGTS()
	
	Local cString := ""
		
	If !lLaySimplif
		cString := "00="+STR0084+";" //N�o � Base de C�lculo do FGTS
		cString += "11="+STR0098+";" //Base de c�lculo do FGTS.
		cString += "12="+STR0086+";" //Base C�lculo 13�
		cString += "21="+STR0099+";" //Base de C�lculo do FGTS Rescis�rio (aviso pr�vio).
		cString += "91="+STR0100     //Incid�ncia suspensa em decorr�ncia de decis�o judicial.
	Else
		cString := "00="+STR0084+";" //N�o � Base de C�lculo do FGTS
		cString += "11="+STR0085+";" //Base de c�lculo do FGTS mensal.
		cString += "12="+STR0086+";" //Base C�lculo 13�
		cString += "21="+STR0087+";" //Base de c�lculo do FGTS aviso pr�vio indenizado.
		cString += "91="+STR0088+";" //Incid�ncia suspensa em decorr�ncia de decis�o judicial - FGTS mensal
		cString += "92="+STR0089+";" //Incid�ncia suspensa em decorr�ncia de decis�o judicial - FGTS 13� sal�rio
		cString += "93="+STR0090     //Incid�ncia suspensa em decorr�ncia de decis�o judicial - FGTS aviso pr�vio indenizado
	EndIf 
	
Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} codIncCPRP

Fun��o que retorna as op��es de combo do c�digo de ajuste 
Campos: C8R_CICPRP 
Tag: codIncCPRP
Defini��o: C�digo de Ajuste da contribui��o apurada no per�odo

@author jose.riquelmo
@since 13/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function codIncCPRP()
	
	Local cString := ""
	
	cString := "00="+STR0091+";" //N�o � base de c�lculo de contribui��es devidas ao RPPS/regime militar
	cString += "11="+STR0092+";" //Base de c�lculo de contribui��es devidas ao RPPS/regime militar
	cString += "12="+STR0093+";" //Base de c�lculo de contribui��es devidas ao RPPS/regime militar - 13� sal�rio
	cString += "31="+STR0094+";" //Contribui��o descontada do segurado e benefici�rio
	cString += "32="+STR0095+";" //Contribui��o descontada do segurado e benefici�rio - 13� sal�rio
	cString += "91="+STR0096+";" //Suspens�o de incid�ncia em decorr�ncia de decis�o judicial
	cString += "92="+STR0184     //Suspens�o de incid�ncia em decorr�ncia de decis�o judicial - 13� sal�rio

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} CondIng

Fun��o que retorna as op��es de combo do c�digo de ajuste 
Campos: C9V_CNDING 
Tag: CondIng
Defini��o: Condi��o de ingresso do trabalhador imigrante. 

@author Karyna Martins
@since 19/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function CondIng()
	
Local cString := ""

	cString := "1="+STR0101+";" // Refugiado
	cString += "2="+STR0102+";" // Solicitante de ref�gio
	cString += "3="+STR0103+";" // Perman�ncia no Brasil em raz�o de reuni�o familiar 
	cString += "4="+STR0104+";" // Beneficiado pelo acordo entre pa�ses do Mercosul
	cString += "5="+STR0105+";" // Dependente de agente diplom�tico e/ou consular de pa�ses que mant�m acordo de reciprocidade para o exerc�cio de atividade remunerada no Brasil 
	cString += "6="+STR0106+";" // Beneficiado pelo Tratado de Amizade, Coopera��o e Consulta entre a Rep�blica Federativa do Brasil e a Rep�blica Portuguesa 
	cString += "7="+STR0107 	// Outra condi��o

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} ctpProv

Fun��o que retorna as op��es de combo do c�digo de ajuste 
Campos: TIPPRO 
Tag: tpProv

@author jose.riquelmo
@since 26/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function cTpProv()
	
	Local cString as character

	If !lLaySimplif
		
		cString := "1="+STR0123+";" //Nomea��o em cargo efetivo 
		cString += "2="+STR0124+";" //Nomea��o em cargo em comiss�o 
		cString += "3="+STR0125+";" //Incorpora��o (militar)
		cString += "4="+STR0126+";" //Matr�cula (militar); 
		cString += "5="+STR0127+";" //Reinclus�o (militar)
		cString += "6="+STR0128+";" //Diploma��o	
		cString += "99="+STR0129    //Outros n�o relacionados acima 

	Else 
		
		cString := "1=" + STR0123 + ";" 	// Nomea��o em cargo efetivo 
		cString += "2=" + STR0140 + ";" 	// Nomea��o exclusivamente em cargo em comiss�o 
		cString += "3=" + STR0141 + ";" 	// Incorpora��o ou matr�cula (militar)
		cString += "5=" + STR0183 + ";" 	// Redistribui��o ou Reforma Administrativa
		cString += "6=" + STR0128 + ";" 	// Diploma��o
		cString += "7=" + STR0130 + ";" 	// Contrata��o por tempo determinado 
		cString += "8=" + STR0131 + ";" 	// Remo��o (em caso de altera��o do �rg�o declarante)
		cString += "9=" + STR0132 + ";" 	// Designa��o 
		cString += "10=" + STR0133 + ";"	// Mudan�a de CPF
		cString += "11=" + STR0182 + ";"	// Estabilizados - Art. 19 do ADCT 	
		cString += "99=" + STR0129 + ";"	// Outros n�o relacionados acima 
	
	EndIf 

Return cString

//---------------------------------------------------------------------
/*/{Protheus.doc} tpJornada

Fun��o que retorna as op��es de combo do c�digo de ajuste 
Campos: CUP_TPJORN/T1V_TPJORN
Tag: CondIng
Defini��o: Condi��o de ingresso do trabalhador imigrante. 

@author Silas Gomes
@since 19/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function tpJornada()

	Local cString := ""

	If !lLaySimplif // 2.5
		cString := "1="+STR0112+";" // Jornada com hor�rio di�rio e folga fixos.
		cString += "2="+STR0113+";" // Jornada 12 x 36 (12 horas de trabalho seguidas de 36 horas ininterruptas de descanso).
		cString += "3="+STR0114+";" // Jornada com hor�rio di�rio fixo e folga vari�vel.
		cString += "9="+STR0115+";" // Demais tipos de jornada.
	Else
		cString := "2="+STR0116+";" // Jornada 12 x 36 (12 horas de trabalho seguidas de 36 horas ininterruptas de descanso)
		cString += "3="+STR0117+";" // Jornada com hor�rio di�rio fixo e folga vari�vel.
		cString += "4="+STR0118+";" // Jornada com hor�rio di�rio fixo e folga fixa (no domingo).
		cString += "5="+STR0119+";" // Jornada com hor�rio di�rio fixo e folga fixa (exceto no domingo).
		cString += "6="+STR0120+";" // Jornada com hor�rio di�rio fixo e folga fixa (em outro dia da semana), com folga adicional peri�dica no domingo.
		cString += "7="+STR0121+";" // Turno ininterrupto de revezamento.
		cString += "9="+STR0122+";" // Demais tipos de jornada.
	EndIf

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} tpPlanRP

Fun��o que retorna as op��es de combo do c�digo de ajuste 
Campos: CUP_TPLASM /T1V_TPLASM
Tag: tpPlanRP
Defini��o: Condi��o de ingresso do trabalhador imigrante. 

@author Karyna Martins
@since 19/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function tpPlanRP()

	Local cString := ""

	If !lLaySimplif // 2.5
		cString := "1="+STR0109+";" // Plano previdenci�rio ou �nico
		cString += "2="+STR0110+";" // Plano financeiro
	Else
		cString := "0="+STR0108+";" // Sem segrega��o da massa
		cString += "1="+STR0134+";" // Fundo em capitaliza��o
		cString += "2="+STR0135+";" // Fundo em reparti��o
		cString += "3="+STR0111+";" // Mantido pelo Tesouro
	EndIf

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} tpProc

Fun��o que retorna as op��es de combo do c�digo de ajuste 
Campos: C1G_TPPROC
Tag: tpProc
Defini��o: Condi��o de ingresso do trabalhador imigrante. 

@author Karyna Martins
@since 19/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function tpProc()

	Local cString := ""
	
	cString := "1="+STR0137+";" // Judicial - Tem que ser invertido com o administrativo devido a ser compartilhado com o fiscal, � ajustado na gera��o do XML
	cString += "2="+STR0136+";" // Administrativo - Tem que ser invertido com o judicial devido a ser compartilhado com o fiscal, � ajustado na gera��o do XML
	
	If !lLaySimplif // 2.5
		cString += "3="+STR0138+";" // N�mero de Benef�cio (NB) do INSS
	EndIf

	cString += "4="+STR0139+";" // Processo FAP de exerc�cio anterior a 2019		
	
Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} tpProc

Fun��o que retorna as op��es de combo do c�digo de ajuste 
Campos: T3A_UNSLFX
Tag: tpProc
Defini��o: Condi��o de ingresso do trabalhador imigrante. 

@author Rodrigo Nicolino
@since 19/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function tpUnidSal()

	Local cString := ""

	If lLaySimplif // Simplificado
			
		cString := "1="+STR0143+";" // Por hora
		cString += "2="+STR0144+";" // Por dia
		cString += "3="+STR0145+";" // Por semana
		cString += "4="+STR0146+";" // Por quinzena
		cString += "5="+STR0147+";" // Por m�s
		cString += "6="+STR0148+";" // Por tarefa
		cString += "7="+STR0149+";" // N�o aplic�vel - Sal�rio exclusivamente vari�vel

	EndIf

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} tpRegPrev

Fun��o que retorna as op��es de combo do c�digo de ajuste 
Campos: CUU_TPRPRE
Tag: tpRegPrev
Defini��o: Condi��o de ingresso do trabalhador imigrante. 

@author Karyna Martins
@since 19/01/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function tpRegPrev(cCampo as character)

	Local cString 			as character
	Local lExibeOpcPadrao  	as Logical

	Default  cCampo 		:=  ""

	lExibeOpcPadrao  := !(ValType(cCampo) != 'U' .and. cCampo $ "CUP_TPREGP|T1V_TPREGP|CUU_TPREGP|T0F_TPREGP")

	If lExibeOpcPadrao
		cString := "1="+STR0150+";" // Regime Geral de Previd�ncia Social - RGPS 
		cString += "2="+STR0151+";"	// Regime Pr�prio de Previd�ncia Social - RPPS ou Sistema de Prote��o Social dos Militares 
		cString += "3="+STR0152+";"	// Regime de Previd�ncia Social no exterior 
	Else 		
		cString := "1="+STR0150+";" // Regime Geral de Previd�ncia Social - RGPS 
		cString += "2="+STR0151+";"	// Regime Pr�prio de Previd�ncia Social - RPPS ou Sistema de Prote��o Social dos Militares 
		cString += "3="+STR0152+";"	// Regime de Previd�ncia Social no exterior 
		cString += "4="+STR0225+";"	// Sistema de Prote��o Social dos Militares das For�as Armadas - SPSMFA 
	EndIf

Return(cString)


//---------------------------------------------------------------------
/*/{Protheus.doc} tpTrib

Fun��o que retorna as op��es de combo do c�digo de ajuste 
Campos: T3H_TPTRIB
Tag: tpTrib
Defini��o: Tipo tributo/Contribui��o. 

@author Bruno de Oliveira
@since 05/02/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function tpTrib()

	Local cString := ""

	If !lLaySimplif // 2.5
		cString := "1="+STR0153+";" // IRRF
		cString += "2="+STR0154+";" // Contribui��es sociais do trabalhador
		cString += "3="+STR0155+";" // FGTS
		cString += "4="+STR0156+";" // Contruibui��o Sindical		
	Else		
		cString := "1="+STR0153+";" // IRRF
		cString += "2="+STR0154+";" // Contribui��es sociais do trabalhador
	EndIf

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} ComTpCon

Fun��o que retorna as op��es de combo do c�digo de ajuste 
Campos: V6I_TPCON
Tag: ComTpCon
Defini��o: Tipo tributo/Contribui��o. 

@author Jos� Riquelmo
@since 23/02/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function ComTpCon()

	Local cString as character

	cString := "A="+STR0157+";" // Acordo Coletivo de Trabalho  
	cString += "B="+STR0158+";" // Legisla��o federal, estadual, municipal ou distrital 
	cString += "C="+STR0159+";" // Conven��o Coletiva de Trabalho 
	cString += "D="+STR0160+";" // Senten�a normativa - Diss�dio 			
	cString += "E="+STR0161+";" // Convers�o de licen�a sa�de em acidente de trabalho 
	cString += "F="+STR0162+";" // Outras verbas de natureza salarial ou n�o salarial devidas ap�s o desligamento 
	cString += "G="+STR0163+";" // Antecipa��o de diferen�as de acordo, conven��o ou diss�dio coletivo 
	cString += "H="+STR0169+";"	// Recolhimento mensal de FGTS anterior ao in�cio de obrigatoriedade dos eventos peri�dicos
	cString += "I="+STR0224+";"	// Senten�a judicial (exceto reclamat�ria trabalhista)
	
Return (cString)
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GatMatC91
Cria��o da trigger
@author  Alexandre lima S.
@since   08/03/2021
@version 1
/*/
//-------------------------------------------------------------------
Function GatMatC91(cAlias as character, cIdFunc as character)

	Local cRet 			as character
	Local cEvent		as character

	Default cAlias 		:= ""
	Default cIdFunc 	:= ""

	cRet	:= ""
	cEvent 	:= IIf(Type("cEvtPosic") == "U" .Or. ValType(cEvtPosic) == "U", "", cEvtPosic)

	If Empty(cEvent) .AND. ALLTRIM(FunName()) == "TAFA549"
		cEvent := C9V->C9V_NOMEVE
	EndIf

	If cAlias == "C91"	

		If !Empty(cEvent) .AND. (INCLUI .OR. ALTERA)
			FWFldPut(cAlias +"_ORIEVE", cEvent)
		Else
			cEvent := C91->C91_ORIEVE
		EndIf

			If	cEvent == 'S2190'
				cNome := "TRABALHADOR PRELIMINAR"
				cCPF  := Posicione("T3A", 3, xFilial("T3A")  + cIdFunc + "1", "T3A_CPF")
				cRet  := cCPF + " - " + cNome
			
			ElseIf cEvent == 'S2200'
				cNome := Posicione("T1U", 2, xFilial("T1U")  + cIdFunc + "1", "T1U_NOME")
				cCPF  := T1U->T1U_CPF
				cRet  := cCPF + " - " + cNome
			Else
				cNome := Posicione("T1V", 2, xFilial("T1V")  + cIdFunc + "1", "T1V_NOME")
				cCPF  := T1V->T1V_CPF
				cRet  := cCPF + " - " + cNome
			EndIf

			If Empty(cNome) .OR. Empty(cCPF)
				cNome := Posicione("C9V", 2, xFilial("C9V") + cIdFunc + "1", "C9V_NOME")
				cCPF  := C9V->C9V_CPF
				cRet  := cCPF + " - " + cNome
			EndIf

	ElseIf cEvent == "S2190"
		If INCLUI .OR. ALTERA
			FWFldPut(cAlias +"_NOMEVE", cEvent)
		EndIf
		cIdFunc := T3A->T3A_ID 
		T3A->( DBSetOrder(3) )
		If T3A->(dbseek(xFilial("T3A") + cIdFunc + "1"))
			cRet := Alltrim(T3A->T3A_MATRIC)
		EndIf

	Else
		If INCLUI .OR. ALTERA
			FWFldPut(cAlias +"_NOMEVE", cEvent)
		EndIf

		If Empty(cIdFunc)
			cIdFunc := C9V->C9V_ID
		EndIf

		C9V->(DBSetOrder(2))

		If C9V->(dbseek(xFilial("C9V") + cIdFunc + "1"))
			If  cEvent == "S2200"
				cRet := Alltrim(C9V->C9V_MATRIC)
			Else
				cRet := AllTrim(C9V->C9V_MATTSV)    
			EndIf
		EndIf
	EndIf

	cEvtPosic := ""

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} tpisnc

Fun��o que retorna as op��es de combo do c�digo de ajuste 
Campos: C9K_TPINSC
Tag: tpisnc
Defini��o: Tipo de inscri��o. 

@author Karyna Martins
@since 18/03/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function tpisnc()

	Local cString := ""

	cString := "1=CNPJ;" 
	If !lLaySimplif
		cString += "2=CPF;"
	EndIf
	cString += "3=CAEPF;"
	cString += "4=CNO;" 
	

Return(cString)

//---------------------------------------------------------------------
/*/{Protheus.doc} VrfPatch

Fun��o que retorna as op��es de combo do c�digo de ajuste 
Campos: C9K_TPINSC
Tag: VrfPatch
Defini��o: Verifica Patch. 

@author Karyna Martins
@since 18/03/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function VrfPatch()

Local cRet:= ""

If lLaySimplif
	cRet:= GatMatC91("C91", M->C91_TRABAL)
Else
	cRet:= TAFNMTRAB(XFILIAL("C9V"),M->C91_TRABAL)  
EndIf

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GatMatSST

Gatilho para considerar C9V quando leiaute 2.5 e C9V/T3A quando 1.0 

@return cIdFunc - ID do funcionario (2200/2300/2190)
@return lView - Passado True quando fun��o for chamada de um inicializador browse
@return cAlias - Alias da tabela que esta utilizando o gatilho

@author Fabio S Mendonca / Alexandre Santos / Karyna Martins / Jos� Riquelmo / Silas Gomes
@since 26/03/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function GatMatSST(cIdFunc as character, lView as logical, cAlias as character, lBenef as logical)                                                                                                                             

	Local cRet        	as character
	Local cCPF        	as character
	Local cNome       	as character
	Local cEvent		as character
	Local cFilEvt		as character
	Local lFldPut		as logical

	Default cIdFunc   	:= ""
	Default cAlias    	:= ""
	Default lView     	:= .F.
	Default lBenef	  	:= .F.

	cRet    := ""
	cCPF    := ""
	cNome	:= ""
	cFilEvt	:= ""
	cEvent	:= IIf(Type("cEvtPosic") == "U" .Or. ValType(cEvtPosic) == "U", "", cEvtPosic)
	lFldPut	:= .F.

	If lView 
		cEvent := (cAlias)->&(cAlias + "_NOMEVE")

		If !lBenef
			If cEvent <> "S2190"
				cFilEvt := IIf(Empty(xFilial("C9V", (cAlias)->&(cAlias + "_FILIAL"))), xFilial("C9V"), xFilial("C9V", (cAlias)->&(cAlias + "_FILIAL")))

				C9V->(DbSetOrder(2))

				If C9V->(MsSeek(cFilEvt + cIdFunc + "1"))
					cCPF  := C9V->C9V_CPF
					cNome := TAFGetNT1U(cCPF,,cFilEvt)
					
					If Empty(cNome)
						cNome := C9V->C9V_NOME
					EndIf
				EndIf
			Else
				cFilEvt := IIf(Empty(xFilial("T3A", (cAlias)->&(cAlias + "_FILIAL"))), xFilial("T3A"), xFilial("T3A", (cAlias)->&(cAlias + "_FILIAL")))

				T3A->(DbSetOrder(3))

				If T3A->(MsSeek(cFilEvt + cIdFunc + "1"))
					cNome	:= STR0209 // "TRABALHADOR PRELIMINAR"
					cCPF	:= T3A->T3A_CPF
				EndIf
			EndIf
		Else
			cFilEvt := IIf(Empty(xFilial("V73", (cAlias)->&(cAlias + "_FILIAL"))), xFilial("V73"), xFilial("V73", (cAlias)->&(cAlias + "_FILIAL")))

			V73->(DbSetOrder(4))

			If V73->(MsSeek(cFilEvt + cIdFunc + "1"))
				cEvent	:= V73->V73_NOMEVE
				cNome 	:= V73->V73_NOMEB
				cCPF  	:= V73->V73_CPFBEN

				V73->(DBSetOrder(3))

				If V73->(MsSeek(cFilEvt + cCPF + "S2405" + "1"))
					cNome := V73->V73_NOMEB
				EndIf	
			EndIf
		EndIf

		cRet := cCPF + " - " + AllTrim(cNome)
	Else
		// Verifica se a chamada foi da fun��o gen�rica de exclus�o.
		// Neste caso n�o tenho as vari�veis INCLUI e ALTERA
		// Prote��o para exclus�o pelo monitor TAF Full
		If FwIsInCallStack('XTAFVEXC') 
			INCLUI := .F.
			ALTERA := .F.
		EndIf

		If !Empty(cEvent) .And. (INCLUI .OR. ALTERA)
			FWFldPut(cAlias + "_NOMEVE", cEvent)	
		ElseIf !INCLUI
			cEvent := (cAlias)->&(cAlias + "_NOMEVE")
		EndIf
		
		If Empty(cEvent)
			lFldPut := .T.
		EndIf

		If lBenef
			cFilEvt := IIf(Empty(xFilial("V73", (cAlias)->&(cAlias + "_FILIAL"))), xFilial("V73"), xFilial("V73", (cAlias)->&(cAlias + "_FILIAL")))

			V73->(DbSetOrder(4))

			If V73->(MsSeek(cFilEvt + cIdFunc + "1"))
				cEvent	:= V73->V73_NOMEVE
				cNome 	:= V73->V73_NOMEB
				cCPF  	:= V73->V73_CPFBEN

				V73->(DBSetOrder(3))

				If V73->(MsSeek(cFilEvt + cCPF + "S2405" + "1"))
					cNome := V73->V73_NOMEB
				EndIf	
			EndIf
		Else
			cFilEvt := IIf(Empty(xFilial("C9V", (cAlias)->&(cAlias + "_FILIAL"))), xFilial("C9V"), xFilial("C9V", (cAlias)->&(cAlias + "_FILIAL")))

			C9V->(DbSetOrder(2))

			If C9V->(MsSeek(cFilEvt + cIdFunc + "1"))
				cEvent	:= C9V->C9V_NOMEVE
				cCPF  	:= C9V->C9V_CPF
				cNome 	:= TAFGetNT1U(cCPF)
				
				If Empty(cNome)
					cNome := C9V->C9V_NOME
				EndIf
			Else
				cFilEvt := IIf(Empty(xFilial("T3A", (cAlias)->&(cAlias + "_FILIAL"))), xFilial("T3A"), xFilial("T3A", (cAlias)->&(cAlias + "_FILIAL")))

				T3A->(DbSetOrder(3))

				If T3A->(MsSeek(cFilEvt + cIdFunc + "1"))
					cEvent	:= "S2190"
					cNome	:= STR0209 // "TRABALHADOR PRELIMINAR"
					cCPF	:= T3A->T3A_CPF
				EndIf
			EndIf
		EndIf
		
		If !Empty(cCPF)
			cRet := cCPF + " - " + AllTrim(cNome)
			
			If lFldPut .And. (INCLUI .Or. ALTERA)
				FWFldPut(cAlias + "_NOMEVE", cEvent)
			EndIf
		EndIf
	EndIf

	cEvtPosic := ""

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} CbTpExam

Fun��o que retorna as op��es de combobox 
Campos: C8B_TPEXAM

@author Fabio S Mendonca
@since 26/03/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function CbTpExam()

	Local cString := ""

	cString := "0="+STR0170+";" // Exame admissional
	cString += "1="+STR0171+";" // Exame peri�dico
	cString += "2="+STR0172+";" // Exame retorno trab 	
	cString += "3="+STR0174+";" // Exame mudan�a fun��o ou mudan�a risco ocupacional			
	cString += "4="+STR0175+";" // Exame Monit. Pontual
	cString += "9="+STR0176+";" // Exame demissional 

Return cString

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFIniMat
Retorna a Matr�cula do trabalhador conforme Nome do Evento e ID
para o inicializador padr�o

@param cNomeEve - Nome do Evento
@param cIDFunc - ID do funcion�rio

@author Melkz Siqueira
@since 23/04/2021
@version 1.0		

@return cRet - Matr�cula do trabalhador
/*/
//-------------------------------------------------------------------
Function TAFIniMat(cNomeEve, cIDTrab)

	Local cRet			:= ""
	Local lOpc			:= Iif(Type("INCLUI") == "U", .F., INCLUI)

	Default cNomeEve 	:= ""
	Default cIDTrab		:= ""

	If !Empty(cIDTrab) .AND. !lOpc
		Do Case
			Case cNomeEve == "S2300"
				cRet := Posicione("C9V", 2, xFilial("C9V") + cIDTrab + "1", "C9V_MATTSV")

			Case cNomeEve == "S2190"
				cRet := Posicione("T3A", 3, xFilial("C9V") + cIDTrab + "1", "T3A_MATRIC")
				
			OtherWise
				cRet := Posicione("C9V", 2, xFilial("C9V") + cIDTrab + "1", "C9V_MATRIC")
		EndCase
	EndIf
	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XC91Valid
Rotina p/ executar os valids presentes no dicion�rio de dados em virtude
do campo X3_VALID n�o possuir caracteres suficientes
@author  Diego Santos
@since   15-06-2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function XC91Valid(cCampo as character)

	Local aTabFunc	as array 
	Local cEvento	as character
	Local cOrigem	as character
	Local lRet		as logical
	Local lAlert	as logical

	Default cCampo	:= ""

	aTabFunc	:= IIf(cOrigem == "S2190", {"T3A", 3}, {"C9V", 2})
	cEvento		:= IIf(Type("cNomEve") == "U" .Or. ValType(cNomEve) == "U", "", cNomEve)
	cOrigem		:= IIf(Type("cEvtPosic") == "U" .Or. ValType(cEvtPosic) == "U", "", cEvtPosic)
	lRet		:= .T.
	lAlert		:= .F.	

	If !lLaySimplIf 
		If AllTrim(cCampo) == "C91_INDAPU" .AND. !Empty(M->C91_INDAPU) .AND. !Empty(FWFLDGET("C91_TRABAL"))
			If cEvento == "S1200"
				If Pertence(" 12")
					lAlert := !XFUNVldUni("C91", 7, M->C91_INDAPU + FWFLDGET("C91_PERAPU") + Posicione("C9V", 2, xFilial("C9V") + FWFLDGET("C91_TRABAL") + "1", "C9V_CPF") + cEvento + "1")
				Else
					lRet := .F.
				EndIf
			Else
				lRet := (Pertence(" 12") .AND. XFUNVldUni("C91", 2, M->C91_INDAPU + FWFLDGET("C91_PERAPU") + FWFLDGET("C91_TRABAL") + cEvento + "1"))
			EndIf
		ElseIf AllTrim(cCampo) == "C91_PERAPU"
			lRet := .T.
		ElseIf AllTrim(cCampo) == "C91_TRABAL" .AND. !Empty(FWFLDGET("C91_INDAPU")) .AND. !Empty(M->C91_TRABAL)
			If cEvento == "S1200"
				If XFUNVldCmp(aTabFunc[1], aTabFunc[2], M->C91_TRABAL + "1",, aTabFunc[2],,, .T.)
					lAlert := !XFUNVldUni("C91", 7, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + Posicione("C9V", 2, xFilial("C9V") + M->C91_TRABAL + "1", "C9V_CPF") + cEvento + "1")	
				Else
					lRet := .F.
				EndIf
			Else
				lRet := (XFUNVldCmp(aTabFunc[1], aTabFunc[2], M->C91_TRABAL + "1",, aTabFunc[2],,, .T.) .AND. XFUNVldUni("C91", 2, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + M->C91_TRABAL + cEvento + "1"))	
			EndIf
		ElseIf AllTrim(cCampo) == "C91_DTRABA" .AND. !Empty(FWFLDGET("C91_INDAPU")) .AND. !Empty(M->C91_TRABAL)
			If cEvento == "S1200"
				lAlert := !XFUNVldUni("C91", 7, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + Posicione("C9V", 2, xFilial("C9V") + M->C91_TRABAL + "1", "C9V_CPF") + cEvento + "1")
			Else
				lRet := XFUNVldUni("C91", 2, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + M->C91_TRABAL + cEvento + '1')	
			EndIf
		EndIf
	Else
		If AllTrim(cCampo) == "C91_INDAPU" .AND. !Empty(M->C91_INDAPU) .AND. !Empty(FWFLDGET("C91_TRABAL"))
			If cEvento == "S1200" 
				If Pertence(" 12")
					cOrigem := IIf(Empty(cOrigem) .And. TAFColumnPos("C91_ORIEVE"), FWFLDGET("C91_ORIEVE"), cOrigem)
					lAlert 	:= !XFUNVldUni("C91", 10, M->C91_INDAPU + FWFLDGET("C91_PERAPU") + FWFLDGET("C91_TPGUIA") + TafGetCPF(, FWFLDGET("C91_TRABAL"),,, cOrigem) + cEvento + "1")
				Else
					lRet := .F.
				EndIf
			Else
				lRet := (Pertence(" 12") .AND. XFUNVldUni("C91", 11, M->C91_INDAPU + FWFLDGET("C91_PERAPU") + FWFLDGET("C91_TPGUIA") + FWFLDGET("C91_TRABAL") + cEvento + "1"))
			EndIf
		ElseIf AllTrim(cCampo) == "C91_PERAPU"
			lRet := .T.
		ElseIf AllTrim(cCampo) == "C91_TRABAL" .AND. !Empty(FWFLDGET("C91_INDAPU")) .AND. !Empty(M->C91_TRABAL)
			If cEvento == "S1200" 
				If XFUNVldCmp(aTabFunc[1], aTabFunc[2], M->C91_TRABAL + "1",, aTabFunc[2],,, .T.)
					cOrigem := IIf(Empty(cOrigem) .And. TAFColumnPos("C91_ORIEVE"), M->C91_ORIEVE, cOrigem)
					lAlert 	:= !XFUNVldUni("C91", 10, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + FWFLDGET("C91_TPGUIA") + TafGetCPF(, M->C91_TRABAL,,, cOrigem) + cEvento + "1")	
				Else
					lRet := .F.					
				EndIf
			Else
				lRet := (XFUNVldCmp(aTabFunc[1], aTabFunc[2], M->C91_TRABAL + "1",, aTabFunc[2],,, .T.) .AND. XFUNVldUni("C91", 11, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + FWFLDGET("C91_TPGUIA") + M->C91_TRABAL + cEvento + "1"))	
			EndIf
		ElseIf AllTrim(cCampo) == "C91_DTRABA" .AND. !Empty(FWFLDGET("C91_INDAPU")) .AND. !Empty(M->C91_TRABAL)
			If cEvento == "S1200"
				cOrigem := IIf(Empty(cOrigem) .And. TAFColumnPos("C91_ORIEVE"), M->C91_ORIEVE, cOrigem)
				lAlert 	:= !XFUNVldUni("C91", 10, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + FWFLDGET("C91_TPGUIA") + TafGetCPF(, M->C91_TRABAL,,, cOrigem) + cEvento + "1")
			Else	
				lRet := XFUNVldUni("C91", 11, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") +	 FWFLDGET("C91_TPGUIA") + M->C91_TRABAL + cEvento + '1')
			EndIf
		ElseIf AllTrim(cCampo) == "C91_TPGUIA" .AND. !Empty(FWFLDGET("C91_INDAPU")) .AND. !Empty(FWFLDGET("C91_TRABAL")) 
			If cEvento == "S1200"
				cOrigem := IIf(Empty(cOrigem) .And. TAFColumnPos("C91_ORIEVE"), FWFLDGET("C91_ORIEVE"), cOrigem)
				lAlert 	:= !XFUNVldUni("C91", 10, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + M->C91_TPGUIA + TafGetCPF(, FWFLDGET("C91_TRABAL"),,, cOrigem) + cEvento + "1")
			Else	
				lRet := XFUNVldUni("C91", 11, FWFLDGET("C91_INDAPU") + FWFLDGET("C91_PERAPU") + M->C91_TPGUIA + FWFLDGET("C91_TRABAL") + cEvento + '1')
			EndIf
		EndIf
	EndIf

	If lAlert
		MsgAlert(STR0177, STR0178) // "Esse CPF j� possui uma Folha de Pagamento inclu�da para este per�odo." / "Aten��o!"
		
		lRet := .F.
	EndIf

Return lRet

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TafNameBen
Funcao chamada do campo virtual de nome do benefici�rio para exibir o �ltimo nome com status 4
@author Lucas A. dos Passos
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TafNameBen(cFil as character, cAlias as character, cCPFTrab as character, cIdTrab as character, lNrCpf as character)

	Local aAreaV73	 as array
	Local cRet       as character
    Local cNome      as character

	Default cIdTrab  := ""
	Default cCPFTrab := ""
    Default cAlias   := "V73"
	Default cFil	 := xFilial(cAlias)
	Default lNrCpf   := .F.

	aAreaV73	:= V73->(GetArea())
	cRet		:= ""
	cNome       := ""

    If !Empty(cCPFTrab) .And. Empty(cIdTrab)
		V73->(DBSetOrder(3))

		If V73->(MsSeek(xFilial("V73", cFil) + cCPFTrab + "S2400" + "1"))
			cNome := V73->V73_NOMEB

			If ExistS2405(.T., cFil, V73->V73_ID, .T.)
				cNome := V73->V73_NOMEB
			EndIf
		EndIf
	EndIf

	If !Empty(cIdTrab)
		If ExistS2405(.T., cFil, cIdTrab, .T.)
			cNome 		:= V73->V73_NOMEB
			cCPFTrab  	:= V73->V73_CPFBEN
		Else
			V73->(DbSetOrder(4))

			If V73->(MsSeek(xFilial("V73", cFil) + cIdTrab + "1"))
				cNome 		:= V73->V73_NOMEB
				cCPFTrab  	:= V73->V73_CPFBEN
			EndIf
		EndIf
	EndIf

	cRet := IIF(lNrCpf, cCPFTrab + " - ", "") + AllTrim(cNome)

	RestArea(aAreaV73)

Return cRet

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} V73Sxb
Funcao chamada da consulta espec�fica V73
@author Lucas A. dos Passos
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
function V73Sxb()

	Local aCols  		as array
	Local aCoord		as array
	Local aWindow		as array
	Local aHeader   	as array
	Local aColSizes 	as array
	Local cTitulo   	as character
	Local cFiltro		as character
	Local cAlias		as character
	Local cFil          as character
	Local lLGPDperm 	as logical
	Local Nx 			as numeric
	Local oListBox		as object
	Local oArea			as object
	Local oList			as object
	Local oButt1 		as object
	Local oButt2 		as object
	Local oButt3 		as object

	Private __cEvtPos	as character

	aCols  		:= {}
	aCoord		:= {}
	aWindow		:= {}
	aHeader   	:= {"ID", "Nome", "CPF", "Evento"}
	aColSizes 	:= {35, 80, 25, 15}
	__cEvtPos	:= ""
	cTitulo   	:= "Consulta Benefici�rio (S-2400)" 
	cFiltro		:= Space(50)
	cAlias		:= GetNextAlias()
	cFil        := cFilant
	lLGPDperm 	:= IIf(FindFunction("PROTDATA"), ProtData(), .T.)
	Nx 			:= 0
	oListBox	:= Nil
	oArea		:= Nil
	oList		:= Nil
	oButt1 		:= Nil
	oButt2 		:= Nil
	oButt3 		:= Nil

	BeginSql Alias cAlias
		SELECT V73_FILIAL FILIAL, V73_ID ID, V73_CPFBEN CPF, V73_NOMEB NOME, V73_STATUS, V73_DTALTE DATAALTERACAO, 'S2400' AS EVENTO
		FROM %Table:V73% V73
		WHERE 
			V73.%NotDel% 
			AND V73_ATIVO = '1'
			AND V73_FILIAL = %xfilial:V73%
			AND ( (V73_NOMEVE = 'S2400' AND V73_ID NOT IN 
					( SELECT V73_ID
						FROM %Table:V73% V731
						WHERE 
						V731.%NotDel%
						AND V731.V73_NOMEVE = 'S2405'
						AND V731.V73_ATIVO = '1' 
						AND V731.V73_STATUS = '4' 
						AND V731.V73_FILIAL = V73.V73_FILIAL
					)
				  ) 
					OR
					(V73_NOMEVE = 'S2405' 
						AND V73.V73_STATUS = '4'
						AND V73_ID NOT IN 
						( SELECT V73_ID
						FROM %Table:V73% V732
						WHERE V732.%NotDel%
						AND V73_ATIVO = '1' 
						AND V732.V73_DTALTE > V73.V73_DTALTE
						AND V732.V73_STATUS = '4' 
						AND V732.V73_FILIAL = V73.V73_FILIAL
						)
					)
				)
	EndSql

	QueenWindow( , cTitulo , cAlias,,,cFil )

Return .T.

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} C9VDFil
Consulta Especifica de trabalhadores S-2200,S-2300 e s-2400.

@author Daniel Aguilar / Karyna Rainho
@since 06/04/2022
@version 1.0

/*/       
//----------------------------------------------------------------------------------------------
Function C9VDFil()

	Local lRet := C9VHFil()

Return lRet

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TelaEspec
Monta a tela da consulta espec�fica

@param cTitulo 	- T�tulo da consulta espec�fica
@param aHeader 	- Array do cabe�alho 
@param aCols 	- Array das colunas

@author Daniel Aguilar / Karyna Rainho
@since 06/04/2022
@version 1.0

/*/       
//----------------------------------------------------------------------------------------------
Function TelaEspec(cTitulo, aHeader, aCols)

Local oListBox		:= Nil
Local oArea			:= Nil
Local oList			:= Nil
Local oButt1 		:= Nil
Local oButt2 		:= Nil
Local oButt3 		:= Nil	
Local aColSizes 	:= { 35, 80, 25, 15 }
Local aCoord		:= {}
Local aWindow		:= {}		
Local cFiltro		:= Space(50)
Local Nx 			:= 0
Local lLGPDperm 	:= IIF(FindFunction("PROTDATA"),ProtData(),.T.)

Default cTitulo	:= "Consulta Espec�fica"
Default aHeader	:= {}
Default aCols  	:= {}	

aCoord 	:= {000,000,400,800}
aWindow := {020,073}

oArea := FWLayer():New()
oFather := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],cTitulo,,,,,CLR_BLACK,CLR_WHITE,,,.T.)
oArea:Init(oFather,.F., .F. )

oArea:AddLine("L01",100,.T.)

oArea:AddCollumn("L01C01",99,.F.,"L01")
oArea:AddWindow("L01C01","TEXT","A��es",aWindow[01],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
oText	:= oArea:GetWinPanel("L01C01","TEXT","L01")

TSay():New(005,002,{||'Pesquisa Nome/CPF:'},oText,,,,,,.T.,,,200,20)
TGet():New(003,057,{|u| if( PCount() > 0, cFiltro := u, cFiltro ) },oText,130,009,"@!",,,,,,,.T.,,,,.T.,,,.F.,,"","cFiltro",,,,.T.,.T.)
oButt3 := tButton():New(003,190,"Pesquisar",oText,{||CheckFilF(oListBox,cFiltro)}, 45,11,,,.F.,.T.,.F.,,.F.,,,.F. )

oArea:AddWindow("L01C01","LIST","Trabalhador",aWindow[02],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
oList	:= oArea:GetWinPanel("L01C01","LIST","L01")

oButt2 := tButton():New(003,239,"&Visualizar",oText,{||PosicTrab(aCols[oListBox:nAt,1],"1",aCols[oListBox:nAt,4])},45,11,,,.F.,.T.,.F.,,.F.,,,.F. )
oButt1 := tButton():New(003,290,"&OK",oText,{||PosicTrab(aCols[oListBox:nAt,1],,aCols[oListBox:nAt,4]), oFather:End()},45,11,,,.F.,.T.,.F.,,.F.,,,.F. )
oButt3 := tButton():New(003,340,"&Sair",oText,{|| oFather:End()},45,11,,,.F.,.T.,.F.,,.F.,,,.F. )

oFather:lEscClose := .T.

nTamCol := Len(aCols[01])
bLine 	:= "{|| {"
For Nx := 1 To nTamCol
	bLine += "aCols[oListBox:nAt]["+StrZero(Nx,3)+"]"
	If Nx < nTamCol
		bLine += ","
	EndIf
Next
bLine += "} }"

oListBox := TCBrowse():New(0,0,386,130,,aHeader,,oList,'Fonte')
oListBox:SetArray( aCols )
oListBox:bLine := &bLine

If !lLGPDperm
	oListBox:aObfuscatedCols :={.F.,.T.,.T.}
EndIf

If !Empty( aColSizes )
	oListBox:aColSizes := aColSizes
EndIf
oListBox:SetFocus()	

oFather:Activate(,,,.T.,/*valid*/,,/*On Init*/)

Return 


//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} GatBenT3P
Gatilho do benefici�rio

@param cAlias 	- Alias da tabela
@param cIdBen 	- Id do benefici�rio

@author Daniel Aguilar / Karyna Rainho
@since 06/04/2022
@version 1.0
/*/       
//----------------------------------------------------------------------------------------------
Function GatBenT3P(cAlias as character, cIdBen as character)      

	Local cCPF    	as character
	Local cEvent	as character
	Local cNome   	as character
	Local cRet    	as character

	Default cAlias 	:= ""
	Default cIdBen 	:= ""

	cCPF    := ""
	cNome   := ""
	cRet    := ""
	cEvent	:= IIf(Type("cEvtPosic") == "U" .Or. ValType(cEvtPosic) == "U", "", cEvtPosic)

	If !Empty(cEvent) .And. (INCLUI .OR. ALTERA)

		FWFldPut(cAlias +"_ORIEVE", cEvent)

	ElseIf TafColumnPos("T3P_ORIEVE")

		cEvent := T3P->T3P_ORIEVE
		
	EndIf

	If cEvent == 'S2200'

		cNome := Posicione("T1U", 2, xFilial("T1U")  + cIdBen + "1", "T1U_NOME")
		cCPF  := T1U->T1U_CPF

	ElseIf cEvent == 'S2400'

		cNome := Posicione("V73", 4, xFilial("V73")  + cIdBen + "1", "V73_NOMEB")
		cCPF  := V73->V73_CPFBEN

	Else
		
		cNome := Posicione("T1V", 2, xFilial("T1V")  + cIdBen + "1", "T1V_NOME")
		cCPF  := T1V->T1V_CPF

	EndIf

	If Empty(cNome) .OR. Empty(cCPF)

		cNome := Posicione("C9V", 2, xFilial("C9V") + cIdBen + "1", "C9V_NOME")
		cCPF  := C9V->C9V_CPF	

	EndIf

	cRet  := cCPF + " - " + cNome
	cEvtPosic := ""

Return cRet
    
//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} tpCont
Gatilho do tpCont

@author Silas Gomes/ Karyna Rainho
@since 25/10/2022
@version 1.0
/*/       
//----------------------------------------------------------------------------------------------
Function tpCont()    

	Local cString  as string
	
	cString := "1="+STR0202+";" // Trabalhador com v�nculo formalizado, sem altera��o nas datas de admiss�o e de desligamento
	cString += "2="+STR0203+";" // Trabalhador com v�nculo formalizado, com altera��o na data de admiss�o
	cString += "3="+STR0204+";" // Trabalhador com v�nculo formalizado, com inclus�o ou altera��o de data de desligamento
	cString += "4="+STR0205+";" // Trabalhador com v�nculo formalizado, com altera��o nas datas de admiss�o e de desligamento
	cString += "5="+STR0206+";" // Empregado com reconhecimento de v�nculo
	cString += "6="+STR0207+";" // Trabalhador sem v�nculo de emprego/estatut�rio (TSVE), sem reconhecimento de v�nculo empregat�cio
	cString += "7="+STR0226+";" // Trabalhador com v�nculo de emprego formalizado em per�odo anterior ao eSocial
	cString += "8="+STR0227+";" // Responsabilidade indireta
	cString += "9="+STR0228+";" // Trabalhador cujos contratos foram unificados (unicidade contratual)

Return cString
            
//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFTpRegT
Gatilho do TAFTpRegT

@author Silas Gomes/ Karyna Rainho
@since 25/10/2022
@version 1.0
/*/       
//----------------------------------------------------------------------------------------------
Function TAFTpRegT()  

	Local cString  as string
	
	cString := "1="+STR0190+";" // CLT - Consolida��o das Leis de Trabalho e legisla��es trabalhistas espec�ficas
	cString += "2="+STR0191+";" // Estatut�rio/legisla��es espec�ficas (servidor tempor�rio, militar, agente pol�tico, etc.)

Return cString

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFTpRegP
Gatilho do TAFTpRegP

@author Silas Gomes/ Karyna Rainho
@since 25/10/2022
@version 1.0
/*/       
//----------------------------------------------------------------------------------------------
Function TAFTpRegP()    

	Local cString  as string
	
	cString := "1="+STR0192+";" // Regime Geral de Previd�ncia Social - RGPS
	cString += "2="+STR0193+";" // Regime Pr�prio de Previd�ncia Social - RPPS ou Sistema de Prote��o Social dos Militares
	cString += "3="+STR0194+";" // Regime de Previd�ncia Social no exterior

Return cString

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMotTSV
Gatilho do TAFMotTSV

@author Silas Gomes/ Karyna Rainho
@since 25/10/2022
@version 1.0
/*/       
//----------------------------------------------------------------------------------------------
Function TAFMotTSV()         

	Local cString  as string
	
	cString := "01="+STR0195+";" // Exonera��o do diretor n�o empregado sem justa causa, por delibera��o da assembleia, dos s�cios cotistas ou da autoridade competente
	cString += "02="+STR0196+";" // T�rmino de mandato do diretor n�o empregado que n�o tenha sido reconduzido ao cargo
	cString += "03="+STR0197+";" // Exonera��o a pedido de diretor n�o empregado
	cString += "04="+STR0198+";" // Exonera��o do diretor n�o empregado por culpa rec�proca ou for�a maior
	cString += "05="+STR0199+";" // Morte do diretor n�o empregado
	cString += "06="+STR0200+";" // Exonera��o do diretor n�o empregado por fal�ncia, encerramento ou supress�o de parte da empresa
	cString += "99="+STR0201+";" // Outros

Return cString

//-------------------------------------------------------------------
/*/{Protheus.doc} GatMatV9U
Gatilho
@author  Karyna / Silas
@since   25/10/2022
@version 1
/*/
//-------------------------------------------------------------------
Function GatMatV9U()

	Default cEvtPosic := ''

Return cEvtPosic

//-----------------------------------------------------------------------
/*/{Protheus.doc} xFunVldAnual
	@type  X3_VALID
	@author Lucas Passos
	@since 23/01/2023
	@param cPerApu - Periodo de apura��o informado em memoria
/*/
//-----------------------------------------------------------------------
Function xFunVldAnual(cPerApu as character)

	Local lOk as Logical
	
	lOk := .T.

	If Len(Alltrim(cPerApu)) < 6
		Help( ,,"TAFVLDANUAL",,, 1, 0 ,,,,,,{STR0213})
		lOk := .F.
	EndIF
	
Return lOk

//-----------------------------------------------------------------------
/*/{Protheus.doc} QueenWindow
	@author Alexandre lima / Karyna Rainho
	@since 01/03/2023
	@param cQuery  - Query para ser aplicada no filtro
	@param cTitulo - T�tulo da rotina
/*/
//-----------------------------------------------------------------------

Function QueenWindow(cQuery as character, cTitulo as character, cAliasQry as character, cCall as character, cEvento as character, cFil as character)

    Local aStruct    	as Array 
    Local aColumns   	as Array 
    Local aFilter    	as Array 
	Local aSeek     	as Array
	Local cCPF 			as character
	Local cNome 		as character
	Local cAliasTmp     as character
	Local cEveUnic      as character
    Local nX         	as Numeric 
	Local oTempTable 	as object
	Local oFWFilter 	as object
	Local oBrowse   	as object
	Local oDlg      	as object
	Local bCancel   
	Local bOk
	Local bVil

	Default cEvento := ""
	Default cCall   := ""
	
	aStruct 	:= {}   
    aColumns  	:= {} 
    aFilter     := {}
	aSeek       := {}
    nX          := 1
	oTempTable  := nil
	oFWFilter   := nil
	oBrowse     := nil
	oDlg        := nil
	cCPF 		:= ""
	cNome 	    := ""
	cAliasTmp   := ""
	
	cEveUnic := Iif( cEvento $ "S2298|S2299", "S2200", Iif( cEvento $ "S2399",  "S2300",  ""))
	
	If FunName() == "TAFA591" .AND. cCall == "C9VHFil"
		cEveUnic := "S2200"
		cEvento  := "S2400"
		cTitulo  := STR0211
	ElseIf FunName() $ "TAFA261"
		cEveUnic := "S2200|S2300"
		cTitulo  := STR0208
	ElseIf FunName() $ "TAFA264|TAFA258|TAFA407|TAFA257"
		cEveUnic := "S2200|S2300|S2190"
		cTitulo  := STR0223
	EndIf

    AaDD(aStruct, {"FILIAL"	, "C", TamSx3( "C9V_FILIAL" )[1], 	0, "!@"})
	AaDD(aStruct, {"ID"		, "C", TamSx3( "C9V_ID" )[1]	, 	0, "!@"})
	AaDD(aStruct, {"NOME"	, "C", TamSx3( "C9V_NOME" )[1]	, 	0, "!@"})
	AaDD(aStruct, {"CPF"	, "C", TamSx3( "C9V_CPF" )[1]	, 	0, "!@"})
	AaDD(aStruct, {"EVENTO"	, "C", TamSx3( "C9V_NOMEVE" )[1], 	0, "!@"})
 
    //Set Columns
    aColumns := {}
    aFilter  := {}

    For nX := 1 To Len(aStruct)
        //Columns
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
        aColumns[Len(aColumns)]:SetTitle(aStruct[nX][1])
        aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
		aColumns[Len(aColumns)]:SetID(aStruct[nX][1])
        //Filters
        aAdd(aFilter, {aStruct[nX][1], aStruct[nX][1], aStruct[nX][2], aStruct[nX][3], aStruct[nX][4], "!@"} )
    Next nX
 
    //Instance of Temporary Table
    oTempTable := FWTemporaryTable():New()

    //Set Fields
    oTempTable:SetFields(aStruct)
	
    //Set Indexes
    oTempTable:AddIndex("INDEX1", {"FILIAL"} )
    oTempTable:AddIndex("INDEX2", {"ID"} )
	oTempTable:AddIndex("INDEX3", {"NOME"} )
    oTempTable:AddIndex("INDEX4", {"CPF"} )
	oTempTable:AddIndex("INDEX5", {"EVENTO"} )

    //Create
    oTempTable:Create()
    cAliasTmp := oTemptable:GetAlias()
 
    aHeadCols := {}
    oBrowse   := NIL
    aAccounts := {}

	If Empty(cAliasQry)
		cAliasQry := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
    	MpSysOpenQuery(cQuery, cAliasQry)
	EndIf

	While !(cAliasQry)->(EOF())

		If (cAliasQry)->CPF != cCPF
			cCPF := (cAliasQry)->CPF
			
			If (cAliasQry)->EVENTO $ "S2200|S2300"
				cNome := TAFGetNT1U((cAliasQry)->CPF)

				If Empty(cNome)
					cNome := (cAliasQry)->NOME
				EndIf
			Else
				cNome := (cAliasQry)->NOME
			EndIf
			
			If ( Empty(cEveUnic) .OR. Alltrim((cAliasQry)->EVENTO) $ cEveUnic ).AND. cFil == (cAliasQry)->FILIAL

				(cAliasTMP)->(DbGoTop())

				If (RecLock(cAliasTMP, .T.))
					(cAliasTMP)->FILIAL     := (cAliasQry)->FILIAL
					(cAliasTMP)->ID  		:= (cAliasQry)->ID
					(cAliasTMP)->NOME 		:= cNome
					(cAliasTMP)->CPF 		:= cCPF
					(cAliasTMP)->EVENTO 	:= (cAliasQry)->EVENTO
					(cAliasTMP)->(MsUnlock())
				EndIf
			EndIf
		EndIf		
		
		(cAliasQry)->(DbSkip())
	EndDo

	DEFINE MSDIALOG oDlg TITLE cTitulo From 0,0 To 500,1000 OF oMainWnd PIXEL

    oBrowse := FWMBrowse():New()
 
    oBrowse:SetAlias(cAliasTMP) //Temporary Table Alias
	oBrowse:SetMenuDef( 'TAFXFUNDIC' )
	oBrowse:SetDescription(cTitulo)
    oBrowse:SetTemporary(.T.) //Using Temporary Table
    oBrowse:SetUseFilter(.T.) //Using Filter
    oBrowse:OptionReport(.F.) //Disable Report Print
    oBrowse:SetColumns(aColumns)
    oBrowse:SetFieldFilter(aFilter) //Set Filters
	oBrowse:SetOwner(oDlg)
	
	aAdd( aSeek, { "Filial"	, { { "", "C",	TamSx3( "C9V_FILIAL" )[1],  0, "FILIAL",	"@!", } } } )
	aAdd( aSeek, { "Id"		, { { "", "C",	TamSx3( "C9V_ID" )[1],   	0, "ID", 		"@!", } } } )
	aAdd( aSeek, { "Nome"	, { { "", "C", 	TamSx3( "C9V_NOME" )[1],  	0, "NOME", 		"@!", } } } )
	aAdd( aSeek, { "Cpf"	, { { "", "C", 	TamSx3( "C9V_CPF" )[1],  	0, "CPF", 		"@!", } } } )
	aAdd( aSeek, { "Evento"	, { { "", "C", 	TamSx3( "C9V_NOMEVE" )[1],  0, "EVENTO", 	"@!", } } } )

	oBrowse:SetSeek(.T., aSeek)
	oBrowse:SetIgnoreARotina(.T.)
	oBrowse:AddButton(STR0220 , bOk := {||  __cEvtPos := Alltrim((cAliasTMP)->EVENTO), PosicTrab(Alltrim((cAliasTMP)->ID),,Alltrim((cAliasTMP)->EVENTO ),(cAliasTMP)->FILIAL ),oDlg:End()})
	oBrowse:AddButton(STR0221 , bVil := {||  PosicTrab(Alltrim((cAliasTMP)->ID),"1",Alltrim((cAliasTMP)->EVENTO ),(cAliasTMP)->FILIAL)})
    oBrowse:AddButton(STR0221 , bCancel := {|| oDlg:End() })
    oBrowse:Activate(/*oDlg*/) //Caso deseje incluir em um componente de Tela (Dialog, Panel, etc), informar como par�metro o objeto
	
	(cAliasQry)->( DbCloseArea() )

	ACTIVATE MSDIALOg oDlg CENTERED

    //Delete Temporary Table
    oTempTable:Delete()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author karyna Rainho
@since 01/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------

static function MenuDef()

Local aRotina as array

aRotina := {}

Return aRotina
