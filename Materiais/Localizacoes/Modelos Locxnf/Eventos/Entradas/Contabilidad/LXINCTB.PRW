#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"

/*/{Protheus.doc} LXINCTB
Clase responsable por el evento de reglas de negocio de 
localizaci�n padr�n

@type 		Class
@author 	laura.medina
@version	12.1.2210 / Superior
@since		05/2023
/*/
Class LXINCTB From FwModelEvent

    //Propiedades que pueden ser alteradas desde los eventos con localizaci�n
    DATA oTipoDoc as object

    Method New() CONSTRUCTOR
    Method Activate()
    Method VldActivate()
    Method ModelPosVld()
    Method GridPosVld()
    Method GridLinePosVld()

EndClass


/*/{Protheus.doc} New
Metodo responsable de la contrucci�n de la clase.

@type 		Method
@author 	laura.medina
@version	12.1.2210 / Superior
@since		05/2023
/*/
Method New() Class LXINCTB 

Return Nil


/*/{Protheus.doc} Activate
Metodo activate

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		lCopy    ,caracter	,Informa si el model debe copiar los datos del registro posicionado.
@author 	laura.medina
@version	12.1.2210 / Superior
@since		05/2023
/*/
Method Activate(oModel, lCopy) Class LXINCTB

    self:oTipodoc := TipoDoc():New()

Return

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		cModelID ,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	laura.medina
@version	12.1.2210 / Superior
@since		05/2021 
/*/
Method VldActivate(oModel, cModelId) Class LXINCTB
Local lRet := .T.

Return lRet

/*/{Protheus.doc} ModelPosVld
M�todo responsable por ejecutar las valida�ioes de las reglas de negocio
gen�ricas del cadastro antes de la grabaci�n del formulario.
Si retorna falso, no permite grabar.

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		cModelID ,caracter	,Identificador do sub-modelo.
@Return     lRet, logico, Retorno de las validaciones.
@author 	laura.medina
@version	12.1.2210 / Superior
@since		05/2023
/*/
Method ModelPosVld(oModel, cModelId) Class LXINCTB
Local lRet      := .T.  
Local dDataRef  
Local dDataBloq	:= GetNewPar("MV_ATFBLQM",CTOD("")) //Data de Bloqueio da Movimenta��o - MV_ATFBLQM
Local oModelSF1 := oModel:GetModel("SF1_MASTER")
Local aArea     := {}

    aArea := GetArea()
     //Verifica se existe bloqueio cont�bil
    dDataRef    := oModelSF1:GetValue("F1_EMISSAO") //M->F1_EMISSAO

    If  !(Empty(dDataRef)) .And. (lRet := CtbValiDt(Nil,dDataRef,/*.T.*/ ,Nil ,Nil ,{"COM001"}/*,"Data de apura��o bloqueada pelo calend�rio cont�bil."*/))
        If!Empty(dDataBloq) .AND. (dDataRef <= dDataBloq)
            Help(" ",1,"ATFCTBBLQ") //P: Processo bloqueado pelo Calend�rio Cont�bil ou par�metro de bloqueio nesta data ou per�odo. S: Caso poss�vel altere a data de refer�ncia do processo, verifique o par�metro ou contate o respons�vel pelo M�dulo Cont�bil.)
            lRet := .F.
        End
    EndIf

    RestArea(aArea)

 Return lRet

/*/{Protheus.doc} GridPosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validaci�n de grid.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@Return     lRet, logico, Retorno de las validaciones.
@author 	laura.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method GridPosVld(oSubModel, cModelID) Class LXINCTB
Local lRet      := .T.

Return lRet

/*/{Protheus.doc} GridLinePosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validaci�n de l�nea.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@param 		nLine		,numerico	,N�mero de l�nea validada
@Return     lRet, logico, Retorno de las validaciones.
@author 	laura.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class LXINCTB
Local lRet      := .T.

Return lRet
