#INCLUDE "RWMAKE.CH"        
#INCLUDE "IMPLIFIN.CH"

// VARIAVEIS UTILIZADAS PARA ARMAZENAR AS INFORMACOES DAS PERGUNTES:
//VARIAVEL					   ORDEM
//nTipo			MV_PAR01  01	//	ZEBRADO/GRAFICO/PRE-IMPR/GRFC ZEBRADO/GRFC GRAFICA
//cFilialDe		MV_PAR02  02	//	FILIAL DE
//cFilialAte		MV_PAR03  03	//	FILIAL ATE
//cMatDe			MV_PAR04  04	//	MATRICULA DE
//cMatAte			MV_PAR05  05	//	MATRICULA ATE
//cCCDe			MV_PAR06  06	//	CENTRO DE CUSTO DE
//cCCAte			MV_PAR07  07	//	CENTRO DE CUSTO ATE
//cTipoRes			MV_PAR08  08	//	NORMAL OU COMPLEMENTAR
//cImprCGC			MV_PAR09  09	//	IMPRIME CGC  SIM OU NAO
//dDtDemDe			MV_PAR10  10	//	DATA DEMISSAO DE
//dDtDemAte		MV_PAR11  11	//	DATA DEMISSAO ATE
//dDtGerDe			MV_PAR12  12	//	DATA GERACAO DE
//dDtGerAte		MV_PAR13  13	//	DATA GERACAO ATE
//nImprDtHom		MV_PAR14  14	//	IMPRIME DATA DE HOMOLOGACAO
//nNumVias			MV_PAR15  15	//	N� DE VIAS
//cImprFerias		MV_PAR16  16	//	IMP. FERIAS    		 AVOS OU DIAS
//dDtHomDe			MV_PAR17  17	//	DATA DE HOMOLOGA�CAO DE
//dDtHomAte		MV_PAR18  18	//	DATA DE HOMOLOGA�CAO AT
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
//cTelefone		MV_PAR33  33	//	DDD/TELEFONE
//nSimples			MV_PAR34  34	//	OPTANTE DO SIMPLES
//dEntregaGRFC	MV_PAR35  35	//	DT. ENTREGA GRFC
//					MV_PAR36  36	//	TODAS RESCISOES COMPL?

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���RdMake    � ImpLiFin � Autor � Alexandre Silva       � Data � 11.03.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Impressao da Rescisao em Papel Zebrado                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � ImpLiFin                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Mohanad   �07/02/14�M12RH01    �Unificacao da Folha V12                ���
���          �        �     197401�                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function GPER997()     
Local Imprime
//DEFINICAO DO ARRAY DE TITULO aTitulos.
#Define CGC		1		
#Define FILIAL 	2
#Define CC     	3 
#Define NOME     	4
#Define MAT		5
#Define ENDERE	6
#Define BAIRRO	7
#Define MUNICIP	8
#Define ESTADO	9
#Define CEP		10
#Define CIC		11
#Define NASC    	12
#Define MAE		13
#Define SALMEN	14
#Define ADMISSA	15
#Define DTAVISO	16
#Define DTDEM		17

Private ADRIVER,CCOMPAC,CNORMAL,LNULL,NCONTAR,NLI
Private IMPRIME,DET,X,cCodSaqIOB

aDriver := LeDriver()
cCompac := aDriver[1]
cNormal := aDriver[2]
lNull   := .F.
nContar := 0
nLi     := 0

nEpoca:= Set(5,1910)

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

EJECT
Set(5,nEpoca)
Setprc(0,0)

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���fCabecalho� ImpLiFin �Autor  �Alexandre Silva     � Data �  11/03/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �fCabecalho - Impressao do Cabecalho da Rescisao.            ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fCabecalho()

Local cCateg 	:= fCateg(0)
Local cNrCGC 	:= Iif(cPaisLoc<>"PER", aInfo[8], fTabela("S015",01,05))
Local cBairro	:= ""
Local cMunicip	:= ""
Local cEstado	:= ""   
Local cFilial   := SRA->RA_FILIAL 
Local cNome     := SRA->RA_NOME
Local cMat      := SRA->RA_MAT    
Local cEnd      := SRA->RA_ENDEREC
Local cComplem  := SRA->RA_COMPLEM
Local cCep      := SRA->RA_CEP   
Local cCic      := SRA->RA_CIC 
Local cNomMae   := SRA->RA_MAE

If cPaisloc == "PER"
	cBairro	 := AllTrim( fDescRCC("S022",SRA->RA_CEP,1,6,7,20) )
	cMunicip := AllTrim( fDescRCC("S021",SUBSTR(SRA->RA_CEP,1,4),1,4,5,20) ) 	
	cEstado	 := AllTrim( fDescRCC("S020",SUBSTR(SRA->RA_CEP,1,2),1,2,3,20) )
ElseIf cPaisloc == "EQU"
	cBairro  := SRA->RA_BAIRRO
	cMunicip := fDesc( "CC2", SRA->RA_MUNICIP, "CC2_MUN",,,3)
	cEstado	 := Posicione( "SX5", 1, xFilial("SX5") + "12" + SRA->RA_ESTADO, fDescSx5(2))
Else
	cBairro  := SRA->RA_BAIRRO
	cMunicip := SRA->RA_MUNICIP 
	cEstado  := SRA->RA_ESTADO
EndIf      
	// Fixacao dos tamanhos para 
	cNrCGC  += Space(14-Len(cNrCGC))   //14 caracteres  
	cNrCGC:= SubStr(cNrCGC,1,14)
	cCateg  += Space(2-Len(cCateg))    // 2 caracteres 
    cCateg:= SubStr(cCateg,1,2)
	cBairro += Space(30-Len(cBairro))  //30 caracteres 
	cBairro:=SubStr(cBairro,1,30)
	cMunicip+= Space(30-Len(cMunicip)) //30 caracteres 
	cMunicip:= SubStr(cMunicip,1,30)
	cEstado += Space(30-Len(cEstado))  //30 caracteres 
	cEstado:=SubStr(cEstado,1,30) 
	cFilial += Space(12-Len(cFilial))  //12 caracteres
	cFilial:=SubStr(cFilial,1,12)
	cNome   += Space(60-Len(cNome))    //30 caracteres
	cNome:= SubStr(cNome,1,60)
	cMat    += Space(6-Len(cMat))      //6  caracteres  
	cMat:=SubStr(cMat,1,6)
	cEnd    += Space(30-Len(cEnd))     //30 caracteres
	cEnd:=SubStr(cEnd,1,30)
	cComplem+= Space(70-Len(cComplem)) //70 caracteres
	cComplem:=SubStr(cComplem,1,70)
	cCep    += Space(8-Len(cCep))      //8  caracteres 
	cCep:=SubStr(cCep,1,8)
	cCic    += Space(20-Len(cCic))     //20 caracteres
	cCic:=SubStr(cCic,1,20)
	cNomMae += Space(40-Len(cNomMae)) //40 caracteres   
	cNomMae:=SubStr(cNomMae,1,40)
                       
@ 00,001 PSAY &cCompac

@ 01,001 PSAY " "+SPACE(43)+STR0002				//"TERMO DE RESCISAO DO CONTRATO DE TRABALHO"

nLi     := 02
@ nLi,001 PSAY STR0018 												//_______________________
nLi := nLi + 1
@ nLi,001 PSAY STR0003 												//| Identificacao do Empregador  " 
nLi := nLi + 1
@ nLi,001 PSAY  "|  " +aTitulo[CGC] + cNrCGC + Space(15) + STR0001 + SubStr(aInfo[3],1,40) + "-" + aTitulo[FILIAL] + cFilial	//"|01- CNPJ/CEI: "##|02- Razao Social / Nome:" ##" Filial: "
@ nLi,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY "|"+Replicate("-",129)+ "|"
nLi := nLi + 1
@ nLi,001 PSAY "|  " + aTitulo[ENDERE]+ SubStr(aInfo[4],1,20) + SubStr(aInfo[14],1,25)		//"|03 Endereco   : "
@ nLi,080 PSAY "|  " + aTitulo[BAIRRO]+ SubStr(aInfo[13],1,20) 								//"|04 Bairro : "
@ nLi,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY "|" + Replicate("-",129)+"|"
nLi := nLi + 1
@ nLi,001 PSAY "|  " + aTitulo[MUNICIP]+SubStr(aInfo[5],1,20)					//"|05 Munic.: "
@ nLi,035 PSAY "|  " + aTitulo[ESTADO] +SubStr(aInfo[6],1,2)	    			//"|06 UF : "
@ nLi,007 PSAY "|  " + aTitulo[CEP]    +SubStr(aInfo[7],1,8)				  	//"|07 Cep: "
@ nLi,000 PSAY STR0006+Subs(aInfo[16],1,7)										//"|08 CNAE"
If cPaisLoc <> "EQU"
	@ nLi,003 PSAY aTitulo[CC]+Substr(fDesc("SI3",SRA->RA_CC,"I3_DESC"),1,15)	//"|09 CNPJ/CEI Tomador/Obra: " 
Else
	@ nLi,003 PSAY aTitulo[CC]+Substr(fDesc("SI3",SRA->RA_CC,"I3_CEI"),1,15)	//"|09 CNPJ/CEI Tomador/Obra: " 
Endif  
@ nLi,002 PSAY "|" 
nLi := nLi + 1
@ nLi,001 PSAY STR0018 												//_______________________
nLi := nLi + 1
@ nLi,001 PSAY STR0004 												//| Identificacao do Trabalhador//
nLi := nLi + 1

@ nLi,001 PSAY "|  "+ aTitulo[NOME]+cNome				   	//"|11 NOME:"
@ nLi,080 PSAY "|  "+ aTitulo[MAT] +cMat					//"|Matricula: "
@ nLi,131 PSAY "|"     
nLi := nLi + 1
@ nLi,001 PSAY "|"+Replicate("-",129)+"|"
nLi := nLi + 1
If cPaisLoc <> "EQU"
	@ nLi,001 PSAY "|  "+SubStr(aTitulo[ENDERE]+cEnd+cComplem,1,79) //"|12 Endereco   : "
Else
	@ nLi,001 PSAY "|  "+aTitulo[ENDERE] + cEnd + Space(37)          //"|12 Endereco   : "
Endif                        
@ nLi,001 PSAY " | "+aTitulo[BAIRRO]+cBairro			//"|13 Bairro : "
@ nLi,048 PSAY " |"     
nLi := nLi + 1
@ nLi,001 PSAY "|"+Replicate("-",129)+"|"
nLi := nLi + 1
@ nLi,001 PSAY "|  " + aTitulo[MUNICIP]+cMunicip				   			//"|05 Munic.: "
@ nLi,050 PSAY "|  " + aTitulo[ESTADO] +cEstado					   			//"|15 UF : "  
@ nLi,002 PSAY "  |  " + aTitulo[CEP]  +cCep					   		  	//"|16 Cep: "      
@ nLi,037 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY "|"+Replicate("-",129)+"|"
nLi := nLi + 1
@ nLi,001 PSAY "|  " + aTitulo[CIC]+cCic							//"|18 CPF:"
@ nLi,005 PSAY aTitulo[NASC]+DTOC(SRA->RA_NASC)				 	//"|19 Nasc.:"
@ nLi,035 PSAY aTitulo[MAE]+ " " + cNomMae + Space(8) + '|'	 			//"|20 Nome da Mae"
nLi := nLi + 1
@ nLi,001 PSAY STR0018 												//_______________________
nLi := nLi + 1            
@ nLi,001 PSAY STR0005											   	//"|Dados do Contrato "
nLi := nLi + 1				
@ nLi,001 PSAY  "|  " + aTitulo[SALMEN]+Transform(SRG->RG_SALMES,"@E 999,999,999.99")//"|21 Remuneracao p/ fins rescisorios
@ nLi,045 PSAY aTitulo[ADMISSA]+DtoC(SRA->RA_ADMISSA)							      //"|22 Admis:"
@ nLi,070 PSAY aTitulo[DTAVISO]+DtoC(SRG->RG_DTAVISO)							      //"|23 Data do Aviso Previo"
@ nLi,100 PSAY aTitulo[DTDEM]+DtoC(SRG->RG_DATADEM)							      //"|24 Data do afastamento: 
@ nLi,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY "|"+Replicate("-",129)+"|"
nLi := nLi + 1

@ nLi,001 PSAY STR0007+ cCodSaq			   							//"|26 Cod. afastamento:"## Cod.Saque FGTS.		
@ nLi,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY STR0018						  						 //_______________________
nLi := nLi + 1
@ nLi,001 PSAY STR0008 
nLi := nLi + 1														 //_______________________

nContar := 1
  
Return Nil


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���fRodape   �ImpLiFin  �Autor  �Microsiga           � Data �  10/30/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �fRodape - Impressao do Rodape da Rescisao.                  ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/

Static Function fRodape()
Local X

nContar := nContar - 1
For X := 1 to 17 - nContar
    @ nLi,001 PSAY "|"+Space(42)+"|"+Space(42)+"|"+Space(42)+" |"
    nLi := nLi + 1
Next

@ nLI,001 PSAY "*"+REPLICATE("-",129)+"*"
nLI := nLi + 1
@ nLI,001 PSAY STR0009+If(lNull,Space(14),Transform(nProv,"@E 999,999,999.99"))			//"|30-TOTAL BRUTO              "
@ nLI,044 PSAY STR0010+If(lNull,Space(14),Transform(nDesc,"@E 999,999,999.99"))			//"|TOTAL DESCONTOS             "
@ nLI,087 PSAY STR0011+If(lNull,Space(14),Transform(nProv - nDesc,"@E 999,999,999.99"))	//"|LIQUIDO A RECEBER           "
@ nLI,131 PSAY "|"
nLI := nLi + 1

@ nLi,001 PSAY STR0018 						//_______________________
nLi := nLi + 1
@ nLi,001 PSAY STR0012  				 	//"|FORMALIZACAO DA RESCISAO"
nLi := nLi + 1
@ nLi,001 PSAY STR0013 						//"|56 Local e data do Recebimento"
@ nLi,065 PSAY STR0015 						//"|57 Carimbo e assinatura do empregador ou preposto"     
@ nLi,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY "|" +Space(63)+"|"+ Space(65) + "|"
nLi := nLi + 1
@ nLi,001 PSAY STR0017						//"|_______________________________________________________________|_________________________________________________________________|"
nLi := nLi + 1
@ nLi,001 PSAY STR0014				  		//"|58 Assinatura do trabalhador"
@ nLi,065 PSAY STR0016						//"|59 Assinatura Responsavel legal"
@ nLi,131 PSAY "|"
nLi := nLi + 1
@ nLi,001 PSAY "|" +Space(63)+"|"+ Space(65) + "|"
nLi := nLi + 1
@ nLi,001 PSAY STR0018						//"|_______________________________________________________________|_________________________________________________________________|

Return Nil
