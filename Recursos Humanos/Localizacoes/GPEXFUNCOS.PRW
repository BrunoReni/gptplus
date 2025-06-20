#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEXFUNCOS.CH"

/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.		    	       ���
����������������������������������������������������������������������������������Ĵ��
���Programador �   Data   �     FNC     �  Motivo da Alteracao 	    		   	   ���
����������������������������������������������������������������������������������Ĵ��
���Mohanad Odeh�06/12/2011�00029489/2011�Inclus�o da fun��o ValidRPatCOS()         ���
���            �          �       TE8334�                                          ���
���Christiane V�13/12/2011�00030173/2011�Cria��o da fun��o gpRCAFiltro(), que ser� ���
���            �          �       TEBBJ9�utilizada na consulta padr�o RCA02.       ���
���Christiane V�16/12/2011�00030173/2011�Retirada da fun��o gpRCAFiltro(), que serᳱ�
���            �          �       TEBBJ9�inclu�da no fonte GPEA291                 ���
���Mohanad Odeh�04/04/2012�00007484/2012�Altera��o na atribui��o do filtro na      ���
���            �          �       TESFXP�fun��o GPCOSSXB() para corre��o pontual de���
���            �          �             �erro em consulta padr�o                   ���
��|Aldo Marini �10/01/2012�				�Alteracao da chamada do alias VAM para    ���
��|            �          �				�CC2 p/ padronizacao do codigo municipio   ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������*/
	
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �fDiaFerCOS  � Autor � Christiane Vieira     � Data � 02/11/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Calcula dias de ferias para Costa Rica                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �dDataBase	: Data inicial do periodo aquisitivo                ���
���          �dDataFim	: Data final do periodo aquisitivo                  ���
���          �aDiasFer	: Array a ser passado por referencia                ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/  
Function fDiaFerCOS(dDataBase, dDataFim, aDiasFer)
Local nDiasTot:= 0

aDiasFer:= { , }

/*�����������������������������������������������������������Ŀ
//� Calcula dias de ferias (dias de direito).                 �
//�������������������������������������������������������������*/
DbSelectArea("RCJ")                         
dbSetOrder(RetOrder("RCJ", "RCJ_FILIAL+RCJ_CODIGO"))
RCJ->(dbSeek(xFilial("RCJ") + SRA->RA_PROCES ))

aDiasFer[1]:= RCJ->RCJ_DIAVAC

/*�����������������������������������������������������������Ŀ
//� Calcula dias de ferias proporcionais.                     �
//�������������������������������������������������������������*/
nDiasTot:=  Min(dDataFim - dDataBase + 1, 365)
nAvosFer:= aDiasFer[1]/365 * nDiasTot

aDiasFer[2]:= nAvosFer     

Return()   


/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������ͻ��
���Programa  � GP3COSSXB � Autor � Ademar Fernandes   � Data �  29/10/08             ���
�����������������������������������������������������������������������������������͹��
���Descricao � Exibe Tela de Pesquisa de tabelas do RCC                             ���
���          �                                                                      ���
�����������������������������������������������������������������������������������͹��
���Uso       � Consulta Padrao Especifica - SXB                                     ���
�����������������������������������������������������������������������������������ͼ��
���Programador � Data   � BOPS 			 �  Motivo da Alteracao                     ���
�����������������������������������������������������������������������������������Ĵ��
���            �        �                �                                          ���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
*/
Function GPCOSSXB(cTabela,cCpoRet,cFiltro)

Local nOpca:=0, i,lAllOk
Local oDlg, cCampo, nX, nY, cCaption, cPict, cValid, cF3, cWhen, nLargSay, nLargGet, uConteudo, oSay, oGet
Local cBlkGet,cBlkWhen,cBlkVld, oSaveGetdad := Nil, aSvRot := Nil
Local oTop
Local oBottom
Local aObject := {}              
Local aSize := {}
Local nObject
Local nAuxWidth := 0
Local aCordW := {125,0,400,635}

Local nCount := 0
Local cMyCpo := ""
Local lDelGetD := .F.
Local cLineOk := "AllwaysTrue()"
Local cAllOk  := "AllwaysTrue()"
Local nOpcx	:= 7
Local aCGD	:= {}
Local lExist := .F.
Local nCpoRet := 0
Local nCntCmb := 0
Local nMaxCmb := 5	//# Nr.Maximo de opcoes no Combo
Local cVar		:= Alltrim(ReadVar())
Local cPesq := IIf(Empty(AllTrim(&cVar)), Space(30), AllTrim(&cVar) )

Local nPos 		:= At("+", cCpoRet )  
Local cCpoAux	:= ""
Local cRcbCampo	:= ""
Local cRcbDescr	:= ""
Local cRetFiltro:= ""
Private cCombo  := ""
Private aCombo  := {}
Private aMyCombo:= {}
Private aSXBCols   := {}
Private aSXBHeader := {}
Private nUsado  := 0

Private cFilRCB  := ""
Private cFilRCC  := ""
Private cDescRCC := ""
Private lPesqComp := .F. //Variavel que indica se a pesquisa esta sendo feita com mais de um campo

Default cFiltro := ""

If cTabela == NIL .Or. cCpoRet == NIL
	MsgAlert(OemToAnsi(STR0002),OemToAnsi(STR0001))	// "N�o � poss�vel continuar pois faltam parametros nesta fun��o !!!"##"Aten��o !"
	IF Funname() == 'GPEA320'
		Return(.f.)
	else
		Return("")
	endif         
EndIf

If nPos > 0
	lPesqComp := .T.
EndIf

//# Posiciona no RCB
dbSelectArea("RCB")
dbSetOrder(1)

If !dbSeek(xFilial("RCB")+cTabela,.F.)
	MsgAlert(OemToAnsi(STR0003),OemToAnsi(STR0001))	// "A Tabela informada n�o existe !!!"##"Aten��o !"
	IF Funname() == 'GPEA320'
		Return(.f.)
	else
		Return("")
	endif   
EndIf
cFilRCB  := xFilial("RCB")
cDescRCC := Alltrim(RCB_DESC)

//# Posiciona no RCC
dbSelectArea("RCC")
dbSetOrder(1)

If !ExistRTab(cTabela)//!dbSeek(xFilial("RCC")+cTabela,.F.)
	MsgAlert(OemToAnsi(STR0004),OemToAnsi(STR0001))	// "N�o existe informa��es cadastradas para Tabela !!!"##"Aten��o !"
   	IF Funname() == 'GPEA320'
		Return(.f.)
	else
		Return("")
	endif   
EndIf
cFilRCC := xFilial("RCC")

If cTabela == "S013" //Consulta Espec�fica de Cant�es ... � utilizada em v�rias rotinas
	If Funname() == 'GPEA010'     //Cadastro de Funcion�rios
		cRetFiltro := "{ || Substr(RCC->RCC_CONTEU,46,2) ==  '" + M->RA_ESTADO + "' }"
	ElseIf Funname() == 'GPEA390' //Cadastro de Registro Patronal
		cRetFiltro := "{ || Substr(RCC->RCC_CONTEU,46,2) ==  '" + M->RCO_UF + "' }"
	ElseIf Funname() == 'GPEA660' //Cadastro de Localidade de Pagamento
		cRetFiltro := "{ || Substr(RCC->RCC_CONTEU,46,2) ==  '" + M->RGC_ESTADO + "' }"
	ElseIf Funname() == 'GPEA460' //Cadastro de Municipios
		cRetFiltro := "{ || Substr(RCC->RCC_CONTEU,46,2) ==  '" + M->CC2_EST + "' }"
	Endif
Endif

cRetFiltro := Alltrim(cRetFiltro)

fMontaHeaderRCC(cTabela, cCpoRet)
MontaColsRCC(cTabela, cCpoRet, cFiltro, &cRetFiltro)

//# Variaveis inicializadas no teste
Private cTitulo := cTabela+" - "+cDescRCC //#"U014 - Teste"
Private nMax := Len(aSXBCols)
Private aC := {}
Private aColsBkp := aClone(aSXBCols)

//# Variaveis inicializadas no teste
aAdd(aC,{"cMyCpo", {15,001},"",,,,.F.,})

nCount++
__cLineOk := cLineOK
__nOpcx	 := nOpcx
If nCount > 1
	oSaveGetdad := oGetDados
	oSaveGetdad:oBrowse:lDisablePaint := .t.
EndIf

oGets := {}
If Type("aRotina") == "A"
	aSvRot := aClone(aRotina)
EndIf

aRotina := {}
For nX := 1 to nOpcX
	AADD(aRotina,{"","",0,nOpcx})
Next

aCGD:=Iif(Len(aCGD)==0,{34,5,128,315},aCGD)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) FROM aCordW[1],aCordW[2] TO aCordW[3],aCordW[4] PIXEL OF oMainWnd

If Len(aC) > 0
	
	//# Monta o Combo a partir do Titulo do RCB
	dbSelectArea("RCB")
	dbSeek(xFilial("RCB")+cTabela,.F.)
	
	While !Eof() .And. RCB->(RCB_FILIAL+RCB_CODIGO) == (cFilRCB+cTabela)
		
		//# Verifica se o campo ja existe
		If !lExist .And. ValType("RCB->RCB_PESQ")<>"U"
			lExist := .T.
		EndIf
		
		//# Monta o aCombo e aMyCombo
		If !lExist .Or. (lExist .And. RCB->RCB_PESQ=="1")
			nCntCmb += 1
			aAdd( aCombo, Alltrim(Capital(RCB_DESCPO)) )
			aAdd( aMyCombo, {Alltrim(Capital(RCB_DESCPO)),Alltrim(RCB_CAMPOS)} )
			If lPesqComp .And. At(Alltrim(RCB_CAMPOS), cCpoRet) > 0
				cRcbDescr += Alltrim(Substr(Capital(RCB_DESCPO),1,9)) + '+'
				cRcbCampo += Alltrim(RCB_CAMPOS) + '+'
			Endif
			If nCntCmb >= nMaxCmb
				Exit
			EndIf
		EndIf
		
		dbSkip()
	EndDo
	If lPesqComp
		cRcbDescr := Substr(cRcbDescr, 1, Len(cRcbDescr)-1)
		cRcbCampo := Substr(cRcbCampo, 1, Len(cRcbCampo)-1)
		nCntCmb += 1
		aAdd( aCombo, Alltrim(cRcbDescr) )
		aAdd( aMyCombo, {Alltrim(cRcbDescr),Alltrim(cRcbCampo)} )
	Endif       

	dbSelectArea("RCC")
	
	@ 000,000 SCROLLBOX oTop
	Aadd(aSize,aCGD[1]+13)
	Aadd(aObject,oTop)
	nObject := 2
	
	Private oCombo, oPesq, oBtn1, oCheckBox, lCheck
	
	@ 005,005 SAY OemToAnsi(STR0005) SIZE 35,07 OF oTop PIXEL	// "Pesquisar por: "
	@ 005,045 MSCOMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 080,010 OF oTop PIXEL
	@ 006,140 CHECKBOX oCheckBox VAR lCheck PROMPT OemToAnsi(STR0006) VALID Iif(!Empty(cCombo),GP310Ord(),fValPesq()) SIZE 55,08 OF oTop PIXEL	// "Ordenar"
	@ 005,185 MSGET oPesq VAR cPesq PICTURE "@!" VALID Iif(!Empty(cCombo),PesqDados(cPesq),fValPesq()) SIZE 80,10 OF oTop PIXEL			
	@ 013,530 BTNBMP oBtn1 RESOURCE "btpesq" SIZE 025,025 OF oTop PIXEL ACTION ( PesqDados(cPesq) )			
	
	For i:=1 to Len(aC)
		cCampo:=aC[i,1]
		nX:=aC[i,2,1]-13
		nY:=aC[i,2,2]
		cCaption:=Iif(Empty(aC[i,3])," ",aC[i,3])
		cPict:=Iif(Empty(aC[i,4]),Nil,aC[i,4])
		cValid:=Iif(Empty(aC[i,5]),".t.",aC[i,5])
		cF3:=Iif(Empty(aC[i,6]),NIL,aC[i,6])
		cWhen    := Iif(aC[i,7]==NIL,".t.",Iif(aC[i,7],".t.",".f."))
		cWhen    := Iif(!(Str(nOpcx,1,0)$"346"),".f.",cWhen)
		cBlKSay  := "{|| OemToAnsi('"+cCaption+"')}"
		
		oSay     := TSay():New( nX+1, nY, &cBlkSay,oTop,,, .F., .F., .F., .T.,,,,, .F., .F., .F., .F., .F. )
		nLargSay := GetTextWidth(0,cCaption) / 1.8  // estava 2.2
		cCaption := oSay:cCaption
		
		cBlkGet  := "{ | u | If( PCount() == 0, "+cCampo+","+cCampo+":= u ) }"
		cBlKVld  := "{|| "+cValid+"}"
		cBlKWhen := "{|| "+cWhen+"}"
					
		oGet := TGet():New( nX, nY+nLargSay,&cBlKGet,oTop,,,cPict, &(cBlkVld),,,, .F.,, .T.,, .F., &(cBlkWhen), .F., .F.,, .F., .F. ,cF3,(cCampo))
		AADD(oGets,oGet)
	Next
EndIf

//oGetDados :=MSGetDados():New(aCGD[1],aCGD[2],aCGD[3],aCGD[4],nOpcX,"__MOD2LineOK()","AllwaysTrue()",,lDelGetD,,,,nMax,"__Field2Ok()")
oGetDados := MsNewGetDados():New(aCGD[1],;// nTop
								 aCGD[2],;   	// nLelft
								 aCGD[3],;	// nBottom
	                             aCGD[4],;	// nRright
								 nOPCX,;	    	// controle do que podera ser realizado na GetDado - nstyle
								 "SXBMod2LOk()",;	// funcao para validar a edicao da linha - ulinhaOK
								 "AllwaysTrue()",;	// funcao para validar todas os registros da GetDados - uTudoOK
  								 NIL,;				// cIniCPOS
								 NIL,;		        // aAlter
								 0,; 				// nfreeze
								 nMax,;  			// nMax
								 NIL,;		 		// cFieldOK
								 NIL,;				// usuperdel
								 .F.,;	        	// udelOK
								 @oDlg,;        	// objeto de dialogo - oWnd
								 @aSXBHeader,;		// Vetor com Colunas - AparHeader
								 @aSXBCols;			// Vetor com Header - AparCols
					)

Aadd(aObject,oGetDados:oBrowse)
Aadd(aSize,NIL)

If !Empty(cPesq)
	PesqDados(cPesq)
Endif
	
ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,lAllOk:=__Mod2OK(cAllOk),Iif(lAllOk,oDlg:End(),nOpca:=0)},{||oDlg:End()},,),;
								AlignObject(oDlg,aObject,1,nObject,aSize),oGetDados:oBrowse:Refresh())

nCount--
If nCount > 0
	oGetDados := oSaveGetDad
	oGetDados:oBrowse:lDisablePaint := .f.
EndIf
If ValType(aSvRot) == "A"
	aRotina := aClone(aSvRot)
EndIf

If nOpca == 1 .and. Len(aSXBCols)>0
	If !lPesqComp
		nCpoRet := GdFieldPos(cCpoRet, aSXBHeader)
		VAR_IXB  := aSXBCols[oGetDados:nAt,nCpoRet]
		IF Funname() == 'GPEA320'
			&(ReadVar()) := VAR_IXB
		ENDIF
	Else         
		VAR_IXB := ""	
		While lPesqComp
			cCpoAux := Substr(cCpoRet, 1, nPos - 1)
			cCpoRet := Substr(cCpoRet, nPos +1)    
			
			nCpoRet := GdFieldPos(cCpoAux, aSXBHeader)
			VAR_IXB += aSXBCols[oGetDados:nAt,nCpoRet]			

			nPos := At("+", cCpoRet )
			lPesqComp := If (nPos > 0, .T., .F.)
			
			If nPos == 0
				nCpoRet := GdFieldPos(cCpoRet, aSXBHeader)
				VAR_IXB += aSXBCols[oGetDados:nAt,nCpoRet]
			Endif
		EndDo
		IF Funname() == 'GPEA320'
			&(ReadVar()) := VAR_IXB
		ENDIF
	Endif	
Else
	VAR_IXB := ""
EndIf
Return(nOpca == 1)


/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Funcao    � ValidIdCOS � Autor � Christiane Vieira 	� Data � 18.11.2011  ���
����������������������������������������������������������������������������Ĵ��
���Descricao � Valida��o de campo RA_CIC para Localiza��o Costa Rica         ���
���			 �                                                               ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   � < Vide Parametros Formais >	                                 ���
����������������������������������������������������������������������������Ĵ��
���Uso       � GPEA010 - Localiza��o Costa Rica                              ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function ValidIdCOS(cId)
Local aArea   	:= GetArea()
Local lRet 		:= .T.
Local cMsgAlert	:= ""

DbSelectArea("SRA")
DbSetOrder( 5 )


If DbSeek( xFilial( "SRA" ) + cId )
	cMsgAlert := OemToAnsi(STR0007) + CRLF		//"Este n�mero de identifica��o j� existe para o funcion�rio: "
	cMsgAlert += SRA->RA_FILIAL + " / " + SRA->RA_MAT  + " / " + AllTrim(SRA->RA_NOME) + CRLF
	cMsgAlert += OemToAnsi(STR0008)				//"Deseja confirmar a inclus�o? 

	If MsgYesNo(cMsgAlert ,OemToAnsi(STR0001))
	
	Else
		lRet := .F.
	Endif
Endif

DbSetOrder(1)

RestArea(aArea)

Return lRet


/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Funcao    � ValidRPatCOS � Autor � Christiane Vieira  � Data � 21.11.11	 ���
����������������������������������������������������������������������������Ĵ��
���Descricao � Valida��o do Registro Patronal para a Localiza��o Costa Rica  ���
���			 �                                                               ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   � < Vide Parametros Formais >	                                 ���
����������������������������������������������������������������������������Ĵ��
���Uso       � GPEA390 - Localiza��o Costa Rica                              ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function ValidRPatCOS(cRegPat)
Local cRPat01 	:= ""
Local cNumProv	:= ""
Local lRet		:= .T.
Default cRegPat	:= Space(20)

cRPat01 := Substr(cRegPat,1,1)		//Natureza Patronal (0, 2, 9)
cNumProv := Substr(cRegPat,2,1)		//Numero da Provincia (1-7)

If !Empty(AllTrim(cRegPat))
	If !cRPat01 $ ("0|2|9")
		Help( " ", 1, "Help",, OemToAnsi(STR0009), 1, 0 ) // "O Registro Patronal deve iniciar com 0 ou 2 ou 9"
		lRet := .F.
	ElseIf cRPat01 == "0"
		If !cNumProv $ ("1|2|3|4|5|6|7")
			Help( " ", 1, "Help",, OemToAnsi(STR0010) , 1, 0 ) // "O segundo d�gito do Registro Patronal deve corresponder ao n�mero do Estado, entre 1 e 7"
			lRet := .F.
		EndIf
	Endif
Endif

Return(lRet)