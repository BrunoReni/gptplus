#INCLUDE "RWMAKE.CH"        // INCLUIDO PELO ASSISTENTE DE CONVERSAO DO AP5 IDE EM 14/04/00
#INCLUDE "IMPGPS.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���RdMake    � IMPGPS  � Autor � Kleber Dias Gomes            � Data � 17/05/99 ���
�������������������������������������������������������������������������������Ĵ��
���Descricao � Impressao da GUIA DA PREVIDENCIA SOCIAL - GPS                    ���
�������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                    ���
�������������������������������������������������������������������������������Ĵ��
���Programador � Data   �CHAMADO/REQ�  Motivo da Alteracao                      ���
�������������������������������������������������������������������������������Ĵ��
���Mohanad     �28/02/14� M12RH01   �UnIficacao da Folha V12                    ���
���            �        �  194404   �                                           ���
���Emerson Camp�06/08/14�TQDDAY     �Corre��o de uma linha fora do local na     ���
���            �        �           �impress�o por filial                       ���
���Flavio Corr.�01/09/14�TQIF05     �Ajuste na variavel nTipRel/nOpcao 			���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Function GPER1035()        // INCLUIDO PELO ASSISTENTE DE CONVERSAO DO AP5 IDE EM 14/04/00
Local aFoneSM0 := {}

// DECLARACAO DE VARIAVEIS UTILIZADAS NO PROGRAMA ATRAVES DA FUNCAO
// SETPRVT, QUE CRIARA SOMENTE AS VARIAVEIS DEFINIDAS PELO USUARIO,
// IDENTIFICANDO AS VARIAVEIS PUBLICAS DO SISTEMA UTILIZADAS NO CODIGO
// INCLUIDO PELO ASSISTENTE DE CONVERSAO DO AP5 IDE

SetPrvt("AINFO,CCGC,CRAZAO,CENDERECO,CTELEFONE,CSTRING")
SetPrvt("CCEP,CCIDADE,CUF,CCEI,CFONE,CBAIRRO")
SetPrvt("CMUNICIPIO,N6,N9,N10,CSAVEMENUH,NOPCA")
SetPrvt("NVEZ,NLIN")
SetPrvt("nDeduz")

cString	   := "SRZ"					
aInfo      := {}
cCgc       := ""
cRazao     := ""
cEndereco  := ""
cTelefone  := ""
cCep       := ""
cCidade    := ""
cUf        := ""

dbSelectArea("SRZ")

IF !fInfo(@aInfo,cFil)
	Return Nil
Endif

cCgc	:= aInfo[8]								// CGC
cRazao	:= PadR(aInfo[3],40)					// RAZAO SOCIAL
cCei	:= If( aInfo[28] == 1, aInfo[27], "" )	// CEI

/*FUNCAO PARA DESMEMBRAR O TELEFONE EM UM VETOR COM 3 ELEMENTOS:
  		1O ELEMENTO - REFERE-SE AO DDI									
  		2O ELEMENTO - REFERE-SE AO DDD									
  		3O ELEMENTO - REFERE-SE AO TELEFONE								
   DEVE-SE ENVIAR O TELEFONE EM UMA VARIAVEL CARACTER COM O CONTEUDO DO CAMPO SM0->M0_FONE.*/
aFoneSM0	:= FisGetTel(aInfo[10])
nTam := LEN(ALLTRIM(STR(aFoneSM0[03]))) 
cFone		:= PadR("(" + Str(aFoneSM0[02],2) +") "+ Str(aFoneSM0[03], nTam), 14)

cEndereco 	:= PadR(aInfo[4],30)
cBairro   	:= PadR(aInfo[13],20)
cCep      	:= PadR(aInfo[7],8)
cMunicipio	:= PadR(aInfo[5],20)                                  
cUf       	:= PadR(aInfo[6],2)
n6        	:= 0
n9        	:= 0
n10       	:= 0                     
nDeduz		:= 0

oFont07    	:= TFont():New("Arial",07,10,,.F.,,,,.T.,.F.)
oFont09    	:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)  
oFont10    	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont10n   	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
oFont11    	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
oFont12n   	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
oFont15    	:= TFont():New("Arial",15,15,,.F.,,,,.T.,.F.)

// IMPRIME CEI POR CENTRO DE CUSTO
If nPorCc == 1 .OR. nPorCc == 2
	dbSelectArea("CTT")
	dbSeek(If(XFILIAL("CTT")==Space(FWGETTAMFILIAL),XFILIAL("CTT"),cFil)+cParam)
	//SE CTT_TIPO FOR IGUAL A "2" E CTT_RECFAT FOR DIFERENTE DE "S", PEGA DADOS DO TOMADOR
	If TYPE("CTT->CTT_CEI") #"U" .AND. CTT->CTT_TIPO == "2" .AND. ((TYPE("CTT->CTT_RECFAT") #"U" .and. CTT->CTT_RECFAT <> "S") .or. (TYPE("CTT->CTT_RECFAT") == "U")) //Cei
		cCei := Left(CTT->CTT_CEI,12)
	EndIf	
dbSelectArea("SRZ")
EndIf

If !Empty(cCei)
	cCei := Transform(cCei,"@R ##.###.#####/##")			// CEI
ElseIf nTipRel == 2	// SE ZEBRADO
	cCGC := PadR(Transform(cCgc,"@R ##.###.###/####-##"),18)// CGC
Else	
	cCGC := PadR(Transform(cCgc,"@R ########/####-##"),18)	// CGC
EndIf	

//SETAR IMPRESSORA
If lImpVez 
	If nTipRel = 2 
		@ nLin , 0 PSAY AvalImp(nColunas) 
	Endif 
	lImpVez := .F. 
EndIf 
	
While .T.
   // CAMPO 6
	If cEscolha == "1"
		If n16 #0 .And. n16 # Nil
			n6 := n6 + n16
			nDeduz := If(n6 < 0, n6, 0)
		Endif
		If (n17 #0 .And. n17 # Nil) .Or. (n17a # 0)
			nDeduz := If((n6 + (n17 + n17a)) < 0, (n6 + (n17 + n17a)), 0)
			n6 := n6 + (n17 + n17a)
		Endif
		If n21 #0 .And. n21 # Nil
			nDeduz 	:= If((n6 - n21) < 0, (n6 - n21), 0)
			n6 		:= Max(n6 - n21, 0)
		Endif
		n6 	:= Max(n6, 0)	
	Else
		If n16Fil #0 .And. n16Fil # Nil
			nDeduz 	:= If((n6 + n16Fil) < 0, (n6 + n16Fil), 0)
			n6 := n6 + n16Fil
		Endif
		If (n17Fil #0 .And. n17Fil # Nil) .Or. (n17aFil # 0)
			nDeduz 	:= If((n6 + (n17Fil + n17aFil)) < 0, (n6 + (n17Fil + n17aFil)), 0)
			n6 := n6 + (n17Fil + n17aFil)
		Endif
		If n21Fil #0 .And. n21Fil # Nil
			nDeduz 	:= If((n6 - n21Fil) < 0, (n6 - n21Fil), 0)
			n6 		:= Max(n6 - n21Fil, 0)
		Endif
		n6 	:= Max(n6, 0)	
	Endif
	// CAMPO 9
	If cEscolha == "1"
		If n18 #0 .And. n18 # Nil
			n9 := n9 + n18
		Endif
	Else
		If n18Fil #0 .And. n18Fil # Nil
			n9 := n9 + n18Fil
		Endif
	Endif
	// CAMPO 10
	If nValJuros #0 .And. nValJuros # Nil
		n10 := n10 + nValJuros
	EndIf
	If nDeduz < 0 
		IF (aScan(aLog, { |x | x[1]+x[3]  == cParam + ' - ' + AllTrim(DescCc(cParam,cFil,26)) + "1"   }) == 0)
			Aadd(aLog,{cParam + ' - ' + AllTrim(DescCc(cParam,cFil,26))   , Transform(nDeduz,"@E 999,999,999,999.99"), "1"})
		Endif 	
	EndIf
	//NAO GERA GUIA COM VALOR TOTAL IGUAL A ZERO OU NAO ATINGE O VALOR MINIMO DE RECOLHIMENTO DA GPS
	If (n6+n9+n10) == 0 
		Exit 
	Endif 
	If (nVlrMinGPS> 0 .and. (n6+n9+n10) < nVlrMinGPS) 
		IF (aScan(aLog, { |x| x[1]+x[3]  == cParam + ' - ' + AllTrim(DescCc(cParam,cFil,26))+ "2" }) == 0)			
			Aadd(aLog,{cParam+ ' - ' + AllTrim(DescCc(cParam,cFil,26)) , Transform((n6+n9+n10),"@E 999,999,999,999.99"),"2"}) 
		Endif 
		Exit
	Endif 
	If nTipRel == 3
		fGPSGrafica()
	Else
		If nTipRel == 1
			fCImpressao()   // IMPRESSAO DO RECIBO DE PAGAMENTO FORMULARIO CONTINUO
			If nVez == 0 .and. aReturn[5] # 1 
				//DESCARREGA TESTE DE IMPRESSAO
				fImpTeste(cString,nTipRel)
				If nOpcA == 2
					Set Device to Print
					nVez := 0
					n6   := 0
					n9   := 0
					n10  := 0
					nLin := nLin + 3
					Loop
				ElseIf nOpcA == 1
					nVez := 1    
				Endif		
			Endif	
		ElseIf nTipRel == 2
			fZImpressao()   // IMPRESSAO DO RECIBO DE PAGAMENTO FORMULARIO ZEBRADO 
		Endif
		If nTipRel = 1
			nLin := nLin + 5
		ElseIf nTipRel = 2
			nLin := nLin + 3
		Endif
	EndIf
	Exit
Enddo

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fZImpressao   � Autor � Kleber Dias Gomes� Data � 21.06.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � IMRESSAO DO RECIBO FORMULARIO ZEBRADO                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fZImpressao()                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
// Substituido pelo assistente de conversao do AP5 IDE em 14/04/00 ==> Function fZImpressao
Static Function fZImpressao()                                                                                                                 
//         10        20        30        40        50        60        70        80        90       100       110       120       130       140
// 12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//"*---------------------------------------------------------------------------------*------------------------*---------------------------*"//
//"|                            Ministerio da Previdencia e Assistencia Social-MPAS  | 3 - CODIGO DE          |                           |"//
//"|                                                                                 |     PAGAMENTO          |                           |"//
//"|                            Instituto Nacional do Seguro Social-INSS             *------------------------*---------------------------*"//
//"|                                                                                 | 4 - COMPETENCIA        |                           |"//
//"|                                                                                 *------------------------*---------------------------*"//
//"|                            GUIA DA PREVIDENCIA SOCIAL - GPS                     | 5 - IDENTIFICADOR      |                           |"//
//"*---------------------------------------------------------------------------------*------------------------*---------------------------*"//
//"| 1 - NOME OU RAZAO SOCIAL / FONE / ENDERECO:                                     | 6 - VALOR DO INSS      |                           |"//
//"|                                                                                 *------------------------*---------------------------*"//
//"|                                                                                 | 7 -                    |                           |"//
//"|                                                                                 *------------------------*---------------------------*"//
//"|                                                                                 | 8 -                    |                           |"//
//"*-------------------------------*-------------------------------------------------*------------------------*---------------------------*"//
//"| 2 - VENCIMENTO                |                                                 | 9 - VALOR DE OUTRAS    |                           |"//
//"| (Uso Exclusivo do INSS)       |                                                 | ENTIDADES              |                           |"//
//"*-------------------------------*-------------------------------------------------*------------------------*---------------------------*"//
//"| ATENCAO: E vedada a utilizacao de GPS  para  recolhimento de  receita de  valor |                        |                           |"//
//"| inferior ao estipulado  em   Resolucao  publicada  pelo  INSS,  A  receita  que | 10 - ATM/MULTA E JUROS |                           |"//
//"| resultar  valor  inferior devera  ser adicionada  a contribuicao ou importancia |                        |                           |"//
//"| correspondente nos meses subsequentes, ate que o  tal seja  igual  ou  superior *------------------------*---------------------------*"//
//"| valor minimo fixado                                                             | 11 - TOTAL             |                           |"//
//"*---------------------------------------------------------------------------------*------------------------*---------------------------*"//
//"|                                                                                   12 - AUTENTICACAO BANCARIA                         |"//
//"|                                                                                                                                      |"//
//"|                                                                                                                                      |"//
//"*--------------------------------------------------------------------------------------------------------------------------------------*"//
//"1�VIA - INSS - 2�VIA - CONTRIBUINTE"//

@ nLin , 0 PSAY "*" + Repl("-",81) + "*" + Repl("-",24) + "*" + Repl("-",23) + "*"
nLin := nLin + 1
@ nLin , 0 PSAY "|" + Space(28) + STR0002 + Space(2) + "| " + STR0003 + Space(10) + "|" + Space(23) + "|" //"Ministerio da Previdencia e Assistencia Social-MPAS"###"3 - CODIGO DE"
nLin := nLin + 1

// CAMPO 3	
@ nLin , 0 PSAY "|" + Space(81) + "|" + Space(5) + STR0004 + Space(10) + "|" + Space(18) + cCodPag + " |" //"PAGAMENTO"
nLin := nLin + 1
@ nLin , 0 PSAY "|" + Space(28) + STR0005 + Space(13) + "*" + Repl("-",24) + "*" + Repl("-",23) + "*" //"Instituto Nacional do Seguro Social-INSS"
nLin := nLin + 1

// CAMPO 4
If cTipo == 2
   @ nLin , 0 PSAY "|" + Space(81) + "| " + STR0006 + Space(8) + "|" + Space(15) + PadR("13"+"/"+Subs(mv_par07,3,4),7) + " |" //"4 - COMPETENCIA"
Else
   @ nLin , 0 PSAY "|" + Space(81) + "| " + STR0006 + Space(8) + "|" + Space(15) + PadR(Subs(mv_par07,1,2)+"/"+Subs(mv_par07,3,4),7)  + " |" //"4 - COMPETENCIA"
EndIf
nLin := nLin + 1
@ nLin , 0 PSAY "|" + Space(81) + "*" + Repl("-",24) + "*" + Repl("-",23) + "*"
nLin := nLin + 1

// CAMPO 5
If !Empty(cCei)                                                                                         
	@ nLin , 0 PSAY "|" + Space(28) + STR0007 + Space(21) + "| " + STR0008 + Space(6) + "|" + Space(07) + cCei + " |" //"GUIA DA PREVIDENCIA SOCIAL - GPS"###"5 - IDENTIFICADOR"
Else
	@ nLin , 0 PSAY "|" + Space(28) + STR0007 + Space(21) + "| " + STR0008 + Space(6) + "|" + Space(04) + cCGC + " |" //"GUIA DA PREVIDENCIA SOCIAL - GPS"###"5 - IDENTIFICADOR"
EndIf
nLin := nLin + 1
@ nLin , 0 PSAY "*" + Repl("-",81) + "*" + Repl("-",24) + "*" + Repl("-",23) + "*"
nLin := nLin + 1

// CAMPO 6
@ nLin , 0 PSAY "| " + STR0009 + Space(37) + "| " + STR0010 + Space(6) + "|" + Space(04) + Transform(n6,"@E 999,999,999,999.99")  +  " |" //"1 - NOME OU RAZAO SOCIAL / FONE / ENDERECO:"###"6 - VALOR DO INSS"
nLin := nLin + 1

// CAMPO 1 
@ nLin , 0 PSAY "| " + cRazao + " / " + cFone + Space(23) + "*" + Repl("-",24) + "*" + Repl("-",23) + "*"
nLin := nLin + 1
@ nLin , 0 PSAY "| " + cEndereco + " - " + cBairro + Space(27) + "| 7 -" + Space(20) + "|" + Space(23) + "|"
nLin := nLin + 1
@ nLin , 0 PSAY "| " + cCep + " - " + cMunicipio + " - " + cUF + Space(44) + "*" + Repl("-",24) + "*" + Repl("-",23) + "*"
nLin := nLin + 1
@ nLin , 0 PSAY "|" + Space(81) + "| 8 -" + Space(20) + "|" + Space(23) + "|"
nLin := nLin + 1 
@ nLin , 0 PSAY "*" + Repl("-",31) + "*" + Repl("-",49) + "*" + Repl("-",24) + "*" + Repl("-",23) + "*"
nLin := nLin + 1
@ nLin , 0 PSAY "| " + STR0011 + Space(16) + "|" + Space(49) + "| " + STR0012 + Space(4) + "|" + Space(23) + "|" //"2 - VENCIMENTO"###"9 - VALOR DE OUTRAS"
nLin := nLin + 1

// CAMPO 9
@ nLin , 0 PSAY "| " + STR0013 + Space(7) + "|" + Space(49) + "| " + STR0014 + Space(14) + "|" + Space(04) + Transform(n9,"@E 999,999,999,999.99")  +  " |" //"(Uso Exclusivo do INSS)"###"ENTIDADES"
nLin := nLin + 1
@ nLin , 0 PSAY "*" + Repl("-",31) + "*" + Repl("-",49) + "*" + Repl("-",24) + "*" + Repl("-",23) + "*"
nLin := nLin + 1
@ nLin , 0 PSAY "| " + STR0015 + " |" + Space(24) + "|" + Space(23) + "|" //"ATENCAO: E vedada a utilizacao de GPS  para  recolhimento de  receita de  valor"
nLin := nLin + 1
@ nLin , 0 PSAY "| " + STR0016 + " | " + STR0017 + " |" + Space(04) + Transform(n10,"@E 999,999,999,999.99") + " |" //"inferior ao estipulado  em   Resolucao  publicada  pelo  INSS,  A  receita  que"###"10 - ATM/MULTA E JUROS"
nLin := nLin + 1
@ nLin , 0 PSAY "| " + STR0018 + " |" + Space(24) + "|" + Space(23) + "|" //"resultar  valor  inferior devera  ser adicionada  a contribuicao ou importancia"
nLin := nLin + 1
@ nLin , 0 PSAY "| " + STR0019 + " *" + Repl("-",24) + "*" + Repl("-",23) + "*" //"correspondente nos meses subsequentes, ate que o  tal seja  igual  ou  superior"
nLin := nLin + 1
@ nLin , 0 PSAY "| " + STR0020 + Space(61) + "| " + STR0021 + Space(13) + "|" + Space(04) + Transform(n6+n9+n10,"@E 999,999,999,999.99") + " |" //"valor minimo fixado"###"11 - TOTAL"
nLin := nLin + 1
@ nLin , 0 PSAY "*" + Repl("-",81) + "*" + Repl("-",24) + "*" + Repl("-",23) + "*"
nLin := nLin + 1
@ nLin , 0 PSAY "|" + cTexto1 + cTexto2 + space(32) + STR0022 + Space(12) + "|"  //"12 - AUTENTICACAO BANCARIA"
nLin := nLin + 1
@ nLin , 0 PSAY "|" + cTexto3 + ctexto4 + space(70) + "|"
nLin := nLin + 1
// CODIGO E DESCRICAO DO CENTRO DE CUSTO
If Upper(cParam) #Replicate('\',Len(cParam))
	@ nLin,  0 PSAY "| " + PadR(AllTrim(cParam) + ' - ' + AllTrim(DescCc(cParam,cFil,26)),41) + Space(88) + "|"
Else
	@ nLin , 0 PSAY "|" + cFil + "-" + aInfo[1]+Space(130-(Len(cFil + "-" + aInfo[1]))) + "|" 
	
EndIf

nLin := nLin + 1
@ nLin , 0 PSAY "*" + Repl("-",130) + "*"
nLin := nLin + 1
If nLin < 40 
	@ nLin , 0 PSAY STR0034 // 1a. VIA - INSS
Else
	@ nLin , 0 PSAY STR0035 // 2a. VIA - CONTRIBUINTE
EndIf
nLin := nLin + 1

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fCImpressao   � Autor � Kleber Dias Gomes� Data � 21.06.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � IMRESSAO DO RECIBO FORMULARIO ZEBRADO                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fCImpressao()                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
// Substituido pelo assistente de conversao do AP5 IDE em 14/04/00 ==> Function fCImpressao
Static Function fCImpressao()        

@ nlin, 0 PSAY " "
nLin := nLin + 1
@ nLin , 0 PSAY + Space(68) + cCodPag
nLin := nLin + 2
If cTipo == 2
   @ nLin , 0 PSAY  Space(65) + PadR("13"+"/"+Subs(mv_par07,3,4),7)
Else
   @ nLin , 0 PSAY  Space(65) + PadR(Subs(mv_par07,1,2)+"/"+Subs(mv_par07,3,4),7)
EndIf
nLin := nLin + 2
If !Empty(cCei)
	@ nLin , 0 PSAY Space(57) + cCei
Else
	@ nLin , 0 PSAY Space(56) + cCGC
EndIf
nLin := nLin + 2
@ nLin , 0 PSAY Space(54) + Transform(n6,"@E 999,999,999,999.99")
nLin := nLin + 1
@ nLin , 0 PSAY Space(2) + cRazao
nLin := nLin + 1
@ nLin , 0 PSAY Space(2) + cFone
nLin := nLin + 1
@ nLin , 0 PSAY Space(2) + cEndereco + " - " + cBairro
nLin := nLin + 1
@ nLin , 0 PSAY Space(2) + cCep + " - " + cMunicipio + " - " + cUF
nLin := nLin + 2
@ nLin , 0 PSAY Space(54) + Transform(n9,"@E 999,999,999,999.99")
nLin := nLin + 2
@ nLin , 0 PSAY Space(54) + Transform(n10,"@E 999,999,999,999.99")
nLin := nLin + 2
@ nLin , 0 PSAY Space(54) + Transform(n6+n9+n10,"@E 999,999,999,999.99")
nLin := nLin + 1
@ nLin , 0 PSAY cTexto1 + cTexto2
nLin := nLin + 1
@ nlin,  0 PSAY cTexto3 + cTexto4 
nLin := nLin + 1
// CODIGO E DESCRICAO DO CENTRO DE CUSTO
If Upper(cParam) #Replicate('\',Len(cParam))
	@ nLin, 2 PSAY AllTrim(cParam) + ' - ' + AllTrim(DescCc(cParam,cFil,26))
EndIf

Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fImpTeste �Autor  �R.H. - Natie        � Data �  11/29/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Testa impressao de Formulario Teste                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static function fImpTeste(cString,nTipoRel)
//COMANDO PARA NAO SALTAR FOLHA APOS O MSFLUSH
SetPgEject(.F.)
//DESCARREGA TESTE DE IMPRESSAO
MS_Flush()  
fInicia(cString)
nlin := _Prow()
If nTipRel == 2
	@ nLin , 0 PSAY AvalImp(nColunas)
EndIf

Pergunte("GPR30A",.T.)
nOpca	:= If(mv_par01 = 1 ,1, 2)
    
Return nOpca

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fInicia   �Autor  �R.H.Natie           � Data �  11/12/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicializa Impressao                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fInicia(cString)

If nLastKey == 27
	Return .F. 
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Return .F. 
Endif

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IMPGPS    �Autor  �Microsiga           � Data �  06/29/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fGPSGrafica()
Local cStartPath := GetSrvProfString("StartPath","")
//INICIALIZACAO DO OBJETO GRAFICO
cBmp := cStartPath + "GPS.BMP" //LOGO DA RECEITA FEDERAL

//DEFINICAO DO BOX PRINCIPAL
oPrint:Box(nLin,0030,nLin+1100,2350)

//INCLUSAO DO LOGOTIPO DO MINISTERIO DA FAZENDA
If File(cBmp)
	oPrint:SayBitmap(nLin+10,040,cBmp,200,180)
EndIf
oPrint:Say(nLin+020,270,STR0002,oFont07) //"MINISTERIO DA PREVIDENCIA E ASSISTENCIA SOCIAL-MPAS"
oPrint:Say(nLin+070,270,STR0024,oFont07) //"SECRETARIA DA RECEITA PREVIDENCI�RIA - SRP"
oPrint:Say(nLin+120,270,STR0005,oFont07) //"INSTITUTO NACIONAL DO SEGURO SOCIAL-INSS"
oPrint:Say(nLin+170,270,STR0007,oFont12n) //"GUIA DA PREVIDENCIA SOCIAL - GPS"

oPrint:Line(nLin,1300,nLin+850,1300)
oPrint:Line(nLin,1800,nLin+850,1800)

//DEFINICAO DO QUADRO 01
oPrint:Line(nLin+270,030,nLin+270,1300) 
oPrint:Say(nLin+280,040,"1 - ",oFont10)
oPrint:Say(nLin+280,110,STR0025,oFont09) //"NOME OU RAZ�O SOCIAL / ENDERE�O / TELEFONE"
oPrint:Say(nLin+345,110,cRazao + " / " + cFone,oFont09)               
oPrint:Say(nLin+380,110,cEndereco + " - " + cBairro,oFont09)
oPrint:Say(nLin+415,110,cCep + " - " + cMunicipio + " - " + cUf,oFont09)

oPrint:Line(nLin+540,030,nLin+540,1300)
oPrint:Say(nLin+552,040,STR0011,oFont09) //"2 - VENCIMENTO"
oPrint:Say(nLin+582,040,STR0013,oFont09) //"(USO EXCLUSIVO DO INSS)"
oPrint:Line(nLin+540,450,nLin+630,450)
oPrint:Line(nLin+630,030,nLin+630,1300)

//DEFINICAO DO QUADRO 03                                                  
oPrint:Say(nLin+020,1305,STR0026,oFont09)//"3 - C�DIGO DE PAGAMENTO"
oPrint:Say(nLin+030,2010, cCodPag,oFont10)
//DEFINICAO DO QUADRO 04
oPrint:Line(nLin+090,1300,nLin+90,2350)
oPrint:Say(nLin+120,1305,STR0006,oFont09) //"4 - COMPET�NCIA"

If cTipo == 2
	oPrint:Say(nLin+130,2010,PadR("13"+"/"+Subs(mv_par07,3,4),7),oFont10)  
Else
	oPrint:Say(nLin+130,2010,PadR(Subs(mv_par07,1,2)+"/"+Subs(mv_par07,3,4),7),oFont10)  
EndIf

//DEFINICAO DO QUADRO 05
oPrint:Line(nLin+180,1300,nLin+180,2350)
oPrint:Say(nLin+200,1305,STR0008,oFont09) //"5 - IDENTIFICADOR"
If !Empty(cCei)                                                                                         
	oPrint:Say(nLin+210,2010,cCei,oFont10)
Else
	oPrint:Say(nLin+210,2010,cCgc,oFont10)
EndIf

//DEFINICAO DO QUADRO 06
oPrint:Line(nLin+270,1300,nLin+270,2350)
oPrint:Say(nLin+290,1305,STR0010,oFont09) //"6 - VALOR DO INSS"
oPrint:Say(nLin+300,1900,Transform(n6,"@E 999,999,999,999.99"),oFont11)
//DEFINICAO DO QUADRO 07
oPrint:Line(nLin+360,1300,nLin+360,2350)
oPrint:Say(nLin+380,1305,"7 -",oFont09)
//DEFINICAO DO QUADRO 08
oPrint:Line(nLin+450,1300,nLin+450,2350)
oPrint:Say(nLin+470,1305,"8 - ",oFont09)
//DEFINICAO DO QUADRO 09
oPrint:Line(nLin+ 540,1300,nLin+540,2350)
oPrint:Say(nLin+552,1303,STR0012,oFont09) //"9 - VALOR DE OUTRAS"
oPrint:Say(nLin+582,1350,STR0014,oFont09) //"ENTIDADES"
oPrint:Say(nLin+582,1900,Transform(n9,"@E 999,999,999,999.99"),oFont11)
//DEFINICAO DO QUADRO 10
oPrint:Line(nLin+630,1300,nLin+630,2350)
oPrint:Say(nLin+650,1305,STR0017,oFont09) //"10 - ATM/MULTA E JUROS"
oPrint:Say(nLin+670,1900,Transform(n10,"@E 999,999,999,999.99"),oFont11)
//DEFINICAO DO QUADRO 11
oPrint:Line(nLin+720,1300,nLin+720,2350)
oPrint:Say(nLin+760,1305,STR0021,oFont10) //"11 - TOTAL"
oPrint:Say(nLin+770,1900,Transform(n6+n9+n10,"@E 999,999,999,999.99"),oFont11)
//DEFINICAO DO QUADRO DE AVISO
oPrint:Say(nLin+0650,040,STR0028,oFont10n) //"ATEN��O:"
oPrint:Say(nLin+0650,270,STR0029,oFont07) //"� VEDADA A UTILIZA��O DE GPS PARA RECOLHIMENTO DE RECEITA DE "
oPrint:Say(nLin+0690,040,STR0030,oFont07) //"VALOR INFERIOR AO ESTIPULADO EM RESOLU��O PUBLICADA PELA SRP. A RECEITA QUE   "
oPrint:Say(nLin+0730,040,STR0031,oFont07) //"RESULTAR VALOR INFERIOR, DEVER� SER ADICIONADA A CONTRIBUI��O OU IMPORT�NCIA  "
oPrint:Say(nLin+0770,040,STR0032,oFont07) //"CORRESPONDENTE NOS MESES SUBSEQUENTES, AT� QUE O TOTAL SEJA IGUAL OU SUPERIOR "
oPrint:Say(nLin+0810,040,STR0033,oFont07) //"AO VALOR M�NIMO FIXADO."
//DEFINICAO DO QUADRO 12
oPrint:Line(nLin+850,030,nLin+850,2350)
oPrint:Say(nLin+870,1305,"12-",oFont10)
oPrint:Say(nLin+870,1370,STR0027,oFont10n) //"AUTENTICA��O BANC�RIA (SOMENTE NAS 1 E 2 VIAS)"

oPrint:Say(nLin+0870,0040,substr(cTexto1+cTexto2+cTexto3+cTexto4,1,76),oFont07)
oPrint:Say(nLin+0910,0040,substr(cTexto1+cTexto2+cTexto3+cTexto4,77),oFont07)

// CODIGO E DESCRICAO DO CENTRO DE CUSTO
If Upper(cParam) #Replicate('\',Len(cParam))
	oPrint:Say(nLin+1000,0040, PadR(AllTrim(cParam) + ' - ' + AllTrim(DescCc(cParam,cFil,26)),41),oFont10)
Else
	oPrint:Say(nLin+1000,0040, cFil + "-" + aInfo[1],oFont10)
EndIf

nQtdGps ++

If nQtdGps == 1
	oPrint:Say(nLin+1110,040,STR0034,oFont09)
	//DEFINICAO DO PICOTE
	oPrint:Say(nLin+1250,000,Replicate("-",132),oFont11)
	//SEGUNDA VIA
	nLin := 1480
EndIf

//FINALIZA A PAGINA
If nQtdGps == 2
	oPrint:Say(nLin+1120,040,STR0035,oFont09)
	oPrint:EndPage()
EndIf

Return .T.
