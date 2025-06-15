#include "totvs.ch"
#include "PROTHEUS.ch"

/*/{Protheus.doc} LOCM006
Ponto de entrada ao final da gravação do pedido de vendas
@author Juliano Bobbio
@since 24/08/2020
@version undefined
Antigo ponto de entrada M410STTS
/*/

Function LOCM006()
Local _aArea :=	{FP0->(GetArea()),FQ2->(GetArea()),SC6->(GetArea()),FQ3->(GetArea()),GetArea()} 
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local _cAs := ""
Local nX

    If lMvLocBac

        // Tratamento para a geração das tabelas auxiliares de relacionamento entre o Rental x Faturamento
        If (INCLUI .And. IsInCallStack("LOCA010")) .or. IsInCallStack("LOCA048")
            // aFPYTransf e aFPZTransf são alimentadas no loca010
            If Type("aFPYTransf") == "A" .and. Type("aFPZTransf") == "A"
                FPY->(RecLock("FPY",.T.))
                FPY->FPY_FILIAL := aFPYTransf[1,2]
                FPY->FPY_PEDVEN := SC5->C5_NUM
                FPY->FPY_PROJET := aFPYTransf[3,2]
                FPY->FPY_TIPFAT := aFPYTransf[4,2]
                FPY->FPY_STATUS := aFPYTransf[5,2]
			    If _LROMANEIO // variavel alimentada no loca010
    				FPY->FPY_IT_ROM :=  aFPYTransf[6,2]
			    EndIf
                FPY->(MsUnlock())
                For nX := 1 to len(aFPZTransf)
                    FPZ->(RecLock("FPZ",.T.))
                    FPZ->FPZ_FILIAL := aFPZTransf[nX,1,2]
		            FPZ->FPZ_PEDVEN := SC6->C6_NUM
		            FPZ->FPZ_PROJET := aFPZTransf[nX,3,2]
		            FPZ->FPZ_ITEM   := aFPZTransf[nX,4,2]
		            FPZ->FPZ_AS     := aFPZTransf[nX,5,2]
		            FPZ->FPZ_EXTRA  := aFPZTransf[nX,6,2]
		            FPZ->FPZ_FROTA  := aFPZTransf[nX,7,2]
		            FPZ->FPZ_CCUSTO := aFPZTransf[nX,8,2]
                    FPZ->(MsUnlock())
                    _cAs := FPZ->FPZ_AS
                Next
            EndIF
        EndIF

    Else
        _cAs := SC6->C6_XAS
    EndIF


    If INCLUI .And. IsInCallStack("LOCA010")
        //Posiciono no item do romaneio conforme item do pedido de remessa
        FQ3->(DbSetOrder(3)) //Z1_FILIAL+Z1_AS
        If FQ3->(DbSeek(xFilial('FQ3') + _cAs))
            //Posiciono na cabeçalho do Romaneio
            FQ2->(DbSetOrder(3)) //Z0_FILIAL + Z0_ASF + Z0_NUM
            If FQ2->(DbSeek(xFilial('FQ2') + FQ3->FQ3_ASF + FQ3->FQ3_NUM ))
                Reclock('SC5',.F.)
                SC5->C5_TRANSP := FQ2->FQ2_XCODTR
                SC5->(MsUnlock())
            EndIf
        EndIf
    EndIf
    AEval(_aArea, {|x,y| RestArea(x)} )
Return Nil
