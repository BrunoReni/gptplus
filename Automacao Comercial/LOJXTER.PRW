#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"

#define POS    posicao [terminal+1]  // posicao do programa
#define KPIC   pikture [terminal+1]  // picture de teclado
#define KBD    teclado [terminal+1]  // variavel com input de teclado
#define WAITT  waitkbd [terminal+1]  // flag de aguardo de entrada de dados
#define PPIC   pospic  [terminal+1]  // posicao a receber na picture de teclado
#define PPRN   pprinter[terminal+1]
#define SPRN   sprinter[terminal+1]
#define PINP   pinpos  [terminal+1]
#define PINS   sinpos  [terminal+1]
#define POUTP  poutpos [terminal+1]
#define POUTS  soutpos [terminal+1]
#define DESVIO nDesvio [terminal+1]
#define SEGANT aSegAnt [terminal+1]  // Segundos Anteriores
#define DELAY  NumDelay[terminal+1]  // N�mero de segundos que deseja-se esperar
#define PICANT aPicAnt [terminal+1]  // Picture Anterior

#define ESC 27
#define BKSP 8

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���Descri��o � Fun��es gen�ricas para utiliza��o de Microterminais        ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPOSCUR  � Autor � F�bio F. Pessoa       � Data � 18/09/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Posiciona o cursor no display do terminal                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPosCur(Linha, coluna)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Linha (0,1), Coluna (00, 39)                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function GPosCur( linha, coluna )
helpstr := chr(254)+padl( ltrim( str(terminal,2,0) ), 2, "0" )+"C"+str(linha,1,0)+padl( ltrim( str(coluna,2,0) ), 2, "0" )
fwrite( handle, helpstr, len(helpstr) )
return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GDISPLAY � Autor � F�bio F. Pessoa       � Data � 18/09/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia uma string ao display do terminal                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GDisplay(Mensagem)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Mensagem                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function GDisplay( mensagem )
helpstr := chr(254)+padl( ltrim( str(terminal,2,0) ), 2, "0" )+"D"+mensagem
fwrite( handle, helpstr, len(helpstr) )
return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GIsWill  � Autor � F�bio F. Pessoa       � Data � 17/11/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna se � Willbor n�o.                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � GIsWill()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Observa��o� Como conven��o adotada em conjunto com o Adriano, ficou    ���
���          � estabelecido que teclados de 16 teclas ser�o considerados  ���
���          � Willbor, portanto isto ficar� constatado se os 2 �ltimos   ���
���          � bytes da string for igual a 10.                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function GIsWill()
LOCAL cRet := " "
LOCAL lRet := .F.
LOCAL cBin := ""

helpstr := Chr(254) + StrZero(Terminal, 2) + "U"
fwrite( handle, helpstr, Len(helpstr) )
fread( handle, @helpstr, 2 )
cRet := Substr( helpstr, 1, 1 )

If cRet <> Chr(0)
	
	cBin := DecToBin(Asc(cRet))
	If substr(cBin,Len(cBin)-1,2) = '10'
		lRet := .T.
	EndIf
	
EndIf

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �   GECHO  � Autor � F�bio F. Pessoa       � Data � 18/09/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia um caracter para o display do terminal               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GEcho(dado)                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� dado                                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function GEcho( dado )
helpstr := chr(254)+padl( ltrim( str(terminal,2,0) ), 2, "0" )+"D"+dado
fwrite( handle, helpstr, len(helpstr) )
return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GCLEAR   � Autor � F�bio F. Pessoa       � Data � 18/09/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Apaga o display do terminal                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GClear()                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function GClear
helpstr := chr(254)+padl( ltrim( str(terminal,2,0) ), 2, "0" )+"L"
fwrite( handle, helpstr, len(helpstr) )
return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPrint   � Autor � F�bio F. Pessoa       � Data � 06/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Conforme um par�metro verifica qual a fun��o deve ser      ���
���          � chamada, se para a porta paralela (GPrintP) ou para a      ���
���          � porta serial (GPrintS).                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPrint()                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� String  - String que deseja-se imprimir                    ���
���          � NumTerm - N�mero do Terminal                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function GPrint( string, numterm )

If Substr(Mv_LjPorIm, numterm, 1) == "S"
	GPrintS( string, numterm )
Else
	GPrintP( string, numterm )
EndIf

return  .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPrintP  � Autor � F�bio F. Pessoa       � Data � 18/09/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia uma string para a porta de saida paralela do terminal���
���          � assinalado em um NumTerm (00 a 31).                        ���
���          � O aplicativo dever� ter o tratamento para que o array de   ���
���          � saida daquele terminal nao seja estourado (65535 caract).  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPrintP(String, NumTerm)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� String  - String que deseja-se imprimir                    ���
���          � NumTerm - N�mero do Terminal                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function GPrintP( string, numterm )
pinpos  [numterm+1] := pinpos  [numterm+1] + len( string )
pprinter[numterm+1] := pprinter[numterm+1] + string
return  .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPrintS  � Autor � F�bio F. Pessoa       � Data � 18/09/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia uma String para a porta de saida serial do terminal  ���
���          � assinalado em um NumTerm (00 a 31).                        ���
���          � O aplicativo dever� ter o tratamento para que o array de   ���
���          � saida daquele terminal nao seja estourado (65535 caract).  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPrintS(String, NumTerm)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� String  - String que deseja-se imprimir                    ���
���          � NumTerm - N�mero do Terminal                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function GPrintS( string, numterm )
sinpos  [numterm+1] := sinpos  [numterm+1] + len( string )
sprinter[numterm+1] := sprinter[numterm+1] + string
return  .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GFLUSHPRN � Autor � F�bio F. Pessoa       � Data � 18/09/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a tentativa de envio das informacoes contidas no buffer���
���          � de impressao de paralela e serial dos terminais.           ���
���          � Deve ser  chamada  com uma  alta  frequencia, pois a  nao  ���
���          � colocacao no buffer do schedule, implica na nao impressao  ���
���          � dos dados.                                                 ���
���          � O buffer do schedule e limitado a 200 posicoes que serao   ���
���          � assim preenchidas a cada chamada do GFLUSHPRN, e           ���
���          � descarregadas a cada chamada do schedule.                  ���
���          � Uma chamada do schedule nao significa que o buffer de      ���
���          � saida sera descarregado completamente. Porem sempre que    ���
���          � houver espaco para passar dados para este buffer a funcao  ���
���          � enviara alguma informacao.                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GFlushPrn()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function GFlushPrn
LOCAL i, j

If Substr(Mv_LjPorIm, Terminal+1, 1) == "S"
	helpstr := chr(1)
	i := 1
	Do While Substr( helpstr, 1, 1 ) == chr(1) .And. i <= 100
		
		if PINS<>POUTS
			helpstr:=chr(254)+padl( ltrim( str(terminal,2,0) ), 2, "0" )+"R"+substr(SPRN,POUTS,1)
			fwrite( handle, helpstr, len(helpstr) )
			fread( handle, @helpstr, 2 )
			if substr( helpstr, 1, 1 )=chr(1)
				POUTS := POUTS + 1
				i := i + 1
				
				For j := 1 To 1000
				Next j
				
			endif
		else
			SPRN:=""
			PINS:=1
			POUTS:=1
			i := 100
			helpstr:=chr(0)
		endif
		
	enddo
Else
	
	helpstr:=chr(1)
	do while substr( helpstr, 1, 1 )==chr(1)
		if PINP<>POUTP
			helpstr:=chr(254)+StrZero(terminal,2,0)+"I"+substr(PPRN,POUTP,1)
			fwrite( handle, helpstr, len(helpstr) )
			fread( handle, @helpstr, 2 )
			if substr( helpstr, 1, 1 )=chr(1)
				POUTP := POUTP + 1
			endif
		else
			PPRN:=""
			PINP:=1
			POUTP:=1
			helpstr:=chr(0)
		endif
	enddo
EndIf
return nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �   GGET   � Autor � F�bio F. Pessoa       � Data � 18/09/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Prepara todas as estruturas para o recebimento de uma      ���
���          � picture do teclado.                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GGet(Formato)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Formato  - Formato da picture                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function GGet( formato )
retorno := .T.
if WAITT==0
	KPIC:=formato   // guarda o formato
	PPIC:=1         // posiciona o ponteiro na 1a. posicao
	KBD:=""         // limpa o buffer de entrada
	WAITT:=1        // liga o flag de espera de picture
	retorno:=.T.
else
	retorno:=.F.
endif
return retorno

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GTRTECLA � Autor � F�bio F. Pessoa       � Data � 18/09/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua o recebimento de uma tecla e trata de acordo        ���
���          � com a picture de entrada de cada uim dos terminais         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GTrTecla()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lNormal - Default (.T.) - Retorna o Echo do caracter       ���
���          �           digitado para o Display do micro-terminal.       ���
���          �           .F. - Retorna a m�scara de senha '*'.            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Gtrtecla(lNormal)
lNormal := IIf(lNormal==Nil,.T.,lNormal)
retorno := .F.
gtecla  := " "
gpict   := " "

helpstr := chr(254)+strzero(terminal,2)+"K"
fwrite( handle, helpstr, len(helpstr) )
fread( handle, @helpstr, 2 )
gtecla:=substr( helpstr, 1, 1 )
if WAITT==0             // se o flag de espera por picture nao
	return .F.      // estiver ligado retorna erro.
endif
if gtecla<>Chr(0)     // se a existe tecla para tratar
	if gtecla==Chr(127)
		if PPIC==1
			KBD := Chr(ESC)
			WAITT := 0
			return .T.
		else
			do while PPIC>1
				Gecho(CHR(BKSP))
				PPIC:=PPIC-1
			enddo
			KBD:=""
		endif
	elseif gtecla==Chr(BKSP)
		if PPIC>1
			gpict := substr( KPIC, PPIC-1, 1 )
			if gpict=="/" .or. gpict=="."
				Gecho( gtecla )
				PPIC = PPIC-1
			endif
			PPIC = PPIC-1
			KBD := substr( KBD, 1, PPIC-1 )
			Gecho( gtecla )
		endif
	elseif gtecla==Chr(13)
		WAITT:=0
		retorno:=.T.
	else
		gpict=substr( KPIC, PPIC, 1 )
		if gpict=="X"
			KBD = KBD + gtecla
			PPIC = PPIC + 1
			Gecho( IIf(lNormal, gtecla, "*") )
		elseif gpict=="9"
			if gtecla>="0" .and. gtecla<="9" .or. gtecla=="."
				if gtecla=="."
					ajusta_ponto()
				else
					KBD = KBD + gtecla
					PPIC = PPIC + 1
					Gecho( IIf(lNormal, gtecla, "*") )
				endif
			endif
		elseif gpict=="A"
			if gtecla>="A" .and. gtecla<="Z" .or. gtecla==" "
				KBD = KBD + gtecla
				PPIC = PPIC + 1
				Gecho( IIf(lNormal, gtecla, "*") )
			endif
		endif
		gpict=substr( KPIC, PPIC, 1 )
		if gpict=="@"
			WAITT:=0
			retorno:=.T.
		elseif gpict=="/"
			PPIC = PPIC + 1
			Gecho("/")
		elseif gpict=="."
			Gecho(".")
			KBD := KBD + "."
			PPIC = PPIC + 1
		else
			retorno:=.F.
		endif
	endif
endif
return retorno

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AJUSTA_PONTO � Autor � F�bio F. Pessoa   � Data � 18/09/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tem como objetivo acertar a posi��o do . e , qdo. est�     ���
���          � ocorrendo a digita��o de valores em uma picture.           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ajusta_Ponto()                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
procedure ajusta_ponto
pponto   := 0
slen     := len(KBD)
posponto := 1

do while substr(KPIC, posponto, 1 )<>"."
	posponto:=posponto+1
	if posponto==len(KPIC)
		exit
	endif
enddo
if (posponto==len(KPIC)) .Or. (posponto < PPIC)
	return nil
endif
strdisp := REPLICATE(" ",posponto-1-LEN(ALLTRIM(KBD))) + ALLTRIM(KBD)
sppic := PPIC
do while SPPIC>1
	Gecho(chr(BKSP))
	sppic := sppic - 1
enddo
PPIC := posponto
Gdisplay( strdisp )
KBD:=strdisp
return nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Calc_Delay� Autor � F�bio F. Pessoa       � Data � 03/10/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula um Delay de espera.                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Calc_Delay()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� -                                                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Calc_Delay()
LOCAL NovoSeg

If DELAY <> 0
	
	NovoSeg  := Substr( Time(), 7, 2 )
	If NovoSeg <> SEGANT
		
		DELAY := DELAY - 1
		
		If DELAY == 0
			
			POS    := DESVIO
			SEGANT := "00"
			WAITT  := 0
			GGet(PICANT)             // Recebe a picture anterior
			
		EndIf
		
	EndIf
	
	SEGANT := NovoSeg
	
EndIf

Return NIL


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �  FinTer  � Autor � F�bio F. Pessoa       � Data � 23/09/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manda uma mensagem de finaliza��o para todos os terminais  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FinTer()                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� -                                                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FinTer
LOCAL lPode := .T.                // Pode fechar o sistema ?

terminal := 0
Do While terminal < nNumTer
	
	If POS > 2 .And. POS <= 100
		lPode := .F.
		Exit
	EndIf
	
	terminal := terminal + 1
	
EndDo

If lPode
	
	terminal := 0
	Do While terminal < nNumTer
		POS   := 1                    // define a posi��o inicial de entrada no programa
		WAITT := 0                    // inicializa o buffer de teclado
		PINP  := 0                    // inicializa entrada de impress�o paralela
		PINS  := 0                    // inicializa entrada de impress�o serial
		POUTS := 0                    // inicializa saida de impressao paralela
		POUTP := 0                    // inicializa saida de impress�o serial
		PPRN  := ""                   // inicializa o vetor de paralela
		SPRN  := ""                   // inicializa o vetor de serial
		GClear()                      // Envia dois apagamentos de display para que o
		GClear()                      // terminal possa ficar sincronizado com o PC
		If !GIsWill()
			GDisplay("O sistema foi finalizado ...")
		Else
			GDisplay("   O sistema foi    ")
			GPosCur ( 1, 0 )
			GDisplay("     finalizado     ")
		EndIf
		terminal := terminal + 1
	EndDo
	
Else
	
	If ! lMostrou
		ConOut( "Aguardando transacao pendente em algum microterminal..." )
		lMostrou := .T.
	Endif
	
EndIf

Return lPode

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � DecToBin � Autor � F�bio F. Pessoa   	� Data � 19/11/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Transforma um n�mero Descimal em uma string Bin�ria.       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � DecToBin(ExpN1)	 			 						      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 := N�mero decimal  								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SigaTer  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function DecToBin(nDec)
LOCAL nDividendo := nDec
LOCAL nResto     := 0
LOCAL sBin       := ""

While nDividendo >= 2
	
	nResto     := Mod(nDividendo,2)
	nDividendo := Int(nDividendo / 2)
	sBin       := Str(nResto,1,1) + sBin
	
EndDo

sBin := Str(nDividendo,1,1) + sBin

Return sBin