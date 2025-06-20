#INCLUDE "CTBSFUN.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "ECD.CH"
#Include "FWLIBVERSION.CH"

//Compatibiliza��o de fontes 30/05/2018

Static __lDefTop	:= IfDefTopCTB()
Static __lUnicRef := Nil // cache de verifica��o de registro unico na cvd. -- Ver Func. VerUnicRef()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBSFUN   �Autor  �Microsiga           � Data �  03/01/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function GetEmpMarcadas( aEmp )
Local aArea		:= GetArea()
Local lRet		:= .T.

Local lFim    	:= .F.
Local lAdmin  	:= .F.
Local oOk 		:= LoadBitmap( GetResources(), "LBOK")
Local oNo		:= LoadBitmap( GetResources(), "LBNO")
Local oEmp 		:= Nil    
Local nOpcRot	:= 0

Local lFWCodFil   	:= FindFunction( "FWCodFil" )
Local lGestao		:= Iif( lFWCodFil, ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() ), .F. )	// Indica se usa Gestao Corporativa

Private oWzrdEmp
Default aEmp	:= {}

aEmp := GetEmpEcd(,.T.)

IF Len( aEmp ) <= 0
	MsgAlert( STR0001 ) //"Nenhuma empresa encontrada no sigamat.emp"
	lRet := .F.
Else
	//�������������������������������������Ŀ
	//�Monta o aheader do ListBox de empresa�
	//���������������������������������������
	aHeader := ARRAY(NUM_COL_EMP)
	
	aHeader[1]	:= ""  		
	aHeader[2] 	:= "Cod Empresa" 
	aHeader[3] 	:= STR0003	//"Raz�o Social"
	aHeader[4]	:= ""	//"CNPJ"
	aHeader[5]	:= ""
	
	//������������������������������������������������������������������������Ŀ
	//� Montagem da Interface                                                  �
	//��������������������������������������������������������������������������
	DEFINE WIZARD oWzrdEmp ;
		TITLE STR0011;//Central de Escritura��o		
		HEADER STR0011;//Central de Escritura��o		
		MESSAGE "";
		TEXT STR0005 + CRLF + CRLF + STR0006 ; //"Esse assistente ir� lhe ajudar na escolha das empresas a serem exibidas na central de escritura��o."###"Clique em avan�ar para iniciarmos a sele��o de suas empresas."
		NEXT {|| .T.} ;
		FINISH {||.T.}
	       
	CREATE PANEL oWzrdEmp  ;
		HEADER STR0007; //"Escolha a Empresa para exibi��o na central de escritura��o."
		MESSAGE ""	;
		BACK {|| .T.} ;
		FINISH {|| ValidaEmpEcd( aEmp , @nOpcRot ) } ;
		PANEL
		
		oEmp := TWBrowse():New( 0.7, 0.7, 290, 130,Nil,aHeader, Nil, oWzrdEmp:GetPanel(2), Nil, Nil, Nil,Nil,;
						      {|| aEmp := EmpTrocEcd( oEmp:nAt, aEmp, .T. ), oEmp:Refresh() })      

		oEmp:SetArray( aEmp )
		
		oEmp:bLine := {|| {;
						If( aEmp[oEmp:nAt,EMP_SELECAO] , oOk , oNo ),;
							aEmp[oEmp:nAt,EMP_CODIGO],;
							aEmp[oEmp:nAt,EMP_GRUPO],;
							aEmp[oEmp:nAt,EMP_CGC];
						}}
							
	ACTIVATE WIZARD oWzrdEmp CENTERED
Endif

RestArea( aArea )
lRet := nOpcRot == 1

Return lRet

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 �GetEmpEcd  � Autor � Elton C. / Renato     � Data � 01.02.10 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno	 � Array com as Empresas do SigaMat                            ���
��������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
���Observacao� Copiada a fun��o do GetEmp ref. ao ajuste das empresas      ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function GetEmpEcd( cEmp, lMarcado )
Local aArea		:= GetArea()
Local aEmp		:= {}		// Matriz com todas as empresas do Sistema
Local nReg		:= SM0->(Recno())
Local cEmpAnt1	:= ''
Local cEmpOld
Local cFilOld
Local bCond := {||.T.}
Local lFWCodFil   	:= FindFunction( "FWCodFil" )
Local lGestao		:= Iif( lFWCodFil, ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() ), .F. )	// Indica se usa Gestao Corporativa
Local cAlias		:= "CT2"
Default lMarcado	:= .F.
Default cEmp := ""

dbSelectArea( "SM0" )
DbSetorder(1)
dbGoTop()

If !Empty( cEmp )
	bCond := {|| SM0->M0_CODIGO == cEmp }
	MsSeek( cEmp )
Endif

While SM0->( !Eof() ) .And. Eval( bCond )
	
	cEmpOld := SM0->M0_CODIGO
	cFilOld := SM0->M0_CODFIL
	
	If cEmpAnt1 <> cEmpOld				//Se a empresa for diferente, are o SX2.
		EmpOpenEcd( cEmpOld ) 
	EndIf
	
	If !Empty(cEmp) .Or. (SM0->M0_CODIGO == cEmpAnt)//(( Ascan( aEmp, {|x| x[2] = SM0->M0_CODIGO } ) <= 0 ) .And. (( Ascan( aEmp, {|x| x[3] = SM0->M0_CODFIL } ) <= 0 )))
		// Isto garante que a empresa seja aberta somente uma vez!!
		dbSelectArea("SX2TMP")
		If MsSeek("CT2") 
	   		If lGestao   

				cModo	:= FWModeAccess(cAlias,1,cEmpOld) + FWModeAccess(cAlias,2,cEmpOld) + FWModeAccess(cAlias,3,cEmpOld)
				cModo   := IIF(  "E" $cModo , "E" , "C" )   
			Else
				cModo	:= FWModeAccess(cAlias,3,cEmpOld)
			EndIf
		EndIf
	
		aAdd(aEmp ,Array(NUM_COL_EMP) )    
		aEmp[Len(aEmp)][EMP_SELECAO] 	:= lMarcado
		aEmp[Len(aEmp)][EMP_CODIGO] 	:= SM0->M0_CODIGO
		aEmp[Len(aEmp)][EMP_FILIAL] 	:= iif( Empty( cEmp ) , '' , SM0->M0_CODFIL )
		aEmp[Len(aEmp)][EMP_DESCRIC] 	:=  IIF(FwLibVersion() >= "20211004", SubStr( FWSM0Util():getSM0FullName(SM0->M0_CODIGO,SM0->M0_CODFIL), 1, 170 ), SM0->M0_NOMECOM )
		aEmp[Len(aEmp)][EMP_CGC]     	:= iif( Empty( cEmp ) , '' , SM0->M0_CGC )
		aEmp[Len(aEmp)][EMP_MODO_CT2] 	:= cModo   
		aEmp[Len(aEmp)][EMP_GRUPO]      := SM0->M0_NOME

		If Empty( cEmp )
			EXIT		
		Endif
	Endif
		
	dbSelectArea("SM0")
	cEmpAnt1 := cEmpOld
	dbSkip()
EndDo

IF Len( aEmp ) <= 0
	Help("GetEmpEcd",1,"HELP",STR0008,STR0009,1,0)  //"Nao h� filiais para essa empresa"###"Verifique o arquivo de empresas"
	Return
Endif

dbSelectArea( "SM0" )
dbGoto( nReg )

RestArea( aArea )

Return aEmp       

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    � ValidaEmpEcd � Autor  � Elton C./ Renato    � Data 01.02.10��� 
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Confirma processamento                                     ���
��������������������������������������������������������������������������Ĵ��
���Retorno    � Nenhum                                                     ���
��������������������������������������������������������������������������Ĵ��
���  Uso      � SigaCTB                                                    ���
��������������������������������������������������������������������������Ĵ��
��� Par�metros� ExpA1 = Array   contendo as empresas                       ���
���           � ExpA2 = Array contendo as empresas a serem consolidadas    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function ValidaEmpEcd( aEmp ,nOpcRot,aTipoEscrit,cMatriz)
Local aArea    	:= GetArea()
Local nCont		:= 0
Local lEmpresa	:= .F.
Local lRet 		:= .T.
Local nEmpSel   := 0 
Local nAuxFil   := 0
Local nFilCont  := 0
Local lFilEmp   := SuperGetMv("MV_FILTEMP", .F., .F.)

Default aTipoEscrit := {} 
Default cMatriz	  := ""

nOpcRot  := 1

For nCont := 1 to Len( aEmp )
	IF aEmp[nCont][EMP_SELECAO]
		nEmpSel++
		lEmpresa := .T.
	Endif
Next

// Nao selecionou nenhuma empresa
If !lEmpresa
	HELP (" ",1,"C210S/EMP")
	lRet 	 := .F.
	nOpcRot  := 0
Endif


If !Empty(aTipoEscrit) .And. lRet
	If aTipoEscrit[1] == 2 .And. nEmpSel > 1 // Sem Centraliza��o  	
		If !ValidaMatriz(cMatriz, aEmp)                                      
			lRet 	 := .F.
			nOpcRot  := 0                                                          
		EndIf
	ElseIf aTipoEscrit[1] == 1 .And. nEmpSel > 1 // Com Centraliza��o 
		MsgAlert(STR0013+CRLF+CRLF+STR0014)//"Tipo de Escritura��o centralizada."###"-Selecione apenas uma filial"
		For nAuxFil := 1 to Len( aEmp )
			IF nAuxFil > 1 .And. aEmp[nAuxFil][EMP_SELECAO] == .T.
				aEmp[nAuxFil][EMP_SELECAO] := .F.		
			Endif
		Next
		lRet 	 := .F.
		nOpcRot  := 0
	EndIf
EndIf

If lRet .And. lFilEmp .And. !Empty(aTipoEscrit)
	If aTipoEscrit[1] == 1 
		For nFilCont := 1 to Len( aEmp )
			If cFilAnt != Alltrim(aEmp[nFilCont][EMP_FILIAL]) .And. aEmp[nFilCont][EMP_SELECAO] == .T.
				MsgAlert(STR0019+CRLF+CRLF+STR0020)	
				lRet := .F.
				aEmp[nFilCont][EMP_SELECAO] := .F.
				Exit
			Endif
		Next
	ElseIf aTipoEscrit[1] == 2 
		For nFilCont := 1 to Len( aEmp )
			If cFilAnt != cMatriz .And. aEmp[nFilCont][EMP_SELECAO] == .T.
				MsgAlert( STR0019 +CRLF+CRLF+ STR0021 )
				lRet := .F.
				aEmp[nFilCont][EMP_SELECAO] := .F.
				Exit	
			Endif
		Next
	EndIf
EndIf

RestArea( aArea )

Return lRet



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidaMatriz �Autor  �Microsiga			� Data �03/02/10  ���
�������������������������������������������������������������������������͹��
���Desc.     �Efetua a valida��o da Matriz, se a escritura��o for         ���
���          �centralizada                                                ���
�������������������������������������������������������������������������͹��
���Uso       � 			                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ValidaMatriz(cMatriz, aEmp)

Local lRet		:= .F.
Local nX		:= 0
//Local nCont		:= 0

Default cMatriz	:= ""				
Default aEmp	:= {}

For nX := 1 to Len(aEmp)
	If aEmp[nX][1]
		If aEmp[nX][1] .And. Alltrim(aEmp[nX][3]) == Alltrim(cMatriz)
			lRet := .T.
		EndIf
	EndIf 
Next nX

If Empty(cMatriz)
	MsgAlert(STR0015 +CRLF+CRLF+ STR0016)//"Tipo de Escritura��o descentralizada."###"-Informe a matriz a ser escriturada"
ElseIf !lRet
	MsgAlert(STR0017)//"Matriz informada n�o existe."
EndIf

Return lRet

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    � EmpTrocEcd  � Autor  � Elton C. / Renato	� Data 01.02.10���
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Troca marcador entre x e branco                            ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    � EmpTrocEcd(nIt,aArray)                                     ���
��������������������������������������������������������������������������Ĵ��
���Retorno    � aArray                                                     ���
��������������������������������������������������������������������������Ĵ��
���  Uso      � SigaCTB                                                    ���
��������������������������������������������������������������������������Ĵ��
��� Par�metros� ExpN1 = Numero da posicao                                  ���
���           � ExpA1 = Array contendo as empresas a serem consolidadas    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function EmpTrocEcd(nIt,aArray,lEmp,cModEsc,lMostraMsg)

Local aArea    		:= GetArea()
Local nCont			:= 1
Local cEmpAtu		:= ""
Local cFilAtu		:= ""
Local cModo			:= ""
Local cMensagem		:= STR0010 //"A tabela de lan�amentos est� compartilhada, nesse caso, escriture centralizado"
Local lFWCodFil   	:= FindFunction( "FWCodFil" )
Local lGestao		:= Iif( lFWCodFil, ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() ), .F. )	// Indica se usa Gestao Corporativa
Local aFilEmp		:= {}
Local nPosFil		:= 0
Local nAuxFil		:= 1
Local nTipEsc       := 0
Local lRtMstrMsg 	:= .F.

Default lEmp 		:= .F.
Default cModEsc     := "ECD"
Default lMostraMsg 	:= .T.

If Type("aResEsc") == "U"
	aResEsc := {}
	aadd( aResEsc, 1)
EndIf
If Type("aResWiz2") == "U"
	aResWiz2 := {}
	aadd( aResWiz2, 1)
EndIf

If lEmp
	cEmpAtu	:= aArray[nIt][EMP_CODIGO]
	cFilAtu	:= aArray[nIt][EMP_FILIAL]	
	cModo	:= aArray[nIt][EMP_MODO_CT2]
	
	// Se o CT2 for compartilhado, verificar se esta marcando mais de uma filial
	If cModo == "C"
		For nCont := 1 to Len(aArray)
			If nCont <> nIt //Nao verificar o que esta sendo marcado/desmarcado
				If aArray[nCont][EMP_SELECAO] .And. cEmpAtu == aArray[nCont][EMP_CODIGO] .And. cFilAtu <> aArray[nCont][EMP_FILIAL]
					If !IsBlind()
						If lMostraMsg
							MsgAlert( cMensagem )
						Else
							lRtMstrMsg := .T.
						EndIf
					EndIf
					
					Return(aArray)
				EndIf
			EndIf
		Next
	ElseIf lGestao // Valida��o para Gestao Corporativa
		For nCont := 1 to Len(aArray)
			If (aArray[nCont][EMP_SELECAO] .Or. nCont == nIt ).And. cEmpAtu == aArray[nCont][EMP_CODIGO] 
				nPosFil := aScan(aFilEmp,{ |x| Alltrim(x) ==  Alltrim(xFilial("CT2",aArray[nCont][EMP_FILIAL])) })
				
				If cModEsc == "ECF" .OR. cModEsc == "LAL"
					nTipEsc := aResWiz2[1]
				Else
					nTipEsc := aResEsc[1]
				EndIf
				
				If nTipEsc == 1 .And. nPosFil > 1 
					For nAuxFil := 1 to Len( aArray )
						IF nAuxFil > 1 .And. aArray[nAuxFil][EMP_SELECAO] == .T.
							aArray[nAuxFil][EMP_SELECAO] := .F.		
						Endif
					Next
					If !IsBlind()
						If lMostraMsg
							MsgAlert( cMensagem )
						Else
							lRtMstrMsg := .T.
						EndIf 
					EndIf
					Return(aArray)
				Else
					aAdd(aFilEmp,Alltrim(xFilial("CT2",aArray[nCont][EMP_FILIAL])))
				EndIF
			EndIf
		Next
	EndIf

	lMostraMsg := lRtMstrMsg
EndIf

aArray[nIt,EMP_SELECAO] := !aArray[nIt,EMP_SELECAO]

RestArea( aArea )
Return aArray

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    � EmpOpenEcd � Autor  � Elton C. / Renato F.  � Data 01.02.10���
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Abre arquivo do SX2                                        ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    � EmpOpenEcd(cEmpresa)                                       ���
��������������������������������������������������������������������������Ĵ��
���Retorno    � Nenhum                                                     ���
��������������������������������������������������������������������������Ĵ��
���  Uso      � SigaCTB                                                    ���
��������������������������������������������������������������������������Ĵ��
��� Par�metros� ExpC1 = Codigo da Empresa                                  ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function EmpOpenEcd( cEmpresa )

Local aArea    := GetArea()
Local cArquivo := "SX2" + cEmpresa + "0"
Local cIndice  := "SX2" + cEmpresa + "01"

If( ! MsFile( Trim( cArquivo ) + GetDBExtension()))
	Final( cArquivo + STR0012 )
EndIf

If Select( "SX2TMP" ) <> 0
	dbSelectArea("SX2TMP")
	dbCloseArea()
EndIf

cArqIx2 := cIndice

OpenSxs(,,,,cEmpresa,"SX2TMP","SX2",,.F.)

If Select("SX2TMP") <= 0
	Final( cArquivo + STR0012 )
EndIf

dbSetOrder(1)

RestArea( aArea )
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GerNextRev�Autor  �Microsiga           � Data �  03/01/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GerNextRev( cCodEmp)
Local aArea 	:= GetArea()
Local cCodTemp	:= StrZero( 1 , TamSx3("CS0_CODREV")[1] )
Local cAlias := ""
Local cQuery := ""

IF __lDefTop
	cAlias := "TMPPRXREV"
	
	cQuery := "SELECT MAX( CS0_CODREV ) CODTEMP" ;
	+ "  FROM " + RetSqlName("CS0") + " CS0 " ;
	+ " WHERE CS0.CS0_CODEMP = '" + cCodEmp + "'" ;
	+ "   AND D_E_L_E_T_ <> '*' "
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAlias)
	
	cCodTemp := AllTrim( (cAlias)->CODTEMP )
	
	DbSelectArea(cAlias)
	(cAlias)->( DbCloseArea())
	
	DbSelectArea( "CS0" )
	
	If StrZero( Val(cCodTemp),6) == "999999"
		cCodTemp := "000000"
	Else
		If Empty(cCodTemp)
			cCodTemp := "000001"
		Else
			cCodTemp := StrZero(Val(cCodTemp)+1,6)
		EndIf
	EndIf
Else
	dbSelectArea( "CS0" )
	dbSetOrder( 2 )
	
	MsSeek( cCodEmp + "999999",.T.)        //// SEEK .T. + DBSkip(-1)
	dbSkip(-1)
	
	If CS0->CS0_CODEMP == cCodEmp .And. CS0->CS0_CODFIL == cCodFil
		nNumRev := Val( CS0->CS0_CODREV )
		
		If nNumRev == 999999
			cCodTemp := "000000"
		Else
			cCodTemp := StrZero( nNumRev + 1 ,6)
		EndIf
	Else
		cCodTemp := "000001"
	EndIf
Endif

RestArea( aArea )

Return cCodTemp

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ECDQuery   �Autor  �Alvaro Camillo Neto � Data �  01/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata a query e abre ou fecha a area de trabalho            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTB ECD                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ECDQuery(cTemp,nOPC,cQuery)
Local aArea := GetArea()
Default cQuery := ""

If Empty(cQuery)
	nOPC := 2
EndIf


If nOpc == 1 // Cria area de trabalho
	cQuery := ChangeQuery(cQuery)

	If Select(cTemp) <> 0
		(cTemp)->(dbCloseArea())
	EndIF
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp)
Else
	If Select(cTemp) > 0
		dbSelectArea(cTemp)
		dbCloseArea()
	EndIf
EndIf

RestArea(aArea)
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ECDGrvTmp � Autor �Alvaro Camillo Neto    � Data �02.03.2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de conversao de Array para arquivo temporario        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Alias do arquivo temporario                          ���
���          �ExpN2: nOperacao 1-Cria/2-Destroi                           ���
���          �ExpA3: Estrutura                                            ���
���          �ExpA4: Array com a seguinte estrutura                       ���
���          �       [1] Registro                                         ���
���          �       [1][n] Campos do arquivo                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function ECDGrvTmp(cAlias,nOper,aStru,aArray)

Local aArea := GetArea()
Local nX    := 0
Local nY    := 0

Static cArquivo
Static _oCTBFUN01

If nOper == 1
	
	_oCTBFUN01 := FWTemporaryTable():New( cAlias )  
	_oCTBFUN01:SetFields(aStru) 
	_oCTBFUN01:AddIndex("1", {aStru[1][1]})	
	
	//------------------
	//Cria��o da tabela temporaria
	//------------------
	_oCTBFUN01:Create() 
	
	dbSelectArea(cAlias)
	dbsetorder(0)
	For nX := 1 To Len(aArray)
		RecLock(cAlias,.T.)
		For nY := 1 To Len(aArray[nX])
			FieldPut(nY,aArray[nX][nY])
		Next nY
		MsUnLock()
	Next nX
Else
	dbSelectArea(cAlias)
	dbCloseArea()
	
	If _oCTBFUN01 <> Nil
		_oCTBFUN01:Delete()
		_oCTBFUN01 := Nil
	Endif

EndIf
RestArea(aArea)
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ECDDateConv� Autor �Alvaro Camillo Neto    � Data �03.03.2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de conversao de data para string em varios formatos  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpC1: String                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpD1: Alias do arquivo temporario                          ���
���          �ExpC2: Formato onde:                                        ���
���          �       DD = Dia                                             ���
���          �       MM = Mes                                             ���
���          �       YYYY ou YY = Ano                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function ECDDateConv(dData,cMasc)

Local cDia    := ""
Local cMes    := ""
Local cAno    := ""
Local cData   := Dtos(dData)
Local cResult := ""
Local cAux    := ""

DEFAULT cMasc := "DDMMYYYY"

cDia := SubStr(cData,7,2)
cMes := SubStr(cData,5,2)
cAno := SubStr(cData,1,4)

While !Empty(cMasc)
	cAux := SubStr(cMasc,1,2)
	Do Case
		Case cAux == "DD"
			cResult += cDia
		Case cAux == "MM"
			cResult += cMes
		Case cAux == "YY"
			If SubStr(cMasc,1,4) == "YYYY"
				cResult += cAno
				cMasc := SubStr(cMasc,3)
			Else
				cResult += SubStr(cAno,3)
			EndIf
	EndCase
	cMasc := SubStr(cMasc,3)
EndDo
Return(cResult)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FsLoadTxt � Autor �Alvaro Camillo Neto    � Data �05.03.2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de leitura de arquivo texto para anexar ao layout    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExC1: Arquivo texto                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Nome do arquivo texto com path                       ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function ECDLoadTXT(cFileTxt)
Local aRet		 := {}
//��������������������Ŀ
//�Abre o arquivo texto�
//����������������������
FT_FUse(cFileTxt)
FT_FGoTop()
While !FT_FEof()
	aAdd(aRet,FT_FReadLn())
	FT_FSkip()
End
FT_FUse()

Return(aRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBSFUN   �Autor  �Microsiga           � Data �  03/23/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ECDGetTxt(nRecno)
Local cRet := ""
Local aArea := GetArea()
Local aAreaCSF := CSF->(GetArea())

CSF->(dbGoTo(nRecno))
If !Empty(CSF->CSF_ARQRTF)
	cRet := Alltrim(StrTran(CSF->CSF_ARQRTF,CRLF,''))
EndIf

RestArea(aAreaCSF)
RestArea(aArea)
Return cRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VerUnicRef�Autor  �Controladoria       � Data �  18/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VerUnicRef( cEntRef, cCodPla ,cVerPla )
Local aArea      := {}
Local cQuery     := ''
Local cAliasTMP  := ''
Local cFilialCVD := ''

Default cEntRef  := ''
Default cCodPla  := ' '
Default cVerPla  := ""

If __lUnicRef == Nil .And. !Empty( cEntRef )
	aArea      := GetArea()
	cFilialCVD := xFilial("CVD")
	
	cQuery := " SELECT count(*) AS QTDE FROM " + RetSqlTab('CVD')
	cQuery += "  WHERE CVD_FILIAL = '" + cFilialCVD + "'"
	cQuery += "    AND CVD_ENTREF = '" + cEntRef + "'" 
	If !Empty(cCodPla)
		cQuery += "    AND CVD_CODPLA = '" + cCodPla + "'" 
		cQuery += "    AND CVD_VERSAO = '" + cVerPla + "'" 
	EndIf
	cQuery += "    AND D_E_L_E_T_= ' '"  
	If Empty(cCodPla)
		cQuery += "  GROUP BY CVD_FILIAL, CVD_CONTA, CVD_ENTREF, CVD_CTAREF"
	Else
		cQuery += "  GROUP BY CVD_FILIAL, CVD_CODPLA,CVD_VERSAO, CVD_CONTA, CVD_ENTREF, CVD_CTAREF"
	Endif
	cQuery += " HAVING Count(*) > 1"
	
	cQuery := ChangeQuery( cQuery )
	
	// gera um novo alias
	cAliasTMP := GetNextAlias()
	
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasTMP )
	
	DbSelectArea(cAliasTMP)
	(cAliasTMP)->(DbGotop())
	
	__lUnicRef := (cAliasTMP)->(Eof())
	
	(cAliasTMP)->( dbCloseArea() )

	RestArea( aArea )
Endif

Return __lUnicRef

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  ECFRetPeri �Autor  �Totvs        	     Data �  02/04/2015   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna Periodo do ECF		                              ���
���          �                     				 					      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ECFRetPeri(dDataini)
Local cRet 	:= ""
Local nIx	:= 0
Local cPeriodo := Substr( Dtos(dDataini), 5 )

aPerTrim := {	{01, "0101" , "0331"},;
				{02, "0401" , "0630"},;
				{03, "0701" , "0930"},;
				{04, "1001" , "1231"},;
			}

For nIx := 1 TO Len( aPerTrim )
	If cPeriodo >= aPerTrim[nIx,2] .AND. cPeriodo <= aPerTrim[nIx,3] 
		cRet := aPerTrim[nIx,1]
		Exit
	Endif
Next nIx

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CtbsInvtFl
Efetuar a invers�o da sele��o de filais do grid 
@author Daniel Mendes
@version P11
@since   04/04/2016
@return  Nil
/*/
//-------------------------------------------------------------------
Function CtbsInvtFl( oGrid , nPosCol , aFils , lEmp , cModEsc )
Local nFor      := 0
Local lExibMsg  := .F.

Default nPosCol := 0
Default aFils	:= {}
Default lEmp	:= .T.
Default cModEsc	:= ''

If nPosCol == 1
	For nFor := 1 To Len( aFils	)
		aFils := EmpTrocEcd( nFor , aFils , lEmp , cModEsc , @lExibMsg )
	Next nFor

	If lExibMsg
		MsgAlert( STR0010 )
	EndIf

	oGrid:Refresh()
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ECDMemo

Retorna o cont�udo do campo tipo Memo, varbinary para texto

@author Andr� Brito
@since 05/02/2018 
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function ECDMemo(nRec)

Local cRet     := ""
Local aArea    := GetArea()

CSE->(dbGoTo(nRec))
cRet := Alltrim(StrTran(CSE->CSE_NOTAEX,CRLF,''))
cRet := Padr(cRet,255)//255 � o n�mero de caracteres disponiveis para uso no porgrama validador da Receita Federal
RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} EcdSave

Salva as informa��es digitadas no wizard ECD

@author Andr� Brito
@since 05/02/2018 
@version P12.1.17
/*/
//-------------------------------------------------------------------

Function EcdSave(cLoad,aParametros,cBloq,cTipo)
local nx
Local cCodEmp := cEmpAnt
Local cWrite  := ""
Local cBarra  := If(issrvunix(), "/", "\")
Default cTipo := "ECD"

cWrite := cBloq+"Arquivo de configura��o - "+iIf(cTipo=="ECD","ECD","ECF")+"_"+cCodEmp+CRLF

For nx := 1 to Len(aParametros)
	If ValType(aParametros[nx]) == "C"
		cWrite += aParametros[nx] + CRLF
	ElseIf ValType(aParametros[nx]) == "N"
		cWrite += Str(aParametros[nx]) + CRLF
	ElseIf ValType(aParametros[nx]) == "D"
		cWrite += DTOC(aParametros[nx]) + CRLF
	Else
		cWrite += "X"+CRLF
	EndIf

Next
//adicionando o c�digo da empresa ao nome do arquivo
cLoad := Alltrim(cLoad)+"_"+cCodEmp

MemoWrit(cBarra + "PROFILE" + cBarra +Alltrim(cLoad)+".PRB",cWrite)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} EcdLoad

Resgata as informa��es digitadas no wizard ECD

@author Andr� Brito
@since 05/02/2018 
@version P12.1.17
/*/
//-------------------------------------------------------------------

Function EcdLoad(cLoad,aParametros,nx,xDefault,lDefault)
local ny
Local cBarra 		:= If(issrvunix(), "/", "\")
Local cCodEmp 		:= cEmpAnt
Local xRet			:= ""
DEFAULT lDefault 	:= .F.

cLoad := cLoad + "_" + cCodEmp

If cCodEmp $ cLoad
	If File(cBarra + "PROFILE" + cBarra +Alltrim(cLoad)+".PRB")
		If FT_FUse(cBarra +"PROFILE"+cBarra+Alltrim(cLoad)+".PRB")<> -1
			FT_FGOTOP()
			If nx == 0
				cLinha := FT_FREADLN()
				FT_FUSE()
				Return Substr(cLinha,1,1)
			EndIf
			For ny := 1 to nx
				FT_FSKIP()
			Next
			cLinha := FT_FREADLN()
			If !lDefault
				xRet := Substr(cLinha,1,Len(cLinha))
			Else
				xRet := xDefault
			Endif
			FT_FUSE()
		EndIf
	Else
		xRet := xDefault
	EndIf
EndIf

If Alltrim(xRet) == "X"
	xRet := ""
EndIf

Return Alltrim(xRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ECDIndCta

Retorna a natureza da conta caso o saldo da mesma seja igual a 0

@author Andr� Brito
@since 09/05/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function ECDIndCta(cConta, nVal, cReg)

Local cRet     := "" //Identificador de natureza da conta
Local aArea    := GetArea()

Default cConta := ""  //Conta contabil 
Default nVal   := 0 //Valor
Default cReg   := ""  //Registro I155 / I355

DbSelectArea("CT1")
DbSetorder(1)

If cReg == 'I155'
	If nVal == 0 //Se o valor do registro I155 for igual a 0, gerar a partir do identificador da conta contabil ("D"ebito/"C"redito)
		If dbSeek(xFilial("CT1")+cConta)
			If CT1->CT1_NORMAL == '1' //1 - Debito 2 -Cr�dito
				cRet := 'D'
			Else
				cRet := 'C'
			EndIf
		EndIf
	EndIf
Else
	//A condi��o abaixo do I355 foram extra�das do XML
	If nVal > 0 //Se o registro for I355 e maior que zero imprimir D�bito
		cRet := 'D'
	Else 
		If nVal == 0 
			If dbSeek(xFilial("CT1")+cConta) //Se n�o for maior que 0, gerar a partir do identificador da conta
				If CT1->CT1_NORMAL == '1' //1 - Debito 2 -Cr�dito
					cRet := 'D'
				Else
					cRet := 'C'
				EndIf
			EndIf
		Else
			cRet := 'C'
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return cRet
/*/
{Protheus.doc} PictCPFCGC
Atualiza a m�scara de acordo com o conte�do digitado
@author TOTVS
@since 07-03-2019
/*/
Function PictCPFCGC()

Local oModel    := FWModelActive()
Local cRet 		:= "@R 99.999.999/9999-99"
Local cConteudo := ""
Local nLen		:= 0
Local nTam 		:= 0
Local cCampo    := oModel:GetModel("ModelCVR"):GetValue("CVR_CGC")

If !Empty(cCampo)
	cConteudo := AllTrim((cCampo))
	If !Empty(cConteudo)			
		If Len(cConteudo) == 11 
			cRet := "@R 999.999.999-99"		
		EndIf
	EndIf

	nLen := Len(cConteudo)
	nTam := TamSx3(StrTran("CVR_CGC","M->",""))[1]

	If nLen < nTam
		cRet += Replicate("9",nTam-nLen) //Para manter o tamanho do campo. 
	EndIf
EndIf

cRet+="%C"

Return cRet

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ECDFilLength

Fun��o que retorna array com o tamanho de cada segmento da composi��o da Filial com o uso de gest�o 
empresarial.

	- Grupo de Empresas
	- Empresa
	- Unidade de Neg�cio
	- Filial

@params:

@return: 
	aRetLen:	Array. Vetor com o tamanho de cada segmento
		aRetLen[1]:	Num�rico. Tamanho da cadeia de caracteres do Grupo de Empresas
		aRetLen[2]:	Num�rico. Tamanho da cadeia de caracteres de Empresa
		aRetLen[3]:	Num�rico. Tamanho da cadeia de caracteres de Unidade de Neg�cio
		aRetLen[4]:	Num�rico. Tamanho da cadeia de caracteres de Filial

@sample:
	aRetLen := ECDFilLength()
@author Totvs

@since 06/02/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Function ECDFilLength()

Local aGrpComp	:= FWAllGrpCompany()
Local aCompany	:= FwAllCompany()
Local aUnitBus	:= FWAllUnitBusiness()
Local aAllFili	:= FwAllFilial()
Local aRetLen	:= Array(4)

aFill(aRetLen,0)

If ( ValType(aGrpComp) == "A" .And. Len(aGrpComp) > 0 )
    aRetLen[1] := Len(aGrpComp[1])
EndIf

If ( ValType(aCompany)  == "A" .And. Len(aCompany) )
    aRetLen[2] := Len(aCompany[1])
EndIf

If ( ValType(aUnitBus)  == "A" .And. Len(aUnitBus) )
    aRetLen[3] := Len(aUnitBus[1])
EndIf

If ( ValType(aAllFili)  == "A" .And. Len(aAllFili) )
    aRetLen[4] := Len(aAllFili[1])
EndIf

Return(aRetLen)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ECDQryCta

Fun��o que retorna array com o tamanho de cada segmento da composi��o da Filial com o uso de gest�o 
empresarial.

	- Grupo de Empresas
	- Empresa
	- Unidade de Neg�cio
	- Filial

@params:

@return: 
	aRetLen:	Array. Vetor com o tamanho de cada segmento
		aRetLen[1]:	Num�rico. Tamanho da cadeia de caracteres do Grupo de Empresas
		aRetLen[2]:	Num�rico. Tamanho da cadeia de caracteres de Empresa
		aRetLen[3]:	Num�rico. Tamanho da cadeia de caracteres de Unidade de Neg�cio
		aRetLen[4]:	Num�rico. Tamanho da cadeia de caracteres de Filial

@sample:
	aRetLen := ECDFilLength()
@author Totvs

@since 06/02/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
/*Function ECDQryCta(dDataFin,dDataIni,cMoeda,cSaldo,aFiliais,lConsMovZer,cTabEmp)

Local cQuery 	:= ""
Local cInFil	:= ""

Default dDataFin	:= Ctod("")
Default dDataIni	:= Ctod("")
Default cMoeda		:= ''
Default cSaldo		:= ''
Default aFiliais	:= {}
Default lConsMovZer	:= .F. // Considera somente contas movimentadas?
Default cTabEmp		:= RetSqlName("CQ1")

If ( TCCanOpen(cTabEmp) )

	If ( Len(aFiliais) > 0 )
		
		cInFil := "IN "
		cInFil := StrTran(AsString(aFiliais,.t.),"{","(")
		cInFil := StrTran(cInFil,"}",")")

	Else
		cInFil := "= '" + xFilial("CQ1") + "' " + chr(13)
	EndIf

	cQuery := "( SELECT CQ1_CONTA" 
	cQuery += "	FROM ( "
	cQuery += "			SELECT CQ1.CQ1_CONTA, SUM(CQ1.CQ1_DEBITO - CQ1.CQ1_CREDIT) VALOR "
	cQuery += "			FROM " + cTabEmp + " CQ1 "
	cQuery += "			WHERE CQ1.CQ1_FILIAL " + cInFil

	If !Empty(dDataIni)
		cQuery += "			  AND CQ1.CQ1_DATA >= '" + DTOS(dDataIni) + "'" 
	EndIf

	If !Empty(dDataFin)
		cQuery += "			  AND CQ1.CQ1_DATA <= '" + DTOS(dDataFin) + "'" 
	EndIf

	cQuery += "			  AND CQ1.CQ1_MOEDA = '" + cMoeda + "'"  
	cQuery += "			  AND CQ1.CQ1_TPSALD = '" + cSaldo + "'" 
	cQuery += "			  AND CQ1.D_E_L_E_T_ = ' ' "
	cQuery += "			GROUP BY CQ1.CQ1_CONTA"
	cQuery += "		) CQ11" 

	If !lConsMovZer
		cQuery += "	WHERE CQ11.VALOR <> 0"
	Endif

	cQuery += ")

EndIf

Return(cQuery)*/
