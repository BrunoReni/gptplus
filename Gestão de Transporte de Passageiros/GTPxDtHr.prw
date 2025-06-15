#INCLUDE 'TOTVS.CH'

Function GxDtHr2Str(dDt,nHr)
Local cRet  := ""
Default dDt := dDataBase
Default nHr := 0

cRet := DtoS(dDt)+StrTran(IntToHora(nHr,4),':','')

Return cRet

Function GxElapseTime(dDtIni,nHrIni,dDtFim,nHrFim)
Local nRet      := 0
Local nQtdDias  := 0
Local nHoras    := 0
Local lViraDia  := .F.

Default dDtIni  := dDataBase
Default nHrIni  := 0
Default dDtFim  := dDataBase
Default nHrFim  := 0

lViraDia  := nHrFIm < nHrIni

nHoras := If(lViraDia, nHrFIm+24 ,nHrFIm )- nHrIni
nQtdDias := ( dDtFim - dDtIni ) + If(lViraDia, -1,0)

nRet    := (nQtdDias*24)+nHoras

Return nRet


//------------------------------------------------------------------------------
/* /{Protheus.doc} GxVldDtHr

@type Function
@author jacomo.fernandes
@since 07/12/2019
@version 1.0
@param dDtIni, date, (Descri��o do par�metro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GxVldData(dDtIni,dDtFim,cErro)
Local lRet := .T.

Default dDtIni  := StoD('')
Default dDtFim  := StoD('')
Default cErro   := ""


If !Empty(dDtIni) .and. !Empty(dDtFim)

    If dDtIni > dDtFim
        lRet    := .F.
        cErro   := "Data inicial maior que a data final"
    Endif
    
Endif

Return lRet 

//------------------------------------------------------------------------------
/* /{Protheus.doc} GxVldDtHr

OBS: Esta fun��o foi baseada na fun��o IntToHora(..) (do TECAXFUN). Por�m, foi 
ajustada por conta de algumas falhas de retorno da fun��o advpl Int(nFloat). 
Esta fun��o, quando recebia um valor inteiro, nem sempre retornava o pr�prio valor,
mas sim um valor menor

Converte um n�mero inteiro que representa o n�mero de horas em um valor 
de string que representa a hora no formato "hh:mm"

@type Function
@author Fernando Radu Muscalu
@since 05/04/2023
@version 1.0
@param  nHour (n�mero de horas) - um n�mero inteiro que representa o n�mero de 
        horas a serem convertidas em formato de hora;
        nDigits (n�mero de d�gitos) - um n�mero inteiro opcional que indica o n�mero 
        de d�gitos que a hora deve ter, caso seja necess�rio preencher com zeros � 
        esquerda. Se n�o for especificado, o n�mero de d�gitos ser� determinado 
        automaticamente;
        lCptZro (completar com zero) - um valor l�gico opcional que indica se o 
        n�mero de horas deve ser preenchido com zeros � esquerda, caso o 
        n�mero de d�gitos seja maior que o n�mero de d�gitos da hora. 
        Se n�o for especificado, o valor padr�o ser� falso.
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPInt2Hr(nHour,nDigits,lCptZro)

Local nHoras    := 0
Local nMinutos  := 0
Local cHora     := ""
Local lNegativo := .F.

Default lCptZro := .F. //Indica se ir� preencher com zeros a esquerda, horas dentro do intervalo de 99 - 1000, em rela��o ao nDigitos

lNegativo := ( nHour < 0 )

nHoras    := ABS( nHour )
nMinutos  := (nHour-Int(nHoras))*60

//a Fun��o int() est� com comportamento estranho em alguns casos de n�meros
//inteiros. Um exemplo que foi testado � nHoras possuir o valor 4 e a fun��o
//Int(nHoras) retorna 3 e n�o 4. Assim, se minutos for maior ou igual a 60
//ir� somar na hora e ira subtrair 60 de nMinutos
If ( nMinutos >= 60 ) 
    nHoras := Int(nHoras) + 1
    nMinutos := nMinutos - 60
Else
    nHoras := Int(nHoras)
EndIf

nDigitos := If( ValType( nDigitos )=="N", nDigitos, Len(cValtoChar(Int(nHoras))) ) - If( lNegativo, 1, 0 )

If nHoras > 99 .And. nHoras < 1000 .AND. !lCptZro
	cHora := If( lNegativo, "-", "" ) + StrZero( nHoras, 3 )+":"+StrZero( nMinutos, 2 )
Else
	cHora := If( lNegativo, "-", "" ) + StrZero( nHoras, Iif(nDigitos<2,2,nDigitos))+":"+StrZero( nMinutos, 2 )
Endif

Return(cHora)
