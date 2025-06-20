#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "LOJA340.CH"

/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �LOJA340() �Autora �Solange Zanardi        � Data � 20/01/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Assistente para abertura de caixa 						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � LOJA340()                            					  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 														      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGALOJA                                                   ���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���26/07/06  �Danilo Calil   �Bops 100967                                 ���
���          �               �Atualiza a database com a data de movimento ���
���          �               �do ECF.                                     ���
���27/03/07  �Danilo Calil   �Bops 105168                                 ���
���          �               �Substituicao de funcoes:                    ���
���          �               �- Lj010VldGet por LjxDVldGet                ���
���05/04/07  �Conrado Quilles�Bops 122711                                 ���
���          �               �Alterada a utiliza��o da chamada            ���
���          �               �SubStr(cUsuario,7,15) por cUserName         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LOJA340()

	Local oCaixa																//Objeto do numero de caixa
	Local oNomCaixa																//Objeto para o nome do caixa
	Local oLeituraX																//Objeto para Leitura X
	Local oValor																//Objeto para valor de fundo de troco
	Local oCodOrigem															//Objeto com o conte�do do caixa origin�rio de troco	
	Local oData																	//Objeto referente a data de abertura	
	Local oLbx                                                                  //ListBox para edicao das moedas - Localizacoes
	Local nLeituraX 	:= 1													//Emite leitura x 1-Sim 2-Nao
	Local cAbreCaixa  	:= Space(01) 											//Verifica permissao para abertura de caixa
	Local cTroco 	 	:= Space(01) 											//Verifica permissao para sangria e troco 
	Local cUsaFiscal	:= Space(01) 											//Verifica se utiliza impressora fiscal
	Local lImpFis   	:= .F.													//Indica se utiliza impressora fiscal
	Local lLibTro 		:= .F.													//Indica se liberou o fundo de troco com a senha de supervisor
	Local lLibFis 		:= .F.													//Indica se liberou a utilizacao da impressora fiscal com a senha de supervisor
	Local cNomCaixa 	:= Space(15)   											//Nome do Caixa
	Local dDataAbr 																//Data de abertura do caixa
	Local dDataFch																//Data de fechamento do caixa
	Local cHoraAbr		                										//Hora de abertura do caixa
	Local cHoraFch		                										//Hora de fechamento do caixa
	Local aMoedas       := {}                                                   //Array com as moedas utilizadas no sistema
	Local aSimbs        := {}													//Simbolos
	Local aSizes        := {40,40}												//Tamanho
	Local aFields       := {STR0039,STR0040}  //"Moeda"###"Valor"				//Campos
	Local nI                                                                    //Contador
	Local lEmitNfce		:= ExistFunc("LjEmitNFCe") .AND.  LjEmitNFCe()		//Sinaliza se utiliza NFC-e
	Local nPanel		:= 0													//Qtde de Panel, quando NFC-e nao cria Panel para LeituraX
	Local lINFIs			:= ExistFunc("INFIs")							//Se a rotia de impressora n�o-fiscal existe
	Local lImpNotFisc   := .F.													//Impressora N�o-Fiscal
	Local lUseSAT		:= ( ExistFunc("LjUseSat") .AND. LjUseSat())			//Usa SAT
	Local lPanelX	    := .T.

	Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

	Private oWizard																//Objeto da janela
	Private cCaixa 	 	:= xNumCaixa() 											//Numero do caixa logado
	Private lRetPanel	:=.F. 													//Controle de Retorno do Painel
	Private cSupCaixa 	:= Space(15)   											//Supervisor do Caixa controle da ljprofile
	Private lAbre       :=.T.           										//Verifica se permite reabrir o caixa
	Private nValor    	:= 0													//Valor de Fundo de Caixa

	Private cCodOrigem 	:= Substr(GetMv("MV_CXLOJA"),1,3)						// Origem do troco, caixa central
	Private cCodDestin 	:= cCaixa                  								// Quem ir� receber o troco
	Private nMoedaCorr  := 1                                                    // Moeda Corrente do Caixa
	Private cMoedaCorr  := ""                                                   // Moeda Selecionado no combo da moeda corrente do caixa

	If nModulo == 5 .AND. AllTrim(cStrAcesso) == ""
		LojXAcesso()
	EndIf

	//���������������������������������������������������Ŀ
	//� Carrega o array aMoedas com as moedas do sistema //
	//�����������������������������������������������������
	If cPaisLoc <> "BRA"
		For nI := 1 To MoedFin()             
			If !Empty(SuperGetMV("MV_MOEDA"+Str(nI,1,0)))
				AAdd(aMoedas,{SuperGetMv("MV_MOEDA"+Str(nI,1,0))+" ("+SuperGetMv("MV_SIMB"+Str(nI,1,0))+")",0,nI,MsDecimais(nI)})
			EndIf              

			// Carrega o array aSimbs com o simbolo das moedas do sistema.
			If !Empty(SuperGetMv("MV_SIMB"+Str(nI,1,0)))
				AAdd(aSimbs,SuperGetMv("MV_SIMB"+Str(nI,1,0)))
			EndIf
		Next nI
	Else
		AAdd(aMoedas,{SuperGetMv("MV_MOEDA1")+" ("+SuperGetMv("MV_SIMB1")+")",0,1,MsDecimais(1)})	
	EndIf

	//��������������������������������������������Ŀ
	//� Verifica se o caixa est� em branco         �
	//����������������������������������������������
	If Empty(cCaixa)
		MsgInfo(STR0006)														//"Caixa inv�lido!"
		Return(NIL)
	EndIf

	//��������������������������������������������Ŀ
	//� Verifica se pode ou nao Fechar/Abrir Caixa �
	//����������������������������������������������
	If !ChkPsw(41)
		Return(NIL)
	EndIf

	//��������������������������������������������Ŀ
	//� Verifica Permissao de Abertura de Caixa    �
	//����������������������������������������������
	If !LjProfile(4,@cSupCaixa,,,) 								//Abre a tela para a digita��o da senha do supervisor
		MsgStop( STR0001 + " " + ; 									// "O(a) usu�rio(a)"
		AllTrim(cUserName) + " " + ; 						// nome do usuario
		STR0002 ) 											//"n�o possui autoriza��o para efetuar o processo de abertura de caixa, contate seu superior."
		Return(NIL)
	EndIf

	//����������������������������Ŀ
	//� Verifica se o Caixa Existe �
	//������������������������������
	If !lj030Verif()															// Verifica se o caixa est� cadastrado na tabela de caixas SX5
		Return(NIL)
	EndIf

	//������������������������������������������������������������Ŀ
	//�Verifica se existe conferencias de fechamento de caixa      �
	//�pendentes e/ou o caixa esta aberto em outro terminal.       �
	//�(Aplicavel quando empregado a confer. de caixa esta ativa)  �
	//��������������������������������������������������������������
	If FindFunction("LjPendConf")
		If LjPendConf("A")
			MsgAlert(STR0041)
			Return Nil
		Endif
	Endif

	If !lAutomato
		If lINFIs
			lImpNotFisc := INFIs(LjGetStation("IMPFISC"))
		Else
			lImpNotFisc := nModulo == 5 .OR. nModulo == 51 .OR. lEmitNfce .OR. lUseSAT
		EndIf
	Else
		lImpNotFisc   := .F.													//Impressora N�o-Fiscal
	EndIf
	//��������������������������������������������������Ŀ
	//�Atualiza a database do sistema caso n�o tenha sido�
	//�realizada a Redu��o Z pendente.                   �
	//����������������������������������������������������
	If lFiscal .AND. !lEmitNfce .AND. !lImpNotFisc
		LjEcfIFData()
	EndIf

	//�����������������������������������������������������������������������Ŀ
	//�Posicionar no caixa de trabalho e carregar vari�veis a serem utilizadas�
	//�������������������������������������������������������������������������
	DbSelectArea("SA6")
	DbSetOrder(1)
	DbSeek(xFilial("SA6")+AllTrim(cCaixa))
	cHoraAbr 	:= SA6->A6_HORAABR
	dDataAbr 	:= SA6->A6_DATAABR
	cHoraFch 	:= SA6->A6_HORAFCH
	dDataFch 	:= SA6->A6_DATAFCH
	cNomCaixa  	:= Capital(SA6->A6_NREDUZ)

	//����������������������������������������������������������������������������������������������Ŀ
	//�  1 - Analise de credito   Verificacao do caixa se tem analise de credito                     �
	//�  2 - Usa TEF              Caixa tem acesso a utilizar o sistema de TEF                       �
	//�  3 - Usa Imp. Fiscal      Caixa tem acesso a utilizar Impressora Fiscal                      �
	//�  4 - Supervis�o Caixa     Acesso para abrir e fechar o caixa                                 �
	//�  5 - Sangria/Troco        Acesso para fazer sangria e entrada de troco                       �
	//�  6 - Redu��o Z            Acesso para fazer Redu��o Z                                        �
	//�  7 - Cancelamento Item    Acesso para cancelar item                                          �
	//�  8 - Cancelamento Cupom   Acesso para cancelar o cupom                                       �
	//�  9 - Alterar parcelas     Acesso para alterar parcelas na venda balc�o                       �
	//� 10 - Saida do Atendimento Acesso para sair da tela de Atendimento  --- OUTRO MODULO          �
	//� 11 - Efetuar Descontos    Acesso para efetuar descontos                                      �
	//� 12 - Fun��es FrontLoja    Acesso para as teclas de fun��es       (F12)   --- FRONT LOJA      �
	//� 13 - Abertura de Gaveta   Acesso para abrir Gaveta                                           �
	//� 14 - Atu. Geral Check-Out Acesso para realizar atualizacao geral no Check-Out --- FRONT LOJA �
	//������������������������������������������������������������������������������������������������

	lImpFis    	:= IIf(Len(Alltrim(LjGetStation("IMPFISC")))==0,.F.,.T.)   		//Verifica se a estacao possui impressora fiscal
	cUsaFiscal	:= SubStr(cStrAcesso,3,1)  										//Utiliza impressora Fiscal s/n/x
	cAbreCaixa 	:= SubStr(cStrAcesso,4,1)  										//Permite abrir o caixa s/n/x
	cTroco 	 	:= SubStr(cStrAcesso,5,1)  										//Permite efetuar sangria ou fundo de troco s/n/x

	//����������������������������������������������������������������������������������Ŀ
	//�Se a esta��o ou o usu�rio n�o usarem impressora fiscal deixar a leitura X como N�o�
	//������������������������������������������������������������������������������������
	If !lImpFis .OR. cUsaFiscal == "N" .OR. lImpNotFisc
		nLeituraX := 2
	EndIf

	//����������������������Ŀ
	//�Tela inicial do Wizard�
	//������������������������
	DEFINE WIZARD oWizard  		;
	TITLE   STR0003 		; 												//"Abertura de Caixa"
	HEADER  STR0004 		; 												//"Assistente para Abertura de Caixa"
	MESSAGE " "     		;
	TEXT STR0005   		; 												//"O assistente ir� ajud�-lo a executar os processos de abertura de caixa"
	PANEL NEXT {|| .T.} 	;
	FINISH {|| .T.}

	//�����������������Ŀ
	//�Abertura do caixa�
	//�������������������
	CREATE PANEL oWizard   		;
	HEADER  STR0007  	; 												//"Abertura do Caixa"
	MESSAGE STR0008 		; 												//"Confira os dados e clique em <Avan�ar>"
	PANEL BACK {|| .T.} 	;
	NEXT {|| Lj340Val("1",dDataAbr,dDataFch,cUsaFiscal,@lLibFis,cHoraAbr,nLeituraX,cTroco,@lLibTro) .AND. ; //Verifico se o caixa j� est� aberto
	Lj340Panel(2,"NEXT",cUsaFiscal,cTroco,lImpFis) } ; 			
	FINISH {|| Lj340Sai(lRetPanel) } ;
	EXEC {|| .T.}

	@ 010,050 To 125,235 Of oWizard:oMPanel[2] Pixel
	@ 020,057 Say STR0009 Of oWizard:oMPanel[2] 	Pixel				   		//"Caixa : "
	@ 018,080 MsGet oCaixa 	Var cCaixa 				When .F. Size 20,8 Of oWizard:oMPanel[2] Pixel
	@ 035,057 Say STR0010 Of oWizard:oMPanel[2] 	Pixel						//"Nome  : "
	@ 033,080 MsGet oNomCaixa Var cNomCaixa 		When .F. Size 50,8 Of oWizard:oMPanel[2] Pixel
	@ 092,202 BitMap oBitMap Resname "troco_ocean" Size 32,32 Of oWizard:oMPanel[2] Pixel	


	lPanelX := !lEmitNfce .AND. !lImpNotFisc 

	//�����������������������������Ŀ
	//�Entrada de Troco             �
	//�������������������������������
	CREATE PANEL oWizard   ;
	HEADER STR0015  ; 													//"Fundo de caixa"
	MESSAGE STR0016 ; 													//"Informe abaixo o valor de fundo de caixa"
	PANEL BACK {|| .T.} ;
	NEXT {|| Lj340Val("2",dDataAbr,dDataFch,cUsaFiscal,@lLibFis,cHoraAbr,nLeituraX,cTroco,@lLibTro) .AND. ; //Valida se pode informar o troco
	(!lPanelX .OR. Lj340Panel(3,"NEXT",cUsaFiscal,cTroco,lImpFis)) } ; 
	FINISH {|| Lj340Sai(lRetPanel) } ;
	EXEC {|| .T.}

	@ 010,050 To 125,235 Of oWizard:oMPanel[3] Pixel
	@ 020,057 Say STR0032 Of oWizard:oMPanel[3] Pixel							//"Do Caixa: "
	@ 018,085 Msget oCodOrigem Var cCodOrigem F3 "23" Size 30,08 Of oWizard:oMPanel[3] Pixel ;
	Valid SX5->(DbSeek(xFilial("SX5")+"23"+cCodOrigem)) .AND. SA6->(DbSeek(xFilial("SA6")+cCodOrigem) .AND. cCodOrigem <> cCaixa)
	@ 020,120 Say STR0033 Of oWizard:oMPanel[3] Pixel							//"Para o Caixa: "
	@ 018,155 Msget oCaixa Var cCaixa  When .F. Size 20,08  Of oWizard:oMPanel[3] Pixel 
	@ 035,057 Say STR0017 Of oWizard:oMPanel[3] Pixel							//"Data  : "
	@ 033,085 Msget oData Var dDataBase When .F. Size 40,08 Of oWizard:oMPanel[3] Pixel	
	If cPaisLoc == "BRA"
		@ 050,057 Say STR0019 Of oWizard:oMPanel[3] Pixel							//"Valor : "
		@ 048,085 MsGet oValor Var nValor Valid Positivo() Picture "@E 999,999.99" Size 50,08 Of oWizard:oMPanel[3] Pixel
	Else
		//                      LS  CE  CD  LI
		oLBx := TWBrowse():New(050,057,120,060,,aFields,aSizes,oWizard:oMPanel[3],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oLBx:SetArray(aMoedas)       
		oLBx:bLDblClick	:= {|| Lj340EdList(@aMoedas,@oLbx)}
		oLBx:bLine := {|| {aMoedas[oLBx:nAt,1],TransForm(aMoedas[oLBx:nAt,2],Tm(aMoedas[oLBx:nAt,2],16,aMoedas[oLBx:nAt,4]))}}
	EndIf
	@ 092,202 BitMap oBitMap RESNAME "troco" Size 32,32 Of oWizard:oMPanel[3] Pixel

	//�����������������������������Ŀ
	//�Leitura X                    �
	//�������������������������������
	If lPanelX
		nPanel := 5
		CREATE PANEL oWizard   ;
		HEADER  STR0011 ; 													//"Leitura X"
		MESSAGE STR0012 ; 													//"Deseja efetuar a Leitura X na impressora fiscal ?"
		PANEL BACK {|| Lj340Panel(4,"BACK",cUsaFiscal,cTroco,lImpFis) } ;
		NEXT {|| Lj340Val("4",dDataAbr,dDataFch,cUsaFiscal,@lLibFis,cHoraAbr,nLeituraX,cTroco,@lLibTro) .AND. ;	//Valida se pode usar impressora fiscal 
		Lj340Val("3",dDataAbr,dDataFch,cUsaFiscal,@lLibFis,cHoraAbr,nLeituraX,cTroco,@lLibTro) }     ;  //Valida o hor�rio para abertura do caixa
		FINISH {|| Lj340Sai(lRetPanel) } ;
		EXEC {|| .T.}

		@ 010,050 To 125,235 Of oWizard:oMPanel[4] Pixel
		@ 020,057 Radio oLeituraX Var nLeituraX 3D ;
		Size 130,10 	;
		PROMPT 		;
		STR0013,		; 													//"Sim"
		STR0014 		;  													//"N�o"
		Of oWizard:oMPanel[4] Pixel	
		@ 050,050 BitMap oBitMap RESNAME "printer_l" Size 60,48 Of oWizard:oMPanel[4] Pixel	NOBORDER
	Else
		nPanel := 4
	EndIf

	//�����������������������������Ŀ
	//�Tela de finalizacao do Wizard�
	//�������������������������������
	CREATE PANEL oWizard   ;
	HEADER STR0020  ; 													//"Finalizar"
	MESSAGE STR0025 ; 													//"Voc� est� pretes a finalizar a opera��o de abertura de caixa..."
	PANEL BACK {|| Lj340Panel(nPanel,"BACK",cUsaFiscal,cTroco,lImpFis) } ;
	NEXT {|| .T. } ;
	FINISH {|| lRetPanel:=Lj340Fim() } ;
	EXEC {|| .T.}

	@ 010,050 To 125,235 Of oWizard:oMPanel[nPanel] Pixel
	@ 020,057 Say STR0021 Size 180,30 Of oWizard:oMPanel[nPanel] Pixel 				//"Para confirmar o processo de abertura clique em <Finalizar>"
	@ 092,202 BitMap oBitMap RESNAME "discount" Size 32,32 Of oWizard:oMPanel[nPanel] Pixel	

	// Se nao for o Robo, chama as telas
	If !lAutomato                                     
		ACTIVATE WIZARD oWizard CENTERED VALID {|| Lj340Sai(lRetPanel)}
		If lRetPanel .AND. lAbre
			LjMsgRun(STR0031,,{|| Lj340Proc(cAbreCaixa,lImpFis,nLeituraX,lLibFis,cUsaFiscal,lLibTro,cTroco,aMoedas,aSimbs, lImpNotFisc) }) //"Aguarde... Efetuando a Abertura do Caixa..."
		EndIf

	EndIf

Return(.T.)

/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Lj340Val �Autora �Solange Zanardi        � Data � 20/01/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o das permiss�es dos caixas                        |��
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Lj340Val(cExp1,dExp2,dExp3,cExp4,lExp5,cExp6,nExp7,;       ���
���          |          cExp8,lExp9)                                      ���
�������������������������������������������������������������������������Ĵ��
��|Parametros| cExp1 - Caracter para controle interno da fun��o n� painel ���
��|          | dExp2 - Data da abertura do caixa                          ���
��|          | dExp3 - Data de fechamento do caixa                        ���
��|          | cExp4 - Permissao do caixa para util. da imp.fiscal (SNX)  ���
��|          | lExp5 - Indica se o sup.liberou a utiliza��o da imp.fiscal ���
��|          | cExp6 - Hora de Abertura do caixa                          ���
��|          | nExp7 - Indica se foi setado no painel 1=S 2=N LeituraX    ���
��|          | cExp8 - Permissao do caixa para entrada de troco    (SNX)  ���
��|          | lExp9 - Indica se o sup.liberou a digita��o do troco   	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � LOJA340                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Lj340Val(cTp     , dDataAbr , dDataFch  , cUsaFiscal , ;
	lLibFis , cHoraAbr , nLeituraX , cTroco     , ;
	lLibTro)

	Local lRet 		:= .T.				   		//Retorno da validacao
	Local cRet 		:= Space(01)				//Data do ECF
	Local xRet      := .T.                      //Retorno do ponto de entrada LJ340VLD
	Local lLj340Vld := ExistBlock("LJ340VLD")   //Ponto de entrada que permite validar a abertura automatica do caixa
	Local lEmitNfce	:= FindFunction("LjEmitNFCe") .AND.  LjEmitNFCe()		// Sinaliza se utiliza NFC-e
	Local lMvLjPdvPa:= FindFunction("LjxBGetPaf") .And. LjxBGetPaf()[2] //Indica se � PDV
	Local aDtHrECF  := IIF(lEmitNfce ,  LjDtHrECF(.T.) , {dDataBase,  Time()} )   //Data/Hora do caixa

	//�������������������������������������������������������������������Ŀ
	//�Ponto de entrada que permite validar a abertura automatica do caixa�
	//���������������������������������������������������������������������
	If lLj340Vld
		xRet := ExecBlock("LJ340VLD",.F.,.F.)
		If ValType(xRet) == "L"
			lRet := xRet
		EndIf
	EndIf

	If lRet
		Do Case
			Case cTP == "1"									
			//��������������������������������Ŀ
			//�Valida se o caixa j� est� aberto�
			//����������������������������������
			lAbre := .T. 														// Vari�vel para controlar reabertura de caixa
			If !Empty(dDataAbr)                             
				MsgStop(STR0028+" "+Dtoc(dDataAbr)+CHR(10)+CHR(13)+STR0036)		//"Este caixa j� foi aberto em:"
				lAbre := .F.			                                        //"Efetue primeiramente o seu fechamento"
				lRet  := .F.
			ElseIf !Empty(dDataFch) .AND. dDataFch == dDataBase
				If !MsgYesNo(STR0029+" "+Dtoc(dDataFch)+CHR(10)+CHR(13)+STR0037)//"Este caixa j� foi fechado em:" 											
					lAbre := .F.                                                //"Confirma reabertura nesta data ?"
					lRet  := .F.
				EndIf
			ElseIf dDataAbr > aDtHrECF[1] .AND. cHoraAbr > SubStr(aDtHrECF[2],1,5)
				Help(" ",1,"LJHORAABR")
				lRet := .F.
			EndIf

			Case cTp == "2"									
			//�������������������������������Ŀ
			//�Valida se pode informar o troco�
			//���������������������������������
			If	cTroco == "N" .AND. nValor > 0
				MsgInfo(STR0026) 												//"Usu�rio sem permiss�o para informar troco"
				lRet := .F.
			ElseIf cTroco == "X" .AND. nValor > 0 .AND. !lLibTro
				lLibTro := LjProfile(5,@cSupCaixa,,,) 
				lRet := lLibTro 
			Endif

			Case cTp == "3"
			//������������������������������������������Ŀ
			//�Valido o hor�rio da Ecf ou do Sistema     �
			//��������������������������������������������
			If !lEmitNfce .AND. nLeituraX == 1 .AND. cUsaFiscal == "S" .OR. lLibFis	//Se usa ou foi liberado para usar impressora fiscal

				IFStatus(nHdlECF, "2", @cRet)

				If dDataBase <> CtoD(cRet)
					MsgStop(STR0034)		 									//"A data do ECF est� diferente da data do Sistema."
					lRet := .F.
				Else
					If SM0->M0_ESTCOB $ "MG|AM|SP"
						If !VerifHora()
							/* "Conforme previsto no Requisito XVII (Ato Cotepe/ICMS 9, de 13 de Mar�o de 2013),
							para PAF-ECF admite-se somente uma toler�ncia em minutos entre a hora do Sistema e a hora do ECF,
							limitada a uma hora, desde que na mesma data." */
							If lMvLjPdvPa
								MsgStop(STR0042)
							Else
								MsgStop(STR0035) 									//"Hora do Sistema diferente da hora do ECF."
							EndIf
							lRet := .F.
						EndIf
					EndIf
				EndIf

			EndIf

			Case cTp == "4"    
			If cUsaFiscal == "N" .AND. nLeituraX == 1
				MsgInfo(STR0027) 												//"Usu�rio sem permiss�o para utilizar impressora fiscal"
				lRet := .F.
			ElseIf cUsaFiscal == "X" .AND. nLeituraX == 1 .AND. !lLibFis
				lLibFis := LjProfile(3,@cSupCaixa,,,)
				lRet 	:= lLibFis
			EndIf


		EndCase

	EndIf	
Return(lRet)

/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Lj340Panel�Autora �Solange Zanardi        � Data � 23/01/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Controla a sequ�ncia dos pain�is de acordo com as permis-  ���
���          � soes do caixa.                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Lj340Panel(nExp1,cExp2,cExp3,cExp4,lExp5)                  ���
�������������������������������������������������������������������������Ĵ��
��|Parametros| nExp1 - Controle de n�mero de painel                       ���
��|          | cExp2 - Controle do tipo de operacao next ou back          ���
��|          | cExp3 - Permissao do caixa para utiliza��o de imp.fiscal   ���
��|          | cExp4 - Permissao do caixa para digitacao de troco         ���
��|          | lExp5 - Indica se utiliza impressora fiscal                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � LOJA340                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function lj340Panel(nPanel , cTipo , cUsaFiscal , cTroco , ;
	lImpFis)          

	//�����������������������������������������������������������Ŀ
	//�1 -  Painel de Bem Vindo                                   �
	//�2 -  Painel para Sele��o de Caixa                          �
	//�3 -  Painel para Dig. Confer�ncia de Caixa                 �
	//�4 -  Painel para conf. da Impress�o de Cr�tica             �
	//�5 -  Painel para conf. de c�pia dos dados dig. para sangria�
	//�6 -  Painel para digita��o de Sangrias                     �
	//�7 -  Painel da Leitura X                                   �
	//�8 -  Painel da Redu��o Z                                   �
	//�9 -  Painel de Finaliza��o                                 �
	//�������������������������������������������������������������

	If cTipo == "NEXT"
		//��������������������������������������������������������������Ŀ
		//�Trato todas as combina��es de par�metros para que o assistente�
		//�pule as telas sobre as quais o operador n�o tem acesso.       �
		//����������������������������������������������������������������
		Do Case
			Case nPanel == 2
			If cTroco == "N"
				If !lImpFis .OR. cUsaFiscal == "N"
					oWizard:NPanel+=2
				Else
					oWizard:NPanel+=1
				EndIf	
			EndIf

			Case nPanel == 3
			If !lImpFis .OR. cUsaFiscal == "N"
				oWizard:NPanel+=1
			EndIf
		EndCase

	ElseIf cTipo == "BACK"
		//��������������������������������������������������Ŀ
		//�Quando estou trabalhando com o m�todo BACK        �
		//�devo me atentar a soma de mais 1 no NPanel, pois o�
		//�pr�prio comando BACK j� efetua um retorno.        �
		//����������������������������������������������������
		Do Case
			Case nPanel == 4
			If cTroco == "N"
				oWizard:NPanel-=1
			EndIf

			Case nPanel == 5
			If !lImpFis .OR. cUsaFiscal == "N"
				If cTroco == "N"
					oWizard:NPanel-=2
				Else
					oWizard:NPanel-=1
				EndIf	
			EndIf
		EndCase
	EndIf
Return(.T.)

/* 
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    � Lj340Proc�Autora �Solange Zanardi        � Data � 20/01/04       ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o �Efetua os procedimentos para a abertura de Caixa                  ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � Lj340Proc(cExp1,lExp2,nExp3,lExp4,cExp5,lExp6,cExp7,nExp8,nExp9) ���
�������������������������������������������������������������������������������Ĵ��
��|Parametros| cExp1 - Permissao do caixa abertura e fechamento    (SNX)        ���
��|          | lExp2 - Indica se o caixa utiliza impressora fiscal              ���
��|          | nExp3 - Indica se foi setado no painel 1=S 2=N LeituraX          ���
��|          | lExp4 - Indica se o sup.liberou a utiliza��o da imp.fiscal       ���
��|          | cExp5 - Permissao do caixa para utilizacao de imp.fiscal         ���
��|          | lExp6 - Indica se o sup.liberou a entrada de troco               ���
��|          | cExp7 - Permissao do caixa para entrada de troco                 ���
��|          | nExp8 - Array com os valores para entrada de troco (Localizacoes)���
��|          | nExp9 - Array com os simbolos das moedas                         ���
��|          | lExp10 - Impressora N�o Fiscal?                                  ���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � LOJA340       |                                                  ���
�������������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                     	        ���
�������������������������������������������������������������������������������Ĵ��
���31/07/07  �Erik Belluco   �Bops 128060                                       ���
���          �               �Criado ponto de entrada LJ340ABRCX que recebe como���
���          �               �parametro aMoedas									���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Function Lj340Proc(cAbreCaixa , lImpFis , nLeituraX , lLibFis , ;
	cUsaFiscal , lLibTro , cTroco    , aMoedas , ;
	aSimbs, lImpNotFisc)

	Local lRet 			:= .T.									// Indica se o troco foi gravado com sucesso
	Local nI  			:= 0									// Controle auxiliar de loop
	Local lLj340AbrCx  	:= FindFunction("U_LJ340ABRCX") 		// Variavel que recebe o ponto de entrada LJ340FIM 
	Local lEmitNfce		:= FindFunction("LjEmitNFCe") .AND.  LjEmitNFCe()		// Sinaliza se utiliza NFC-e

	Default lImpNotFisc := .f.
	//�����������������������������Ŀ
	//� Efetua abertura do caixa    �
	//�������������������������������
	cx_abre_fecha(cCaixa,"A")

	//����������������������������Ŀ
	//� Leitura X				   �
	//������������������������������
	If !lEmitNfce .AND. lImpFis .AND. nLeituraX == 1 .AND. !lImpNotFisc .AND.  (lLibFis .OR. cUsaFiscal	== "S")
		IFLeituraX(nHdlECF)
	EndIf

	//���������������������������������������������������������������Ŀ
	//� Gravando Troco de acordo com a fun��o do Front Loja 	      �
	//�����������������������������������������������������������������
	For nI := 1 To Len(aMoedas)
		//������������������������������������������������������������Ŀ
		//� Determina o valor e a moeda corrente para entrada de Troco.|
		//��������������������������������������������������������������
		If cPaisLoc <> "BRA"
			nValor    := aMoedas[nI][02]
			nMoedaCorr:= aMoedas[nI][03]
		EndIf

		If (lLibTro .OR. cTroco == "S") .AND. nValor > 0
			lRet := Lj340Troc(aSimbs)
			If !lRet
				Return(.F.)	
			EndIf
		EndIf
	Next nI

	If cPaisLoc == "MEX"
		If lLj340AbrCx
			U_LJ340ABRCX(aMoedas)
		EndIf   
	EndIf

	MsgAlert(STR0022) 															//"Abertura de caixa efetuada com sucesso!"
Return(.T.)

/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Lj340Troc �Autora �Solange Zanardi        � Data � 03/02/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Prepara os dados para o envio de informa��es � fun��o de   ���
���          � grava��o de troco do Front Loja                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Lj340Troc()                            					  ���
�������������������������������������������������������������������������Ĵ��
��|Parametros|ExpA1 (1 - aSimbs) Array de simbolos de moeda.              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � LOJA340                                                    ���
�������������������������������������������������������������������������Ĵ��
���Data      | Analista | Bops  | Descricao                               |��
�������������������������������������������������������������������������Ĵ��
���02/10/2007| Nunzio   |132489 | Passagem do parametro lSigaLoja = .T.   |��
���			 | 			|		| para a funcao Frt050SE5, para sempre    |��
���			 | 			|		| gravar o SE5 quando for chamada pelo 	  |��
���			 | 			|		| siga loja e o caixa origem for diferente|��
���			 | 			|		| do logado.					          |��  
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Lj340Troc(aSimbs)

	Local aRet      	:= {} 													// Retorno do Ponto de Entrada
	Local lRet      	:= .F.													// Retorno da funcao
	Local nCheck		:= 2													//1=Sangria 2=Troco

	If ExistBlock("FRT050SA")
		aRet := ExecBlock("FRT050SA",.F.,.F.,{nCheck,cCodOrigem,cCodDestin})
		nCheck		:= aRet[1]
		cCodOrigem	:= aRet[2]
		cCodDestin	:= aRet[3]
		nDinheir	:= aRet[4]
		nCheques	:= aRet[5]
		nCartao		:= aRet[6]
		nVlrDebi	:= aRet[7]
		nFinanc		:= aRet[8]
		nConveni	:= aRet[9]
		nVales		:= aRet[10]
		nOutros		:= aRet[11]
	EndIf

	SX5->(DbSetOrder(1)) 														// Primeiro indice para validacao do caixa digitado
	SA6->(DbSetOrder(1)) 														// Primeiro indice para obtencao da Agencia/Conta para geracao do SE5

	lRet := Frt050SE5(nCheck, cCodOrigem, cCodDestin, nValor,0,0,0,0,0,0,0,aSimbs,.F., .T.)
	If lRet .AND. ExistBlock("Frt050ST")
		ExecBlock("Frt050ST",.F.,.F.,{nCheck,cSupCaixa,nValor,0,0,0,0,0,0,0})
	EndIf
Return(lRet)

/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Lj340Sai �Autora �Solange Zanardi        � Data � 20/01/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Mensagem para confirmar saida do assistente.        		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Lj340Sai(lExp1)                        					  ���
�������������������������������������������������������������������������Ĵ��
��|Parametros| lExp1  -	Indicador de sa�da do painel                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � LOJA340                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Lj340Sai(lConfirma)

	If lConfirma 																//Se confimou gravacao sai do assistente
		Return(.T.)		
	Else
		If MsgNoYes(STR0030) 													//"Deseja abandonar o assistente ?"	
			Return(.T.)	
		EndIf	
	EndIf

Return(.F.)

/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Lj340Fim �Autora �Solange Zanardi        � Data � 20/01/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Confirma��o para o processo de abertura de caixa            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Lj340Fim()                             					  ���
�������������������������������������������������������������������������Ĵ��
��|Parametros|                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � LOJA340                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Lj340Fim()

	If MsgNoYes(STR0023) 														//"Ao confirmar o procedimento, ser� efetuada a abertura de caixa. Deseja prosseguir com a opera��o ?"	 
		Return(.T.)	
	EndIf	

Return(.F.)

/*/
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o	 �Lj340EdList  � Autor �    Julio Cesar        �Data  �08/04/2004���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Permite editar o valor que sera recebido como entrada de troco���
���          � para cada moeda existente no sistema.                         ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Lj340EdList(ExpA1,ExpO1)                                      ���
����������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 := Array com cada uma das moedas existentes no sistema. ���
���          � ExpO1 := Objeto referente ao TWBrowse                         ���
����������������������������������������������������������������������������Ĵ��
��� Uso		 � Loja340 - Assistente de abertura de caixa.                    ���
����������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                              ���
����������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                            ���
����������������������������������������������������������������������������Ĵ��
���15/06/07  �Norbert Waage  �Bops 127759 - Correcao da picture utilizada na ���
���          �               �edicao do valor. Utilizacao das validacoes ca- ���
���          �               �dastradas no SX3 para o campo E5_VALOR.        ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Static Function Lj340EdList(aMoedas,oLbx)

	Local aArea		:= GetArea()					// Armazena a area atual
	Local aAreaSX3	:= SX3->(GetArea())			// Armazena a area do SX3
	Local nValEnt	:= aMoedas[oLBx:nAt,2]			// Valor de entrada de troco
	Local cPict		:= ""							// Picture utilizada na edicao da celula
	Local cValid	:= "Lj340VldGet()"				// Validacao do valor informado

	DbSelectArea("SX3")
	DbSetOrder(2)

	If DbSeek("E5_VALOR")

		//������������������������������������Ŀ
		//�Recupera a Picture do campo E5_VALOR�
		//��������������������������������������
		cPict	:= SX3->X3_PICTURE

		//��������������������������������������Ŀ
		//�Recupera a validacao do campo E5_VALOR�
		//����������������������������������������
		If !Empty(SX3->X3_VALID)
			cValid	+= ' .AND. (' + AllTrim(SX3->X3_VALID) + ')'
		EndIf

		//�������������������������������������������������Ŀ
		//�Recupera a validacao de usuario do campo E5_VALOR�
		//���������������������������������������������������
		If !Empty(SX3->X3_VLDUSER)
			cValid	+= ' .AND. (' + AllTrim(SX3->X3_VLDUSER) + ')'
		EndIf

	EndIf

	oLBx:ColPos := 2
	MaFisEditCell(@nValEnt,oLBx,cPict,2,cValid) 

	SysRefresh()
	oLBx:Refresh()

	RestArea(aAreaSX3)
	RestArea(aArea)

Return(Nil)


/*    
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o	 �Lj340VldGet  � Autor �Norbert Waage Junior   �Data  �18/06/07  ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a validacao do valor informado pelo usuario no        ���
���          � TWBrowse.                                                     ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe	 � ExpL1 := Lj340VldGet()                                        ���
����������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1 := .T. para o dado valido e .F. para o dado invalido    ���
����������������������������������������������������������������������������Ĵ��
��� Uso		 � LOJA340                                                       ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function Lj340VldGet()

	Local lRet := .T.

	If M->CELL <= 0
		lRet := .F.
	EndIf

Return(lRet)
