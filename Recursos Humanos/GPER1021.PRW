#Include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 02/05/00

Function GPER1021()        // incluido pelo assistente de conversao do AP5 IDE em 02/05/00

Local nX:=0
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("AIMP,ADRIVER,CFILSRR,CDATAANT,CDATAATU,CTPC")
SetPrvt("AINSSEMP,CTERCEIROS,CCODR,CAVPREVIO,CCODSAQIOB,NX")
SetPrvt("NLI,NPOS,NRECNOSRR,NFGTSMAT,NFGTSMAN,NFGTS13")
SetPrvt("NVALMULTA,NVALREM,NSALCON,NINSS,NSALFAM,NVALAV")
SetPrvt("N13AV,NDEVPRE,NREMMAT,NREMMAN,NREMA13,NTOT39")
SetPrvt("NTOT40,NTOT41,CFIL,NPERCFPAS,NPERCACI,COCORR")
SetPrvt("NFGTSAV,NFG13AV,CCATEG,")

// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 02/05/00 ==> 	#DEFINE PSAY SAY

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿛rograma  � ImpGRec  � Autor � Fernando Joly Siquini � Data � 13.03.98 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Emissao da Guia de Recolhimento Rescis줿io do FGTS         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � Chamada padr꼘 para programas em RDMake.                   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Generico                                                   낢�
굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             낢�
굇쳐컴컴컴컴컴컫컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛rogramador � Data   � BOPS �  Motivo da Alteracao                     낢�
굇쳐컴컴컴컴컴컵컴컴컴컴탠컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿎ecilia Car.�06/08/14쿟QENRX쿔ncluido o fonte da 11 para a 12 e efetua-낢�
굇�            �        �      쿭a a limpeza.                             낢�
굇읕컴컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�/*/
//-- Inicializa Variaveis

* Array
aImp       := {}
aDriver    := LeDriver()

* Data
* Caracter
If aReturn[4] == 1  // Comprimido
	@ nLi , 0 PSAY &(aDriver[1])
Else                // Normal
	@ nLi , 0 PSAY &(aDriver[2])
Endif
cFilSRR    := If(xFilial('SRR') == Space(FWGETTAMFILIAL),xFilial('SRR'),SRA->RA_FILIAL)
cDataAnt   := '.. ..'
cDataAtu   := '.. ..'
cTpc       := If (SRA->RA_TPCONTR$ " *1","1",SRA->RA_TPCONTR)
aInssEmp   := array(23,2)
cTerceiros := Space(4)
cCodR      := If (SRA->RA_AFASFGT #"I","L","I")
cAvPrevio  := "3"
cCei       := Space(14)
cOpcSimp   := If (mv_par21==1,"2","1")

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿎odigos de Saque Validos Segundo o Calendario de    Obrigacoes�
//쿮 Tabelas Praticas do IOB de Out/99 Paginas 62 a 68.          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cCodSaqIOB := "01_02_03_04_05_06_07_10_23_26_27_80_81_86_87_88_91_92_93_94_95" 

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿞e o Codigo nao For Valido nao Imprime a Guia de Rescisao.    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
IF !(StrZero(Val(cCodSaq),2) $ cCodSaqIOB)  //Nao Imprime Guia se Codigo nao for de Saque
	Return
EndIF

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿞e os Encargos Empresa nao Forem Carregados nao Immprime     a�
//쿲uia de Rescisao.                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
IF !(fInssEmp(SRA->RA_FILIAL,aInssEmp,.T.))
   Return
EndIF

* L줳ico
* N즡굍ico
Set Century On

nX         := 0
nLi        := 0
nPos       := 0
nRecnoSRR  := SRR->(Recno())
nFgtsMAt   := 0
nFgtsMAn   := 0
nFgts13    := 0
nValMulta  := 0
nValRem    := 0
nSalCon    := 0
nInss      := 0
nSalFam    := 0
nValAv     := 0
n13Av	   := 0	
nDevPre    := 0
nRemMAt    := 0
nRemMAn    := 0
nRemA13    := 0
nTot39     := 0
nTot40     := 0
nTot41     := 0

dbSelectArea("CTT")
cFil := SRA->RA_FILIAL
If ( cFil #Nil .And. xFilial('CTT') == Space(FWGETTAMFILIAL) ) .Or. cFil == Nil
	cFil := xFilial("CTT")
Endif
nPercFPAS := 0
If dbSeek( cFil + SRA->RA_CC )
	If CTT->CTT_PERFPA > 0
		aInssEmp[21,Val(cTpc)] := CTT->CTT_PERCAC / 100
		nPercFPAS    := CTT->CTT_PERFPA / 100
	Endif
Endif	
If aInssEmp[21,Val(cTpc)] == 0
	aInssEmp[21,Val(cTpc)] := aInssEmp[3,Val(cTpc)]
Endif

// Verifica se existe no. do Cei para impressao
If dbSeek(If(XFILIAL("CTT")==Space(FWGETTAMFILIAL),XFILIAL("CTT"),cFil)+ CTT->CTT_CUSTO)
		If TYPE("CTT->CTT_CEI") # "U".And. !Empty(CTT->CTT_CEI)
			cCei := Left(CTT->CTT_CEI,14)
		EndIf	
		
		If TYPE("CTT->CTT_DESC01") # "U" 
	      cDesCei := PadR(CTT->CTT_DESC01,25)
		EndIf
EndIf


//--Buscar os Valores da Rescisao
dbSelectArea("SRR")
If dbSeek(cFilSRR + SRA->RA_MAT + 'R' + DtoS(SRG->RG_DTGERAR) )

	//-- Data do Mes da Rescis꼘 e Mes Anterior a Resci뇙o
	cDataAnt := If ( Month(SRR->RR_DATA)-1<=0 , '12'+'/'+StrZero(Year(SRR->RR_DATA)-1,4),StrZero(Month(SRR->RR_DATA)-1,2)+'/'+StrZero(Year(SRR->RR_DATA),4))
	cDataAtu := StrZero(Month(SRR->RR_DATA), 2) + '/' + StrZero(Year(SRR->RR_DATA), 4)

	While ! Eof() .And. SRR->RR_FILIAL+SRR->RR_MAT+SRR->RR_TIPO3 == ;
		cFilSrr+SRA->RA_MAT+"R" .And. SRR->RR_DATA == SRG->RG_DTGERAR 
		
		//--Fgts Mes Anterior		
		If SRR->RR_PD == aCodFol[117,1]
			nFgtsMAn := SRR->RR_VALOR
			nRemMAn  := Round(SRR->RR_VALOR / aInssEmp[4,Val(cTpc)],2)
		//--Fgts Pago Rescisao
		Elseif SRR->RR_PD	 == aCodFol[119,1]
			nFgtsMAt  := SRR->RR_VALOR
		//--Base Fgts Pago Rescisao
		Elseif SRR->RR_PD	 == aCodFol[293,1]
			nRemMAt  := SRR->RR_VALOR
		//--Base Fgts 13o. Pago Rescisao
		Elseif SRR->RR_PD	 == aCodFol[294,1]
			nRemA13 := SRR->RR_VALOR
		//--Multa 40 % Art. 22
		Elseif SRR->RR_PD	 == aCodFol[120,1]
			nValMulta := SRR->RR_VALOR			
		//--Fgts 13o Rescisao
		Elseif SRR->RR_PD == aCodFol[214,1]
			nFgts13   := SRR->RR_VALOR
		//--Base de Inss Normal e 13o. 	
		Elseif SRR->RR_PD == aCodFol[013,1] .Or.	SRR->RR_PD == aCodFol[014,1] .Or.;
      		 SRR->RR_PD == aCodFol[019,1] .Or.	SRR->RR_PD == aCodFol[020,1] 
			nSalCon := nSalCon + SRR->RR_VALOR				 
		//--Desconto Inss e Inss 13o.			
		Elseif SRR->RR_PD == aCodFol[064,1] .Or. SRR->RR_PD == aCodFol[070,1] .Or.;
				SRR->RR_PD == aCodFol[065,1]			
			nInss := nInss + SRR->RR_VALOR				 
		//--Salario Familia	
		Elseif SRR->RR_PD == aCodFol[034,1]			
			nSalFam := SRR->RR_VALOR
		//--Aviso Previo Indenizado	
		Elseif SRR->RR_PD == aCodFol[111,1]
			nValAv := SRR->RR_VALOR
			cAvPrevio := "2"
		//--Aviso Previo Trabalhado				
		ElseIf SRR->RR_PD == aCodFol[112,1]
			cAvPrevio := "1"
		//--1/12 13o. Indenizado
		Elseif SRR->RR_PD == aCodFol[115,1]
			n13Av := SRR->RR_VALOR
		Endif
		
		dbSelectArea("SRR")
		dbSkip()
	Enddo

	//--Verifica se est� pagando FGTS Mes Anterio deve considerar Inss Mes Anterior
	//--Porque esse funcionario n�o saiu na SEFIP do Mes Anterior.
	If nFgtsmAn > 0
		//--Procura as verbas do Mes no Acumulado
		dbSelectArea("SRD")
		If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+MesAno(SRG->RG_DATADEM) )
		    While ! Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT+MesAno(SRG->RG_DATADEM) ==;
		    					SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ
				//--Verbas de Sal.de Contribuicao		    					
				If SRD->RD_PD$ aCodFol[13,1]+"*"+aCodFol[14,1]+"*"+aCodfol[19,1]+"*"+aCodFol[20,1] 		    					
					nSalCon := nSalCon + SRD->RD_VALOR
				//--Verbas de Inss						
				Elseif SRD->RD_PD$ aCodFol[64,1]+"*"+aCodFol[70,1]
					nInss := nInss + SRD->RD_VALOR
				//--Verbas de Salario Familia						
				Elseif SRD->RD_PD$ aCodFol[34,1]
					nSalFam := nSalFam + SRD->RD_VALOR
				Endif
				dbSelectArea("SRD")
				dbSkip()
			Enddo		
		Else
			//-- PROCURA NO MOVIMENTO MENSAL QUANDO NAO ENCONTRA NO ACUMULADO
			dbSelectArea("SRC")
			If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
			    While ! Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT == SRC->RC_FILIAL+SRC->RC_MAT
					//--Verbas de Sal.de Contribuicao		    					
					If SRC->RC_PD$ aCodFol[13,1]+"*"+aCodFol[14,1]+"*"+aCodfol[19,1]+"*"+aCodFol[20,1] 		    					
						nSalCon := nSalCon + SRC->RC_VALOR
					//--Verbas de Inss						
					Elseif SRC->RC_PD$ aCodFol[64,1]+"*"+aCodFol[70,1]
						nInss := nInss + SRC->RC_VALOR
					//--Verbas de Salario Familia						
					Elseif SRC->RC_PD$ aCodFol[34,1]
						nSalFam := nSalFam + SRC->RC_VALOR
					Endif
					dbSelectArea("SRC")
					dbSkip()
				Enddo		
			Endif
		Endif							
	Endif	
Endif		

nDevPre := 0
nDevPre := nDevPre + Round(nSalCon * aInssemp[1,Val(cTpc)],2)   // Inss Emp.
nDevPre := nDevPre + Round(nSalCon * If (nPercFPAS > 0, nPercFPAS ,aInssemp[2,Val(cTpc)]),2)   // Terceiros
If Type("SRA->RA_PERCSAT") # "U" .And. SRA->RA_PERCSAT > 0
	nPercAci := SRA->RA_PERCSAT / 100
Else
	//-- Verifica o % de Acidente do C.Custo
	nPercAci := If (aInssEmp[21,Val(cTpc)] > 0,aInssEmp[21,Val(cTpc)],aInssEmp[3,Val(cTpc)])  // Ac.Trab.
Endif	
nDevPre := nDevPre + Round(nSalCon * nPercAci,2)  // Ac.Trab.
nDevPre := nDevPre + nInss
nDevPre := nDevPre - nSalFam

//--Verifica Ocorrencia do Funcionario
//-- Ocorrencia
If TYPE("SRA->RA_OCORREN") # "U"
	cOcorr := SRA->RA_OCORREN
Else
	cOcorr := Space(02)
EndIf

//-- Abater da Remuneracao o Aviso Previo Indenizado
nFgtsAv := 0.00
If nValAv > 0 .And. PosSrv(aCodfol[111,1],SRA->RA_FILIAL,"RV_FGTS") == "S"

	If nRemMat > 0
		nRemMAT  := nRemMAT - nValAv
		nRemMat  := If (nRemMAt  < 0,0,nRemMAt)

		//--Achar Fgts Sobre Aviso Previo
		nFgtsAv  := Round( nValAv * aInssEmp[4,Val(cTpc)] ,2) 

		//--Abater Fgts s/Aviso do Fgts da Quitacao
		nFgtsMAt := nFgtsMAt - nFgtsAv
		nFgtsMAt := If (nFgtsMAt < 0,0,nFgtsMAt)
	Else
		nFgtsAv := 0
		nFgtsMat:= 0
		nValAv	:= 0
	Endif			
Endif	

nFg13Av := 0.00               
//-- Abater da Remuneracao do 13o., o 13o. Indenizado			
If n13Av > 0 .And. PosSrv(aCodfol[115,1],SRA->RA_FILIAL,"RV_FGTS") == "S"

	If nRemA13 > 0
		nRemA13 := If (nRemA13 - n13Av > 0 , nRemA13 - n13Av , 0)

		//--Achar Fgts 13 Indenizado
		nFg13Av  := Round(n13Av * aInssEmp[4,Val(cTpc)],2)
		
		//--Abater Fgts 13o Indenizado do Fgts 13o.	
		nFgts13   := nFgts13 - nFg13Av	            
		nFgts13   := If (nFgts13 > 0 , nFgts13 , 0.00)
	Else
		nFgts13 := 0.00
		nFg13Av := 0.00
		nRemA13 := 0.00
		n13Av	:= 0.00
	Endif		
Endif	


//-- Categoria do Funcionario
cCateg := "01"
// Contrato de trabalho
If SRA->RA_TPCONTR == "2"  //--Contrato Tempo Determinnado
	cCateg:= "04"
EndIf

//--Verifica se houve dissidio p/ rescisao complementar
dbSelectArea( "SR3" )
cDissid :=""
If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
	While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SR3->R3_FILIAL + SR3->R3_MAT
		If Mv_Par08 ==2
			If MesAno(SRG->RG_DATADEM) == MesAno(SR3->R3_DATA)
				cDissid := "0"
			Else
				cDissid := "1"
			EndIf
		Else
			cDissid := "1"
		EndIf
		dbSelectArea( "SR3" )
		dbSkip()
	EndDo
EndIf

aAdd(aImp, '       C A I X A                    PREVIDENCIA SOCIAL                          GRFP- Guia de Recolhimento Rescisorio do FGTS e     ')
aAdd(aImp, 'CAIXA ECONOMICA FEDERAL      INSTITUTO NACIONAL DO SEGURO SOCIAL                Informacoes a Previdencia Social                    ')  
aAdd(aImp, '                                                                                                                                    ')
aAdd(aImp, '                                                                                                    |Cod. Op.|00-Para Uso da Caixa |')
aAdd(aImp, '                                                                                                    |  758   |                     |')
aAdd(aImp, '                                                                                                    +--------+---------------------+')
aAdd(aImp, 'DADOS DO EMPREGADOR                                                                                                                 ')
aAdd(aImp, '|02-Razao Social/nome                              |03-Pessoa para contato/DDD/telefone   |04-CGC/CNPJ/CEI    | |01-Carimbo CIEF    ')
aAdd(aImp, '|                                                  |                                      |                   | |                   ')
aAdd(aImp, '+--------------------------------------------------+--------------------------------------+-------------------+ |                   ')
aAdd(aImp, '|05-Endereco(logradouro,nro,andar,apartamento)     |06-Bairro/distrito                                        | |                   ')
aAdd(aImp, '|                                                  |                                                          | |                   ')
aAdd(aImp, '+--------------------------------------------------+----------------------------------------------------------+ |                   ')
aAdd(aImp, '|07-Cep       |08-Municipio                                                                            |09-UF | |                   ')
aAdd(aImp, '|             |                                                                                        |      | |                   ')
aAdd(aImp, '+-------------+----------------------------------------------------------------------------------------+------+ |                   ')
aAdd(aImp, '|10-Tomador de servico (CGC/CNPJ/CEI)  |11-Tomador de servico (razao Social)                                  | +-------------------')
aAdd(aImp, '|                                      |                                                                      |                     ')
aAdd(aImp, '+--------------------------------------+----------------------------------------------------------------------+                     ')
aAdd(aImp, 'DADOS DA PREVIDENCIA SOCIAL                                                                                                         ')
aAdd(aImp, '|12-FPAS  |13-Cod.Terceiros |14-Simples  |15-Aliquota SAT |16-CNAE  |                                                               ')
aAdd(aImp, '|         |                 |            |                |         |                                                               ')
aAdd(aImp, '+---------+-----------------+------------+----------------+---------+                                                               ')
aAdd(aImp, '|17-Valor Devido Previdencia Social |18-Contribuicao descontada empregado |19-Valor Salario-Familia |20-Somatorio (17+18+19)       |')
aAdd(aImp, '|                                   |                                     |                         |                              |')
aAdd(aImp, '+-----------------------------------+-------------------------------------+-------------------------+------------------------------+')
aAdd(aImp, 'DADOS DO TRABALHADOR                                                                                                                ')
aAdd(aImp, '|21-Nome do trabalhador          |22-Data nascimento |23-Data opcao |                                                               ')
aAdd(aImp, '|                                |                   |              |                                                               ')
aAdd(aImp, '+--------------------------------+-------------------+--------------+                                                               ')
aAdd(aImp, '|24-PIS/PASEP |25-CTPS/Serie |26-Dt.admissao |27-Cat.|28-Ocor.|29-Dt.movto./Cod.|30-Av.previo| 1-Trabalhado         |31-Dissidio   |')
aAdd(aImp, '|             |              |               |       |        |                 |            | 2-Indenizado         |              |')
aAdd(aImp, '+-------------+--------------+---------------+-------+--------+-----------------+------------+ 3-Ausencia/dispensa  +--------------+')
aAdd(aImp, '                                                                                                                                    ')
aAdd(aImp, 'DADOS DO RECOLHIMENTO                                                                                                               ')
aAdd(aImp, '|32-Competencia       | Mes/Ano |33-Cod.|34-Remumeracao (sem 13o)     |35-Remuneracao (somente 13o) |36-Recolhimento (FGTS)        |')
aAdd(aImp, '|                     |         |       |                             |                             |                              |')
aAdd(aImp, '|Mes anterior rescisao|         |  406  |                             |                             |                              |')
aAdd(aImp, '+---------------------+---------+-------+-----------------------------+-----------------------------+------------------------------+')
aAdd(aImp, '|Mes de Rescisao      |         |  407  |                             |                             |                              |')
aAdd(aImp, '+---------------------+---------+-------+-----------------------------+-----------------------------+------------------------------+')
aAdd(aImp, '|Verbas indenizatorias|         |  408  |                             |                             |                              |')
aAdd(aImp, '+---------------------+---------+-------+-----------------------------+-----------------------------+------------------------------+')  
aAdd(aImp, '                                |  400  |37-Valor multa rescisoria    |            N A O            |38-Rec. da multa rescisoria   |')
aAdd(aImp, '                                |       |                             |      P R E E N C H E R      |                              |')
aAdd(aImp, '                                +-------+-----------------------------+-----------------------------+------------------------------+')
aAdd(aImp, '                                        |39-Somatorio (34+37)         |40-Somatorio (35)            |41-Total a recolher (36+38)   |')
aAdd(aImp, '                                        |                             |                             |                              |')
aAdd(aImp, '                                        +-----------------------------+-----------------------------+------------------------------+')
aAdd(aImp, '                                                                                                                                    ')
aAdd(aImp, '                                                                                           |Autenticacao mecanica                   ')
aAdd(aImp, '-----------------------------------                                                        |                                        ')
aAdd(aImp, '                                                                                           |                                        ')
aAdd(aImp, '                                                                                           |                                        ')
aAdd(aImp, '                                                                                                                                    ')
aAdd(aImp, '                                                                                                                                    ')
aAdd(aImp, '-----------------------------------                                                                                                 ')
aAdd(aImp, 'Assinatura                                                                                                                          ')

aImp[09] := Stuff( aImp[9], 002, Len(aInfo[03]), aInfo[03] )                          // Nome Completo
aImp[09] := Stuff( aImp[9], 054, Len(mv_par19+'/'+mv_par20), mv_par19+'/'+mv_par20 )  // Pessoa Para contato/telefone  
aImp[09] := Stuff( aImp[9], 093, 18, Transform(aInfo[08],'@R 99.999.999/9999-99') )   // CGC
aImp[12] := Stuff( aImp[12],002, Len(aInfo[04]), aInfo[04] )                          // Endereco
aImp[12] := Stuff( aImp[12],054, Len(aInfo[13]), aInfo[13] )                          // Bairro
aImp[15] := Stuff( aImp[15],002, Len(aInfo[07]), aInfo[07] )                          // CEP
aImp[15] := Stuff( aImp[15],017, Len(aInfo[05]), aInfo[05] )                          // Municipio
aImp[15] := Stuff( aImp[15],107, Len(aInfo[06]), aInfo[06] )                          // UF
// Imprime Cei/Descricao se existir
If !Empty(cCei)
	aImp[18] := Stuff( aImp[18], 003,18, Transform(cCei,'@R 99.999.999/9999-99'))      // CEI
	aImp[18] := Stuff( aImp[18], 042,25, cDesCei)                                      // Descricao Cei
EndIf

aImp[22] := Stuff( aImp[22],004, Len(aInfo[17]), aInfo[17] )                          // FPAS
aImp[22] := Stuff( aImp[22],019, Len(cTerceiros), cTerceiros )                        // Terceiros
aImp[22] := Stuff( aImp[22],036, 1, cOpcSimp )  						                      // Simples
aImp[22] := Stuff( aImp[22],043, Len(Str(nPercAci*100)), Str(nPercAci*100) )         // Aliquota de SAT
aImp[22] := Stuff( aImp[22],062, Len(aInfo[16]), aInfo[16] )                          // CNAE
aImp[25] := Stuff( aImp[25],018,10,TRANSFORM(nDevPre,'@R 999,999.99') )               // Valor Devido a Previdencia
aImp[25] := Stuff( aImp[25],052,10,TRANSFORM(nInss,'@R 999,999.99') )                 // Contribuicao Descontada do Empregado
aImp[25] := Stuff( aImp[25],084,10,TRANSFORM(nSalFam,'@R 999,999.99') )               // Valor do Salario Familia
aImp[25] := Stuff( aImp[25],110,12,TRANSFORM(nDevPre+nInss+nSalFam,'@R 9,999,999.99') ) // Somatorio
aImp[29] := Stuff( aImp[29],002, Len(SRA->RA_NOME), SRA->RA_NOME )                      // Nome do Funcionario
aImp[29] := Stuff( aImp[29],040, Len(DTOC(SRA->RA_NASC)), DTOC(SRA->RA_NASC) )         // Data de Nascimento
aImp[29] := Stuff( aImp[29],058, Len(DTOC(SRA->RA_OPCAO)), DTOC(SRA->RA_OPCAO) )       // Data da Opcao
aImp[32] := Stuff( aImp[32],003, Len(SRA->RA_PIS), SRA->RA_PIS )                        // Numero do PIS
aImp[32] := Stuff( aImp[32],016, Len(SRA->RA_NUMCP+'/'+SRA->RA_SERCP), SRA->RA_NUMCP+'/'+SRA->RA_SERCP ) // Numero da Carteira de Trabalho
aImp[32] := Stuff( aImp[32],034, Len(DTOC(SRA->RA_ADMISSA)), DTOC(SRA->RA_ADMISSA) )   // Data de Admissao
aImp[32] := Stuff( aImp[32],049, Len(cCateg), cCateg )                      			    // Categoria
aImp[32] := Stuff( aImp[32],057, Len(cOcorr), cOcorr )                      			    // Ocorrencia
aImp[32] := Stuff( aImp[32],066, Len(DTOC(SRG->RG_DATADEM)+'-'+cCodR), DTOC(SRG->RG_DATADEM)+'-'+cCodR ) // Data e Codigo da Movimentacao
aImp[32] := Stuff( aImp[32],087, Len(cAvPrevio), cAvPrevio ) 						   // Aviso Previo
aImp[32] := Stuff( aImp[32],125, 1, cDissid )                    							   // Dissidio
aImp[38] := Stuff( aImp[38],025, Len(cDataAnt), cDataAnt )
aImp[38] := Stuff( aImp[38],057, 12, TRANSFORM(nRemMAn,'@R 9,999,999.99') )
aImp[38] := Stuff( aImp[38],118, 12, TRANSFORM(nFgtsMAn,'@R 9,999,999.99') )
aImp[40] := Stuff( aImp[40],025, Len(cDataAtu), cDataAtu )
aImp[40] := Stuff( aImp[40],057, 12, TRANSFORM(nRemMAt,'@R 9,999,999.99') )
aImp[40] := Stuff( aImp[40],087, 12, TRANSFORM(nRemA13,'@R 9,999,999.99') )
aImp[40] := Stuff( aImp[40],118, 12, TRANSFORM(nFgts13+nFgtsMat,'@R 9,999,999.99') )
aImp[42] := Stuff( aImp[42],025, Len(cDataAtu), cDataAtu )
aImp[42] := Stuff( aImp[42],057, 12, TRANSFORM(nValAv,'@R 9,999,999.99') )
aImp[42] := Stuff( aImp[42],087, 12, TRANSFORM(n13Av   ,'@R 9,999,999.99') )
aImp[42] := Stuff( aImp[42],118, 12, TRANSFORM(nFgtsAv+nfg13Av,'@R 9,999,999.99')  )
aImp[45] := Stuff( aImp[45],057, 12, TRANSFORM(nValMulta,'@R 9,999,999.99') )
aImp[45] := Stuff( aImp[45],118, 12, TRANSFORM(nValMulta,'@R 9,999,999.99') )
aImp[48] := Stuff( aImp[48],057, 12, TRANSFORM(nRemMan+nRemMAt+nValav+nValMulta,'@R 9,999,999.99') )
aImp[48] := Stuff( aImp[48],087, 12, TRANSFORM(nRemA13+n13Av,'@R 9,999,999.99') )
aImp[48] := Stuff( aImp[48],118, 12, TRANSFORM(nFgtsMAn+nFgtsMAt+nValMulta+nFgts13+nFgtsAv+nFg13Av,'@R 9,999,999.99') )
If mv_par22 # NIL .And. ! empty(mv_par22)
	aImp[53] := Stuff( aImp[53],001,Len(Rtrim(aInfo[5])+Space(3)+ DTOC(mv_par22)), Rtrim(aInfo[5])+Space(3)+ DTOC(mv_par22) )
Else	
	aImp[53] := Stuff( aImp[53],001,Len(Rtrim(aInfo[5])+Space(3)+ DTOC(SRG->RG_DATAHOM)), Rtrim(aInfo[5])+Space(3)+ DTOC(SRG->RG_DATAHOM) )
Endif
nLi := 0
For nX := 1 to Len(aImp)
	@ nLi, 00 PSAY aImp[nX]
	nLi := nLi + 1
Next nX
	 
SRR->(dbGoto(nRecnoSRR))	 
If nTData == 8
	Set Century OFF
Else
	Set Century On
Endif

Return Nil
