#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA806
Funcao para abrir Agendamento de Capta��o
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLSRPS4(lAutoma)

Local oBrowse
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 //Para fins de automa��o

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B4K')
oBrowse:SetDescription('Lote RPS')
iif(!lAutoma, oBrowse:Activate(), '')

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

Add Option aRotina Title 'Visualizar' Action 'VIEWDEF.PLSRPS5' Operation 2 Access 0
Add Option aRotina Title 'Incluir'    Action 'processa( {|| PRPS5ZZZ()}, "Gera��o de Lote RPS", "Verificando base de dados...", .f.)'		Operation 3 Access 0 //processa( {|| PLSEEXC(nPos) }, "Protocolo", "Excluindo registros...", .f.)
Add Option aRotina Title 'Gerar RPS'  Action 'PRPSIMPARQ()' 	Operation 4 Access 0
Add Option aRotina Title 'Informar negativa ANS'  Action 'PLRPSNEG(.F.)' Operation 4 Access 0

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel // Modelo de dados constru�do
Local oStrB4K:= FWFormStruct(1,'B4K')// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que ir�considerar

oModel := MPFormModel():New( 'PLSRPS4' , , {|| PLSRPS4VLD(oModel) }) // Cria o objeto do Modelo de Dados e insere a fun�ao de p�s-valida��o

oModel:addFields('MasterB4K',/*cOwner*/,oStrB4K)  // Adiciona ao modelo um componente de formul�rio

oModel:GetModel('MasterB4K'):SetDescription('Lote RPS') // Adiciona a descri��o do Modelo de Dados

oModel:SetPrimaryKey( {"B4K_FILIAL", "B4K_CODOPE", "B4K_NUMLOT"} )

Return oModel // Retorna o Modelo de dados


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do interface
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oView  // Interface de visualiza��o constru�da
Local oModel := FWLoadModel( 'PLSRPS4' ) // Cria as estruturas a serem usadas na View
Local oStrB4K:= FWFormStruct(2, 'B4K' )

oView := FWFormView():New() // Cria o objeto de View

oView:SetModel(oModel)		// Define qual Modelo de dados ser� utilizado

oView:AddField('ViewB4K' , oStrB4K,'MasterB4K' ) // Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)

oView:CreateHorizontalBox( 'SUPERIOR' , 100 ) // Cria um "box" horizontal para receber cada elemento da view e Associa � Aba Correspondente

oView:SetOwnerView('ViewB4K','SUPERIOR') // Relaciona o identificador (ID) da View com o "box" para exibi��o

Return oView // Retorna o objeto de View criado


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRPS4VLD
Valida��o e confirma��o da gera��o do lote RPS
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLSRPS4VLD(oModel)

Local cMsg := ""
Local lRet := .F.
Local oB4K := oModel:getModel("MasterB4K")

oModel:Activate()

If PLSRPSCHK(oB4K:getvalue("B4K_TIPARQ"), oB4K:getValue("B4K_CODOPE"),oB4K:getValue("B4K_TIPCAB") )	
//	Help(NIL, NIL, "Texto do Help", NIL, "Texto do Problema", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Texto da Solu��o"})
	Help(NIL, NIL, 'N�o � poss�vel Incluir', NIL, 'N�o � poss�vel incluir um lote deste tipo, pois h� outro do mesmo tipo em aberto.', 1, 0, NIL, NIL, NIL, NIL, NIL, {"Para incluir um novo � necess�rio finalizar o atualmente aberto"})
else
	cMsg += " Ser� gerado um novo lote RPS com os seguinte par�metros: " + CRLF
	cMsg += " - Tipo de Lote : " + oB4K:getvalue("B4K_TIPARQ") + CRLF
	cMsg += " - Isen��o �nus : " + oB4K:getvalue("B4K_ISENON") + CRLF
	cMsg += " - N�mero da GRU: " + oB4K:getvalue("B4K_NUMGRU") + CRLF
	cMsg += CRLF + " Confirma a gera��o? "
	If MsgYesNo( cMsg, "Confirma��o da gera��o")
		lRet := .T.
	else
		Help(NIL, NIL, 'Informa��o', NIL, 'Gera��o Cancelada', 1, 0, NIL, NIL, NIL, NIL, NIL)
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLRPSNEG
Informa o retorno negativo da ANS quanto � um arquivo gerado
@author Oscar Zanin
@since 15/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLRPSNEG(lAutoma)
Local lProcessa := .F.
Local cCodOpe	  := PLSINTPAD()
Local cStaRPS	  := ""
Local cAntRPS	  := ""
Local lret := .F.
default lAutoma := iif(valtype(lAutoma) <> "L", .F., lAutoma )	

//0=Inclus�o;1=Altera��o;2=Vincula��o;3=Exclus�o
//B4K_TIPARQ
//0=Nao Enviado; 1=Enviado; 2=Excluido;3=Enviar Altera��o;4=enviar Exclus�o
If  B4K->B4K_STATUS == "1"
	If lAutoma .Or. MsgYesNo("Esta op��o deve ser utilizada para informar que um arquivo n�o foi acatado pela ANS." + CRLF + "Deseja prosseguir?")
		If lAutoma .Or. MsgYesNo("O lote atual ser� Aberto para que as inconsist�ncias possam ser corrigidas na base de dados, confirma a a��o?")
			Begin Transaction
				B5B->(dbSetOrder(1))
				BAU->(dbsetOrder(1))
				lProcessa := .T.
				B4K->(RecLock("B4K", .f.))
					B4K->B4K_STATUS := "0"
					B4K->B4K_DATARQ := dDataBase
				B4K->(MsUnLock())
				
				If B4K->B4K_TIPARQ == "0"
					cStaRPS := "0"
					cAntRPS := "1"
				elseif B4K->B4K_TIPARQ == "1"
					cStaRPS := "3"
					cAntRPS := "1"
				elseIf B4K->B4K_TIPARQ == "3"
					cStaRPS := "4"
					cAntRPS := "2"
				endIf
				
				If !(EmpTy(cStaRPS))
					B5B->(MsSeek(xfilial("B5B") + cCodOpe + B4K->B4K_NUMLOT))
					While xfilial("B5B") + cCodOpe + B4K->B4K_NUMLOT == B5B->(B5B_FILIAL+B5B_CODOPE+B5B_NUMLOT) .AND. !(B5B->(eoF()))
						If BAU->(msSeek(xfilial("BAU") + B5B->B5B_CODRDA)) .AND. BAU->BAU_ENVRPS == cAntRPS
							BAU->(RecLock("BAU", .f.))
								BAU->BAU_ENVRPS := cStaRPS
							BAU->(MsUnLock())
						endIf
						B5B->(dbskip())
					EndDo
				endIf
			end transaction
		endIf
	EndIf
else
	Help(NIL, NIL, "Aten��o", NIL, "Esta op��o deve ser utilizada somente ap�s o envio do arquivo e retorno negativo da ANS. ", 1, 0, NIL, NIL, NIL, NIL, NIL, {"O registro atual est� com situa��o 'em Aberto', pois o arquivo ainda n�o foi gerado"})
endIf
If !lProcessa
	Help(NIL, NIL, "Aten��o", NIL, "Opera��o N�o realizada", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
Else
	lret := .T.
	Help(NIL, NIL, "Aten��o", NIL, "Opera��o Conclu�da", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
endIf

Return lret