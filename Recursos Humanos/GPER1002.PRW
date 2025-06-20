#INCLUDE "RWMAKE.CH"
#INCLUDE "IMPRESZ.CH"
#INCLUDE "Protheus.CH"

// VARIAVEIS UTILIZADAS PARA ARMAZENAR AS INFORMACOES DAS PERGUNTES:
//VARIAVEL					   ORDEM
//nTipo				MV_PAR01  01	//	ZEBRADO/GRAFICO/PRE-IMPR/GRFC ZEBRADO/GRFC GRAFICA
//cFilialDe			MV_PAR02  02	//	FILIAL DE
//cFilialAte		MV_PAR03  03	//	FILIAL ATE
//cMatDe			MV_PAR04  04	//	MATRICULA DE
//cMatAte			MV_PAR05  05	//	MATRICULA ATE
//cCCDe				MV_PAR06  06	//	CENTRO DE CUSTO DE
//cCCAte			MV_PAR07  07	//	CENTRO DE CUSTO ATE
//cTipoRes			MV_PAR08  08	//	NORMAL OU COMPLEMENTAR
//cImprCGC			MV_PAR09  09	//	IMPRIME CGC  SIM OU NAO
//dDtDemDe			MV_PAR10  10	//	DATA DEMISSAO DE
//dDtDemAte			MV_PAR11  11	//	DATA DEMISSAO ATE
//dDtGerDe			MV_PAR12  12	//	DATA GERACAO DE
//dDtGerAte			MV_PAR13  13	//	DATA GERACAO ATE
//nImprDtHom		MV_PAR14  14	//	IMPRIME DATA DE HOMOLOGACAO
//nNumVias			MV_PAR15  15	//	N� DE VIAS
//cImprFerias		MV_PAR16  16	//	IMP. FERIAS    		 AVOS OU DIAS
//dDtHomDe			MV_PAR17  17	//	DATA DE HOMOLOGA�CAO DE
//dDtHomAte			MV_PAR18  18	//	DATA DE HOMOLOGA�CAO AT
//cContato			MV_PAR19  19	//	NOME PARA CONTATO
//					MV_PAR20  20	//	RODAPE DO RECIBO
//					MV_PAR21  21	//	COMP. VERB 50
//					MV_PAR22  22	//	RG
//					MV_PAR23  23	//	NOME DO EMPREGADOR
//					MV_PAR24  24	//	TIPO DO ORGAO HOMOLOGADOR
//					MV_PAR25  25	// CODIGO DO MINISTERIO
//dDtDissidio		MV_PAR26  26	//	DT PUBLIC.DISS/ACOR
//nTipSal			MV_PAR27  27	//	TIPO DO SALARIO?
//					MV_PAR28  28	//	IMPRIMIR INF. EXTRA?
//					MV_PAR29  29	//	GRUPO DE VERBAS QUE COMPOEM A REMUNERACAO
//					MV_PAR30  30	//	IMPRIME CABECALHO EM OUTRA PAGINA?
//					MV_PAR31  31	//	AJUSTA LINHAS EM BRANCO?
//cImpr13Sal		MV_PAR32  32	//	IMP. 13� SAL�RIO
//cTelefone			MV_PAR33  33	//	DDD/TELEFONE
//nSimples			MV_PAR34  34	//	OPTANTE DO SIMPLES
//dEntregaGRFC		MV_PAR35  35	//	DT. ENTREGA GRFC
//					MV_PAR36  36	//	TODAS RESCISOES COMPL?


/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���RdMake    � ImpResZ  � Autor � Mauro                        � Data � 10.03.97 ���
��������������������������������������������������������������������������������Ĵ��
���Descricao � Impressao da Rescisao em Papel Zebrado                            ���
��������������������������������������������������������������������������������Ĵ��
���Sintaxe e � ImpResZ                                                           ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                          ���
��������������������������������������������������������������������������������Ĵ��
���              ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.               ���
��������������������������������������������������������������������������������Ĵ��
���PROGRAMADOR � DATA     �CHAMADO/REQ�  MOTIVO DA ALTERACAO                     ���
��������������������������������������������������������������������������������Ĵ��
���Mohanad     | 07/02/14 |M12RH01   |Unificacao da Folha V12                    ���
���            |          |197401	  |                                           ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Function GPER1002()        // incluido pelo assistente de conversao do AP5 IDE em 05/07/00
Local Imprime	:= 0 

//Declaracao de variaveis utilizadas no programa atraves da funcao
//SetPrvt, que criara somente as variaveis definidas pelo usuario,
//identificando as variaveis publicas do sistema utilizadas no codigo
//Incluido pelo assistente de conversao do AP5 IDE

SetPrvt("LNULL,NCONTAR,NLI,DET,X,cCodSaqIOB")

lNull   := .F.
nContar := 0
nLi     := 0
nEpoca	:= SET(5,1910)
Private lGPEM40B := .F.

DbSelectArea("SX1")
If IsInCallStack("GPEM040B") .And. SX1->(dbSeek("GPE140R2"))
	lGPEM40B	:= .T.
EndIf

//--MUDAR ANO PARA 4 DIGITOS
SET CENTURY ON

fCabecalho()
   
For Imprime := 1 to Max(Len(aPdv),Len(aPdd))
	If Max(Len(aPdv)/2,Len(aPdd)) <= 16
		If Imprime <= 16 .And. Imprime <= Len(aPdv)
			Det := Space(1) + aPdv[Imprime]+"|"
		Else
			Det := Space(42)+"|"
		Endif
		
		If Imprime + 16 <= Len(aPdv)
			Det := Det + Space(1) + aPdv[Imprime + 16]+"|"
		Else
			Det := Det + Space(42)+"|"
		Endif
		
		If Imprime <= Len(aPdd)
			Det := Det + Space(1) + aPdd[Imprime]+" |"
		Else
			Det := Det + Space(42)+" |"
		Endif
		
		If Det <> Space(42)+"|"+Space(42)+"|"+Space(42)+" |"
	    	@ nLi,001 PSAY "|" + Det
		   nLi := nLi + 1
		   nContar := nContar + 1
		Else
	      Exit
		Endif
	Else
		If Imprime <= Len(aPdv)/2 .And. Imprime <= Len(aPdv)
			Det := Space(1) + aPdv[Imprime]+"|"
		Else
			Det := Space(42)+"|"
		Endif
		
		If Imprime + If(Len(aPdv)%2>0,Len(aPdv)/2-1,Len(aPdv)/2) <= Len(aPdv)
			Det := Det + Space(1) + aPdv[Imprime + Len(aPdv)/2]+"|"
		Else
			Det := Det + Space(42)+"|"
		Endif
		
		If Imprime <= Len(aPdd)
			Det := Det + Space(1) + aPdd[Imprime]+" |"
		Else
			Det := Det + Space(42)+" |"
		Endif
		
		If Det <> Space(42)+"|"+Space(42)+"|"+Space(42)+" |"
	    	@ nLi,001 PSAY "|" + Det
		   nLi := nLi + 1
		   nContar := nContar + 1
		Else
	      Exit
		Endif
		If nContar > 16
			lNull := .T.
			fRodape()
			lNull := .F.
			fCabecalho()
		EndIf
	EndIf
Next

fRodape()

Set(5,nEpoca)
If nTdata > 8
	SET CENTURY ON
Else
	SET CENTURY OFF
Endif

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fCabecalho � Autor � Equipe RH            � Data �28/01/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �Imprime cabecalho                                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fCabecalho()
Local cCateg		:= fCateg(0)
Local nSalIncorp 	:= 0
nLi					:= 1

@ nLi,001 PSAY AvalImp(132)

If !Empty(SRA->RA_CHIDENT) 
	@ nLi,020 PSAY If(lGPEM40B, If(MV_PAR02 == 1, STR0002, STR0003), If(MV_PAR08 == 1, STR0002, STR0003)) //"TERMO DE RESCISAO DO CONTRATO DE TRABALHO"  /   TERMO DE RESCISAO DO CONTRATO DE TRABALHO ( COMPLEMENTAR ) "
	@ nLi,085 PSAY STR0058 + SRA->RA_CHIDENT    								// Chave Identif.: 999999999999999999999999
Else 
	@ nLi,045 PSAY If(lGPEM40B, If(MV_PAR02 == 1, STR0002, STR0003), If(MV_PAR08 == 1, STR0002, STR0003))	//"TERMO DE RESCISAO DO CONTRATO DE TRABALHO" / /   TERMO DE RESCISAO DO CONTRATO DE TRABALHO ( COMPLEMENTAR ) "
Endif 
nLi:= nLi+ 1
@ nLi,001 PSAY STR0049 												//_______________________
nLi := nLi + 1                    
@ nLi,001 PSAY STR0005 												//| Identificacao do Empregador  " 
nLi := nLi + 1
@ nLi,001 PSAY STR0056 + SUBSTR (If( Len(aInfo) >= 27 .And. !Empty( aInfo[27] )  .And. aInfo[28] == 1, aInfo[27], aInfo[8] )+Space(20),1,20) + STR0001 + SUBSTR(aInfo[3],1,56) + "-" + STR0055 + SRA->RA_FILIAL 	//"|01- CNPJ#|02- Razao Social / Nome:" ##" Filial: "
@ nLi,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY "|"+Replicate("-",129)+ "|"
nLi := nLi + 1
@ nLi,001 PSAY "|03" + STR0011+ Trim(aInfo[4])	+ Space(1) + Trim(aInfo[14])		//"|03 Endereco   : "
@ nLi,090 PSAY "|04" + STR0014+aInfo[13] 							//"|04 Bairro : "
@ nLi,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY "|" + Replicate("-",129)+"|"
nLi := nLi + 1
@ nLi,001 PSAY "|05" + STR0015+AllTrim(aInfo[5])					//"|05 Munic.: "
@ nLi,035 PSAY "|06" + STR0016+aInfo[6]								//"|06 UF : "
@ nLi,048 PSAY "|07" + STR0013+aInfo[7]								//"|07 Cep: "
@ nLi,068 PSAY STR0017+Subs(aInfo[16],1,7)							//"|08 CNAE"
@ nLi,086 PSAY STR0004+Substr(fDesc("SI3",SRA->RA_CC,"I3_CEI")+Space(5),1,15)	//"|09 CNPJ/CEI Tomador/Obra: " 
@ nLi,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY STR0006 												//| Identificacao do Trabalhador//
nLi := nLi + 1
@ nLi,001 PSAY STR0025+SRA->RA_PIS				  					//"|10 PIS/PASEP:"

If !Empty(SRA->RA_NOMECMP)
	@ nLi,035 PSAY STR0023+Subs(SRA->RA_NOMECMP+Space(50),1,50)	   	//"|11 NOME:" ## Nome completo
	@ nLi,100 PSAY STR0057+SRA->RA_MAT									//"|Matricula: "
Else
	@ nLi,035 PSAY STR0023+Subs(SRA->RA_NOME+Space(30),1,30)		   	//"|11 NOME:"  ## Nome
	@ nLi,080 PSAY STR0057+SRA->RA_MAT									//"|Matricula: "
EndIf	

@ nLi,131 PSAY "|"     
nLi := nLi + 1
@ nLi,001 PSAY "|"+Replicate("-",129)+"|"
nLi := nLi + 1
@ nLi,001 PSAY "|12"+STR0011+SRA->RA_ENDEREC+SPACE(1)+SRA->RA_COMPLEM //"|12 Endereco   : "
@ nLi,080 PSAY "|13"+STR0014+SRA->RA_BAIRRO	 						 //"|13 Bairro : "
@ nLi,131 PSAY "|"     
nLi := nLi + 1
@ nLi,001 PSAY "|"+Replicate("-",129)+"|"
nLi := nLi + 1
@ nLi,001 PSAY "|14" + STR0015+SRA->RA_MUNICIP 									//"|05 Munic.: "
@ nLi,035 PSAY "|15" + STR0016+SRA->RA_ESTADO 		 							//"|15 UF : "  
@ nLi,048 PSAY "|16" + STR0013+SRA->RA_CEP										//"|16 Cep: "      
@ nLi,085 PSAY STR0024+SRA->RA_NUMCP+"/"+SRA->RA_SERCP+"/"+SRA->RA_UFCP	//"|13 Ctps/Serie/UF :"   
@ nLi,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY "|"+Replicate("-",129)+"|"
nLi := nLi + 1
@ nLi,001 PSAY STR0012+SRA->RA_CIC									//"|18 CPF:"
@ nLi,025 PSAY STR0027+DTOC(SRA->RA_NASC)				 			//"|19 Nasc.:"
@ nLi,048 PSAY STR0007+SUBSTR(SRA->RA_MAE+SPACE(30),1,40) 			//"|20 Nome da Mae"
@ nLi,131 PSAY "|"                                                                       
nLi := nLi + 1
@ nLi,001 PSAY STR0008											   		//"|Dados do Contrato "
nLi := nLi + 1
//TODO
If nTipSal == 1 // Sal�rio incorporado
	nSalIncorp := nRrValor
Else
	nSalIncorp := SRG->RG_SALMES
EndIf

@ nLi, 001 PSAY STR0009 + Transform(nSalIncorp, "@E 999,999,999.99")	// "|21 Remuneracao p/ fins rescisorios - Salario Mes

@ nLi,045 PSAY STR0010+DtoC(SRA->RA_ADMISSA)							//"|22 Admis:"
@ nLi,070 PSAY STR0018+DtoC(SRG->RG_DTAVISO)							//"|23 Data do Aviso Previo"
@ nLi,100 PSAY STR0030+DtoC(SRG->RG_DATADEM)							//"|24 Data do afastamento: 
@ nLi,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY "|"+Replicate("-",129)+"|"
nLi := nLi + 1
@ nLi,001 PSAY STR0034+cCodR + "- " +SubStr(cCausa+Space(30),1,30)	//"|25 Causa do Afastamento :"           

//CODIGOS DE SAQUE VALIDOS SEGUNDO O CALENDARIO DE OBRIGACOES E TABELAS PRATICAS DO IOB DE OUT/99 PAGINAS 62 A 68
cCodSaqIOB := "01_02_03_04_05_06_07_10_23_26_27_50_70_80_81_82_86_87_88_91_92_93_94_95" 

//SE O CODIGO NAO FOR VALIDO NAO IMPRIME A GUIA DE RESCISAO
IF !(StrZero(Val(cCodSaq),2) $ cCodSaqIOB)  						//Imprime NAO se Codigo nao for de Saque.
cCodSaq := "NAO"
EndIF

@ nLi,045 PSAY STR0035+ cCodSaq			   							//"|26 Cod. afastamento:"## Cod.Saque FGTS.		
@ nLi,075 PSAY STR0033+Transform(nPerPensa,"999.99")				//"|27 Pens.Alim.:"
@ nLi,100 PSAY STR0036+cCateg										//"|28 Categoria do trabalhador"
@ nLi,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY STR0037									//"|______________________________________________DISCRIMINACAO DAS VERBAS RESCISORIAS_____________________________________DESCONTOS_|"
nLi := nLi + 1													

nContar := 1
  
Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���fRodape   �IMPRESZ   �Autor  �Microsiga           � Data �  10/30/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �fRodape - Impressao do Rodape da Rescisao.                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fRodape()
Local X	:= 0 
Local cOrgao	:=	space(155)
Local cLinha1	:=	space(24)
Local cLinha2	:=	space(63)
Local cLinha3	:=	space(63)

nContar := nContar - 1
For X := 1 to 16 - nContar
    @ nLi,001 PSAY "|"+Space(42)+"|"+Space(42)+"|"+Space(42)+" |"
    nLi := nLi + 1
Next

@ nLI,001 PSAY "*"+REPLICATE("-",129)+"*"
nLI := nLi + 1
@ nLI,001 PSAY STR0038+If(lNull,Space(14),Transform(nProv,"@E 999,999,999.99"))			//"|30-TOTAL BRUTO              "
@ nLI,044 PSAY STR0039+If(lNull,Space(14),Transform(nDesc,"@E 999,999,999.99"))			//"|TOTAL DESCONTOS             "
@ nLI,087 PSAY STR0040+If(lNull,Space(14),Transform(nProv - nDesc,"@E 999,999,999.99"))	//"|LIQUIDO A RECEBER           "
@ nLI,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY STR0041  				 	//"|FORMALIZACAO DA RESCISAO"
nLi := nLi + 1
@ nLi,001 PSAY STR0042 						//"|56 Local e data do Recebimento"
@ nLi,065 PSAY STR0044 						//"|57 Carimbo e assinatura do empregador ou preposto"     
If cPaisLoc == "BRA"
	@ nLi,131 PSAY "|"
	nLi := nLi +1 
	@ nLi,001 PSAY "|"
	@ nLi,65 PSAY "|"
	If lGPEM40B
		@ nLi, 66 PSAY "R.G.: " + MV_PAR16 + Space(1) + MV_PAR17
	Else
		@ nLi, 66 PSAY "R.G.: " + MV_PAR22 + Space(1) + MV_PAR23
	EndIf
EndIf
@ nLi,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY STR0048						//"|_______________________________________________________________|_________________________________________________________________|"
nLi := nLi + 1
@ nLi,001 PSAY STR0043				  		//"|58 Assinatura do trabalhador"
@ nLi,065 PSAY STR0045						//"|59 Assinatura Responsavel legal"
@ nLi,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY STR0048						//"|_______________________________________________________________|_________________________________________________________________|
nLi := nLi + 1
@ nLi,001 PSAY STR0046						//"|60 HOMOLOGACAO"                 
@ nLi,065 PSAY STR0047  					//"|61 Digital do trabalhador    |62 Digital do responsavel legal"	
@ nLi,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY "|"+( substr( STR0050+ space(64),1,63) ) +STR0020			//"Foi prestada, gratuitamente, assistencia ao trabalhador, nos   "
nLi := nLi + 1
@ nLi,001 PSAY "|"+( substr( STR0051+ space(64),1,63) ) +STR0020         //"termos do art. 477,Inc.1. da CLT, sendo comprovado, neste ato  "
nLi := nLi + 1
@ nLi,001 PSAY "|"+( substr( STR0052+ space(64),1,63) ) +STR0020 		    //"o efetivo pagamento das verbas rescisorias acima especificadas."
nLi := nLi + 1
@ nLi,001 PSAY STR0032
nLi := nLi + 1 
@ nLi,001 PSAY STR0031	//"| __________________________________                            |                                |                                |"
nLi := nLi + 1
If(lGPEM40B .And. MV_PAR08 == 1) .OR. (! lGPEM40B .And. MV_PAR14 == 1) 
	@ nLi,001 PSAY "| "+Rtrim(aInfo[5]) + " - "+ Dtoc(SRG->RG_DATAHOM)	 // local +  data
	@ nLi,065 PSAY "|                                |                                |"	
Else
	@ nLi,001 PSAY STR0029	//"| Local e data                                                  |                                |                                |"
Endif 
nLi := nLi + 1
@ nLi,001 PSAY STR0032
nLi := nLi + 1
@ nLi,001 PSAY STR0032
nLi := nLi + 1
@ nLi,001 PSAY STR0031	//"| __________________________________                            |                                |                                |"
nLi := nLi + 1
@ nLi,001 PSAY STR0028	//"| Carimbo e assinatura do assistente                            |                                |                                |"
nLi := nLi + 1
@ nLi,001 PSAY STR0048						//"|_______________________________________________________________|_________________________________________________________________|
nLi := nLi + 1       

If (lGPEM40B .And. MV_PAR18 == 1) .Or. (! lGPEM40B .And. MV_PAR24 == 1)
	cOrgao	:=	fGetOrgao(SRA->RA_SINDICA,xFilial("RCE"))
ElseIf (lGPEM40B .And. MV_PAR18 == 2) .Or. (! lGPEM40B .And. MV_PAR24 == 2)
	cOrgao	:=	fGetOrgao(If(lGPEM040B, MV_GET19, MV_PAR25),xFilial("RCE"))
Else
	cOrgao	:=	""
EndIf
cLinha1		:=	Memoline(cOrgao,63,1,,.T.)
cOrgao			:=	right(cOrgao,len(cOrgao)-len(AllTrim(cLinha1)))
cLinha2		:=	Memoline(AllTrim(cOrgao),63,1,,.T.)
cLinha3		:=	Memoline(AllTrim(cOrgao),63,2,,.T.)

@ nLi,001 PSAY STR0054         				//"|63 Identificacao do orgao homologador: "
@ nLi,065 PSAY "|"+STR0053			        //"64 Recepcao pelo Banco (data e carimbo)"
@ nLI,131 PSAY "|"
nLi := nLi + 1 
@ nLi,001 PSAY "|"+cLinha1
@ nLi,065 PSAY "|"
@ nLI,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY "|"+cLinha2
@ nLi,065 PSAY "|"
@ nLI,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY "|"+cLinha3
@ nLi,065 PSAY "|"
@ nLI,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY STR0049						//"|_________________________________________________________________________________________________________________________________|"
nLi := nLi + 1
@ nLi,001 PSAY SPACE(40)+ STR0019				//" A ASSISTENCIA NO ATO DE RESCISAO CONTRATUAL E GRATUITA" #  (LINHA 63)//

Return Nil

/*/{Protheus.doc} PenunSal
Obtem o penultimo salario do funcionario antes da demissao.
@author Mauricio MR
@since 16/02/11
@param dAdmissao, date, Data de admiss�o do funcion�rio
@param dDemissao, date, Data de demiss�o do funcion�rio
@param cVerbas, characters, Verbas que ser�o incorporadas ao sal�rio
@param cVerbSal, characters, C�digo da verba de sal�rio
/*/
Static Function PenunSal(dAdmissao, dDemissao, cVerbas, cVerbSal)
	
	Local nEpoch		:= Set(_SET_EPOCH)	//OBTEM A CONFIGURACAO DE SECULO CORRENTE
	Local aArea			:= GetArea()
	Local aSRCArea		:= SRC->(GetArea())
	Local aPerAtual		:= {}
	//DATA DO PENULTIMO SALARIO
	Local dDTPenSal 
	Local dDataDe
	Local dDataAte
	Local nValPenSal
	Local cFilMat		:= SRA->(RA_FILIAL+RA_MAT)
	
	Default dAdmissao	:= SRA->RA_ADMISSA	
	Default dDemissao	:= SRG->RG_DATADEM  
	Default cVerbas		:= ''  
	Default cVerbSal	:= acodfol[318, 1]
	
	fGetPerAtual(@aPerAtual, xFilial("RCH", SRA->RA_FILIAL), SRA->RA_PROCES, fGetCalcRot('1'))
	If ! Empty(aPerAtual)
		dDataDe  := aPerAtual[1, 6]
		dDataAte := aPerAtual[1, 7]
	EndIf
	
	Set(_SET_EPOCH, 1920)	//ALTERA O SET EPOCH PARA 1920
	
	dDTPenSal := If(Month(dDemissao) - 1 != 0, CtoD( '01/' + StrZero(Month(dDemissao) - 1, 2) + '/' + Right(StrZero(Year(dDemissao), 4), 2)), CtoD('01/12/' + Right(StrZero(Year(dDemissao) - 1, 4), 2)) )
	
	If MesAno(dDtPenSal) < MesAno(dAdmissao)
		dDTPenSal 	:= CTOD("  /  /  ")
		nValPenSal 	:= 0.00
	Endif
	//PENULTIMO
	If ! Empty(dDTPenSal)
		nValPenSal := fBuscaAcm(cVerbas + cVerbSal, , dDTPenSal, dDTPenSal, "V")	//SALARIO DO MES + VERBAS QUE INCORPORARAM  AO SALARIO
		//PESQUISA NO MOVIMENTO MENSAL QUANDO O MES CORRENTE ESTIVER ABERTO
		//E NAO ENCONTRAR SALARIO NOS ACUMULADOS ANUAIS
		If nValPenSal == 0 .AND. MesAno(dDTPenSal) == MesAno(dDataDe)
			If SRC->(Dbseek(cFilMat))
				While ! SRC->(Eof()) .And. cFilMat == SRC->(RC_FILIAL + RC_MAT)
					If SRC->RC_PD $ cVerbas + cVerbSal
						nValPenSal += SRC->RC_VALOR
					Endif
					SRC->(dbskip())
				Enddo
			Endif
		Endif
	Endif
	
	//RESTAURA O SET EPOCH PADRAO
	Set(_SET_EPOCH, nEpoch)
	
	RestArea(aSRCArea)
	RestArea(aArea)
	
Return(nValPenSal)
