#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINA160.CH"
#INCLUDE "FWMVCDEF.CH"

// 17/08/2009 - Compilacao para o campo filial de 4 posicoes
// 18/08/2009 - Compilacao para o campo filial de 4 posicoes

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � FINA160	� Autor � Wagner Xavier 	    � Data � 25/06/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria Bordero de Deposito de Cheques 						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � FINA160()												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAFIN													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FinA160(nPosArotina)

Local lPanelFin := IsPanelFin()
Local aLegenda  := {{ 'Empty(SE5->E5_LA) ', "BR_VERDE",    "Titulo em aberto" },;         
                   { '!Empty(SE5->E5_LA)', "BR_VERMELHO", "Titulo em border�" }}


PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0004) //"Bordero de Dep�sito de Cheques"

DbSelectArea("SE5")
dbSeek( xFilial("SE5") )

pergunte("AFI160",.F.)
SetKey (VK_F12,{|a,b| AcessaPerg("AFI160",.T.)})

DEFAULT nPosArotina := 0
If nPosArotina > 0 // Sera executada uma opcao diretamento de aRotina, sem passar pela mBrowse	
	bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
	Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina)
Else
	mBrowse( 6, 1,22,75,"SE5",,,,,,aLegenda )  
Endif

If lPanelFin //Chamado pelo Painel Financeiro					
	dbSelectArea(FinWindow:cAliasFile)					
	FinVisual(FinWindow:cAliasFile,FinWindow,(FinWindow:cAliasFile)->(Recno()),.T.)
Endif

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FA160Borde� Autor � Wagner Xavier 		  � Data � 06/05/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Define os borderos a serem enviados ao banco					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �FA160Borde(ExpC1,ExpN1,ExpN2)										  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo											  ���
���			 � ExpN1 = Numero do registro 										  ���
���			 � ExpN2 = Opcao selecionada no menu								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA160																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FA160Borde(cAlias,nReg,nOpcx)

LOCAL cArquivo,lGrava:=.F.
LOCAL cIndex:=""
LOCAL oDlg
Local oBanco160
Local lPanelFin := IsPanelFin()

Local oModelMov := FWLoadModel("FINM030")
Local oSubFK5
Local oSubFKA
Local lRet := .T.

PRIVATE nValCheq := 0 ,dVencDe:=dDataBase ,dVencAte:=dDataBase,nHdlBord:=0
PRIVATE cNumBor  := Space(06)
PRIVATE cAgencia := CriaVar("A6_AGENCIA"),cConta:=CriaVar("A6_NUMCON")
PRIVATE cBanco   := CriaVar("A6_COD")
PRIVATE cMarca   := GetMark()
PRIVATE lInverte := .f.

//��������������������������������������������������������Ŀ
//� Verifica se o arquivo est� realmente vazio ou se		  �
//� est� posicionado em outra filial.							  �
//����������������������������������������������������������
If EOF() .or. SE5->E5_FILIAL # xFilial("SE5")
	HELP(" " , 1 , "ARQVAZIO")
	Return Nil
Endif

While .T.
	
	//��������������������������������������������������������������Ŀ
	//� Desenha tela para gets do codigo e loja							 �
	//����������������������������������������������������������������
	nOpca := 0
	
	If lPanelFin //Chamado pelo Painel Financeiro			
		oPanelDados := FinWindow:GetVisPanel()
		oPanelDados:FreeChildren()
		aDim := DLGinPANEL(oPanelDados)
		DEFINE MSDIALOG oDlg OF oPanelDados:oWnd FROM 0,0 To 0,0 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )							
		//����������������������������������������������������������������Ŀ
		//� Observacao Importante quanto as coordenadas calculadas abaixo: � 
		//� -------------------------------------------------------------- � 		
		//� a funcao DlgWidthPanel() retorna o dobro do valor da area do	 �
		//� painel, sendo assim este deve ser dividido por 2 antes da sub- �
		//� tracao e redivisao por 2 para a centralizacao. 					 �		
		//������������������������������������������������������������������		
		nEspLarg := ((DlgWidthPanel(oPanelDados)/2) - 230) /2		 					
		nEspLin  := 0				
   Else   
   	nEspLarg := 0 
	  	nEspLin  := 0	
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0008) FROM 005,000 To 165,480 OF oMainWnd PIXEL //"Border� de Dep�sitos"
	Endif    
	oDlg:lMaximized := .F.
	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT    			
	
	@ 002+nEspLin,005+nEspLarg TO 060+nEspLin,235+nEspLarg OF oPanel PIXEL
	
	@ 010+nEspLin,013+nEspLarg SAY	  OemToAnsi(STR0009) OF oPanel PIXEL //"Border� N�"
	@ 010+nEspLin,048+nEspLarg MSGET  cNumBor  Picture "@!"       Valid !Empty(cNumBor) SIZE 35,08 OF oPanel PIXEL
	
	@ 025+nEspLin,013+nEspLarg SAY	  OemToAnsi(STR0010) OF oPanel PIXEL //"Vencimento"
	@ 025+nEspLin,048+nEspLarg MSGET  dVencDe  SIZE 37,08 OF oPanel PIXEL Hasbutton	
	@ 025+nEspLin,093+nEspLarg SAY	  OemToAnsi(STR0011 ) OF oPanel PIXEL //"�"	
	@ 025+nEspLin,103+nEspLarg MSGET  dVencAte	Valid fa160data(dVencDe,dVencAte) SIZE 37,08 OF oPanel PIXEL Hasbutton
	
	@ 025+nEspLin,153+nEspLarg SAY	  OemToAnsi(STR0012 ) OF oPanel PIXEL //"Limite"
	@ 025+nEspLin,173+nEspLarg MSGET  nValCheq Picture "@E 999,999,999,999.99" Valid nValCheq >= 0 SIZE 55,08 OF oPanel PIXEL Hasbutton
	
	@ 040+nEspLin,013+nEspLarg SAY	  OemToAnsi(STR0013) OF oPanel PIXEL //"Banco "
	@ 040+nEspLin,048+nEspLarg MSGET  oBanco160 VAR cBanco   F3 "SA6" Picture "@!" SIZE 20,08 OF oPanel PIXEL Hasbutton 
	
	@ 040+nEspLin,088+nEspLarg SAY	  OemToAnsi(STR0014 ) OF oPanel PIXEL //"Ag�ncia"
	@ 040+nEspLin,116+nEspLarg  MSGET  cAgencia	Picture "@!"         SIZE 20,08 OF oPanel PIXEL
	
	@ 040+nEspLin,153+nEspLarg SAY	  OemToAnsi(STR0015) OF oPanel PIXEL //"Conta"
	@ 040+nEspLin,173+nEspLarg MSGET  cConta 	Picture "@!"  Valid If(FA160Banco(),.T.,oBanco160:=SetFocus()) SIZE 45,08 OF oPanel PIXEL

	If lPanelFin //Chamado pelo Painel Financeiro					
		oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])			
		ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,;
		{||nOpca := 1,oDlg:End()},;
		{||nOpca := 0,oDlg:End()})
	
	Else	
		DEFINE SBUTTON FROM 62,180 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 62,207 TYPE 2 ACTION (nOpca := 0,oDlg:End()) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED
	Endif
	
	If nOpca # 1
		Exit
	Endif
	
	dbSelectArea( cAlias )
	//��������������������������������������������������������������Ŀ
	//� Filtra o arquivo por tipo e vencimento							  �
	//����������������������������������������������������������������
	cIndex	:= CriaTrab(nil,.f.)
	cChave	:= IndexKey()
	cCond := '(E5_MOEDA=="C1".or.'
	cCond += 'E5_MOEDA=="C2".or.'
	cCond += 'E5_MOEDA=="C3".or.'
	cCond += 'E5_MOEDA=="C4").and.'
	cCond += 'E5_RECPAG=="R".and.'
	cCond += 'DTOS(E5_VENCTO)>="'+DTOS(dVencDe) +'".and.'
	cCond += 'DTOS(E5_VENCTO)<="'+DTOS(dVencAte)+'".and.'
	cCond += 'E5_LA!=" S".and.'
	cCond += '!(E5_SITUACA$"C/E/X")'
	If mv_par01 == 1
		cCond +='.and. E5_BANCO=="'+cBanco+'"'  
		cCond +='.and. E5_AGENCIA=="'+cAgencia+'"' 
		cCond +='.and. E5_CONTA=="'+cConta+'"' 
	Endif
	IndRegua("SE5",cIndex,cChave,,cCond,"Selecionando Registros...")
	nIndex := RetIndex("SE5")
	dbSelectArea("SE5")
	#IFNDEF TOP
		dbSetIndex(cIndex+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndex+1)
	DbGoTop()
	If BOF() .and. EOF()
		dbSelectArea("SE5")
		Help(" ",1,"RECNO")
		Exit
	EndIf
	
	// Efetua pr� marca�ao
	nValor  := 0
	nQtdTit := 0
	If nValCheq # 0
		dbGotop()
		While !Eof()
			If nValor + E5_VALOR <= nValCheq
					
				oModelMov := FWLoadModel("FINM030") //Recarrega o Model de movimentos para pegar o campo do relacionamento (SE5->E5_IDORIG)
				oModelMov:SetOperation( MODEL_OPERATION_UPDATE ) //Altera��o
				oModelMov:Activate()
				oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //habilita grava��o de SE5
				
				//Posiciona a FKA com base no IDORIG da SE5 posicionada
				oSubFKA := oModelMov:GetModel( "FKADETAIL" )
				oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
				
				//Dados do movimento
				oSubFK5 := oModelMov:GetModel( "FK5DETAIL" )
				oSubFK5:SetValue( "FK5_OK", cMarca ) 
				
				If oModelMov:VldData()
			       oModelMov:CommitData()
			       oModelMov:DeActivate()
				Else
			       	lRet := .F.
				    cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
				    cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
				    cLog += cValToChar(oModelMov:GetErrorMessage()[6])        	
		    
			       	Help( ,,"MF160BOR",,cLog, 1, 0 )
				Endif
									
				nValor += SE5->E5_VALOR
				nQtdTit ++
			Endif
			dbSkip()
		Enddo
		dbGoTop()
	Endif

	DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(STR0016)  From 9,0 To 28,80 OF oMainWnd //"Cheques Para Dep�sito"
	oPanel := TPanel():New(0,0,'',oDlg1,, .T., .T.,, ,20,20)
	oPanel:Align := CONTROL_ALIGN_TOP    			

	@002,003 SAY OemToAnsi(STR0017) PIXEL OF oPanel //"Valor Total:"
	@002,030 SAY oValor VAR nValor Picture "@E 999,999,999.99" PIXEL OF oPanel 
	@012,003 SAY OemToAnsi(STR0018 )  PIXEL OF oPanel //"Quantidade:"
	@012,030 SAY oQtda VAR nQtdTit Picture "@E 99999" SIZE 50,10  PIXEL OF oPanel 

	oMark := MsSelect():New(cAlias,"E5_OK","!E5_VALOR",,@lInverte,@cMarca,{35,1,143,315})
	oMark:bMark := {| | fa160Display(cMarca,lInverte,oValor,oQtda)}
	oMark:oBrowse:lhasMark = .t.
	oMark:oBrowse:lCanAllmark := .t.
	oMark:oBrowse:bAllMark := { || FA160Inverte(cMarca,oValor,oQtda) }
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| nOpca := 1,oDlg1:End()},{|| nOpca := 2,oDlg1:End()})
	
	//��������������������������������������������������������������Ŀ
	//� Restaura os indices														 �
	//����������������������������������������������������������������
	#IFDEF TOP
		dbSelectArea("SE5")
		Set Filter to
		dbGoTop()
	#ELSE
		RetIndex("SE5")
		FErase (cIndex+OrdBagExt())
	#ENDIF
	
	If nOpca == 1 .and. nQtdTit > 0
		lGrava := fA160Grava()
	Endif
	RetIndex("SE5")
	Set Filter to
	Exit
EndDO

IF lGrava
	If MsgYesNo( OemToAnsi(STR0019), OemToAnsi(STR0020) ) // "Imprime Relat�rio ? "###" Aten��o"
		fA160Impr(cNumBor)
	Endif
	cArquivo:=__RELDIR+"BD"+TRIM(cNumBor)+".CHQ"
EndIF

dbSelectArea("SE5")
Set Filter to
FCLOSE(nHdlBord) // cArquivo ?!
RetIndex("SE5")

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fA160Grava� Autor � Wagner Xavier 		  � Data � 20/05/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava o Arquivo com os Cheques marcados 						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � FA160DBEVA(ExpN1,ExpD1,ExpD2) 									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Limite de valor para marcar titulos					  ���
���			 � ExpD1 = Data de vencimento inicial a considerar 			  ���
���			 � ExpD2 = Data de vencimento final a considerar				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA160																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fA160Grava()
LOCAL cArquivo:=__RELDIR+"BD"+TRIM(cNumBor)+".CHQ",cReg,lGrava:=.F.
Local oModelMov := FWLoadModel("FINM030")
Local oSubFK5
Local oSubFKA
Local cCamposE5 := ""
Local lRet := .T.

/*/
�������������������������Ŀ
� Arquivo de Cheques 	  �
�	  Remessa/Retorno 	  �
�								  �
� Memoria de Calculo 	  �
� Registro 1 - USUARIOS   �
� - Bordero 				6 �
� - Banco					3 �
� - Agencia 				6 �
� - Tipo do Cheque		2 �
� - Conta Corrente	  15 �
� - Numero do Cheque 	8 �
� - Valor				  14 �
� - Tipo Cheque			2 �
���������������������������
/*/

nHdlBord:=MSFCREATE(cArquivo)
dbSelectArea("SE5")
dbGoTop()
While .NOT. Eof()
	IF E5_OK == cMarca
		lGrava:=.T.
		dbSelectArea("SE5")
											
		//Manda o campo LA com o valor de 2 Caracteres, para manter a grava��o original na E5
		cCamposE5 := "{{'E5_LA', '" + Substr(E5_LA,1,1) + "S'}}"
		
		oModelMov := FWLoadModel("FINM030") //Recarrega o Model de movimentos para pegar o campo do relacionamento (SE5->E5_IDORIG)
		oModelMov:SetOperation( MODEL_OPERATION_UPDATE ) //Altera��o
		oModelMov:Activate()
		oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita grava��o de SE5
		oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que ser�o gravados indepentes de FK5
		
		//Posiciona a FKA com base no IDORIG da SE5 posicionada
		oSubFKA := oModelMov:GetModel( "FKADETAIL" )
		oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
		
		//Dados Cont�beis
   		oSubFK5 := oModelMov:GetModel("FK5DETAIL")	
		oSubFK5:SetValue( "FK5_NUMBOR", cNumBor )
		oSubFK5:SetValue( "FK5_LA", "S" )
		
		If oModelMov:VldData()
       		oModelMov:CommitData()
	       	oModelMov:DeActivate()
		Else
	       	lRet := .F.
		    cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
		    cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
		    cLog += cValToChar(oModelMov:GetErrorMessage()[6])        	
        
	       	Help( ,,"MF160GRV",,cLog, 1, 0 )	
		Endif				
		
		cReg:=cNumBor+cBanco+cAgencia+cConta+E5_MOEDA+E5_NUMCHEQ+Str(E5_VALOR,16,2)
		fWrite(nHdlBord,cReg+CHR(13)+CHR(10),59)
	EndIF
	dbSkip()
End                       

//�����������������������������������������������������Ŀ
//� Ponto de entrada para gravacao de arquivos externos �
//� do cliente.                                         �
//�������������������������������������������������������
IF ExistBlock("F160BORD")
	ExecBlock("F160BORD",.f.,.f.)
Endif

Return lGrava

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fA160Impr � Autor � Wagner Xavier 		  � Data � 20/05/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime o Bordero de Cheques										  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �fA160Impr(ExpC1)														  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Numero do Bordero											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA160																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fA160Impr(cNumBor)
PRIVATE CbTxt	  := Space(10)
PRIVATE cArquivo := __RELDIR+"BD"+TRIM(cNumBor)+".CHQ",nTamArq:=0,nLidos:=0,xBuffer
PRIVATE cBanco,cAgencia,cConta,cCheque,nValor,cTipo
PRIVATE titulo   := OemToAnsi(STR0021) //"Relacao de Bordero de Cheques"
PRIVATE cabec1   := OemToAnsi(STR0022) //"Banco Agencia Conta Corrente TP  Numero do Cheque              Valor"
PRIVATE cabec2   := " "
PRIVATE limite   := 80,cString := "SE5"
PRIVATE tamanho  := "P",cbcont := 0
PRIVATE nomeprog := "FINA160"
PRIVATE cDesc1   := OemToAnsi(STR0023) //"Este relatorio ira imprimir a relacao dos cheques marcados para"
PRIVATE cDesc2   := OemToAnsi(STR0024) //"serem depositados. "
PRIVATE cDesc3   := ""
PRIVATE lFirst   := .F.,j,nTotal:=0

PRIVATE aReturn := { OemToAnsi(STR0025), 1,OemToAnsi(STR0026), 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE nLastKey:= 0
PRIVATE m_pag	 := 1
PRIVATE li		 := 80
PRIVATE nT1:=0,nT2:=0,nT3:=0,nT4:=0,nT5:=0

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Imporessao do Cabecalho e Rodape   �
//����������������������������������������������������������������
wnrel   := "BORDECHQ"

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT 							  �
//����������������������������������������������������������������
wnrel := SetPrint(cString,wnrel,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)
If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif

IF !File(cArquivo)
	Return .T.
EndIF


RptStatus({|lEnd| FinA161(@lEnd,wnRel,cString)},titulo)	// Chamada do Relatorio

Return

Function Fina161(lEnd,wnRel,cString)
Local j
nTamArq:=FSEEK(nHdlBord,0,2)
FSEEK(nHdlBord,0,0)

While nLidos < nTamArq
	
	IF li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
	EndIF
	
	xBuffer:=Space(59)
	FREAD(nHdlBord,@xBuffer,59)
	cBanco  := SubStr(xBuffer, 7, 3)
	cAgencia:= SubStr(xBuffer,10, 5)
	cTipo   := Substr(xBuffer,25, 2)
	cConta  := SubStr(xBuffer,15,10)
	cCheque := SubStr(xBuffer,27,15)
	nValor  := Val(SubStr(xBuffer,42,16))
	li++
	IF !lFirst
		lFirst := .T.
		@li, 0 PSAY cBanco
		@li, 6 PSAY cAgencia
	EndIF
	
	@li,14 PSAY cConta
	@li,29 PSAY cTipo
	@li,33 PSAY cCheque
	@li,52 PSAY nValor	PicTure tm(nValor,16)
	nLidos+=59
	nTotal+=nValor
	
	IF cTipo = "C1"
		nT1 += nValor
	Elseif cTipo = "C2"
		nT2 += nValor
	Elseif cTipo = "C3"
		nT3 += nValor
	Elseif cTipo = "C4"
		nT4 += nValor
	Elseif cTipo = "C5"
		nT5 += nValor
	EndIF
	
EndDO

IF li > 52
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
EndIF

IF nTotal != 0
	For j:=1 To 5
		cSuf:=Str(j,1)
		IF nT&cSuf != 0
			dbSelectArea("SX5")
			dbSeek(cFilial+"06C"+cSuf)
			li++
			@li , 0 PSAY OemToAnsi(STR0027)	+ Trim( X5_DESCRI ) //"Total de Cheques "
			@li ,52 PSAY nT&cSuf Picture tm(nT&cSuf,16)
		EndIF
	Next j
	li++;li++
	@li,	0 PSAY OemToAnsi(STR0028) //"Total Geral do Bordero "
	@li, 52 PSAY nTotal		Picture tm(nTotal,16)
EndIF

IF li != 80
	roda(cbcont,cbtxt,"P")
EndIF

Set Device to Screen

//��������������������������������������������������������������Ŀ
//� Se em disco, desvia para Spool										  �
//����������������������������������������������������������������
If aReturn[5] = 1 	// Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

MS_FLUSH()

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fA160Banco� Autor � Wagner Xavier 		  � Data � 20/05/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica a existencia do banco 									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �fA160Banco() 															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA160																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fA160Banco()
Local lRet:=.t.
dbSelectArea("SA6")
dbSeek(cFilial+cBanco+cAgencia+cConta)
IF !Found()
	Help(" ",1,"NOCONTA")
	lRet:=.f.
ElseIf SA6->A6_BLOCKED == "1"  // CONTA BLOQUEADA
	Help(" ",1,"CCBLOCKED")
	lRet:=.f.	
EndIF

Return lRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � fa160data� Autor � Vinicius Barreira	  � Data � 12/12/95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se data final � maior que data inicial 			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fa160data(ExpD1,ExpD2)												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpD1 = Data Inicial 												  ���
���			 � ExpD2 = Data Final													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA060																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fa160data(dVencDe,dVencAte)
LOCAL lRet:=.T.
IF dVencAte<dVencDe
	Help(" ",1,"DATAMENOR")
	lRet:=.F.
EndIF
Return lRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � fa160display	  � Vinicius Barreira	  � Data � 12/12/95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Informa o valor marcado e o n�mero de cheques				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fa160display( cMarca,lInverte,oValor,oQtda ) 				  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cMarca																	  ���
���			 � lInverte 																  ���
���			 � oValor																	  ���
���			 � oQtda 																	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA160																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fa160display(cMarca,lInverte,oValor,oQtda)

If IsMark("E5_OK",cMarca,lInverte)
	nValor += E5_VALOR
	nQtdTit ++
Else
	nValor  -= E5_VALOR
	nQtdTit --
	nQtdTit := Iif(nQtdTit<0,0,nQtdTit)
Endif

oValor:Refresh()
oQtda:Refresh()

Return

Static Function Fa160Inverte(cMarca,oValor,oQtda)
Local nReg := SE5->(Recno())
Local oModelMov := FWLoadModel("FINM030")
Local oSubFK5
Local oSubFKA
Local lRet := .T.

dbSelectArea("SE5")
dbSeek(cFilial)
While !Eof() .and. cFilial == E5_FILIAL

	oModelMov := FWLoadModel("FINM030") //Recarrega o Model de movimentos para pegar o campo do relacionamento (SE5->E5_IDORIG)
	oModelMov:SetOperation( MODEL_OPERATION_UPDATE ) //Altera��o
	oModelMov:Activate()
	oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //habilita grava��o de SE5
	
	//Posiciona a FKA com base no IDORIG da SE5 posicionada
	oSubFKA := oModelMov:GetModel( "FKADETAIL" )
	oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
	
	//Dados do movimento
	oSubFK5 := oModelMov:GetModel( "FK5DETAIL" )			
	IF E5_OK == cMarca
		oSubFK5:SetValue( "FK5_OK", "  " )
		nValor -= E5_VALOR
		nQtdTit--
	Else
		oSubFK5:SetValue( "FK5_OK", cMarca )
		nValor += E5_VALOR
		nQtdTit++
	Endif 
	
	If oModelMov:VldData()
       oModelMov:CommitData()
       oModelMov:DeActivate()
	Else
       	lRet := .F.
	    cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
	    cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
	    cLog += cValToChar(oModelMov:GetErrorMessage()[6])        	
    
       	Help( ,,"MF160DISP",,cLog, 1, 0 )
	Endif
	
	dbSkip()
End
SE5->(dbGoto(nReg))
oValor:Refresh()
oQtda:Refresh()
oMark:oBrowse:Refresh(.t.)
Return Nil

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �23/11/06 ���
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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
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
Local aRotina := { { OemToAnsi(STR0001), "AxPesqui"  , 0 , 1,,.F.},; //"Pesquisar"
							{ OemToAnsi(STR0002), "AxVisual"  , 0 , 2},; //"Visualizar"
							{ OemToAnsi(STR0003), "FA160Borde", 0 , 3} } //"Bordero"
Return(aRotina)
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FinA160T   � Autor � Marcelo Celi Marques � Data � 04.04.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada semi-automatica utilizado pelo gestor financeiro   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA160                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FinA160T(aParam)	
	cRotinaExec := "FINA160"
	ReCreateBrow("SE5",FinWindow)      		
	FinA160(aParam[1])
	ReCreateBrow("SE5",FinWindow)      	
	dbSelectArea("SE5")
	
	INCLUI := .F.
	ALTERA := .F.
	
Return .T.	
