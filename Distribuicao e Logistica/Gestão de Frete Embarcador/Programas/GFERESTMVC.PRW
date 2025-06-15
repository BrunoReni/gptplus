#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static IsRest := .F.
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GFERESTMVC

Publicação dos modelos que devem ficar disponíveis no REST.
Vide classe FwRestModel.

@author Andre Luis Wisnheski
@since 05/04/2017
@version 1.0
/*/
//-------------------------------------------------------------------

Class GFERestModel From FwRestModel
    Method Activate()
    Method DeActivate()
EndClass

Method Activate() Class GFERestModel
    IsRest := .T.
Return _Super:Activate()

Method DeActivate() Class GFERestModel
    IsRest := .F.
Return _Super:DeActivate()

Function GFEIsRest()
Return IsRest 

/* Publicação dos modelos que são disponibilizados no REST */

PUBLISH MODEL REST NAME GFEA014 SOURCE GFEA014 RESOURCE OBJECT GFERestModel       //Cadastro de Tipos de Itens
PUBLISH MODEL REST NAME GFEA015 SOURCE GFEA015 RESOURCE OBJECT GFERestModel       //Cadastro de Emitentes de Transporte
PUBLISH MODEL REST NAME GFEA029 SOURCE GFEA029 RESOURCE OBJECT GFERestModel       //Cadastro de Frete Referência
PUBLISH MODEL REST NAME GFEA030 SOURCE GFEA030 RESOURCE OBJECT GFERestModel       //Cadastro de Tipos de Ocorrência
PUBLISH MODEL REST NAME GFEA031 SOURCE GFEA031 RESOURCE OBJECT GFERestModel       //Cadastro de Motivos de Ocorrência
PUBLISH MODEL REST NAME GFEA032 SOURCE GFEA032 RESOURCE OBJECT GFERestModel       //Cadastro de Ocorrências
PUBLISH MODEL REST NAME GFEA041 SOURCE GFEA041 RESOURCE OBJECT GFERestModel		  //Cadastro de Tipos de Documentos de Carga
PUBLISH MODEL REST NAME GFEA042 SOURCE GFEA042 RESOURCE OBJECT GFERestModel		  //Cadastro de Classificação de Frete
PUBLISH MODEL REST NAME GFEA043 SOURCE GFEA043 RESOURCE OBJECT GFERestModel		  //Cadastro de Unitizadores de Carga
PUBLISH MODEL REST NAME GFEA044 SOURCE GFEA044 RESOURCE OBJECT GFERestModel		  //Documentos de Cargas
PUBLISH MODEL REST NAME GFEA045 SOURCE GFEA045 RESOURCE OBJECT GFERestModel       //Cadastro de Tipo de Veículo
PUBLISH MODEL REST NAME GFEA047 SOURCE GFEA047 RESOURCE OBJECT GFERestModel       //Cadastro de Tipo de Operação
PUBLISH MODEL REST NAME GFEA059 SOURCE GFEA059 RESOURCE OBJECT GFERestModel       //Requisição de Negociação de Frete
PUBLISH MODEL REST NAME GFEA079 SOURCE GFEA079 RESOURCE OBJECT GFERestModel       //Contratos TransportePUBLISH MODEL REST NAME GFEA079 SOURCE GFEA079 RESOURCE OBJECT GFERestModel       //Contratos Transporte

