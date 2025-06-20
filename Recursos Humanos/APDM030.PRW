#include "Protheus.ch"
#include "APDM030.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � APDM030  � Autor � Eduardo Ju            � Data � 04.10.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Geracao Automatica: PDP ou Plano de Metas                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � APDM030(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAAPD                                                    ���
�������������������������������������������������������������������������Ĵ��
���            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           ���
�������������������������������������������������������������������������Ĵ��
���Programador �Data      �BOPS       �Motivo da Alteracao                ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�08/07/2014�TPZWF1     �Incluido o fonte da 11 para a 12 e ���
���            �          �           �efetuada a limpeza.                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Function APDM030( cAlias , nReg , nOpc , lExecAuto , nTipo )

Local aArea 	:= GetArea()
Local aSays		:= {}
Local aButtons	:= {} 	//<== arrays locais de preferencia
Local nOpca 	:= 0
Local oDlg
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}
Local bSet15		:= { || NIL }
//Local bSet24		:= { || NIL }
Local lValid		:= .t.
Local cTipoIni 		:= AllTrim( SuperGetMV( "MV_APDCPDP", .F., "1") )

Private cAliasTMP1	:= GetNextAlias()
Private	cAliasRDE	:= GetNextAlias()
Private cAliasTMP2	:= GetNextAlias()
Private	cAliasRD4	:= GetNextAlias()
Private oTabRDE	
Private oTabRD4

DEFAULT nTipo	:= 0	//Sem Filtro

Private cCadastro 	:= ""

If ( nTipo == 1 )   	//PDP (Plano de Desenvolvimento Pessoal)

	cCadastro	:= OemToAnsi( STR0001 )	//"Gera��o Autom�tica do Plano de Desenvolvimento Pessoal"
	AADD(aSays,OemToAnsi(STR0003)+" "+OemToAnsi(STR0004)+" "+OemToAnsi(STR0006))	//"Este programa tem a finalidade de Gerar o Plano de"###"Desenvolvimento Pessoal"###"aos participantes, de acordo com o criterio estabelecido."

ElseIf ( nTipo == 2 )	//Plano de Metas

	cCadastro	:= OemToAnsi( STR0002 )	//"Gera��o Autom�tica do Plano de Metas"
	AADD(aSays,OemToAnsi(STR0003)+" "+OemToAnsi(STR0005)+" "+OemToAnsi(STR0006))	//"Este programa tem a finalidade de Gerar o Plano de"###"Metas"###"aos participantes, de acordo com o criterio estabelecido."

EndIf

AADD(aSays,OemToAnsi(STR0035) )	//"Os avaliadores ser�o definidos pela hierarquia conforme a op��o selecionada pelo usu�rio na pergunta 'Avaliadores'."
AADD(aSays,OemToAnsi(STR0036)+" '"+cTipoIni+"', "+OemToAnsi(STR0037)+(If(cTipoIni=='1',OemToAnsi(STR0039),OemToAnsi(STR0038))) ) //"O par�metro MV_APDCPDP, atualmente com conte�do"+" '" + cTipoIni + "', "+"define que a atribui��o da manuten��o ficar� a cargo do " + "Avaliado." ou "Avaliador."

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 70	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 50	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*50), (((aObjSize[1,4])/100)*62) }	//1,3 Vertical /1,4 Horizontal

Pergunte("APDM30",.F.)

//Retirar posteriormente, junto com a retirada do COLUMNPOS
If len(TamSX1("APDM30","04")) == 0
	mv_par04 := 3 //Mentor
EndIf

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE TITLE OemToAnsi( STR0001 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL //"Pesquisar"

	@ aGdCoord[1]+5 , aGdCoord[2]	GROUP oGroupCalc TO (aGdCoord[3]/1.5),aGdCoord[4]+10  LABEL "" OF oDlg PIXEL //"Selecione o Objeto da Pesquisa"
	oGroupCalc:oFont:=oFont

	@ aGdCoord[1]+20,aGdCoord[2]+4 Say OemToAnsi( aSays[1] ) Size 900,07 Pixel Font oFont Color CLR_BLUE
	@ aGdCoord[1]+32,aGdCoord[2]+4 Say OemToAnsi( aSays[2] ) Size 900,07 Pixel Font oFont Color CLR_BLUE
	@ aGdCoord[1]+44,aGdCoord[2]+4 Say OemToAnsi( aSays[3] ) Size 900,07 Pixel Font oFont Color CLR_BLUE

	aButtons	:=	{;
					{"Perguntas" ,{ || Pergunte("APDM30",.T. ) },STR0024,STR0024};
					}

	bSet15 := { |o| nOpca := 1,IF(gpconfOK(),oDlg:End(),nOpca:=0) }

	bSvSet15 := SetKey( 15 , oDlg:bSet15 )
	bSvSet24 := SetKey( 24 , { || oDlg:End() } )

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15, { || oDlg:End() } , NIL , aButtons )

If mv_par04 == 1
	If empty(mv_par05)
		Aviso( OemToAnsi(STR0009), OemToAnsi(STR0026), { "OK" } )	//"Aten��o"#"O preenchimento do c�digo da vis�o � obrigat�rio quando a pergunta Avaliadores for preenchida como Vis�o."
		lValid := .f.
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//����������������������������������������������������������������
If lValid .and. nOpca == 1
	If nTipo == 1
			APD030Processa(STR0001)//"Gera��o Autom�tica do Plano de Desenvolvimento Pessoal"
		ElseIf nTipo == 2
			APD030Processa(STR0002)//"Gera��o Autom�tica do Plano de Desenvolvimento Pessoal"
	Endif
EndIf

dbSelectArea("RD0")	//Pessoas/Participantes
dbSelectArea(1)

dbSelectArea("RDI")	//Tipos de Objetivos
dbSetOrder(1)

dbSelectArea("RDU")	//Periodos de Metas/Objetivos
dbSetOrder(1)

dbSelectArea("RDV")	//Cabecalho do Plano de Metas/PDP
dbSetOrder(1)

dbSelectArea("RDE")	//Itens Participantes x Vis�es  
dbSetOrder(3)

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �APDM031   � Autor � Eduardo Ju            � Data � 04.10.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Geracao Automatica do Plano de Desenvolvimento Pessoal     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � APDM030(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAAPD                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function APDM031( cAlias , nReg , nOpc )
Return( APDM030( cAlias , nReg , nOpc , NIL ,  1 ) )

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �APDM032   � Autor � Eduardo Ju            � Data � 04.10.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Geracao Automatica do Plano de Metas                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � APDM030(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAAPD                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function APDM032( cAlias , nReg , nOpc )
Return( APDM030( cAlias , nReg , nOpc , NIL ,  2 ) )

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �APD030Proc� Autor � Eduardo Ju            � Data � 29.09.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processamento da Geracao Automatica                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � APDM030(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAAPD                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function APD030Processa(cTitulo)

	Local cCodAdo		:= ""
	Local cTipObj		:= ""
	Local cPeriodo		:= ""
	Local cCriterio		:= ""
	Local cCodVis		:= ""
	Local aRD0Crit		:={}
	Local aRD0Aux		:={}
	Local aLogCriterio 	:={}
	Local cRdtDescDet	:=""
	Local lSave			:=.T.
	Local lContinua		:= .T.
	Local nX
	Local cMsgRet		:= ""
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
	Local aFldRel		:= Iif( aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RD0_NOME"} ), {} )
	Local lOfusca		:= Len(aFldRel) > 0

	//��������������������������������������������������������������Ŀ
	//� Carregando as Perguntas 									 �
	//����������������������������������������������������������������
	cTipObj		:= mv_par01	//Codigo do Tipo de Objetivo a ser gerado aos Participantes
	cPeriodo	:= mv_par02	//Codigo do Periodo
	cCriterio	:= mv_par03	//Filtro por Criterio



	If mv_par04 == 1
		cMsgRet:= STR0031 //"N�O ENCONTRADO O SUPERIOR NA VIS�O"
	Elseif mv_par04 == 2
		cMsgRet:= STR0032 //"N�O ENCONTRADO O RESPONS�VEL DO DEPARTAMENTO"
	Else
		cMsgRet:= STR0033 //"N�O ENCONTRADO O MENTOR NO CADASTRO DESTE PARTICIPANTE"
	EndIf
	dbSelectArea("RDI")	//Tipo de Objetivos
	dbSelectArea(1)

	If RDI-> ( dbSeek(xFilial("RDI")+mv_par01) )
		cCodVis:=RDI->RDI_VISAO
	EndIf
	//���������������������������������������������������������������Ŀ
	//� Avaliar todos os participantes(RD0)                           �
	//�����������������������������������������������������������������
	dbSelectArea("RD0")
	dbSetorder(1)
	RD0->( dbGotop() )

	//���������������������������������������������������������������Ŀ
	//� Criterio                                                      �
	//�����������������������������������������������������������������
	Proc2BarGauge(;
		{ || aRD0Crit:=aClone(APDParCrit(cCriterio, cCodVis,@cRdtDescDet)) },;		//Acao a ser Executada
	STR0017,; //"Selecionando os registros"  									//Titulo do Dialogo
	NIL,;									   									//Mensagem para a 1a. BarGauge
	NIL,;
		.T.,;
		.T.,;
		.T.,;
		.T.;
		)

	// Gera tempor�rias apenas para a Vis�o selecionada se gera��o do PDP for por Vis�o
	If MV_PAR04 == 1
		fCriaTMP()
	EndIf

	For nX:= 1 to Len(aRD0Crit)

		aadd( aRD0Aux, { aRD0Crit[nX,1], aRD0Crit[nX,2], aRD0Crit[nX,3], aRD0Crit[nX,4],;
			aRD0Crit[nX,5], '', '', cMsgRet  } )
		APD030ADO(aRD0Aux[nX])
	Next nX


	aEval(aRD0Aux,{|x|	if ( !Empty(x[6]), x[7]:= Posicione("RD0",1,xFilial("RD0")+x[6],"RD0_NOME"), x[7]:= '' ),7,1})

	aRD0Crit := {}
	For nX := 1 to len(aRD0Aux)
		If aRD0Aux[nX,6] <> '__ULTIMO__'
			aadd(aRD0Crit,aRD0Aux[nX])
		EndIf
	Next nX

	If !Empty(aRD0Crit).and.(ascan(aRD0Crit,{|X|!Empty(x[2])})<>0)
		aAdd( aLogCriterio , STR0034)// "Filial   Participante Nome                           Nome do Avaliador              Observa��es"
		aAdd( aLogCriterio ,            "-------- ------------ ------------------------------ ------------------------------ -----------------------------------------------------------" )

		RD0->(dbsetorder(1))

		For nX :=1 to Len(aRD0Crit)
			If Empty(aRD0Crit[nX,2])
				Loop
			Endif
			//Posiciona no registro do Avaliador
			If RD0->( dbseek(xFilial("RD0")+aRD0Crit[nX,6]) )
				cNomeDor := If( lOfusca, Replicate('*',30), RD0->RD0_NOME )
			Else
				cNomeDor := ""
			EndIf

			//Posiciona no registro do Avaliado
			RD0->( dbgoto(aRD0Crit[nX,4]) )

			/*/
			��������������������������������������������������������������Ŀ
			�Obtem as Informacoes do RD0            					   �
			����������������������������������������������������������������/*/
			If Empty(aRD0Crit[nX,6])
				aAdd( aLogCriterio , PADR(RD0->RD0_FILIAL,8)+" "+PADR(RD0->RD0_CODIGO,12)+" "+If(lOfusca, Replicate('*',30), PADR(RD0->RD0_NOME,30))+" "+PADR(cNomeDOR,30)+" "+aRD0Crit[nX,8] )
				lContinua	:= .F.
			Else
				aAdd( aLogCriterio , PADR(RD0->RD0_FILIAL,8)+" "+PADR(RD0->RD0_CODIGO,12)+" "+If(lOfusca, Replicate('*',30), PADR(RD0->RD0_NOME,30))+" "+PADR(cNomeDOR,30) )
			EndIf


		Next nX

		if !lContinua
			Aviso( OemToAnsi(STR0028), OemToAnsi(STR0027), { "OK" } )
		Endif

		MsAguarde( { || fMakeLog( { aLogCriterio } , { STR0020 + cRdtDescDet} , NIL , .T. , FunName() , NIL , "G" , "L" , NIL , .F. ) } , STR0020 )    //"Registros selecionados pelo Criterio "

		If lContinua .And. MsgYesNo(STR0021 )//"Confirma grava�ao para os participantes"
			//���������������������������������������������������������������Ŀ
			//� Gravacao dos PDP para os participantes selecionado			  �
			//�����������������������������������������������������������������
			Proc2BarGauge(;
				{ || APD030Save(aRD0Crit,cTipObj,cPeriodo) },;		//Acao a ser Executada
			STR0022,;//"Gravando os registros"	//Titulo do Dialogo
			NIL,;												//Mensagem para a 1a. BarGauge
			NIL,;
				.T.,;
				.T.,;
				.T.,;
				.T.;
				)
		EndIf
	Else
		MsgInfo(STR0023)//"Nenhum registro encontrado"
	EndIf
	MsgInfo(OemToAnsi(STR0008))		//Fim do Processamento

	// Fecha tabelas tempor�rias
	(cAliasRDE)->(dbCloseArea())
	(cAliasRD4)->(dbCloseArea())
	(cAliasTMP1)->(dbCloseArea())
	(cAliasTMP2)->(dbCloseArea())
	If oTabRDE <> Nil
		oTabRDE:Delete()
		oTabRDE := Nil
	EndIf
	If oTabRD4 <> Nil
		oTabRD4:Delete()
		oTabRD4 := Nil
	EndIf

Return Nil



/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �APD030Save� Autor � Microsiga             � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao do Plano 				                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � APD030Save(void)                                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAAPD                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function APD030Save(aRD0Crit,cTipObj,cPeriodo)
	Local nX
	Local cCodAdo
	Local cCodDor
	Local cTipoIni 	:= AllTrim( SuperGetMV( "MV_APDCPDP", .F., "1") )
	Local cCodAval	:= ""
	Local lSave		:=.T.

	For nX :=1 to Len(aRD0Crit)
		If Empty(aRD0Crit[nX,2])
			Loop
		Endif
		RD0->( dbgoto(aRD0Crit[nX,4]) )

		cCodAdo	:=	aRD0Crit[nX,2] 	//Codigo do Participante/Avaliado
		cCodDor :=  aRD0Crit[nX,6] 	//Codigo do Avaliador

		//���������������������������������������������������������������Ŀ
		//� Verifica se o Participante ja esta com Plano cadastrado       �
		//�����������������������������������������������������������������
		dbSelectArea("RDV")
		dbSetorder(1)
		lSave:=.T.
		If dbSeek(xFilial("RDV")+cCodado+cTipObj+cCodDor)
			While xFilial("RDV")+cCodado+cTipObj+cCodDor == RDV->RDV_FILIAL+RDV->RDV_CODPAR+RDV->RDV_CODOBJ+RDV->RDV_CODDOR
				If RDV_CODPER = cPeriodo
					lSave:=.F.
				EndIf
				RDV->(dbSkip())
			End
		EndIf
		If lSave
			RecLock("RDV",.T.)
			Replace RDV_FILIAL With xFilial("RDV")
			Replace RDV_CODPAR With cCodAdo
			Replace RDV_CODDOR With cCodDor
			Replace RDV_CODOBJ With cTipObj
			Replace RDV_CODPER With cPeriodo
			Replace RDV_STATUS With cTipoIni
			RDV->(MsUnlock())
		EndIf
	Next nX
Return Nil


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RdiSxbFilt� Autor � Eduardo Ju            � Data � 05.10.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Filtro da Consulta Padrao Tipos de Objetivos               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � APDM030(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAAPD                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function RdiSxbFilter()

Local cRet	:= "@#.T.@#"

If funname() == "APDM031"	// Plano de Desenvolvimento Pessoal
	cRet	:= "@#"
	cRet	+= "RDI->RDI_TIPO = '1'"
	cRet	+= "@#"
ElseIf funname() == "APDM032"	//Plano de Metas
	cRet	:= "@#"
	cRet	+= "RDI->RDI_TIPO = '2'"
	cRet	+= "@#"
EndIf

Return (cRet)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �APDM3001	� Autor � Eduardo Ju            � Data � 05.10.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do Tipo de Objetivo informado SX1                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � APDM030(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SX1 - 'APDM30' - Ordem 01 - 'Tipo de Objetivo'             ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
//Function APDM30Sx101Vld()	//Nomenclatura da Funcao: GrupoSX1OrdemVld()
Function APDM3001()

Local lValid	:=	.T.
Local aSaveArea := GetArea()

dbSelectArea("RDI")	//Tipo de Objetivos
dbSelectArea(1)

If !RDI-> ( dbSeek(xFilial("RDI")+mv_par01) )
	Aviso( OemToAnsi(STR0009), OemToAnsi(STR0010), { "OK" } )//"Aten��o"#"Tipo do Objetivo n�o cadastrado."
	lValid	:= .F.
Else
	If funname() == "APDM031" .And. RDI->RDI_TIPO == "2"	// Plano de Desenvolvimento Pessoal
		Aviso( OemToAnsi(STR0009), OemToAnsi(STR0011) + " " + OemToAnsi(STR0012), { "OK" } )	//"Aten��o"#"Tipo Objetivo Inv�lido. Informe somente Tipo de Objetivo"#"'Plano'"
		lValid	:=	.F.
	ElseIf funname() == "APDM032" .And. RDI->RDI_TIPO == "1" 	//Plano de Metas
		Aviso( OemToAnsi(STR0009), OemToAnsi(STR0011) + " " + OemToAnsi(STR0013), { "OK" } )	//"Aten��o"#"Tipo Objetivo Inv�lido. Informe somente Tipo de Objetivo"#"'Meta'"
		lValid	:=	.F.
	EndIf
EndIF

RestArea(aSaveArea)

Return lValid


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � APDM3002 � Autor � Emerson Grassi Rocha  � Data � 14/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do Periodo informado SX1                 		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � APDM030(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SX1 - 'APDM30' - Ordem 01 - 'Tipo de Objetivo'             ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function APDM3002()	//Nomenclatura da Funcao: GrupoSX1+Ordem()

Local lValid := .T.
Local aSaveArea := GetArea()

dbSelectArea("RDU")  	//Periodos
dbSelectArea(1)

If !RDU-> ( dbSeek(xFilial("RDU")+mv_par02) )

	Aviso( OemToAnsi(STR0009), OemToAnsi(STR0015), { "OK" } )	//"Aten��o"#"Periodo n�o cadastrado."
	lValid	:= .F.
Else
	If ( funname() == "APDM031" .And. RDU->RDU_TIPO != "2" .Or.;	//Plano de Desenvolvimento Pessoal
		funname() == "APDM032" .And. RDU->RDU_TIPO != "3" ) 		//Plano de Metas

		Aviso( OemToAnsi(STR0009), OemToAnsi(STR0016), { "OK" } )	//"Aten��o"#"Periodo n�o pertence ao Tipo de Objetivo selecionado."
		lValid	:=	.F.
	EndIf
EndIF

RestArea(aSaveArea)
Return( lValid )

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � APD030ADO � Autor � Eduardo Ferreira  � Data � 01/06/16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Busca do Superior do Avaliado	                		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � APDM030(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � APD030ADO = aRD0Crit							              ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function APD030ADO(aRegAval)

	Local cMsgErro	:= ""
	Local cResp		:= "((cAliasTMP1)->RDE_RESP == '1')" //1-Sim
	Local aArea		:= GetArea()
	Local nX		:= 0
	Local aRet		:= {}
	Local aCodAval	:= {}
	Local aRdeCodRd0:= {}
	Local cSeek		:= ''

	aRegAval[7]	:= STRTRAN(aRegAval[7], '%avaliador%', 'aRegAval[6]')

	Do Case
	Case MV_PAR04 == 1
		(cAliasTMP1)->(dbSetOrder(1))  //RDE_FILIAL+RDE_CODPAR+RDE_CODVIS+RDE_ITEVIS
		cSeek := xFilial("RDE")+aRegAval[2]+mv_par05 
		If (cAliasTMP1)->(MsSeek(cSeek))
			While (cAliasTMP1)->(!eof()) .and. (cAliasTMP1)->(RDE_FILIAL+RDE_CODPAR+RDE_CODVIS) == cSeek
				aRegAval[6] := ApdaDorNivel( (cAliasTMP1)->RDE_ITEVIS, xFilial("RDE"), MV_PAR05 , "2", 1 ,aRdeCodRd0,,cResp, cAliasTMP1 , cAliasTMP2)
				If aRegAval[6]=="__NoExistItem__"
					aRegAval[6]:= ""
					RD4->(dbsetorder(1))
					If RD4->(MsSeek(xFilial("RD4")+MV_PAR05+(cAliasTMP1)->RDE_ITEVIS)) .and. RD4->RD4_TREE == '000000'
						aRegAval[6]:= "__ULTIMO__"
					EndIf
				EndIf
				Exit
				(cAliasTMP1)->(dbskip())
			EndDo
		Else
			aRegAval[6]:= ""
		EndIf
	Case mv_par04 == 2
		If 	Participant(aRegAval[2], aRet)
			If Len(aRet) == 10
				dbSelectArea("SQB")
				SQB->(DbSetOrder(1))//QB_FILIAL+QB_DEPTO
				dbSelectArea("RDZ")
				RDZ->(DbSetOrder(1))//RDZ_FILIAL+RDZ_EMPENT+RDZ_FILENT+RDZ_ENTIDA+RDZ_CODENT+RDZ_CODRD0
				If SQB->(dbSeek(xFilial("SQB")+aRet[8]))
					If RDZ->(DbSeek(xFilial("RDZ")+ cEmpAnt+SQB->QB_FILRESP+'SRA'+SQB->QB_FILRESP+SQB->QB_MATRESP))
						aRegAval[6]	:=	RDZ->RDZ_CODRD0
					EndIf
				EndIf
			Else
				aRegAval[8]	:= STR0029 + aRegAval[2] + STR0030 //"Participante:'"#"' possui duplo vinculo, ou ser� necess�rio buscar apenas os funcion�rios admitidos."
			EndIf
		EndIf
	OTHERWISE
		aRegAval[6]:= aRegAval[5]
	EndCase

	RestArea(aArea)

Return


/*/{Protheus.doc} fCriaTMP()
Fun��o que cria tabelas tempor�rias para tabelas RDE/RD4 com a Vis�o selecionada nas configura��es
@type function
@author raquel.andrade
@since 31/05/2021
@version 1.0
/*/
Static Function fCriaTMP()
Local aCposRDE		:= {}	
Local aCposRD4		:= {}	

	// Cria tabela tempor�ria RDE com C�d. Vis�o do pergunte e status ativo
		
	aAdd(aCposRDE, { "RDE_FILIAL"	,"C", FwSizeFilial()		 		, 0 })
	aAdd(aCposRDE, { "RDE_CODPAR"	,"C", TamSX3("RDE_CODPAR")[1]	 	, 0 })
	aAdd(aCposRDE, { "RDE_CODVIS"	,"C", TamSX3("RDE_CODVIS")[1]	 	, 0 })
	aAdd(aCposRDE, { "RDE_ITEVIS"	,"C", TamSX3("RDE_ITEVIS")[1]	 	, 0 })
	aAdd(aCposRDE, { "RDE_DATA"		,"C", TamSX3("RDE_DATA")[1]	 		, 0 })
	aAdd(aCposRDE, { "RDE_STATUS"	,"C", TamSX3("RDE_STATUS")[1]	 	, 0 })
	aAdd(aCposRDE, { "RDE_RESP"		,"C", TamSX3("RDE_RESP")[1]			, 0 })

	oTabRDE := FWTemporaryTable():New(cAliasTMP1, aCposRDE)
	oTabRDE:AddIndex("01", {'RDE_FILIAL', 'RDE_CODPAR', 'RDE_CODVIS', 'RDE_ITEVIS'})
	oTabRDE:AddIndex("02", {'RDE_FILIAL', 'RDE_CODVIS', 'RDE_ITEVIS', 'RDE_STATUS', 'RDE_CODPAR'})
	oTabRDE:Create()

	BeginSql alias cAliasRDE
		SELECT 		*
		FROM 		%table:RDE% RDE
		WHERE   RDE.RDE_FILIAL = %exp:xFilial("RDE")%  AND
				RDE.RDE_CODVIS = %exp:MV_PAR05%  AND
				RDE.RDE_STATUS = '1' AND
				RDE.%NotDel%
		ORDER BY RDE.RDE_FILIAL, RDE.RDE_CODPAR,RDE.RDE_CODVIS,RDE.RDE_ITEVIS
	EndSql

	dbSelectArea(cAliasRDE)
	(cAliasRDE)->( dbGoTop() )
	While !(cAliasRDE)->( Eof() )
		RecLock( (cAliasTMP1), .T. )
			(cAliasTMP1)->RDE_FILIAL := (cAliasRDE)->RDE_FILIAL
			(cAliasTMP1)->RDE_CODPAR := (cAliasRDE)->RDE_CODPAR
			(cAliasTMP1)->RDE_CODVIS := (cAliasRDE)->RDE_CODVIS
			(cAliasTMP1)->RDE_ITEVIS := (cAliasRDE)->RDE_ITEVIS
			(cAliasTMP1)->RDE_DATA 	:= (cAliasRDE)->RDE_DATA
			(cAliasTMP1)->RDE_STATUS := (cAliasRDE)->RDE_STATUS
			(cAliasTMP1)->RDE_RESP 	:= (cAliasRDE)->RDE_RESP
		MsUnLock()
		(cAliasRDE)->(dbSkip())
	EndDo

	// Cria tabela tempor�ria RD4 com C�d. Vis�o do pergunte 
	aAdd(aCposRD4, { "RD4_FILIAL"	,"C", FwSizeFilial()		 		, 0 })
	aAdd(aCposRD4, { "RD4_CODIGO"	,"C", TamSX3("RD4_CODIGO")[1]	 	, 0 })
	aAdd(aCposRD4, { "RD4_ITEM"		,"C", TamSX3("RD4_ITEM")[1]	 		, 0 })
	aAdd(aCposRD4, { "RD4_EMPIDE"	,"C", TamSX3("RD4_EMPIDE")[1]	 	, 0 })
	aAdd(aCposRD4, { "RD4_FILIDE"	,"C", TamSX3("RD4_FILIDE")[1]	 	, 0 })
	aAdd(aCposRD4, { "RD4_CODIDE"	,"C", TamSX3("RD4_CODIDE")[1]	 	, 0 })
	aAdd(aCposRD4, { "RD4_DESC"		,"C", TamSX3("RD4_DESC")[1]			, 0 })
	aAdd(aCposRD4, { "RD4_TREE"		,"C", TamSX3("RD4_TREE")[1]			, 0 })
	aAdd(aCposRD4, { "RD4_CHAVE"	,"C", TamSX3("RD4_CHAVE ")[1]		, 0 })
	aAdd(aCposRD4, { "RD4_DATA"		,"C", TamSX3("RD4_DATA  ")[1]		, 0 })
	aAdd(aCposRD4, { "RD4_STATUS"	,"C", TamSX3("RD4_STATUS")[1]		, 0 })

	oTabRDE := FWTemporaryTable():New(cAliasTMP2, aCposRD4)
	oTabRDE:AddIndex("01", {'RD4_FILIAL', 'RD4_CODIGO', 'RD4_ITEM', 'RD4_TREE'})
	oTabRDE:AddIndex("02", {'RD4_FILIAL', 'RD4_CODIGO', 'RD4_TREE', 'RD4_ITEM'})
	oTabRDE:Create()

	BeginSql alias cAliasRD4
		SELECT 		*
		FROM 		%table:RD4% RD4
		WHERE   RD4.RD4_FILIAL = %exp:xFilial("RD4")%  AND
				RD4.RD4_CODIGO = %exp:MV_PAR05% AND
				RD4.%NotDel%
		ORDER BY RD4.RD4_FILIAL, RD4.RD4_CODIGO,RD4.RD4_ITEM,RD4.RD4_TREE
	EndSql

	dbSelectArea(cAliasRD4)
	(cAliasRD4)->( dbGoTop() )
	While !(cAliasRD4)->( Eof() )
		RecLock( (cAliasTMP2), .T. )
			(cAliasTMP2)->RD4_FILIAL 	:= (cAliasRD4)->RD4_FILIAL
			(cAliasTMP2)->RD4_CODIGO 	:= (cAliasRD4)->RD4_CODIGO 
			(cAliasTMP2)->RD4_ITEM 		:= (cAliasRD4)->RD4_ITEM 
			(cAliasTMP2)->RD4_EMPIDE 	:= (cAliasRD4)->RD4_EMPIDE 
			(cAliasTMP2)->RD4_FILIDE 	:= (cAliasRD4)->RD4_FILIDE
			(cAliasTMP2)->RD4_CODIDE 	:= (cAliasRD4)->RD4_CODIDE 
			(cAliasTMP2)->RD4_DESC		:= (cAliasRD4)->RD4_DESC
			(cAliasTMP2)->RD4_TREE		:= (cAliasRD4)->RD4_TREE
			(cAliasTMP2)->RD4_CHAVE		:= (cAliasRD4)->RD4_CHAVE
			(cAliasTMP2)->RD4_DATA		:= (cAliasRD4)->RD4_DATA
			(cAliasTMP2)->RD4_STATUS	:= (cAliasRD4)->RD4_STATUS
		MsUnLock()
		(cAliasRD4)->(dbSkip())
	EndDo


Return
