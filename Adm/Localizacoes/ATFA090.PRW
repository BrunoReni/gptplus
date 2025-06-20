#INCLUDE "Atfa090.ch"
#Include "Protheus.CH"

//#Define NUM_MOEDAS	5

//********************************
// Controle de multiplas moedas  *
//********************************
Static lMultMoed := FindFunction("AtfMoedas")

// 17/08/2009 - Ajuste para filiais com mais de 2 caracteres.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA090   �Author �Alexandre Silva     � Date �  07-07-03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Programa para fazer o calculo da reavaliacao dos itens de   ���
���          �ativo.                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � Ativo Fixo                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function ATFA090()

Private cCadastro 		:= STR0001 //"Atualiza��o de Ativos Imobilizados"
Private aRotina := MenuDef()

mBrowse( 6, 1,22,75,"SN1")

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATF090Reav�Author �Alexandre Silva     � Date �  07-07-03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Programa para fazer o calculo da reavaliacao dos itens de   ���
���          �ativo.                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � Ativo Fixo                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function ATF090Reav()

Private aLinSN1		:= Nil
Private aLinRecSN3	:= Nil

If Pergunte("AFA090",.T.) .And. ATF090Tela(STR0005, .T.) == 1 //"Reavalicao de Ativo"
	dbSelectArea("SN0")
	SN0->(dbSetOrder(1))	
	If !SN0->(MsSeek(xFilial('SN0')+'10'+MV_PAR07))
		MsgInfo(STR0016) //"Motivo da reavalia��o invalido, escolha um motivo de reavalia��o valido"
	ELSE
		MsAguarde({||Reavaliar(.T.)},STR0006) //"Aguarde! Reavaliando os Ativos..."
	EndIf	                                                                                                                                                                           
EndIf	                                                                                                                                                                           
Return .T.
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AFF090Reve�Author �Alexandre Silva     � Date �  07-07-03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Programa para fazer o calculo da revercao da reavalicao dos ���
���          �itens de ativo.                                             ���
�������������������������������������������������������������������������͹��
���Uso       � Ativo Fixo                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function ATF090Reve()

Private aLinSN1		:= Nil
Private aLinRecSN3	:= Nil


If Pergunte("AFA090REV",.T.) .And. ATF090Tela(STR0007, .F.) == 1 //"Reversao da Reavaliacao de Ativos"
	MsAguarde({||Reavaliar(.F.)},STR0008) //"Aguarde! Revertendo a reavaliacao..."
EndIf	

Return .T.
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATF090Tela�Author �Alexandre Silva     � Date �  07-07-03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Programa para fazer o calculo da revercao da reavalicao dos ���
���          �itens de ativo.                                             ���
�������������������������������������������������������������������������͹��
���Uso       � Ativo Fixo                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function ATF090Tela(cTitulo,lReav)

Local cBLinSN1 	:= ""
Local nOpca		:= 0 
Local lInverte	:= .T.

Local aATFDados	:= ATF090Load(lReav)
Local aCoordIn	:= {34,1,143,315}
Local aCoordExt := {9,0,28,80}
Local aCabSN1   := aATFDados[1]
Local aTamSN1	:= {5,50}

Private oOk		:= LoadBitMap(GetResources(), "LBOK")
Private oNo		:= LoadBitMap(GetResources(), "LBNO")
Private oBrowse	:= Nil

aLinSN1			:= aATFDados[2]
aLinRecSN3		:= aATFDados[4]

If Len(aLinSN1) > 0
	DEFINE MSDIALOG oDlgMark TITLE cTitulo FROM aCoordExt[1],aCoordExt[2] TO aCoordExt[3],aCoordExt[4]
	
	@ 1.3,1.3 Say STR0009 //"Selecione os itens para reavaliar."
	
	oBrowse				:= TwBrowse():New(030,010,297,110,,aCabSN1,aTamSN1, oDlgMark,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrowse:lColDrag	:= .T.                            
	oBrowse:nFreeze		:= 1
	oBrowse:SetArray(aLinSN1)
	oBrowse:bLDblClick 	:= { || iIF(aLinSN1[oBrowse:nAt,1]== 0, ( aLinSN1[oBrowse:nAt,1]:=iIf(AtfSelReav( aLinSN1[oBrowse:nAt,2], aLinSN1[oBrowse:nAt,3]) ,1, 0)), aLinSN1[oBrowse:nAt,1] := 0)}
	oBrowse:bLine		:= { || &(aATFDados[03]) }
	
	ACTIVATE MSDIALOG oDlgMark CENTERED ON INIT	EnchoiceBar(oDlgMark,;
			{ || nOpca:=1,oDlgMark:End()},;
			{ || nOpca:=0,oDlgMark:End()})
Else
	MsgInfo(STR0010)		 //"Nao existem ativos para reavaliacao. Verique as perguntas."
EndIf
	
Return nOpca
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Reavaliar �Author �Alexandre Silva     � Date �  07-07-03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Programa para fazer o calculo da reavaliacao dos itens de   ���
���          �ativo.                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � Ativo Fixo                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function Reavaliar(lReavaliar)

Local aAtfCab 	:= 	{}
Local aAtfItens	:= 	{}
Local aStruSN1 	:=	LoadStru("SN1")
Local aStruSN3 	:= 	LoadStru("SN3")
Local nPosSeq	:=	0
Local nPosItem	:=	0
Local nPosTipo	:=	0
Local nItens	:=	0
Local nTaxaRea	:=	0
Local lReverte	:= .F.
Local cTipoAnt	:= ""
Local cSequen	:= ""
Local nZ		:= 1
Local nA		:= 1

Local nElementoA:= 0  
Local nElementoB:= 0
Local lTipReav	:= .T.
Local nPosSeqRea:= Ascan( aStruSN3, {|x| x[2] == "N3_SEQREAV" })
Local nValorMaior:= 0
Local nValorLido := 0
Local cHistorico := IIf(lReavaliar, MV_PAR06, "")
Local cMotivo    := IIf(lReavaliar, MV_PAR07, "")
Local nMVPAR05	 := 0

Private lMsErroAuto	:=	.F.

/*��������������������������������������������������������������Ŀ
  �Ponto para informacao da taxa de reavalicao da depreciacao.   �
  ����������������������������������������������������������������*/

If Existblock("ATF90TAX") .And. lReavaliar
	nTaxaRea	:= ExecBlock("ATF90TAX",.F.,.F.)
Endif

For nItens := 1 To Len(aLinSN1)

	dbSelectArea("SN1")
	dbSetOrder(1)
	/*/�������������������������������������������������������Ŀ
	  �Preparacao do array dos itens que ja EXISTAM.          �
	  ���������������������������������������������������������/*/
	If aLinSN1[nItens,1] == 1 .And. SN1->(dbSeek(xFilial("SN1")+aLinSN1[nItens,2]+aLinSN1[nItens,3]))
		/*/�������������������������������������������������������Ŀ
		  �Preparacao do cabecalho SN1                            �
		  ���������������������������������������������������������/*/
  		For nZ := 1 To Len(aStruSN1)
			AADD(aAtfCab,{aStruSN1[nZ,2],&(aStruSN1[nZ,2]),NIL})
		Next nZ
   		dbSelectArea("SN3")
		dbSetOrder(1)
		
		If lReavaliar

	        SN3->(dbgoto(aLinRecSN3[nItens,1])) //dados com a mesma estrutura da vari�vel aLinSN1

			/*�������������������������������������������������������Ŀ
			 �Preparacao dos itens  SN3                              �
			���������������������������������������������������������*/
	  		AADD(aAtfItens,{})
			For nZ := 1 To Len(aStruSN3)           
  				AADD(aAtfItens[Len(aAtfItens)],{aStruSN3[nZ,2],If(aStruSN3[nZ,9]=="Zero",0 ,&(aStruSN3[nZ,2])) ,NIL})
			Next nZ

			/*��������������������������������������������������������������Ŀ
			 �Ponto para informacao da taxa de reavalicao por Item.         �
			����������������������������������������������������������������*/
	  		If Existblock("AF90TAXI")
				nTaxaRea := ExecBlock("AF90TAXI",.F.,.F.,nTaxaRea)
		 	Endif
			/*�������������������������������������������������������Ŀ
			 �Adicao do vetor para a reavaliacao dos itens.          �
			 �E passado o vetor anterior como base para atualizacao. �
			 �So sao atualizados as posicoes que influenciam na rea- | 
			 �valiacao do bem.                                       �
			���������������������������������������������������������*/
			AADD(aAtfItens,{})
			aAtfItens := {AddReava(aClone(aAtfItens[(Len(aAtfItens))-1]),nTaxaRea,cHistorico,cMotivo)}
			/*�����������������������������������������������������������������������������Ŀ
			 �Para utilizacao da rotina automatica e necessario a inclusao do campo N3_SEQ.�
			�������������������������������������������������������������������������������*/
			nPosSeq := Ascan(aAtfItens[Len(aAtfItens)],{|aItens| Alltrim(aItens[1]) == "N3_SEQ" })
			aAtfItens[Len(aAtfItens),nPosSeq,2]	:= ""
			nPosSeq := Ascan(aAtfItens[Len(aAtfItens)],{|aItens| Alltrim(aItens[1]) == "N3_DINDEPR" })
			aAtfItens[Len(aAtfItens),nPosSeq,2]	:= dDataBase
			nPosSeq := Ascan(aAtfItens[Len(aAtfItens)],{|aItens| Alltrim(aItens[1]) == "N3_TIPO" })
			cTipoAnt:=aAtfItens[Len(aAtfItens),nPosSeq,2]
			/*��������������������������������������������������������������������������������Ŀ
			 �Este item foi adicionado para compatibilizacao da rotina automatica. MsGetDAuto.�
			����������������������������������������������������������������������������������*/
		Else

			// Order(1) N3_FILIAL+     N3_CBASE+     N3_ITEM+ N3_TIPO+ N3_BAIXA+ N3_SEQ
			SN3->(dbSeek(SN1->N1_FILIAL+SN1->N1_CBASE+SN1->N1_ITEM+ "01"+   "0"))
			
			Do While ! SN3->(Eof()) .And. SN1->N1_FILIAL+SN1->N1_CBASE+SN1->N1_ITEM == N3_FILIAL+N3_CBASE+N3_ITEM//Itens
				/*�������������������������������������������������������Ŀ
				 �Preparacao dos itens  SN3                              �
				���������������������������������������������������������*/
				AADD(aAtfItens,{})
	  			For nZ := 1 To Len(aStruSN3)           
					AADD(aAtfItens[Len(aAtfItens)],{aStruSN3[nZ,2], &(aStruSN3[nZ,2]) ,NIL})
		  		Next nZ
				SN3->(dbSkip())
			EndDo
			/*���������������������������������������������������������Ŀ
			  �Localizar a ultima reavalicao para exclusao.             |
			  �����������������������������������������������������������*/
			nPosTipo := Ascan(aAtfItens[Len(aAtfItens)],{|aItens| Alltrim(aItens[1]) == "N3_TIPO" })
			For nA := Len(aAtfItens) To 1 Step -1
				If Alltrim(aAtfItens[nA,nPosTipo,2])== "02"
					AADD(aAtfItens[nA] ,{"AUTDELETA","S",NIL})
					/*��������������������������������������������������������������������������������Ŀ
					�Este item foi adicionado para compatibilizacao da rotina automatica. MsGetDAuto.�
					����������������������������������������������������������������������������������*/
				  	lReverte	:= .T.
					Exit
 				EndIf					
			Next nA				
	 	EndIf			
		
		/*���������������������������������������������Ŀ
		  �Execucao da rotina automatica 4 Alteracao    �
		  �����������������������������������������������*/
		If lReavaliar .Or. lReverte
			nMVPAR05 := MV_PAR05 // A rotina ATFA012 ao ser executada altera o MV_PAR05, mudando a tx de reavalia��o.
  		 	MSExecAuto({|x,y,z| Atfa012(x,y,z)},aAtfCab,aAtfItens,4)
			aAtfCab 	:= 	{}
	  		aAtfItens	:= 	{}
			MV_PAR05 := nMVPAR05 // Devolvo o conteudo correto do MV_PAR05 depois do execauto.
			If lMsErroAuto
				DisarmTransaction()
  				MostraErro()
				Exit
	  		Endif
         
            If lReavaliar	//Grava��o do nro sequencial do campo N3_SEQREAV
							//Order(1) N3_FILIAL+     N3_CBASE+     N3_ITEM+ N3_TIPO+ N3_BAIXA+ N3_SEQ
				dbSelectArea("SN3")
				SN3->(dbSeek(SN1->N1_FILIAL+SN1->N1_CBASE+SN1->N1_ITEM+ "02" ))
				nValorMaior :=0

				Do While ! SN3->(Eof()) .And. SN1->N1_FILIAL+SN1->N1_CBASE+SN1->N1_ITEM == N3_FILIAL+N3_CBASE+N3_ITEM//Itens
					If SN3->N3_TIPO = "02"
						nValorMaior := if( Val(SN3->N3_SEQREAV) > nValorMaior, Val(SN3->N3_SEQREAV), nValorMaior)
					    If Empty(SN3->N3_SEQREAV)
							RecLock("SN3", .F.)
							SN3->N3_SEQREAV := STRZERO(nValorMaior+1, len(SN3->N3_SEQREAV) )                       
							MsUnlock()
							Exit
						Endif
					Endif
					SN3->( dbSkip() )
				Enddo   
			Endif
		EndIf
 	EndIf
   	lReverte	:= .F.
Next nItens 

If ! lMsErroAuto
	If lReavaliar
		MsgInfo(STR0011) //"Revaliacao dos ativos completa."
	Else
		MsgInfo(STR0012) //"Reversao da reavaliacao completa."
	EndIf
EndIf	

Return .T.
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AddReava  �Author �Alexandre Silva     � Date �  07-07-03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Faz a montagem da matriz com o item da reavaliacao.         ���
�������������������������������������������������������������������������͹��
���Uso       � Ativo Fixo                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function AddReava(aNovoItem,nTaxaReava,cHistorico,cMotivo)

Local dDataImp	:= 	cTod("")
Local nMesesDep	:=	0 
Local nPos		:=	0
Local nTaxReaAnu:=	iiF(nTaxaReava == 0,MV_PAR05,nTaxaReava)

//********************************
// Controle de multiplas moedas  *
//********************************
Local aTaxDepAnu:=	If(lMultMoed, AtfMultMoe(,,{|x| 0 }) , {0,0,0,0,0} ) 
Local aVlrDepAcu:=	If(lMultMoed, AtfMultMoe(,,{|x| 0 }) , {0,0,0,0,0} ) 
Local aVlrImp	:=	If(lMultMoed, AtfMultMoe(,,{|x| 0 }) , {0,0,0,0,0} ) 
Local aVlrRea	:=	If(lMultMoed, AtfMultMoe(,,{|x| 0 }) , {0,0,0,0,0} ) 
//********************************
// Controle de multiplas moedas  *
//********************************
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)
Local aAtuCamp	:= 	{{},{},{}}
Local nX                                              
Local cTipReav := GetMv("MV_ATFMTRV",.F.,"1")
Local nVlrOrig := 0
Local nVlrDAcm := 0
Local nTxDAnual:= 0
Local lTipReav	:= .T.
Local lVMXDepr	:= .T.

Default cHistorico := MV_PAR06
Default cMotivo	   := MV_PAR07

/*�������������������������������������������������������Ŀ
  �Verificacao da movimentacao dos itens SN4              �
  ���������������������������������������������������������*/

//********************************
// Controle de multiplas moedas  *
//********************************
If lMultMoed
	AtfMultMoe(,,{|x| aAdd( aAtuCamp[1] , "N3_VORIG"+Alltrim(Str(x)) ) })
	AtfMultMoe(,,{|x| aAdd( aAtuCamp[2] , If(x>9,"N3_VRDAC","N3_VRDACM")+Alltrim(Str(x)) ) })
	AtfMultMoe(,,{|x| aAdd( aAtuCamp[3] , "N3_TXDEPR" + Alltrim(Str(x)) ) })
Else
	aAtuCamp	:= {{"N3_VORIG1" ,"N3_VORIG2" ,"N3_VORIG3" ,"N3_VORIG4" ,"N3_VORIG5" },;
					{"N3_VRDACM1","N3_VRDACM2","N3_VRDACM3","N3_VRDACM4","N3_VRDACM5"},;
					{"N3_TXDEPR1","N3_TXDEPR2","N3_TXDEPR3","N3_TXDEPR4","N3_TXDEPR5"}}
EndIf

dbSelectArea("SN4")
dbSetOrder(1)
If SN4->(dbSeek(SN1->N1_FILIAL+SN1->N1_CBASE+SN1->N1_ITEM))
	SN3->(dbSetOrder(1))
	SN3->(dbSeek(SN1->N1_FILIAL+SN1->N1_CBASE+SN1->N1_ITEM))
	//********************************
	// Controle de multiplas moedas  *
	//********************************
	If lMultMoed
		aTaxDepAnu	:= AtfMultMoe("SN3","N3_TXDEPR")
		aVlrImp		:= AtfMultMoe("SN3","N3_VORIG")
	Else
		aTaxDepAnu	:=	LeMultVal("SN3->N3_TXDEPR")
		aVlrImp		:=	LeMultVal("SN3->N3_VORIG") 
	EndIf
	dDataImp	:= 	N4_DATA

			//********************************
			// Controle de multiplas moedas  *
			//********************************
    // Taxa de Reavalia��o - nTaxReaAnu

	For nX := 1 To __nQuantas

		aVlrRea[nX]	:= ( aVlrImp[nX] * ( nTaxReaAnu / 100) ) 

		nVlrOrig	:= SN3->&(aAtuCamp[1][nX])	//Valor original
		nVlrDAcm	:= SN3->&(aAtuCamp[2][nX])	//Valor da Deprecia��o Acumulada
		nTxDAnual	:= SN3->&(aAtuCamp[3][nX])	//Taxa de deprecia��o anual

		If cTipReav == '1'		// Com reavalia��o da taxa
            If  nTxDAnual > 0 .And.;
                nVlrOrig  > 0 .And.;
                nVlrDAcm  > 0

				nElementoA		:= ( 100 / nTxDAnual )  
				nElementoB		:= ( (nVlrDAcm / nVlrOrig ) * 100 / nTxDAnual ) 

                If (nElementoA - nElementoB) <> 0
		            aTaxDepAnu[nx]	:= (100 / (nElementoA - nElementoB) )
                Else
		            aTaxDepAnu[nx]	:= 0
                Endif
			Else
	            aTaxDepAnu[nx]	:= 0
			Endif
			aVlrDepAcu[nX]		:= 0

		ElseIf cTipReav == '2'	// Com reavalia��o depreciacao acumulada
			aVlrDepAcu[nX]	:= ( nVlrDAcm * ( nTaxReaAnu / 100) )
            aTaxDepAnu[nx]	:= nTxDAnual

		Else
			aVlrDepAcu[nX]	:= 0
            aTaxDepAnu[nx]	:= nTxDAnual
		EndIf 
		
		/*�������������������������������������������������������Ŀ
		  �Atualiza o valor da depreciacao.                       �
		  ���������������������������������������������������������*/
		nPos := Ascan(aNovoItem,{ |aItem | Alltrim(aItem[1]) == aAtuCamp[1,nX]})
		aNovoitem[nPos,2] := aVlrRea[nX]
		/*�������������������������������������������������������Ŀ
		  �Faz a correcao da depreciacao.                         �
		  ���������������������������������������������������������*/
		nPos := Ascan(aNovoItem,{ |aItem | Alltrim(aItem[1]) == aAtuCamp[2,nX]})
		aNovoitem[nPos,2] := aVlrDepAcu[nX] 
		
		//�������������������������������������Ŀ
		//�Faz a corre��o da taxa da depreciacao�
		//���������������������������������������		
		nPos := Ascan(aNovoItem,{ |aItem | Alltrim(aItem[1]) == aAtuCamp[3,nX]})
		aNovoitem[nPos,2] := aTaxDepAnu[nX] 		
				
	Next nX
	
	nPos := Ascan(aNovoItem,{ |aItem | Alltrim(aItem[1]) == "N3_TIPO"})
	aNovoitem[nPos,2] := "02" //Reavalicao
	nPos := Ascan(aNovoItem,{ |aItem | Alltrim(aItem[1]) == "N3_DINDEPR"})
	aNovoitem[nPos,2] := dDataImp //Data da implementacao do bem.
	nPos := Ascan(aNovoItem,{ |aItem | Alltrim(aItem[1]) == "N3_HISTOR"})
	aNovoitem[nPos,2] := cHistorico //Historico da depreciacao do bem.

	If lVMXDepr
		nPos := Ascan(aNovoItem,{ |aItem | Alltrim(aItem[1]) == "N3_VMXDEPR"})                        
		//----------------------
		//SN3->&(aAtuCamp[nPos][nX])
		//------------------------
		aNovoitem[nPos,2] := ( aNovoitem[nPos,2] * ( nTaxReaAnu / 100) )	//Valor Maximo de Deprecia��o 
	Endif

	nPos := Ascan(aNovoItem,{ |aItem | Alltrim(aItem[1]) == "N3_TIPREAV"})
	aNovoitem[nPos,2] := cMotivo	//Motivo da Reavaliacao
EndIf

Return aNovoItem
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeMulVal  �Author �Alexandre Silva     � Date �  07-07-03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Le os valores, nas 5 moedas possiveis para calculo da depre-���
���          �ciacoes.                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Substituida pela fun��o AtfMultMoed                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function LeMultVal(cCampPref)

Local aTempArea	:= Afill(Array(NUM_MOEDAS),0)
Local nX

For nX := 1 To NUM_MOEDAS
	aTempArea[nX]	:=  &(cCampPref+Alltrim(Str(nX)))
Next nX

Return aTempArea
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATF090Load�Author �Alexandre Silva     � Date �  07-07-03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Faz a montagem da matriz de cabecalho e carrega os registros���
���          �que foram selecionados pelo usuario atraves dos parametros. ���
�������������������������������������������������������������������������͹��
���Uso       � Ativo Fixo                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function ATF090Load(lReav)

Local cPict		:= ""
Local cPicRea 	:= 	PesqPict("SN3","N3_TXDEPR1")
Local cbLinha	:= ""//Propriedade bLine da TwBrowse 
Local cAtivoDe	:= MV_PAR01
Local cAtivoAte	:= MV_PAR02
Local cItemDe	:= MV_PAR03
Local cItemAte	:= MV_PAR04
Local nTaxaRea	:= MV_PAR05 
Local cGrupode  //:= MV_PAR08
Local cGrupoate //:= MV_PAR09
Local cFilUser	:= ".T."
Local cTeste	:= ""
Local aCabTit 	:= {}
Local aLinDet	:= {}
Local aLinRecSN3:= {}
Local aCampos	:= {"nSEL","N1_CBASE","N1_ITEM","N1_DESCRIC","N1_CHAPA","nREAVA"}
Local lRet		:= .T.
Local oErro		:= Nil
Local nX := 1
Local aArea		:= {}

If lReav
	aArea := GetArea()
	
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))		//X1_GRUPO+X1_ORDEM
	If SX1->(dbSeek(Padr("AFA090",Len(SX1->X1_GRUPO))+"09"))
		cGrupode  := MV_PAR08
		cGrupoate := MV_PAR09
	Else
		cGrupode  := MV_PAR07
		cGrupoate := MV_PAR08
	EndIf
	
	RestArea(aArea)
Else
	cGrupode  := Space(TamSX3("N1_GRUPO")[1])
	cGrupoate := Replicate("Z",TamSX3("N1_GRUPO")[1])
EndIf

/*������������������������������������������Ŀ
  �Ponto de entrada para o filtro do usuario.�
  ��������������������������������������������*/
If Existblock("ATF90FI")
	cFilUser:= ExecBlock("ATF90FI",.F.,.F.)
	oErro 	:= ErrorBlock({|e| Alert(STR0013+chr(13)+STR0014),lRet:= .F.}) //"Erro no filtro de usuario."###"Filtro de usuario cancelado."
	cTeste	:= &cFilUser
	ErrorBlock(oErro)
	If !lRet
		cFilUser	:= ".T."
	EndIf		
Endif

/*������������������������������������������Ŀ
  �Montagem do cabecalho.                    �
  ��������������������������������������������*/
For nX := 1 To Len(aCampos)
	/*������������������������������������������Ŀ
	  �Se comecar com N1, Usar a RetTile.        �
	  ��������������������������������������������*/
	If Subs(aCampos[nX],1,3) == "N1_"
		AADD(aCabTit,Rtrim(RetTitle(aCampos[nX])))
		cPict	:= PesqPict("SN1",aCampos[nX])
		cbLinha += ", Transform(aLinSN1[oBrowse:nAT][" + AllTrim(Str(nX))+ "], '" + cPict + "')"
	Else
		Do Case
		Case aCampos[nX]== "nSEL"
			AADD(aCabTit," ")
			cbLinha	:= "{IIF(aLinSN1[oBrowse:nAt,1] > 0,oOk,oNo)"
		Case aCampos[nX]== "nREAVA"
			AADD(aCabTit,Rtrim(RetTitle("N4_TXDEPR")))
			cbLinha += ", Transform(aLinSN1[oBrowse:nAT][" + AllTrim(Str(nX))+ "], '" + cPicRea + "')"
		EndCase		
	EndIf
Next nX

cbLinha += "}"

SN1->(dbSeek(xFilial("SN1")+cAtivoDe))
SN3->(dbSetOrder(1))
Do While xFilial() == SN1->N1_FILIAL .And.;
	(SN1->N1_CBASE >= cAtivoDe .And. SN1->N1_CBASE <= cAtivoAte) .And. ;
	(SN1->N1_GRUPO >= cGrupode .And. SN1->N1_GRUPO <= cGrupoAte) .And. !SN1->(EOF())
	Do Case
		Case ! &cFilUser
			SN1->(dbSkip())
			Loop
		Case SN1->N1_ITEM  < cItemDe .Or. SN1->N1_ITEM  > cItemAte
			SN1->(dbSkip())
			Loop
		Case SN1->N1_STATUS $ "2|3" 
			SN1->(dbSkip())
			Loop
		Case ATFXVerPrj(SN1->N1_CBASE,SN1->N1_ITEM)
			SN1->(dbSkip())
			Loop
	EndCase
			
	AADD(aLinDet,    {})
	AADD(aLinRecSN3, {})

	For nX := 1 To Len(aCampos)
		/*������������������������������������������Ŀ
		  �Se comecar com N1, Usar a RetTile.        �
		  ��������������������������������������������*/
		If Subs(aCampos[nX],1,3) == "N1_" 
			AADD(aLinDet[Len(aLinDet)],&("SN1->"+aCampos[nX]))
		Else
			Do Case
				Case aCampos[nX]== "nSEL"
					AADD(   aLinDet[Len(aLinDet)], Iif(ATFSelReav(), 1, 0) )
					AADD(aLinRecSN3[Len(aLinDet)], SN3->(Recno()) )
				Case aCampos[nX]== "nREAVA"
					AADD(aLinDet[Len(aLinDet)],nTaxaRea)
			EndCase
		EndIf
	Next nX
	SN1->(dbSkip())
EndDo

Return {aCabTit,aLinDet,cbLinha,aLinRecSN3}

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Program   �LoadStru  �Author �Alexandre Silva     � Date �  07-08-03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta o a Header especifico para a rotina automatica.       ���
�������������������������������������������������������������������������͹��
���Use       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function LoadStru(cAlias)

Local aAreaAnt	:= GetArea()

Local aStru 	:= {}
Local cCampoZero:="Zero"

dbSelectArea("SX3")
dbSetOrder(1)
SX3->(dbSeek(cAlias))

While ! SX3->(Eof()) .And. (SX3->X3_ARQUIVO == cAlias)
	If  X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .and. SX3->X3_CONTEXT <> "V" .Or.;
		Rtrim(X3_CAMPO) == "N3_SEQ" .Or. Rtrim(X3_CAMPO) == "N3_CBASE" .Or. Rtrim(X3_CAMPO) == "N3_ITEM".Or. Rtrim(X3_CAMPO) == "N3_TIPREAV" 
		If cAlias == "SN1"
		  	If Alltrim(X3_CAMPO) == "N1_CBASE" .Or. Alltrim(X3_CAMPO) == "N1_ITEM"
				AADD(aStru,{TRIM(X3TITULO()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID ,SX3->X3_USADO ,SX3->X3_TIPO ,SX3->X3_ARQUIVO ,SX3->X3_CONTEXT})
			EndIF
		Else
			If Alltrim(X3_CAMPO) != "N3_TPDEPR"
   				// Alterado para conter parte do nome do campo "N3_VORIG" ou nome do arquivo "SN3" .Procura se o nome finaliza com numeros
   				cCampoZero := SX3->X3_ARQUIVO
	 			if Subs(X3_CAMPO, Len(Trim(X3_CAMPO)),1) $ "0123456789"
					cCampoZero := "Zero"
				Endif
				AADD(aStru,{TRIM(X3TITULO()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID ,SX3->X3_USADO ,SX3->X3_TIPO ,cCampoZero ,SX3->X3_CONTEXT})
			EndIf
		EndIf
	EndIf
	SX3->(dbSkip())
EndDo

RestArea(aAreaAnt)

Return aStru

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �10/12/06 ���
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
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados   		  ���
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
Local aRotina 		:= {{STR0002,"AxPesqui"			, 0, 1},; //"Pesquisar"
						{STR0015,"VIEWDEF.ATFA012"	, 0, 2},; //"Visualizar"
						{STR0003,"ATF090Reav" 		, 0, 2},; //"Reavaliar"
						{STR0004,"ATF090Reve"		, 0, 2}} //"Reverter"
Return(aRotina)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Program   �ATFSelReav �Author �Alexandre Silva    � Date �  07-08-03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta o a Header especifico para a rotina automatica.       ���
�������������������������������������������������������������������������͹��
���Use       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ATFSelReav( CBASE, CITEM )

Local aAreaAnt	:= GetArea()
Local lRet		:= .F.
Local lOnAlert  := !(CBASE = Nil)

Default CBASE	:= SN1->N1_CBASE
Default CITEM	:= SN1->N1_ITEM

dbSelectArea("SN3")
dbSetOrder(1)

// dbSeek(SN1->N1_FILIAL+SN1->N1_CBASE+SN1->N1_ITEM)
//                                                    01=Requis+  "0"=Nao baixado
// Order(1)   N3_FILIAL+       N3_CBASE+   N3_ITEM+   N3_TIPO  +   N3_BAIXA+ N3_SEQ
lRet := dbSeek( xFILIAL("SN1")+   CBASE+     CITEM+   "01"+       "0")

If !lRet .And. lOnAlert
   Help(" ",1,"ATFREAV01")
Endif   

If lRet .And. SN1->N1_STATUS $ "2|3" 
	Help(" ",1,"A090BLOQ")
	lRet := .F.
EndIf

If lRet .And. ATFXVerPrj(SN1->N1_CBASE,SN1->N1_ITEM, .T. ) 
	lRet := .F.
EndIf

RestArea(aAreaAnt)
Return lRet
