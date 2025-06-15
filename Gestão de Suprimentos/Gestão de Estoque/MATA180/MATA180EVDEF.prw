#Include "PROTHEUS.CH"
#include "Mata180.ch"
#include "FWMVCDef.ch"

/*/{Protheus.doc} MATA180EVDEF
Eventos padr�o do Complemento de Produto, as regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente. 

Todas as valida��es de modelo, linha, pr� e pos, tamb�m todas as intera��es com a grava��o
s�o definidas nessa classe.

Importante: Use somente a fun��o Help para exibir mensagens ao usuario, pois apenas o help
� tratado pelo MVC. 

Documenta��o sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
CLASS MATA180EVDEF FROM FWModelEvent
	
	DATA nOpc	
	DATA cIDSB5	
	DATA lHistFiscal	
	DATA bCampoSB5	
	DATA aCmps
	
	METHOD New() CONSTRUCTOR
	METHOD FieldPosVld()
	METHOD InTTS()
	METHOD ModelPosVld(oModel, cModelId)
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New(cID) CLASS MATA180EVDEF
Default cID := "SB5MASTER"

	::cIDSB5 := cID
	
	::lHistFiscal := HistFiscal()
		
	::bCampoSB5 := { |x| SB5->(Field(x)) }
	
	::aCmps := {}
	
Return

METHOD FieldPosVld(oModel, cID) CLASS MATA180EVDEF
Local lRet := .T.
Local cCodigo

	If cID == ::cIDSB5
		::nOpc := oModel:GetOperation()		
		
		If ::nOpc == MODEL_OPERATION_DELETE
			cCodigo := oModel:GetValue(::cIDSB5, "B5_COD")

			If IntDl(cCodigo)
				lRet := WmsVlDelB5(cCodigo)
			EndIf
		EndIf	
	
	EndIf
			
Return lRet

METHOD InTTS(oModel, cID) CLASS MATA180EVDEF

Local nPos := 0

	If ::nOpc == MODEL_OPERATION_DELETE .Or. ::nOpc == MODEL_OPERATION_UPDATE
		If ::lHistFiscal .And. Len(::aCmps) > 0
			nPos := Ascan(::aCmps,{ |x| x[1] == 'B5_IDHIST' } )
			::aCmps[nPos][2] := SB5->B5_IDHIST
			GrvHistFis("SB5", "SS5", ::aCmps)			
		EndIf
	EndIf
	
Return

/*/{Protheus.doc} ModelPosVld
M�todo de p�s valida��o do modelo de dados
@author douglas.heydt
@since 23/01/2020
@version 1.0

@param oModel	- Modelo de dados que ser� validado
@param cModelId	- ID do modelo de dados que est� sendo validado.

@return lReturn	- Indica se o modelo foi validado com sucesso.
/*/
METHOD ModelPosVld(oModel, cModelId) CLASS MATA180EVDEF

	Local lReturn   := .T.
	Local nOpc      := oModel:GetOperation()
	Local oModelSB5 := oModel:GetModel(::cIDSB5)
	Local cProduto  := ""
	Local aAreaSG1  := SG1->(GetArea())
	Local nRecnoSB5 := 0
	
	cProduto := oModel:GetValue(::cIDSB5, "B5_COD")

	::nOpc := oModel:GetOperation()
    
	If cModelId == "MATA180" .And. (nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE)

		If M->B5_PROTOTI
			
			SG1->(dbSetOrder(1))
			If SG1->(DbSeek(xFilial("SG1") + cProduto))
				lReturn := .F.
				Help( ,  , "A180PROTOT", ,  STR0032,; //"O produto n�o pode ser definido como prot�tipo pois faz parte de uma estrutura."
					 1, 0, , , , , , {""}) 
			EndIf
			
			SG1->(dbSetOrder(2))
			If lReturn .And. SG1->(DbSeek(xFilial("SG1") + cProduto))
				lReturn := .F.
				Help( ,  , "A180PROTOT", ,  STR0032,; //"O produto n�o pode ser definido como prot�tipo pois faz parte de uma estrutura."
					 1, 0, , , , , , {""}) 
			EndIf

		EndIf
	EndIf

	If ::nOpc == MODEL_OPERATION_DELETE	.Or. ::nOpc == MODEL_OPERATION_UPDATE		
		If ::lHistFiscal
			nRecnoSB5 := SB5->(RECNO())
			SB5->(dbSeek(xFilial("SB5")+cProduto))
			
			If ::nOpc == MODEL_OPERATION_UPDATE
				oModelSB5:SetValue("B5_IDHIST",IdHistFis())
			EndIf

			::aCmps := RetCmps("SB5",::bCampoSB5)

			SB5->(dbGoTo(nRecnoSB5))
		EndIf			
	EndIf

	RestArea(aAreaSG1)
Return lReturn
