#include 'protheus.ch'

static cStGrpComp	:=	GetSrvProfString( 'TAFSTByGrpCompany' , '0' ) //vari�vel de controle que verifica se a integra��o ser� feita multi-empresa
static cSt2Name		:=	nil
static cXErpName	:=	nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSt2Name

Fun��o criada para retornar o nome da tabela TAFST2 conforme configura��o
da chave TAFSTByGrpCompany no arquivo appserver.ini
Caso a chave esteja habilitada, o nome da tabela ser� acrescido do c�digo da
empresa que est� operando o sistema, por exemplo TAFST2_99.
Isso se faz necess�rio para avaliar a carga da tabela TAFST2 pensando na utiliza��o
do TAF in Cloud.

@return cSt2Name -> Nome da tabela TAFST2, caso a chave TAFSTByGrpCompany esteja habilitada
 					o nome ser� retornado acrescido do c�digo da empresa, por exemplo
 					TAFST2_99.

@author Luccas Curcio
@since 03/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
function TAFSt2Name()

if cSt2Name == nil 

	cSt2Name	:=	'TAFST2'
	
	if cStGrpComp == '1'
		cSt2Name := cSt2Name + '_' + cEmpAnt
	endif

endif

return cSt2Name

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFXErpName

Fun��o criada para retornar o nome da tabela TAFXERP conforme configura��o
da chave TAFSTByGrpCompany no arquivo appserver.ini
Caso a chave esteja habilitada, o nome da tabela ser� acrescido do c�digo da
empresa que est� operando o sistema, por exemplo TAFXERP_99.
Isso se faz necess�rio para avaliar a carga da tabela TAFXERP pensando na utiliza��o
do TAF in Cloud.

@return cXErpName -> Nome da tabela TAFXERP, caso a chave TAFSTByGrpCompany esteja habilitada
 					 o nome ser� retornado acrescido do c�digo da empresa, por exemplo
 					 TAFXERP_99.

@author Luccas Curcio
@since 03/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
function TAFXErpName()

if cXErpName == nil

	cXErpName	:=	'TAFXERP'
	
	if cStGrpComp == '1'
		cXErpName := cXErpName + '_' + cEmpAnt
	endif

endif

return cXErpName

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSTByGrpComp

Verifica se o ambiente est� configurado para trabalhar com as tabelas transacionais do TAF
por Grupo de Empresa.

@return lreturn ->	Indica se o ambiente est� configurado para trabalhar com as tabelas transacionais do TAF
					por Grupo de Empresa.

@author Luccas Curcio
@since 03/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
function TAFSTByGrpComp()

return ( cStGrpComp == '1' )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGetPriority

Retorna array bidimensional contendo os c�digos e descri��es v�lidas para prioridades
de registros na tabela TAFST2

@return aPriority ->	Array contendo c�digos e descri��es v�lidas para prioridades de registros

@author Luccas Curcio
@since 08/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
function TAFGetPriority()

local	aPriority	as	array

aPriority := {	{ '0' , 'Urgente' 			} ,; 
				{ '1' , 'Prioridade Cr�tica'} ,;
				{ '2' , 'Prioridade Alta' 	} ,;
				{ '3' , 'Prioridade M�dia' 	} ,;
				{ '4' , 'Prioridade Baixa' 	} ,;
				{ '5' , 'N�o Priorit�rio' 	} }

return aPriority

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFIsPriority

Valida se c�digo de prioridade enviado como par�metro � v�lido.

@return lValid ->	C�digo v�lido ( .T. ) ou inv�lido ( .F. )

@author Luccas Curcio
@since 08/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
function TAFIsPriority( cCodePriority )

local	lValid	as	logical

lValid := aScan( TAFGetPriority() , { |x| x[1] ==  allTrim( cCodePriority ) } ) > 0

return lValid