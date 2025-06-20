#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"                              

/*/{Protheus.doc} PLMIBA8M
Somente para compilar

@author Alexander Santos
@since 11/02/2014
@version P11
/*/

function PLMIBA8M
return

/*/{Protheus.doc} ModelDef
ModelDef utilizado para importacao com LAYOUT MILE.

@author Alexander Santos
@since 11/02/2014
@version P11
/*/
static function ModelDef()
local oBA8C	:= PLSABA8C():new()
local oStruM	:= FWFormStruct(oBA8C:getModelOperation(), oBA8C:getAlias(0))
local oStruD	:= FWFormStruct(oBA8C:getModelOperation(), oBA8C:getAlias(1))
local oModel	:= MPFormModel():New( oBA8C:getModel(0),/*bPreValidacao*/,{|oModel| oBA8C:MDPosVLD(oModel,oBA8C:getAlias(0))},{|oModel| oBA8C:MDCommit(oModel,oBA8C:getAlias(0)) }, /*bCancel*/ )  /*bPosValidacao*/ /*bCommit*/
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Adiciona a strutura de campos ao modelo - mestre									 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
oModel:addFields(oBA8C:getModelId(0),/*cOwner*/,oStruM)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Inclus�o apenas para utilizacao na importacao MILE									 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
oModel:addGrid(oBA8C:getModelId(1), oBA8C:getModelId(0), oStruD,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� modelo filho e opcional									 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
oModel:getModel(oBA8C:getModelId(1)):setOptional(.t.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Adiciona relacionamento entre tabelas BD4									 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
oModel:setRelation(oBA8C:getModelId(1), {	{'BD4_FILIAL', 'xFilial("BD4")'},;
												{'BD4_CODTAB', 'BA8_CODTAB'},;
												{'BD4_CDPADP', 'BA8_CDPADP'},;
												{'BD4_CODPRO', 'BA8_CODPRO'}},;
												BD4->(indexKey(1)))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Defini a descricao da tela												 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
oModel:setDescription(oBA8C:getTitulo(0))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Fim da rotina															 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
return oModel