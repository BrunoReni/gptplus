#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99
#INCLUDE "ETIQAS.CH"

Function GPER981()        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CBTXT,CSTRING,AORD,CDESC1,CDESC2,CDESC3")
SetPrvt("LEND,ARETURN,NOMEPROG,AVETOR,NLASTKEY,CPERG")
SetPrvt("AINFO,AT_PRG,WCABEC0,WCABEC1,WCABEC2,CONTFL")
SetPrvt("LI,NTAMANHO,TITULO,WNREL,CMOSTRA,CDET")
SetPrvt("NTOT,CCAB,CNOME,CFIM,NTAM,NLC")
SetPrvt("NLN,NPULA,NORDEM,CFILDE,CFILATE,CCCDE")
SetPrvt("CCCATE,CMATDE,CMATATE,CNOMEDE,CNOMEATE,CCATEGORIA")
SetPrvt("DPERDE,DPERATE,CSINDICATO,NCOLUNAS,CSITUACAO,CINICIO")
SetPrvt("CHAVE,NCOL,NALIN,CFIL,CTIPPAGTO")
SetPrvt("CMOTIVO,CFUN,CTIPO")

// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 19/11/99 ==> 	#DEFINE PSAY SAY
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 19/11/99 ==> #INCLUDE "ETIQAS.CH"

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � ETIQAS   � Autor 쿝.H. - Marcos Stiefano � Data � 04.01.96 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Emiss꼘 de Etiqueta de Aumento Salarial                    낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � ETIQCT                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros�                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � RdMake                                                     낢�
굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             낢�        
굇쳐컴컴컴컴컴컫컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛rogramador � Data   � BOPS �  Motivo da Alteracao                     낢�
굇쳐컴컴컴컴컴컵컴컴컴컴탠컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿎ecilia Car.�04/09/14쿟QMSLV쿐fetuada a limpeza do fonte.              낢�
굇쿛aulo O.    �26/04/17쿏RHPAG쿌juste em GR320Imp() para tratar o tamanho낢�
굇쿔nzonha     �        �-255  쿭o n�mero da CTPS.                        낢�
굇읕컴컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

//+--------------------------------------------------------------+
//� Define Variaveis Locais (Basicas)                            �
//+--------------------------------------------------------------+
cbTxt   := ''
cString := "SRA"  			// alias do arquivo principal (Base)
aOrd    := {STR0001,STR0002,STR0003} 	//"Matricula"###"Centro de Custo"###"Nome"
cDesc1  := STR0004			//"Emiss�o de Etiqueta de Aumento Salarial."
cDesc2  := STR0005			//"Ser� impresso de acordo com os parametros solicitados pelo"
cDesc3  := STR0006			//"usuario."

//+--------------------------------------------------------------+
//� Define Variaveis Private(Basicas)                            �
//+--------------------------------------------------------------+
lEnd     := .F.
aReturn  := {STR0007,1,STR0008,2,2,1,"",1 }		//"Zebrado"###"Administra醴o"
NomeProg := "GPER320"
aVetor   := {}
nLastKey := 0
cPerg    := "GPR320"
aInfo    := {}
//+--------------------------------------------------------------+
//� Variaveis Utilizadas na funcao IMPR                          �
//+--------------------------------------------------------------+
AT_PRG   := "GPER320"
wCabec0  := 2
wCabec1  := ""
wCabec2  := ""
Contfl   := 1
Li       := 0
nTamanho := "M"

/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
� Variaveis de Acesso do Usuario                               �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸*/
cAcessaSRA	:= &( " { || " + ChkRH( "ETIQAS" , "SRA" , "2" ) + " } " )


//+--------------------------------------------------------------+
//� Verifica as perguntas selecionadas                           �
//+--------------------------------------------------------------+
pergunte("GPR320",.F.)

//+--------------------------------------------------------------+
//� Variaveis utilizadas para parametros                         �
//� MV_PAR01        //  Filial De                                �
//� MV_PAR02        //  Filial Ate                               �
//� MV_PAR03        //  Centro de Custo De                       �
//� MV_PAR04        //  Centro de Custo Ate                      �
//� MV_PAR05        //  Matricula De                             �
//� MV_PAR06        //  Matricula Ate                            �
//� MV_PAR07        //  Nome De                                  �
//� MV_PAR08        //  Nome Ate                                 �
//� MV_PAR09        //  Categorias                               �
//� MV_PAR10        //  Periodo De                               �
//� MV_PAR11        //  Periodo Ate                              �
//� MV_PAR12        //  Sindicato (99 Todos)                     �
//� MV_PAR13        //  Numero de Colunas                        �
//� MV_PAR14        //  Esp.Estabelecimento                      �
//� MV_PAR15        //  Tipo                                     �
//� MV_PAR16        //  Situa�Ses                                �
//+--------------------------------------------------------------+
Titulo := STR0009		//"EMISS횽 ETIQUETA DE AUMENTO SALARIAL"

//+--------------------------------------------------------------+
//� Envia controle para a funcao SETPRINT                        �
//+--------------------------------------------------------------+
wnrel:="GPER320"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({||GR320Imp()})// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> 	RptStatus({||Execute(GR320Imp)})
Return Nil
// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> 	function GR320Imp
Static function GR320Imp()

Local T
Local cSimb     := SuperGetmv("MV_SIMB1")
Local lNewProf	:= SuperGetMv("MV_NCPROF",,"2") == "1" // 1-Novo calculo da folha de professores; 2-Calculo antigo da folha de professores
Local cDescTar	:= ""
Local nCont		:= 2
Local dDataTar	:= Ctod("//")
Local bTarOk	:= { || .T. }
Local lFirst	:= .T.
Local cTpAlt	:= ""

//+--------------------------------------------------------------+
//� Define Variaveis Locais (Programa)                           �
//+--------------------------------------------------------------+
cMostra := "S"
cDet    := ""
nTot    := ""
cCab    := ""
cNome   := ""
cFim    := ""
nTam    := 0
nLC     := 189
nLN     := 105
nPula   := 1

//+--------------------------------------------------------------+
//� Carregando variaveis MV_PAR?? para Variaveis do Sistema.     �
//+--------------------------------------------------------------+
nOrdem     := aReturn[8]
cFilDe     := MV_PAR01
cFilAte    := MV_PAR02
cCcDe      := MV_PAR03
cCcAte     := MV_PAR04
cMatDe     := MV_PAR05
cMatAte    := MV_PAR06
cNomeDe    := MV_PAR07
cNomeAte   := MV_PAR08
cCategoria := MV_PAR09
dPerDe     := MV_PAR10
dPerAte    := MV_PAR11
cSindicato := MV_PAR12
nColunas   := If( MV_PAR13 > 4 , 4 , MV_PAR13 )
cSituacao  := MV_PAR16

dbSelectArea( "SRA" )
If nOrdem == 1
	dbSetOrder( 1 )
ElseIf nOrdem == 2
	dbSetOrder( 2 )
ElseIf nOrdem == 3
	dbSetOrder(3)
Endif

dbGoTop()

If nOrdem == 1
	dbSeek(cFilDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
	cFim    := cFilAte + cMatAte
ElseIf nOrdem == 2
	dbSeek(cFilDe + cCcDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
	cFim    := cFilAte + cCcAte + cMatAte
ElseIf nOrdem == 3
	DbSeek(cFilDe + cNomeDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
	cFim    := cFilAte + cNomeAte + cMatAte
Endif

dbSelectArea( "SRA" )
SetRegua(SRA->(RecCount()))

Chave := 0 
Li    := PROW()
nCol  := 1
nAlin := 0
For T:=1 TO nColunas
	aAdd(aVetor,{" "," "," "," "," "," "})
Next T

cFil  := Space(FWGETTAMFILIAL)
@Li,0 PSAY Chr(15)

dbSelectArea( "SRA" )
While !Eof() .And. Chave == 0

	//+--------------------------------------------------------------+
	//� Movimenta Regua Processamento                                �
	//+--------------------------------------------------------------+

	IncRegua()
   //+--------------------------------------------------------------+
   //� Verifica Quebra de Filial                                    �
   //+--------------------------------------------------------------+
	If SRA->RA_FILIAL != cFil
		If !fInfo(@aInfo,SRA->RA_FILIAL)
			Exit
		Endif
		cFil:=SRA->RA_FILIAL
	Endif

	While !Eof() .And. SRA->RA_FILIAL == cFil 

		//+--------------------------------------------------------------+
		//� Movimenta Regua Processamento                                �
		//+--------------------------------------------------------------+
		IncRegua()

		//+--------------------------------------------------------------+
		//� Verifica o De / Ate Solicitado                               �
		//+--------------------------------------------------------------+
		If nOrdem == 1
			If SRA->RA_FILIAL + SRA->RA_MAT > cFilAte + cMatAte
				Chave := 1
				Exit
			Endif
		Elseif nOrdem == 2
			If SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT > cFilAte + cCcAte + cMatAte
				Chave := 1
				Exit
			Endif
		Elseif nOrdem == 3
			If SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT > cFilAte + cNomeAte + cMatAte
				Chave := 1
				Exit
			Endif
		Endif

		//+--------------------------------------------------------------+
		//� Cancela Impres쫛 ao se pressionar <ALT> + <A>                �
		//+--------------------------------------------------------------+
		If lEnd
			Chave := 1
			Exit
		EndIF
	
		//+--------------------------------------------------------------+
		//� Consiste Parametriza獵o do Intervalo de Impress쫛            �
		//+--------------------------------------------------------------+
		If (Sra->Ra_Nome < cNomeDe) .Or. (Sra->Ra_Nome > cNomeAte) .Or. ;
		   (Sra->Ra_Mat < cMatDe) .Or. (Sra->Ra_Mat > cMatAte) .Or. ;
			(Sra->Ra_CC < cCcDe) .Or. (Sra->Ra_CC > cCCAte)
			dbSkip(1)
			Loop
		EndIf
		
			/*
		旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		쿎onsiste Filiais e Acessos                                             �
		읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
		IF !( SRA->RA_FILIAL $ fValidFil() .and. Eval( cAcessaSRA ) )
			dbSelectArea("SRA")
      		dbSkip()
       		Loop
		EndIF
			
		//+--------------------------------------------------------------+
		//� Verifica Situacao e Categoria do Funcionario                 �
		//+--------------------------------------------------------------+
		If !( SRA->RA_SITFOLH $ cSituacao ) .OR. !( SRA->RA_CATFUNC $ cCategoria )
			dbSkip()
			Loop
		Endif
	
		//+--------------------------------------------------------------+
		//� Verifica Sindicatos - 99 Todos                               �
		//+--------------------------------------------------------------+
		If cSindicato #"99" .And. SRA->RA_SINDICA # cSindicato
			dbSkip()
			Loop
		EndIf
		
        cTipPagto := If(SRA->RA_CATFUNC$"M*C*I"," POR MES",If(SRA->RA_CATFUNC="H"," POR HRS"," POR DIA"))
		
		If SRA->RA_CATFUNC $ "I*J" .And. lNewProf
			dbSelectArea( "SRO" )
			dbSetOrder(1)
			IF dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
				
				// Para prof. mensalista, imprime apenas tarefas fixas
				If SRA->RA_CATFUNC == "I"
					bTarOk := { || SRO->RO_TIPO == "1" }
				Else
					bTarOk := { || .T. }
				EndIf
				
				While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SRO->RO_FILIAL + SRO->RO_MAT
					If SRO->RO_DATA >= dPerDe .And. SRO->RO_DATA <= dPerAte
						dDataTar	:= SRO->RO_DATA
						cTpAlt		:= SRO->RO_TPALT
						nCont		:= 2
						lFirst		:= .T.
						While !Eof() .And. SRO->RO_DATA == dDataTar .And. SRO->RO_TPALT == cTpAlt .And. nCont < 4
							If Eval(bTarOk) .And. SRO->RO_QUANT # 0
								dDtReaj := SRO->RO_DATA

								If lFirst
									nAlin++
									lFirst := .F.
								EndIf

								dbSelectArea( "SX5" )
								If dbSeek( xFilial( "SX5" ) + "41" + SRO->RO_TPALT )
									cMotivo := fTAcento( SubStr(X5Descri(),1,15) )
								Else
									cMotivo := STR0010			//"Nao Cad.Tab. 41"
								Endif
	
								dbSelectArea( "SRX" )
								dbSetOrder(1)
								If dbSeek( xFilial("SRX") + "59" + SRO->RO_CODTAR + "1" )
									If SRA->RA_CATFUNC == "I"	
										cDescTar := Left( SRX->RX_TXT, 15 ) + Space(1) + "R$" + Transform(SRO->RO_VALTOT,"@E 9,999.99")
									Else
										cDescTar := Left( SRX->RX_TXT, 16 ) + Space(1) + "R$" + Transform(SRO->RO_VALOR,"@E 999.99")
									EndIf
								EndIf
	
								If SRA->RA_CATFUNC == "I"
									aVetor[nAlin,nCont]:= cDescTar + OemtoAnsi(STR0020)	//" POR MES + D.S.R. + H.A."
								Else
									aVetor[nAlin,nCont]:= cDescTar + OemtoAnsi(STR0021)	//" POR AULA + D.S.R. + H.A."
								EndIf
								
								nCont++
							EndIf

							dbSelectArea( "SRO" )
							dbSkip()
						EndDo
						
						If nAlin > 0 .And. !Empty( aVetor[nAlin,2] )
							aVetor[nAlin,1]:= STR0012+SRA->RA_FILIAL+"  "+STR0013+SRA->RA_MAT+"  "+ OemtoAnsi(STR0015) + DtoC(dDtReaj)	//"FIL.: "###"MATRIC: "###"AUMENTADO EM "
							aVetor[nAlin,4]:= STR0019+ cMotivo									//"POR MOTIVO DE "
							aVetor[nAlin,5]:= " "
							aVetor[nAlin,6]:= " "
							cTipo:="I"
							FChkET320()
						EndIf
					Else
						dbSelectArea( "SRO" )
						dbSkip()
					EndIf
				Enddo
			EndIf
		Else
			dbSelectArea( "SR3" )
			IF dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
				While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SR3->R3_FILIAL + SR3->R3_MAT 
					If SR3->R3_DATA >= dPerDe .And. SR3->R3_DATA <= dPerAte .And. SR3->R3_PD == "000"
						nAlin:=nAlin+1
						dbSelectArea( "SX5" )
						If dbSeek( xFilial( "SX5" ) + "41" + SR3->R3_TIPO )
							cMotivo := fTAcento( SubStr(X5Descri(),1,15) )
						Else
							cMotivo := STR0010			//"Nao Cad.Tab. 41"
						Endif
						dbSelectArea( "SR7" )
						If dbSeek(SR3->R3_FILIAL+SR3->R3_MAT+DTOS(SR3->R3_DATA))
							cFun:= DescFun( SR7->R7_FUNCAO, SR7->R7_FILIAL, 20 )
						Else
							cFun:= STR0011					//"*** Nao Cadastrado ***"
						Endif
				
						dbSelectArea( "SR3" )
						aVetor[nAlin,1]:= STR0012+SRA->RA_FILIAL+" "+STR0013+SRA->RA_MAT+" "+ Iif(cPaisLoc == "BRA",STR0014+AllTrim(SRA->RA_NUMCP)+"/"+SRA->RA_SERCP,"")			//"FIL.: "###"MATRIC: "###"CART.PROF: "
						aVetor[nAlin,2]:= STR0015+DtoC(SR3->R3_DATA)+STR0016+cSimb+" "+ALLTRIM(Transform(SR3->R3_VALOR,"@E 999,999,999.99"))+cTipPagto	    	//"AUMENTADO EM "###" P/  R$ "
						aVetor[nAlin,3]:= STR0017+alltrim(cFun)+Iif(cPaisLoc == "BRA",STR0018+fCodCBO(SRA->RA_FILIAL,SR7->R7_FUNCAO,dDataBase),"")				//"NA FUNCAO DE "###" C.B.O. "
						aVetor[nAlin,4]:= STR0019+ cMotivo									//"POR MOTIVO DE "
						aVetor[nAlin,5]:= " "
						aVetor[nAlin,6]:= " "
						cTipo:="I"
						FChkET320()
					Endif
					dbSkip()
				Enddo
			Endif
		EndIf
		dbSelectArea( "SRA" )
		dbSkip()
	Enddo

	IF Chave == 1
		Exit
	Endif

	If Eof()
		Exit
	Endif
Enddo
cTipo:="F"
FChkET320()
//+--------------------------------------------------------------+
//� Termino do Relatorio                                         �
//+--------------------------------------------------------------+
dbSelectArea( "SRA" )
Set Filter to
dbSetOrder(1)
Set Device To Screen

If aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel)
Endif

MS_FLUSH()

*-------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> FuncTion FChkET320
Static FuncTion FChkET320()
*-------------------------------------

Local C
Local I

If (cTipo == "I" .And. nAlin == nColunas) .Or. (cTipo == "F" .And. nAlin > 0)
	For C:= 1 To 6
		nCol:=0
		For I:= 1 To nColunas       
			 @ Li,nCol PSAY aVetor[I,C]
			 nCol := nCol + 56
			 aVetor[I,C]:= " "
		Next
		Li := Li + 1
		If Li >= 60
  			Li :=0
		Endif 
	Next

	nAlin:=0              

Endif

If cTipo == "F"
	@ Li, 0 PSAY " "
Endif	

Return(nil)        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99
