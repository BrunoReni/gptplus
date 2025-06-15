#include "MATA019.CH"
#include "Protheus.CH"
#include "FWMVCDef.CH"

/*/{Protheus.doc} MATA019EVDEF
Eventos padr�o do Indicador de Produto, as regras definidas aqui se aplicam a todos os paises.
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
CLASS MATA019EVDEF FROM FWModelEvent
	
	DATA cIDSBZ       As Character
	DATA cIDSB1       As Character
	DATA cIdHist      As Character
	
	DATA lHistFiscal  As Logical
	
	DATA aCmps        As Array
	
	DATA bCampoSBZ    As Block

	Data cFilBkp      As Character
	
	METHOD New() CONSTRUCTOR
	
	METHOD GridLinePosVld()
	METHOD GridLinePreVld()
	METHOD GridPosVld()
	METHOD Before()
	METHOD After()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New(cIDSB1, cIDSBZ) CLASS MATA019EVDEF
Default cIDSB1 := "SB1MASTER"
Default cIDSBZ := "SBZDETAIL"
	
	::cFilBkp := cFilAnt
	
	::cIDSB1 := cIDSB1
	::cIDSBZ := cIDSBZ
	
	::aCmps := {}
	::bCampoSBZ := { |x| SBZ->(Field(x)) }
		
	::lHistFiscal := HistFiscal()
	If ::lHistFiscal
		::cIdHist  := IdHistFis()
	EndIf	
Return

/*/{Protheus.doc} GridLinePosVld
Obriga que o usuario digite uma filial. 

@type metodo
 
@author Juliane Venteu
@since 27/03/2017
@version P12.1.17
 
/*/
METHOD GridLinePosVld(oSubModel, cID, nLine) CLASS MATA019EVDEF
Local lRet := .T.	
Local nOpc := oSubModel:GetOperation()
	
	If cID == ::cIDSBZ	
		If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
			If Empty(oSubModel:GetValue("BZ_FILIAL"))
				Help( ,, 'Help',, STR0010, 1, 0 ) //Campo de Filial Vazio				
				lRet:= .F.
			EndIf
		EndIf		
	EndIf
	
Return lRet

/*/{Protheus.doc} GridPosVld
P�s valida��o do grid, verifica se o produto existe em todas as filiais, caso
o produto seja exclusivo por filial.

@type metodo
 
@author Juliane Venteu
@since 27/03/2017
@version P12.1.17
 
/*/
METHOD GridPosVld(oSubModel, cID) CLASS MATA019EVDEF
Local lRet := .T.
Local nX
Local nLine
Local aAreaSB1 := SB1->(GetArea())
Local cFilSBZ
Local cProduto 
Local nOpc 
	
	If cID == ::cIDSBZ
		nOpc := oSubModel:getOperation()
		
		If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
			If FWModeAccess("SB1",3) == "E"
				
				SB1->(DbSetOrder(1))
													
				For nX:=1 to oSubModel:Length()				
					If !oSubModel:IsDeleted()					
						cFilSBZ := oSubModel:GetValue("BZ_FILIAL", nX)
											
						If SB1->(!DbSeek(xFilial("SB1",cFilSBZ) + M->B1_COD))
							Help( ,, 'Help',, STR0017, 1, 0 )							
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next nX			
			EndIf
		EndIf

		cFilAnt := ::cFilBkp
	EndIf

RestArea(aAreaSB1)	
Return lRet

/*/{Protheus.doc} GridLinePreVld
Valida��es especificas do campo BZ_FILIAL, se na� atender a todas as condi��es, n�o
deixa o usuario finalizar a edi��o do campo.

@type metodo
 
@author Juliane Venteu
@since 27/03/2017
@version P12.1.17
 
/*/
METHOD GridLinePreVld(oSubModel, cID, nLine, cAction, cFieldID, xValue, xCurrentValue) CLASS MATA019EVDEF
Local lRet := .T.
Local aSB2Area	:= SB2->( GetArea() )
Local cFilSBZ
Local aAreaSB1
Local cBkpFil	:= cFilAnt
Local cBZLocaliz:= Nil
Local cB1Localiz:= Nil
Local nQtdSB2	:= 0
Local nQtdSB9	:= 0
Local nQtdSBF	:= 0
Local cLocaliz 	:= Nil

dbSelectArea( "SB2" )
SB2->( dbSetOrder( 1 ) )

If cID == ::cIDSBZ
	If cAction == "SETVALUE"
		Do Case
		Case cFieldID == "BZ_FILIAL"
			cFilSBZ := xValue
			
			If Empty(cFilSBZ)
				Help( ,, 'Help',, STR0010, 1, 0 ) //"O campo filial deve ser preenchido"					
				lRet := .F.					
			ElseIf !FWFilExist(,cFilSBZ)
				Help( ,, 'Help',, STR0013, 1, 0 ) //Campo de Filial n�o cadastrada
				lRet := .F.					
			ElseIf FWModeAccess("SB1",3) == "E"	
				aAreaSB1 := SB1->(GetArea())
				SB1->(dbSetOrder(1))
				
				If SB1->(!dbSeek(xFilial("SB1", cFilSBZ) + M->B1_COD))
					Help( ,, 'Help',, STR0014, 1, 0 ) //N�o existe produto cadastrado para esta filial
					lRet := .F.
				EndIf
				
				RestArea(aAreaSB1)
			EndIf
			
			If lRet
				cFilAnt := cFilSBZ
			EndIf			
		Case cFieldID == "BZ_LOCALIZ"
			cBZLocaliz 	:= xValue
			cB1Localiz 	:= GetMemVar( 'B1_LOCALIZ' )
			cFilAnt		:= oSubModel:GetValue( 'BZ_FILIAL' )
			cLocaliz 	:= SuperGetMv( "MV_LOCALIZ",.F., "N" )

			If cLocaliz == "S"
				nQtdSBF 	:= SaldoSBF( GetMemVar( 'B1_LOCPAD' ) , Nil, GetMemVar( 'B1_COD' ) )
				lFound 		:= SB2->( dbSeek( FWxFilial( 'SB2' ) + GetMemVar( 'B1_COD' ) + GetMemVar( 'B1_LOCPAD' ) ) )
				nQtdSB2		:= IIf( lFound, SaldoSB2(), 0 )
				nQtdSB9		:= IIf( lFound, SB2->B2_QACLASS, 0 )
				
				If lRet .And. nQtdSBF > 0 .And. ( ( cB1Localiz == "N" .And. ( cBZLocaliz == "N" .Or. Empty( cBZLocaliz ) ) ) .Or. ( cB1Localiz == "S" .And. ( cBZLocaliz == "N" .Or. Empty( cBZLocaliz ) ) ) .Or. ( cB1Localiz == "N" .And. ( cBZLocaliz == "S" .Or. Empty( cBZLocaliz ) ) ) )
					Help(" ",1,"TEMLOCALIZ")
		 			lRet := .F.
				EndIf

				If lRet .And. nQtdSB2 > 0 .And. ( ( cB1Localiz == "N" .And. ( cBZLocaliz == "N" .Or. Empty( cBZLocaliz ) ) ) .Or. ( cB1Localiz == "S" .And. ( cBZLocaliz == "N" .Or. Empty( cBZLocaliz ) ) ) .Or. ( cB1Localiz == "N" .And. ( cBZLocaliz == "S" .Or. Empty( cBZLocaliz ) ) ) )
					MSGALERT(STR0024)// "Como existe Saldo Fisico para este  produto � necess�rio que seja executado  o Programa 'Cria Endere�o' MATA805 para  adequa��o do Saldo por Endere�o."
					lRet := .T.
				EndIf

				If lRet .And. nQtdSB9 > 0 .And. ( ( cB1Localiz == "N" .And. ( cBZLocaliz == "N" .Or. Empty( cBZLocaliz ) ) ) .Or. ( cB1Localiz == "S" .And. ( cBZLocaliz == "N" .Or. Empty( cBZLocaliz ) ) ) .Or. ( cB1Localiz == "N" .And. ( cBZLocaliz == "S" .Or. Empty( cBZLocaliz ) ) ) )
					Help(" ",1,"ATUALOCALI")
					lRet := .F.
				EndIf
			ElseIf cLocaliz == "N"
				If cBZLocaliz == "S"
					Help(" ",1,"NAOLOCALIZ")
					lRet := .F.
				ElseIf cBZLocaliz == "N"
					lRet := .T.
				EndIf
			EndIf
			cFilAnt := cBkpFil
		EndCase

	EndIf
EndIf

RestArea( aSB2Area )
Return lRet

/*/{Protheus.doc} Before
Antes da grava��o de cada linha do indicador, carrega os campos para
grava��o do historico de altera��o.

@type metodo
 
@author Juliane Venteu
@since 27/03/2017
@version P12.1.17
 
/*/
METHOD Before(oSubModel, cID, cAlias, lNewRecord) CLASS MATA019EVDEF
Local nOpc := oSubModel:GetOperation()
Local nRecnoSBZ := 0
Local cProduto

	If cID == ::cIDSBZ
		cFilAnt  := oSubModel:GetValue("BZ_FILIAL")
		cProduto := M->B1_COD
		
		If nOpc == MODEL_OPERATION_DELETE .Or. nOpc == MODEL_OPERATION_UPDATE
			 If ::lHistFiscal
				nRecnoSBZ := SBZ->(RECNO())
				SBZ->(dbSeek(xFilial("SBZ")+cProduto))
				::aCmps := RetCmps("SBZ",::bCampoSBZ)

				If nOpc == MODEL_OPERATION_UPDATE
					oSubModel:SetValue("BZ_IDHIST",::cIdHist)
				EndIf
				
				SBZ->(dbGoTo(nRecnoSBZ))		
			EndIf
		EndIf

	EndIf
	
Return

/*/{Protheus.doc} After
Ap�s a grava��o de cada linha do indicador, integra com o Loja
e grava o historico fiscal

@type metodo
 
@author Juliane Venteu
@since 27/03/2017
@version P12.1.17
 
/*/
METHOD After(oSubModel, cID, cAlias, lNewRecord) CLASS MATA019EVDEF
Local oProcessOff 	:= Nil				   							//Objeto do tipo LJCProcessoOffLine
Local lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)			//Identifica se o ambiente esta operando em offline
Local nOpc 			:= oSubModel:GetOperation()
Local cTipo 
Local nPos		 	:= 0

	If cID == ::cIDSBZ
		//Verifica se o ambiente esta em off-line
		If lAmbOffLn
			//Instancia o objeto LJCProcessoOffLine
			oProcessOff := LJCProcessoOffLine():New("031")
			                                                               
			
			//Determina o tipo de operacao, quando n�o enviado no parametro
			If nOpc == MODEL_OPERATION_INSERT
				cTipo := "INSERT"
			ElseIf nOpc == MODEL_OPERATION_UPDATE
				cTipo := "UPDATE"
			Else
				cTipo := "DELETE"		
			
				//Considera os registros deletados
				SET DELETED OFF			                
			EndIf
					    
			//Insere os dados do processo (registro da tabela)
			oProcessOff:Inserir("SBZ", xFilial("SBZ") + SBZ->BZ_COD, 1, cTipo)	
		
			//Processa os dados 
			oProcessOff:Processar()	
		
			//Desconsidera os registros deletados
			SET DELETED ON
		EndIf
		
		If nOpc == MODEL_OPERATION_DELETE .Or. nOpc == MODEL_OPERATION_UPDATE
			If ::lHistFiscal .And. Len(::aCmps) > 0
				nPos := Ascan(::aCmps,{ |x| x[1] == 'BZ_IDHIST' } )
				::aCmps[nPos][2] := SBZ->BZ_IDHIST
				GrvHistFis("SBZ", "SS6", ::aCmps)
			EndIf
		EndIf

		cFilAnt := ::cFilBkp
	EndIf
Return
