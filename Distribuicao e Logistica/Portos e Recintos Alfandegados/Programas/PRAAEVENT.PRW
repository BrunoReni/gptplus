#include 'protheus.ch'
#include 'FWMVCDef.ch'
#INCLUDE "PRAA802.CH"

/*/{Protheus.doc} A800EVENT
//TODO Descrição auto-gerada.
Classe responsavel por acionar o metodo InTTS e que por sua vez aciona o commit
@author mohamed
@since 14/06/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Class _A800EVENT FROM FWModelEvent

    Method New() CONSTRUCTOR
    Method InTTS()

End Class

Method New() Class _A800EVENT
Return

Method InTTS(oModel) Class _A800EVENT

    If (oModel:getOperation() == MODEL_OPERATION_INSERT) .Or. (oModel:getOperation() == MODEL_OPERATION_UPDATE)
        	StaticCall(PRAA800, A800OPE, oModel)
    Endif
    
Return

/*/{Protheus.doc} _A801EVENT
//TODO Descrição auto-gerada.
Classe responsavel por acionar o metodo InTTS e que por sua vez aciona o commit
@author mohamed
@since 14/06/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Class _A801EVENT FROM FWModelEvent
    
    Method New() CONSTRUCTOR
    Method InTTS()

End Class

Method New() Class _A801EVENT
Return

Method InTTS(oModel) Class _A801EVENT
    
    If (oModel:getOperation() == MODEL_OPERATION_INSERT) .Or. (oModel:getOperation() == MODEL_OPERATION_UPDATE)
        	StaticCall(PRAA801, A801OPE, oModel)
    Endif
	
Return

/*/{Protheus.doc} _A802EVENT
//TODO Descrição auto-gerada.
Classe responsavel por acionar o metodo InTTS e que por sua vez aciona o commit
@author mohamed
@since 14/06/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Class _A802EVENT FROM FWModelEvent
    
    Method New() CONSTRUCTOR
    Method InTTS()

End Class

Method New() Class _A802EVENT
Return

Method InTTS(oModel) Class _A802EVENT
    
    If (oModel:getOperation() == MODEL_OPERATION_INSERT) .Or. (oModel:getOperation() == MODEL_OPERATION_UPDATE)
           StaticCall(PRAA802, A802OPE, oModel)
    Endif
	
Return

/*/{Protheus.doc} _A804EVENT
//TODO Descrição auto-gerada.
Classe responsavel por acionar o metodo InTTS e que por sua vez aciona o commit
@author mohamed
@since 14/06/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Class _A804EVENT FROM FWModelEvent
    
    Method New() CONSTRUCTOR
    Method InTTS()

End Class

Method New() Class _A804EVENT
Return

Method InTTS(oModel) Class _A804EVENT
    
    If (oModel:getOperation() == MODEL_OPERATION_INSERT) .Or. (oModel:getOperation() == MODEL_OPERATION_UPDATE)
        StaticCall(PRAA804, A804BCOMMIT, oModel)
    Endif
	
Return

/*/{Protheus.doc} _A806EVENT
//TODO Descrição auto-gerada.
Classe responsavel por acionar o metodo InTTS e que por sua vez aciona o commit
@author mohamed
@since 14/06/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Class _A806EVENT FROM FWModelEvent
    
    Method New() CONSTRUCTOR
    Method InTTS()

End Class

Method New() Class _A806EVENT
Return

Method InTTS(oModel) Class _A806EVENT
    If (oModel:getOperation() == MODEL_OPERATION_INSERT) .Or. (oModel:getOperation() == MODEL_OPERATION_UPDATE)
       StaticCall(PRAA806, A806BCOMMIT, oModel)
    Endif
    
    If (oModel:getOperation() == MODEL_OPERATION_DELETE)
        StaticCall(PRAA806, A806BCOMMIT, oModel)
    EndIf
Return

/*/{Protheus.doc} _A903EVENT
//TODO Descrição auto-gerada.
Classe responsavel por acionar o metodo InTTS e que por sua vez aciona o commit
@author mohamed
@since 14/06/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Class _A903EVENT FROM FWModelEvent

    Method New() CONSTRUCTOR
    Method InTTS()

End Class

Method New() Class _A903EVENT
Return

Method InTTS(oModel) Class _A903EVENT
    
    If (oModel:getOperation() == MODEL_OPERATION_INSERT) .Or. (oModel:getOperation() == MODEL_OPERATION_UPDATE)
         StaticCall(PRAA903, A903OPE, oModel)
    Endif
    
Return

/*/{Protheus.doc} _A806AEVENT
//TODO Descrição auto-gerada.
Classe responsavel por acionar o metodo InTTS e que por sua vez aciona o commit
@author mohamed
@since 14/06/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Class _A806AEVENT FROM FWModelEvent
    Method New() CONSTRUCTOR
    Method InTTS()

End Class

Method New() Class _A806AEVENT
Return

Method InTTS(oModel) Class _A806AEVENT
    
    If (oModel:getOperation() == MODEL_OPERATION_INSERT) .Or. (oModel:getOperation() == MODEL_OPERATION_UPDATE) .Or. (oModel:getOperation() == MODEL_OPERATION_DELETE)
        	If(StaticCall(PRAA806A, A806ABCOMMIT, oModel)) 
        		StaticCall(PRAA806A, A806ABPOS, oModel) 
        	EndIf
    Endif
	
Return

/*/{Protheus.doc} _A807EVENT
//TODO Descrição auto-gerada.
Classe responsavel por acionar o metodo InTTS e que por sua vez aciona o commit
@author mohamed
@since 14/06/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Class _A807EVENT FROM FWModelEvent
    
    Method New() CONSTRUCTOR
    Method InTTS()

End Class

Method New() Class _A807EVENT
Return

Method InTTS(oModel) Class _A807EVENT
    
    If (oModel:getOperation() == MODEL_OPERATION_INSERT) .Or. (oModel:getOperation() == MODEL_OPERATION_UPDATE)
        StaticCall(PRAA807, A807BCOMMIT, oModel)
    Endif
    
    If (oModel:getOperation() == MODEL_OPERATION_DELETE)
        StaticCall(PRAA807, A807BCOMMIT, oModel)
    EndIf
	
Return

/*/{Protheus.doc} _A807AEVENT
//TODO Descrição auto-gerada.
Classe responsavel por acionar o metodo InTTS e que por sua vez aciona o commit
@author mohamed
@since 14/06/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Class _A807AEVENT FROM FWModelEvent

    Method New() CONSTRUCTOR
    Method InTTS()

End Class

Method New() Class _A807AEVENT
Return

Method InTTS(oModel) Class _A807AEVENT
    
    If (oModel:getOperation() == MODEL_OPERATION_INSERT) .Or. (oModel:getOperation() == MODEL_OPERATION_UPDATE)
        	If (StaticCall(PRAA807A, A807ABCOMMIT, oModel))
        	     StaticCall(PRAA807A, A807ABPOS, oModel) 
        	EndIf
     EndIf
	
Return


