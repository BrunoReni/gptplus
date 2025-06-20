#include "PROTHEUS.CH"
#include "PLSA460.CH"
#include "PLSMGER.CH"
#INCLUDE "FWBROWSE.CH"

STATIC oBrwBE2	:= NIL
STATIC lRet090 	:= .F.
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA460 � Autor � Tulio Cesar            � Data � 11.01.03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Liberacao Especial                                         ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA460()
LOCAL cFiltro			:= ""
PRIVATE aRotina   	:= MenuDef()
PRIVATE cCadastro 	:= STR0039 //"Liberacao Especial"

//���������������������������������������������������������������������������
//� Seleciona area e idx
//���������������������������������������������������������������������������
DbSelectArea("BE2")
BE2->(DbSetOrder(1))
//��������������������������������������������������������������������������Ŀ
//� Monta filtro para trazer as autorizacoes nao autorizadas...              �
//����������������������������������������������������������������������������
cFiltro := "BE2->BE2_FILIAL == '" + BE2->(xFilial("BE2")) + "' .and. BE2->BE2_NEGADA != '1' .and. BE2->BE2_STATUS == '0' .and. BE2->BE2_AUDITO != '1' .and. BE2->BE2_LIBESP == '1'"

if ExistBlock( "PL460FIL" )
	cFiltro := ExecBlock( "PL460FIL", .F., .F., {cFiltro} )
endIf 
//���������������������������������������������������������������������������
//� Browse
//���������������������������������������������������������������������������
oBrwBE2 := FWmBrowse():New()
oBrwBE2:SetAlias( 'BE2' )
oBrwBE2:SetDescription( cCadastro ) 
oBrwBE2:SetFilterDefault( cFiltro )  

oBrwBE2:Activate()
//���������������������������������������������������������������������������
//� Fim da Rotina Principal...                                               
//���������������������������������������������������������������������������
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLSA460NUS � Autor � Tulio               � Data � 04.06.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Exibe nome do usuario no INIBRW BE2_NOMUSR                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA460NUs()
//���������������������������������������������������������������������������
//� Futuramente esta funcao pode ser excluida pois o nome do usuario ja esta gravado na BE2 e B02
//���������������������������������������������������������������������������
Return("")
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLSA460NRA � Autor � Tulio               � Data � 04.06.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Exibe nome da RDA no INIBRW BE2_NOMRDA                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA460NRA()
Return(Posicione("BAU",1,xFilial("BAU")+BE2->BE2_CODRDA,"BAU_NOME"))
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLSA460VIS � Autor � Tulio               � Data � 04.06.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Visualiza uma autorizacao                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA460Vis(cAlias,nReg,nOpc)

If BE2->( EOF() )
	Help("",1,"ARQVAZIO")
	Return
Endif

BEA->(DbSetOrder(1))
If ! BEA->(MsSeek(xFilial("BEA")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)))
	MsgInfo(STR0040) //"Nao foi possivel localizar o cabecalho deste evento."
	Return
Endif

Inclui := .F.
PLSA090Mov("BEA",BEA->(Recno()),K_Visualizar)

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLSA460LIB � Autor � Tulio               � Data � 04.06.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Libera uma autorizacao negada                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA460Lib()
LOCAL nOK
LOCAL lGerarTit := .F.
LOCAL cPrefixo
LOCAL cNumTit
LOCAL cTipTit
LOCAL dvencto
LOCAL nOpc
LOCAL aRetSta
LOCAL cStatus
LOCAL cSenhaPLS := ""

If BE2->( EOF() )
    If !lRet090
		Help("",1,"ARQVAZIO")
	EndIf	
	lRet090 := .F.
	Return
Endif

nOK := AxInclui("BA5",0,K_Incluir)
                                  
If nOK == K_OK
	
	DbSelectArea("BEA")
	
	BEA->(DbSetOrder(1))
	BEA->(MsSeek(xFilial("BEA")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)))
	
	BE2->(RecLock("BE2",.F.))
		BE2->BE2_STATUS := "1" // Autorizada
		if BE2->BE2_QTDPRO == 0
			BE2->BE2_QTDPRO := BE2->BE2_QTDSOL
		endIf
		if Empty(BE2->BE2_NIVAUT) .And. !Empty(BE2->BE2_NIVCRI)
			BE2->BE2_NIVAUT := BE2->BE2_NIVCRI
			BE2->BE2_NIVCRI := ""
		endIf
	BE2->(MsUnlock()) 
	//��������������������������������������������������������������������������Ŀ
	//� Saldo e StaLib															 �
	//����������������������������������������������������������������������������	
	PLSATUSS(nil,.T.,IIF(BE2->BE2_LIBERA=="1",.T.,.F.),If(BE2->BE2_LIBERA=="1",BE2->BE2_QTDSOL,0),"1",nil,BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)+BE2->BE2_SEQUEN,nil,nil,BE2->(Recno()))
	//��������������������������������������������������������������������������Ŀ
	//� Deleta criticas															 �
	//����������������������������������������������������������������������������	
	BEG->(DbSetOrder(1))//BEG_FILIAL + BEG_OPEMOV + BEG_ANOAUT + BEG_MESAUT + BEG_NUMAUT + BEG_SEQUEN
	If BEG->( MsSeek( xFilial("BEG")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN) ) )
		While !BEG->(Eof()) .And. BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) == BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN)
			BEG->( RecLock("BEG",.F.) )
				BEG->(DbDelete())
			BEG->(MsUnLock())
			
			BEG->( DBSKIP() )
		EndDo
	EndIf
	//��������������������������������������������������������������������������Ŀ
	//� Se for internacao..														 �
	//����������������������������������������������������������������������������	
	If BEA->BEA_TIPGUI $ "03"
		BEJ->(DbSetOrder(1))
		If BEJ->(MsSeek(xFilial("BEJ")+BEA->(BEA_OPEMOV+BEA_ANOINT+BEA_MESINT+BEA_NUMINT+BE2->BE2_SEQUEN)))
			BEJ->(RecLock("BEJ",.F.))
				BEJ->BEJ_STATUS := "1" // Autorizada
				BEJ->BEJ_AUDITO := "0" //Nao esta mais em auditoria...
			BEJ->(MsUnlock())
			//��������������������������������������������������������������������������Ŀ
			//� Deleta criticas															 �
			//����������������������������������������������������������������������������	
			BEL->(DbSetOrder(1))//BEL_FILIAL + BEL_CODOPE + BEL_ANOINT + BEL_MESINT + BEL_NUMINT + BEL_SEQUEN
	  		If BEL->( MsSeek( xFilial("BEL")+BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN) ) )
				While !BEL->(Eof()) .And. BEL->(BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT+BEL_SEQUEN) == BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN)
					BEL->( RecLock("BEL",.F.) )
						BEL->(DbDelete())
					BEL->(MsUnLock())
					
					BEL->( DbSkip() )
				EndDo
			EndIf			

		Endif
	Endif
	
	aRetSta := PLSGUIAAud(BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT),,, "BE2")
	
	If ! aRetSta[1]
		cStatus := aRetSta[2]
		If  cStatus $ "1,2" //autorizada, parcialmente ou nao
			cSituac := "1" //Ativo

			If BEA->BEA_STATUS == "3"
				If ExistBlock("PLS090L1")
					cSenhaPLS := ExecBlock("PLS090L1",.F.,.F.,{cTipoRotEsp,.F.,dData})
				Else
					cSenhaPLS := PLSSenAut(BEA->BEA_DATPRO)
				Endif
			EndIf
		Else //nao autorizada
			cSituac := "3" //Bloqueado
		Endif                             

		
		BEA->(RecLock("BEA",.F.))
		
			If !Empty(cSenhaPLS)
	
				BEA->BEA_SENHA := cSenhaPLS
	
				If BEA->BEA_TIPGUI <> "03"
					//�������������������������������������������������������������������������������������Ŀ
					//� ATUALIZA BD5	 															        �
					//���������������������������������������������������������������������������������������
					BD5->( DbSetOrder(1) ) //BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO
					If BD5->( MsSeek(xFilial("BD5")+BEA->(BEA_OPEPEG+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI) ) )
						BD5->(RecLock("BD5",.F.))
							BD5->BD5_SENHA  := BEA->BEA_SENHA
						BD5->(MsUnlock())
					EndIf
				EndIf
				
			EndIf
			
			BEA->BEA_NRAOPE := BA5->BA5_NRAOPE
			BEA->BEA_NRAEMP := BA5->BA5_NRAEMP
			
			If BEA->BEA_PAGATO == "1"
				If cStatus $ "1,2" 			//autorizada, parcialmente ou nao
					BEA->BEA_STATUS := "5" //aguardando baixa
					lGerarTit := .T.
				Else
					BEA->BEA_STATUS := "3" //nao autorizada
				EndIf
			Else
				If cStatus $ "1,2" //autorizada OU autorizada parcialmente
					BEA->BEA_STATUS := cStatus 
				Else
					BEA->BEA_STATUS := "3" //nao autorizada
				EndIf
			EndIf
		
		BEA->( MsUnlock() ) 
		//��������������������������������������������������������������������������Ŀ
		//� Ajusta cabecalho da guia BEA											 �
		//����������������������������������������������������������������������������
		PLSATUCS(Iif(cStatus $ "1,2","1","2"))
		//��������������������������������������������������������������������������Ŀ
		//� Se for internacao...													 �
		//����������������������������������������������������������������������������
		If BEA->BEA_TIPGUI == "03"
			BE4->(DbSetOrder(2))
			If BE4->(MsSeek(xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_ANOINT+BEA_MESINT+BEA_NUMINT)))
				BE4->(RecLock("BE4",.F.))
					If cStatus $ "1,2" //autorizada ou autorizada parcialmente 
						BE4->BE4_STATUS := cStatus 
						If !Empty(cSenhaPLS)
							BE4->BE4_SENHA := cSenhaPLS
						EndIf
					Else
						BE4->BE4_STATUS := "3" //nao autorizada
					Endif
					BE4->BE4_AUDITO := "0" //nao esta mais em auditoria
				BE4->(MsUnlock())
			Endif
		Endif
		
		If lGerarTit
			cPrefixo := GetNewPar("MV_PLSPRCP","CPP")
			cNumTit  := PLSE1NUM(cPrefixo)
			cTipTit  := GetNewPar("MV_PLSTPCP","FT")
			dvencto  := BEA->BEA_DATPRO+GetNewPar("MV_PLSVCGC",0)
			nOpc     := K_Incluir
			
			PLSGRVTCP(cPrefixo,cNumTit,BEA->BEA_CODCLI,BEA->BEA_LOJA,cTipTit,dVencto,;
						BEA->BEA_OPEUSR,BEA->BEA_CODEMP,BEA->BEA_MATRIC,nOpc,BEA->BEA_VALOR,BEA->BEA_CONEMP,BEA->BEA_VERCON,;
						BEA->BEA_SUBCON,BEA->BEA_VERSUB)
			
			BEA->(RecLock("BEA",.F.))
			BEA->BEA_CHVSE1 := cPrefixo+cNumTit
			BEA->(MsUnLock())
		Endif
		
		If ExistBlock("PLS460GR")
			ExecBlock("PLS460GR",.F.,.F.,{K_Incluir,.T.})
		Endif
	Endif
	
	Inclui := .F.        
	lRet090:= .T.
	PLSA090Mov("BEA",BEA->(Recno()),K_Visualizar)
	
	if valtype(oBrwBE2) == "O"
		oBrwBE2:ExecuteFilter()
	endIf	
Endif

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLSA460NEG � Autor � Tulio               � Data � 16.07.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Nega uma liberacao negada excluindo da base de dados       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA460Neg()

If BE2->( EOF() )
	Help("",1,"ARQVAZIO")
	Return
Endif

If MsgYesNo(STR0041) //"Confirma a negacao da autorizacao?"
	BE2->(RecLock("BE2",.F.))
	BE2->BE2_NEGADA := "1"
	BE2->(MsUnLock())
Endif


Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �05/01/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	 1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
Private aRotina := {	{ STR0004 ,'AxPesqui'  ,  0 , K_Pesquisar  , 0, .F.},; //"Pesquisar"
						{ STR0005 ,'PLSA460Vis',  0 , K_Visualizar , 0, Nil},; //"Visualizar"
						{ STR0042 ,'PLSA460Lib',  0 , K_Incluir    , 0, Nil},; //"Liberar"
						{ STR0043 ,'PLSA460Neg',  0 , K_Alterar    , 0, Nil} } //"Negar"
Return(aRotina)
