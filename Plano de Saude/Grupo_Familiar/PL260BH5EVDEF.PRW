#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "PLSA260.ch"

/*/{Protheus.doc} PL260BH5EVDEF
Classe Responsavel pelo Evento de valida��es e  
atualiza��es do cadastro de Gratuidade
@author    Roberto Barbosa
@since     15/08/2019
/*/
Class PL260BH5EVDEF From FwModelEvent
Data auMovStatus	As Array
Data oModel			As Object

Method New() Constructor
//Method AfterTTS( oModel, cIdModel  )
//Method After(oSubModel, cModelId, cAlias, lNewRecord)
Method ModelPreVld( oModel, cModelId )
//Method ModelPosVld( oModel, cModelId )
//Method Before(oModel, cModelId)
//Method FieldPreVld(oModel, cModelID, cAction, cId, xValue)
//Method BeforeTTS(oModel, cModelId)
//Method InTTS(oModel, cModelId)

EndClass

/*/{Protheus.doc} new
Metodo construtor da classe
@author    Roberto Barbosa
@since     15/08/2019
/*/
Method new() Class PL260BH5EVDEF
Self:oModel 	:= Nil
Self:auMovStatus:= {}

Return Self

/*/{Protheus.doc} After
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit
depois da grava��o de cada submodelo (field ou cada linha de uma grid)
@author    Roberto Barbosa
@since     15/08/2019
/*/
//Method After(oSubModel, cModelId, cAlias, lNewRecord) Class PL260BH5EVDEF
//Local lRet := .T.
//Return lRet

/*/{Protheus.doc} BeforeTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit antes da transa��o.
Esse evento ocorre uma vez no contexto do modelo principal.
@author    Roberto Barbosa
@since     15/08/2019
/*/
//Method BeforeTTS(oModel, cModelId) Class PL260BH5EVDEF
//Local lRet := .T.
//Return lRet

/*/{Protheus.doc} InTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit Ap�s as grava��es por�m 
antes do final da transa��o.
Esse evento ocorre uma vez no contexto do modelo principal.

@author    Roberto Barbosa
@since     15/08/2019
/*/
//Method InTTS(oModel, cModelId) Class PL260BH5EVDEF
//Local lRet := .T.
//Return lRet


/*/{Protheus.doc} ModelPreVld
Metodo responsavel por realizar a pre valida��o do modelo
@author    Roberto Barbosa
@since     15/08/2019
/*/
Method ModelPreVld( oModel, cModelId ) Class PL260BH5EVDEF
LOCAL nOperation := oModel:GetOperation()
Local nTamUsuari := TamSX3("BH5_USUARI")[1]
    
    If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE).AND. Empty(oModel:GetValue('BH5DETAIL',  'BH5_CODINT'))
        oModel:LoadValue( 'BH5DETAIL', 'BH5_FILIAL' , xFilial("BH5"))
        oModel:LoadValue( 'BH5DETAIL', 'BH5_CODINT' , PLSINTPAD())
        oModel:LoadValue( 'BH5DETAIL', 'BH5_CODEMP' , BA1->BA1_CODEMP)
        oModel:LoadValue( 'BH5DETAIL', 'BH5_MATRIC' , BA1->BA1_MATRIC)
        oModel:LoadValue( 'BH5DETAIL', 'BH5_USUARI' , SUBSTR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),1,nTamUsuari))
        oModel:LoadValue( 'BH5DETAIL', 'BH5_USUOPE' , PLRETOPE())

    EndIf

Return .T.


//Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class PL260BH5EVDEF
//Return .T.

/*/{Protheus.doc} ModelPosVld
Metodo responsavel por realizar a pos valida��o do modelo
@author    Roberto Barbosa
@since     15/08/2019
/*/
//Method ModelPosVld( oModel, cModelId ) Class PL260BH5EVDEF
//Return .T.

/*/{Protheus.doc} AfterTTS
Metodo Utilizado apos Concluido o Commit do Modelo
Realizo as integra��es
@author    Roberto Barbosa
@since     15/08/2019
/*/
//Method AfterTTS( oModel, cIdModel ) Class PL260BH5EVDEF
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
//Method FieldPreVld(oModel, cModelID, cAction, cId, xValue) Class PL260BH5EVDEF
//Return .T.