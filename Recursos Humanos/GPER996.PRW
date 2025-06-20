#Include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 05/07/00
#INCLUDE "IMPIRPJ.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���RdMake    � IMPIRPJ  � Autor � R.H. - Recursos Humano� Data � 26.01.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do comprovante de rendimentos pessoa juridica    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � DIRF                                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RdMake                                                     ���
�������������������������������������������������������������������������Ĵ��
���Programar � Data   � BOPS �  Motivo da Alteracao                       ���
�������������������������������������������������������������������������Ĵ��
���Cecilia C.�04/09/14�TQMSLV�Efetuada a limpeza do fonte.                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/

Function GPER996()        // incluido pelo assistente de conversao do AP5 IDE em 05/07/00

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CDESEMP,CDESEND,CDESCID,CUF,CTPINSC,CTELEF")
SetPrvt("CDESCEP,CCODRET,CTIPO,M->RL_CIDABEN,M->RL_NUMDOC,NLIN")
SetPrvt("NTOTRB,NTOTIR,CMESANT,NTOTBRUTO,NALIQ,NVALIR")
SetPrvt("T,")

cDesEmp := aInfo[3]
cDesEnd := aInfo[4]
cDesCid := aInfo[5]
cUf	 	:= aInfo[6]
cTpInsc := Str(aInfo[15],1)
cTelef  := aInfo[10]
cDesCep := ainfo[7]

cCodRet := SRL->RL_CODRET

If 	MV_PAR12 == 1	
	fIrPjPre()
Else
	fIrPjGraf()
EndIf


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���RdMake    � DIRFPJ   � Autor � R.H. - Recursos Humano� Data � 26.01.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao da DIRF em Formulario Continuo                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � DIRFPJ                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RdMake                                                     ���
�������������������������������������������������������������������������Ĵ��
���Programar � Data   � BOPS �  Motivo da Alteracao                       ���
�������������������������������������������������������������������������Ĵ��
���Marina    �30/08/00�      � Retirada parte DOS.                        ���
��|          �08/04/04�------� Acerto no Driver para Impressao            ���
���Andreia   �30/01/06�092400�-Ajuste para imprimir as pessoas juridicas  ���
��|          �        �      �cadastradas.                                ���
��|          �        �      �- Alteracao no tamanho do fonte.            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 05/07/00 ==> 	#DEFINE PSAY SAY

// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 05/07/00 ==> #INCLUDE "IMPIRPJ.CH"
Static Function fIrPjPre()
Local T	:= 0 
Local nX:= 0

cDesEmp := aInfo[3]
cDesEnd := aInfo[4]
cDesCid := aInfo[5]
cUf	  	:= aInfo[6]
cTpInsc := Str(aInfo[15],1)
cTelef  := aInfo[10]
cDesCep := ainfo[7]

cCodRet := SRL->RL_CODRET

dbSelectArea("SRL")
cTipo := TYPE("SRL->RL_CIDABEN")
If  cTipo == "U"
    M->RL_CIDABEN := SPACE(20)
    M->RL_NUMDOC  := SPACE(10)
Else
    M->RL_CIDABEN := SRL->RL_CIDABEN
    M->RL_NUMDOC  := SRL->RL_NUMDOC
Endif

dbSelectArea ( "SR4" )
dbSeek ( SRL->RL_FILIAL+SRL->RL_MAT+ SRL->RL_CPFCGC + SRL->RL_CODRET+ cAno )
If !Eof()
	SET DEVICE TO PRINT
	@ 00,00 PSAY AvalImp( Colunas ) 
	@ 01,00 PSAY " " + Replicate("-",78) + " "
	If ! (SRL->RL_CODRET $ '5952/5987/5960/5979' )
		@ 02,00 PSAY STR0001	//"|         MINISTERIO DA ECONOMIA      | COMPROVANTE ANUAL DE RENDIMENTOS PAGOS |"
	 	@ 03,00 PSAY STR0002	//"|         SECRETARIA ESPECIAL DA      | OU CREDITADOS E DE RETENCAO DE IMPOSTO |"
		@ 04,00 PSAY STR0003	//"|        RECEITA FEDERAL DO BRASIL    |   DE RENDA NA FONTE - PESSOA JURIDICA  |"
   Else
		@ 02,00 PSAY STR0044	//"|         MINISTERIO DA ECONOMIA      | COMPROVANTE ANUAL DE RETENCAO DE CSLL, |"
	 	@ 03,00 PSAY STR0045	//"|         SECRETARIA ESPECIAL DA      |  COFINS E PIS/PASEP - PESSOA JURIDICA  |"
		@ 04,00 PSAY STR0046	//"|         RECEITA FEDERAL DO BRASIL   |                                        |"
   EndIf
	@ 05,00 PSAY STR0004+"   "+PADR(MV_PAR08,14)+"|"	//"|                                     |         ANO CALENDARIO"
	@ 06,00 PSAY " " + Replicate("-",78) + " "

	@ 07,00 PSAY STR0005 	//"  1. - FONTE PAGADORA"
	@ 08,00 PSAY " " + Replicate("-",78) + " "
	@ 09,00 PSAY STR0006 // "| Nome Empresarial                               | CNPJ                        |"
	@ 10,00 PSAY "| "+PADR(cDesEmp,47)+"| "+PADR(cCgc,28)+"|"
	@ 11,00 PSAY "|" + Replicate("-",78) + "|"

//	@ 12,00 PSAY STR0007+" "+PADR(cDesEnd,67)+"|" // "| Endereco:"
//	@ 13,00 PSAY "|" + Replicate("-",78) + "|"
//	@ 14,00 PSAY STR0008+" "+PADR(cDesCid,33)+" | "+STR0009+" "+cUf+"  | "+STR0010+" "+PADR(cTelef,17)+"|" // "| Cidade:" ### "UF:" ### "FONE:"
//	@ 15,00 PSAY " " + Replicate("-",78) + " "
	@ 13,00 PSAY If(!(SRL->RL_CODRET $ '5952/5987/5960/5979' ),STR0011,STR0051)+PADL(SRL->RL_FILIAL+"-"+SRL->RL_MAT+"-"+SRL->RL_CC,27)		//"  2. - PESSOA JURIDICA BENEFICIARIA DOS RENDIMENTOS "
	@ 14,00 PSAY " " + Replicate("-",78) + " "
	@ 15,00 PSAY STR0012 + " "+ SRL->RL_CPFCGC + " | " + STR0013 + " "+PADR(SRL->RL_BENEFIC,40) + "  |"	//"| CNPJ:" ### "NOME EMPR.:"
	@ 16,00 PSAY " " + Replicate("-",78) + " "

	@ 18,00 PSAY If(! (SRL->RL_CODRET $ '5952/5987/5960/5979' ),STR0014,STR0052)	//"  3  - RENDIMENTO BRUTO E IMPOSTO DE RENDA RETIDO NA FONTE"
	@ 19,00 PSAY " " + Replicate("-",78) + " "
	@ 20,00 PSAY STR0015	//"| MES COD. DESCRICAO DO RENDIMENTO               REND. BRUTO       I.R. RETIDO |"
	@ 21,00 PSAY STR0016	//"|     RET.                                           R$                R$      |"
	@ 22,00 PSAY "|" + Replicate("-",78) + "|"
	nLin := 23
	nTotRb := 0.00
	nTotIr := 0.00

	dbSeek ( SRL->RL_FILIAL+SRL->RL_MAT+SRL->RL_CPFCGC+SRL->RL_CODRET+ cAno )
   	While SR4->(!Eof()) .AND. SR4->R4_FILIAL == SRL->RL_FILIAL .AND. SR4->R4_MAT == SRL->RL_MAT .AND. ;
										SR4->R4_CPFCGC == SRL->RL_CPFCGC .AND. SR4->R4_CODRET == SRL->RL_CODRET;
										.and. 	SR4->R4_ANO == cAno 
		
		cMesant   := SR4->R4_MES
		nTotBruto := 0
		nAliq     := 0
		nValIR    := 0
	   	While ! Eof() .AND. SR4->R4_FILIAL == SRL->RL_FILIAL .AND. SR4->R4_MAT == SRL->RL_MAT .AND. ;
					SR4->R4_CPFCGC == SRL->RL_CPFCGC .AND. SR4->R4_CODRET == SRL->RL_CODRET .AND. ;
					SR4->R4_ANO == cAno .and. SR4->R4_MES == cMesAnt
			
		    If Len(Alltrim(SR4->R4_TIPOREN)) == 1

				If ! Alltrim(SR4->R4_TIPOREN) $ "ABD"
					dbSkip()
					Loop
				EndIf	
			
				If nAliq == 0
					If Alltrim(SR4->R4_TIPOREN) == "B"
						nAliq  := SR4->R4_VALOR
					Endif
				Endif
				If Alltrim(SR4->R4_TIPOREN) == "A"
					nTotBruto := nTotBruto + SR4->R4_VALOR
				Endif
				If Alltrim(SR4->R4_TIPOREN) == "D"
					nValIR    := nValIR + SR4->R4_VALOR
				Endif
			EndIf
			dbSkip()
			
		Enddo
	   	If Round(nTotBruto,2) + Round(nValIr,2) > 0.00
	      nTotRb := nTotRb + Round(nTotBruto,2)
	      nTotIr := nTotIr + Round(nValIR,2)
	      @ nLin,00 PSAY "| " + cMesAnt + "  " + cCodRet + " " + Subs(cDescRet,1,30) +;
	   	          " "  + Transform(Round(nTotBruto,2),"@E 999,999,999,999.99")+"  "+;
	                "  " + Transform(Round(nValIR,2),"@E 999,999,999.99") + " |"
			nLin:=nLin+1
		Endif
	Enddo
	For T:=(nLin-26) TO 12
		@ nLin,00 PSAY "|"+Space(78)+"|"
		nLin:=nLin+1
	Next
	@ nLin,00 PSAY "|" + Replicate(" ",78) + "|"
	nLin:=nLin+1
	@ nLin,00 PSAY "|" + Replicate("-",78) + "|"
	nLin:=nLin+1
	@ nLin,00 PSAY STR0018	//"  4 - INFORMACOES COMPLEMENTARES"
	nLin:=nLin+1
	@ nLin,00 PSAY " " + Replicate("-",78) + " "
	nLin:=nLin+1
	
	For nx := 1 to len(aComplem)
	
		@ nLin,00 PSAY "| " +aComplem[nx,1]+"|"+TRANSFORM(acomplem[nX,2],"@E 99,999,999.99") +" |"
		nLin++
	Next nX
	
	nLin:=nLin+1
	@ nLin,00 PSAY " " + Replicate("-",78) + " "
	nLin:=nLin+2
	@ nLin,00 PSAY STR0019	//"  5. RESPONSAVEL PELAS INFORMACOES"
	nLin:=nLin+1
	@ nLin,00 PSAY " " + Replicate("-",78) + " "
	nLin:=nLin+1
	@ nLin,00 PSAY "|  "+cResponsa+space(16) + STR0020+ DtoC(dDataBase)+Space(14)+"|"	//"Data  : "
	nLin:=nLin+1
	@ nLin,00 PSAY " " + Replicate("-",78) + " "
	nLin:=nLin+1    

	If cCodRet == "5952"
		@ nLin,00 PSAY " " + OemToAnsi(Alltrim(STR0055))	// "Aprovado pela IN/RFB n� 459/2004"
	ElseIf cCodRet $ "5960#5979#5987"
		@ nLin,00 PSAY " " + OemToAnsi(Alltrim(STR0054))	// "Aprovado pela IN/RFB n� 1234, de 11 de janeiro de 2012"
	Else
		@ nLin,00 PSAY " " + STR0043	// "Aprovado pela IN/SRF No. 119/2000"
	EndIf
	
	SET DEVICE TO SCREEN

Endif

Return()
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpGraf   �Autor  �R.H.-Priscila       � Data �  01/02/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �Impressao Modo Grafico IMPIRPJ                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function	fIrPjGraf()

Local cFileFaz	:= ""
Local cStartPath:= GetSrvProfString("Startpath","")
Local nContador

oPrint:StartPage()

/*
��������������������������������������������������������������Ŀ
�Cabecalho                                                     �
����������������������������������������������������������������*/

cFileFaz 	:= cStartPath+ "RECEITA" + ".BMP" 			// Empresa+Filial

//-- CABECALHO
//Box Itens
nLin := 030
nLinI:= 030
nLin +=10

oPrint:Box( nLinI,0030,nLin+195,2350)  		// box Cabecalho
oPrint:Line(nLinI,1450,nLin+195,1450)		// Linha Div.Cabecalho
oPrint:SayBitmap(nLinI+10,050, cFileFaz,250,180) // Tem que estar abaixo do RootPath

nLin +=20

oPrint:say(nLin,500 ,STR0032,oFont13n)				//	ministerio da fazenda
If ! (SRL->RL_CODRET $ '5952/5987/5960/5979' )
	oPrint:Say(nLin,1475,STR0033,oFont10)				//Comprovante de rendimento
Else
	oPrint:Say(nLin,1475,STR0047,oFont10)				//"COMPROVANTE ANUAL DE RETEN��O DE CSLL,"
EndIf
nLin +=40
If ! (SRL->RL_CODRET $ '5952/5987/5960/5979' )
	oPrint:Say(nLin,1475,STR0035,oFont10)              //OU CREDITADOS E DE RETENCAO DE IMPOSTO DE
	nLin +=10
Else
	oPrint:Say(nLin,1475,STR0048,oFont10)				//"COFINS E PIS/PASEP - PESSOA JURIDICA  "
	nLin +=40
	oPrint:Say(nLin,1475,STR0053,oFont10)				//"(Lei n� 10.833, de 2003, art. 30)"
EndIf	
oPrint:say(nLin,500 ,STR0034,oFont13)              //secretaria de receita
If ! (SRL->RL_CODRET $ '5952/5987/5960/5979' )
	nLin +=30
	oPrint:Say(nLin,1475,STR0036,oFont10)              //RENDA NA FONTE - PESSOA JURIDICA
EndIf
nLin +=50
oPrint:Say(nLin,1560,STR0037,oFont10) 				//ano calendario
oPrint:Say(nLin,2010,mv_par08 + ")" ,oFont10n)      //ano  base

//Fonte Pagadora
oPrint:say ( 250, 040,STR0038,oFont12n)		// 1. - FONTE PAGADORA
oPrint:Box ( 300, 030, 400,2350)
oPrint:say ( 320, 040,STR0023,oFont08)		  			//Nome Empresarial
oPrint:say ( 360, 040,PADR(cDesEmp,47),oFont10)
//Linha Vertical
oPrint:line( 300,1800, 300,1800)
oPrint:say ( 320,1900,STR0022,oFont08)					//CNPJ
oPrint:say ( 360,1900,PADR(cCgc,28),oFont10)
//Pessoa Juridica Beneficiaria dos Rendimentos

oPrint:say ( 430, 040,If(! (SRL->RL_CODRET $ '5952/5987/5960/5979' ),STR0039,STR0049)+PADL(SRL->RL_FILIAL+"-"+SRL->RL_MAT+"-"+SRL->RL_CC,27),oFont12n)		//2. - PESSOA JURIDICA BENEFICIARIA DOS RENDIMENTOS
oPrint:Box ( 480, 030, 580,2350)
oPrint:say ( 500, 040,STR0023,oFont08) 				//Nome Empresarial

dbSelectArea("SRL")
cTipo := TYPE("SRL->RL_CIDABEN")
If  cTipo == "U"
	M->RL_CIDABEN := SPACE(20)
	M->RL_NUMDOC  := SPACE(10)
Else
	M->RL_CIDABEN := SRL->RL_CIDABEN
	M->RL_NUMDOC  := SRL->RL_NUMDOC
Endif

dbSelectArea ( "SR4" )
dbSeek (SRL->RL_FILIAL+SRL->RL_MAT+SRL->RL_CPFCGC+SRL->RL_CODRET+ cAno  )
If !Eof()
	oPrint:say ( 500,1900,STR0022,oFont08)							//CNPJ
	//Descricao do Nome Pessoa Juridica
	oPrint:say ( 540, 040,PADR(SRL->RL_BENEFIC,40),oFont10)		//"| CNPJ:" ### "NOME EMPR.:"
	//CNPJ
	oPrint:say ( 540,1900,TRANSFORM(SUBSTR(SRL->RL_CPFCGC,1,14),"@R ##.###.###/####-##"),oFont10)
	
	//Rendimento e Imposto Retido na fonte
	oPrint:say ( 610, 040,If(! (SRL->RL_CODRET $ '5952/5987/5960/5979' ),STR0040,STR0050),oFont12n)					//"  3  - RENDIMENTO BRUTO E IMPOSTO DE RENDA RETIDO NA FONTE"
	oPrint:Box ( 660, 030,1595,2350)
	oPrint:line( 760, 030, 760,2350)							//LINHA HORIZONTAL
	oPrint:line( 660, 250,1595, 250)							//Linha Vertical
	oPrint:line( 660, 550,1595, 550)	 						//Linha Vertical
	oPrint:line( 660,1510,1595,1510)	  						//Linha Vertical
	oPrint:line( 660,1900,1595,1900)	   						//Linha Vertical
	//Cabecalho - Mes / Codigo Retencao / Rendimento / Imposto /Retido//
	oPrint:say ( 680, 050,STR0024,oFont08)	   	 				//MES
	oPrint:say ( 680, 300,STR0025,oFont08)   	 				//CODIGO DE
	oPrint:say ( 710, 300,STR0026,oFont08)      				//RETENCAO
	oPrint:say ( 680, 700,STR0027,oFont08)      				//DESCRICAO DO RENDIMENTO
	oPrint:say ( 680,1550,STR0028,oFont08)       				//RENDIMENTO (R$)
	oPrint:say ( 680,1950,STR0029,oFont08)  				    //IMPOSTO RETIDO (R$)
	
	nTotRb := 0.00
	nTotIr := 0.00
	nPos:= 780
	While ! Eof() .AND. SR4->R4_FILIAL == SRL->RL_FILIAL .AND. SR4->R4_MAT == SRL->RL_MAT .AND. ;
		SR4->R4_CPFCGC == SRL->RL_CPFCGC .AND. SR4->R4_CODRET == cCodRet .and. SR4->R4_ANO == cAno
		
		cMesant   := SR4->R4_MES
		nTotBruto := 0
		nAliq     := 0
		nValIR    := 0
		
		While ! Eof() .AND. SR4->R4_FILIAL == SRL->RL_FILIAL .AND. SR4->R4_MAT == SRL->RL_MAT .AND. ;
			SR4->R4_CPFCGC == SRL->RL_CPFCGC .AND. SR4->R4_CODRET == SRL->RL_CODRET .AND. ;
			SR4->R4_ANO == cAno .and. SR4->R4_MES == cMesAnt
			
		    If Len(Alltrim(SR4->R4_TIPOREN)) == 1

				If ! Alltrim(SR4->R4_TIPOREN) $ "ABD"
					dbSkip()
					Loop
				EndIf	
	
				If nAliq == 0
					If Alltrim(SR4->R4_TIPOREN) == "B"
						nAliq  := SR4->R4_VALOR
					Endif
				Endif
				If Alltrim(SR4->R4_TIPOREN) == "A"
					nTotBruto := nTotBruto +SR4->R4_VALOR
				Endif
				If Alltrim(SR4->R4_TIPOREN) == "D"
					nValIR    := nValIR + SR4->R4_VALOR
				Endif
			EndIf
			dbSkip()
		Enddo
		oPrint:say(nPos, 055,cMesAnt,oFont14)					//Mes
		oPrint:say(nPos, 320,cCodRet,oFont14)					//Codigo Retencao
		oPrint:say(nPos, 600,Subs(cDescRet,1,41),oFont14)		//Descricao do Rendimento
		oPrint:say(nPos,1500,Transform(Round(nTotBruto,2),"@E 999,999,999,999.99"),oFont14)				//Rendimento
		oPrint:say(nPos,2000,Transform(Round(nValIR,2),"@E 999,999,999.99"),oFont14)					//Imposto Retido
		If cMesAnt #"12"
			nPos+=40
			oPrint:line(npos,030,npos,2350)
			npos+=30
		EndIf
	Enddo

	//INFORMACOES COMPLEMENTARES
	nPos := 1640
	oPrint:say (nPos, 040,STR0041,oFont12n)   	   		//"  4 - INFORMACOES COMPLEMENTARES"
	nPos += 60
	nLinI:=nPos -10
	nItem := 1

	If Empty(aComplem)              
		nPos+=230
		oPrint:box(nLinI,0030,nPos ,2350) 
		oPrint:line(nLinI,1900,nPos ,1900)
	Else 
		nLinhas	:= Int(nPos    + (  (Len(aComplem)+1 )    * 50  ) )
		oPrint:box(nLinI,0030,nLinhas,2350)
		oPrint:line(nLinI,1900,nLinhas,1900)
		For nContador := 1 to len(aComplem)
		    oPrint:say(nPos,0040,aComplem[nContador,1],oFont10)
		    oPrint:Say(nPos,2000,TRANSFORM(aComplem[nContador,2],"@E 99,999,999.99"),oFont12)
		    nPos +=50
			oPrint:line(nLinI,1900,nPos,1900)
			nPos +=30
		Next nContador 
	Endif
	nPos+=60
	//RESPONSAVEL PELAS INFORMACOES
	oPrint:Say(nPos,0040,STR0042,ofont12n)			//"  7. - Responsavel Pelas Informacoes"
	nPos	+=50 
	oPrint:Box(nPos,0030,nPos + 100,2350)
	oPrint:Line(nPos,1300,nPos+ 100,1300)
	oPrint:Line(nPos,1540,nPos+ 100,1540)
	
	nPos +=20
	oPrint:say(nPos,0040,STR0030,oFont08)
	oPrint:Say(nPos,1340,STR0020,oFont08)
	oPrint:Say(nPos,1550,STR0031,oFont08)
	
	nPos += 30
	oPrint:say(nPos,0050,cResponsa,ofont10)
	oPrint:say(nPos,1340,DtoC(dDataBase),oFont10)
	
	nPos+=50
	
	If cCodRet == "5952"
		oPrint:say(nPos, 0040, OemToAnsi(Alltrim(STR0055)), oFont08)	// "Aprovado pela IN/RFB n� 459/2004"
	ElseIf cCodRet $ "5960#5979#5987"
		oPrint:say(nPos, 0040, OemToAnsi(Alltrim(STR0054)), oFont08)	// "Aprovado pela IN/RFB n� 1234, de 11 de janeiro de 2012"
	Else	
		oPrint:say(nPos,0040,STR0043,oFont08)		// "Aprovado pela IN/SRF No. 119/2000"
	EndIf	
Endif

oPrint:EndPage()

Return()

/*
LAY-OUT MODELO
 ------------------------------------------------------------------------------ 
|         MINISTERIO DA ECONOMIA      | COMPROVANTE ANUAL DE RENDIMENTOS PAGOS |
|         SECRETARIA ESPECIAL DA      | OU CREDITADOS E DE RETENCAO DE IMPOSTO |
|        RECEITA FEDERAL DO BRASIL    |   DE RENDA NA FONTE - PESSOA JURIDICA  |
|                                     |         ANO CALENDARIO 9999            |
 ------------------------------------------------------------------------------ 
  1. - Fonte Pagadora        
 ------------------------------------------------------------------------------ 
| Nome Empresarial                               | CNPJ                        |
| XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX       | 99999999999999              |
|------------------------------------------------------------------------------|
| Endereco:   : XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                         |
|------------------------------------------------------------------------------| 
| Cidade: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  |   UF: XX  | FONE: 9999 9999-9999   |
 ------------------------------------------------------------------------------ 
  2. - PESSOA JURIDICA BENEFICIARIA DOS RENDIMENTOS                  01-000000
 ------------------------------------------------------------------------------ 
| CNPJ: 99999999999999 | NOME EMPR.: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  |
 ------------------------------------------------------------------------------ 
  3  - RENDIMENTO BRUTO E IMPOSTO DE RENDA RETIDO NA FONTE
 ------------------------------------------------------------------------------ 
| MES COD. NATUREZA DO RENDIMENTO           REND. BRUTO  ALIQ.     I.R. RETIDO |
|     DARF                                      R$       ( % )         R$      |
|------------------------------------------------------------------------------|
| 01  0561 Rendimentos do Trabalho A           9.999,99   0,00            0,00 |
| 02  0561 Rendimentos do Trabalho A           9.999,99   0,00            0,00 |
| 03  0561 Rendimentos do Trabalho A           9.999,99   0,00            0,00 |
| 04  0561 Rendimentos do Trabalho A           9.999,99   0,00            0,00 |
| 05  0561 Rendimentos do Trabalho A           9.999,99   0,00            0,00 |
| 12  0561 Rendimentos do Trabalho A             999,99   0,00            0,00 |
|                                                                              |
|                                                                              |
|                                                                              |
|                                                                              |
|                                                                              |
|                                                                              |
|                                                                              |
|                                                                              |
|------------------------------------------------------------------------------|
|       T O T A L                             999999,99                   0,00 |
|------------------------------------------------------------------------------|
  4  - INFORMACOES COMPLEMENTARES
 ------------------------------------------------------------------------------ 
|                                                                              |
|                                                                              |
 ------------------------------------------------------------------------------ 
  5 - RESPONSAVEL PELAS INFORMACOES 
 ------------------------------------------------------------------------------ 
|  Emitido atraves de processamento automatico de dados, sendo dispensada a    |
|  assinatura ou chancela mecanica, conforme Instrucao Normativa No. 88/97.    |
|------------------------------------------------------------------------------|
|  xxxxxxxxxxxxxxxxxxx                           Data  : 99/99/99              |
 ------------------------------------------------------------------------------
*/

Return(nil)        // incluido pelo assistente de conversao do AP5 IDE em 04/02/00

