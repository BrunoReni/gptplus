#include "TMSA800.CH"
#Include "FWMVCDEF.CH"

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  � TMSA800  � Autor �Patricia A. Salomao    � Data �30.06.2003  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Contrato de Fornecedores                                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA800()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � NIL                                                          ���
���������������������������������������������������������������������������Ĵ��
���Uso       � SigaTMS - Gestao de Transporte                               ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
���������������������������������������������������������������������������Ĵ��
���Programador    � Data   � BOPS �  Motivo da Alteracao                    ���
���������������������������������������������������������������������������Ĵ��
���Mauro Paladini �15/10/13�      � Conversao da rotina para MVC            ���
���               �        �      �                                         ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function TMSA800()

Local oBrowse 	:= Nil
Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DUJ")
oBrowse:SetDescription(STR0001) // "Contrato de Fornecedores"
oBrowse:Activate()

Return Nil
 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ModelDef � Autor � Mauro Paladini        � Data �21.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo de dados                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oModel Objeto do Modelo                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function ModelDef()

	Local oModel	:= Nil
	Local oStruCDUJ := FwFormStruct( 1, "DUJ") 
	Local oStruIDVG := FwFormStruct( 1, "DVG")
	Local oStruIDNI

	// Validacoes dos Fields
	Local bPosValid := { |oMdl| PosVldMdl(oMdl) }

	// Validacoes da Grid
	Local bLinePost	:= { |oMdl| PosVldLine(oMdl) }

	oModel:= MpFormMOdel():New("TMSA800",  /*bPreValid*/ , bPosValid , /*bComValid*/ ,/*bCancel*/ )
	oModel:SetDescription(STR0001) 		// "Contrato de Fornecedores"

	oModel:AddFields("MdFieldCDUJ",Nil,oStruCDUJ,/*prevalid*/,,/*bCarga*/)
								
	oModel:SetPrimaryKey({ })

	oModel:AddGrid("MdGridIDVG", "MdFieldCDUJ" /*cOwner*/, oStruIDVG , /*bLinePre*/ , bLinePost , /*bPre*/ , /*bPost*/,  /*bLoad*/)
	oModel:SetRelation( "MdGridIDVG", { { "DVG_FILIAL" , 'xFilial("DVG")'  }, { "DVG_NCONTR", "DUJ_NCONTR" } }, DVG->( IndexKey( 1 ) ) )
	oModel:GetModel("MdGridIDVG"):SetUseOldGrid()

	If AliasInDic("DNI")
		oStruIDNI := FwFormStruct( 1, "DNI")
		oModel:AddGrid("MdGridIDNI", "MdFieldCDUJ" /*cOwner*/, oStruIDNI , /*bLinePre*/ , /*bLinePost*/ , /*bPre*/ , /*bPost*/,  /*bLoad*/)
		oModel:SetRelation( "MdGridIDNI", { { "DNI_FILIAL" , 'xFilial("DNI")'  }, { "DNI_NCONTR", "DUJ_NCONTR" } }, DNI->( IndexKey( 1 ) ) )
		oModel:GetModel( "MdGridIDNI" ):SetUniqueLine( { "DNI_CODOPE", "DNI_CARDID" } )
		oModel:GetModel( "MdGridIDNI" ):SetOptional( .T. )
		oModel:GetModel( "MdGridIDNI" ):SetUseOldGrid()
	EndIf

Return ( oModel )                   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ViewDef  � Autor � Mauro Paladini        � Data �20.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe browse de acordo com a estrutura                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oView do objeto oView                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function ViewDef()

	Local oModel 	 := FwLoadModel("TMSA800")
	Local oView 	 := Nil
	Local oStruCDUJ  := FwFormStruct( 2, "DUJ") 
	Local oStruIDVG  := FwFormStruct( 2, "DVG")
	Local lTemDicDNI := AliasInDic("DNI")
	Local oStruIDNI

	oView := FwFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VwFieldCDUJ', oStruCDUJ , 'MdFieldCDUJ') 
	oView:AddGrid( 'VwGridIDVG', oStruIDVG , 'MdGridIDVG')
	If lTemDicDNI
		oStruIDNI  := FwFormStruct( 2, "DNI")
		oView:AddGrid( 'VwGridIDNI', oStruIDNI , 'MdGridIDNI')
	Endif

	If lTemDicDNI
		oView:CreateHorizontalBox("SUPERIOR",40)
		oView:CreateHorizontalBox("INFERIOR",30)
		oView:CreateHorizontalBox("CARTOES", 30)
	Else
		oView:CreateHorizontalBox("SUPERIOR",40)
		oView:CreateHorizontalBox("INFERIOR",60)
	Endif

	oView:EnableTitleView('VwFieldCDUJ')

	oView:AddIncrementField( 'VwGridIDVG', 'DVG_ITEM' ) 
	If lTemDicDNI
		oView:AddIncrementField( 'VwGridIDNI', 'DNI_SEQUEN' ) 
	EndIf

	oView:SetOwnerView("VwFieldCDUJ","SUPERIOR")

	oView:SetOwnerView("VwGridIDVG","INFERIOR")
	If lTemDicDNI
		oView:SetOwnerView("VwGridIDNI","CARTOES")
	Endif


Return(oView)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Mauro Paladini        � Data �14.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � MenuDef com as rotinas do Browse                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina array com as rotina do MenuDef                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Private aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION "PesqBrw"         OPERATION 1 ACCESS 0    //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TMSA800" OPERATION 2 ACCESS 0    //"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.TMSA800" OPERATION 3 ACCESS 0    //"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.TMSA800" OPERATION 4 ACCESS 0    //"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.TMSA800" OPERATION 5 ACCESS 0    //"Excluir"
                
If ExistBlock("TM800MNU")
	ExecBlock("TM800MNU",.F.,.F.)
EndIf

Return ( aRotina )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PosVldLine  Autor � Mauro Paladini        � Data �14.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Faz a validacao da linha na GRID (LineOk)                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � EXPL1 - Verdadeiro ou Falso                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function PosVldLine(oMld)

	Local lRet 		:= .T.
	Local oModel 	:= FWModelActive()
	Local oModelAtu := oModel:GetModel("MdGridIDVG")

	Private aCols 	:= oModelAtu:aCols
	Private aHeader	:= oModelAtu:aHeader
	Private n		:= oModelAtu:nLine	
	
	lRet := TMSA800LinOk()
	
Return lRet 

/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA800LinOk  � Autor � Patricia A. Salomao  � Data �30.06.2003���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Valida a Linha digitada                                        ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �TMSA800LinOk()                                                 ���
����������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                         ���
����������������������������������������������������������������������������Ĵ��
���Retorno   �Logico                                                         ���
����������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                ���
����������������������������������������������������������������������������Ĵ��
���Programador    � Data   � BOPS �  Motivo da Alteracao                     ���
����������������������������������������������������������������������������Ĵ��
���Mauro Paladini �15/10/13�      � Conversao da rotina para MVC             ���
���               �        �      �                                          ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/

Function TMSA800LinOk()

	Local lRet    := .T.
	Local cTabFre := ""
	Local cTipTab := ""
	Local cTabCar := ""
	Local lAbrCal := DVG->(ColumnPos("DVG_ABRCAL")) > 0
	Local lTipCal := DVG->(ColumnPos("DVG_TIPCAL")) > 0
	
	If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
		//-- Se for Transporte Aereo, sera' permitido informar varias Tabelas de Frete.
		If GdFieldGet("DVG_SERTMS",n) == StrZero(2, Len(DVG->DVG_SERTMS)) .And. GdFieldGet("DVG_TIPTRA",n) == StrZero(2, Len(DVG->DVG_TIPTRA))
			If DVG->(ColumnPos('DVG_TPOPVG')) > 0
				lRet := GDCheckKey( { 'DVG_SERTMS', 'DVG_TIPTRA', 'DVG_TIPVEI', 'DVG_TPOPVG', 'DVG_TABFRE', 'DVG_TIPTAB'}, 4 )
			Else
				lRet := GDCheckKey( { 'DVG_SERTMS', 'DVG_TIPTRA', 'DVG_TIPVEI', 'DVG_TABFRE', 'DVG_TIPTAB'}, 4 )
			EndIf
		Else
			If DVG->(ColumnPos('DVG_TPOPVG')) > 0
				lRet := GDCheckKey( { 'DVG_SERTMS', 'DVG_TIPTRA', 'DVG_TIPVEI', 'DVG_TPOPVG'}, 4 )
			Else
				lRet := GDCheckKey( { 'DVG_SERTMS', 'DVG_TIPTRA', 'DVG_TIPVEI'}, 4 )
			EndIf
		EndIf
	EndIf
	
	If lRet
	
		If !GdDeleted( n )
			cTabFre := GDFieldGet("DVG_TABFRE", n)
			cTipTab := GDFieldGet("DVG_TIPTAB", n)
			cTabCar := GDFieldGet("DVG_TABCAR", n)
	
			If !Empty(cTabCar) .And. !Empty(cTabFre)
				Help("", 1, "TMSA80002") // Utilize apenas uma tabela.
				lRet:= .F.
			EndIf
	
			If lRet .And. Empty(cTabCar) .And. Empty(cTabFre)
				Help("", 1, "TMSA80003") //"Informe a Tabela de Frete Ou a Tabela de Carreteiro"
				lRet:= .F.
			EndIf
	
			If lRet
				DTL->(dbSetOrder(1))
				If (!Empty(cTabFre) .Or. !Empty(cTipTab)) .And. ;
					!DTL->(MsSeek(xFilial('DTL')+cTabFre+cTipTab))
					Help("", 1, "TMSA80004") //Tabela de Frete Nao Cadastrada !!!
					lRet:= .F.
				EndIf

				If lRet .And. lAbrCal .And. FWFldGet("DVG_ABRCAL",n) $ '12'   
					If FwFldGet("DVG_SERTMS",n)  <> StrZero(3,Len(DVG->DVG_SERTMS))
						Help("", 1, "TMSA80009") //A Abrangencia de Calculo deve ser informada apenas para o Servi�o de Transporte de ENTREGA
						lRet:= .F.
					EndIf
				EndIf

				If lRet .And. lTipCal .And. !Empty(FWFldGet("DVG_TIPCAL",n))
					If !Empty(cTabCar) 
						Help("", 1, "TMSA80010") //N�o � permitido informar o 'Tipo de Calculo de Frete' para Tabela de Carreteiro. 
						lRet:= .F.
					EndIf
				EndIf

			EndIf
		EndIf
	
	EndIf

Return lRet


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   � PosVldMdl  � Autor �        Nava        � Data � 15/10/13 ���
��������������������������������������������������������������������������͹��
��� Faz a validacao do model                                    		   ���
��������������������������������������������������������������������������͹��
��� Sintaxe    �                                                           ���
��������������������������������������������������������������������������͹��
��� Parametros �                                         			       ���
��������������������������������������������������������������������������͹��
��� Retorno    � NIL                                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario �                                                           ���
���            �                                                           ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codificacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador    �  Data    � BOPS � Motivo da Alteracao                  ���
��������������������������������������������������������������������������͹��
���Mauro Paladini � 15/10/13 �      � Conversao para padrao MVC            ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function PosVldMdl(oMdl)

	Local aAreaDUJ  := DUJ->(GetArea())
	Local lRet      := .T.
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""         

	Local oModelDUJ := oMdl:GetModel("MdFieldCDUJ")	
	Local dFimVig	  := oModelDUJ:GetValue('DUJ_FIMVIG')
	Local dIniVig	  := oModelDUJ:GetValue('DUJ_INIVIG')
	Local cCodFor   := oModelDUJ:GetValue('DUJ_CODFOR')
	Local cLojFor   := oModelDUJ:GetValue('DUJ_LOJFOR')
	Local cNContr   := oModelDUJ:GetValue('DUJ_NCONTR')	
	
	Local oModel 	:= FWModelActive()
	Local oModelAtu := oModel:GetModel("MdGridIDVG")

	Private aCols 	:= oModelAtu:aCols
	Private aHeader	:= oModelAtu:aHeader
	Private n		:= oModelAtu:nLine		

	If oMdl <> Nil .And. oMdl:GetOperation() == MODEL_OPERATION_DELETE
	
		//�������������������������������������������������������������������������Ŀ
		//�Se existir Carreteiro utilizando o Contrato, nao permite excluir o mesmo �
		//���������������������������������������������������������������������������
		
		cQuery := " SELECT 1 "
		cQuery += "   FROM " + RetSqlName("DTY") + " DTY "
		cQuery += "   WHERE DTY.DTY_CODFOR = '"+DUJ->DUJ_CODFOR+"' "
		cQuery += "     AND DTY.DTY_LOJFOR = '"+DUJ->DUJ_LOJFOR+"' "
		cQuery += "  AND DTY.DTY_DATCTC >= '"+Dtos(DUJ->DUJ_INIVIG)+"' "

		If !Empty(dFimVig)
			cQuery += "  AND DTY.DTY_DATCTC <= '"+Dtos(DUJ->DUJ_FIMVIG)+"' "
		EndIf

		cQuery += "     AND DTY.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		If (cAliasQry)->(!Eof())
			Help( ' ', 1, 'TMSA80006') //"Existe Contrato(s) de Carreteiro(s) utilizando este Contrato..."
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	
	Elseif  oMdl <> Nil .And. oMdl:GetOperation() <> MODEL_OPERATION_DELETE
	
		lRet:= TMSA800LinOK()
	
		//-- Analisa se todos os itens da GetDados estao deletados.
		If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
			Help( ' ', 1, 'OBRIGAT2') //"Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
			Return ( .F. )
		EndIf
		
		If !Empty(dFimVig)

			cQuery := " SELECT COUNT(*) NREG "
			cQuery += "   FROM " + RetSqlName("DTY") + " DTY "
			cQuery += "   WHERE DTY.DTY_CODFOR = '"+DUJ->DUJ_CODFOR+"' "
			cQuery += "     AND DTY.DTY_LOJFOR = '"+DUJ->DUJ_LOJFOR+"' "
			cQuery += "  AND DTY.DTY_DATCTC >= '"+Dtos(dFimVig)+"' "
			cQuery += "     AND DTY.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
			If (cAliasQry)->NREG > 0
				Help( ' ', 1, 'TMSA80007') //Data de vig�ncia inv�lida. Existe(m) Contrato(s) de Carreteiro(s) com data superior a data final de vigencia!
				lRet := .F.
			EndIf
	
			(cAliasQry)->(DbCloseArea())

		EndIf
	
		//���������������������������������������������������������������������������Ŀ
		//� Verifica se existe outro contrato na mesma data de vigencia para o cliente�
		//�����������������������������������������������������������������������������
		If  oMdl <> Nil .And. oMdl:GetOperation() <> MODEL_OPERATION_UPDATE
		
			dbSelectArea("DUJ")
			dbSetOrder(2)
			If lRet .And. DUJ->(MsSeek(xFilial('DUJ')+cCodFor+cLojFor))
	
				Do While !Eof() .And. DUJ->DUJ_FILIAL+DUJ->DUJ_CODFOR+DUJ->DUJ_LOJFOR == xFilial('DUJ')+cCodFor+cLojFor
				If DUJ->DUJ_NCONTR <> cNContr .And.;
				(Empty(DUJ->DUJ_FIMVIG) .Or. ( dIniVig <=DUJ->DUJ_FIMVIG .Or.;
				If(!Empty(dFimVig),dFimVig<=DUJ->DUJ_INIVIG,.F.) ) )
					Help(" ", 1, "TMSA80001") // Ja existe Contrato cadastrado para este Fornecedor ...
					lRet := .F.
					Exit
				EndIf
				DUJ->(dbSkip())
			EndDo
	
			EndIf
		
		EndIf
			
	Endif
	
	RestArea(aAreaDUJ)

Return lRet 



/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA800Val    � Autor � Patricia A. Salomao  � Data �01.07.2003���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao dos campos                                           ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �TMSA800Val()                                                   ���
����������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                         ���
����������������������������������������������������������������������������Ĵ��
���Retorno   �Logico                                                         ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
/*/

Function TMSA800Val()

	Local lRet      := .T.
	Local cTabela   := ""
	Local cTipo     := ""
	Local cCampo    := ReadVar()
	Local cCatTab   := StrZero(2, Len(DTL->DTL_CATTAB)) // Categoria da Tabela : Frete a Pagar 
	Local lTMSA730  := IsInCallStack("TMSA730")  //Gera��o Contrato Fornecedor
	Local oModel 	:= Iif(lTMSA730, Nil, FWModelActive() )
	Local lAchou     := .F.
	Local lTMSOPdg   := SuperGetMV("MV_TMSOPDG",,"0") == "2"
	Local cCodOper   := "01"
	Local cDVG_Sertms:= ""
	
	If cCampo $ 'M->DVG_TABFRE.M->DVG_TIPTAB'

		If cCampo == 'M->DVG_TABFRE'

			cTabela := M->DVG_TABFRE
			// Se a tabela nao for preenchida limpa tb o tipo de tabela
			If Empty(cTabela)
				If lTMSA730
					GDFieldPut( 'DVG_TIPTAB' , Criavar("DVG_TIPTAB",.F.) , n )
				Else	
					oModel:SetValue( "MdGridIDVG" , "DVG_TIPTAB" , Criavar("DVG_TIPTAB",.F.) )
				EndIf	
			EndIf
			If lTMSA730
				cTipo   := GdFieldGet('DVG_TIPTAB',n)				
			Else	
				cTipo   := oModel:GetValue( "MdGridIDVG" , 'DVG_TIPTAB' )
			EndIf	

		ElseIf cCampo == 'M->DVG_TIPTAB'

			cTipo   := M->DVG_TIPTAB
			// Se o tipo nao for preenchido limpa tb a tabela
			If Empty(cTipo)
				If lTMSA730
					GDFieldPut( 'DVG_TABFRE' , Criavar("DVG_TABFRE",.F.) , n )
				Else	
					oModel:SetValue( "MdGridIDVG" , "DVG_TABFRE",Criavar("DVG_TABFRE",.F.) )
				EndIf	
			EndIf

			If lTMSA730
				cTabela := GdFieldGet('DVG_TABFRE',n)
			Else	
				cTabela := oModel:GetValue( "MdGridIDVG" , 'DVG_TABFRE' )
			EndIf	

		EndIf

		If !Empty(cTabela) .And. !Empty(cTipo)
			lRet := TMSTbAtiva( cTabela, cTipo,,, cCatTab, .T.)
		EndIf
	ElseIf cCampo == "M->DVG_OPERAC" 
		If lTMSOPdg
			cDVG_Sertms:= Iif(lTMSA730, GdFieldGet('DVG_SERTMS',n), oModel:GetValue( "MdGridIDVG" , 'DVG_SERTMS' ))

			DEJ->(dbSetOrder(1)) //DEJ_FILIAL+DEJ_CODOPE+DEJ_ITEM
			DEJ->(MsSeek(xFilial("DEJ")+cCodOper))
			While DEJ->(!Eof() .And. DEJ_FILIAL+DEJ_CODOPE == xFilial("DEJ")+cCodOper)
				If	M->DVG_OPERAC == DEJ->DEJ_OPERAC .And. DEJ->DEJ_SERTMS == cDVG_Sertms
					lAchou := .T.
					Exit
				EndIf
				DEJ->(dbSkip())
			EndDo
		EndIf
		If !lAchou
			lRet := .F.
			Help('', 1, 'REGNOIS')
		EndIf
	ElseIf cCampo == "M->DNI_CODOPE"
		lRet := TMSValField('M->DNI_CODOPE',.T.,'DNI_NOMOPE')
		If lRet
			FwFldPut("DNI_NOMOPE", TMSValField('M->DNI_CODOPE',.F.,'DNI_NOMOPE'))
		EndIf

	EndIf

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA800Whe� Autor � Eduardo de Souza      � Data � 23/02/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verificar a permissao da digitacao dos campos.             ���
�������������������������������������������������������������������������Ĵ��
���Sibtaxe   � TMSA800Whe()                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SINCRONIZADOR                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSA800Whe()

	Local lRet   	:= .T.
	Local cCampo 	:= ReadVar()
	Local oModel 	:= FWModelActive()
	
	If cCampo == "M->DVG_TABCAR"
		If !Empty( oModel:GetValue( "MdGridIDVG" , 'DVG_TIPVEI' ) )
			lRet := .F.
		EndIf
	ElseIf cCampo == "M->DVG_ABRCAL"
		//-- Campo habilitado somente para Entrega
		lRet:= oModel:GetValue( "MdGridIDVG" , 'DVG_SERTMS' ) == StrZero(3,Len(DVG->DVG_SERTMS))
	ElseIf cCampo == "M->DVG_TIPCAL"
		lRet:= Empty(oModel:GetValue( "MdGridIDVG" , 'DVG_TABCAR' )) 
	EndIf

Return lRet



