#INCLUDE "QPPR160.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QPPR160  � Autor � Robson Ramiro A. Olive� Data � 06.10.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Relatorio do Plano de Controle                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPR160(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PPAP                                                       ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���Robson Ramiro �23.12.02�061488� Melhoria na impressao dos campos       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QPPR160(lBrow,cPecaAuto,cJPEG)

Local oPrint
Local lPergunte := .F.                                           

Private cPecaRev := ""
Private cStartPath := GetSrvProfString("Startpath","")

Default lBrow 		:= .F.
Default cPecaAuto	:= ""
Default cJPEG       := "" 

DbSelectArea("QKM")                            

If Right(cStartPath,1) <> "\"
	cStartPath += "\"
Endif

If !Empty(cPecaAuto)
	cPecaRev := cPecaAuto
Endif

oPrint	:= TMSPrinter():New(STR0001) //"Plano de Controle"

oPrint:SetLandscape()

If Empty(cPecaAuto)
	If AllTrim(FunName()) == "QPPA160"
		cPecaRev := Iif(!lBrow, M->QKL_PECA + M->QKL_REV + M->QKL_TPPRO, QKL->QKL_PECA + QKL->QKL_REV + QKL->QKL_TPPRO)
	Else
		lPergunte := Pergunte("PPR180",.T.)

		If lPergunte
			cPecaRev := mv_par01 + mv_par02 + AllTrim(STR(mv_par05-1))
		Else
			Return Nil
		Endif
	Endif
Endif
	
DbSelectArea("QK1")
DbSetOrder(1)
DbSeek(xFilial()+cPecaRev)

DbSelectArea("QK2")
DbSetOrder(1)
DbSeek(xFilial()+cPecaRev)

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1") + QK1->QK1_CODCLI + QK1->QK1_LOJCLI)

DbSelectArea("QKK")
DbSetOrder(1)
DbSeek(xFilial()+cPecaRev)

DbSelectArea("QKL")
DbSetOrder(1)
If DbSeek(xFilial()+cPecaRev)

	If Empty(cPecaAuto)
		MsgRun(STR0002,"",{|| CursorWait(), MontaRel(oPrint) ,CursorArrow()}) //"Gerando Visualizacao, Aguarde..."
	Else
		MontaRel(oPrint)
	Endif

	If lPergunte .and. mv_par03 == 1 .or. !Empty(cPecaAuto)
		If !Empty(cJPEG)
			oPrint:SaveAllAsJPEG(cStartPath+cJPEG,1120,840,140)
		Else 
			oPrint:Print()
		EndIF
	Else
		oPrint:Preview()  		// Visualiza antes de imprimir
	Endif
Endif

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MontaRel � Autor � Robson Ramiro A. Olive� Data � 06.10.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Cronograma                                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MotaRel(ExpO1)                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPR160                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MontaRel(oPrint)

Local i := 1, nCont, nxCont := 0
Local x := 0, lin
Local aTxt := {}    
Local aTexto := {}    
Local nPos, nLinha

Private oFont16, oFont08, oFont10, oFontCou08

oFont16		:= TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
oFont08		:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
oFont10		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFontCou08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)

Cabecalho(oPrint,i)  	// Funcao que monta o cabecalho

lin := 820

DbSelectArea("QKM")
DbSetOrder(3)
DbSeek(xFilial("QKM")+cPecaRev)

Do While !Eof() 
	If QKM->QKM_PECA+QKM->QKM_REV+QKM->QKM_TPPRO <> cPecaRev
		DbSelectArea("QKM")
		DbSetOrder(3)	
		DbSkip()
		Loop
	Endif

	nCont++ 
	
	aTxt := {}	// Array que armazena as linhas

	If lin > 2200
		nCont := 1
		i++
		oPrint:EndPage() 		// Finaliza a pagina
		Cabecalho(oPrint,i)  	// Funcao que monta o cabecalho
		lin := 820
	Endif
	
	DbSelectArea("QK2")
	DbSetOrder(2)
	DbSeek(xFilial()+QKM->QKM_PECA+QKM->QKM_REV+QKM->QKM_NCAR)

	DbSelectArea("QKK")
	DbSetOrder(2)
	DbSeek(xFilial()+QKM->QKM_PECA+QKM->QKM_REV+QKM->QKM_NOPE)
	
	nLinha := 1
	For nxCont := 1 To Len(QKK->QKK_NOPE) Step 3
		If Len(aTxt) <> 0
			nPos := aScan( aTxt, { |x| x[1] == nLinha })
		Else
			nPos := 0
		Endif

		If !Empty(Subs(QKK->QKK_NOPE,nxCont,3))
			If nPos == 0
				aAdd( aTxt,{	nLinha, Subs(QKK->QKK_NOPE,nxCont,3), Space(19), Space(19), Space(08),;
								Space(19), Space(14), Space(14), Space(05), Space(05), Space(14), Space(17) })
      		Else
				aTxt[nPos,2] := Subs(QKK->QKK_NOPE,nxCont,3)
   			Endif
   		Endif		
   		nLinha++   		
	Next nxCont    

    aTexto := JustificaTXT(QKK->QKK_DESC,19) // Na situacao de quebra ele gera + 1
	nLinha := 1
	For nxCont := 1 To Len(aTexto)
		If Len(aTxt) <> 0
			nPos := aScan( aTxt, { |x| x[1] == nLinha })
		Else
			nPos := 0
		Endif

		If nPos == 0
			aAdd( aTxt,{	nLinha, Space(06), aTexto[nxCont], Space(19), Space(08),;
							Space(19), Space(14), Space(14), Space(05), Space(05), Space(14), Space(17) })
   		Else
			aTxt[nPos,3] := aTexto[nxCont]
		Endif
   		nLinha++   		
	Next nxCont
		
    aTexto := JustificaTXT(QKK->QKK_MAQ,19) // Na situacao de quebra ele gera + 1
	nLinha := 1
	For nxCont := 1 To Len(aTexto)
		If Len(aTxt) <> 0
			nPos := aScan( aTxt, { |x| x[1] == nLinha })
		Else
			nPos := 0
		Endif

		If nPos == 0
			aAdd( aTxt,{	nLinha, Space(06), Space(19), aTexto[nxCont], Space(08),;
							Space(20), Space(15), Space(15), Space(05), Space(05), Space(15), Space(18) })
		Else
			aTxt[nPos,4] := aTexto[nxCont]
		Endif
		nLinha++
	Next nxCont

	nLinha := 1
	For nxCont := 1 To Len(QK2->QK2_CODCAR) Step 4
		If Len(aTxt) <> 0
			nPos := aScan( aTxt, { |x| x[1] == nLinha })
		Else
			nPos := 0
		Endif

		If !Empty(Subs(QK2->QK2_CODCAR,nxCont,4))
			If nPos == 0
				aAdd( aTxt,{	nLinha, Space(06), Space(19), Space(19), Subs(QK2->QK2_CODCAR,nxCont,4),;
								Space(19), Space(14), Space(14), Space(05), Space(05), Space(14), Space(17) })
			Else
				aTxt[nPos,5] := Subs(QK2->QK2_CODCAR,nxCont,4)
			Endif
		Endif
		nLinha++
	Next nxCont

    aTexto := JustificaTXT(QK2->QK2_DESC,19) // Na situacao de quebra ele gera + 1
	nLinha := 1
	For nxCont := 1 To Len(aTexto) 
		If Len(aTxt) <> 0
			nPos := aScan( aTxt, { |x| x[1] == nLinha })
		Else
			nPos := 0
		Endif

		If nPos == 0
			aAdd( aTxt,{	nLinha, Space(06), Space(19), Space(19), Space(08),;
							aTexto[nxCont], Space(14), Space(14), Space(05), Space(05), Space(14), Space(17) })
      		Else
			aTxt[nPos,6] := aTexto[nxCont]
		Endif

   				
   		nLinha++
	Next nxCont

    aTexto := JustificaTXT(QKM->QKM_ESPE,14)
	nLinha := 1
	For nxCont := 1 To Len(aTexto) 
		If Len(aTxt) <> 0
			nPos := aScan( aTxt, { |x| x[1] == nLinha })
		Else
			nPos := 0
		Endif

		If nPos == 0
			aAdd( aTxt,{	nLinha, Space(06), Space(19), Space(19), Space(08),;
							Space(19), aTexto[nxCont], Space(14), Space(05), Space(05), Space(14), Space(17) })
      		Else
			aTxt[nPos,7] := aTexto[nxCont]
		Endif
		
   		nLinha++
	Next nxCont

    aTexto := JustificaTXT(QKM->QKM_TECAVA,14)
	nLinha := 1
	For nxCont := 1 To Len(aTexto)
		If Len(aTxt) <> 0
			nPos := aScan( aTxt, { |x| x[1] == nLinha })
		Else
			nPos := 0
		Endif

		If nPos == 0
			aAdd( aTxt,{	nLinha, Space(06), Space(19), Space(19), Space(08),;
							Space(19), Space(14), aTexto[nxCont], Space(05), Space(05), Space(14), Space(17) })
      		Else
			aTxt[nPos,8] := aTexto[nxCont]
		Endif
 				
   		nLinha++
	Next nxCont

	
	nLinha := 1
	For nxCont := 1 To Len(QKM->QKM_TAMO) Step 5
		If Len(aTxt) <> 0
			nPos := aScan( aTxt, { |x| x[1] == nLinha })
		Else
			nPos := 0
		Endif

		If !Empty(Subs(QKM->QKM_TAMO,nxCont,5))
			If nPos == 0
				aAdd( aTxt,{	nLinha, Space(06), Space(20), Space(20), Space(08),;
								Space(20), Space(15), Space(15), Subs(QKM->QKM_TAMO,nxCont,5), Space(05), Space(14), Space(17) })
      		Else
				aTxt[nPos,9] := Subs(QKM->QKM_TAMO,nxCont,5)
			Endif
   		Endif
				
   		nLinha++
	Next nxCont

	nLinha := 1
	For nxCont := 1 To Len(QKM->QKM_FREQ) Step 5
		If Len(aTxt) <> 0
			nPos := aScan( aTxt, { |x| x[1] == nLinha })
		Else
			nPos := 0
		Endif

		If !Empty(Subs(QKM->QKM_FREQ,nxCont,5))
			If nPos == 0
				aAdd( aTxt,{	nLinha, Space(06), Space(20), Space(20), Space(08),;
								Space(20), Space(15), Space(15), Space(05), Subs(QKM->QKM_FREQ,nxCont,5), Space(14), Space(17) })
      		Else
				aTxt[nPos,10] := Subs(QKM->QKM_FREQ,nxCont,5)
			Endif
   		Endif
				
   		nLinha++
	Next nxCont

    aTexto := JustificaTXT(QKM->QKM_METCON,14)
	nLinha := 1
	For nxCont := 1 To Len(aTexto)
		If Len(aTxt) <> 0
			nPos := aScan( aTxt, { |x| x[1] == nLinha })
		Else
			nPos := 0
		Endif

		If nPos == 0
			aAdd( aTxt,{	nLinha, Space(06), Space(19), Space(19), Space(08),;
							Space(19), Space(14), Space(14), Space(05), Space(05), aTexto[nxCont], Space(17) })
      		Else
			aTxt[nPos,11] := aTexto[nxCont]
		Endif
				
   		nLinha++
	Next nxCont

    aTexto := JustificaTXT(QKM->QKM_PLREA,17)
	nLinha := 1
	For nxCont := 1 To Len(aTexto)
		If Len(aTxt) <> 0
			nPos := aScan( aTxt, { |x| x[1] == nLinha })
		Else
			nPos := 0
		Endif

		If nPos == 0
			aAdd( aTxt,{	nLinha, Space(06), Space(19), Space(19), Space(08),;
							Space(19), Space(14), Space(14), Space(05), Space(05), Space(14), aTexto[nxCont] })
      		Else
			aTxt[nPos,12] := aTexto[nxCont]
		Endif
				
   		nLinha++
	Next nxCont

	PPAPBMP(QK2->QK2_SIMB+".BMP", cStartPath)
	oPrint:SayBitmap(lin,1610, QK2->QK2_SIMB+".BMP",40,40)

	If Len(aTxt) > 0
		For nxCont := 1 To Len(aTxt)
			oPrint:Say(lin,0040,aTxt[nxCont,2],oFontCou08)
			oPrint:Say(lin,0110,aTxt[nxCont,3],oFontCou08)
			oPrint:Say(lin,0460,aTxt[nxCont,4],oFontCou08)
			oPrint:Say(lin,0810,aTxt[nxCont,5],oFontCou08)

			If QK2->QK2_PRODPR == "1" // Produto / Processo
				oPrint:Say(lin,0913,aTxt[nxCont,6],oFontCou08)
			Else
				oPrint:Say(lin,1263,aTxt[nxCont,6],oFontCou08)
			Endif

			oPrint:Say(lin,1663,aTxt[nxCont,7],oFontCou08)
			oPrint:Say(lin,1930,aTxt[nxCont,8],oFontCou08)
			oPrint:Say(lin,2198,aTxt[nxCont,9],oFontCou08)
			oPrint:Say(lin,2300,aTxt[nxCont,10],oFontCou08)
			oPrint:Say(lin,2403,aTxt[nxCont,11],oFontCou08)
			oPrint:Say(lin,2670,aTxt[nxCont,12],oFontCou08)

			lin += 40

			If lin > 2200
				nCont := 1
				i++
				oPrint:EndPage() 		// Finaliza a pagina
				Cabecalho(oPrint,i)  	// Funcao que monta o cabecalho
				lin := 820
			Endif

		Next nxCont
	Endif

	oPrint:Line( lin, 30, lin, 3000 )   	// horizontal
	lin += 20

	DbSelectArea("QKM")	
	DbSetOrder(3)	
	DbSkip()

Enddo

Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Cabecalho� Autor � Robson Ramiro A. Olive� Data � 06.10.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Relatorio do Plano de Controle                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cabecalho(ExpO1,ExpN1)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpN1 = Contador de paginas                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPR160                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Cabecalho(oPrint,i)

Local cFileLogo  := "LGRL"+SM0->M0_CODIGO+FWCodFil()+".BMP" // Empresa+Filial

If !File(cFileLogo)
	cFileLogo := "LGRL" + SM0->M0_CODIGO+".BMP" // Empresa
Endif

oPrint:StartPage() 		// Inicia uma nova pagina

oPrint:SayBitmap(05,0005, cFileLogo,328,82)             // Tem que estar abaixo do RootPath
oPrint:SayBitmap(05,2800, "Logo.bmp",237,58)

oPrint:Say(050,1250,STR0001,oFont16) //"PLANO DE CONTROLE"

//Box Cabecalho
oPrint:Box( 150, 30, 550, 3000 )

oPrint:Line( 230, 30, 230, 3000 ) // horizontal
oPrint:Line( 310, 30, 310, 3000 ) // horizontal
oPrint:Line( 390, 30, 390, 3000 ) // horizontal
oPrint:Line( 470, 30, 470, 3000 ) // horizontal

oPrint:Line( 150, 1090, 550, 1090 ) // vertical
oPrint:Line( 150, 1490, 310, 1490 ) // vertical
oPrint:Line( 150, 2090, 310, 2090 ) // vertical
oPrint:Line( 150, 2800, 390, 2800 ) // vertical
oPrint:Line( 390, 2490, 470, 2490 ) // vertical
oPrint:Line( 470, 2090, 550, 2090 ) // vertical

// Descricao do Cabecalho
// 1a Linha
oPrint:Say(160,0040,STR0003,oFont08) //"Numero da Peca(Cliente)"
oPrint:Say(195,0040,QK1->QK1_PCCLI,oFontCou08)

oPrint:Say(160,1100,STR0004,oFont08) //"Cliente"
oPrint:Say(195,1100,Subs(SA1->A1_NOME,1,22),oFontCou08)

oPrint:Say(160,1500,STR0005,oFont08) //"Rev/Data Desenho"
oPrint:Say(195,1500,Alltrim(QK1->QK1_REVDES)+" / "+DtoC(QK1->QK1_DTRDES),oFontCou08)

oPrint:Box(160,2100,210,2150)
oPrint:Say(160,2120,Iif(QKL->QKL_TPPRO == "1","X"," "),oFontCou08)
oPrint:Say(160,2160,STR0006,oFont08) //"Prototipo"

oPrint:Box(160,2300,210,2350)
oPrint:Say(160,2320,Iif(QKL->QKL_TPPRO == "2","X"," "),oFontCou08)
oPrint:Say(160,2360,STR0007,oFont08) //"Pre-Lancamento"

oPrint:Box(160,2600,210,2650)
oPrint:Say(160,2620,Iif(QKL->QKL_TPPRO == "3","X"," "),oFontCou08)
oPrint:Say(160,2660,STR0008,oFont08) //"Producao"

oPrint:Say(160,2810,STR0009,oFont08)  //"Pagina"
oPrint:Say(195,2820, Str(i,2),oFont08)

// 2a Linha
oPrint:Say(245,0040,STR0010,oFont08) //"Nome da Peca"
oPrint:Say(275,0040,Subs(QK1->QK1_DESC,1,60),oFontCou08)

oPrint:Say(245,1100,STR0011,oFont08) //"No. Plano"
oPrint:Say(275,1100,QKL->QKL_PLAN,oFontCou08)

oPrint:Say(245,1500,STR0012,oFont08) //"Equipe Principal"
oPrint:Say(275,1500,Subs(QKL->QKL_EQPRIN,1,34),oFontCou08)
                                                
oPrint:Say(245,2100,STR0013,oFont08) //"Aprovacao do Fornecedor/Data"
oPrint:Say(275,2100,Subs(Alltrim(QKL->QKL_APRFOR),1,20)+" / "+DtoC(QKL->QKL_DTAFOR),oFontCou08)

oPrint:Say(245,2810,STR0014,oFont08) //"Data Inicial"
oPrint:Say(275,2810,DtoC(QKL->QKL_DTINI),oFontCou08)

// 3a Linha
oPrint:Say(325,0040,STR0015,oFont08) //"Fornecedor"
oPrint:Say(355,0040,SM0->M0_NOMECOM,oFontCou08)

oPrint:Say(325,1100,STR0016,oFont08) //"No. Peca/Revisao (Fornecedor)"
oPrint:Say(355,1100,Alltrim(QK1->QK1_PECA)+" / "+QK1->QK1_REV,oFontCou08)

oPrint:Say(325,2810,STR0017,oFont08) //"Data Rev."
oPrint:Say(355,2810,DtoC(QKL->QKL_DTREV),oFontCou08)

// 4a Linha
oPrint:Say(405,0040,STR0018,oFont08) //"Aprovacao da Engenharia do Cliente/Data (Se requerido)"
oPrint:Say(435,0040,Alltrim(QKL->QKL_APENCL)+" / "+DtoC(QKL->QKL_DTAENG),oFontCou08)

oPrint:Say(405,1100,STR0019,oFont08) //"Aprovacao da Qualidade do Cliente/Data (Se requerido)"
oPrint:Say(435,1100,Alltrim(QKL->QKL_APQUCL)+" / "+DtoC(QKL->QKL_DTAQUA),oFontCou08)

oPrint:Say(405,2500,STR0020,oFont08) //"Contato Chave / Fone"
oPrint:Say(435,2500,Subs(QKL->QKL_CONTAT,1,29),oFontCou08)

// 5a Linha
oPrint:Say(485,0040,STR0021,oFont08) //"Outra Aprovacao/Data (Se requerido)"
oPrint:Say(515,0040,Alltrim(QKL->QKL_OUTAP1)+" / "+DtoC(QKL->QKL_DTOUT1),oFontCou08)

oPrint:Say(485,1100,STR0021,oFont08) //"Outra Aprovacao/Data (Se requerido)"
oPrint:Say(515,1100,Alltrim(QKL->QKL_OUTAP2)+" / "+DtoC(QKL->QKL_DTOUT2),oFontCou08)

oPrint:Say(485,2105,STR0048,oFont08) //"Cod. do Fornecedor"
oPrint:Say(515,2105,Alltrim(QK1->QK1_CODVCL),oFontCou08)

//Box Itens
oPrint:Box( 0560, 30, 0800, 3000 )
oPrint:Box( 0800, 30, 2260, 3000 )

oPrint:Line( 0560, 0100, 2260, 0100 ) // vertical
oPrint:Line( 0560, 0450, 2260, 0450 ) // vertical
oPrint:Line( 0560, 0800, 2260, 0800 ) // vertical
oPrint:Line( 0640, 0903, 2260, 0903 ) // vertical
oPrint:Line( 0640, 1253, 2260, 1253 ) // vertical
oPrint:Line( 0560, 1603, 2260, 1603 ) // vertical
oPrint:Line( 0560, 1653, 2260, 1653 ) // vertical
oPrint:Line( 0640, 1920, 2260, 1920 ) // vertical
oPrint:Line( 0640, 2188, 2260, 2188 ) // vertical
oPrint:Line( 0700, 2290, 2260, 2290 ) // vertical
oPrint:Line( 0640, 2393, 2260, 2393 ) // vertical
oPrint:Line( 0560, 2660, 2260, 2660 ) // vertical

oPrint:Line( 640, 0800, 640, 1600 ) // horizontal
oPrint:Line( 700, 2188, 700, 2393 ) // horizontal
oPrint:Line( 640, 1653, 640, 2660 ) // horizontal

// Descricao dos Itens
oPrint:Say(600,0040,STR0022,oFont08) //"No."
oPrint:Say(660,0040,STR0023,oFont08) //"Pc/"
oPrint:Say(720,0040,STR0024,oFont08) //"Pro"

oPrint:Say(600,0120,STR0025,oFont08) //"Nome do Processo"
oPrint:Say(660,0200,STR0026,oFont08) //"ou"
oPrint:Say(720,0110,STR0027,oFont08) //"Descricao da Operacao"

oPrint:Say(600,0470,STR0028,oFont08) //"Maquina, Dispositivo"
oPrint:Say(660,0470,STR0029,oFont08) //"Padrao, Ferramenta p/"
oPrint:Say(720,0470,STR0030,oFont08) //"Manufatura"

oPrint:Say(600,1100,STR0031,oFont08) //"Caracteristicas"

oPrint:Say(660,0820,STR0022,oFont08) //"No."

oPrint:Say(660,0980,STR0032,oFont08) //"Produto"

oPrint:Say(660,1330,STR0033,oFont08) //"Processo"

oPrint:Say(660,1610,STR0034,oFont08) //"Car"

oPrint:Say(660,1700,STR0037,oFont08) //"Prod./Espec."
oPrint:Say(720,1700,STR0038,oFont08) //"Proc./Toler."

oPrint:Say(660,1970,STR0035,oFont08) //"Tecnica de"
oPrint:Say(720,1970,STR0036,oFont08) //"Aval./Medicao"

oPrint:Say(600,2150,STR0039,oFont08) //"Metodo"

oPrint:Say(660,2230,STR0040,oFont08) //"Amostra"

oPrint:Say(720,2198,STR0041,oFont08) //"Tam."

oPrint:Say(720,2300,STR0042,oFont08) //"Freq."

oPrint:Say(660,2450,STR0043,oFont08) //"Metodo de"
oPrint:Say(720,2450,STR0044,oFont08) //"Controle"

oPrint:Say(600,2750,STR0045,oFont08) //"Plano"
oPrint:Say(660,2780,STR0046,oFont08) //"de"
oPrint:Say(720,2750,STR0047,oFont08) //"Reacao"

Return Nil
