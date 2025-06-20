#Include "protheus.ch"
#include "msmgadd.CH"
#Include "ctba050.ch"

STATIC nQtdEntid

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBA050   �Autor  �Acacio Egas         � Data �  23/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de Configuracoes de Entidades Contabeis.          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function CTBA050(cAlias , nReg , nOpcx)

Local cFilterCV0	:= "CV0_CODIGO=' '"
Default cAlias := "CV0"

Private aIndexCV0	:= {}
Private bFiltraBrw	:= {|| FilBrowse(cAlias,@aIndexCV0,@cFilterCV0,.T.) }


If !CtbVerSX2("CT0", .T.)
	Return
EndIf

//�������������������������������������������������������������������Ŀ
//�Verifica se sera utilizada a rotina de cubo das entidades contabeis�
//���������������������������������������������������������������������
If GetMv('MV_CTBCUBE',.F.,"0")=="1"
	CTBA800()
	Return
EndIf
Private aRotina 	:= MenuDef()//Nao colocar o 'aRotina' antes da chamada do CTBA800. A declara��o desta var�avel causa erro na Msget deste fonte.

mBrowse( 6, 1,22,75,cAlias,,,,,,,,,,,,,,cFilterCV0)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTB050DLG �Autor  � Acacio Egas        � Data �  11/23/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Dialog de Vizualiza�o, Inclus�o, Altera��o, Dele��o.       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTB050DLG(cAlias,nReg,nOpc)

// variaveis de tela
Local cCadastro		:= STR0001//"Entidades Contabeis"
Local oDlg
Local oEnch,oPlano,oDesc
Local aExbCpo		:= {"CV0_PLANO","CV0_DESC","NOUSER"}
Local aHeaderCV0
Local aColsCV0		:= {}
Local aRecnosCV0	:= {}
Local nOpcao		:= 0
Local aSizeAut		:= {}
Local aObjects		:= {}
Local aButtons		:= {}
Local aInfo			:= {}
Local aPosObj		:= {}// variaveis de integridade
Local aArea			:= (cAlias)->(GetArea())
// variaveis de controle
Local bOk			:= { || IIf(CTBA050TOk() , (nOpcao:=1,oDlg:End()) , nOpcao := 0) }
Local bCancel		:= { || nOpcao:=0 , oDlg:End() }
Local cGetOpc		:= Iif(Altera .OR. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE, 0)
Local nX
Local cItem			:= StrZero(0,TamSX3("CV0_ITEM")[1])
Local lContinua 	:= .T.
Private oGDItens
Private cPlanoCV0
Private nLinInc
Private aGets		:= {} 
Private aTela		:= {}
Private bLinGtd		:= {|| If(Valtype(oGDItens)="O",oGDItens:nAt,0) }
Private INCLUI		:= .F.

//Tratamento para executar a opcao que se deseja 
//Necessario por nao ter rotina de Inclusao.
//nOpc chega com a posi��o do array aRotina
nOpc := aRotina[nOpc,4]

nReg   := IIf(nOpc==3,Nil,CV0->(Recno()))
cAlias := "CV0"

If cPaisLoc == "RUS" .And. SuperGetMv("MV_REDSTORN",.F.,.F.) .And. nOpc == 4 .And. CV0->CV0_PLANO == '05'
	Help(" ",1,"NOUPDATE05EC")
	lContinua := .F.
Endif

If lContinua
	// Maximizacao da tela em rela��o a area de trabalho
	aSizeAut := MsAdvSize()
	aAdd(aObjects,{100,040,.T.,.F.})
	aAdd(aObjects,{100,100,.T.,.T.})
	
	aInfo     := {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],3,3}
	aPosObj   := MsObjSize(aInfo,aObjects)
	
	If nOpc == 2	//Visualiza��o
		nOpEnch:= 2
		cPlanoCV0 := CV0->CV0_PLANO
		cDescCV0 := CV0->CV0_DESC
	ElseIf nOpc == 3	//Inclus�o
		nOpEnch:= 3
		INCLUI	:= .T.
		cPlanoCV0 	:= Space(TamSx3("CV0_PLANO")[1]	)
		cDescCV0 	:= Space(TamSx3("CV0_DESC")[1]	)
	ElseIf nOpc == 4	//Altera��o
		nOpEnch:= 3
		cPlanoCV0 := CV0->CV0_PLANO
		cDescCV0 := CV0->CV0_DESC
	ElseIf nOpc == 5	//Exclus�o
		nOpEnch:= 5
		cPlanoCV0 := CV0->CV0_PLANO
		cDescCV0 := CV0->CV0_DESC
	Else //Outras situa��es
		nOpEnch:= 2
		cPlanoCV0 := CV0->CV0_PLANO
		cDescCV0 := CV0->CV0_DESC
	EndIf
	
	If !CTB050Tab(CV0->CV0_PLANO)
		Return
	EndIf

	// Montagem da tela que serah apresentada para usuario (lay-out)
	Define MsDialog oDlg Title cCadastro From aSizeAut[7],0 To aSizeAut[6],aSizeAut[5] Of oMainWnd Pixel
	
	@ 043,008 	SAY OemToAnsi(STR0002) SIZE 18, 7 OF oDlg PIXEL  //"Plano"
	oPlano	:=	TGet():New( 040, 038, {|u| If(PCount() > 0,cPlanoCV0 := u,cPlanoCV0) }, oDlg, 020, ,"@!",{||CTB050VlPl()},,,,,,.T./*<.pixel.>*/,,,{|| INCLUI },,,,,,,"cPlanoCV0"/*<(uVar)>*/,,,)
	
	@ 043,158 	SAY OemToAnsi(STR0003) SIZE 35, 7 OF oDlg PIXEL  //"Descri��o"
	oDesc	:=	TGet():New( 040, 198, {|u| If(PCount() > 0,cDescCV0 := u,cDescCV0)  }, oDlg, 080, ,"@!",,,,,,,.T./*<.pixel.>*/,,,,,,,,,,"cDescCV0"/*<(uVar)>*/,,,)
	
	//RegToMemory("CV0", nOpc == 3 ,,, FunName())
	
	//oEnch 	:= Msmget():New(cAlias,nReg,nOpEnch,,,,aExbCpo,aPosObj[1],aExbCpo,,,,,oDlg,,.T.)
	
	aHeaderCV0	:= GetaHeader(cAlias,,{"CV0_PLANO"})
	
	DbSelectArea(cAlias)
	DbSetOrder(1)
	If nOpc <> 3
		//***************
		// Monta aCols	*
		//***************
		DbGoTo(nReg)
		cPlanoCV0 := CV0->CV0_PLANO
		Do While !(cAlias)->(Eof()) .and. xFilial(cAlias)+cPlanoCV0 == CV0->CV0_FILIAL+CV0->CV0_PLANO
			If !Empty(CV0->CV0_CODIGO)
				aAdd(aRecnosCV0, (cAlias)->(Recno()) )
				aAdd(aColsCV0,Array(Len(aHeaderCV0) + 1))
				AEval(aHeaderCV0, {|x,y| aColsCV0[Len(aColsCV0)][y] := If(Alltrim(x[2])$"CV0_ALI_WT|CV0_REC_WT".OR. x[10]=="V",NIL, CV0->(FieldGet(FieldPos(x[2]))) ) })
				aColsCV0[Len(aColsCV0),Len(aHeaderCV0) + 1] := .F.
			EndIf
			(cAlias)->(DbSkip())
		EndDo
	EndIf

	//******************************
	// Busca utima linha com recno *
	//******************************
	nLinInc := Len(aRecnosCV0)
	
	oGDItens:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],cGetOpc,"CTB050LOk()",,"+CV0_ITEM",,,15000,,,"CTB050DOk()",oDlg,aHeaderCV0,aColsCV0)
	
	
	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)
	
	If nOpcao == 1
	
		//**********************
		// Inicio da Transac�o *
		//**********************
		Begin Transaction
	
		aColsCV0 := oGDItens:aCols
		DbSelectArea(cAlias)
	
		Do Case
			Case nOpc == 3
				RecLock("CV0",.T.)
				CV0->CV0_FILIAL	:= xFilial(cAlias)
				CV0->CV0_PLANO	:= cPlanoCV0
				CV0->CV0_DESC	:= cDescCV0  
				MsUnLock()
		 	Case nOpc == 4
			DbGoTo(nReg)
				RecLock("CV0",.F.)
				CV0->CV0_FILIAL	:= xFilial(cAlias)
				CV0->CV0_PLANO	:= cPlanoCV0
				CV0->CV0_DESC	:= cDescCV0
				MsUnLock()
			Case nOpc == 5
			DbGoTo(nReg)
				RecLock("CV0",.F.,.T.)
				DbDelete()
				MsUnLock()
		EndCase
	
		For nX:= 1 to Len(aColsCV0)
			//**************************
			// Procura recno da linha  *
			//**************************
			If nX <= Len(aRecnosCV0)
				DbSelectArea(cAlias)
				DbGoTo(aRecnosCV0[nX])
		
				If !aColsCV0[nX, Len(aHeaderCV0) +1 ] .and. nOpc <> 5
					//*****************************************************
					// Altera linhas n�o deletadas quando nao for Delete  *
					//*****************************************************
					RecLock("CV0",.F.)
					CV0->CV0_FILIAL	:= xFilial(cAlias)
					CV0->CV0_PLANO	:= cPlanoCV0
					aEval(aHeaderCV0, {|x,y| If(x[10]<>"V",CV0->&(x[2]) := aColsCV0[nX,y],.F.) })
					MsUnLock()				
				Else
					//***********************************************
					// Deleta linhas deletas ou Delete de entidades *
					//***********************************************
					RecLock("CV0",.F.,.T.)
					DbDelete()
					MsUnLock()
				EndIf
			ElseIf !aColsCV0[nX, Len(aHeaderCV0) +1 ]
				//************************
				// Cria linhas sem recno *
				//************************
				RecLock("CV0",.T.)
				CV0->CV0_FILIAL	:= xFilial(cAlias)
				CV0->CV0_PLANO	:= cPlanoCV0
				aEval(aHeaderCV0, {|x,y| If(x[10]<>"V",CV0->&(x[2]) := aColsCV0[Nx,y],.F.) })
				MsUnLock()
						
			EndIf
		Next
		
	    CV0->(dbSetOrder(1)) //CV0_FILIAL+CV0_PLANO+CV0_CODIGO
	    If CV0->(MsSeek(xFilial("CV0") + cPlanoCV0 ))
	    	While CV0->(!EOF()) .And. CV0->(CV0_FILIAL+CV0_PLANO) == xFilial("CV0") + cPlanoCV0
	    	    If !Empty(CV0->CV0_CODIGO)
		    	    cItem := Soma1(cItem)
		    	    RecLock("CV0",.F.)
					CV0->CV0_ITEM	:= cItem
		    	    MsUnLock()
	    	    EndIf
	    		CV0->(dbSkip())
	    	EndDo  
	    EndIf 
           
		//*******************
		// Fim da Transac�o *
		//*******************	
		End Transaction	
		
	EndIf

Endif

RestArea(aArea)

Return

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Acacio Egas           � Data � 24/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���     
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()
//Local aUsRotina := {}
Local aRotina 	:= {	{ STR0004	,	"AxPesqui"	, 0 , 1, ,.F.},;	//"Pesquisar"
						{ STR0005	,	"CTB050DLG"	, 0 , 2},;			//"Visualizar"
						{ STR0007	,	"CTB050DLG"	, 0 , 4}}			//"Alterar"

Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTB050WHEN�Autor  � Acacio Egas        � Data �  11/24/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Condi��o de altera��o do campo.                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTB050WHEN()

Local lRet		:= .T.
Local cFuncAux	:= FUNNAME()
Local lCTBA800	:= GetMv('MV_CTBCUBE',.F.,"0")=="1" //Define se a tratativa sera para a rotina CTBA800 ou CTBA005/CTBA050

If (!lCTBA800) .And. (cFuncAux == "CTBA050") .And. (Eval(bLinGtd) <= nLinInc)
	lRet := .F.
EndIf

If cFuncAux == "CTBA005"
	If lCTBA800
		lRet := !(M->CT0_ID $ '01|02|03|04') //CTBA800
	Else
		lRet := GdFieldGet('CT0_ALIAS')=='CV0' //CTBA005	
	EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTB050SXB �Autor  � Acacio Egas        � Data �  11/24/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Condi��o de altera��o do campo.                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTB050SXB()

Local lRet		:= .T.
Local cFuncAux	:= FUNNAME()
Local cIdEntid	:= ""
Local cAuxIdEnt := ""
Local nX		:= 0
Local cCodEntid	:= ""
Local lCTBA800	:= (GetMv('MV_CTBCUBE',.F.,"0")=="1")
Local cOrdPerg	:= ""
Local nPosDesc:=0
//"CV0->CV0_PLANO=cPlano .AND. !EMPTY(CV0->CV0_CODIGO) .AND. CV0->CV0_CODIGO<>cCodigo"

If nQtdEntid == NIL
	nQtdEntid:= CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

If Type("cPlano") == "U"
	Private cPlano	:= ""
EndIf	

If Type("cCodigo") == "U"	
	Private cCodigo := ""
EndIf	
Private cSXB	:= "CV01"

If cFuncAux == "CTBA050" .And. (!lCTBA800)
	cPlano  := cPlanoCV0
	cCodigo	:= GdFieldGet("CV0_CODIGO")
	cSXB	:= "CV01"
ElseIf cFuncAux == "CTBA005" .And. (!lCTBA800)
	cSXB	:= "CV02"
Else
	If READVAR() == "M->CT0_ENTIDA" .OR. READVAR() == "CT0->CT0_ENTIDA"
		cSXB	:= "CV02"
	Else
		If (Alltrim(cFuncAux) $ "CTBA290|CTBR051|CTBR403|CTBC403")
			cPlano := ""
		EndIf
        
		If Empty(cPlano)                                  
			If (Alltrim(cFuncAux) $ "CTBR051|CTBR403|PCOA330|CTBC403")
				If ReadVar() $ "AENTIDADES[9]#AENTIDADES[10]"
					cIdEntid := "05"
				ElseIf ReadVar() $ "AENTIDADES[11]#AENTIDADES[12]"
					cIdEntid := "06"
				ElseIf ReadVar() $ "AENTIDADES[13]#AENTIDADES[14]"
					cIdEntid := "07"
				ElseIf ReadVar() $ "AENTIDADES[15]#AENTIDADES[16]"
					cIdEntid := "08"
				ElseIf ReadVar() $ "AENTIDADES[17]#AENTIDADES[18]"
					cIdEntid := "09"
				EndIf

			ElseIf Alltrim(cFuncAux) $ "PCOR200"

				cAuxIdEnt := Right(AllTrim(GetAdvFVal("SX1","X1_VAR01",PadR("PCOR200",Len(SX1->X1_GRUPO))+Right(ReadVar(),2),1,"")),2)
				
				For nX := 5 To nQtdEntid
	         		If StrZero(nX,2) == cAuxIdEnt
	            		cIdEntid := cAuxIdEnt
						Exit
					EndIf
				Next
			ElseIf AllTrim(cFuncAux) $ 'PCOC350|PCOC360' .and. Type('aRelac') =='A'	
				nPosDesc:=aScan(aRelac,{|x|alltrim(x[1])==AllTrim(ReadVar())})
				If nPosDesc > 0
		         		Do Case
		         			Case 'ENT05' $ aRelac[nPosDesc][2]
		            			cIdEntid := '05'
		            		Case 'ENT06' $ aRelac[nPosDesc][2]
		            			cIdEntid := '06'
		            		Case 'ENT07' $ aRelac[nPosDesc][2]
		            			cIdEntid := '07'
		            		Case 'ENT08' $ aRelac[nPosDesc][2]
		            			cIdEntid := '08'
		            		Case 'ENT09' $ aRelac[nPosDesc][2]
		            			cIdEntid := '09'
						EndCase
				Endif
			ElseIf AllTrim(Upper(cFuncAux)) $ 'CTBA420'
				If ReadVar() $ "MV_PAR01#MV_PAR02"
					cIdEntid := "05"
				ElseIf ReadVar() $ "MV_PAR03#MV_PAR04"
					cIdEntid := "06"
				ElseIf ReadVar() $ "MV_PAR05#MV_PAR06"
					cIdEntid := "07"
				ElseIf ReadVar() $ "MV_PAR07#MV_PAR08"
					cIdEntid := "08"
				ElseIf ReadVar() $ "MV_PAR09#MV_PAR10"
					cIdEntid := "09"
				EndIf				
			Else
				//������������������������������������������������Ŀ
				//�Processo para obter o ID da entidade adicional. �
				//��������������������������������������������������
				cAuxIdEnt := Right(Readvar(),6)
				For nX := 5 To nQtdEntid
	         		If StrZero(nX,2) $ cAuxIdEnt
	            		cIdEntid := StrZero(nX,2)
						Exit
					EndIf
				Next
			EndIf
				
			dbSelectArea("CT0")
			dbSetOrder(1)
			If dbSeek(xFilial("CT0") + cIdEntid)
				cPlano := CT0->CT0_ENTIDA
			EndIf
		EndIf
		
		If Type(Readvar())=="U" .OR. ((Alltrim(cFuncAux) $ "CTBA240|CTBA270|CTBA290|PCOA330") .And. ! ( "->" $ ReadVar() ))
			cCodEntid := Space(Len(CV0->CV0_CODIGO))
		Else
			cCodEntid := &(Readvar())
		EndIf
			
		dbSelectArea("CV0")
		dbSetOrder(1)
		dbSeek(xFilial("CV0")+cPlano+cCodEntid)
		If Found() .And. Empty(CV0->CV0_ITEM)
			dbSkip()
		EndIf
		cCodigo	:= Space(Len(CV0->CV0_CODIGO))
		cSXB	:= "CV01"
	EndIf
EndIf

dbSelectArea("CV0")
lRet	:= ConPad1( , , ,cSXB, /*cCampoRet*/,/*lGet*/,.F./*lOnlyView*/,/*cVar*/,/*oGet*/, /*uContent*/)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AutoIncCV0�Autor  � Acacio Egas        � Data �  11/24/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Auto incremento de Entidades Contabeis.                    ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CtbIncCV0()

Local aEstrut	:= {"CV0_FILIAL","CV0_PLANO","CV0_ITEM","CV0_CODIGO","CV0_DESC","CV0_CLASSE","CV0_NORMAL",;
					"CV0_ENTSUP","CV0_BLOQUE","CV0_DTIBLQ","CV0_DTFBLQ","CV0_DTIEXI","CV0_DTFEXI","CV0_CFGLIV",;
					"CV0_LUCPER","CV0_PONTE"}
Local aIncCV0	:= {}
Local nX,nY
Local cCodigo	:= ""

If cPaisLoc $ "COL"

	aAdd(aIncCV0, {xFilial("CV0"),"01","","","N.I.T.","","","","",Ctod(""),dDatabase,Ctod(""),Ctod(""),"","",""} )

ElseIf cPaisLoc $ "PER"

	aAdd(aIncCV0, {xFilial("CV0"),"01","","","R.U.C.","","","","",Ctod(""),dDatabase,Ctod(""),Ctod(""),"","",""} )

ElseIf cPaisLoc == "RUS" .And. SuperGetMv("MV_REDSTORN",.F.,.F.)

	aAdd(aIncCV0, {xFilial("CV0"),"01","","","R.S.A.","","","","",Ctod(""),dDatabase,Ctod(""),Ctod(""),"","",""} )
	cCodigo := Space(Len(CV0->CV0_CODIGO))
	
EndIf

For nX:= 1 to Len(aIncCV0)
	DbSelectArea("CV0")
	DbSetOrder(1)
	If !DbSeek(aIncCV0[nX,1]+aIncCV0[nX,2]+cCodigo)
		RecLock("CV0",.T.)
		For nY := 1 to Len(aEstrut)
			CV0->&(aEstrut[nY])	:= aIncCV0[nX,nY]
		Next
		MsUnLock()
	EndIf
	
Next

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �Ctb050ESup� Autor � Marcelo Akama         � Data � 15/01/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida entidade superior na getdados                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ctb050ESup(cPlano,cEntSup,lHelp)                           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T./.F.                                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Expc1 = Plano                                              ���
���          � Expc2 = Entidade Superior                                  ���
���          � Expl1 = Exibe Help?                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTB050ESup(cPlano,cEntSup,lHelp,cEntAtu)

Local lRet			:= .T.
Local lEntSupGD 	:= .F.
Local aAreaCV0		:= CV0->(GetArea())
Local lCTBA800		:= GetMv('MV_CTBCUBE',.F.,"0")=="1" //Execucao via CTBA800
Local nPosCodEnt	:= IIf(lCTBA800,0,aScan(oGDItens:aHeader,{|x|AllTrim(Upper(x[2]))=="CV0_CODIGO"}))

Default cPlano	:= "01"
Default lHelp	:= .T.
Default cEntAtu	:= IIf(lCTBA800, M->CV0_CODIGO, IIf(nPosCodEnt>0,oGDItens:aCols[oGDItens:nAt][nPosCodEnt],""))

If lCTBA800 //Execucao via CTBA800
	cPlano := M->CV0_PLANO
ElseIf !Empty(cPlanoCV0) //Execucao via CTBA050
	cPlano := cPlanoCV0 //Variavel Private presente nas funcoes CTB050DLG e CTBA800
EndIf

If !Empty(cEntSup)

	If !lCTBA800 //Execucao via CTBA050
		lEntSupGD := (aScan(oGDItens:ACOLS,{|x| AllTrim(x[2]) == AllTrim(cEntSup)})) > 0	//Verifica se o codigo se encontra na GetDados
	EndIf																					//e ainda nao foi gravado na tabela CV0

	If lCTBA800 .Or. !lEntSupGD 
		dbSelectArea("CV0")
		dbSetOrder(1)
		If !dbSeek(xFilial()+cPlano+cEntSup)
			If lHelp
				Help("  ", 1, "NOENTIDA")
			EndIf
			lRet := .F.
		EndIf
		If lRet 
			If CV0->CV0_CLASSE != "1"	// Sintetica
				If lHelp
					Help(" ",1,"NOCLASSE")
				EndIf
				lRet := .F.
			EndIf
		EndIf
		If lRet
			If Alltrim(cEntSup) == Alltrim(cEntAtu)
				MsgAlert(STR0011,STR0009) //"Codigo da entidade superior dever� ser diferente do codigo do entidade posicionada."###"Aten��o"
				lRet := .F.
			EndIf			
		EndIf
	EndIf
EndIf

RestArea(aAreaCV0)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTB050SX3 �Autor  � Microsiga          � Data �  13/05/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Condi��o de altera��o do campo.                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTB050SX3(cCpoSX3)

Local lRet		:= .T.
Local aSaveArea	:= GetArea()
Local aAreaCV0	:= CV0->(GetArea())

Default cCpoSX3 := "" 

If GetMv('MV_CTBCUBE',.F.,"0")=="1" //CTBA800

	dbSelectArea("CV0")

	If Type("cPlnAtu")="C" .And. Type("cCodAtu")="C"
		dbSetOrder(1)
		dbSeek(xFilial("CV0")+cPlnAtu+cCodAtu)
	EndIf

	Do Case
		Case INCLUI .And. cCpoSX3 $ "CV0_PLANO|CV0_ITEM"
			lRet := .F.
		Case ALTERA
			If cCpoSX3 <> "CV0_ENTSUP" .Or. !Empty(CV0->CV0_ENTSUP)	//Permite alterar o campo CV0_ENTSUP
				lRet := .F.												//se nao houver entidade superior
			EndIf
			If cCpoSX3 == "CV0_CLASSE"
				lRet := .F.
			EndIf
	EndCase
	
	If cCpoSX3 == "CV0_ENTSUP"
		lRet := .F.
	EndIf
	
EndIf               

RestArea(aAreaCV0)
RestArea(aSaveArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTB050VlPl�Autor  �Marcos Pires        � Data �  14/03/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida se o plano ja esta cadastrado                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTB050VlPl()
Local lRet		:= .T.
Local aSaveArea	:= GetArea()
Local aSaveCV0	:= CV0->(GetArea())

If INCLUI
	DbSelectArea("CV0")
	DbSetOrder(1)
	If DbSeek(xFilial("CV0")+cPlanoCV0)
		lRet := .F. 
		MsgAlert(STR0010,STR0009) //"Plano j� cadastrado"###"Aten��o"
	EndIf
EndIf

RestArea(aSaveCV0)
RestArea(aSaveArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTB050LOk �Autor  �Marcos R. Pires     � Data �  16/03/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao da linha da GetDados                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTB050LOk()
Local lRet			:= .T.
Local nX			:= 0
Local nLin			:= oGDItens:nAt //Linha posicionada no aCols
Local nPosCodEnt	:= aScan(oGDItens:aHeader,{|x|AllTrim(Upper(x[2]))=="CV0_CODIGO"}) //Posicao do codigo da entidade
Local nPosCodESp	:= aScan(oGDItens:aHeader,{|x|AllTrim(Upper(x[2]))=="CV0_ENTSUP"}) //Posicao do codigo da entidade superior
Local nPosClasse	:= aScan(oGDItens:aHeader,{|x|AllTrim(Upper(x[2]))=="CV0_CLASSE"}) //Posicao da classe da entidade 1-Sintetica 2-Analitica
Local aColsCV0		:= aClone(oGDItens:aCols)

Do Case

	//���������������������������Ŀ
	//�Se a linha estiver deletada�
	//�����������������������������
	Case aColsCV0[nLin][Len(aColsCV0[nLin])]
		Return(lRet)

	//��������������������������������������������������������������
	//�Se o cod. da entidade for igual ao cod. da entidade superior�
	//��������������������������������������������������������������
	Case AllTrim(aColsCV0[nLin][nPosCodEnt]) == AllTrim(aColsCV0[nLin][nPosCodESp])
		lRet := .F.
		MsgAlert(STR0011,STR0009) //"Codigo da entidade superior dever� ser diferente do codigo do entidade posicionada."###"Aten��o"

EndCase

If lRet
	For nX := 1 To Len(aColsCV0)

		Do Case

			//�������������������������������������������������������Ŀ
			//�Para nao avaliar a linha posicionada e linhas deletadas�
			//���������������������������������������������������������
			Case nX == nLin .Or. aColsCV0[nX][Len(aColsCV0[nX])]
				Loop

			//�����������������������������������������������Ŀ
			//�Verifica se o codigo da entidade esta duplicado�
			//�������������������������������������������������
			Case AllTrim(aColsCV0[nX][nPosCodEnt]) == AllTrim(aColsCV0[nLin][nPosCodEnt])
				lRet := .F.
				MsgAlert(STR0012,STR0009) //"C�digo da entidade j� cadastrado"###"Aten��o"
				Exit

			//��������������������������������������������������������������������������Ŀ
			//�Verifica se ha entidade superior e valida a estrutura de analita/sintetica�
			//����������������������������������������������������������������������������
			Case !Empty(aColsCV0[nLin][nPosCodESp]) .And. AllTrim(aColsCV0[nX][nPosCodEnt]) == AllTrim(aColsCV0[nLin][nPosCodESp]) .And.;
					aColsCV0[nX][nPosClasse] == "2"	//Se a entidade superior for analitica
					lRet := .F.						//nao permite que haja entidade inferior
					MsgAlert(STR0013,STR0009) //"Entidade superior inv�lida, confira a classe da conta superior."###"Aten��o"
					Exit
					
			//��������������������������������������������������������������������������Ŀ
			//�Verifica se ha entidade inferior e valida a estrutura de analita/sintetica�
			//����������������������������������������������������������������������������
			Case aColsCV0[nLin][nPosClasse] == "2" .And. AllTrim(aColsCV0[nLin][nPosCodEnt]) == AllTrim(aColsCV0[nX][nPosCodESp])
					lRet := .F.						//nao permite que altera a classe para analitica se houver entidade inferior
					MsgAlert(STR0017,STR0009) //"Classe inv�lida, h� entidade(s) inferior(es) relacionada(s)."###"Aten��o"
					Exit

		EndCase

	Next
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTB050DOk �Autor  �Marcos R. Pires     � Data �  16/03/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida a exclusao de linha da GetDados                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTB050DOk()
Local lRet			:= .T.
Local nX			:= 0
Local nLin			:= oGDItens:nAt //Linha posicionada no aCols
Local nPosCodEnt	:= aScan(oGDItens:aHeader,{|x|AllTrim(Upper(x[2]))=="CV0_CODIGO"}) //Posicao do codigo da entidade
Local nPosCodESp	:= aScan(oGDItens:aHeader,{|x|AllTrim(Upper(x[2]))=="CV0_ENTSUP"}) //Posicao do codigo da entidade superior
Local aColsCV0		:= aClone(oGDItens:aCols)

For nX := 1 To Len(aColsCV0)

	Do Case

		//�������������������������������������������������������Ŀ
		//�Para nao avaliar a linha posicionada e linhas deletadas�
		//���������������������������������������������������������
		Case nX == nLin .Or. aColsCV0[nX][Len(aColsCV0[nX])]
			Loop

		//�������������������������������������������������������������Ŀ
		//�Verifica se a entidade deletada eh superior de outra entidade�
		//���������������������������������������������������������������
		Case AllTrim(aColsCV0[nX][nPosCodESp]) == AllTrim(aColsCV0[nLin][nPosCodEnt])
			lRet := .F.
			MsgAlert(STR0014,STR0009) //"A entidade selecionada possui relacionamento(s) com outra(s) entidade(s)"###"Aten��o"
			Exit

	EndCase

Next
	//Valida��o se a Entidade Adicional CONT�M lan�amentos no PCO atrelados a um lote
	If lRet
		lRet := VldEntPCO("CV0",aColsCV0[nLin][2],cPlanoCV0)
	Endif
	
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBA050TOk�Autor  �Marcos R. Pires     � Data �  16/03/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida o preenchimento do cabecalho e dos itens            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTBA050TOk()
Local lRet := .T.

Do Case

	Case Empty(cPlanoCV0)
		MsgAlert(STR0015) //"Preencha o campo Plano"
		lRet := .F.

	Case Empty(cDescCV0)
		MsgAlert(STR0016) //"Preencha o campo Descri��o"
		lRet := .F.

	Case !oGDItens:TudoOk()
		lRet := .F.
		
EndCase

Return lRet   


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTB050Tab �Autor  �Alvaro Camillo Neto � Data �  04/10/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida a manuten��o da tabela                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTB050Tab(cPlano)
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaCT0 := CT0->(GetArea())

CT0->(dbSetOrder(1)) //CT0_FILIAL+CT0_ID

If CT0->(dbSeek(xFilial("CT0") + cPlano ))
	If Alltrim(CT0->CT0_ALIAS) != "CV0"
		Help("  ",1,"CT050TAB",,STR0018 + CT0->CT0_ALIAS + " . " +STR0019  ,1,0) //"Entidade relacionada a tabela "##"Por favor, utilize o cadastro padr�o desta entidade"
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaCT0)
RestArea(aArea)
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTB050PLANO �Autor  �Felipe Cunha      � Data �  29/08/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Consulta SXB - retorna o codigo do plano da entidade        ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTB050PLANO(cEnt)
Local aArea    := GetArea()
Local aAreaCT0 := CT0->(GetArea())   

//Verifica a existencia da variavel cPlano
If Type("cPlano") == "U"
	Private cPlano	:= ""
EndIf	

//Verifica a existencia da variavel cCodigo
If Type("cCodigo") == "U"	
	Private cCodigo := ""
EndIf	

dbSelectArea("CT0")
dbSetOrder(1)
If dbSeek(xFilial("CT0") + cEnt)
	cPlano := CT0->CT0_ENTIDA
EndIf

RestArea(aAreaCT0)
RestArea(aArea)     
	
Return cPlano
