#Include "TMSA501.ch"
#Include 'Protheus.ch'

Static cTMSERP := SuperGetMV("MV_TMSERP",," ")	//-- Condi��o de integra��o com ERP (0 - Protheus, 1 - Datasul)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � TMSA501 � Autor � Valdemar Roberto       � Data �24.03.2017���
�������������������������������������������������������������������������Ĵ��
���Descricao � Insere dados eletronicos no documento fiscal               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA501()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TmsA501()
Local aCores := {}
Local lCont  := .T.

Private cCadastro := STR0001	//-- "Insere dados eletronicos no documento fiscal"
Private aRotina   := MenuDef()

If cTMSERP != "1"
	Help("",1,"TMSA50105")	//-- "Esta funcionalidade somente poder� ser utilizada, com a integra��o com ERP Datasul ativa."
	lCont := .F.
EndIf

If lCont
	AAdd(aCores,{ "Empty(F3_DTCANC)","BR_VERDE"})	//-- N�o Cancelado
	AAdd(aCores,{"!Empty(F3_DTCANC)","BR_VERMELHO"})	//-- Cancelado
	
	Mbrowse(6,1,22,75,"SF3",,,,,,aCores)
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �TmsA500Mnt� Autor � Alex Egydio           � Data �22.07.2002���
�������������������������������������������������������������������������Ĵ��
���Descricao � Manutencao de documentos                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA200Mnt(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSA501Mnt( cAlias, nReg, nOpcx )
Local aAreas   := {DT6->(GetArea()),SFT->(GetArea()),SF3->(GetArea()),DTC->(GetArea()),GetArea()}
Local aVisual  := {}
Local aAltera  := {}
Local aContAnt := {}
Local lCont    := .T.
Local lTSSOK   := .T.
Local nOpca    := 0
//-- Variaveis da tela
Local cSeekSFT := ""
Local oDlgNFE
Local oEmiNFE
Local oHorNFE
Local oChvNFE
Local oCodNFE
//-- Dimensionamento da tela
Local aButtons := {}
Local aSize    := {}
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}

//-- Variaveis da tela
Private dEmiNFE  := SF3->F3_EMINFE
Private cHorNFE  := SF3->F3_HORNFE
Private cChvNFE  := SF3->F3_NFELETR
Private cCodNFE  := SF3->F3_CODNFE

Private aSetKey := {}
Private oDlgNFE

nOpcx := aRotina[nOpcx,4]

If nOpcx == 2
	AxVisual(cAlias,nReg,nOpcx,,,,,)
	lCont := .F.
EndIf

If lCont .And. AllTrim(SF3->F3_ESPECIE) != "RPS"
	Help("",1,"TMSA50106")	//-- "Documento n�o � uma nota fiscal."
	lCont := .F.
EndIf
	
If lCont
	If nOpcx == 8	//-- Autentica��o
		If !Empty(SF3->F3_DTCANC)
			Help("",1,"TMSA50107")	//-- "Documento est� cancelado."
			lCont := .F.
		Else
			DT6->(DbSetOrder(1))
			If !DT6->(DbSeek(xFilial("DT6") + SF3->(F3_FILIAL + F3_NFISCAL + F3_SERIE)))
				Help("",1,"TMSA50108")	//-- "Documento de transporte n�o localizado."
				lCont := .F.
			Else
				If !Empty(SF3->F3_CODRSEF)
					Help("",1,"TMSA50109")	//-- "Documento j� enviado � SEFAZ."
					lCont := .F.
				EndIf
			EndIf
		EndIf
	ElseIf nOpcx == 9	//-- Cancelamento
		If Empty(SF3->F3_DTCANC)
			Help("",1,"TMSA50110")	//-- "Documento n�o est� cancelado."
			lCont := .F.
		Else
			DT6->(DbSetOrder(1))
			If DT6->(DbSeek(xFilial("DT6") + SF3->(F3_FILIAL + F3_NFISCAL + F3_SERIE)))
				Help("",1,"TMSA50111")	//-- "Primeiramente estorne o documento no TMS."
				lCont := .F.
			Else
				If AllTrim(SF3->F3_CODRSEF) == "101"
					Help("",1,"TMSA50112")	//-- "Cancelamento j� enviado � SEFAZ."
					lCont := .F.
				ElseIf Empty(SF3->F3_CODRSEF)
					Help("",1,"TMSA50115")	//-- "N�o � poss�vel enviar o cancelamento de um documento, sem que sua autentica��o tenha sido enviada ao ERP."
					lCont := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If lCont
	//-- Calcula as dimensoes dos objetos.
	aSize  := MsAdvSize(.T.)
	AAdd(aObjects,{100,100,.T.,.T.})
	aInfo  := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj:= MsObjSize(aInfo,aObjects,.T.)

	DEFINE MSDIALOG oDlgNFE TITLE "Informa��es Fiscais" FROM aSize[7]/2,00 TO aSize[6]/2.5,aSize[5]/1.5 PIXEL
		@ 040,006 Say AllTrim(RetTitle("F3_EMINFE")) Size 030,009 Of oDlgNFE Pixel
		@ 039,038 MsGet oEmiNFE Var dEmiNFE Valid NaoVazio(dEmiNFE) .And. Tmsa501Vld() Size 040,009 When (nOpcx == 8) Of oDlgNFE Pixel

		@ 060,006 Say AllTrim(RetTitle("F3_HORNFE")) Size 030,009 Of oDlgNFE Pixel
		@ 059,038 MsGet oHorNFE Var cHorNFE Valid NaoVazio(cHorNFE) .And. Tmsa501Vld() Size 030,009 Valid Picture AllTrim(X3Picture("F3_HORNFE")) When (nOpcx == 8) Of oDlgNFE Pixel

		@ 080,006 Say AllTrim(RetTitle("F3_NFELETR")) Size 030,009 Of oDlgNFE Pixel
		@ 079,038 MsGet oChvNFE Var cChvNFE Valid NaoVazio(cChvNFE) .And. Tmsa501Vld() Size 080,009 When (nOpcx == 8) Of oDlgNFE Pixel

		@ 100,006 Say AllTrim(RetTitle("F3_CODNFE")) Size 030,009 Of oDlgNFE Pixel
		@ 099,038 MsGet oCodNFE Var cCodNFE Valid Tmsa501Vld() Size 080,009 When (nOpcx == 8) Of oDlgNFE Pixel
	ACTIVATE MSDIALOG oDlgNFE CENTERED ON INIT EnchoiceBar(oDlgNFE,{|| nOpca := 1,oDlgNFE:End()},{|| oDlgNFE:End()},,aButtons)

	If nOpca == 1 .And. nOpcx != 2
		Aadd(aContAnt,SF3->F3_EMINFE)
		Aadd(aContAnt,SF3->F3_HORNFE)
		Aadd(aContAnt,SF3->F3_NFELETR)
		Aadd(aContAnt,SF3->F3_CODNFE)
		Aadd(aContAnt,SF3->F3_CODRSEF)

		RecLock("SF3",.F.)
		SF3->F3_EMINFE  := dEmiNFE
		SF3->F3_HORNFE  := cHorNFE
		SF3->F3_NFELETR := cChvNFE
		SF3->F3_CODNFE  := cCodNFE
		SF3->F3_CODRSEF := Iif(nOpcx == 8,"100","101")
		SF3->(MsUnlock())
		
		DT6->(DbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE                                                                                                                         
		If DT6->(DbSeek(xFilial("DT6") + SF3->(F3_FILIAL + F3_NFISCAL + F3_SERIE)))
			RecLock("DT6",.F.)
			DT6->DT6_NFELET := cChvNFE
			DT6->DT6_EMINFE := dEmiNFE
			DT6->DT6_CODNFE := cCodNFE
			SF3->(MsUnlock())

			DTC->(DbSetOrder(1)) //DTC_FILIAL+DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERVIC+DTC_CODPRO+DTC_NUMNFC+DTC_SERNFC
			If DTC->(MsSeek(xFilial("DTC")+DT6->DT6_FILORI+DT6->DT6_LOTNFC+DT6->DT6_CLIREM+DT6->DT6_LOJREM+DT6->DT6_CLIDES+DT6->DT6_LOJDES+DT6->DT6_SERVIC))
				RecLock("DTC",.F.)
				DTC->DTC_NFELET := cChvNFE
				DTC->DTC_EMINFE := dEmiNFE
				DTC->DTC_CODNFE := cCodNFE
				SF3->(MsUnlock())
			EndIf
		EndIf		

		If nOpcx == 8
			SFT->(DbSetOrder(3))
			If SFT->(DbSeek(cSeekSFT := xFilial("SFT") + "S" + SF3->(F3_CLIEFOR + F3_LOJA + F3_SERIE + F3_NFISCAL)))
				Do While SFT->(!Eof()) .And. SFT->(xFilial("SFT") + FT_TIPOMOV + FT_CLIEFOR + FT_LOJA + FT_SERIE + FT_NFISCAL) == cSeekSFT
					RecLock("SFT",.F.)   						
					SFT->FT_EMINFE  := dEmiNFE
					SFT->FT_HORNFE  := cHorNFE
					SFT->FT_NFELETR := cChvNFE
					SFT->FT_CODNFE  := cCodNFE
					SFT->(MsUnLock ())
					SFT->(DbSkip())
				EndDo
			EndIf
		EndIf
		
		lTssOK := TMSAE76()		
		If !lTssOK 
			RecLock("SF3",.F.)
			SF3->F3_EMINFE  := aContAnt[1]
			SF3->F3_HORNFE  := aContAnt[2]
			SF3->F3_NFELETR := aContAnt[3]
			SF3->F3_CODNFE  := aContAnt[4]
			SF3->F3_CODRSEF := aContAnt[5]
			SF3->(MsUnlock())			
		EndIf		
	EndIf

EndIf

AEval(aAreas,{|x| RestArea(x)})

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �Tmsa501Leg� Autor � Valdemar Roberto      � Data �24/03/2017���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe a legenda dos status                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Tmsa501Leg()
Local aLegenda := {{"BR_VERDE"   ,STR0007},;	//-- "N�o Cancelado"
				   {"BR_VERMELHO",STR0008}}		//-- "Cancelado"

BrwLegenda(cCadastro,STR0009,aLegenda)	//-- "Status"

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �Tmsa501Vld� Autor � Valdemar Roberto      � Data �11/04/2017���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida digita��o                                           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Tmsa501Vld(cCampo)
Local lRet := .T.

Default cCampo := ReadVar()

If Upper(AllTrim(cCampo)) == "DEMINFE"
	If dEmiNFe < SF3->F3_EMISSAO
		Help("",1,"TMSA50113")	//-- "Data de autentica��o n�o pode ser menor que a data de gera��o do documento."
		lRet := .F.
	ElseIf dEmiNFe > dDataBase
		Help("",1,"TMSA50114")	//-- "Data de autentica��o n�o pode ser maior que hoje."
		lRet := .F.
	EndIf
ElseIf Upper(AllTrim(cCampo)) == "CHORNFE"
	If !AtVldHora(cHorNFe)
		lRet := .F.
	Else
		If !Empty(SubStr(cHorNFe,5,2)) .And. SubStr(cHorNFe,5,2) > "60"
			Help("",1,"VLDHORA")
			lRet := .F.
		Else
			If dEmiNFe == dDataBase
				If cHorNFe > SubStr(Time(),1,2) + SubStr(Time(),4,2) +SubStr(Time(),7,2)
					Help("",1,"TMSA50116")	//-- "Hora da nota fiscal n�o pode ser maior que a hora atual."
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descricao � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transacao a ser efetuada:                        ���
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef(lVisual,lAlianca)
Private aRotina := {{STR0002,"AxPesqui"  ,0,1,0,.F.},;	//-- "Pesquisar"
					{STR0003,"TmsA501Mnt",0,2,0,Nil},;	//-- "Visualizar"
					{STR0006,"Tmsa501Leg",0,7,0,Nil},;	//-- "Legenda"
					{STR0004,"Tmsa501Mnt",0,8,0,Nil},;	//-- "Autentica��o"
					{STR0005,"Tmsa501Mnt",0,9,0,Nil}}	//-- "Cancelamento"

Return (aRotina)
