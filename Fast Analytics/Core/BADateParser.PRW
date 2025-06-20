#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} BAParseDate
Respons�vel pela chamada das fun��es para efetuar parse das datas.

@param cQuery, String, query com as datas a serem parseadas.

@return cQuery, String, query parseada, exemplo: "SELECT * FROM SA1T10"

@author  Helio Leal
@since   06/03/2018
/*/
//-------------------------------------------------------------------
Function BAParseDate(cQuery)

Return BIParseDate(cQuery)

//-------------------------------------------------------------------
/*/{Protheus.doc} BADateDiff
Retorna a diferen�a entre duas datas em dias, meses ou anos.
(Depende do segundo par�metro do parser:
 	Dias:  <<DATEDIFF_DD_Campo1-Campo2>>
 	Meses: <<DATEDIFF_MM_Campo1-Campo2>>
 	Anos:  <<DATEDIFF_YY_Campo1-Campo2>>

@param cQuery, String, query com as datas a serem parseadas.

@return cQuery, String, query parseada, exemplo: "SELECT * FROM SA1T10"

@author  Helio Leal
@since   06/03/2018
/*/
//-------------------------------------------------------------------
Function BADateDiff( cQuery )

Return BIDateDiff( cQuery )

//-------------------------------------------------------------------
/*/{Protheus.doc} BAVldDateDiff
Valida se o DateDiff est� no formato correto
Fun��o deve estar no formato <<DATEDIFF(DD, C1, C2)>>

@param cDateDiff, String, par�metro datediff vindo da query.

@return lValid, Boolean, verifica se o comando datediff est� correto.

@author  Helio Leal
@since   06/03/2018
/*/
//-------------------------------------------------------------------
Function BAVldDateDiff( cDateDiff )

Return BIVldDateDiff( cDateDiff )

//-------------------------------------------------------------------
/*/{Protheus.doc} BAParseDtDiff
Retorna a diferen�a entre duas datas em dias, meses ou anos 
(Depende do segundo par�metro do parser:
Dias:  <<DATEDIFF_DD_Campo1-Campo2>>
Meses: <<DATEDIFF_MM_Campo1-Campo2>>
Anos:  <<DATEDIFF_YY_Campo1-Campo2>>

@param cDateDiff, String, par�metro datediff vindo da query.

@return lValid, Boolean, verifica se o comando datediff est� correto.

@author  henrique.cesar
@since   07/03/2018
/*/
//-------------------------------------------------------------------
Function BAParseDtDiff( cDateDiff )

Return BIParseDtDiff( cDateDiff )

//-------------------------------------------------------------------
/*/{Protheus.doc} BAQryGetLF (BAQueryGetLastFirstDay)
Efetua parse na query para �ltimo ou primeiro dia do m�s.

@param cQuery, String, query com as datas a serem parseadas.
@param cTag, String, tag a ser parseada, exemplo <<LASTDAY( ou <<FIRSTDAY(
@return cQuery, String, query parseada para o primeiro/�ltimo dia do m�s.

@author  Helio Leal
@since   02/04/2018
/*/
//-------------------------------------------------------------------
Function BAQryGetLF( cQuery, cTag )

Return BIQryGetLF( cQuery, cTag )

//-------------------------------------------------------------------
/*/{Protheus.doc} BAGetTagLF (BAGetTagLastFirstDay)
Fun��o para gerar comando que pega �ltimo dia do m�s de um determinado campo de data.
exemplo: se data  03/04/2018, retorna 30/04/2018.

@param cQueryTag, String, tag da query a ser parseada, exemplo <<LASTDAY(NSZ_DTINCL>> ou <<FIRSTDAY(NSZ_DTINCL>>
@param cTag, String, tag a ser parseada, exemplo <<LASTDAY( ou <<FIRSTDAY(
@return cCommand, String, comando SQL para pegar �ltimo/primeiro dia de uma data ( Por bando: SQL ou ORACLE)

@author  Helio Leal
@since   03/04/2018
/*/
//-------------------------------------------------------------------
Function BAGetTagLF( cQueryTag, cTag )

Return BIGetTagLF( cQueryTag, cTag )

//-------------------------------------------------------------------
/*/{Protheus.doc} BAVldTag
Valida se a Tag est� no formato correto.
Fun��o deve estar no formato <<LASTDAY(CAMPO>> ou <<FISTDAY_CAMPO>>

@param cQueryTag, String, tag da query a ser parseada, exemplo <<LASTDAY(NSZ_DTINCL>> ou <<FIRSTDAY(NSZ_DTINCL>>
@param cTag, String, tag a ser parseada, exemplo <<LASTDAY( ou <<FIRSTDAY(

@return lValid, Boolean, verifica se o comando est� correto.

@author  Helio Leal
@since   04/04/2018
/*/
//-------------------------------------------------------------------
Function BAVldTag( cQueryTag, cTag )

Return BIVldTag( cQueryTag, cTag )

