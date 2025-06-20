#INCLUDE "PROTHEUS.CH"
#INCLUDE "ATFA440.CH"

Static lDefTop		:= IfDefTopCTB()
Static lMultMoed	:= .T.
Static lCtrlAprov	:= .T.
Static lDtExec		:= ""

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA440   �Autor  �Renan Guedes        � Data �  11/07/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Revis�o do AVP                                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFA440()

Local cFiltra		:= "ATFA440FIL()"
Local cFilQry		:= ""
Local aAreaSN1		:= {}
Local aAreaSN3		:= {}
Local nTamProj		:= 0
Local lRet			:= .T.

Private aRotina 	:= MenuDef()
Private cCadastro	:= STR0001		//"Revis�o de Ajuste a Valor Presente (AVP)"
Private aCores		:= AFA440Leg(.T.)
Private aIndexFNF 	:= {}
Private bFiltraBrw	:= { || FilBrowse("FNF",@aIndexFNF,@cFiltra) }
Private lProjeto	:= .F.

//Verifica a existencia da data de execucao de AVP na tabela FNF
If Empty(lDtExec)
	lDtExec		:= .T.
Endif

//Inclui os novos lan�amentos padr�es da revis�o do AVP
ChkCVA()

If lRet
	//Verifica se o campo de projeto existe
	dbSelectArea("SN1")
	aAreaSN1 := SN1->(GetArea())
	lProjeto := .T.
	nTamProj := TamSX3("N1_PROJETO")[1]
	SN1->(dbSetOrder(1))		//N1_FILIAL+N1_CBASE+N1_ITEM
	
	dbSelectArea("SN3")
	aAreaSN3 := SN3->(GetArea())
	SN3->(dbSetOrder(1))		//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
	
	dbSelectArea("FNF") 
	FNF->(dbSetOrder(1)) 
	
	If lDefTop
		//Cria a query de retorno dos registros que ser�o exibidos no browse
		cFilQry := "	R_E_C_N_O_ IN (	"
		cFilQry += "		SELECT FNF.R_E_C_N_O_	"
		cFilQry += "			FROM " + RetSqlTab("FNF")
		If lProjeto
			cFilQry += "			," + RetSqlTab("SN1")
		EndIf
		cFilQry += "			WHERE 	FNF.D_E_L_E_T_ != '*'	"
		If lProjeto
			cFilQry += "			AND SN1.D_E_L_E_T_ != '*'	"
		EndIf
		cFilQry += "				AND FNF.FNF_FILIAL	= '" + xFilial("FNF") + "'	"
		cFilQry += "				AND FNF.FNF_TPMOV	= '1'						"
		cFilQry += "				AND FNF.FNF_MSBLQL	!= '1'						"

		If lProjeto
			cFilQry += "			AND SN1.N1_FILIAL	= '" + xFilial("SN1") + "'	"
			cFilQry += "			AND SN1.N1_CBASE	= FNF.FNF_CBASE				"
			cFilQry += "			AND SN1.N1_ITEM		= FNF.FNF_ITEM				"
			cFilQry += "			AND SN1.N1_PROJETO	= '" + Space(nTamProj) + "'	"
		EndIf

		cFilQry += "	)	"
	Else
		//Aplica o filtro no alias FNF
		Eval(bFiltraBrw)
		//Ativa o filtro
		FNF->(dbGoTop())
	EndIf
	
	mBrowse(006,001,022,075,"FNF",,,,,,aCores,,,,,,,,cFilQry)
	
	RestArea(aAreaSN3)
	RestArea(aAreaSN1)
	
	If !lDefTop
		//Desfaz o filtro no alias FNF
		EndFilBrw("FNF",aIndexFNF)
	EndIf
EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MENUDEF   �Autor  �Renan Guedes        � Data �  11/07/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

aRotina	:= {	{ STR0002	,"AxPesqui"  , 0, 1 , ,.F.	},;		//"Pesquisar"
				{ STR0003	,"AxVisual"  , 0, 2			},;		//"Visualizar"
				{ STR0005	,"AFA440Rev" , 0, 4			},;		//"Revisar"
				{ STR0007	,"AFA440Leg" , 0, 6			}}		//"Legenda"

Return(aRotina)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AFA440Leg   �Autor  �Renan Guedes      � Data �  11/16/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Legenda do browse                                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�lRetCor =  Se verdadeiro, monta a regra de cores, do  	  ���
���          �			 contr�rio monta a janela da legenda              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �aCores =   Regra de cores ou janela da legenda              ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFA440Leg(lRetCor)

Local aRet		:= {}
Local aCores 	:= {}

Default lRetCor := .F. 

aCores	:=	{{	"BR_VERDE"		,"FNF_TPMOV == '1' .And. FNF_STATUS == '1'", STR0008	},;		//"Ativo"
			{	"BR_VERMELHO"	,"FNF_TPMOV == '1' .And. FNF_STATUS == '2'", STR0009	},;		//"Encerrado"
			{	"BR_AZUL"		,"FNF_TPMOV == '1' .And. FNF_STATUS == '7'", STR0010	},;		//"Bloqueado por revis�o"
			{	"BR_AMARELO"	,"FNF_TPMOV == '1' .And. FNF_STATUS == '8'", STR0011	},;		//"Bloqueado por aprova��o"
			{	"BR_PRETO"		,"FNF_TPMOV == '1' .And. FNF_STATUS == '9'", STR0012	}}		//"Bloqueado por usu�rio"

If ValType(lRetCor) != 'L'
	lRetCor := .F.
EndIf

If lRetCor
	aEval( aCores, {|x|  Aadd( aRet, {x[2],x[1]} ) } ) 
Else
	aEval( aCores, {|x|  Aadd( aRet, {x[1],x[3]} ) } ) 
	BrwLegenda(cCadastro, STR0007, aRet)
	aRet := Nil
EndIf

Return(aRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AFA440Rev    �Autor  �Renan Guedes     � Data �  11/07/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Browse da rotina de revis�o de AVP                          ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFA440Rev(cAlias,nReg,nOpc)

Local nOpcA			:= 0
Local aVisual		:= {}		//Campos que ser�o exibidos
Local aEdit			:= {}		//Campos que permitem edi��o
Local nOpcX			:= 0
Local aAreaSX3		:= {}
Local oDlg, oGetRev
Local aDms  		:= FWGetDialogSize(oMainWnd)
Local bUpdate  		:= {|| IIF(Obrigatorio(oGetRev:aGets,oGetRev:aTela) .And. AF440TudOk(oGetRev),(nOpcA := 1,oDlg:End()),Nil)}
Local bEndWin		:= {|| oDlg:End()}
Local lRet			:= .T.
Local dUltDepr		:= GetNewPar("MV_ULTDEPR", STOD("19800101"))
Local aAreaSN1		:= {}
Local aAreaFNF		:= {}

//Verifica a existencia da data de execucao de AVP na tabela FNF
If Empty(lDtExec)
	lDtExec		:= .T.
Endif

nOpcX := aRotina[nOpc,4]

If !(FNF->FNF_STATUS == '1')		//Valida se a constitui��o posicionada est� ativa
	lRet := .F.
	Help("",1,"AFA440ENCE",,STR0018+CRLF+STR0019,1,0)		//"N�o � poss�vel revisar constitui��es encerradas ou bloqueadas."###"A revis�o do ajuste a valor presente somente pode ser realizada para as constitui��es ativas"
ElseIf dDataBase <= dUltDepr	//Valida se a data da revis�o � maior que a data da �ltima deprecia��o
	lRet := .F.
	Help("",1,"AFA440DEPR")		//"N�o � poss�vel realizar revis�es em data igual ou inferior a data do �ltimo c�lculo de deprecia��o."##"Realize a revis�o ap�s a data do �ltimo c�lculo de deprecia��o."
EndIf

If lRet
	//Verifica a existencia de revisao com pendencia de aprovacao
	aAreaFNF := FNF->(GetArea())
	FNF->(DBSetOrder(4))		//FNF_FILIAL+FNF_CBASE+FNF_ITEM+FNF_TPMOV+FNF_STATUS
	If FNF->( MsSeek(xFilial("FNF")+FNF->(FNF_CBASE+FNF_ITEM+FNF_TPMOV+"7")) )
		lRet := .F.
		Help("",1,"AFA440INREV",,STR0014+CRLF+STR0015,1,0)   //"Esta constitui��o de AVP possui processo de revis�o aguardando aprova��o."###"Para nova revis�o, � necess�ro que o processo pendente seja aprovado ou rejeitado."
	Endif
	FNF->(RestArea(aAreaFNF))
Endif

If lRet
	dbSelectArea("SN1")
	aAreaSN1 := SN1->(GetArea())
	dbSetOrder(1)		//N1_FILIAL+N1_CBASE+N1_ITEM
	
	If SN1->(MsSeek(xFilial("SN1")+FNF->(FNF_CBASE+FNF_ITEM)))
		//Valida se a data da revis�o � maior ou igual a data de aquisi��o do bem
		If dDataBase < SN1->N1_AQUISIC
			lRet := .F.
			Help("",1,"AFA440AQUI")		//"N�o � poss�vel realizar a revis�o em data inferior a aquisi��o do bem."##"Realize a revis�o em data igual ou superior a aquisi��o do bem."
		EndIf
	EndIf
	
	RestArea(aAreaSN1)
EndIf

If lRet
	//Monta array com os campos que ser�o editados
	dbSelectArea("SX3")
	aAreaSX3 := SX3->(GetArea())
	SX3->(dbSetOrder(1))		//X3_ARQUIVO+X3_ORDEM+X3_CAMPO
	If SX3->(MsSeek("FNF"))
		While SX3->(!EoF()) .And. SX3->X3_ARQUIVO == "FNF"
			If AllTrim(SX3->X3_CAMPO) $ "FNF_CBASE|FNF_ITEM|FNF_TIPO|FNF_SEQ|FNF_TPSALD|FNF_DTAVP|FNF_BASE|FNF_STATUS|FNF_MSBLQL|FNF_MOEDA|";
				.And. X3USO(SX3->X3_USADO) .And. cNivel >= X3_NIVEL			
				AADD(aVisual	, SX3->X3_CAMPO)
			ElseIf AllTrim(SX3->X3_CAMPO) $ "FNF_INDAVP|FNF_DTEXEC";
				.And. X3USO(SX3->X3_USADO) .And. cNivel >= X3_NIVEL
				AADD(aVisual	, SX3->X3_CAMPO)
				AADD(aEdit		, SX3->X3_CAMPO)
			EndIf
			SX3->(dbSkip())
		EndDo
	EndIf
	RestArea(aAreaSX3)
	
	dbSelectArea("FNF") 
	FNF->(dbSetOrder(1))
	FNF->(dbGoTo(nReg))
	
	//Carrega os dados da constitui��o posicionada
	RegToMemory("FNF",.F.)
	
	//Ajuste para que a Data de execucao do AVP nao esteja em branco (registros antigos)
	If lDtExec .and. Empty(M->FNF_DTEXEC)
		M->FNF_DTEXEC := SN1->N1_DTAVP
	Endif

	//Cria a tela da revis�o
	oDlg := MsDialog():New(aDms[1],aDms[2],aDms[3],aDms[4],cCadastro,,,,,,,,oMainWnd,.T.)  
	oGetRev := MsMGet():New(cAlias,nReg,nOpcX,,,,aVisual,{0,0,150,200},aEdit,,oDlg,,.T.,,,.T.)
	oGetRev:oBox:Align		:= CONTROL_ALIGN_ALLCLIENT
	oDlg:Activate(,,,.T.,,,EnchoiceBar(oDlg,bUpdate,bEndWin))
	
	//Se confirmado, processa a revis�o
	If nOpcA == 1
		AF440Grava(oGetRev,nReg)
	EndIf
	
	dbSelectArea("FNF")
	FNF->(dbSetOrder(1))
EndIf

Return(.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AF440TudOk   �Autor  �Renan Guedes     � Data �  11/07/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��o de valida��o da confirma��o da grava��o da nova      ���
���          �taxa de AVP                                                 ���
�������������������������������������������������������������������������͹��
���Parametros�oGetRev =  Objeto da dialog de revis�o de AVP               ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AF440TudOk(oGetRev,cStatus,lAprov,nRec)
           
Local lRet			:= .T.
Local aArea			:= {}
Local aAreaSN1		:= {}
Local aAreaSN3		:= {}
Local aAreaFIT		:= {}
Local aAreaFIU		:= {}
Local cPeriodo		:= ""
Local nTaxa			:= 0
Local cIndAVP		:= ""
Local lAltDtExec	:= .F.
Local dDtExec		:= CTOD("//")

//Verifica a existencia da data de execucao de AVP na tabela FNF
If Empty(lDtExec)
	lDtExec		:= .T.
Endif

Default cStatus		:= "2"
Default lAprov		:= .F.
Default nRec		:= 0

If !lAprov

	//Verifico se a data de execucao do AVP foi alterado
	If lDtExec .and. M->FNF_DTEXEC != FNF->FNF_DTEXEC
		lAltDtExec := .T.
	Endif

	If M->FNF_INDAVP == FNF->FNF_INDAVP		//Verifica se o �ndice realmente foi alterado
		nTaxa := AtfRetInd(M->FNF_INDAVP, dDataBase)
		If nTaxa != FNF->FNF_TAXA
			If !IsBlind()
				If !MsgNoYes(STR0013) //"A taxa para o indice financeiro atual � diferente da taxa original do bem, deseja realizar a revis�o? " 
					lRet := .F.
				EndIf
			Else
				lRet := .F.
			EndIf
		ElseIf !lAltDtExec
			lRet := .F.
		EndIf 
	EndIf
EndIf

If lRet
	If lAprov .And. (nRec > 0)
		dbSelectArea("FNF")
		FNF->(dbGoTo(nRec))
		cIndAVP := FNF->FNF_INDAVP
	Else
		cIndAVP := M->FNF_INDAVP
	EndIf
EndIf

If lRet
	aArea := GetArea()
	
	dbSelectArea("FIT")
	aAreaFIT := FIT->(GetArea())
	cPeriodo := Posicione("FIT", 1, xFilial("FIT")+cIndAVP, "FIT_PERIOD")
	
	//Atualiza a taxa do �ndice
	dbSelectArea("FIU")
	aAreaFIU := FIU->(GetArea())
	nTaxa := AtfRetInd(cIndAVP, dDataBase)
	
	//Posiciona nos registros do bem
	dbSelectArea("SN1")
	aAreaSN1 := SN1->(GetArea())
	SN1->(dbSetOrder(1))		//N1_FILIAL+N1_CBASE+N1_ITEM
	
	//Posiciona nos registros do bem
	dbSelectArea("SN3")
	aAreaSN3 := SN3->(GetArea())
	SN3->(dbSetOrder(11))		//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO
	
	If SN1->(MsSeek(xFilial("SN1")+FNF->(FNF_CBASE+FNF_ITEM)))
		//If SN3->(MsSeek(xFilial("SN3")+FNF->(FNF_CBASE+FNF_ITEM+FNF_TIPO)+"0"+FNF->FNF_SEQ))
		If SN3->(MsSeek(xFilial("SN3")+FNF->(FNF_CBASE+FNF_ITEM+FNF_TIPO)+"0"+FNF->FNF_TPSALD))
			//Guarda o recno do registro
			nRecAVP := SN3->(Recno())
			
			//Data de execucao do AVP
			If lDtExec
				If  UPPER(Funname()) == "ATFA440" .AND. ALTERA .AND. !EMPTY(M->FNF_DTEXEC)
					dDtExec := M->FNF_DTEXEC
			 	Else
    				dDtExec := FNF->FNF_DTEXEC
    			EndIf
			Else    			
				dDtExec := SN1->N1_DTAVP
			Endif
			
			//Calcula a constitui��o do novo �ndice
			nValPres	:= 0
			nValAVP		:= 0
			AFCalcAVP("C",nTaxa,cIndAVP,FNF->FNF_BASE,cPeriodo,dDataBase,@nValPres,@nValAVP,dDtExec)
			
			//Posiciona novamente no registro do AVP
			SN3->(dbGoTo(nRecAVP))
			
		EndIf
	EndIf
	
	RestArea(aAreaSN3)
	RestArea(aAreaSN1)
	RestArea(aAreaFIU)
	RestArea(aAreaFIT)
	RestArea(aArea)
EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA440FIL   �Autor  �Renan Guedes     � Data �  11/08/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Filtro do browse da tabela FNF                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �lRet =  Verdadeiro se o registro deve ser exibido no browse ���
���          �		  e falso quando contr�rio                            ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFA440FIL()

Local lRet			:= .T.
Local aArea			:= {}

aArea := GetArea()

//Valida��o pr�via: movimento de constitui��o ativo e desbloqueado
If !(FNF->FNF_TPMOV == '1' .And. FNF_MSBLQL != '1')
	lRet := .F.
EndIf

If lRet
	//Valida se o bem n�o est� vinculado a um projeto
	If SN1->(MsSeek(xFilial("SN1")+FNF->(FNF_CBASE+FNF_ITEM)))
		If lProjeto
			lRet := !ATFXVerPrj(FNF->FNF_CBASE,FNF->FNF_ITEM,.F.)
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AF440Grava   �Autor  �Renan Guedes     � Data �  11/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Grava��o da revis�o de AVP                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�oGetRev	= Objeto da tela de revis�o do AVP                ���
���          �nReg		= Recno do registro da constitui��o na tabela FNF ���
���          �lAprRev	= Processo de aprova��o da revis�o (.T.) ou n�o   ���
���          �		      (.F.)                                           ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AF440Grava(oGetRev,nReg,lAprRev,cIndAVP,dDataAVP,lProcAprov,lMostraCTB,dDataExec)

Local aArea			:= {}
Local aAreaSN1		:= {}
Local aAreaSN3		:= {}
Local aAreaFIT		:= {}
Local aAreaFIU		:= {}
Local aAreaFNF		:= {}
Local nTaxa			:= 0
Local nValPres		:= 0
Local nValAVP		:= 0
Local lRet			:= .T.
Local cIdProc		:= ""
Local aDepAcm10		:= Array(Len(If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )),3)
Local aDepAcm14		:= Array(Len(If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )),3)
Local aDados10		:= {}
Local aDados14		:= {}
Local aStruSN3		:= {}
Local nX			:= 0
Local cSeq10		:= ""
Local cSeq14		:= ""
Local lAprov		:= .F.
Local cOrigem		:= ""
Local cPeriodo		:= ""
Local nRecFNF		:= 0
Local cProcPai		:= ""
Local lRevisand	:= UPPER(Funname()) == "ATFA440" .AND. ALTERA
Local aRecFNF :={}
Local cProcesso := ""
Local nOrdFNF    := 1
Private aRecCTB		:= {}
Private nTotal		:= 0
Private nHdlPrv		:= 0
Private cLoteAtf	:= LoteCont("ATF")
Private cArquivo	:= ""

Default oGetRev		:= Nil
Default nReg		:= 0
Default lAprRev		:= .F.		//Aprova��o da revis�o?
Default cIndAVP     := ""
Default dDataAVP    := dDataBase
Default lProcAprov  := .T.
Default lMostraCTB  := .T.
Default dDataExec   := Ctod("")

//Verifica a existencia da data de execucao de AVP na tabela FNF
If Empty(lDtExec)
	lDtExec		:= .T.
Endif

aArea := GetArea()

If !Empty(nReg)
	FNF->(dbGoTo(nReg))
EndIf

//Se for aprova��o da revis�o, posiciona no registro antigo da constitui��o
If lAprRev
	dbSelectArea("FNF")
	aAreaFNF := FNF->(GetArea())
	FNF->(dbGoTo(nReg))
	cProcPai := FNF->FNF_IDPRCP
	
	If Empty(cIndAVP)
		cIndAVP := FNF->FNF_INDAVP
	EndIf
	
	FNF->(dbSetOrder(3))		//FNF_FILIAL+FNF_IDPROC+FNF_TPMOV+FNF_STATUS
	If FNF->(MsSeek(xFilial("FNF")+cProcPai+"1"+"1"))
		nRecFNF := nReg
		nReg	:= FNF->(Recno())
	EndIf
	RestArea(aAreaFNF)
	FNF->(dbGoTo(nReg))
EndIf

dbSelectArea("FIT")
aAreaFIT := FIT->(GetArea())
If !lAprRev
	If Empty(cIndAVP)
		cIndAVP	:= M->FNF_INDAVP
	EndIf
EndIf
cPeriodo := Posicione("FIT", 1, xFilial("FIT")+cIndAVP, "FIT_PERIOD")

//Atualiza a taxa do �ndice
dbSelectArea("FIU")
aAreaFIU := FIU->(GetArea())

//Posiciona nos registros do bem
dbSelectArea("SN1")
aAreaSN1 := SN1->(GetArea())
SN1->(dbSetOrder(1))		//N1_FILIAL+N1_CBASE+N1_ITEM

//Posiciona nos registros do bem
dbSelectArea("SN3")
aAreaSN3 := SN3->(GetArea())
SN3->(dbSetOrder(1))		//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

//Gera um novo c�digo de processo
cIdProc	:= GetSxeNum('FNF','FNF_IDPROC','FNF_IDPROC'+cEmpAnt,3)

//Verifica se o controle de aprova��o est� habilitado
If lCtrlAprov .And. lProcAprov
	lAprov := ATFxCtrlAprov("ATFA440","06")		//Revisar
EndIf

BEGIN TRANSACTION		//Controle de transa��o
	
	//Sem controle de aprova��o ou aprova��o da revis�o:
	If !lAprov .Or. lAprRev
		If lRet
			//Taxa do �ndice antigo
			nTaxa := AtfRetInd(FNF->FNF_INDAVP,dDataAVP)
			//Posiciona no bem
			If SN1->(MsSeek(xFilial("SN1")+FNF->(FNF_CBASE+FNF_ITEM)))
				//Posiciona SN3
				If SN3->(MsSeek(xFilial("SN3")+FNF->(FNF_CBASE+FNF_ITEM+FNF_TIPO)+"0"+FNF->FNF_SEQ))
					//Calcula a apropria��o do �ndice antigo at� a data atual
					nValPres	:= 0
					nValAVP		:= 0
					AFCalcAVP("A",nTaxa,FNF->FNF_INDAVP,FNF->FNF_BASE,FNF->FNF_PERIND,dDataAVP,@nValPres,@nValAVP,Iif(lRevisand .AND. !EMPTY(M->FNF_DTEXEC),M->FNF_DTEXEC,SN1->N1_DTAVP))
					//Grava a apropria��o do �ndice antigo at� a data atual
					AfGrvAvp(xFilial("FNF"),"2",dDataAVP,FNF->FNF_CBASE,FNF->FNF_ITEM,FNF->FNF_TIPO,FNF->FNF_TPSALDO,' ',FNF->FNF_SEQ,,nValAVP,.T.,@nTotal,@nHdlPrv,cLoteAtf,,cIdProc,aRecCTB,,,,"ATFA440",@cArquivo,,,,,,Iif(lRevisand .AND. !EMPTY(M->FNF_DTEXEC),M->FNF_DTEXEC,SN1->N1_DTAVP))
				Else
					lRet := .F.
				EndIf
			Else
				lRet := .F.
			EndIf
		EndIf
		
		//Reposiciona na constitui��o antiga
		If lRet
			FNF->(dbGoTo(nReg))
			//Taxa do novo �ndice
			nTaxa := AtfRetInd(cIndAVP,dDataAVP)
			//Posiciona no bem
			If SN1->(MsSeek(xFilial("SN1")+FNF->(FNF_CBASE+FNF_ITEM)))
				If SN3->(MsSeek(xFilial("SN3")+FNF->(FNF_CBASE+FNF_ITEM+FNF_TIPO)+"0"+FNF->FNF_SEQ))
					If lAprRev
						//Reposiciona na constitui��o antiga
						FNF->(dbGoTo(nReg))
						Reclock("FNF",.F.)
						FNF->FNF_STATUS := '2' //Encerrado
						MsUnlock()
						//Posiciona no novo registro de constitui��o
						FNF->(dbGoTo(nRecFNF))
					EndIf
					//Altera o indice de AVP do SN1
					RecLock("SN1",.F.)
					SN1->N1_INDAVP := cIndAVP
					SN1->N1_TAXAVP := nTaxa
					SN1->N1_INIAVP := dDataAVP
					//Grava nova data de execucao no SN1
					If lDtExec
						If Empty(dDataExec) .AND. !EMPTY(M->FNF_DTEXEC)
							SN1->N1_DTAVP := M->FNF_DTEXEC
						ElseIf !Empty(dDataExec)
							SN1->N1_DTAVP := dDataExec
						EndIf
					Endif
					SN1->(MSUnlock())
					
					//Calcula a constitui��o do novo �ndice
					nValPres	:= 0
					nValAVP		:= 0
					AFCalcAVP("C",nTaxa,cIndAVP,FNF->FNF_BASE,cPeriodo,dDataAVP,@nValPres,@nValAVP,Iif(lRevisand .AND. !EMPTY(M->FNF_DTEXEC),M->FNF_DTEXEC,SN1->N1_DTAVP))
					
					//Reposiciona na constituicao antiga para obter o valor original
					FNF->(dbGoTo(nReg))
					If lAprRev
						//Posiciona no novo registro de constitui��o
						FNF->(dbGoTo(nRecFNF))
						Reclock("FNF",.F.)
						FNF->FNF_DTAVP	:= dDataAVP
						FNF->FNF_VALOR	:= nValAVP
						FNF->FNF_AVPVLP	:= nValPres
						FNF->FNF_STATUS	:= "1"
						MsUnlock()
						// Aprovar os demais registros do Processo de Revis�o de AVP
						nOrdFNF := FNF->(IndexOrd())
						cProcesso := FNF->FNF_IDPROC
						FNF->(dbSetOrder(3))
						FNF->(dbSeek(xFilial("FNF")+cProcesso))
						while !Eof() .and. FNF->(FNF_FILIAL + FNF_IDPROC) = xFilial("FNF")+cProcesso
							if FNF->FNF_STATUS <> '1'
								aAdd(aRecFNF , FNF->(Recno()))
							endif	
							dbSkip()
						enddo
						//Aprovar aos registros do processo
						for nX := 1 To Len(aRecFNF)
							FNF->(dbGoto(aRecFNF[nX]))	
							Reclock("FNF",.F.)
							FNF->FNF_STATUS	:= "1"		//Aprovado
							MsUnlock()
						next
						FNF->(dbSetOrder(nOrdFNF))
						FNF->(dbGoTo(nRecFNF))

					Else
						
						//Grava registro de diferenca por revisao de AVP
						AfGrvAvp(xFilial("FNF"),"A",dDataAVP,FNF->FNF_CBASE,FNF->FNF_ITEM,FNF->FNF_TIPO,FNF->FNF_TPSALDO,SN3->N3_BAIXA,FNF->FNF_SEQ,,nValAVP,.T.,@nTotal,@nHdlPrv,cLoteAtf,SN3->(Recno()),cIdProc,,,,nValPres,"ATFA440",@cArquivo,@nRecFNF,,cIndAvp,cPeriodo,nTaxa)
						
						//Grava a nova constitui��o
						AfGrvAvp(xFilial("FNF"),"8",dDataAVP,FNF->FNF_CBASE,FNF->FNF_ITEM,FNF->FNF_TIPO,FNF->FNF_TPSALDO,SN3->N3_BAIXA,FNF->FNF_SEQ,,nValAVP,.T.,@nTotal,@nHdlPrv,cLoteAtf,SN3->(Recno()),cIdProc,,,,nValPres,"ATFA440",@cArquivo,@nRecFNF,,,,,Iif(lRevisand .AND. !EMPTY(M->FNF_DTEXEC),M->FNF_DTEXEC,SN1->N1_DTAVP))
						//Posiciona no novo registro de constitui��o
						FNF->(dbGoTo(nRecFNF))
					EndIf
				Else
					lRet := .F.
				EndIf
			Else
				lRet := .F.
			EndIf
		EndIf
	Else //Com controle de aprova��o:
		//Posiciona no bem
		If SN1->(MsSeek(xFilial("SN1")+FNF->(FNF_CBASE+FNF_ITEM)))
			If SN3->(MsSeek(xFilial("SN3")+FNF->(FNF_CBASE+FNF_ITEM+FNF_TIPO)+"0"+FNF->FNF_SEQ))
				//Calcula a constitui��o do novo �ndice
				nValPres	:= 0
				nValAVP		:= 0
				
				//Altera o indice de AVP do SN1
				nTaxa := AtfRetInd(cIndAVP,dDataAVP)
				//Efetua calculo da constituicao do AVP (revisao)
				AFCalcAVP("C",nTaxa,cIndAVP,FNF->FNF_BASE,cPeriodo,dDataAVP,@nValPres,@nValAVP,SN1->N1_DTAVP)
				
				//Grava registro de diferenca por revisao de AVP
				AfGrvAvp(xFilial("FNF"),"A",dDataAVP,FNF->FNF_CBASE,FNF->FNF_ITEM,FNF->FNF_TIPO,FNF->FNF_TPSALDO,SN3->N3_BAIXA,FNF->FNF_SEQ,,nValAVP,.F.,@nTotal,@nHdlPrv,cLoteAtf,SN3->(Recno()),cIdProc,,,,nValPres,"ATFA440",@cArquivo,@nRecFNF,,cIndAvp,cPeriodo,nTaxa)

				//Posiciona no novo registro de diferencao por revisao
				FNF->(dbGoTo(nRecFNF))
				//Atualiza o status da constitui��o
				Reclock("FNF",.F.)
				FNF->FNF_STATUS	:= "7"		//Bloqueado por revis�o
				MsUnlock()
				
				
				//Grava a nova constitui��o
				AfGrvAvp(xFilial("FNF"),"8",dDataAVP,FNF->FNF_CBASE,FNF->FNF_ITEM,FNF->FNF_TIPO,FNF->FNF_TPSALDO,SN3->N3_BAIXA,FNF->FNF_SEQ,,nValAVP,.F.,@nTotal,@nHdlPrv,cLoteAtf,SN3->(Recno()),cIdProc,,,,nValPres,"ATFA440",@cArquivo,@nRecFNF,,cIndAvp,cPeriodo,nTaxa)
				
				//Reposiciona na constitui��o antiga
				FNF->(dbGoTo(nReg))
				Reclock("FNF",.F.)
				FNF->FNF_STATUS	:= "1"		//Mant�m ativa a constitui��o antiga
				MsUnlock()
				//Posiciona no novo registro de constitui��o
				FNF->(dbGoTo(nRecFNF))
				//Atualiza o status da constitui��o
				Reclock("FNF",.F.)
				FNF->FNF_STATUS	:= "7"		//Bloqueado por revis�o
				MsUnlock()
				//Gera o movimento de aprova��o
				cOrigem := FunName()
				AF004GrvMov("ATFA440","06",dDataAVP,,FNF->FNF_MOEDA,FNF->FNF_VALOR,cOrigem,"FNF",nRecFNF)
			EndIf
		EndIf
	EndIf
	
	//Reposiciona na constitui��o antiga
	FNF->(dbGoTo(nReg))
	
	If lRet
		//Confirma o c�digo de processo
		ConfirmSX8()
	Else
		RollBackSX8()
		DISARMTRANSACTION()		//Controle de transa��o
	EndIf
	
	If (nHdlPrv > 0) .And. (nTotal > 0)
		RodaProva(nHdlPrv, nTotal)
		cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,lMostraCTB,.F.)
	EndIf

END TRANSACTION		//Controle de transa��o

RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aAreaFIU)
RestArea(aAreaFIT)
RestArea(aArea)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AF440RepRev   �Autor  �Renan Guedes    � Data �  12/21/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Grava��o da rejei��o do movimento de aprova��o da revis�o   ���
���          �do AVP                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�nRec	= Recno do registro da nova constitui��o (bloqueada   ���
���          �		  por revis�o) na tabela FNF                          ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AF440RepRev(nRec)

Local aAreaFNF		:= {}
Local cIdProc := ''
Local aRecRep :={} // Array com os Registros a Reprovar
Local nX
Local cProcPai	:= ""
Local nAvpAcm 	:= 0
Default nRec	:= 0

If (nRec > 0)
	dbSelectArea("FNF")
	aAreaFNF := FNF->(GetArea())
	FNF->(dbGoTo(nRec))
	cIdProc := FNF->FNF_IDPROC
	dbSetOrder(3)
	dbSeek(xFilial("FNF")+cIdProc)
	// Bloquear todos os Regittos do Mesmo Processo
	cProcPai := FNF->FNF_IDPRCP // Processo Pai
	while !Eof() .and. FNF->(FNF_FILIAL + FNF_IDPROC) = xFilial("FNF")+cIdProc
		aAdd(aRecREp , FNF->(Recno()))
		dbSkip()
	enddo
	// Reprovar aos registros do processo
	for nX := 1 To Len(aRecRep)
		FNF->(dbGoto(aRecRep[nX]))
		if FNF->FNF_TPMOV = '9'
			nAvpAcm := FNF->FNF_VALOR
		Elseif FNF->FNF_TPMOV = 'A'
			nAvpAcm := -FNF->FNF_VALOR
		endif 	
		Reclock("FNF",.F.)
		FNF->FNF_STATUS	:= "8"		//Bloqueado por aprova��o
		MsUnlock()
	next
	// Ajustar o valor a AVP Acumulada descontando a Revis�o
	FNF->(dbSetOrder(3))		//FNF_FILIAL+FNF_IDPROC+FNF_TPMOV+FNF_STATUS
	If FNF->(MsSeek(xFilial("FNF")+cProcPai+"1"+"1"))
		Reclock("FNF",.F.)
		FNF->FNF_ACMAVP	-= nAvpAcm
		MsUnlock()
	EndIf
	
	RestArea(aAreaFNF)
EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FA440VldAvp� Autor � Mauricio Pequim Jr   � Data � 03.04.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de apropriacao do AVP de bens imobilizados		  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � ATFA440													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FA440VldAvp()

Local lRet := .T.

//Valida se a data de execucao do AVP foi preenchida
If Empty(M->FNF_DTEXEC)
	lRet := .F.
	Help("",1,"AF440DTEXEC",,STR0016,1,0)   //"Data de execu��o do AVP informada � inv�lida. Esta data deve ser maior que a data do movimento de constitui��o"
Endif

//Valida se a data de execucao eh maior que a data de inicio do AVP
If lRet .and. (M->FNF_DTEXEC <= M->FNF_DTAVP)
	lRet := .F.
	Help("",1,"AF440DTEXEC",,STR0017,1,0)   //"Data de execu��o do AVP informada � inv�lida. Esta data deve ser maior que a data do movimento de constitui��o"
Endif

Return lRet


