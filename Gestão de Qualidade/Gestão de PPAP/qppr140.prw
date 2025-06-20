#INCLUDE "QPPR140.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QPPR140  � Autor � Robson Ramiro A. Olive� Data � 31.10.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Viabilidade                                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPR140(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PPAP                                                       ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPPR140(lBrow,cPecaAuto,cJPEG)

Local oPrint
Local lPergunte := .F.
Local cStartPath := GetSrvProfString("Startpath","")

Private cPecaRev := ""
Private	axTex	 := {}
Private	cTextRet := ""

Default lBrow 		:= .F.
Default cPecaAuto	:= ""
Default cJPEG       := ""         

If Right(cStartPath,1) <> "\"
	cStartPath += "\"
Endif

If !Empty(cPecaAuto)
	cPecaRev := cPecaAuto
Endif

oPrint := TMSPrinter():New(STR0001) //"Viabilidade"

oPrint:SetPortrait()

If Empty(cPecaAuto)
	If AllTrim(FunName()) == "QPPA140"
		cPecaRev := Iif(!lBrow, M->QKF_PECA + M->QKF_REV, QKF->QKF_PECA + QKF->QKF_REV)
	Else
		lPergunte := Pergunte("PPR180",.T.)

		If lPergunte
			cPecaRev := mv_par01 + mv_par02	
		Else
			Return Nil
		Endif
	Endif
Endif

DbSelectArea("QK1")
DbSetOrder(1)
DbSeek(xFilial()+cPecaRev)

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1") + QK1->QK1_CODCLI + QK1->QK1_LOJCLI)

DbSelectArea("QKF")
DbSetOrder(1)
If DbSeek(xFilial()+cPecaRev)

	If Empty(cPecaAuto)
		MsgRun(STR0002,"",{|| CursorWait(), MontaRel(oPrint) ,CursorArrow()}) //"Gerando Visualizacao, Aguarde..."
	Else
		MontaRel(oPrint)
	Endif

	If lPergunte .and. mv_par03 == 1 .or. !Empty(cPecaAuto)
		If !Empty(cJPEG)
			oPrint:SaveAllAsJPEG(cStartPath+cJPEG,870,870,140)
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
���Funcao    � MontaRel � Autor � Robson Ramiro A. Olive� Data � 31.10.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Viabilidade                                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MotaRel(ExpO1)                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPR140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MontaRel(oPrint)

Local i 	 := 1
Local nCont  := 0
Local lin	 := 0
Local oBrush := TBrush():New( , CLR_BLACK )
Local aCoord := {}
Local nx 	 :=1
Private oFont16, oFont09,oFont10

oFont16		:= TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
oFont09		:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
oFont10		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)

Cabecalho(oPrint,i)  	// Funcao que monta o cabecalho
lin := 350

DbSelectArea("QKF")

nCont++ 

	
If lin > 2900
	nCont := 1
	i++
	oPrint:EndPage() 		// Finaliza a pagina
	Cabecalho(oPrint,i)  	// Funcao que monta o cabecalho
	lin := 350
Endif

lin += 40
oPrint:Say(lin,0030,STR0003,oFont10)	 //"Consideracoes Sobre a Viabilidade"

lin += 80
oPrint:Say(lin,0030,STR0004,oFont09) //"Nossa equipe de planejamento da qualidade do produto considerou as seguintes questoes, que nao pretendem ser totalmente incluidas na execucao de uma avaliacao"

lin += 40
oPrint:Say(lin,0030,STR0005,oFont09) //"de viabilidade. Os desenhos e/ou especificacoes fornecidos foram usados como base para analisar a capacidade de atender a todos os requisitos especificados."

lin += 40
oPrint:Say(lin,0030,STR0006,oFont09)// 'Todas as respostas "nao" sao suportadas por comentarios anexo identificando nossas preocupacoes e/ou alteracoes propostas para nos habilitar a atender os requisitos especificados.'

lin += 80
oPrint:Box( lin, 0030, lin+1280, 2300 )		// Box Consideracao

oPrint:Line( lin, 0230, lin+1280, 0230 )		// vertical
oPrint:Line( lin, 0430, lin+1280, 0430 )		// vertical

oPrint:Say(lin+20,0100,STR0007,oFont10) //"SIM"
oPrint:Say(lin+20,0300,STR0039,oFont10) //"NAO"
oPrint:Say(lin+20,1000,STR0008,oFont10) //"CONSIDERACAO"

lin += 80
oPrint:Line(lin, 0030, lin, 2300)	// horizontal, 1a Linha
oPrint:Say(lin+20,110,Iif(QKF->QKF_Q01 == "1","X"," "),oFont10)
oPrint:Say(lin+20,310,Iif(QKF->QKF_Q01 == "2","X"," "),oFont10)
oPrint:Say(lin+20,450,STR0009,oFont09) //"O produto esta adequadamente definido (requisito de aplicacao, etc.) para habilitar a avaliacao da viabilidade?"

lin += 80
oPrint:Line(lin, 0030, lin, 2300)	// horizontal, 2a Linha
oPrint:Say(lin+20,110,Iif(QKF->QKF_Q02 == "1","X"," "),oFont10)
oPrint:Say(lin+20,310,Iif(QKF->QKF_Q02 == "2","X"," "),oFont10)
oPrint:Say(lin+20,450,STR0010,oFont09) //"As Especificacoe de Desempenho de Engenharia podem ser atendidas, como descritas?"

lin += 80
oPrint:Line(lin, 0030, lin, 2300)	// horizontal, 3a Linha
oPrint:Say(lin+20,110,Iif(QKF->QKF_Q03 == "1","X"," "),oFont10)
oPrint:Say(lin+20,310,Iif(QKF->QKF_Q03 == "2","X"," "),oFont10)
oPrint:Say(lin+20,450,STR0011,oFont09) //"O produto pode ser manufaturado de acordo com as tolerancias especificadas no desenho?"

lin += 80
oPrint:Line(lin, 0030, lin, 2300)	// horizontal, 4a Linha
oPrint:Say(lin+20,110,Iif(QKF->QKF_Q04 == "1","X"," "),oFont10)
oPrint:Say(lin+20,310,Iif(QKF->QKF_Q04 == "2","X"," "),oFont10)
oPrint:Say(lin+20,450,STR0012,oFont09) //"O produto pode ser manufaturado com Cpk's que atendem as especificacoes?"

lin += 80
oPrint:Line(lin, 0030, lin, 2300)	// horizontal, 5a Linha
oPrint:Say(lin+20,110,Iif(QKF->QKF_Q05 == "1","X"," "),oFont10)
oPrint:Say(lin+20,310,Iif(QKF->QKF_Q05 == "2","X"," "),oFont10)
oPrint:Say(lin+20,450,STR0013,oFont09) //"Existe capacidade adequada para a fabricacao do produto?"

lin += 80
oPrint:Line(lin, 0030, lin, 2300)	// horizontal, 6a Linha
oPrint:Say(lin+20,110,Iif(QKF->QKF_Q06 == "1","X"," "),oFont10)
oPrint:Say(lin+20,310,Iif(QKF->QKF_Q06 == "2","X"," "),oFont10)
oPrint:Say(lin+20,450,STR0014,oFont09) //"O projeto permite o uso de tecnicas  eficientes de manuseio de material?"

lin += 80
oPrint:Line(lin, 0030, lin, 2300)	// horizontal, 7a Linha
oPrint:Say(lin+20,450,STR0015,oFont09) //"O produto pode ser manufaturado sem incorrer em inesperados:"
aCoord := {lin,30,lin+80,430}
oPrint:FillRect(aCoord,oBrush)

lin += 80
oPrint:Line(lin, 0030, lin, 2300)	// horizontal, 8a Linha
oPrint:Say(lin+20,110,Iif(QKF->QKF_Q07 == "1","X"," "),oFont10)
oPrint:Say(lin+20,310,Iif(QKF->QKF_Q07 == "2","X"," "),oFont10)
oPrint:Say(lin+20,550,STR0016,oFont09) //"- Custos de equipamentos de transformacao ?"

lin += 80
oPrint:Line(lin, 0030, lin, 2300)	// horizontal, 9a Linha
oPrint:Say(lin+20,110,Iif(QKF->QKF_Q08 == "1","X"," "),oFont10)
oPrint:Say(lin+20,310,Iif(QKF->QKF_Q08 == "2","X"," "),oFont10)
oPrint:Say(lin+20,550,STR0017,oFont09) //"- Custos de ferramental?"

lin += 80
oPrint:Line(lin, 0030, lin, 2300)	// horizontal, 10a Linha
oPrint:Say(lin+20,110,Iif(QKF->QKF_Q09 == "1","X"," "),oFont10)
oPrint:Say(lin+20,310,Iif(QKF->QKF_Q09 == "2","X"," "),oFont10)
oPrint:Say(lin+20,550,STR0018,oFont09) //"- Metodos de manufatura alternativos ?"

lin += 80
oPrint:Line(lin, 0030, lin, 2300)	// horizontal, 11a Linha
oPrint:Say(lin+20,110,Iif(QKF->QKF_Q10 == "1","X"," "),oFont10)
oPrint:Say(lin+20,310,Iif(QKF->QKF_Q10 == "2","X"," "),oFont10)
oPrint:Say(lin+20,450,STR0019,oFont09) //"E necessario controle estatistico do processo para o produto ?"

lin += 80
oPrint:Line(lin, 0030, lin, 2300)	// horizontal, 12a Linha
oPrint:Say(lin+20,110,Iif(QKF->QKF_Q11 == "1","X"," "),oFont10)
oPrint:Say(lin+20,310,Iif(QKF->QKF_Q11 == "2","X"," "),oFont10)
oPrint:Say(lin+20,450,STR0020,oFont09) //"O controle estatistico do processo esta sendo atualmente utilizado em produtos similares ?"

lin += 80
oPrint:Line(lin, 0030, lin, 2300)	// horizontal, 13a Linha
oPrint:Say(lin+20,450,STR0021,oFont09) //"Onde for utilizado controle estatistico do processo em produtos similares:"
aCoord := {lin,30,lin+80,430}
oPrint:FillRect(aCoord,oBrush)

lin += 80
oPrint:Line(lin, 0030, lin, 2300)	// horizontal, 14a Linha
oPrint:Say(lin+20,110,Iif(QKF->QKF_Q12 == "1","X"," "),oFont10)
oPrint:Say(lin+20,310,Iif(QKF->QKF_Q12 == "2","X"," "),oFont10)
oPrint:Say(lin+20,550,STR0022,oFont09) //"- Os processos estao sob controle e estaveis?"

lin += 80
oPrint:Line(lin, 0030, lin, 2300)	// horizontal, 15a Linha
oPrint:Say(lin+20,110,Iif(QKF->QKF_Q13 == "1","X"," "),oFont10)
oPrint:Say(lin+20,310,Iif(QKF->QKF_Q13 == "2","X"," "),oFont10)
oPrint:Say(lin+20,550,STR0023,oFont09) //"- Os Cpk's sao maiores que 1,33?"

lin += 160
oPrint:Say(lin,0030,STR0024,oFont10) //"Conclusao"

lin += 80
oPrint:Box( lin, 0030, lin+240, 230 )		// Box Conclusao
oPrint:Line(lin+080, 0030, lin+080, 230)	// horizontal
oPrint:Line(lin+160, 0030, lin+160, 230)  // horizontal

lin += 20
oPrint:Say(lin,0250,STR0025,oFont10) //"Viavel"
oPrint:Say(lin,110,Iif(QKF->QKF_CONC == "1","X"," "),oFont10)
oPrint:Say(lin,0450,STR0026,oFont10) //"O produto pode ser produzido conforme especificado, sem revisoes."

lin += 80
oPrint:Say(lin,0250,STR0025,oFont10) //"Viavel"
oPrint:Say(lin,110,Iif(QKF->QKF_CONC == "2","X"," "),oFont10)
oPrint:Say(lin,0450,STR0027,oFont10) //"Alteracoes sao recomendadas (veja anexo)."

lin += 80
oPrint:Say(lin,0250,STR0028,oFont10) //"Nao viavel"
oPrint:Say(lin,110,Iif(QKF->QKF_CONC == "3","X"," "),oFont10)
oPrint:Say(lin,0450,STR0029,oFont10) //"Revisao de projeto requerida para a manufatura do produto dentro dos requisitos especificados."

lin += 140
oPrint:Say(lin,0030,STR0030,oFont10) //"Aprovacao"

//1o bloco de assinaturas
lin += 80
oPrint:Say(lin,0030,AllTrim(SubStr(QKF->QKF_MEMB1,1,50))+Space(05)+DtoC(QKF->QKF_DTAP1),oFont10)
oPrint:Say(lin,1200,AllTrim(SubStr(QKF->QKF_MEMB2,1,50))+Space(05)+DtoC(QKF->QKF_DTAP2),oFont10)

lin += 40
oPrint:Line(lin, 0030, lin, 0815)	// horizontal
oPrint:Line(lin, 1200, lin, 1985)	// horizontal

lin += 20
oPrint:Say(lin,0030,STR0031,oFont10)  //"Membro da Equipe/Cargo/Data"
oPrint:Say(lin,1200,STR0031,oFont10)  //"Membro da Equipe/Cargo/Data"

// 2o bloco de assinaturas
lin += 80
oPrint:Say(lin,0030,AllTrim(SubStr(QKF->QKF_MEMB3,1,50))+Space(05)+DtoC(QKF->QKF_DTAP3),oFont10)
oPrint:Say(lin,1200,AllTrim(SubStr(QKF->QKF_MEMB4,1,50))+Space(05)+DtoC(QKF->QKF_DTAP4),oFont10)

lin += 40
oPrint:Line(lin, 0030, lin, 0815)	// horizontal
oPrint:Line(lin, 1200, lin, 1985)	// horizontal

lin += 20
oPrint:Say(lin,0030,STR0031,oFont10)  //"Membro da Equipe/Cargo/Data"
oPrint:Say(lin,1200,STR0031,oFont10)  //"Membro da Equipe/Cargo/Data"

// 3o bloco de assinaturas
lin += 80
oPrint:Say(lin,0030,AllTrim(SubStr(QKF->QKF_MEMB5,1,50))+Space(05)+DtoC(QKF->QKF_DTAP5),oFont10)
oPrint:Say(lin,1200,AllTrim(SubStr(QKF->QKF_MEMB6,1,50))+Space(05)+DtoC(QKF->QKF_DTAP6),oFont10)

lin += 40
oPrint:Line(lin, 0030, lin, 0815)	// horizontal
oPrint:Line(lin, 1200, lin, 1985)	// horizontal

lin += 20
oPrint:Say(lin,0030,STR0031,oFont10)  //"Membro da Equipe/Cargo/Data"
oPrint:Say(lin,1200,STR0031,oFont10) //"Membro da Equipe/Cargo/Data"

i++
oPrint:EndPage() 		// Finaliza a pagina
Cabecalho(oPrint,i)  		// Funcao que monta o cabecalho
lin := 350
lin += 80
oPrint:Say(lin,0030,STR0032,oFont10) //"Explicacoes/Comentarios"
lin += 40

If !Empty(QKF->QKF_CHAVE)
	axTex := {}
	cTextRet := ""
	cTextRet := QO_Rectxt(QKF->QKF_CHAVE,"QPPA140 ",1,TamSX3("QKO_TEXTO")[1],"QKO")
	axTex := Q_MemoArray(cTextRet,axTex,TamSX3("QKO_TEXTO")[1])

	For nx :=1 To Len(axTex)
		If !Empty(axTex[nx])
			lin += 40
			If lin > 2900
				i++
				oPrint:EndPage() 		// Finaliza a pagina
				Cabecalho(oPrint)  		// Funcao que monta o cabecalho
				lin := 350
				lin += 80
				oPrint:Say(lin,0030,STR0032,oFont10) //"Explicacoes/Comentarios"
				lin += 40
			Endif
			oPrint:Say(lin,0030,axTex[nx],oFont10)
		Endif
	Next nx
Endif

DbSelectArea("QKF")

Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Cabecalho� Autor � Robson Ramiro A. Olive� Data � 31.10.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Viabilidade                                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cabecalho(ExpO1,ExpN1)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpN1 = Contador de paginas                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPR140                                                    ���
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
oPrint:SayBitmap(05,2100,"Logo.bmp",237,58)

oPrint:Say(050,500,STR0033,oFont16) //"COMPROMETIMENTO DA EQUIPE COM A VIABILIDADE"

oPrint:Say(200,1400,STR0034,oFont10) //"Data :"
oPrint:Say(200,1730,DtoC(QKF->QKF_DATA),oFont09)

oPrint:Say(200,0030,STR0035,oFont10) //"Cliente :"
oPrint:Say(200,0330,SubStr(SA1->A1_NOME,1,TamSX3("A1_NOME")[1]-3),oFont09)

oPrint:Say(300,0030,STR0036,oFont10) //"Nome da Peca :"
oPrint:Say(300,0330,Subs(QK1->QK1_DESC,1,33),oFont09)

oPrint:Say(250,0030,STR0037,oFont10) //"No. da Peca :"
oPrint:Say(250,0330,QKF->QKF_PECA,oFont09)

oPrint:Say(250,1400,STR0038,oFont10) //"Rev. da Peca :"
oPrint:Say(250,1730,QKF->QKF_REV,oFont09)
 
Return Nil
