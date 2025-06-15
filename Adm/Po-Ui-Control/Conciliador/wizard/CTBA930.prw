#INCLUDE "CTBA930.ch"
#INCLUDE "protheus.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fwlibversion.ch"

#DEFINE MB_OK 0

Static _aCposDat
Static _lMarker
Static _nRadioWiz
Static _lIsNotRussia 	:= IIf(Upper(Alltrim(cPaisLoc)) == "RUS", .F., .T.)

/*{Protheus.doc} CTBA930
Chama a fun��o CTBA930 para libera��o da classe MPX31Field
nos fontes da LIB

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Main Function WIZARDUUID()
Local lContinua := .F.
Local oStartWiz
Local cPassWiz 	:= Space(100)
Local lBack 	:= .F.

Private _aGrpEmpSel := {}
Private _aListaSM0  := {}

Rptstatus({|| _aListaSM0 := C930SetEnv()}, STR0055, STR0054) //"Preparando o ambiente..." //"Aguarde"

If SuperGetMv("MV_PRJOVER",.F.,.F. )	

	If C930TemQLB()

		oStartWiz := APWizard():New(;
									"",; 					//chTitle
									"",;					//chMsg
									STR0016,;				//"Conciliador - Wizard de Configura��o"  			
									STR0001+CRLF+; 			//"Este Wizard ajudar� na prepara��o da sua base de dados para a utiliza��o da rotina de "
									STR0002+CRLF+;			//"concilia��o. "
									IIf(_lIsNotRussia, STR0003+CRLF+; 			//"Voc� pode acessar a documenta��o completa do Wizard clicando"		
									STR0004, ''),;				//"Ou clicando nos links 'saiba mais...' dispon�veis no pr�ximo passo."
									{|| C930VldPsw(cPassWiz) },; //bNext
									{||lContinua := .T.},;	//bFinish
									.T.,;					//lPanel
									,;						//cResHead
									{||.T.},;				//bExecute 
									.F.)					//lNoFirst


		//Painel 2 - Defini��o das Novas Entidades
		oStartWiz:NewPanel(/*<chTitle>*/,;
							STR0056/*<chMsg>*/,; //"Selecione o(s) grupo(s) empresa(s) para processamento"
							{|| lBack := .T.}/*<bBack>*/,;
							{|| .F.} /*<bNext>*/ ,;
							{|| lContinua := C930VldGrp(_aGrpEmpSel) }/*<bFinish>*/,;
							.T./*<.lPanel.>*/ ,;
							{|| IIf(lBack,nil,_aGrpEmpSel := C930LdSM0(oStartWiz))/*<bExecute>*/}) //Montagem da tela							

		oStartWiz:oFInish:cCaption := STR0032 //"Avan�ar"

		oStartWiz:Activate( .T.,; 	  //lCenter
							{||.T.},; //bValid
							{|| C930GetPsw(oStartWiz,@cPassWiz), IIF(_lIsNotRussia, WizLinkComp(oStartWiz), ) },; //bInit
							{||.T.})  //bWhen
	Else	
		C930MsgBox(STR0058+CRLF+STR0057) //"Aplique o pacote de atualiza��o de dicion�rios via UPDDISTR." //"Tabela QLB n�o encontrada na base de dados."
	EndIf

	If lContinua	
		_aListaSM0 := C930Ajusta()
		While CTBA930() 
		EndDo
		C930MsgBox(STR0031) //"Processamento Finalizado"
	EndIf
Else
	C930MsgBox(STR0066+CRLF+STR0067) //"Par�metro MV_PRJOVER (tipo L) n�o encontrado ou com conte�do F." //"Crie ou ative esse par�metro para prosseguir."
EndIf

Return

/*{Protheus.doc} CTBA930
Vefifica qual op��o do Wizard deve processar
1 - Criar campos UUID
2 - Popular Campos UUID
3 - Popular Rastreamento Cont�bil'

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function CTBA930()
Local oMainWiz 
Local lContinua := .F.

If _nRadioWiz == Nil
	_nRadioWiz := 1
EndIf

oMainWiz := APWizard():New(;
							"",; 					//chTitle
							"",;					//chMsg
							STR0016,;               //cTitle //"Conciliador - Wizard de Configura��o"
							STR0017+CRLF+;          //"Esse Wizard auxiliar� na prepara��o da base de dados para utiliza��o da rotina de concilia��o."
							STR0018,;               //cText //"Selecione a op��o desejada: "
							{|| .T.},;				//bNext
							{||lContinua := .T.},;	//bFinish
							.T.,;					//lPanel
							,;						//cResHead
							{||.T.},;				//bExecute 
							.F.)					//lNoFirst


oMainWiz:oFInish:cCaption := "&"+STR0032+" >>" //"Avan�ar"

oMainWiz:Activate( 	.T.,; 					 //lCenter
					{||.T.},; 				 //bValid
					{||GetOpcWiz(oMainWiz),IIf( _lIsNotRussia , WizLinkEsp(oMainWiz), )},;//bInit
					{||.T.})				 //bWhen

If lContinua
	CallWIz()	
EndIf

Return lContinua

/*{Protheus.doc} GetOpcWiz
Monta o objeto Radio

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function GetOpcWiz(oMainWiz)
Local aItems := {STR0033,STR0020,STR0019,STR0021} //"Importar configura��es de Match (QLB)" "Gerar SDF com os campos de ID" "Popular os campos de ID" "Popular Rastreamento Cont�bil"
Local oPanel := oMainWiz:oMPanel[oMainWiz:nPanel]
Local oRadio 

oRadio := tRadMenu():New(55,15,aItems,{|u|if(PCount()==0,_nRadioWiz,_nRadioWiz:=u)},oPanel,,,,,,,,120,30,,,,.T.)

Return .T.

/*{Protheus.doc} CallWIz
Direciona para a fun��o correta de acordo com 
a op��o selecionada no objeto Radio

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function CallWIz()
Local aFunctions := {"CTBA930a()","CTBA930b()","CTBA930c()","CTBA930d()"}
Return &(aFunctions[_nRadioWiz])


/*{Protheus.doc} MontaGDQLB
Monta a GetDados com os campos que ser�o criados

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Function C930GDQLB(aHeader,aCols,aSM0,aAlterCpos)
Local oPanel 	:= oWizard:oMPanel[oWizard:nPanel]
Local nOpcX		:= 2
Local oGetWizard
DEFAULT aHeader := {}
DEFAULT aCols := {}

oGetWizard := MsNewGetDados():New(010,008,130,300,nOpcX,/*cLinOk*/,/*cTudoOk*/,/*cIniCpos*/,;
aAlterCpos,/*nFreeze*/,/*nMax*/,/*cFieldOk*/,/*cSuperDel*/,/*cDelOk*/,oPanel,aHeader,aCols)

Return oGetWizard


/*{Protheus.doc} WizGetHead
Monta o aHeader para exibir no Wizard

@author: TOTVS
@since 06/08/2021
@version 1.0
*/	
Static Function WizGetHead(aHeadAux)
DEFAULT aHeadAux := {}	

If _nRadioWiz == 1
	Aadd(aHeadAux,{STR0015 ,"TMP_GREMP"	    ,""   ,15	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""}) //"Grp.Empresa"	
	Aadd(aHeadAux,{STR0035 ,"TMP_CONFI"		,""   ,30	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""}) //"Configura��o"
	Aadd(aHeadAux,{STR0036 ,"TMP_ORIDE"		,""   ,05	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""}) //"Origem x Destino"
	Aadd(aHeadAux,{STR0034 ,"TMP_ARQUI"		,""   ,30	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""}) //"Arquivo"
ElseIf _nRadioWiz == 2
	Aadd(aHeadAux,{STR0015	,"TMP_GREMP"	,""   ,30	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""}) //"Grp.Empresa"
	Aadd(aHeadAux,{STR0008	,"TMP_TABLE"	,"@!" ,03	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""}) //"Tabela"
	Aadd(aHeadAux,{STR0009	,"TMP_CAMPO"	,"@!" ,10	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""}) //"Campo"
	Aadd(aHeadAux,{STR0010 	,"TMP_DESCR"	,""   ,15	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""}) //"Descri��o"
	Aadd(aHeadAux,{STR0011	,"TMP_TAMAN"	,"99" ,10	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""}) //"Tamanho"
	Aadd(aHeadAux,{STR0012  ,"TMP_SITUA"	,""   ,10	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""}) //"Situa��o"
ElseIf _nRadioWiz == 3
	Aadd(aHeadAux,{STR0015	,"TMP_GREMP"	,""   ,30	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""}) //"Grp.Empresa"
	Aadd(aHeadAux,{STR0008	,"TMP_TABLE"	,"@!" ,03	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""}) //"Tabela"
	Aadd(aHeadAux,{STR0009	,"TMP_CAMPO"	,"@!" ,10	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""}) //"Campo"
	Aadd(aHeadAux,{STR0022  ,"TMP_CPODT"	,"@!" ,10	,0	,"" ,"�" ,"C" ,"C930X3" ,"R"	,"" ,""})	 //"Campo Dt."
ElseIf _nRadioWiz == 4
	Aadd(aHeadAux,{STR0015	,"TMP_GREMP"	,""   ,30	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""}) //"Grp.Empresa"
	Aadd(aHeadAux,{STR0037 ,"TMP_TABOR"		,""   ,5	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""}) 		  //"Tab. Origem"
	Aadd(aHeadAux,{STR0038 ,"TMP_IDORIG"	,""   ,10	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""})	  //"Id. Origem"
	Aadd(aHeadAux,{STR0039 ,"TMP_TABDE"		,""   ,5	,0	,""	,"�" ,"C" ," " ,"R"	,"" ,""})	      //"Tab. Destino"
EndIf

Return

/*{Protheus.doc} WizGetCols
Insere os dados no aCols

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizGetCols(aCols,aSM0)
Local aStructCols := {}

DEFAULT aCols  := {}
DEFAULT aSM0   := {}

aStructCols := WizStruCols(aSM0)
		
aCols := WizGetDados(aStructCols)	

If Len(aCols)>0
	If _nRadioWiz == 2
		aSort(aCols,,,{|x,y| x[1]+x[2] < y[1]+y[2]})		
	ElseIf _nRadioWiz > 2
		aSort(aCols,,,{|x,y| x[2]+x[3] < y[2]+y[3]})
	EndIf
EndIf

Return

/*{Protheus.doc} WizGetDados
L� a tabela QLB e monta o aCols

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizGetDados(aStructCols)
Local nI := 0
Local aCols := {}
DEFAULT aStructCols := {}

For nI := 1 to Len(aStructCols)
	
	If _nRadioWiz == 2
		aAdd(aCols,{aStructCols[nI,1],;
					aStructCols[nI,2],;
					aStructCols[nI,3],;
					aStructCols[nI,4],;
					aStructCols[nI,5],;
					aStructCols[nI,6],;
					.F.})
	Else
		aAdd(aCols,{.F.,;
					aStructCols[nI,1],;
					aStructCols[nI,2],;
					aStructCols[nI,3],;
					aStructCols[nI,4],;									
					.F.})
	EndIf
Next

Return aCols

/*{Protheus.doc} C930SelEmp
Seleciona a empresa/filial desejada
@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Function C930SelEmp(cEmpAux,cFilAux,aSM0)
Local lRet := .F.

DEFAULT aSM0 := {}
DEFAULT cEmpAux := ""
DEFAULT cFilAux := ""

If Empty(cEmpAux)	
	aSM0 := _aListaSM0
	lRet := Len(aSM0) > 0	
ElseIf cEmpAux == cEmpAnt 
	lRet := .T.
ElseIf TcCanOpen("SX2"+cEmpAux+"0")
	RpcClearEnv()
	RpcSetType(3)	
	lRet := RpcSetEnv(cEmpAux, cFilAux)	
	
	//Provis�rio - Tratamento para contornar erro na LIB
	__cUserID := "000000"
EndIf

Return lRet

/*{Protheus.doc} C930SelEmp
Retorna o alias do campo com 3 ou 2 posi��es

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizAliasCpo(cTabela)
DEFAULT cTabela := ""

If !(cTabela)->(FieldPos(cTabela+"_FILIAL"))
	cTabela := SubStr(cTabela,2,2)
EndIf

Return cTabela

/*{Protheus.doc} WizStruCols
Verifica os campos que devem ser criados
de acordo com o cadastro da tabela QLB.
Faz a leitura em todas os grupos de empresas

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizStruCols(aSM0)
Local cEmpAux := ""
Local cFilAux := ""
Local cEmpFor := ""
Local nI 	  := 0
Local nJ	  := 0
Local aRetAux := {}
Local aRetArr := {}
Local lContinua := .T.

DEFAULT aSM0 := {}

cEmpAux := cEmpAnt
cFilAux := cFilAnt

If Len(aSM0) > 0
	For nI := 1 to Len(aSM0)
		If cEmpFor <> aSM0[nI][1]

			lContinua := C930SelEmp(aSM0[nI][1],aSM0[nI][2])
			
			If lContinua
				aRetAux := WizRetStru()		
				For nJ := 1 to Len(aRetAux)	
					aAdd(aRetArr,aRetAux[nJ])
				Next
			EndIf
			
			cEmpFor := aSM0[nI][1]
		EndIf
	Next
Else
	aRetArr := WizRetStru()
EndIf

If cEmpAux <> cEmpAnt	
	C930SelEmp(cEmpAux,cFilAux)
EndIf

Return aRetArr

/*{Protheus.doc} WizRetStru
Faz o direcionamento para a fun��o correta

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizRetStru()
Local aAuxRet := {}

If _nRadioWiz == 1
	aAuxRet := WizRetArq()
Else
	aAuxRet := WizRetQLB()
EndIf	

Return aAuxRet 

/*{Protheus.doc} WizRetQLB
Monta o array de estrutura dos campos UUID
baseado no cadastro da tabela QLB (configura��es de match)

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizRetQLB()
Local cTabela  := ""
Local cAlias   := ""
Local cDescri  := STR0025 //"Id de Concilia��o"
Local nTamanho := If(AllTrim(Upper(TCGetDB())) == "ORACLE", 32, 36)
Local cStatus  := ""
Local lUUIDOri := .F.
Local lUUIDDes := .F.
Local cDescEmp := cEmpAnt+" - "+FWGrpName()
Local aRetStru := {}
Local cCpoDat  := ""

If AliasInDic("QLB")
	QLB->(dbSetOrder(1))
	QLB->(dbGoTop())
	While !QLB->(Eof())
		
		lUUIDOri := .F.
		lUUIDDes := .F.

		cTabela := QLB->QLB_TABORI	
		
		//Provis�rio
		If _nRadioWiz == 3 .And. cTabela$"AGG/AGH/SEZ"
			QLB->(dbSkip())
			Loop
		EndIf

		If !Empty(cTabela) .And. !cEmpAnt+cTabela$cListTab
			cListTab += cEmpAnt+cTabela+"|"
			
			cAlias := WizAliasCpo(cTabela)			
			cCampo := AllTrim(Upper(QLB->QLB_CIDORI))
		
			cStatus := STR0013 //"Incluir"			
			If (cTabela)->(FieldPos(cCampo)) .Or. cCampo == "R_E_C_N_O_"
				lUUIDOri := .T.
				cStatus := STR0014 //"Ok"
			EndIf
			If _nRadioWiz == 2
				aAdd(aRetStru, {cDescEmp,cTabela,cCampo,cDescri,nTamanho,cStatus})
			ElseIf _nRadioWiz == 3 .And. lUUIDOri
				cCpoDat := WizCpoDef(cTabela)				
				aAdd(aRetStru, {cDescEmp,cTabela,PadR(cCampo,10),cCpoDat})
			EndIf
		EndIf
		
		cTabela := QLB->QLB_TABDES
		If !Empty(cTabela) .And. !cEmpAnt+cTabela$cListTab			
			cListTab += cEmpAnt+cTabela+"|"
			
			cAlias := WizAliasCpo(cTabela)			
			cCampo:= AllTrim(Upper(QLB->QLB_CIDDES))
			
			cStatus := STR0013 //"Incluir"			
			If (cTabela)->(FieldPos(cCampo)) .Or. cCampo == "R_E_C_N_O_"
				lUUIDDes := .T.
				cStatus := STR0014 //"Ok"
			EndIf
			If _nRadioWiz == 2
				aAdd(aRetStru, {cDescEmp,cTabela,cCampo,cDescri,nTamanho,cStatus})
			ElseIf _nRadioWiz == 3 .And. lUUIDDes
				cCpoDat := WizCpoDef(cTabela)				
				aAdd(aRetStru, {cDescEmp,cTabela,PadR(cCampo,10),cCpoDat})
			EndIf
		EndIf

		If _nRadioWiz == 4 .And. (lUUIDOri .Or. lUUIDDes)
			If QLB->QLB_TABORI == "CT2" .Or. QLB->QLB_TABDES == "CT2"
				aAdd(aRetStru, {cDescEmp,;
								  QLB->QLB_TABORI,; 
								  QLB->QLB_CIDORI,;
								  QLB->QLB_TABDES})
			EndIf
		EndIf

		QLB->(dbSkip())
	EndDo
EndIf

Return aRetStru

/*{Protheus.doc} WizCpoDef
Retorna os campos data das tabelas DEFAULT do conciliador

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizCpoDef(cTabela)
Local cRet := Space(10)
Local nPos := 0

If _aCposDat == Nil
	_aCposDat := WizRetDat()
EndIf

If (nPos := aScan(_aCposDat, {|x| x[1] == cTabela })) > 0
	cRet := _aCposDat[nPos,2]
EndIf

Return cRet

/*{Protheus.doc} WizCpoDef
Retorna os campos data das tabelas DEFAULT do conciliador

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizRetDat()
Local aRet := {}

aAdd(aRet, {"CT2",PadR("CT2_DATA",10)}) 
aAdd(aRet, {"FIP",PadR("FIP_DTAVP",10)})
aAdd(aRet, {"FIS",PadR("FIS_DTAVP",10)})
aAdd(aRet, {"SC5",PadR("C5_EMISSAO",10)})
aAdd(aRet, {"SC6",PadR("C6_ENTREG",10)})
aAdd(aRet, {"SC7",PadR("C7_EMISSAO",10)})
aAdd(aRet, {"SC8",PadR("C8_EMISSAO",10)})
aAdd(aRet, {"SD1",PadR("D1_EMISSAO",10)})
aAdd(aRet, {"SD2",PadR("D2_EMISSAO",10)})
aAdd(aRet, {"SD3",PadR("D3_EMISSAO",10)})
aAdd(aRet, {"SE1",PadR("E1_EMISSAO",10)})
aAdd(aRet, {"SE2",PadR("E2_EMISSAO",10)})
aAdd(aRet, {"SE5",PadR("E5_DATA",10)})
aAdd(aRet, {"SEF",PadR("EF_DATA",10)})
aAdd(aRet, {"SEU",PadR("EU_DTDIGIT",10)})
aAdd(aRet, {"SF1",PadR("F1_DTDIGIT",10)})
aAdd(aRet, {"SF2",PadR("F2_EMISSAO",10)})

Return aRet

/*{Protheus.doc} WizIniDad
Prepara os dados para Wizard

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Function C930IniDad(aHeader,aCols,aSM0)
Local cVDBAccess := ""
Local lRet 		 := .F.
Local lContinua  := .F.

SetRegua(3)

IncRegua()

lContinua := C930SelEmp(nil,nil,@aSM0)

If lContinua	
	cVDBAccess	:= TcVersion()	
	If cVDBAccess < "21.1.1.8"
		C930MsgBox(STR0048+CHR(10)+CHR(13)+; //"Vers�es de LIB e DBAccess inv�lidas para essa rotina"
					'DBAccess: '+cVDBAccess+CHR(10)+CHR(13)+;					
					STR0049+CHR(10)+CHR(13)+; //"Atualize os artefatos para as vers�es: "
					'DBAccess: 21.1.1.8') //'ou maior igual a'
					
	Else
		IncRegua()
		WizGetHead(aHeader)

		IncRegua()
		WizGetCols(aCols,aSM0)	

		IncRegua()

		lRet := .T.		
	EndIf
Else
	C930MsgBox(STR0052) //"N�o foi encontrado nenhum grupo empresa v�lido para esse processamento."
EndIf

Return lRet

/*{Protheus.doc} C930MsgBox
Padroniza caixa de ajuda do wizard.
Outras mensagens n�o funcionavam devido a aus�ncia de um objeto oDlg

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Function C930MsgBox(ctexto)
DEFAULT ctexto := ""

cTexto := CRLF+cTexto+CRLF

MessageBox(cTexto, STR0007, MB_OK) //"Aten��o"

Return 

/*{Protheus.doc} C930GetDat
Monta os campos data de e data ate no Wizard

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Function C930GetDat()
Local oGetDe
Local oGetAte
Local oPanel   := oWizard:oMPanel[oWizard:nPanel]
Local oArial10 := tFont():New("Arial",,-10,,.f.)

	oSay1 := TSay():New(82, 15,{|| STR0023 },oPanel,,oArial10,,,,.T.)  //"Data de  ? "
	oGetDe := TGet():New(80, 43, { | u | If( PCount() == 0, dDatDe, dDatDe := u ) },oPanel, ;
     060, 010, "@D",{|| IIf(!Empty(dDatAte),dDatAte >= dDatDe,.T.)},,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDatDe",,,,.T.  )
	
	oSay1 := TSay():New(97, 15,{|| STR0024 },oPanel,,oArial10,,,,.T.)  //"Data at� ? "
	oGetAte := TGet():New(95, 43, { | u | If( PCount() == 0, dDatAte, dDatAte := u ) },oPanel, ;
     060, 010, "@D",{|| IIf(!Empty(dDatDe),dDatAte >= dDatDe,.T.)},,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDatAte",,,,.T.  )

Return .T.

/*{Protheus.doc} C930MARK
Monta teta com os dados de rastreamento cont�bil CV3

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Function C930MARK(aHeader,aCols,aSM0)
	Local oPanel := oWizard:oMPanel[oWizard:nPanel]	
	Local oBrowseQLB
	Local nI := 0

	_lMarker  := .T.

    oBrowseQLB := fwBrowse():New(oPanel)
    oBrowseQLB:setDataArray()
    oBrowseQLB:setArray(aCols)
    oBrowseQLB:disableConfig()
    oBrowseQLB:disableReport() 
	oBrowseQLB:SetEditCell(.T.)

    oBrowseQLB:AddMarkColumns({|| IIf(aCols[oBrowseQLB:nAt,1], "LBOK", "LBNO")},; //Code-Block image
    					      {|| WizMarkLin(oBrowseQLB, aCols)},; 				  //Code-Block Double Click
        					  {|| WizMarkAll(oBrowseQLB, 1, aCols)}) 			  //Code-Block Header Click
 
	
	aColumns := WizRetCol(oBrowseQLB, aCols, aHeader)
 
    For nI := 1 To Len(aColumns )
        oBrowseQLB:AddColumn( aColumns[nI] )
    Next
	

    oBrowseQLB:Activate(.T.)  

Return aCols

/*{Protheus.doc} WizMarkLin
Fun��o para marcar uma linha

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizMarkLin(oBrowse, aColsBrw)
aColsBrw[oBrowse:nAt,1] := !aColsBrw[oBrowse:nAt,1]
Return .T.
 
/*{Protheus.doc} WizMarkAll
Fun��o para marcar todas as linhas

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizMarkAll(oBrowse, nCol, aColsBrw)
Local nI := 1
For nI := 1 to len(aColsBrw)
    aColsBrw[nI,1] := _lMarker
Next
oBrowse:Refresh()
_lMarker:=!_lMarker
Return .T.

/*{Protheus.doc} WizRetCol
Retorna a estrutura das colunas

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizRetCol(oBrowseQLB, aCols, aHeader)
Local aColumns := {}

Private _cMSUID := ""

aAdd(aColumns, {aHeader[1,1], {||aCols[oBrowseQLB:nAt,2]}, aHeader[1,8], aHeader[1,3], 1, aHeader[1,4],0, .F.,{||}, .F.,, "aCols[oBrowseQLB:nAt,2]",{|| AlwaysTrue()}, .F., .T.,{}, "ID_01"})
aAdd(aColumns, {aHeader[2,1], {||aCols[oBrowseQLB:nAt,3]}, aHeader[2,8], aHeader[2,3], 1, aHeader[2,4],0, .F.,{||}, .F.,, "aCols[oBrowseQLB:nAt,3]",{|| AlwaysTrue()}, .F., .T.,{}, "ID_02"})
aAdd(aColumns, {aHeader[3,1], {||aCols[oBrowseQLB:nAt,4]}, aHeader[3,8], aHeader[3,3], 1, aHeader[3,4],0, .T.,{||}, .F.,, "_cMSUID",{|| AlwaysTrue()}, .F., .T.,{}, "ID_03"})

If _nRadioWiz==3	
	aAdd(aColumns, {aHeader[4,1], {||aCols[oBrowseQLB:nAt,5]}, aHeader[4,8], aHeader[4,3], 1, aHeader[4,4],0, (_nRadioWiz==3),{||}, .F.,{|| CT930SXB(aCols, oBrowseQLB) }, "aCols[oBrowseQLB:nAt,5]",{|| AlwaysTrue()}, .F., .T.,{}, "ID_04"})
Else
	aAdd(aColumns, {aHeader[4,1], {||aCols[oBrowseQLB:nAt,5]}, aHeader[4,8], aHeader[4,3], 1, aHeader[4,4],0, (_nRadioWiz==3),{||}, .F.,{||}, "aCols[oBrowseQLB:nAt,5]",{|| AlwaysTrue()}, .F., .T.,{}, "ID_04"})
EndIf

Return aColumns

/*{Protheus.doc} WizRetQLB
Monta o array de estrutura para o Wizard

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizRetArq()
Local nI 	   := 0
Local nJ 	   := 0
Local cDescEmp := cEmpAnt+" - "+FWGrpName()
Local cPath	   := ""
Local cInfoArq := ""
Local cNomArq  := ""
Local aStruRet := {}
Local aNomArq  := {}
Local aDatas   := {}
Local aHoras   := {}
Local oJsonArq := JsonObject():New()
Local cTmp 	   := GetSrvProfString("ROOTPATH", "")
Local cTabelas := ""
Local cConfig  := ""

/* lPathVld � inicializada anteriormente com valor .T. na fun��o CTBA930a(). A fun��o WizRetArq � chamada uma vez para cada 
	grupo de empresas mas as valida��es que s�o feitas aqui s�o do mesmo arquivo/diret�rio. Para evitar que as mensagens
	de erro sejam exibidas para todos os grupos de empresas, a variavel lPathVld identifica se j� foi encontrado algum erro nesta etapa*/

If lPathVld
	If Empty(cPathSave) //Se o pathsave esta preenchido, significa que o caminho j� esta validado
		cPath := cGetFile(, STR0069,, cTmp, .T., (GETF_LOCALHARD+GETF_RETDIRECTORY), .T.) //"Sele��o de Arquivos"
	Else
		cPath := cPathSave
	EndIf

	If AliasInDic("QLB")
		ADir(cPath+'*.json',@aNomArq,nil,@aDatas,@aHoras,nil,.F.)
		If Len(aNomArq) > 0
			For nI := 1 to Len(aNomArq)
				
				cNomArq := aNomArq[nI]

				cBuffer := C930ReadF(cPath+cNomArq)

				If !Empty(cBuffer)
					uRet := oJsonArq:FromJson(cBuffer)
					If uRet == Nil

						If oJsonArq["codcfg"] <> nil .And. oJsonArq["descfg"] <> nil 
							cConfig := oJsonArq["codcfg"]+"-"+oJsonArq["descfg"]
						Else
							C930MsgBox(STR0041+cNomArq) //"C�digo de configura��o n�o encontrado no arquivo: "
							lPathVld	:= .F.
						EndIf

						If oJsonArq["tabori"] <> nil .And. oJsonArq["tabdes"] <> nil 
							If oJsonArq["union"] <> nil
								
								cTabelas := oJsonArq["tabori"]
								If oJsonArq["union"]["unionori"] <> NIL
									For nJ := 1 to Len(oJsonArq["union"]["unionori"])								
										cTabelas += "+"+oJsonArq["union"]["unionori"][nJ]["table"]
									Next nJ
								EndIf

								cTabelas += " x "+oJsonArq["tabdes"]
								If oJsonArq["union"]["uniondes"] <> NIL
									For nJ := 1 to Len(oJsonArq["union"]["uniondes"])								
										cTabelas += "+"+oJsonArq["union"]["uniondes"][nJ]["table"]
									Next nJ
								EndIf
							Else
								cTabelas := oJsonArq["tabori"]+" x "+oJsonArq["tabdes"]
							EndIf
						Else
							C930MsgBox(STR0042+cNomArq) //"Objetos TABORI e TABDES n�o encontrados no arquivo: "
							lPathVld	:= .F.
						EndIf

						cInfoArq := cNomArq+" ("+DtoC(aDatas[nI])+" "+aHoras[nI]+")"
						
						aAdd(aStruRet,{ cDescEmp,;								
										cConfig,;
										cTabelas,;
										cInfoArq})
					Else
						C930MsgBox(STR0043+cNomArq) //"Erro na estrutura do arquivo JSON: "
						lPathVld	:= .F.
					EndIf		
				EndIf
			Next
			//Se entrou neste if, a pasta selecionada cont�m os arquivos de configura��o
			cPathSave   := cPath
		Else
			C930MsgBox(STR0068)		 //"N�o foram encontrados arquivos de configura�ao no diret�rio selecionado"
			lPathVld	:= .F.
			cPathSave	:= ""
		EndIf
	EndIf
EndIf
Return aStruRet

/*{Protheus.doc} WizLinkComp
Link da documenta��o 

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizLinkComp(oStartWiz)
Local bBlocMsg := {|| ShellExecute( "Open", "https://tdn.totvs.com/pages/viewpage.action?pageId=638741736", "", "C:\", 1 )}
Local oFont1   := TFont():New('Arial',,13,,,,,,,.F.)
Local oPanel   := oStartWiz:oMPanel[oStartWiz:nPanel]
Local oSayDoc

oSayDoc := TSay():New(054,180,{|| STR0005 },oPanel,,oFont1,,,,.T.,CLR_HBLUE,,200,100,,,,,,.F./*lHtml*/) //"aqui."

oSayDoc:bLClicked := bBlocMsg

Return 

/*{Protheus.doc} WizLinkEsp
Link da documenta��o espec�fica de cada op��o

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizLinkEsp(oMainWiz)
Local bBlocM1 := {|| ShellExecute( "Open", "https://tdn.totvs.com/pages/viewpage.action?pageId=644712574", "", "C:\", 1 )}
Local bBlocM2 := {|| ShellExecute( "Open", "https://tdn.totvs.com/pages/viewpage.action?pageId=644712730", "", "C:\", 1 )}
Local bBlocM3 := {|| ShellExecute( "Open", "https://tdn.totvs.com/pages/viewpage.action?pageId=644712794", "", "C:\", 1 )}
Local bBlocM4 := {|| ShellExecute( "Open", "https://tdn.totvs.com/pages/viewpage.action?pageId=644712856", "", "C:\", 1 )}
Local oFont1   := TFont():New('Arial',,14,,,,,,,.F.)
Local oPanel   := oMainWiz:oMPanel[oMainWiz:nPanel]
Local oSayOpc1
Local oSayOpc2
Local oSayOpc3
Local oSayOpc4

oSayOpc1 := TSay():New(056,137,{|| STR0006 },oPanel,,oFont1,,,,.T.,CLR_HBLUE,,200,100,,,,,,.F./*lHtml*/) //"saiba mais"
oSayOpc2 := TSay():New(065,137,{|| STR0006 },oPanel,,oFont1,,,,.T.,CLR_HBLUE,,200,100,,,,,,.F./*lHtml*/) //"saiba mais"
oSayOpc3 := TSay():New(074,137,{|| STR0006 },oPanel,,oFont1,,,,.T.,CLR_HBLUE,,200,100,,,,,,.F./*lHtml*/) //"saiba mais"
oSayOpc4 := TSay():New(083,137,{|| STR0006 },oPanel,,oFont1,,,,.T.,CLR_HBLUE,,200,100,,,,,,.F./*lHtml*/) //"saiba mais"

oSayOpc1:bLClicked := bBlocM1
oSayOpc2:bLClicked := bBlocM2
oSayOpc3:bLClicked := bBlocM3
oSayOpc4:bLClicked := bBlocM4

Return 

/*{Protheus.doc} C930VldSel
Valida se pelo menos um item foi selecionado

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Function C930VldSel(aCols930a)
Local lRet := .F.
Local nI := 0

For nI := 1 to Len(aCols930a)
	lRet := aCols930a[nI,1]
	If lRet 
		Exit
	EndIf
Next

If !lRet
	C930MsgBox(STR0045) //"� obrigat�rio selecionar pelo menos um registro."
EndIf

Return lRet

/*{Protheus.doc} C930TemQLB
Valida se existe a tabela QLB no dicion�rio

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function C930TemQLB()
Return ChkFile("QLB")

/*{Protheus.doc} C930LdSM0
Valida se existe a tabela QLB no dicion�rio

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function C930LdSM0(oStartWiz)
Local nI      	 := 0
Local aLisEmpAux := FWAllGrpCompany()
Local aCols 	 := {}

//Carrega o acols somente com os grupos 
For nI := 1 to Len(aLisEmpAux)	
	cEmpAux := aLisEmpAux[nI]
	aAdd(aCols,{.F.,;
				cEmpAux,;
				AllTrim(FWGrpName(cEmpAux)),;
				.F.})	
Next nI

If Len(aCols) > 0
	C930MkSM0(oStartWiz, aCols)
EndIf

Return aCols

/*{Protheus.doc} C930MkSM0
Monta teta com os dados de grupo empresa

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function C930MkSM0(oStartWiz, aCols)
	Local oPanel := oStartWiz:oMPanel[oStartWiz:nPanel]	
	Local oBrowseSM0 := nil

	DEFAULT aCols := {}

	_lMarker  := .T.

    oBrowseSM0 := fwBrowse():New(oPanel)
    oBrowseSM0:setDataArray()
    oBrowseSM0:setArray(aCols)
    oBrowseSM0:disableConfig()
    oBrowseSM0:disableReport() 
	oBrowseSM0:SetEditCell(.T.)

    oBrowseSM0:AddMarkColumns({|| IIf(aCols[oBrowseSM0:nAt,1], "LBOK", "LBNO")},; //Code-Block image
    					      {|| WizMarkLin(oBrowseSM0, aCols)},; 				  //Code-Block Double Click
        					  {|| WizMarkAll(oBrowseSM0, 1, aCols)}) 			  //Code-Block Header Click 
	
	oBrowseSM0:AddColumn( {STR0059, {||aCols[oBrowseSM0:nAt,2]}, "C", "@!", 1, 2, 0, .F.,{||}, .F.,, "aCols[oBrowseSM0:nAt,2]",{|| AlwaysTrue()}, .F., .T.,{}, "ID_01"}) //"C�digo"
	oBrowseSM0:AddColumn( {STR0060, {||aCols[oBrowseSM0:nAt,3]}, "C", "@!", 1, 60, 0, .F.,{||}, .F.,, "aCols[oBrowseSM0:nAt,3]",{|| AlwaysTrue()}, .F., .T.,{}, "ID_02"}) //"Grupo de empresas"

    oBrowseSM0:Activate(.T.)  

Return

/*{Protheus.doc} C930VldGrp
Valida se foi selecionado um grupo empresa

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function C930VldGrp(_aGrpEmpSel)
Local lRet := .F.
Local nI := 0

DEFAULT _aGrpEmpSel := {}

For nI :=  1 to Len(_aGrpEmpSel)
	If (lRet := _aGrpEmpSel[nI,1])
		Exit
	EndIf
Next nI

If !lRet
	C930MsgBox(STR0061) //"Processamento Finalizado" //"Para avan�ar, selecione um grupo empresa."
EndIf

Return lRet

/*{Protheus.doc} C930SetEnv
Abre o primeiro grupo empresa / filial v�lidos
@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function C930SetEnv()
Local nI := 0
Local cEmpAux := ""
Local cFilAux := ""
Local lRet    := .F.

DEFAULT aSM0  := {}

SetRegua(3)

IncRegua()

OpenSm0()	
aSM0 := FWLoadSM0()

For nI := 1 to Len(aSM0)			
	cEmpAux := aSM0[nI][1]		
	cFilAux := aSM0[nI][2]
	
	//Prote��o para um problema encontrado em cliente piloto (dicion�rio ctree)
	//O cliente tinha registros deletados com o campo de grupo empresa em branco
	//Na vers�o do cliente esses registros eram trazidos no retorno da fwloadsm0
	If Empty(cEmpAux)
		Loop
	EndIf

	//Valido se a empresa tem o dicion�rio criado antes de tentar abrir
	If TCCanOpen("SX2"+cEmpAux+"0") 
		RpcSetType(3)
		lRet := RpcSetEnv(cEmpAux, cFilAux)	
		
		//Provis�rio - Tratamento para contornar erro na LIB
		__cUserID := "000000"

		//Ap�s setar o ambiente, atualizo a lista da SM0 em mem�ria
		aSM0 := FWLoadSM0(.T.) 		
		Exit
	EndIf
Next nI

Return aSM0

/*{Protheus.doc} C930Ajusta
Ajusta o array de empresas de acordo com o selecionado

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function C930Ajusta()
Local nI := 0
Local cEmpSel := ""
Local cEmpAux := ""
Local jListEmp
Local aSM0Aux := {}

jListEmp := C930listEmp()

For nI := 1 to Len(_aListaSM0)
	cEmpSel := _aListaSM0[nI,1]
	
	If cEmpSel <> cEmpAux
		lAddArray := .F.
		If jListEmp[cEmpSel] <> nil
			lAddArray := .T.
		EndIf
		cEmpAux := cEmpSel
	EndIf

	If lAddArray		
		aAdd(aSM0Aux, {_aListaSM0[nI,1], _aListaSM0[nI,2]})
	EndIf
Next nI

Return aSM0Aux

/*{Protheus.doc} C930listEmp
Cria um objeto json com as empresas selecionadas
Objetivo: evitar aScan / performance

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function C930listEmp()
Local oRet := JsonObject():New()
Local nI := 0

For nI := 1 to Len(_aGrpEmpSel)
	If _aGrpEmpSel[nI,1]
		oRet[_aGrpEmpSel[nI,2]] := _aGrpEmpSel[nI,2]
	EndIf
Next nI

Return oRet

/*{Protheus.doc} C930GetPsw
Exige a senha do admin para prosseguir

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function C930GetPsw(oStartWiz, cPassWiz)
Local oPanel   := oStartWiz:oMPanel[oStartWiz:nPanel]
Local oArial10 := tFont():New("Arial",,-11,,.T.)
Local cUserWiz := STR0062 //"Administrador"

TSay():New(83, 15,{|| STR0063 },oPanel,,oArial10,,,,.T.) //"Usu�rio:"
TGet():New(80, 40, { | u | If( PCount() == 0, cUserWiz, cUserWiz := u ) },oPanel, ;
			060, 010, "",{|| .T.},,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F. ,,"cUserWiz",,,,.T.  )

TSay():New(98, 15,{|| STR0064 },oPanel,,oArial10,,,,.T.) //"Senha:"
TGet():New(95, 40, { | u | If( PCount() == 0, cPassWiz, cPassWiz := u ) },oPanel, ;
			060, 010, "",{|| .T.},,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.T.,,"cPassWiz",,,,.T.  )
	
Return

/*{Protheus.doc} C930VldPsw
Valida a senha do admin para prosseguir

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Function C930VldPsw(cPassAux)
Local lRet := .F.
DEFAULT cPassAux := ""

If !Empty(cPassAux)
	PswOrder(1)
	If PswSeek("000000")
		lRet := PswName(cPassAux)
	EndIf

	If !lRet
		C930MsgBox(STR0065) //"Senha inv�lida."
	EndIf
EndIf

Return lRet 
