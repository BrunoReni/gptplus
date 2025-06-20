#Include "FISA173.ch"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "FWEditPanel.CH"

STATIC cLpApur		:= "767"
STATIC cLpExApur	:= "768"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA173()

Fun��o de apura��o dos tributos gen�ricos

@author Erick G Dias
@since 19/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA173()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F2H")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F2H")
    oBrowse:SetDescription(STR0001) //"Apura��o dos Tributos Gen�ricos"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) // Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal. //"Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Erick G Dias
@since 11/09/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION 'FSA173PROC()'   OPERATION 3 ACCESS 0 //"Processar"
ADD OPTION aRotina TITLE STR0004 ACTION 'FSA173VIS()'    OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0005 ACTION 'FSA173EDIT()'   OPERATION 4 ACCESS 0 //"Editar"
ADD OPTION aRotina TITLE STR0006 ACTION 'FSA173EXCL()'   OPERATION 5 ACCESS 0 //"Excluir"

// Se a fun��o de gera��o de t�tulos do financeiro n�o existir n�o adiciono os bot�es.
If FindFunction("FGrvImpFi")
	ADD OPTION aRotina TITLE STR0007 ACTION 'FSA173TIT("1")' OPERATION 4 ACCESS 0 //"Gerar T�tulo Financeiro"
	ADD OPTION aRotina TITLE STR0008 ACTION 'FSA173TIT("2")' OPERATION 4 ACCESS 0 //"Gerar T�tulo Financeiro/Contabiliza��o"
	ADD OPTION aRotina TITLE STR0037 ACTION 'FSA173TIT("3")' OPERATION 4 ACCESS 0 //"Contabilizar T�tulo Gerado"	
	ADD OPTION aRotina TITLE STR0009 ACTION 'FSA173VTIT()'   OPERATION 4 ACCESS 0 //"Visualizar T�tulo Gerado"
EndIf

If FindFunction("FISR161")
	ADD OPTION aRotina TITLE STR0041 ACTION 'FISR161()' OPERATION 4 ACCESS 0 //"Relat�rio de Confer�ncia de Apura��o"
EndIf

Return ( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do cadastro das regras de apura��o

@author Erick G Dias
@since 11/09/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai do cabe�alho da rotina
Local oCabecalho := FWFormStruct(1, "F2H" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA173')

//Atribuindo cabe�alho para o modelo
oModel:AddFields("FISA173",,oCabecalho)

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0001) //"Apura��o dos Tributos Gen�ricos"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Erick G Dias    
@since 19/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA173" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F2H")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA173' )
oView:CreateHorizontalBox( "CABEC" , 100 )
oView:SetOwnerView( "VIEW_CABECALHO" , "CABEC" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA173PROC
Fun��o que iniciar� o processamento da apura��o

@author Erick G Dias    
@since 19/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA173PROC()

Local aParam    := FISA175WIZ()
Local aFil      := {}
Local aReproc	:= {}
Local aAreaSM0 	:= SM0->(GetArea())
Local nX        := 0
Local nCont		:= 0
Local nRecnoTit	:= 0
Local cAliasF2H := ""
Local cTitOk	:= ""
Local cTitNotOk	:= ""
Local cNumTit	:= ""
Local cAlsTit	:= ""
Local lProc		:= .T.
Local oSay	 	:= nil

dbSelectArea("F2L")
F2L->(dbSetOrder(2)) //F2L_FILIAL+F2L_IDAPUR

If Len(aParam) > 0   

	aReproc	:= ChkApur(aParam) 

	IF aReproc[1]
		
		//J� existem apura��es processadas neste per�odo, questionar� o usu�rio se deseja prosseguir com apura��o.
		lProc	:= .F.
		lProc	:= ApMsgYesNo(aReproc[2] + CHR(13)+CHR(10)  + STR0010) //'Deseja prosseguir com o reprocessamento?'

		IF lProc

			//La�o para verificar a quest�o dos t�tulos  tributo a tributo 
			For nCont:=1  to len(aReproc[3])

				If !Empty(aReproc[3][nCont][1]) .And. F2L->(MsSeek(xFilial("F2L") + aReproc[3][nCont][1]))
					//Se entrou aqui possui t�tulo, precisa verificar ent�o se tem baixas
					//Verifica se os t�tulos podem ser exclu�dos
					IF !Empty(F2L->F2L_CHVFK7)						
						//Guarda a chave FK7
						aReproc[3][nCont][2]	:= F2L->F2L_CHVFK7
						//Verifica se pode excluir o t�tulo
						IF DelTit(F2L->F2L_CHVFK7, "1", "FISA173", @cNumTit)
							//Montar lista de t�tulos por tributo que podem ser exclu�dos
							cTitOk += cNumTit + CHR(13) + CHR(10)							
						Else
							//Montar lista de t�tulos por tributo que N�O podem ser exclu�dos							
							cTitNotOk += cNumTit + CHR(13) + CHR(10)							
						EndIF
					EndIF
				EndIF
			
			Next nCont

			//Se existem t�tulos na lista cTitNotOk, significa que estes t�tulos possuem baixa e o reprocessamento n�o poder� prosseguir
			If !Empty(cTitNotOk)
				MsgAlert(STR0011 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cTitNotOk ) //"Foram identificados t�tulos que possuem baixa, por este motivo o reprocessamento ser� interrompido."
				lProc	:= .F.
			ElseIF !EMpty(cTitOk)
				lProc	:= ApMsgYesNo(STR0012 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cTitOk  ) //"Confirma a exclus�o dos t�tulos abaixo?"
			EndIF

			IF lProc
				dbSelectArea("F2H")
				F2H->(dbSetOrder(3)) //F2H_FILIAL+F2H_ID
				
				For nCont:=1  to len(aReproc[3])
					//Deleta os t�tulos
					IF !Empty(aReproc[3][nCont][2])
						
						//Reverte a x173Contaba��o, caso tenha sido x173Contabado previamente.//Preciso posicionar a F2H tamb�m
						IF aReproc[3][nCont][3] == "5" .AND. x173PosTit(aReproc[3][nCont][2], @cAlsTit, @nRecnoTit) .AND. F2H->(MsSeek(xFilial("F2H") + aReproc[3][nCont][1]))
							x173Contab(cLpExApur, cAlsTit, nRecnoTit)
						EndIF
						
						//Deleta o t�tulo
						DelTit(aReproc[3][nCont][2], "2", "FISA173")

					EndIF				
					
					//Deleta a apura��o
					DelApur(aReproc[3][nCont][1])
				Next nCont
			EndIF
			dbSelectArea("F2H")
			F2H->(dbSetOrder(1))

		EndIF

	EndIF
	
	IF lProc
		aFil    := x173GetFil( aParam[3] == '1' )

		IF Len(aFil) > 0

			FwMsgRun(,{|oSay| x175Processa(aFil, aParam) },STR0013,"") //"Processando Apura��o dos Tributos Gen�ricos"

			RestArea (aAreaSM0)
			cFilAnt := FWGETCODFILIAL

			
			//Exibe mensagem de sucesso
			MsgInfo(STR0014) //"Apura��o Conclu�da com Sucesso !"

			//Se o usu�rio selecionou somente 1 tributo, abriremos a tela
			If Len( StrToKArr(aParam[4], "|") ) == 1
				FSA173EDIT()
			EndIF

		EndIF

	EndIF

EndIF

//Desabilita o loop de inclus�o
MbrChgLoop(.F.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA173VIS
Fun��o que faz a visualiza��o da apura��o.

@author Erick G Dias    
@since 19/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA173VIS()

If !Empty(F2H->F2H_ID)
	FISA174('1', STR0017 + F2H->F2H_TRIB + STR0018 + DTOC(F2H->F2H_DTINI) + STR0016 +  DTOC(F2H->F2H_DTFIN) + STR0015, F2H->F2H_ID) //' (Visualizando)' //' - Per�odo Final: ' //'Tributo: ' //' - Per�odo Inicial: '
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA173EDIT
FUn��o respons�vel por fazer edi��o na apura��o

@author Erick G Dias    
@since 19/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA173EDIT()

BEGIN TRANSACTION

If !Empty(F2H->F2H_ID)
	
	IF F2H->F2H_STATUS $ "5/2"
		MSGALERT(STR0019) //"N�o � permitida edi��o de apura��o que j� possui t�tulo gerado!"
		
	ElseIF FISA174('2', STR0017 + F2H->F2H_TRIB + STR0018 + DTOC(F2H->F2H_DTINI) + STR0016 +  DTOC(F2H->F2H_DTFIN) + STR0020, F2H->F2H_ID) == 1 //' (Editando)' //' - Per�odo Final: ' //'Tributo: ' //' - Per�odo Inicial: '
		//Clicou no OK, pode confirmar as altera��es...caso contr�rio dever� fazer rollback
		DisarmTransaction()
	Else
		//Chama fun��o para atualizar o Status da Apura��o
		x175AtuSts(F2H->F2H_ID)
	EndIF

EndIF

END TRANSACTION

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA173EXCL
Fun��o respons�vel por fazer a exclus�o da apura��o

@author Erick G Dias    
@since 19/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA173EXCL()

Local cNumTit	:= ""
Local cChaveFk7	:= ""
Local cAlsTit	:= ""
Local lProc		:= .T.
Local nRecnoTit	:= 0

BEGIN TRANSACTION	

dbSelectArea("F2L")
F2L->(dbSetOrder(2)) //F2L_FILIAL+F2L_IDAPUR

If  ApMsgYesNo( STR0021 ) //"Deseja realmente excluir apura��o?"

	If !Empty(F2H->F2H_ID) .And. F2L->(MsSeek(xFilial("F2L") + F2H->F2H_ID))
		//Se entrou aqui possui t�tulo, precisa verificar ent�o se tem baixas
		//Verifica se os t�tulos podem ser exclu�dos		
		IF !Empty(F2L->F2L_CHVFK7)
			cChaveFk7	:= F2L->F2L_CHVFK7

			//Verifica se pode excluir o t�tulo
			IF DelTit(cChaveFk7, "1", "FISA173", @cNumTit)
				//Aqui significa que o t�tulo pode ser exclu�do, perguntar se o cliente confirmar exclus�o do t�tulo
				If ApMsgYesNo( STR0022 + cNumTit + STR0024 + CHR(13)+CHR(10) + CHR(13)+CHR(10) + STR0023) //"Existe o t�tulo financeiro " //"Deseja prosseguir exclu�ndo este t�tulo?" //" gravado para esta apura��o. "
					//Aqui pode excluir o t�tulo
					lProc	:= .T.
				Else
					lProc	:= .F.
				EndIF
			Else
				//T�tulo n�o pode ser cancelado, pois possui baixa, exibir mensagerm de que t�tulo n�o pode ser deletado.
				MsgAlert(STR0026 + cNumTit + STR0025) //" j� possui baixa e n�o poder� ser exclu�do!" //"T�tulo "
				lProc	:= .F.
			EndIF
		EndIF
	EndIF

	IF lProc						
		//Reverte a x173Contaba��o caso tenha sido x173Contabado anteriormente.
		If F2H->F2H_STATUS == "5" .AND. x173PosTit(cChaveFk7, @cAlsTit, @nRecnoTit)
			x173Contab(cLpExApur, cAlsTit, nRecnoTit)
		EndIF

		//Chama fun��o para excluir o t�tulo
		If !(Empty(cChaveFk7))
			DelTit(cChaveFk7, "2", "FISA173")
		EndIf
		DelApur(F2H->F2H_ID)
		MsgInfo( STR0027) //"Apura��o exclu�da com sucesso!"
	EndIF

EndIF

END TRANSACTION

Return

//------------------------------------------------------------
/*/{Protheus.doc} FSA173TIT

Fun��o que far� a gera��o do t�tulo financeiro 

@author Erick G. Dias
@since 23/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Function FSA173TIT(cOpcao, lAutomato)

Local cRegraFin		:= ""
Local cFiltroBrw 	:= ""
Local cAlsTit		:= ""
Local cRegraGNRE	:= ""
Local cNumTitulo	:= ""
Local nValTit		:= 0
Local nRecnoTit		:= 0
Local aTitulo		:= {}
Local aChvSE 		:= {}
Local lContabOK		:= .F.
Local lOnlyCont		:= .T.

DEFAULT lAutomato := .F.

dbSelectArea("F2N")
F2N->(dbSetOrder(1)) //F2N_FILIAL+F2N_TRIB
dbSelectArea("F2K")
F2K->(dbSetOrder(1)) //F2K_FILIAL + F2K_IDAPUR
dbSelectArea("F2L")
F2L->(dbSetOrder(2)) //F2L_FILIAL+F2L_IDAPUR

IF F2H->F2H_STATUS == "5" .AND. cOpcao $ "1/2" //T�tulo J� foi gerado e contabilizado	
	MsgAlert(STR0038) //"T�tulo j� foi gerado e Contabilizado"

ElseIF F2H->F2H_STATUS == "3" .AND. cOpcao $ "1/2" //Saldo Credor
	//Exibe mensagem de sucesso
	MsgAlert(STR0030) //"T�tulo n�o ser� gerado pois apura��o n�o possui saldo devedor!"

ElseIF F2H->F2H_STATUS == "4" .AND. cOpcao $ "1/2" //Sem saldos
	//Exibe mensagem de sucesso
	MsgAlert(STR0030) //"T�tulo n�o ser� gerado pois apura��o n�o possui saldo devedor!"

ElseIF F2H->F2H_STATUS == "2" .AND. cOpcao $ "1/2" //T�tulo j� gerado
	//T�tulo j� foi gerado
	MsgAlert(STR0029)		 //"T�tulo desta apura��o j� foi gerado!"
	
ElseIF F2H->F2H_STATUS == "1" .AND. cOpcao $ "1/2"  //Aqui o t�tulo ser� gerado	
	//Posicionar tabela F2G para buscar regra financeira 	
	If !Empty(F2H->F2H_TRIB) .And. F2N->(MsSeek(xFilial("F2N") + F2H->F2H_TRIB))
		cRegraFin	:= F2N->F2N_RTIT
	EndIf

	//Pega regra de GNRE
	If F2N->(FieldPos("F2N_RGGUIA"))>0
		cRegraGNRE	:= F2N->F2N_RGGUIA
	EndIF
	
	//Posiciona na F2K para obter o valor do saldo devedor, que ser� considerado para grava��o do t�tulo
	If !Empty(F2H->F2H_TRIB) .And. F2K->(MsSeek(xFilial("F2K") + F2H->F2H_ID))
		nValTit	:= 	F2K->F2K_SLDDEV
	EndIF

	IF Empty(cRegraFin) 
		//N�oTributo n�o possui regra de T�tulo x Apura��o
		MsgAlert(STR0028) //"Este t�tulo n�o possui uma Regra de T�tulo da Apura��o Cadastrada!"	
	
	ElseIf FindFunction("FinFKKVig") .AND. !FinFKKVig(cRegraFin, dDataBase)
		MsgAlert(STR0042 + cRegraFin + STR0043 )//"Verifique a regra financeira " + cRegraFin + ", ela n�o est� vigente ou ativa. Por este motivo o t�tulo n�o ser� gerado "" 
		cRegraFin	:= ""
	EndIF

ElseIf cOpcao == "3" .AND. F2H->F2H_STATUS <> "2"	
	MsgAlert(STR0035) //"Esta apura��o ainda n�o gerou t�tulo!"

//Para as op��es 1 e 2 � necess�rio ter a regra financeira prenchida 
ElseIF cOpcao $ "1/2" .AND. Empty(cRegraFin) 
	//N�oTributo n�o possui regra de T�tulo x Apura��o
	MsgAlert(STR0031) //"Este t�tulo n�o possui uma Regra de T�tulo da Apura��o Cadastrada"

EndIF

BEGIN TRANSACTION 

//Se a regra financeira estiver preenchida, ent�o gerarei o t�tulo
If !Empty(cRegraFin) .AND. nValTit > 0	
	cNumTitulo	:= xFisTitTG()
	aAdd(aTitulo, {cRegraFin,; // C�digo da Regra FKK
	               nValTit,; // Valor do tributo
				   cNumTitulo,; // N�mero do t�tulo a ser gerado
				   '',; // ID FK7 do t�tulo gerado
				   '',;
				   AllTrim(F2H->F2H_TRIB) + " - DE " + DtoC(F2H->F2H_DTINI)  + " A " + DtoC(F2H->F2H_DTFIN)}) 
	
	//Chama fun��o do Financeiro para gera��o do t�tulo
	FGrvImpFi(@aTitulo, "FISA173", dDatabase)

	//Aqui dever� verificar se poss� regra de GNRE para gerar via apura��o.
	IF !Empty(cRegraGNRE) .And. CJ4->(MsSeek(xFilial("CJ4") + cRegraGNRE )) .AND. CJ4->CJ4_MODO == "2"
		
		//Gerar a GNRE aqui		
		GravaGNRE(cNumTitulo, nValTit, F2H->F2H_TRIB, F2H->F2H_ID)

	EndIF

	IF !Empty(aTitulo[1][4])

		//Grava��o da tabela F2L, que tem o v�nculo da apura��o com a F2L.	
		x173PrcF2L("1", F2H->F2H_ID, aTitulo[1][4], cRegraFin)		

		//Faz x173Contaba��o. Posiciona o t�tulo atrav�s da x173PosTit
		If cOpcao == "2" .AND. x173PosTit(aTitulo[1][4], @cAlsTit, @nRecnoTit)
			//Chama fun��o para contabilizar
			lContabOK	:= x173Contab(cLpApur, cAlsTit, nRecnoTit)
		EndIF

		//Chama fun��o para atualizar o Status da Apura��o
		x175AtuSts(F2H->F2H_ID, lContabOK)
		
	EndIF		
		
	// Exibe um browse com o t�tulo gerado pela apura��o.
	// N�o chamar visualiza��o quando executado pelo ADVPR.
	If !lAutomato .And. Len(aTitulo) > 0 .And. !Empty(aTitulo[1][4])	
		
		//Fun��o que faz visualiza��o do t�tulo gerado pela apura��o
		x173VisTit(aTitulo[1][4])

		//Exibe mensagem de sucesso
		MsgInfo(STR0032)	 //"T�tulo Gerado com Sucesso!"

	EndIf

ElseIf cOpcao == "3" .AND. F2H->F2H_STATUS == "2" .AND. !Empty(F2H->F2H_ID) .AND. F2L->(MsSeek(xFilial("F2L") + F2H->F2H_ID)) .AND. x173PosTit(F2L->F2L_CHVFK7, @cAlsTit, @nRecnoTit)	
	//Fun��o respons�vel por realizar contabiliza��o de t�tulo j� gerado 	
	//Chama fun��o para contabilizar
	lContabOK	:= x173Contab(cLpApur, cAlsTit, nRecnoTit)
		
	//Chama fun��o para atualizar o Status da Apura��o
	x175AtuSts(F2H->F2H_ID, lContabOK)
	
	//Exibe mensagem de sucesso
	If lContabOK		
		MsgInfo(STR0040) //"Contabiliza��o realizada com Sucesso!"
	EndIF
	
EndIf

END TRANSACTION

Return

//------------------------------------------------------------
/*/{Protheus.doc} x173GetFil

Fun��o que far� tratamento das filiais selecionadas pelo usu�rio, e que 
ser�o consideradas na apura��o

@author Erick G. Dias
@since 19/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Function x173GetFil( lPergunta )

Local aFil	    := {}
Local aSM0	    := {}
Local aAreaSM0	:= {}
Local nFil	    := 0

Default lPergunta	:= .F.

//lpergunrta indica se dever� ser exibda a tela para o usu�rio selecionar quais filiais dever�o ser processadas
//Se lPergunta estiver .F., a fun��o retornar� a filial logada.
If lPergunta	
    //chama fun��o para usu�rio escolher filial
    aFil:= MatFilCalc( .T. )
    If len(aFil) ==0
        MsgAlert(STR0033) //'Nenhuma filial foi selecionada, o processamento n�o ser� realizado.'
    EndiF

Else	
	//Adiciona filial logada para realizar o processamento
	AADD(aFil,{.T.,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_CGC})
EndIF

IF Len(aFil) > 0

	aAreaSM0 := SM0->(GetArea())
	DbSelectArea("SM0")
	//--------------------------------------------------------
	//Ir� preencher aSM0 somente com as filiais selecionadas
	//pelo cliente
	//--------------------------------------------------------
	SM0->(DbGoTop())
	If SM0->(MsSeek(cEmpAnt))
		Do While !SM0->(Eof())
			nFil := Ascan(aFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
			If nFil > 0 .And. (aFil[nFil][1] .OR. !lPergunta) .AND. cEmpAnt == SM0->M0_CODIGO
				Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})
			EndIf
			SM0->(dbSkip())
		Enddo
	EndIf

	SM0->(RestArea(aAreaSM0))
EndIF

Return aSM0

//------------------------------------------------------------
/*/{Protheus.doc} DelTAb

Fun��o gen�rico para deletar as tabelas da apura��o

@author Erick G. Dias
@since 21/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function DelTAb(cTab, cIdApur, lMainTab)

Local cQuery	:= ""
Local cCampoId	:= Iif(lMainTab, "_ID" ,"_IDAPUR")

cCampoId	:= IIf(cTab == "F2M", "_IDRAPU", cCampoId )

cQuery := "DELETE FROM " +  RetSqlName(cTab)  + " "
cQuery += "WHERE " + cTab + cCampoId + " = " + ValToSQL( cIdApur ) + " "

IF !EmpTy(Alltrim(cQuery))
	TcSqlExec(cQuery)
EndIF

Return

//------------------------------------------------------------
/*/{Protheus.doc} DelApur

Fun��o que reune a exclus�o de todas as tabelas, seja acionada pela
op��o de exclus�o ou pela op��o de reprocessamento.

@author Erick G. Dias
@since 21/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function DelApur(cId)

//Exclui as guias que possuierem o ID da apura��o e tipo de imposto igual a "E"(GNRE de apura��o)
IF AliasInDic("CJ4")
	DelGuia(cId)
EndIF

DelTAb("F2I", cId, .F.)
DelTAb("F2J", cId, .F.)

If F2K->(MsSeek(xFilial("F2K") + cId))
	DelTAb("F2M", F2K->F2K_ID, .F.)
	DelTAb("F2K", cId, .F.)
EndIF

DelTAb("F2L", cId, .F.)
DelTAb("F2H", cId, .T.)

Return

//------------------------------------------------------------
/*/{Protheus.doc} DelGuia

Fun��o que far� a exclus�o das guias geradas pela apura��o dos tributos gen�ricos.
Esta fun��o receber� ID e excluir� todas as guias que tiverem o ID da apura��o.

@author Erick G. Dias
@since 28/09/2020
@version 12.1.31
/*/
//------------------------------------------------------------------
Function DelGuia(cId)

Local cChvSF6	:= xFilial("SF6") + cId
Local oModel	:= nil 

//Verifico se o ID est� devidamente preenchido
If !Empty(cId)

	dbSelectArea("SF6")
	SF6->(dbSetOrder(8)) //F6_FILIAL + F6_IDNF

	//La�o nas guias que tiverem este ID, ser�o deletadas!
	If SF6->(MsSeek( cChvSF6 ))
		While !SF6->(EoF()) .And. SF6->(F6_FILIAL + F6_IDNF) == cChvSF6			

			//Prossigo com a dele��o da SF6.
			oModel := FWLoadModel("MATA960")
            oModel:SetOperation( MODEL_OPERATION_DELETE )
			oModel:Activate() 			
        
        	If oModel:VldData()
            	lRet := FWFormCommit( oModel )
	        EndIf
        
			oModel:Deactivate()
			SF6->(dbSkip())			
		EndDo
	EndIf

EndIf

Return

//------------------------------------------------------------
/*/{Protheus.doc} ChkApur

Fun��o que far� verifica��o da exist�ncia de apura��es j� processadas
no per�odo, se existir a rotina retornar� a lista dos tributos j� processados
no per�odo.

@author Erick G. Dias
@since 21/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function ChkApur(aParam)

Local cAliasF2H	:= x175Query('F2H', {aParam[1], aParam[2], aParam[4]  })
Local cMsg		:= STR0034 + CHR(13)+CHR(10) + CHR(13)+CHR(10)  //"J� existe apura��o processada para este per�odo dos seguinte(s) tributos(s):"
Local lExist 	:= .F.
Local aIdsApur	:= {}

While (cAliasF2H)->(!Eof())		
	
	//Adiciona na mensagem os tributos que j� possuem apura��es para o per�odo processado
	cMsg += (cAliasF2H)->F2H_TRIB + CHR(13)+CHR(10)
	aAdd(aIdsApur,{(cAliasF2H)->F2H_ID,"", (cAliasF2H)->F2H_STATUS})
	lExist	:= .T.

	(cAliasF2H)->(dbSkip())
EndDo

//Fecha o alias da query
(cAliasF2H)->(dbCloseArea())

Return {lExist, cMsg, aIdsApur}

//------------------------------------------------------------
/*/{Protheus.doc} x173PrcF2L

Fun��o respons�vel por gravar e excluir as informa��es da tabela F2L

@author Erick G. Dias
@since 23/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function x173PrcF2L(cOpcao, cIdApur, cChvFk7, cRFin)

IF cOpcao == '1' //Inclus�o

	Reclock("F2L", .T.)
	F2L->F2L_FILIAL 	:= xFilial("F2L")
	F2L->F2L_ID 		:= FWUUID("F2L")
	F2L->F2L_IDAPUR 	:= cIdApur
	F2L->F2L_CHVFK7 	:= cChvFk7
	F2L->F2L_RFIN 		:= cRFin
	F2L->(MsUnlock())

EndIF

Return

//------------------------------------------------------------
/*/{Protheus.doc} DelTit

Fun��o respons�vel por gravar e excluir as informa��es da tabela F2L

@author Erick G. Dias
@since 23/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Function DelTit(cChvFk7, cOpcao, cOrigem, cNumTit)

Local cAlsSE		:= ""
Local cChvSE		:= ""
Local lRet 			:= .T.
Local aArea 		:= GetArea()
Local nX			:= 0
Default cOrigem		:= "FISA173|FISA181"

//Posiciona no t�tulo atrav�s da chave FK7
If x173PosTit(cChvFk7, @cAlsSE)
	// Verifica se h� algum t�tulo vinculado que n�o possa ser excluido pois sofreu algum tipo de baixa ou movimenta��o no financeiro.
	// Se houver paro o la�o e j� retorno .F. pois o documento em quest�o n�o pode ser exclu�do.		
	If cOpcao == "1" //Verifica��o se pode deletar
		If cAlsSE == "SE1"
			lRet := FaCanDelCR("SE1", cOrigem, .F.)				
			cNumTit := SE1->E1_NUM + "/" + SE1->E1_PREFIXO
		ElseIf cAlsSE == "SE2"
			lRet := FaCanDelCP("SE2", cOrigem, .F.)				
			cNumTit := SE2->E2_NUM + "/" + SE2->E2_PREFIXO
		EndIf
	
	ElseIf cOpcao == "2" //Exclus�o
		
		If cAlsSE == "SE1
			SE1->(dbGoTo((cAlsSE)->(RecNo())))
			If FindFunction("FinGrvEx")
				FinGrvEx("R") // Gravar o hist�rico.
			EndIf
			RecLock("SE1",.F.)				
			SE1->(dbDelete())
			FaAvalSE1(2, cOrigem)
			FaAvalSE1(3, cOrigem)
			MsUnLock()
			
		ElseIf cAlsSE == "SE2
			SE2->(dbGoTo((cAlsSE)->(RecNo())))
			If FindFunction("FinGrvEx")
				FinGrvEx("P") // Gravar o hist�rico.
			EndIf
			RecLock("SE2",.F.)				
			SE2->(dbDelete())
			FaAvalSE2(2, cOrigem)
			FaAvalSE2(3, cOrigem)
			MsUnLock()

		EndIf	
	EndIF	
EndIF

RestArea(aArea)

Return lRet

//------------------------------------------------------------
/*/{Protheus.doc} x173Contab

Fun��o que realiza a x173Contaba��o do valor do t�tulo da �pura��o

@author Erick G. Dias
@since 23/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function x173Contab(cCodLP,cAlsTit, nRecnoTit)
  
Local cLoteCtb		:= ''
Local cArqCtb		:= ''
Local cAuxCod		:= ''
Local nHdlPrv		:= 0
Local nTotalCtb		:= 0
local lCtbOnLine	:= .F.
Local aCT5			:= {}

// Verifica o numero do lote contabil.�
dbSelectArea("SX5")
dbSetOrder(1)
If MsSeek(xFilial()+"09FIS")
	cLoteCtb := AllTrim(X5Descri())
Else
	cLoteCtb := "FIS "
EndIf		

// Executa um execblock
If At(UPPER("EXEC"),X5Descri()) > 0
	cLoteCtb := &(X5Descri())
EndIf				

//Inicializa o arquivo de x173Contabacao
nHdlPrv := HeadProva(cLoteCtb,"FISA173",Subs(cUsuario,7,6),@cArqCtb)
IF nHdlPrv <= 0
	HELP(" ",1,"SEM_LANC")
	lCtbOnLine := .F.
EndIf

Begin Transaction
	
	//x173Contabacao dos Lancamentos de PIS/COFINS	
	nTotalCtb += DetProva(nHdlPrv,cCodLP,"FISA173",cLoteCtb,,,,,@cAuxCod,@aCT5,,,{cAlsTit,nRecnoTit})

	RodaProva(nHdlPrv,nTotalCtb)
	If nTotalCtb > 0
		cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,.T.,.F.)
	EndIf
	
End Transaction

Return (nTotalCtb > 0)

//------------------------------------------------
/*/{Protheus.doc} x173PosTit

Fun��o que posiciona o t�tulo atrav�s da chave FK7

@author Erick G. Dias
@since 24/10/2018
@version 12.1.17
/*/
//------------------------------------------------
Static Function x173PosTit(cChvFk7, cAlsSE, nRecnoTit)

Local cChvSE	:= ""
Local lAchou	:= .F.
Default cAlsSE	:= ""
Default nRecnoTit	:= 0

cAlsSE		:= ""
nRecnoTit	:= 0

dbSelectarea("FK7")
FK7->(dbSetOrder(1))

dbSelectarea("SE2")
SE2->(dbSetOrder(1))

dbSelectarea("SE1")
SE1->(dbSetOrder(1))

//Posiciona na Fk7 atrav�s da chave Fk7, e na sequ�ncia posiciona o t�tulo
If FK7->(MsSeek(xFilial("FK7") + cChvFk7))
	cAlsSE	:= FK7->FK7_ALIAS	
	// Converte o conte�do do campo FK7_CHAVE para poder localizar a SE1/SE2.
	cChvSE := FK7ToE1E2(FK7->FK7_CHAVE, cAlsSE)
	
	//Posiciona no t�tulo em quest�o
	lAchou	:=  (cAlsSE)->(MsSeek(cChvSE))
	nRecnoTit	:= (cAlsSE)->(RECNO())
EndIF

Return lAchou

//------------------------------------------------
/*/{Protheus.doc} FSA173VTIT

Fun��o que far� a visualiza��o do t�tulo gerado atrav�s 
da apura��o.

@author Erick G. Dias
@since 24/10/2018
@version 12.1.17
/*/
//------------------------------------------------
Function FSA173VTIT()

dbSelectArea("F2L")
F2L->(dbSetOrder(2)) //F2L_FILIAL+F2L_IDAPUR

IF !F2H->F2H_STATUS $ "5/2"
	MsgAlert(STR0035) //"Esta apura��o ainda n�o gerou t�tulo!"
ElseIF F2L->(MsSeek(xFilial("F2L") + F2H->F2H_ID )) .AND. !Empty( F2L->F2L_CHVFK7 )
	//Fun��o que exibe o t�tulo gerado atrav�s da apura��o
	x173VisTit(F2L->F2L_CHVFK7)
EndIF

Return

//------------------------------------------------
/*/{Protheus.doc} x173VisTit

Fun��o que recebe chave FK7 e exibe o t�tulo gerado pela apura��o

@author Erick G. Dias
@since 24/10/2018
@version 12.1.17
/*/
//------------------------------------------------
Static Function x173VisTit(cChaveFk7)

Local cFiltroBrw	:= ""
Local cAlsSE		:= ""
Local aChvSE		:= {}

If !Empty(cChaveFk7)

	dbSelectArea("FK7")
	FK7->(dbSetOrder(1))

	If FK7->(MsSeek(xFilial("FK7") + cChaveFk7))

		cAlsSE := FK7->FK7_ALIAS
		aChvSE := StrToKArr(FK7->FK7_CHAVE, "|")

		If cAlsSE == "SE1"
			cFiltroBrw := "E1_FILIAL == " + ValToSQL(aChvSE[1]) + " .And. "
			cFiltroBrw += "E1_PREFIXO == " + ValToSQL(aChvSE[2]) + " .And. "
			cFiltroBrw += "E1_NUM == " + ValToSQL(aChvSE[3]) + " .And. "
			cFiltroBrw += "E1_PARCELA == " + ValToSQL(aChvSE[4]) + " .And. "
			cFiltroBrw += "E1_TIPO == " + ValToSQL(aChvSE[5]) + " .And. "
			cFiltroBrw += "E1_CLIENTE == " + ValToSQL(aChvSE[6]) + " .And. "
			cFiltroBrw += "E1_LOJA == " + ValToSQL(aChvSE[7]) + " .And. "
			cFiltroBrw += "E1_ORIGEM == 'FISA173'"
		ElseIf cAlsSE == "SE2"
			cFiltroBrw := "E2_FILIAL == " + ValToSQL(aChvSE[1]) + " .And. "
			cFiltroBrw += "E2_PREFIXO == " + ValToSQL(aChvSE[2]) + " .And. "
			cFiltroBrw += "E2_NUM == " + ValToSQL(aChvSE[3]) + " .And. "
			cFiltroBrw += "E2_PARCELA == " + ValToSQL(aChvSE[4]) + " .And. "
			cFiltroBrw += "E2_TIPO == " + ValToSQL(aChvSE[5]) + " .And. "
			cFiltroBrw += "E2_FORNECE == " + ValToSQL(aChvSE[6]) + " .And. "
			cFiltroBrw += "E2_LOJA == " + ValToSQL(aChvSE[7]) + " .And. "
			cFiltroBrw += "E2_ORIGEM == 'FISA173'"
		EndIf

		FISA174DET(cAlsSE, STR0036, cFiltroBrw) //"T�tulos Gerados Pela Apura��o"

	EndIf

EndIf

Return

//------------------------------------------------
/*/{Protheus.doc} GravaGNRE

Fun��o que far� a grava��o da Guia pela apura��o, 
caso a regra de apura��o tenha vinculada um regra de guia.

@author Erick G. Dias
@since 25/10/2018
@version 12.1.17
/*/
//------------------------------------------------
Function GravaGNRE(cNumGNRE, nValor, cTributo, cIdApur)

Local dDtPadrao	:= DataValida( LastDay( dDataBase ) + 1, .T.) //Inicio com padr�o do primeiro dia �til do pr�ximo m�s
Local dDtVenc	:= Iif( FindFunction("xFisDtGnre") , xFisDtGnre(dDtPadrao) , dDtPadrao )
Local cMvEstado := GetNewPar("MV_ESTADO","")
Local oModel    := FWLoadModel('MATA960')

oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()

//Para essa opera��o � preciso especificar qual o modelo que queremos inserir o valor
oModel:SetValue("MATA960MOD","F6_NUMERO"  , cNumGNRE)
oModel:SetValue("MATA960MOD","F6_TIPOIMP" , "E")
oModel:LoadValue("MATA960MOD","F6_VALOR"   , nValor)
oModel:SetValue("MATA960MOD","F6_DTARREC" , dDataBase)
oModel:SetValue("MATA960MOD","F6_MESREF"  , Month(dDataBase))		
oModel:SetValue("MATA960MOD","F6_ANOREF"  , Year(dDataBase))
oModel:SetValue("MATA960MOD","F6_TRIB"    , cTributo)
oModel:SetValue("MATA960MOD","F6_IDNF"    , cIdApur)
oModel:SetValue("MATA960MOD","F6_EST"     , cMvEstado)
oModel:SetValue("MATA960MOD","F6_DTVENC"  , Iif(Empty(dDtVenc), dDtPadrao,dDtVenc ) )

//Executo as valida��es do modelo e prossigo com grava��o das informa��es.
If oModel:VldData()
	oModel:CommitData()	
Else		
	//Aqui exibo erro, pois ocorreu algum erro de valida��o do modelo
	VarInfo("",oModel:GetErrorMessage())			
EndIf

//Desativo e destruo o objeto aqui
oModel:DeActivate()
oModel:Destroy()

//Verifica se deseja visualizar/alterar a Guia gerada
//Aqui posso verifica a CJ4 pois a fun��o EnqNFGNRE() j� posicionou estatabela
IF CJ4->CJ4_VTELA == "1" .AND. !IsBlind() 
	FWExecView( cTributo ,"MATA960", MODEL_OPERATION_UPDATE, , { ||.T. } ,{ || .T.} )
EndIF

Return

//------------------------------------------------
/*/{Protheus.doc} F173ChkGNRE

Verifica se h� apura��o para o tributo no per�odo selecionado. 
Essa fun��o foi criada por conta do SENAR que tinha a gera��o de guia e t�tulo duplicados ao realizar a apura��o de ICMS (FISA153).
Por�m, pode ser utilizada para qualquer tributo.

@author leandro.faggyas
@since 30/01/2023
@version 12.1.2210
@return lRet, Logical, Retorna se foi encontrada apura��o na data inicial para o tributo pesquisado.
/*/
//------------------------------------------------
Function F173ChkGNRE( cIdTrib, dDtIni )
Local cTributo := ""
Local aAreaF2E := F2E->(GetArea())
Local aAreaF2H := F2H->(GetArea())
Local lRet     := .F.

DbSelectArea("F2E")
F2E->(DbSetOrder(3)) //F2E_FILIAL+F2E_IDTRIB
If F2E->(MsSeek(xFilial("F2E")+cIdTrib))
	cTributo := F2E->F2E_TRIB
EndIf

DbSelectArea("F2H")
F2H->(DbSetOrder(1)) //F2H_FILIAL+DTOS(F2H_DTINI)+F2H_TRIB+F2H_ID
If F2H->(MsSeek(xFilial("F2H")+Dtos(dDtIni)+cTributo))
	lRet := .T.
EndIf

RestArea(aAreaF2E)
RestArea(aAreaF2H)

Return lRet
