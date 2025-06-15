#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRetTPCARG
Retorna a informa��o para o indicador de Dimens�o Tempo de Cargo

@author  BI TEAM
@version P11
@since   28/12/2012
@param cMatric, c�digo da matricula do colaborador 
       dDataAtu, data da extra��o ou demiss�o do colaborador 
/*/
//-------------------------------------------------------------------

Function BIXRetTPCARG(cMatric, dDataAtu)

Local   aArea     := {}
Local   cFilter   := ""
Local   cCargoAtu := ""
Local   cFuncAtu  := ""
Local   nQtdAnos  := 0
Local   dDataSR7  := CtoD("//")

DEFAULT cMatric   := ""
DEFAULT dDataAtu  := CtoD("//")

ChkFile("SR7")
aArea := SR7->(GetArea()) // Guarda posi��o atual do arquivo
SR7->(dbSetOrder(1))

cFilter := " R7_MAT = '" + cMatric + "' "
cFilter += " .And. R7_FILIAL = '" + xFilial("SR7") + "' "

SR7->( dbSetFilter ( &("{|| " + cFilter + "}"), cFilter) )
SR7->( dbGoBottom() )

// Guarda os valores atuais
cCargoAtu := SR7->R7_CARGO
cFuncAtu  := SR7->R7_FUNCAO
dDataSR7  := SR7->R7_DATA

While SR7->(!Bof()) .And. !Empty(SR7->R7_MAT)

	If (cCargoAtu != SR7->R7_CARGO .And. !Empty(SR7->R7_CARGO)) .Or. (cFuncAtu != SR7->R7_FUNCAO .And. !Empty(SR7->R7_FUNCAO))
		nQtdAnos := BIXVldValor(dDataAtu, dDataSR7, 3) // Realiza opera��o de diferen�a entre as datas
		nQtdAnos := (nQtdAnos / 365)                   // Converte os dias para anos
		Exit
	EndIf

	dDataSR7  := SR7->R7_DATA
	SR7->(dbSkip(-1))
EndDo

SR7->( dbClearFilter() ) // Remove filtro
RestArea(aArea)

Return nQtdAnos