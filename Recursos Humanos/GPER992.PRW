#INCLUDE "RWMAKE.CH"        // INCLUIDO PELO ASSISTENTE DE CONVERSAO DO AP5 IDE EM 25/09/00
#INCLUDE "IMPGRPS.CH"

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���RdMake    � IMPGRPS  � Autor � Mauro                       � Data � 10/03/97 ���
�������������������������������������������������������������������������������Ĵ��
���Descricao � Impressao da Guia de INSS Formulario Continuo                    ���
�������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                    ���
�������������������������������������������������������������������������������Ĵ��
���Programador � Data   �CHAMADO/REQ�  Motivo da Alteracao                      ���
�������������������������������������������������������������������������������Ĵ��
���Mohanad     �28/02/14� M12RH01   �UnIficacao da Folha V12                    ���
���            �        �  194404   �                                           ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Function GPER992()        // INCLUIDO PELO ASSISTENTE DE CONVERSAO DO AP5 IDE EM 25/09/00
Local aFoneSM0 := {}

// DECLARACAO DE VARIAVEIS UTILIZADAS NO PROGRAMA ATRAVES DA FUNCAO    
// SETPRVT, QUE CRIARA SOMENTE AS VARIAVEIS DEFINIDAS PELO USUARIO,    
// IDENTIFICANDO AS VARIAVEIS PUBLICAS DO SISTEMA UTILIZADAS NO CODIGO 
// INCLUIDO PELO ASSISTENTE DE CONVERSAO DO AP5 IDE                    

SetPrvt("ADRIVER,AINFO,CCGC,CRAZAO,CENDERECO,CTELEFONE")
SetPrvt("CCEP,CCIDADE,CUF,CFPAS,CACTRAB,N22")
SetPrvt("CTIPINSC,NLIN,NOPCA,NVEZ,")

aDriver		:= LeDriver()
aInfo		:= {}
cCgc		:= ""
cRazao		:= ""
cEndereco	:= ""
cTelefone	:= ""
cCep		:= ""
cCidade		:= ""
cUf			:= ""
cFPAS		:= ""
cAcTrab		:= ""
nDeduz		:= 0
nTam		:= 0

DbSelectArea("SRZ")

IF !fInfo(@aInfo,cFil)
	Return Nil
Endif

cCgc      := aInfo[8]                      // CGC
cRazao    := Subs(aInfo[3]+Space(40),1,40) // Razao Social
cEndereco := Subs(aInfo[4]+Space(40),1,40)

/*FUNCAO PARA DESMEMBRAR O TELEFONE EM UM VETOR COM 3 ELEMENTOS:
1O ELEMENTO - REFERE-SE AO DDI
2O ELEMENTO - REFERE-SE AO DDD
3O ELEMENTO - REFERE-SE AO TELEFONE
DEVE-SE ENVIAR O TELEFONE EM UMA VARIAVEL CARACTER COM O CONTEUDO DO CAMPO SM0->M0_FONE.*/

aFoneSM0	:= FisGetTel(aInfo[10])
nTam		:= LEN(ALLTRIM(STR(aFoneSM0[03]))) 
cTelefone	:= Str(aFoneSM0[03], nTam)

cCep		:= aInfo[7]
cCidade		:= Subs(aInfo[5],1,20)
cUf			:= aInfo[6]
n22			:= 0
cFPAS		:= aInfo[17]	// CODIGO FPAS
cAcTrab		:= aInfo[18]	// CODIGO DE ACIDENTE DE TRABALHO
cTipInsc	:= If( aInfo[28] == 1, "2", "1" )

If !Empty(aInfo[27]) .And. cTipInsc == "2"
	cCgc := Transform(aInfo[27],"@R ##.###.#####/##")	// CEI
Else
	cCgc := Transform(cCgc,"@R ##.###.###/####-##")		// CNPJ
EndIf

//SETAR IMPRESSORA
If aReturn[4] == 1  // COMPRIMIDO
	@ nLin , 0 PSAY &(aDriver[3])
Else                // NORMAL
	@ nLin , 0 PSAY &(aDriver[4])
Endif

While .T.
	@ nLin , 0 PSAY Chr(18)+ Space(43) + cTipInsc + Space(13) + cCgc

	// CAMPO 11
	nLin := nLin + 2
	@ nLin , 0 PSAY Space(43) + cFPAS
	nLin := nLin + 2
	
	// CAMPO 13

   IF cTipo == 2
      @ nLin , 0 PSAY Space(43) + "1" + Space(1) + "3" + Space(4) + subs(MV_PAR10,3,1) + Space(1) + subs(MV_par10,4,1)
   Else
      @ nLin , 0 PSAY Space(43) + cCompetencia
   Endif
   nLin := nLin + 3
	
	// CAMPO 16
	If cEscolha == "1"
		If n16 #0 .And. n16 # Nil
			@ nLin , 0 PSAY Space(59)+ Transform(n16,"@E 999,999,999,999.99")
			n22 := n22 + n16
		Endif
	Else
		If n16Fil #0 .And. n16Fil # Nil
			@ nLin , 0 PSAY Space(59)+ Transform(n16Fil,"@E 999,999,999,999.99")
			n22 := n22 + n16Fil
		Endif
	Endif			
	nLin := nLin + 2
	
	// CAMPO 17
	If cEscolha == "1"
		If n17 #0 .And. n17 # Nil .Or. (n17a # 0)
			@ nLin, 0 PSAY Space(59)+ Transform(Max(n17 + n17a,0),"@E 999,999,999,999.99")
			n22 := n22 + Max(n17 + n17a,0)
			nDeduz := n17 + n17a
		Endif
	Else
		If n17Fil #0 .And. n17Fil # Nil .Or. (n17aFil # 0)
			@ nLin, 0 PSAY Space(59)+ Transform(Max(n17Fil + n17aFil,0),"@E 999,999,999,999.99")
			n22 := n22 + Max(n17Fil + n17aFil,0)
			nDeduz := n17Fil + n17aFil
		Endif
	Endif
	
	If nDeduz < 0		
		Aadd(aLog,{cParam,Transform(nDeduz,"@E 999,999,999,999.99")})
	EndIf
		
	nLin := nLin + 2
		
	// RAZAO SOCIAL
	@ nLin , 0 PSAY Space(2) + cRazao
	
	// CAMPO 18  CODIGO DE TERCEIROS
	If cEscolha == "1"	
		If n18 #0 .And. n18 # Nil
			@ nLin , 43 PSAY Space(14) + cTerceiros + Transform(n18,"@E 99,999,999,999.99")
			n22 := n22 + n18
		Endif
	Else
		If n18Fil #0 .And. n18Fil # Nil
			@ nLin , 43 PSAY Space(14) + cTerceiros + Transform(n18Fil,"@E 99,999,999,999.99")
			n22 := n22 + n18Fil
		Endif
	Endif			
	
	nLin := nLin + 4
	@ nLin, 0 PSAY Space(2) + cEndereco
	nLin := nLin + 1
	@ nLin , 0 PSAY Space(30) + cTelefone
	nLin := nLin + 1

	If cEscolha == "1"	
		If n21 #0 .And. n21 # Nil
			@ nLin, 0 PSAY Space(59)+ Transform(n21,"@E 999,999,999,999.99")
			n22 := n22 - n21
		Endif
	Else
		If n21Fil #0 .And. n21Fil # Nil
			@ nLin, 0 PSAY Space(59)+ Transform(n21Fil,"@E 999,999,999,999.99")
			n22 := n22 - n21Fil
		Endif
	Endif			
	nLin := nLin + 1
	
	@ nLin, 0 PSAY Space(02) + Transform(cCep,"@R #####-###") + Space(2) + cCidade + Space(5) + cUf
	nLin := nLin + 1	
	@ nLin, 0 PSAY Space(59) + Transform(n22,"@E 999,999,999,999.99")
	nLin := nLin + 3	
	
	// SALARIO CONTRIBUICAO EMPREGADOS - CAMPO 81
	If cEscolha == "1"
		If n81 #0 .And. n18 # NIL
			@ nLin, 0 PSAY Space(18)+Transform(n81,"@E 999,999,999,999.99")
		Endif
	Else
		If n81Fil #0 .And. n18Fil # NIL
			@ nLin, 0 PSAY Space(18)+Transform(n81Fil,"@E 999,999,999,999.99")
		Endif
	Endif			
	nLin := nLin + 2
	
	// EMPREGADOS/AUTONOMOS - CAMPO 82
	If cEscolha == "1"	
		If n82 #0 .And. n82 # NIL
			@ nLin , 0 PSAY Space(18)+Transform(n82,"@E 999,999,999,999.99")
		Endif
	Else
		If n82Fil #0 .And. n82Fil # NIL
			@ nLin , 0 PSAY Space(18)+Transform(n82Fil,"@E 999,999,999,999.99")
		Endif
	Endif			
	nLin := nLin + 1
	
	// TOTAL A PAGAR
	If cEscolha == "1"	
		If n22 #0 .And. n82 # NIL
			@ nLin, 0 PSAY Space(59)+Transform(n22,"@E 999,999,999,999.99")
		Endif
	Else
		If n22 #0 .And. n82Fil # NIL
			@ nLin, 0 PSAY Space(59)+Transform(n22,"@E 999,999,999,999.99")
		Endif
	Endif			
	nLin := nLin + 1	
	
	// CODIGO ACIDENTE DE TRABALHO
	@ nLin , 0 PSAY Space(10) + cAcTrab // CODIGO DE ACIDENTE DE TRABALHO
	nLin := nLin + 1

	@ nLin , 0 PSAY cTexto1 + cTexto2
	nLin := nLin + 1
	@ nlin,  0 PSAY cTexto3 + cTexto4 
	nLin := nLin + 1

	// CODIGO E DESCRICAO DO CENTRO DE CUSTO
	If Upper(cParam) #Replicate('\',Len(cParam))
		@ nLin, 2 PSAY AllTrim(cParam) + ' - ' + AllTrim(DescCc(cParam,cFil,26))
	EndIf	
    
	If nVez == 0
		Set Device to Screen
		Pergunte('GPR30A',.T.)
		nOpca := MV_PAR01 // 1=CONFIRMA  2=REPETE
		Set Device to Printer

		If nOpcA == 2
			Set Device to Print
			nVez := 0
			n22  := 0
			Loop
		ElseIf nOpcA == 1
			nVez := 1
		ElseIF nOpcA == 3
			nVez := 0
		Endif
	Endif
	
	nLin := nLin + 8
	@ nlin, 0 PSAY " "
	Exit
Enddo
