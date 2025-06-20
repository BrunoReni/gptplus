#INCLUDE "PROTHEUS.CH"
#INCLUDE "QDOA010.CH"
#INCLUDE "TOTVS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � QDOA010    � Autor � Aldo Marini Junior � Data � 24/04/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Cadastro de Assuntos                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � QDOA010()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � SIGAQDO                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���   Data   �  BOPS  � Programador � Alteracao                           ���
�������������������������������������������������������������������������Ĵ��
���15/03/02  �  META  � Eduardo S.  � Refeita a rotina utilizando Enchoice���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function MenuDef()

Local aRotina  := {{OemToAnsi(STR0001),"AxPesqui",	 0, 1,,.F.},; // 'Pesquisar'
				   {OemToAnsi(STR0002),"QD010Telas", 0, 2},;      // 'Visualizar'
				   {OemToAnsi(STR0003),"QD010Telas", 0, 3},;      // 'Incluir'
				   {OemToAnsi(STR0004),"QD010Telas", 0, 4},;      // 'Alterar'
				   {OemToAnsi(STR0005),"QD010Telas", 0, 5} }      // 'Excluir'

Return aRotina


Function QDOA010()

Private aRotina   := MenuDef()
Private cCadastro := OemToAnsi(STR0006) // 'Cadastro de Assuntos'

DbSelectArea("QD3")
DbSetOrder(1)
DbGoTop()
mBrowse(006,001,022,075,"QD3")

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QD010Telas� Autor � Eduardo de Souza      � Data � 15/03/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela Cadastro de Assuntos                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QD010Telas(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Alias do arquivo                                   ���
���          � ExpN1 - Numero do registro                                 ���
���          � ExpN2 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQDO                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QD010Telas(cAlias,nReg,nOpc)

Local nI     := 0
Local nOpcao := 0
Local oDlg   := NIL

Private aGETS      := {}
Private aTELA      := {}
Private bCampo     :={|nCPO| Field( nCPO ) }
Private lFwExecSta := FindClass( Upper("FwExecStatement") )

DbSelectArea("QD3")
DbSetOrder(1)

If nOpc == 3 
   For nI := 1 To FCount()
       cCampo := Eval( bCampo, nI )
       lInit  := .F.
       If ExistIni( cCampo )
          lInit := .T.
          M->&( cCampo ) := InitPad( GetSx3Cache(cCampo,"X3_RELACAO") )
          If ValType( M->&( cCampo ) ) = "C"
             M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo,"X3_TAMANHO") )
          EndIf
          If M->&( cCampo ) == Nil
             lInit := .F.
          EndIf
       EndIf
       If !lInit
          M->&( cCampo ) := FieldGet( nI )
          If ValType( M->&( cCampo ) ) = "C"
             M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
          ElseIf ValType( M->&( cCampo ) ) = "N"
             M->&( cCampo ) := 0
          ElseIf ValType( M->&( cCampo ) ) = "D"
             M->&( cCampo ) := CtoD( "  /  /  " )
          ElseIf ValType( M->&( cCampo ) ) = "L"
             M->&( cCampo ) := .f.
          EndIf
       EndIf
   Next nI
	M->QD3_FILIAL:= xFilial("QD3") 
Else
   For nI := 1 To FCount()
       M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
   Next nI
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) FROM 000,000 TO 385,625 OF oMainWnd PIXEL //"Cadastro de Assuntos"

Enchoice("QD3",nReg,nOpc,,,,,{030,002,190,312})

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela),(nOpcao:= 1,oDlg:End()),)},{|| oDlg:End()}) CENTERED

If nOpc <> 2 .And. nOpcao == 1
	If nOpc == 3 .Or. nOpc == 4
		QDA010GAss(nOpc)	
	ElseIf nOpc == 5
		QDA010Dele()
	EndIf
EndIf

If ExistBlock("QD010FIM")
	ExecBlock("QD010FIM",.F.,.F.,{nOpcao,nOpc})
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QDA010GAss� Autor � Eduardo de Souza      � Data � 15/03/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Assuntos                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QDA010GAss(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao do Browse                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQDO                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QDA010GAss(nOpc)

Local lRecLock:= .F.
Local nI      := 0

If nOpc == 3
	lRecLock:= .T.
EndIf

Begin Transaction
	RecLock("QD3",lRecLock)
	For nI := 1 TO FCount()
		FieldPut(nI,M->&(Eval(bCampo,nI)))
	Next nI
	MsUnLock()      
End Transaction
	
Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � QDA010Dele � Autor � Aldo Marini Junior � Data � 24/04/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Exclusao de registros do Cadastro de Assuntos             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � QDA010Dele()                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � SIGAQDO                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QDA010Dele()

	Local cAliasQDC  := GetNextAlias()
	Local cAliasQDH  := GetNextAlias()
	Local cCodAssun  := QD3->QD3_CODASS
	Local cFilQDCQD3 := ""
	Local cFilQDHQD3 := ""
	Local cQuery     := ""
	Local lQDCAchou  := .F.
	Local lQDHAchou  := .F.
	Local oExec      := Nil
	Local oQLTQueryM := QLTQueryManager():New()

	cFilQDCQD3 := oQLTQueryM:MontaQueryComparacaoFiliaisComValorReferencia("QDC", "QDC_FILIAL", "QD3", QD3->QD3_FILIAL)
	cFilQDHQD3 := oQLTQueryM:MontaQueryComparacaoFiliaisComValorReferencia("QDH", "QDH_FILIAL", "QD3", QD3->QD3_FILIAL)

	Default lFwExecSta := .F. //Para facilitar a cobertuar de c�digo n�o declarar essa variavel na user function

	If !lFwExecSta
		//Verifica se tem registros na QDH
		cQuery := " SELECT QDH.R_E_C_N_O_ "
		cQuery +=   " FROM " + RetSqlName("QDH") + " QDH "
		cQuery +=  " WHERE (QDH.QDH_CODASS = '" + cCodAssun + "' "
		cQuery +=      " OR QDH.QDH_CODAS1 = '" + cCodAssun + "' "
		cQuery +=      " OR QDH.QDH_CODAS2 = '" + cCodAssun + "' "
		cQuery +=      " OR QDH.QDH_CODAS3 = '" + cCodAssun + "' "
		cQuery +=      " OR QDH.QDH_CODAS4 = '" + cCodAssun + "' ) "
		cQuery +=     " AND " + cFilQDHQD3 "
		cQuery +=     " AND QDH.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQDH)

		//Verifica se tem registros na QDC
		cQuery := " SELECT QDC.R_E_C_N_O_ "
		cQuery +=   " FROM " + RetSqlName("QDC") + " QDC "
		cQuery +=  " WHERE QDC.QDC_CODASS = '" + cCodAssun + "' " 
		cQuery +=    " AND " + cFilQDCQD3 "
		cQuery +=    " AND QDC.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQDC)

	Else
		//Verifica se tem registros na QDH
		cQuery := " SELECT QDH.R_E_C_N_O_ "
		cQuery +=   " FROM " + RetSqlName("QDH") + " QDH "
		cQuery +=  " WHERE (QDH.QDH_CODASS = ? " 
		cQuery +=      " OR QDH.QDH_CODAS1 = ? " 
		cQuery +=      " OR QDH.QDH_CODAS2 = ? " 
		cQuery +=      " OR QDH.QDH_CODAS3 = ? " 
		cQuery +=      " OR QDH.QDH_CODAS4 = ? ) "
		cQuery +=     " AND ? "
		cQuery +=     " AND QDH.D_E_L_E_T_ = ' ' "
		oExec := FwExecStatement():New(cQuery)
		oExec:setString( 1, cCodAssun )
		oExec:setString( 2, cCodAssun )
		oExec:setString( 3, cCodAssun )
		oExec:setString( 4, cCodAssun )
		oExec:setString( 5, cCodAssun )
		oExec:setUnsafe( 6, cFilQDHQD3 )
		cAliasQDH := oExec:OpenAlias()
		oExec:Destroy()
		oExec := nil 

		//Verifica se tem registros na QDC
		cQuery := " SELECT QDC.R_E_C_N_O_ "
		cQuery +=   " FROM " + RetSqlName("QDC") + " QDC "
		cQuery +=  " WHERE QDC.QDC_CODASS = ? "
		cQuery +=    " AND ? "
		cQuery +=    " AND QDC.D_E_L_E_T_ = ' ' "
		oExec := FwExecStatement():New(cQuery)
		oExec:setString( 1, cCodAssun )
		oExec:setUnsafe( 2, cFilQDCQD3)
		cAliasQDC := oExec:OpenAlias()
		oExec:Destroy()
		oExec := nil 
		
	EndIf

	If &(cAliasQDH+"->(!Eof())")
		lQDHAchou := .T.
	EndIf
	&(cAliasQDH+"->(DbCloseArea())")

	If &(cAliasQDC+"->(!Eof())")
		lQDCAchou := .T.
	EndIf
	&(cAliasQDC+"->(DbCloseArea())")

	If !lQDHAchou .AND. !lQDCAchou
		Begin Transaction
			QD3->(RecLock("QD3",.F.))
				QD3->(DbDelete())
			QD3->(MsUnlock())
		End Transaction   
		QD3->(DbSkip())
	Else
		IF lQDHAChou .OR. lQDCAChou
			Help(" ",1,"QD_DCTOEXT") // Existe documentos cadastrados associados a esta informacao.
		ENDIF
	EndIf

Return
