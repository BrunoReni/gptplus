#INCLUDE "CRDA210.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWizard.ch"
         
//Pula Linha
#Define CTRL Chr(13)+Chr(10)
 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRDA210   � Autor �Marcos R. Andrade      � Data �29.11.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastro de vale compra                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Campanha de Fidelizacao             					      ���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���12/01/06  �Machima 91206  �Melhoria para geracao automatica de Vale Com���
���			 �				 �pras									      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          

Function CRDA210                   

Private aRotina := MenuDef()

Private cCadastro := STR0006                           //Motivo de Liberacao

DbSelectArea("MAV")   
dbSetOrder(1) 
DbSeek(xFilial("MAV"),.T.) 

mBrowse( 06, 01, 15, 75, "MAV" )

Return 

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Conrado Q. Gomes      � Data � 13.12.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CRDA210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
	Local aRotina := {	{ STR0001	,"AxPesqui" 	,0	,1	,0	,.F.	}	,; 	//"Pesquisar"
						{ STR0002	,"AxVisual" 	,0	,2	,0	,.T.	}	,; 	//"Visualizar"
						{ STR0003	,"AxInclui" 	,0	,3	,0	,.T.	}	,; 	//"Incluir"
						{ STR0004	,"AxAltera" 	,0	,4	,0	,.T.	}	,; 	//"Alterar"
						{ STR0005	,"Crd210Del"	,0	,0	,0	,.T.	}	,; 	//"Excluir"
						{ STR0007	,"Crd210Aut"	,0	,3	,0	,.T.	}	}  	//"Ger. Autom�tica"					
Return(aRotina)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRD210Del � Autor �Marcos R. Andrade      � Data �29.11.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Exclusao do vale compra                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Campanha de Fidelizacao             					      ���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          
Function Crd210Del(cAlias,nReg,nOpc)

If Crd210CanDel()
	AxDeleta(cAlias,nReg,nOpc,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL)
Else
	Help(" ",1,"NODELETA")	
EndIf

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRD210CanDel� Autor �Marcos R. Andrade    � Data �29.11.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da exclusao do motivo da liberacao                ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Campanha de Fidelizacao             					      ���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���31/03/07  � Danilo Calil  �Correcao do campo MAY_CODPRD                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          

Function Crd210CanDel()

Local lRet 		:= .T.              // Controla se foram encontrados registros no arquivo MAY com o codigo da Vale Compra
Local cAliasMAY	:= ""               // Alias da query ou do proprio arquivo MAY

#IFDEF TOP
	Local cQuery	:= ""           // Expressao da query
	Local lQuery	:= .F.          // Controla se trata com query
#ENDIF	

#IFDEF TOP

    lQuery := .T.
    
    cAliasMAY := "QRYMAY"
    
    cQuery := "SELECT COUNT(*) QTDMAY "
    cQuery += " FROM "
    cQuery += RetSqlName("MAY")+ " MAY "
    cQuery += " WHERE "
    
    cQuery += "MAY_FILIAL = '" + xFilial( "MAY" ) +"' AND "
    cQuery += "MAY_CODPRD = '" + MAV->MAV_CODIGO +"' AND "    
    cQuery += "MAY.D_E_L_E_T_ = ' ' "
    
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasMAY,.F.,.T.)

	If (cAliasMAY)->QTDMAY > 0
		lRet := .F.
	EndIf	

	dbCloseArea()
	
	dbSelectArea("MAY")
	
#ELSE
    
    cAliasMAY	:= "MAY"                             
    
	dbSelectArea( "MAY" )
	dbSetOrder( 1 )
	
    If DbSeek(xFilial("MAY")+ MAV->MAV_CODIGO)
		lRet := .F.
	EndIf	
 
	dbSelectArea("MAY")
	                      
#ENDIF

Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Crd210Aut   � Autor �Fernando Machima     � Data �11/01/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Geracao automatica do vale compras						  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Crd210Aut(ExpC1, ExpN2, ExpN3)							  ���
���          �ExpC1 - Alias do arquivo									  ���
���          �ExpN2 - Recno do registro									  ���
���          �ExpN3 - Opcao do aRotina									  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Campanha de Fidelizacao             					      ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          
Function Crd210Aut(cAlias,nReg,nOpc)

Local nTamMAV_COD  := TamSX3("MAV_CODIGO")[1]     // Tamanho do campo MAV_CODIGO
Local nValor       := 0                           // Valor do Vale Compras
Local oWizard                                     // Objeto do wizard
Local oPanel                                      // Objeto do panel
Local oGetNumIni                                  // Objeto do codigo inicial
Local oGetNumFim                                  // Objeto do codigo final
Local oGetValor                                   // Objeto do valor 
Local oGetCodLoja                                 // Objeto do codigo da loja origem
Local cNumIni      := Space(nTamMAV_COD)         // Codigo inicial informado pelo usuario
Local cNumFim      := Space(nTamMAV_COD)		 // Codigo final informado pelo usuario
Local cCodLoja     := Space(TamSX3("LJ_CODIGO")[1])  // Loja origem de geracao
Local cText        := STR0021 +;                 //"Este programa processar� a gera��o autom�tica de Vale Compras de acordo com os "
					  STR0022 + CTRL + CTRL + ;  //"par�metros selecionados."
	  			      STR0023                     //"Para continuar clique em Avan�ar."
Local bValid                                      // Bloco de codigo com validacao
Local dValidade		:= CtoD("  /  /  ")			  //variavel para armazenar a data de validade
Local lRet         := .T.                        // Controle do retorno da senha

//�������������������������������������������Ŀ
//�Permissao apenas com senha de Administrador�
//���������������������������������������������
If !CRDXVLDUSU(3)
   lRet  := .F.
EndIf

//�����������������������Ŀ
//�Inicializacao do Wizard�
//�������������������������
If lRet
	DEFINE WIZARD oWizard TITLE STR0024 ;   //"Processamento de gera��o de Vale Compras"
	HEADER STR0025 ;  						//"Wizard de gera��o autom�tica de Vale Compras"
	MESSAGE STR0026 TEXT cText ;            //"Processamento autom�tico."
	NEXT {|| .T.} FINISH {|| .T.} PANEL
	
	//�������������������������������������������Ŀ
	//�Segundo Panel - Perguntas da geracao       �
	//���������������������������������������������
	CREATE PANEL oWizard HEADER STR0027 ;   //"Par�metros para gera��o autom�tica"
	MESSAGE STR0028 ; 						//"Informe os par�metros abaixo para a gera��o autom�tica de Vale Compras."
	BACK {|| .T. } FINISH {|| IIf(Crd210VlPar( cNumIni  ,cNumFim  ,nValor  ,cCodLoja	,dValidade ),;
	                               Crd210Gera( cNumIni  ,cNumFim  ,nValor  ,cCodLoja	,dValidade ),.F.) } PANEL         
	oPanel := oWizard:GetPanel(2)
	
	bValid   := {|| Crd210VlNum( cNumIni ,cNumFim )}
	TSay():New(15,05,{|| STR0008},oPanel,,,,,,.T.) //"C�digo inicial:"
	oGetNumIni := TGet():New(14,70,bSETGET(cNumIni),oPanel,55,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)
	
	bValid   := {|| Crd210VlNum( cNumIni ,cNumFim )}
	TSay():New(35,05,{|| STR0009},oPanel,,,,,,.T.) //"C�digo final:"
	oGetNumFim := TGet():New(34,70,bSETGET(cNumFim),oPanel,55,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)
	
	bValid   := {|| nValor > 0 }
	TSay():New(55,05,{|| STR0010},oPanel,,,,,,.T.) //"Valor:"
	oGetValor := TGet():New(54,70,bSETGET(nValor),oPanel,45,10,PesqPict("MAV","MAV_VALOR"),bValid,,,,,,.T.,,,,,,,.F.,,,)
	
	bValid   := {|| ExistCpo("SLJ",cCodLoja)}
	TSay():New(75,05,{|| STR0011},oPanel,,,,,,.T.) //"Loja:"
	oGetCodLoja := TGet():New(74,70,bSETGET(cCodLoja),oPanel,20,10,,bValid,,,,,,.T.,,,,,,,.F.,,"SLJ",)

	bValid   := {|| dValidade >= dDatabase }
	TSay():New(95,05,{|| STR0029},oPanel,,,,,,.T.) //"Validade:"
	oGetValidade := TGet():New(94,70,bSETGET(dValidade),oPanel,55,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)	
	ACTIVATE WIZARD oWizard CENTER
EndIf

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Crd210VlPar � Autor �Fernando Machima     � Data �11/01/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida se todos os parametros foram informados              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Crd210VlPar(ExpC1, ExpC2, ExpN3, ExpC4)					  ���
���          �ExpC1 - Codigo inicial do Vale Compras					  ���
���          �ExpC2 - Codigo final do Vale Compras					      ���
���          �ExpN3 - Valor do Vale Compras					  			  ���
���          �ExpC4 - Loja de origem do Vale Compras					  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Campanha de Fidelizacao             					      ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          
Static Function Crd210VlPar( cNumIni  ,cNumFim  ,nValor  ,cCodLoja	,dValidade)

Local lRet    := .T.               //Retorno da validacao

lRet  := !(Empty(cNumIni) .OR. Empty(cNumFim) .OR. nValor == 0 .OR. Empty(cCodLoja) .OR. Empty(dValidade) )

If !lRet
   MsgStop(STR0012) //"Favor preencher todos os par�metros para o in�cio do processamento."
EndIf

Return (lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Crd210Gera  � Autor �Fernando Machima     � Data �11/01/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Chamada do processamento de Vale Compras			          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Crd210Gera(ExpC1, ExpC2, ExpN3, ExpC4)					  ���
���          �ExpC1 - Codigo inicial do Vale Compras					  ���
���          �ExpC2 - Codigo final do Vale Compras					      ���
���          �ExpN3 - Valor do Vale Compras					  			  ���
���          �ExpC4 - Loja de origem do Vale Compras					  ���
���          �ExpC5 - Validade do vale compra                 			  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Campanha de Fidelizacao             					      ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          
Static Function Crd210Gera( cNumIni  ,cNumFim  ,nValor  ,cCodLoja	,dValidade )

Local lRet       := .T.                                   // Retorno da geracao
Local nQtde      := (VAL(cNumFim) - VAL(cNumIni)) + 1    // Intervalo entre os codigos inicial e final digitados pelo usuario
Local nCount     := 0                                     // Contador de Vale Compras gerados
Local cNewNum                                             // Codigo onicial e controle dos codigos sequenciais de Vale Compras

//"ATEN��O! Certifique que os c�digos de Vale Compras dentro do intervalo digitado correspondem ao valor especificado."
//"Confirma a gera��o autom�tica de Vale Compras com os par�metros informados?"
If lRet := MsgYesNo(STR0013 + CTRL + STR0014)              
	DbSelectArea("MAV")
	DbSetOrder(1)
	cNewNum  := ALLTRIM(cNumIni)
	
	Processa({|lEnd| Crd210Processa(@nCount  ,nQtde  ,cNewNum  ,cCodLoja  ,;
	                                nValor	,dValidade    )},,STR0015)	                    //"Gerando Vale Compras..."
	
	If nCount > 0
	   MsgStop(STR0016+ALLTRIM(STR(nCount))+STR0017)  //"Foram gerados "###" Vale Compras."
	Else 
	   lRet  := .F.
	   MsgStop(STR0018)  //"N�o foi gerado nenhum Vale Compras. Verifique se o intervalo de c�digos informado j� n�o existe na base de dados."
	EndIf   
EndIf

Return (lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Crd210VlNum � Autor �Fernando Machima     � Data �11/01/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Va�ida os codigos de Vale Compras inicial e final		  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Crd210VlNum(ExpC1, ExpC2)									  ���
���          �ExpC1 - Codigo inicial do Vale Compras					  ���
���          �ExpC2 - Codigo final do Vale Compras					      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Campanha de Fidelizacao             					      ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          
Static Function Crd210VlNum( cNumIni  ,cNumFim )

Local lRet  := .T.                         // Retorno da validacao

If !Empty(cNumIni) .AND. !Empty(cNumFim)
	lRet  := (VAL(cNumFim) >= VAL(cNumIni))
	
	If !lRet
	   MsgStop(STR0019) //"O c�digo final deve ser maior ou igual ao c�digo inicial."
	EndIf
EndIf

Return (lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Crd210Proces� Autor �Fernando Machima     � Data �11/01/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Processa a geracao de Vale Compras                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Crd210Processa(ExpN1, ExpN2, ExpC3, ExpC4, ExpN5)		      ���
���			 �ExpN1 - contador de Vale Compras gerados 					  ���
���			 �ExpN2 - intervalo entre os codigos inicial e final seleciona���
���			 �dos 														  ���
���			 �ExpC3 - codigo inicial e sequenciais de Vale Compras		  ���
���          �ExpC4 - Loja de origem do Vale Compras					  ���
���          �ExpN5 - Valor do Vale Compras					  			  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Campanha de Fidelizacao             					      ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          
Static Function Crd210Processa(	nCount	, nQtde		, cNewNum	, cCodLoja	,;
								nValor	, dValidade	)

Local nX							// Controle do loop
Local nNewNum	:= 0				// Codigo do Vale Compras numerico
Local nTamCod	:= LEN( cNewNum )	// Tamanho do codigo inicial, referencia para a geracao dos sequenciais
Local aVale		:= {}				// Dados para a grava��o do log do vale compras

BEGIN TRANSACTION
	For nX := 1 to nQtde
		If !DbSeek( xFilial( "MAV" ) + cNewNum )
			RecLock( "MAV", .T. )
			REPLACE MAV_FILIAL     WITH xFilial("MAV")
			REPLACE MAV_CODIGO     WITH cNewNum
			REPLACE MAV_LOJA       WITH cCodLoja
			REPLACE MAV_VALOR      WITH nValor
			REPLACE MAV_STATUS     WITH  "1"				//Ativo
			If MAV->( FieldPos( "MAV_DTVALI" ) ) > 0
				REPLACE MAV_DTVALI WITH dValidade
			EndIf
			MsUnlock()
			
			aAdd( aVale, xFilial("MAV") )
			aAdd( aVale, cNewNum )
			
			//������������������������������������Ŀ
			//�Verifica se a MB1 esta no dicionario�
			//��������������������������������������
			If AliasIndic( "MB1" )
				CRDA270Log( aVale, "1" )
			EndIf
			aVale := {}
			
			nCount++
		EndIf
		
		nNewNum := VAL( cNewNum ) + 1
		cNewNum := ALLTRIM( STR( nNewNum ) )
		If nTamCod > LEN( cNewNum )
			cNewNum := StrZero( nNewNum, nTamCod )
		EndIf
	Next nX
	FkCommit()
END TRANSACTION

Return .T.	
