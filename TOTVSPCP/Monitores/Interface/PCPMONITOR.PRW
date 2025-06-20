#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} PCPMONITOR
Fonte chamador da tela de Monitores do PCP em Po UI
@type Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Function PCPMONITOR()
	If PCPVldApp(.T.)
		FwCallApp("totvs-supply-monitor")
	EndIf
Return

/*/{Protheus.doc} MenuDef
Fun��o respons�vel por atribuir os monitores dispon�veis ao menu para validar acesso no cadastro de regras
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return aRotina, array, Array com a lista dos Monitores dispon�veis
/*/
Static Function MenuDef()
    //Local aRotAdic
    
    Private aRotina := {}

    aAdd(aRotina,{"Status da OP","StatusOrdemProducao", 0, 2, 0, Nil })
    aAdd(aRotina,{"Status do Recurso","StatusRecurso", 0, 2, 0, Nil })
    aAdd(aRotina,{"Status Play Stop PCP","StatusPlayStopPCP", 0, 2, 0, Nil })
    aAdd(aRotina,{"Status Lotes","StatusLotesAVencer", 0, 2, 0, Nil })
    aAdd(aRotina,{"Status Lotes - Gr�fico","StatusLotesAVencerGrafico", 0, 2, 0, Nil })
    aAdd(aRotina,{"Acomp. Prod. Produto","StatusProducaoProduto", 0, 2, 0, Nil })
    aAdd(aRotina,{"Acomp. Horas Apontadas","StatusApontamentoHoras", 0, 2, 0, Nil })
    aAdd(aRotina,{"Horas por Recurso","ProducaoCapacidadeRecurso", 0, 2, 0, Nil })
    
    /*
    If ExistBlock("PCPMONITOR")
        aRotAdic := ExecBlock("PCPMONITOR",.F.,.F.)
        If ValType(aRotAdic) == "A"
            AEval(aRotAdic,{|x| AAdd(aRotina,x)})
        EndIf
    EndIf
    */
Return aRotina

/*/{Protheus.doc} PCPMntMenu
Fun��o respons�vel o indice do Monitor no aRotina para validar acesso ao Monitor
@type Static Function
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cAPINeg, caracter, Fun��o de neg�cio vinculada ao Monitor
@return nIndice, numerico, Indice do Array aRotina que est� localizado o Monitor
/*/
Function PCPMntMenu(cAPINeg)
    Local aMenu   := MenuDef()
    Local nIndice := aScan(aMenu, {|x| x[2] == cAPINeg})

Return nIndice
