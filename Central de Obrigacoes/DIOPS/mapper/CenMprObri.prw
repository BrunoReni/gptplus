#include "TOTVS.CH"

Class CenMprObri from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprObri
    _Super:new()

    aAdd(self:aFields,{"B3A_CODIGO" ,"requirementCode"})
    aAdd(self:aFields,{"B3A_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"B3A_DESCRI" ,"obligationDescription"})
    aAdd(self:aFields,{"B3A_SZNLDD" ,"seasonality"})
    aAdd(self:aFields,{"B3A_TIPO" ,"obligationType"})
    aAdd(self:aFields,{"B3A_ATIVO" ,"activeInactive"})
    aAdd(self:aFields,{"B3A_AVVCTO" ,"dueDateNotification"})

Return self