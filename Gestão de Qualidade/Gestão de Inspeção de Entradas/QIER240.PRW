#INCLUDE "QIER240.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QIER240	� Autor � Antonio Aurelio       � Data � 04.07.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Etiqueta de Rastreabilidade            					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � QIER240(cProg)                                			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAQIE  												  ���
�������������������������������������������������������������������������Ĵ��
��� STR		 � Ultimo utilizado: 0011                                     ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Vera        �04/08/99������ĳ Inclusao funcao AjustaSX1()              ���
���Antonio     �24/08/99������ĳ Inclusao funcao QA_AjusSX1() (QAXFUN.PRX)���
���            �        �      � Esta funcao corresponde a versao generica���
���            �        �      � da AjustaSX1                             ���
���Vera        �23/09/99������ĳ Impressao a pertir do vetor - import. ent���
���Paulo Emidio�18/05/00�------�Retirada da Funcao de ajuste do SX1       ���
���Paulo Emidio�28/05/01�META  � Alterado programa para que possa ser sele���
���       	   �		�	   � cionado o Tipo da Nota Fiscal de Entrada ���
���       	   �		�	   � sendo a mesma 1)Normal 2)Beneficiamento  ���
���       	   �		�	   � 3)Devolucao.							  ���
���Paulo Emidio�01/06/01�009300� Alterado programa para que nao seja efe- ���
���			   �        �      � tuado o salto de pagina ao termino da im-���
���			   �		�	   � pressao das etiquetas.					  ���
���Aldo        �30/01/02�------� Incluido na IndRegua ".And." nos ultimos ���
���            �        �      � parametros.                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QIER240(cProg,nMv_par11,nMv_par12,aVetQEK,aGravDad,lImpFic)

//���������������������������������������������������������������������������Ŀ
//� Se for chamado pelo cadastro Entradas ou pelo menu, nao passa o vetor com �
//� a chave de cada Entrada 												  � 
//� Se for chamado pela importacao, passa o vetor com as Entradas para a im-  �
//� pressao das etiquetas. 													  �
//�����������������������������������������������������������������������������

//���������������������������������������������������������������������������Ŀ
//�  Par�metros para a fun��o SetPrint () 									  �
//�����������������������������������������������������������������������������
Local wnrel 	:= "QIER240"
Local cString	:= "QEK"
Local cDesc1	:= STR0001 //"Ser�o impressas as etiquetas de rastreabilidade "
Local cDesc2	:= STR0002 //"da Entrada."
Local cDesc3	:= ""

//���������������������������������������������������������������������������Ŀ
//�  Guarda aquivo e indices correntes	 									  �
//�����������������������������������������������������������������������������
Local cAlias    := Alias()
Local nOldOrder := IndexOrd()

//���������������������������������������������������������������������������Ŀ
//�  Par�metros para a fun��o SetPrint	 									  �
//�����������������������������������������������������������������������������
Private cTitulo	 := STR0003	// "Etiqueta de Rastreabilidade"
Private cTamanho := "P"
Private nPagina	 := 1

//���������������������������������������������������������Ŀ
//� Vari�veis utilizadas pela fun��o SetDefault e SetPrint  �
//�����������������������������������������������������������
Private aReturn  := {STR0004, 1,STR0005,  1, 2, 1, "",1 }  //"Zebrado"###"Administracao"
Private nLastKey := 0
Private cPerg    := "QER240"
Private nRecno   := QEK->(Recno())
Private lEnd     := .F.
Private nLimite  := 80

Default cProg := "QIER240"

//���������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros					      �
//� mv_par01			  // Fornecedor de					      �
//� mv_par02			  // Fornecedor ate		    		      �
//� mv_par03			  // Loja Fornecedor de	 			      �
//� mv_par04			  // Loja Fornecedor ate   			      �
//� mv_par05			  // Produto de						      �
//� mv_par06			  // Produto ate 					      �
//� mv_par07			  // Data Entrada de				      �
//� mv_par08              // Data Entrada ate                     �
//� mv_par09              // Lote de                              �
//� mv_par10              // Lote ate                             �
//� mv_par11              // Assumir Tam.Lote                     �
//� mv_par12              // N� de Etiquetas se Nao Usar Tam.Lote �
//� mv_par13              // Considera Entradas? 1)Normal		  �
//�           		      //  					 2)Beneficiamento �
//�            			  //  					  3)Devolucao     �
//�����������������������������������������������������������������
Pergunte(cPerg,.F.)

If cProg $ "QIEA200.QIER220"	// Cad.Entradas ou importacao Entradas
	mv_par11 := nMv_par11
	mv_par12 := nMv_par12                                        
	mv_par13 := 1
	cPerg    := ""  // Desabilita a pergunte
Else
	mv_par13 := 1
EndIf

// �������������������������������������������������������Ŀ
// � Assume valores caso usu�rio nao digite ou digite zero �
// ���������������������������������������������������������
IIF(mv_par11<1,mv_par11:=1,)
IIF(mv_par12<1,mv_par12:=1,)

IIF(cProg== NIL, cProg := "",)

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT 				  		 �
//����������������������������������������������������������������
wnrel := SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho,"",.F.)

//�������������������������������������Ŀ
//� Verifica se apertou o botao cancela �
//���������������������������������������
If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Return .F.
EndIf

RptStatus({|lEnd| A240Imp(@lEnd,wnRel,cString,cProg,aVetQEK,aGravDad,lImpFic)},cTitulo)

//�������������������������������������Ŀ
//� Restaura o arq anterior             �
//���������������������������������������
dbSelectArea(cAlias)
dbSetOrder(nOldOrder)
dbGoto(nRecNo)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � A240Imp  � Autor � Antonio Aurelio       � Data � 04.05.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime as Etiquetas dos Produtos da Entrada               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd  - Verifica se o foi cancelada a impressao            ���
���			 � wnRel - Usada na fun��o OurSpool                           ���
���			 � cProg - Usada na verifica��o do prmg chamador desta fun��o ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � 															  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � QIER240                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A240Imp(lEnd,wnRel,cString,cProg,aVetQEK,aGravDad,lImpFic)
Local lImp	   := .T.
Local nOrdQEK  := QEK->(IndexOrd())
Local nIEnt	   := 0
Local cIndex1			:= ""
Local cFiltro			:= ""
Local cKey				:= ""

Private nLin  := 0
Private cTamLot  := ""

SetPrc(00,00)

dbSelectArea("QEK")
dbSetOrder(1)

//������������������������������������������Ŀ
//� Impressao a partir do menu de Relatorios �
//��������������������������������������������
If !cProg $ "QIEA200.QIER220"

	//�������������������������������������������������Ŀ
	//� Cria Indice Condicional nos arquivos utilizados �
	//���������������������������������������������������

	cIndex1 := CriaTrab( Nil, .F. )

	cKey:=IndexKey()
	cFiltro := 'QEK_FILIAL == "'+xFilial("QEK") +'"'
	cFiltro += '.And. QEK_FORNEC >="'+mv_par01+'".And. QEK_FORNEC <="'+mv_par02+'".And.'
	cFiltro += 'QEK_LOJFOR >="'+mv_par03+'".And. QEK_LOJFOR <="'+mv_par04+'".And.'
	cFiltro += 'QEK_PRODUT >="'+mv_par05+'".And. QEK_PRODUT <="'+mv_par06+'".And.'
	cFiltro += 'DTOS(QEK_DTENTR) >="'+DTOS(mv_par07)+'".And.DTOS(QEK_DTENTR) <="'+DTOS(mv_par08)+'".And.'
	cFiltro += 'QEK_LOTE >="'+mv_par09+'".And. QEK_LOTE <="'+mv_par10+'"'

	//Filtra o tipo da Entrada
	If mv_par13 == 1
		cFiltro += ' .And. (QEK_TIPONF == "N"'+'.Or.QEK_TIPONF == " ")'
	ElseIf mv_par13 == 2
		cFiltro += ' .And. QEK_TIPONF == "B"'
	ElseIf mv_par13 == 3
		cFiltro += ' .And. QEK_TIPONF == "D"'
	EndIf	

	IndRegua("QEK",cIndex1,cKey,,cFiltro,STR0006)	//"Selecionando Registros.."
	nIndex := RetIndex("QEK")

 	dbSetOrder(nIndex+1)
	dbSeek( xFilial( "QEK" ) )
			
	A240ImEt(lEnd,wnRel,cString,cProg)

Else
	//��������������������������������������������Ŀ
	//� Impressao a partir do cadastro de Entradas �
	//����������������������������������������������
	If aVetQEK == NIL

		// Reposiciona o QEK
		QEK->(dbGoTo(nRecNo))
		mv_par01 := QEK->QEK_FORNEC
		mv_par02 := QEK->QEK_FORNEC
		mv_par03 := QEK->QEK_LOJFOR
		mv_par04 := QEK->QEK_LOJFOR
		mv_par05 := QEK->QEK_PRODUT
		mv_par06 := QEK->QEK_PRODUT
		mv_par07 := QEK->QEK_DTENTR
		mv_par08 := QEK->QEK_DTENTR
		mv_par09 := QEK->QEK_LOTE
		mv_par10 := QEK->QEK_LOTE
		//�����������������������������������������Ŀ
		//� Utiliza o Tam.Lote corrente ou assume   �
		//�   o informado na pergunte mv_par12      �
		//�������������������������������������������
		If mv_par11 == 1
			cTamLot := QEK->QEK_TAMLOT
			//�����������������������������������������Ŀ
			//� Troca a virgula por ponto outros        �
			//�   caracteres sao bloqueados no cadastro �
			//�������������������������������������������
			If AT(",",cTamLot) > 0
				cTamLot := StrTran(cTamLot,",",".")
			EndIf
			//����������������������������������������������Ŀ
			//� Se o Tam.Lote nao for inteiro � adicionado   �
			//�  uma etiqueta a mais                         �
			//������������������������������������������������
			If Int(SuperVal(cTamLot)) == SuperVal(cTamLot)
				mv_par12 := Int(SuperVal(cTamLot))
			Else
				mv_par12 := Int(SuperVal(cTamLot)) + 1
			EndIf
		EndIf
		lImp := .T.
		A240ImEt(lEnd,wnRel,cString,cProg)

	Else

		//����������������������������������������������Ŀ
		//� Impressao a partir da importacao de Entradas �
		//������������������������������������������������
		DbselectArea("QEK")
		Dbsetorder(14)
		For nIEnt := 1 To Len(aVetQEK)
            //If !lImpFic  
			//	aVetQEK[nIEnt] := xFilial("QEK")+aVetQEK[nIEnt]
            //Endif
			// Posiciona o QEK
			If QEK->(dbSeek(aVetQEK[nIEnt]))
				mv_par01 := QEK->QEK_FORNEC
				mv_par02 := QEK->QEK_FORNEC
				mv_par03 := QEK->QEK_LOJFOR
				mv_par04 := QEK->QEK_LOJFOR
				mv_par05 := QEK->QEK_PRODUT
				mv_par06 := QEK->QEK_PRODUT
				mv_par07 := QEK->QEK_DTENTR
				mv_par08 := QEK->QEK_DTENTR
				mv_par09 := QEK->QEK_LOTE
				mv_par10 := QEK->QEK_LOTE

				//�����������������������������������������Ŀ
				//� Utiliza o Tam.Lote corrente ou assume   �
				//�   o informado na pergunte mv_par12      �
				//�������������������������������������������
				If mv_par11 == 1
					cTamLot := QEK->QEK_TAMLOT

					//�����������������������������������������Ŀ
					//� Troca a virgula por ponto outros        �
					//�   caracteres sao bloqueados no cadastro �
					//�������������������������������������������
					If AT(",",cTamLot) > 0
						cTamLot := StrTran(cTamLot,",",".")
					EndIf
					//����������������������������������������������Ŀ
					//� Se o Tam.Lote nao for inteiro � adicionado   �
					//�  uma etiqueta a mais                         �
					//������������������������������������������������
					If Int(SuperVal(cTamLot)) == SuperVal(cTamLot)
						mv_par12 := Int(SuperVal(cTamLot))
					Else
						mv_par12 := Int(SuperVal(cTamLot)) + 1
					EndIf
				EndIf
				lImp := .T.
				A240ImEt(lEnd,wnRel,cString,cProg)
			EndIf
		Next
	EndIf
EndIf

RetIndex("QEK")                                         
Set Filter to
dbSelectArea("QEK")
dbSetOrder(nOrdQEK)
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � A240ImEt � Autor � Antonio Aurelio       � Data � 04.05.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime as Etiquetas dos Produtos da Entrada               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd  - Verifica se o foi cancelada a impressao            ���
���			 �	wnRel - Usada na fun��o OurSpool                          ���
���			 �	cProg - Usada na verifica��o do prmg chamador desta fun��o���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � 															  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � A240Imp                                         			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A240ImEt(lEnd,wnRel,cString,cProg)
Local cFor		 := ""
Local cLojFor	 := ""
Local nC         := 0
Local cChaveQEK1 := ""
Local nDias      := 0
Local nOrdQE6	 := QE6->(IndexOrd())
Local nOrdSAH	 := SAH->(IndexOrd())
Local nSaltPag   := 0
Local oPrint
Local oFont06
Local cNF
Local nEtiqueta  
Local lin := 80
Local cSerie

oFont06		:= TFont():New("Arial",06,08,,.F.,,,,.T.,.F.)

//��������������������������������������Ŀ
//� N� de Etiquetas a serem impressas    �
//����������������������������������������
If !cProg $ "QIEA200.QIER220"
	SetRegua(RecCount())  // Depende da selecao feita na pergunte
Else
	If mv_par11 == 1 // Assume o tamanho do lote
		SetRegua( mv_par12 * RecCount() )
	Else
        SetRegua(mv_par12)  // S� o tamanho especificado
	EndIf
EndIf


dbSelectArea("QEK")

oPrint := TMSPrinter():New("")
oPrint:SetPortrait()

While QEK->(!Eof()) .And. xFilial("QEK") == QEK->QEK_FILIAL .And. ;
		QEK->QEK_FORNEC >= mv_par01 .And. QEK->QEK_FORNEC <= mv_par02 .And.;
		QEK->QEK_LOJFOR >= mv_par03 .And. QEK->QEK_LOJFOR <= mv_par04 .And.;
		QEK->QEK_PRODUT >= mv_par05 .And. QEK->QEK_PRODUT <= mv_par06 .And.;
		QEK->QEK_DTENTR >= mv_par07 .And. QEK->QEK_DTENTR <= mv_par08 .And.;
		QEK->QEK_LOTE   >= mv_par09 .And. QEK->QEK_LOTE   <= mv_par10

   	IncRegua()

	cChaveQEK1 := QEK->QEK_PRODUT+Inverte(QEK->QEK_REVI)
	cFor	   := QEK->QEK_FORNEC
	cLojFor	   := QEK->QEK_LOJFOR

	dbSelectArea("QE6")
	dbSetOrder(1)
	dbSeek(xFilial("QE6")+cChaveQEK1)

	If QE6->(!Found())
		Set Device to Screen
		Help(" ",1,"QE_NAOPRRV",,AllTrim(QEK->QEK_PRODUT)+" / "+QEK->QEK_REVI,2,1) // "Produto/Revisao nao cadastrados:
		Set Device to Printer
		dbSelectArea("QEK")
		QEK->(dbSkip())
		Loop
	EndIf

	cProduto := QE6->QE6_PRODUT+QE6->QE6_REVI

	If QE6->QE6_UNSHEL == "1"  // Dia
		nDias := QE6->QE6_SHLF
	Else
		If QE6->QE6_UNSHEL == "2" // Mes
			nDias := QE6->QE6_SHLF * 30
		Else
			nDias := QE6->QE6_SHLF * 365
		EndIf
	EndIf

	If !cProg $ "QIEA200.QIER220"
		If mv_par11 == 1  // Assume o Tam. do Lote
			cTamLot := QEK->QEK_TAMLOT
			//�����������������������������������������Ŀ
			//� Troca a virgula por ponto outros        �
			//�   caracteres sao bloqueados no cadastro �
			//�������������������������������������������
			If AT(",",cTamLot) > 0
				cTamLot := StrTran(cTamLot,",",".")
			EndIf
			//����������������������������������������������Ŀ
			//� Se o Tam.Lote nao for inteiro � adicionado   �
			//�  uma etiqueta a mais                         �
			//������������������������������������������������
			If Int(SuperVal(cTamLot)) == SuperVal(cTamLot)
				mv_par12 := Int(SuperVal(cTamLot))
			Else
				mv_par12 := Int(SuperVal(cTamLot)) + 1
			EndIf
		EndIf
	EndIf

	If mv_par11 == 1	
		nEtiqueta:= Int(SuperVal(cTamLot))
	Else	
		nEtiqueta:= mv_par12
    Endif
    
	oPrint:StartPage() 		

	For nC := 1 To mv_par12

	   If lEnd
			nLin := nLin + 1
			@ nLin ,001 PSAY STR0007  // "CANCELADO PELO OPERADOR"
			Exit
		EndIf

		nSaltPag:= nSaltPag + 1

		oPrint:Say(lin,0020,STR0010,oFont06)// Rastreabilidade        		
		lin += 30 

		//           R A S T R E A B I L I D A D E
		//Produto....: 0123456789012345 - XX
		//              XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		//Data Entreg: 99/99/9999 Lote.....: 0123456789012345
		//Validade...: 99/99/9999 Tam.Lote.: 012345678 XXXXXXXXX
		//Nota Fiscal: 0123456789012 012
		// 			1			 2 		  3			4			 5 		  6			7			 8 		  9			10 		 11		  12			13
		//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

		//Produto
		oPrint:Say(lin,0020,Pad(AllTrim(TitSx3("QEK_PRODUT")[1]),11,".")+": "+AllTrim(QEK->QEK_PRODUT)+" - "+QEK->QEK_REVI,oFont06)        
		lin += 30
		oPrint:Say(lin,0140,QE6->QE6_DESCPO,oFont06)        		
		lin += 30 

		//Data Entrega + Lote
		oPrint:Say(lin,0020,Pad(AllTrim(TitSx3("QEK_DTENTR")[1]),11,".")+":  "+Dtoc(QEK->QEK_DTENTR)+"  "+Pad(AllTrim(TitSx3("QEK_LOTE")[1]),10,".")+" : "+QEK->QEK_LOTE,oFont06)        
		lin += 30 

        //Validade
		SAH->(dbSetOrder(1))
		SAH->(dbSeek(xFilial("SAH")+QEK->QEK_UNIMED))
		QEL->(dbSetOrder(1))
		If QEL->(dbSeek(xFilial("QEL")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+Dtos(QEK->QEK_DTENTR)+QEK->QEK_LOTE+Space(6)))
			If !Empty(SAH->AH_UMRES)
				oPrint:Say(lin,0020,STR0011+"    "+Dtoc(QEL->QEL_DTVAL )+"  "+Pad(AllTrim(TitSx3("QEK_TAMLOT")[1]),10,".")+":  "+QEK->QEK_TAMLOT+" "+SAH->AH_UMRES,oFont06)        
			Else
				oPrint:Say(lin,0020,STR0011+"    "+Dtoc(QEL->QEL_DTVAL )+"  "+Pad(AllTrim(TitSx3("QEK_TAMLOT")[1]),10,".")+":  "+QEK->QEK_TAMLOT,oFont06)        
			Endif				
	    Else
			If !Empty(SAH->AH_UMRES)
				oPrint:Say(lin,0020,STR0011+"    "+Dtoc(QEK->QEK_DTENTR + nDias)+"  "+Pad(AllTrim(TitSx3("QEK_TAMLOT")[1]),10,".")+":  "+QEK->QEK_TAMLOT+" "+SAH->AH_UMRES,oFont06)        
			Else
				oPrint:Say(lin,0020,STR0011+"    "+Dtoc(QEK->QEK_DTENTR + nDias)+"  "+Pad(AllTrim(TitSx3("QEK_TAMLOT")[1]),10,".")+":  "+QEK->QEK_TAMLOT,oFont06)        
			Endif	
	    Endif
		lin += 30                  

		//NF
		cSerie:= SerieNfId("QEK",3,"QEK_SERINF")
		If !Empty(QEK->(&cserie))
			 cNF:= Pad(AllTrim(TitSx3("QEK_NTFISC")[1]),11,".")+": "+AllTrim(QEK->QEK_NTFISC)+" - "+QEK->(&cserie)
		Else
		     cNF:= Pad(AllTrim(TitSx3("QEK_NTFISC")[1]),11,".")+": "+AllTrim(QEK->QEK_NTFISC)
		EndIf
		oPrint:Say(lin,0020,cNF,oFont06)        
		lin += 30 
        
		If lin > 2500  
			oPrint:EndPage() 		
			lin := 80
			nSaltPag:= 0
		Else
			If nSaltPag == nEtiqueta // Pula de Pagina de acordo com o numero de etiquetas 
				If lin > 2500  
					oPrint:EndPage() 		
					lin := 80
					nSaltPag:= 0
					nSaltPag:= 0           
					oPrint:EndPage() 		
				Endif	
				lin += 100
			Else			
				lin += 100 
			EndIf
	    Endif
	Next                                              

	QEK->(dbSkip())

	If lEnd
		Exit
	EndIf

EndDo

oPrint:Preview()  	

//��������������������������������������Ŀ
//� Restaura os �ndices dos arq. usados  �
//����������������������������������������
dbSelectArea("QE6")
dbSetOrder(nOrdQE6)
dbSelectArea("SAH")
dbSetOrder(nOrdSAH)

Return 
