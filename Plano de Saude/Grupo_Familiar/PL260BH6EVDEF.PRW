#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "PLSA260.ch"

/*/{Protheus.doc} PL260BH6EVDEF
Classe Responsavel pelo Evento de valida��es e  
atualiza��es do cadastro de Gratuidade
@author    Roberto Barbosa
@since     21/08/2019
/*/
Class PL260BH6EVDEF From FwModelEvent
Data auMovStatus	As Array
Data oModel			As Object

Method New() Constructor
//Method AfterTTS( oModel, cIdModel  )
//Method After(oSubModel, cModelId, cAlias, lNewRecord)
//Method ModelPreVld( oModel, cModelId )
Method ModelPosVld( oModel, cModelId )
//Method Before(oModel, cModelId)
//Method FieldPreVld(oModel, cModelID, cAction, cId, xValue)
//Method BeforeTTS(oModel, cModelId)
//Method InTTS(oModel, cModelId)

EndClass

/*/{Protheus.doc} new
Metodo construtor da classe
@author    Roberto Barbosa
@since     21/08/2019
/*/
Method new() Class PL260BH6EVDEF
Self:oModel 	:= Nil
Self:auMovStatus:= {}

Return Self

/*/{Protheus.doc} After
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit
depois da grava��o de cada submodelo (field ou cada linha de uma grid)
@author    Roberto Barbosa
@since     21/08/2019
/*/
//Method After(oSubModel, cModelId, cAlias, lNewRecord) Class PL260BH6EVDEF
//Return .T.

/*/{Protheus.doc} BeforeTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit antes da transa��o.
Esse evento ocorre uma vez no contexto do modelo principal.
@author    Roberto Barbosa
@since     21/08/2019
/*/
//Method BeforeTTS(oModel, cModelId) Class PL260BH6EVDEF
//Return .T.

/*/{Protheus.doc} InTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit Ap�s as grava��es por�m 
antes do final da transa��o.
Esse evento ocorre uma vez no contexto do modelo principal.

@author    Roberto Barbosa
@since     21/08/2019
/*/
//Method InTTS(oModel, cModelId) Class PL260BH6EVDEF
//Return .T.

/*/{Protheus.doc} ModelPreVld
Metodo responsavel por realizar a pre valida��o do modelo
@author    Roberto Barbosa
@since     21/08/2019

/*/
//Method ModelPreVld( oModel, cModelId ) Class PL260BH6EVDEF
//Return .T.


/*/{Protheus.doc} ModelPreVld
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit
antes da grava��o de cada submodelo (field ou cada linha de uma grid)
@author    Roberto Barbosa
@since     21/08/2019
/*/
//Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class PL260BH6EVDEF
//Return .T.

/*/{Protheus.doc} ModelPosVld
Metodo responsavel por realizar a pos valida��o do modelo
@author    Roberto Barbosa
@since     30/08/2019
/*/
Method ModelPosVld( oModel, cModelId ) Class PL260BH6EVDEF
Local lRet := .F.

If oModel:GetModel('BH6DETAIL'):GetValue('BH6_MESINI') $ '01,02,03,04,05,06,07,08,09,10,11,12' .AND.;
        oModel:GetModel('BH6DETAIL'):GetValue('BH6_MESFIM') $ '01,02,03,04,05,06,07,08,09,10,11,12'

    lRet := .T.
Else
    lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} AfterTTS
Metodo Utilizado apos Concluido o Commit do Modelo
Realizo as integra��es
@author    Roberto Barbosa
@since     21/08/2019
/*/
//Method AfterTTS( oModel, cIdModel ) Class PL260BH6EVDEF
//Return .T.

/*/{Protheus.doc} FieldPreVld
M�todo que � chamado pelo MVC quando ocorrer a a��o de pr� valida��o do Field
@param oSubModel , Modelo principal
@param cModelId  , Id do submodelo
@param nLine     , Linha do grid
@param cAction   , A��o executada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param cId     , nome do campo
@param xValue    , Novo valor do campo

@author Roberto Barbosa
@since 13/08/2019
/*/
//Method FieldPreVld(oModel, cModelID, cAction, cId, xValue) Class PL260BH6EVDEF
//Return .T.