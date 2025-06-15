#INCLUDE "GEMA010.ch"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GEMA010   �Autor  �Telso Carneiro      � Data �  28/01/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de unidades                                       ���
���          �                                                            ���
w�������������������������������������������������������������������������͹��
���Uso       � SIGAGEM                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function GEMA010( cAlias,nReg ,nCallOpcx ,aGetCpos, lWzd )

Local aCores     
Local aArea := GetArea()

Private lWizard  := .F.
Private lRetorno := .F.
Private cCadastro:= OemToAnsi(STR0001) //'Cadastro de Unidades'
Private aRotina  := MenuDef()
					 
Default lWzd := .F.
lWizard := lWzd

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

aCores:= {{'LIQ->LIQ_STATUS == "LV"','ENABLE'    },; // "LIVRE"
          {'LIQ->LIQ_STATUS == "RE"','BR_AMARELO'},; // "RESERVADO"
          {'LIQ->LIQ_STATUS == "CA"','DISABLE'   },; // "CONTRATO ASSINADO"
          {'LIQ->LIQ_STATUS == "ES"','BR_AZUL'   },; // "ESCRITURADO"
          {'LIQ->LIQ_STATUS == "RT"','BR_CINZA'  },; // "RESERVA TECNICA"
          {'LIQ->LIQ_STATUS == "SD"','BR_LARANJA'},; // "SUSPENSO EM DEFINITIVO"
          {'LIQ->LIQ_STATUS == "ST"','LIGHTBLU'  },; // "SUSPENSO TEMPORARIAMENTE"
          {'!LIQ->LIQ_STATUS $ "CA.ES.LV.RE.RT.SD.ST"','BR_PRETO'}} // "OUTROS"

If nCallOpcx <> NIL 
	GM010Telas(cAlias,nReg,nCallOpcx,,,aGetCpos)

Else
	DbSelectArea("LIQ")
	LIQ->(dbSetOrder(1)) //LIQ_FILIAL+LIQ_COD
	DbGoTop()

	mBrowse(006,001,022,075,"LIQ",,,,,, aCores)
EndIf

restArea(aArea)

Return lRetorno

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GM010Telas� Autor � Telso Carneiro        � Data � 28/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela Cadastro de Empreendimentos                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GM010Telas(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Alias do arquivo                                   ���
���          � ExpN1 - Numero do registro                                 ���
���          � ExpN2 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGEM                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function GM010Telas(cAlias,nReg,nOpc,XReserv,YReserv,aGetCpos)

Local oDlg
Local oGetEmp
Local aCampos := {}
Local nCount  := 0
Local nNivel  := 0
Local nI      := 0
Local nX      := 0
Local nOpcao  := 0            
Local nPosCpo := 0
Local aSize	  := MsAdvSize()
Local aArea   := GetArea()
Local lReturn := .F.
Local cUnidade := ""
Local aMask := {}
Local lGrava := .F.

Private bCampo:= {|nCPO| Field( nCPO ) }
Private aTELA[0][0]
Private aGETS[0]

RegToMemory( "LIQ", nOpc == 3 )

//��������������������������������������������������������������������Ŀ
//� Tratamento do array aGetCpos com os campos Inicializados do AF9    �
//����������������������������������������������������������������������
If aGetCpos <> Nil
	aCampos	:= {}
	dbSelectArea("SX3")
	dbSetOrder(1) // X3_FILIAL +X3_CAMPO
	dbSeek("LIQ")
	While !Eof() .and. SX3->X3_ARQUIVO == "LIQ"
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nPosCpo	:= aScan(aGetCpos,{|x| x[1]==Alltrim(X3_CAMPO)})
			If nPosCpo > 0
				If aGetCpos[nPosCpo][3]
					aAdd(aCampos,AllTrim(X3_CAMPO))
				EndIf
			Else
				aAdd(aCampos,AllTrim(X3_CAMPO))
			EndIf
		EndIf
		dbSkip()
	End
	For nx := 1 to Len(aGetCpos)
		cCpo	:= "M->"+Trim(aGetCpos[nx][1])
		&cCpo	:= aGetCpos[nx][2]
	Next nx
EndIf

If nOpc == 3
	If LIQ->(FieldPos("LIQ_NIVEL")) > 0
		M->LIQ_NIVEL := T_GEMNivelUn(M->LIQ_CODEMP, M->LIQ_STRPAI)
	EndIf
EndIf

If !(nOpc == 3)
	// obtem o codigo
	cUnidade := T_GEMLIQUNI( M->LIQ_CODEMP ,M->LIQ_STRPAI ,M->LIQ_COD )
	M->LIQ_UNID := cUnidade 
EndIf


//������������������������������������������������������Ŀ
//� Faz o calculo automatico de dimensoes de objetos     �
//��������������������������������������������������������
aSize := MsAdvSize(,.F.,400)
aObjects := {} 

AAdd( aObjects, { 100, 100 , .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

If lWizard
	cTitle := STR0010 //"Cadastro de Multiplas Unidades"
Else
	cTitle := STR0001 //"Cadastro de Unidades"
Endif

DEFINE FONT oFntVerdana NAME "Verdana" SIZE 0, -10 BOLD
DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitle) FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

oGetEmp:=MsMGet():New("LIQ",nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg)
oGetEmp:oBox:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| iIf( (nOpc == 5 .and. VldExcl(nOpc == 5)) .OR. (Obrigatorio(aGets,aTela).And.T_GEMA143Vld(lWizard)) ; 
                                                        ,(nOpcao:= 1,oDlg:End()) ;
                                                        ,)},{|| nOpcao:= 2, oDlg:End()}) CENTERED

If nOpc <> 2 .And. nOpcao == 1
	If !lWizard
		If nOpc == 3 .Or. nOpc == 4
			lGrava := GMA010Gra(nOpc)	
		ElseIf nOpc == 5
			GMA010Dele()
		EndIf
	Endif
	lReturn := .T.
EndIf
                   
If __lSX8
	If nOpcao == 1
		ConfirmSX8()
	Else
		RollBackSX8()
	Endif
Endif

RestArea(aArea)

lRetorno := lReturn
Return( lReturn )

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �VldExcl   � Autor � Reynaldo Miyashita    � Data � 28/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se unidade pode ser excluida                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � VldExcl(lExclui)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Se � evento de exclusao                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGEM                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function VldExcl( lExclui )
Local lOk := .T.
	If lExclui
		//
		If LIQ->LIQ_STATUS == "RE" .OR. LIQ->LIQ_STATUS == "CA"
			MsgAlert(STR0020) //"Unidade n�o pode ser excluida. Existe reserva ou com contrato assinado." 
			lOk := .F.
		EndIf
	EndIf
Return( lOk )

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GMA010Gra � Autor � Telso Carneiro        � Data � 28/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Empreendimentos                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GMA010Gra(ExpN1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao do Browse                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGEM                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function GMA010Gra(nOpc)

Local lRecLock:= .F.
Local lReCalc := .F.
Local nI      := 0
Local cCodigo := ""
Local dHabite := stod("")
Local aArea   := GetArea()
Local lContrOK:= .T.

cCodigo := allTrim(M->LIQ_COD)

If !Empty(cCodigo)

	If (nOpc == 3)
		M->LIQ_COD := cCodigo+M->LIQ_UNID
	EndIf
	
	DbSelectArea("LIQ")
	LIQ->(dbSetOrder(1)) //LIQ_FILIAL+LIQ_COD
	
	If LIQ->LIQ_STATUS == "CA" .AND. (LIQ->LIQ_PREVHB <> M->LIQ_PREVHB .or. LIQ->LIQ_HABITE <> M->LIQ_HABITE )
		lReCalc := .T.
	EndIf
	
	Begin Transaction
	
		lRecLock := (nOpc == 3)
		
		M->LIQ_FILIAL := xFilial("LIQ")
		
		RecLock("LIQ",lRecLock)
		For nI := 1 TO FCount()
			FieldPut(nI,M->&(Eval(bCampo,nI)))
		Next nI
	
		If lReCalc	
			dbSelectArea("LIU")
			dbSetOrder(2) // LIU_FILIAL + LIU_CODEMP
			If dbSeek(xFilial("LIU")+LIQ->LIQ_COD)
				While lContrOK
					dbSelectArea("LIT")
					dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
					If dbSeek(xFilial("LIT")+LIU->LIU_NCONTR)
						If LIT->LIT_STATUS <> "5"
							lContrOK := .F.
							dHabite := iIf( Empty(LIQ->LIQ_HABITE) ,LIQ->LIQ_PREVHB ,LIQ->LIQ_HABITE )
							t_GMPRCContr( dHabite ,,LIT->(Recno()) )
						Else
							dbselectarea("LIU")
							LIU->(dbSkip())
						Endif
					EndIf
				EndDo
			EndIf
		EndIf
		
		MsUnLock()
		
	End Transaction
EndIf

RestArea(aArea)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � GMA010Dele � Autor � Telso Carneiro     � Data � 28/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Exclusao de registros do Cadastro de Empreendimentos      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � GMA010Dele()                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � SIGAGEM                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function GMA010Dele()

Local lReturn := .T.
Local aArea   := GetArea() 

//������������������������������Ŀ
//�Criar Verificacoes Necessarias�
//��������������������������������

If lReturn
	dbSelectArea("LIQ")
	Begin Transaction
		RecLock("LIQ",.F.)
			LIQ->(DbDelete())
		MsUnlock()			
	End Transaction   
	LIQ->(DbSkip())	
EndIf                     

RestArea(aArea)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GEMA010Lege� Autor � Eduardo de Souza     � Data �14/01/2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe a legenda da Agenda   								  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GEMA010Lege()											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function GM010Lege()

Local aCont := {} // ComboSX5("IT",.F.)
Local aArea := GetArea()
Local cChave := ""

dbSelectArea("SE5")
SX5->(dbSetOrder(1)) // E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ
If SX5->( dbSeek( xFilial("SX5")+"IT" ) )
	While SX5->(!EOF()) .AND.  SX5->X5_FILIAL+SX5->X5_TABELA == xFilial("SX5")+"IT"
	            
		cChave := alltrim(SX5->X5_CHAVE)
	
		Do Case
			Case cChave == "CA"
				aAdd( aCont ,{"DISABLE"	  ,SX5->X5_DESCRI }) // "CONTRATO ASSINADO" 
			Case cChave == "ES"
				aAdd( aCont ,{"BR_AZUL"	  ,SX5->X5_DESCRI }) // "ESCRITURADO
			Case cChave == "LV"
				aAdd( aCont ,{"ENABLE" 	  ,SX5->X5_DESCRI }) // "LIVRE"
			Case cChave == "RE"
				aAdd( aCont ,{"BR_AMARELO",SX5->X5_DESCRI }) // "RESERVADO"   						       				
			Case cChave == "RT"
				aAdd( aCont ,{"BR_CINZA"  ,SX5->X5_DESCRI }) // "RESERVA TECNICA"
			Case cChave == "SD"
				aAdd( aCont ,{"BR_LARANJA",SX5->X5_DESCRI }) // "SUSPENSO EM DEFINITIVO"   						       				
			Case cChave == "ST"
				aAdd( aCont ,{"LIGHTBLU"  ,SX5->X5_DESCRI }) // "SUSPENSO TEMPORARIAMENTE"
			Otherwise
				aAdd( aCont ,{"BR_PRETO"  ,SX5->X5_DESCRI }) // "Outros"
		EndCase
		SX5->(dbSkip())
	EndDo
EndIf

If ! empty(aCont)
	BrwLegenda(cCadastro,OemToAnsi(STR0007),aCont) //'Legenda'
Else
	Alert(STR0011) //"As legendas n�o encontrado. Verifique."
EndIf   						       				

RestArea( aArea )

Return( .T. )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GM010Vld  �Autor  �Telso Carneiro      � Data �  02/02/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valid no campo LIQ_STATUS para nao trocar o Status         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SX3 (X3_VALID) 			                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/        

Template Function GM010Vld(cStatus)
Local lRet:=.T.

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

If LIQ->LIQ_STATUS <> cStatus .AND. LIQ->LIQ_STATUS=="CA"
	MSGALERT(STR0009) //"Status nao pode ser Alterado!"
	lRet:=.F.
Endif

Return(lRet)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GMA010EDTV� Autor � Reynaldo Miyashita    � Data � 14.06.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao do codigo da EDT digitada.                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAGEM                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function GMA010EDTVld()

Local lRet	:= .F.
Local aArea		:= GetArea()
Local aAreaAF8	:= AF8->(GetArea())
Local cContVar	:=	&(ReadVar())

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

AF8->(dbSetOrder(1)) // AF8_FILIAL+AF8_PROJET+AF8_DESCRI
If AF8->(dbSeek(xFilial("AF8")+M->LIQ_PMSPRJ ))
	If AllTrim(ReadVar())=="M->LIQ_PMSEDT"
		AFC->(dbSetOrder(1)) // AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDT+AFC_ORDEM
		If AFC->(dbSeek(xFilial("AFC")+AF8->AF8_PROJET+AF8->AF8_REVISA+cContVar))
			If AFC->AFC_FATURA == "1"
				lRet := .T.
			Else
				HELP("   ",1,"VLDEDTFAT")
			EndIf
		EndIf
	EndIf
Else
	HELP("   ",1,"EXISTCPO")
EndIf

RestArea(aAreaAF8)
RestArea(aArea)
Return lRet



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GMA010Unid�Autor  �Reynaldo Miyashita  � Data �  31.01.06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida o campo unidade                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAGEM                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GMA010Unid()
Local lRet := .T.
Local aAreaLIQ := LIQ->(GetArea())
Local aAreaLK3 := LK3->(GetArea())
Local aAreaLK5 := LK5->(GetArea())

	////////////////////
	// vazia o codigo da unidade
	If Empty(M->LIQ_Unid)
		lRet := .F.
		MsgAlert( STR0012, STR0013 ) //"O Codigo da Unidade n�o foi preenchido"###"Aten��o"
	Endif
	
	////////////////////////////////////
	// Valida se respeita tam da mascara
	If lRet
		dbSelectArea("LK3")
		dbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI
		If dbSeek(xFilial("LK3")+M->LIQ_CODEMP )    
			dbSelectArea("LK5")
			dbSetOrder(1) // LK5_FILIAL+LK5_CODEMP+LK5_NIVEL
			If dbSeek(xFilial("LK5")+M->LIQ_CODEMP+M->LIQ_STRPAI )
				
				aMask := T_GEMMascCnf( LK3->LK3_MASCAR )
			
				nPosMask := aScan( aMask[2] ,{|x| x[1] == Val(LK5->LK5_NIVEL)+1 })
				
				If nPosMask > 0
					// saber o nivel
					nTam  := aMask[2][nPosMask][2]
					If Len( Alltrim(M->LIQ_Unid) ) <> nTam
						lRet := .F.
						MsgAlert(STR0014+; //"O Codigo da Unidade sera valido quando possuir exatamente"
								 " "+Alltrim(Str(nTam,0))+STR0015,STR0013 ) //" digito(s)"###"Aten��o"
					EndIf
				Else
					MsgAlert(STR0016,STR0013 ) //"A mascara do empreendimento n�o foi encontrado."###"Aten��o"
					lRet := .F.
				EndIf
			Else
				MsgAlert(STR0017,STR0013 ) //"O Codigo da estrutura referente n�o foi encontrado."###"Aten��o"
				lRet := .F.
			Endif
		Else
			MsgAlert(STR0018,STR0013 ) //"O Empreendimento n�o foi encontrado."###"Aten��o"
			lRet := .F.
		Endif
	Endif
	///////////////////////
	// Verifica duplicidade
	If lRet
		cCodigo := AllTrim(M->LIQ_COD)
		dbSelectArea("LIQ")
		dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
		If MsSeek( xFilial("LIQ")+cCodigo+M->LIQ_Unid )
			lRet := .F.
			MsgAlert(STR0019,STR0013 ) //"J� existe uma unidade com o mesmo codigo."###"Aten��o"
		Endif
	Endif                

RestArea( aAreaLK5 )
RestArea( aAreaLK3 )
RestArea( aAreaLIQ )

Return( lRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GEMLIQUNI �Autor  �Reynaldo Miyashita  � Data �  31.01.06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Obtem o unidade no campo LIQ_COD, atraves do codigo do     ���
���          � empreendimento com o codigo da estrutura.                  ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAGEM                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function GEMLIQUNI( cCodEmpr ,cStruct ,cCodigo )

Local aMask    := {}
Local cUnidade := ""
Local nNivel   := 0
Local nCount   := 0
Local aArea    := GetArea()
Local aAreaLK3 := LK3->(GetArea())
Local aAreaLK5 := LK5->(GetArea())
	
	// empreendimento
	dbSelectArea("LK3")
	dbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI
	If dbSeek(xFilial("LK3")+cCodEmpr)
		// formato da mascara
		aMask := T_GEMmascCnf( LK3->LK3_MASCAR )
		
		// estrutura
		dbSelectArea("LK5")
		dbSetOrder(1) // LK5_FILIAL+LK5_CODEMP+LK5_STRUCT
		If dbSeek(xFilial("LK5")+cCodEmpr+cStruct)
			nNivel  := val(LK5->LK5_NIVEL)
			nInicio := 1
			For nCount := 1 To nNivel
				// tamanho
				nInicio += aMask[2][nCount][2]
				nInicio += Len(Alltrim(aMask[2][nCount][3]))
			Next nCount

			If Len(aMask[2])>= nNivel+1
				cUnidade := SubStr( cCodigo,nInicio,aMask[2][nNivel+1][2] )
			EndIf

		EndIf
	EndIf
	
RestArea(aAreaLK5)
RestArea(aAreaLK3)
RestArea(aArea)

Return( cUnidade )

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Reynaldo Miyashita     � Data �11/04/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina 	:= {}

	aRotina 	:= {{OemToAnsi(STR0002),"AxPesqui"  , 0, 1,,.F.},;  //'Pesquisar'
	                {OemToAnsi(STR0003),"GM010Telas", 0, 2},;  //'Visualizar'
					{OemToAnsi(STR0004),"GM010Telas", 0, 3},;  //'Incluir'
					{OemToAnsi(STR0005),"GM010Telas", 0, 4},;  //'Alterar'
					{OemToAnsi(STR0006),"GM010Telas", 0, 5},;  //'Excluir'
					{OemToAnsi(STR0007),"GM010Lege" , 0, 6,,.F.}}  //'Legenda'

Return aRotina      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GM010Chk  �Autor  �Marcos R. Pires     � Data �  08/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valid no campo LIQ_STATUS para nao selecionar o Status "CA"���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SX3 (X3_VALID                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/        

Template Function GM010Chk(cStatus)
Local lRet := .T.

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

If cStatus == "CA"
	MSGALERT(STR0021) //"Status v�lido somente quando h� contrato amarrado a unidade!"
	lRet := .F. 
Endif

Return(lRet)
