#INCLUDE "RSPR004.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RSPR004  � Autor � Fernando Joly         � Data � 05.03.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rela��o de Vagas                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Clipper 5.3                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Avoid                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGARSP                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Altera��o                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�06/08/14�TQENRX�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function RSPR004

//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais (Basicas)                            �
//����������������������������������������������������������������
Local cDesc1     := STR0001 //'Rela��o de Vagas'
Local cDesc2     := STR0002 //'Sera impresso de acordo com os parametros solicitados pelo'
Local cDesc3     := STR0003 //'usuario.'
Local cString    := 'SQS'
Local aOrd       := {STR0004,STR0005,STR0006} //'Vaga'###'Area'###'Cliente'
Local cNomePrg   := 'RSPR004'

//��������������������������������������������������������������Ŀ
//� Define Variaveis PRIVATE(Basicas)                            �
//����������������������������������������������������������������
Private aReturn  := {STR0007, 1, STR0008, 1, 2, 1, '',1 } //'Zebrado'###'Administracao'
Private cPerg    := 'RSR004'
Private aDriver  := LeDriver()
Private lEnd     := .F.

//��������������������������������������������������������������Ŀ
//� Variaveis Utilizadas na funcao IMPR                          �
//����������������������������������������������������������������
Private Titulo	:= OemToAnsi(STR0009) //'Relacao de Vagas'
Private cCabec	:= ''
Private AT_PRG	:= cNomePrg
Private wCabec0	:= 1
Private wCabec1	:= STR0010 //'Vaga                                                          Solicitante                      Vagas Prazo Dt.Abert.  Dt.Fecham. Fech. Valor           Area                       Cliente  Processo'
Private ContFl	:= 1
Private Li			:= 0
Private nTamanho	:= 'G'
Private Colunas	:= 220

Pergunte(cPerg, .F.)
	
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01        //  Vaga De                                  �
//� mv_par02        //  Vaga At                                  �
//� mv_par03        //  Centro de Custo De                       �
//� mv_par04        //  Centro de Custo Ate                      �
//� mv_par05        //  Cargo De                                 �
//� mv_par06        //  Cargo Ate                                �
//� mv_par07        //  Cliente De                               �
//� mv_par08        //  Cliente Ate                              �
//� mv_par09        //  Prazo De                                 �
//� mv_par00        //  Prazo At                                 �
//� mv_par11        //  �rea De                                  �
//� mv_par12        //  �rea At                                  �
//� mv_par13        //  Solicitante De                           �
//� mv_par14        //  Solicitante At                           �
//� mv_par15        //  Situa��o das Vagas                       �
//� mv_par16        //  Matr�cula do Respons�vel                 �
//����������������������������������������������������������������
	
//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
WnRel := cNomePrg
WnRel := SetPrint(cString, WnRel, cPerg, Titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., nTamanho)

If nLastKey == 27
	Return 
EndIf	

SetDefault(aReturn,cString)

If nLastKey == 27
	Return 
EndIf	
	
RptStatus({|lEnd| RSR004Imp(@lEnd, WnRel, cString)}, Titulo)

Return Nil
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RSR004Imp� Autor � Fernando Joly         � Data � 05.03.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impress�o da Rela��o de Vagas                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSR004Imp(lEnd, WnRel, cString)                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd        - A��o do Codelock                             ���
���          � WnRel       - T�tulo do relat�rio                          ���
���Parametros� cString     - Mensagem                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function RSR004Imp(lEnd, WnRel, cString)

//-- Variaveis Locais
Local cDet       := ''
Local cVagaDe    := ''
Local cVagaAte   := ''
Local cCCDe      := ''
Local cCCAte     := ''
Local cFuncaoDe  := ''
Local cFuncaoAte := ''
Local cClienteDe := ''
Local cClienteAte:= ''
Local nPrazoDe   := 0
Local nPrazoAte  := 0
Local cAreaDe    := ''
Local cAreaAte   := ''
Local cSoliDe    := ''
Local cSoliAte   := ''
Local cInicio    := ''
Local cFim       := ''
Local cArqNtx    := ''
Local cCCAnt     := Replicate('�', Len(SQS->QS_CC))
Local nOrdem     := aReturn[8]
Local cDescArea  := ''
Local nSituacao  := 0
Local nTamStr    := 19

//-- Define T�tulo do Relat�rio
Titulo := Titulo

//��������������������������������������������������������������Ŀ
//� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
//����������������������������������������������������������������
cVagaDe     := mv_par01
cVagaAte    := mv_par02
cCCDe       := mv_par03
cCCAte      := mv_par04
cFuncaoDe   := mv_par05
cFuncaoAte  := mv_par06
cClienteDe  := Upper(mv_par07)
cClienteAte := Upper(mv_par08)
nPrazoDe    := mv_par09
nPrazoAte   := mv_par10
cAreaDe     := mv_par11
cAreaAte    := mv_par12
cSoliDe     := Upper(mv_par13)
cSoliAte    := Upper(mv_par14)
nSituacao   := mv_par15		     //Situacao das Vagas 
cMatResp    := alltrim(mv_par16) //Matr�cula do Respons�vel 
nTipoRel    := If(!Empty(mv_par17),mv_par17,2) //1-Anal�tico 2-Sint�tico 

If nTipoRel == 1
	wCabec1 := ''	
EndIf

//-- Designa Nome para Arquivo de �ndice Tempor�rio
cArqNtx := CriaTrab(Nil, .F.)

dbSelectArea('SQS')
If nOrdem == 1
	cInicio := 'QS_FILIAL + QS_CC + QS_VAGA'
	cFim    := xFilial('SQS') + cCCAte + cVagaAte
ElseIf nOrdem == 2
	cInicio := 'QS_FILIAL + QS_CC + QS_AREA + QS_FUNCAO + QS_VAGA'
	cFim    := xFilial('SQS') + cCCAte + cAreaAte + cFuncaoAte + cVagaAte
ElseIf nOrdem == 3
	cInicio := 'QS_FILIAL + QS_CC + QS_CLIENTE + QS_VAGA'
	cFim    := xFilial('SQS') + cCCAte + cClienteAte + cVagaAte
EndIf
IndRegua('SQS', cArqNtx, cInicio,,, STR0011) //'Incluindo Quebras de Centro de Custo...'
dbGoTop()

//-- Inicializa Regua de Impressao
SetRegua(SQS->(RecCount()))

Begin Sequence

	Do While !SQS->(Eof()) .And. &(cInicio) <= cFim
	
		//-- Incrementa a R�gua de Impressao
		IncRegua()
		
	   //-- Cancela a Impressao case se pressione Ctrl + A
	   If lEnd
	   	IMPR(cCancela,'C')
	      Break
	  	EndIF
		
		//��������������������������������������������������������������Ŀ
		//� Consiste Parametrizacao do Intervalo de Impressao            �
		//����������������������������������������������������������������
		If 	( Upper(SQS->QS_CLIENTE)	< cClienteDe ).Or. ( Upper(SQS->QS_CLIENTE)	> cClienteAte ) 	.Or. ;
			( Upper(SQS->QS_SOLICIT)	< cSoliDe ) 	.Or. ( Upper(SQS->QS_SOLICIT)	> cSoliAte )		.Or. ;
			( SQS->QS_PRAZO 			< nPrazoDe ) 	.Or. ( SQS->QS_PRAZO 			> nPrazoAte ) 	.Or. ;
			( SQS->QS_FUNCAO 			< cFuncaoDe )	.Or. ( SQS->QS_FUNCAO 			> cFuncaoAte ) 	.Or. ;
			( SQS->QS_VAGA 			< cVagaDe ) 	.Or. ( SQS->QS_VAGA 				> cVagaAte ) 		.Or. ;
			( SQS->QS_AREA 			< cAreaDe ) 	.Or. ( SQS->QS_AREA 				> cAreaAte ) 		.Or. ;
			( SQS->QS_CC 				< cCCDe ) 		.Or. ( SQS->QS_CC 				> cCCAte )
	      	
	      	SQS->(dbSkip())
			Loop
		Endif
		
		//��������������������������������������������������������������Ŀ
		//� Situacao das Vagas: Aberta - Fechada - Ambas                 �
		//����������������������������������������������������������������		
		If (nSituacao == 1 .And. SQS->QS_NRVAGA <= SQS->QS_VAGAFEC) .Or.; //Aberto
		   (nSituacao == 2 .And. SQS->QS_NRVAGA > SQS->QS_VAGAFEC)		//Fechado		    
        	SQS->(dbSkip())
			Loop
       EndIf

		//��������������������������������������������������������������Ŀ
		//� Valida Respons�vel pela vaga                                 �
		//����������������������������������������������������������������		
       If cMatResp <> ""
          If (SQS->QS_FILRESP <> cFilAnt) .Or. (SQS->QS_MATRESP <> cMatResp)
              SQS->(dbSkip())
              Loop
          EndIf
       EndIf
		
		Set Device To Printer

		//-- Processa a Quebra de Centro de Custo
		If SQS->QS_CC # cCCAnt
			cCCAnt := SQS->QS_CC 
			Impr("","C") 
			cDet := Repl("-",Colunas)
			Impr(cDet, "C")
			cDet := STR0012 + SQS->QS_CC + ' - ' + DescCC(SQS->QS_CC, If(!Empty(SQS->QS_FILIAL),SQS->QS_FILIAL, Nil)) //'CENTRO DE CUSTO: '
			ImpR(cDet, 'C')
			cDet := Repl("-",Colunas)
			Impr(cDet, "C")
		EndIf


		If nTipoRel == 1 //Anal�tico
          //Linha 1 
          cDet := STR0004 + Space(nTamStr-Len(STR0004)) + ':' + PadR(SQS->QS_VAGA + ' - ' + SQS->QS_DESCRIC,58) + '|' //Vaga
          cDet += STR0021 + Space(nTamStr-Len(STR0021)) + ':' + PadR(StrZero(SQS->QS_NRVAGA, 3),58)             + '|' //Qtd Vagas
          cDet += STR0028 + Space(nTamStr-Len(STR0028)) + ':' + x3Cbox('QS_TIPO',SQS->QS_TIPO) //Tipo Vaga
          ImpR(cDet, 'C')

          //Linha 2 
          If !empty(SQS->QS_FUNCAO)
             cDet := STR0020 + Space(nTamStr-Len(STR0020)) + ':' + PadR(SQS->QS_FUNCAO +' - ' +Fdesc("SRJ",SQS->QS_FUNCAO,"RJ_DESC"),58) + '|' //Fun��o
          Else
             cDet := STR0020 + Space(nTamStr-Len(STR0020)) + ':' + PadR('',58)                                                           + '|' //Fun��o
          EndIf   	
          cDet += STR0029 + Space(nTamStr-Len(STR0029)) + ':'  + PadR(StrZero(SQS->QS_VAGAFEC,3),58)                                     + '|' //Vagas Fechadas
          If !empty(SQS->QS_AREA)
             cDet += STR0005 + Space(nTamStr-Len(STR0005)) + ':' + SQS->QS_AREA + ' - ' + fDescTab('R1', SQS->QS_AREA) //Vaga
          Else    		
             cDet += STR0005 + Space(nTamStr-Len(STR0005)) + ':' + PadR('',58) //Vaga
          EndIf
          ImpR(cDet, 'C')

          //Linha 3
          If !empty(SQS->QS_MATRESP)
             cDet := STR0022 + Space(nTamStr-Len(STR0022)) + ':' + PadR(SQS->QS_FILRESP +'/' +SQS->QS_MATRESP +' - ' +FDESC("SRA",SQS->QS_MATRESP,"RA_NOME",,SQS->QS_FILRESP),58) + '|' //Respons�vel
          Else    		
             cDet := STR0022 + Space(nTamStr-Len(STR0022)) + ':' + PadR('',58)                                                                                                    + '|' //Respons�vel
          EndIf
          cDet += STR0023 + Space(nTamStr-Len(STR0023)) + ':' + PadR(StrZero(SQS->QS_PRAZO, 3),58)                                                                                + '|' //Prazo
          cDet += STR0024 + Space(nTamStr-Len(STR0024)) + ':' + Transform(SQS->QS_VCUSTO, '@E 99,999,999.99') //Custo da Vaga
          ImpR(cDet, 'C')

          //Linha 4 
          cDet := STR0025 + Space(nTamStr-Len(STR0025)) + ':' + PadR(SQS->QS_SOLICIT,58)                                                                          + '|' //Solicitante
          If !empty(SQS->QS_DTABERT)
             cDet += STR0015 + Space(nTamStr-Len(STR0015)) + ':' + PadR(DtoC(SQS->QS_DTABERT),58)                                                                 + '|' //Dt. Abert.
          Else    		
             cDet += STR0015 + Space(nTamStr-Len(STR0015)) + ':' + PadR('',58)                                                                                    + '|' //Dt. Abert.
          EndIf
          If !empty(SQS->QS_PROCESS)
             cDet += STR0026 + Space(nTamStr-Len(STR0026)) + ':' + SQS->QS_PROCESS + " - " + Fdesc("SQE",SQS->QS_PROCESS,"QE_DESCRIC",20) //Processo
          Else
             cDet += STR0026 + Space(nTamStr-Len(STR0026)) + ':' + PadR('',58) //Processo
          EndIf
          ImpR(cDet, 'C')

          //Linha 5 
          cDet := STR0006 + Space(nTamStr-Len(STR0006)) + ':' + PadR(SQS->QS_CLIENTE,58)                                                                          + '|' //Cliente
          If !empty(SQS->QS_DTFECH)
             cDet += STR0016 + Space(nTamStr-Len(STR0016)) + ':' + PadR(DtoC(SQS->QS_DTFECH),58)                                                                  + '|' //Dt. Fecham.
          Else    		
             cDet += STR0016 + Space(nTamStr-Len(STR0016)) + ':' + PadR('',58)                                                                                    + '|' //Dt. Fecham.
          EndIf
          If !empty(SQS->QS_POSTO)
             cDet += STR0027 + Space(nTamStr-Len(STR0027)) + ':' + SQS->QS_FILPOST +'/' +SQS->QS_POSTO //Posto
          Else    		
             cDet += STR0027 + Space(nTamStr-Len(STR0027)) + ':' + PadR('',58) //Posto
          EndIf
          ImpR(cDet, 'C')

          //Linha T�rmino 
			Impr("","C") 
       Else
			//-- Monta String a ser impresso
			cDet := SQS->QS_VAGA + " - "+SQS->QS_DESCRIC + Space(03)
			cDet += SQS->QS_SOLICIT + Space(3)
			cDet += StrZero(SQS->QS_NRVAGA, 3) + Space(3)
			cDet += StrZero(SQS->QS_PRAZO, 3) + Space(3)
			cDet += DtoC(SQS->QS_DTABERT) + If(__SetCentury(),Space(1),Space(3))
			cDet += DtoC(SQS->QS_DTFECH) + If(__SetCentury(),Space(1),Space(3))
			cDet += StrZero(SQS->QS_VAGAFEC,3) + Space(3)
			cDet += Transform(SQS->QS_VCUSTO, '@E 99,999,999.99') + Space(3)
			cDet += SQS->QS_AREA + ' - ' + Left(fDescTab('R1', SQS->QS_AREA), 18) + Space(3)
			cDet += SQS->QS_CLIENTE + Space(03)
			cDet += SQS->QS_PROCESS + " - " + Fdesc("SQE",SQS->QS_PROCESS,"QE_DESCRIC",20)
			ImpR(cDet, 'C')
		EndIf	
		
		SQS->(dbSkip())
		
	Enddo

End Sequence

If Len(cDet) > 0
	ImpR('', 'F')
EndIf

//-- Apaga indice Tempor�rio
If File(cArqNtx+OrdBagExt())
	RetIndex("SQS")
	FErase(cArqNtx+OrdBagExt())
	Set Filter to
Endif

//��������������������������������������������������������������Ŀ
//� T�rmino do Relat�rio                                         �
//����������������������������������������������������������������
dbSelectArea('SQS')
dbSetOrder(1)
Set Device To Screen

If aReturn[5] == 1
	Set Printer To
	dbCommit()
	OurSpool(WnRel)
Endif
MS_FLUSH()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fDescTab � Autor � Fernando Joly         � Data � 06.03.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a Descri��o do Item de uma Tebala Cadastrada       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fDescTab(cTab, cItem)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cTab        - Tabela a ser Perquizada                      ���
���          � cItem       - Item da Tabela a ser Pesquizado              ���
�������������������������������������������������������������������������Ĵ��
���Retirno   � Retorna a descri��o do Item ou a mensagem "Nao Cadastrado" ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function fDescTab(cTab, cItem)

//-- Inicializa Variaveis Locais
Local cDescArea := Space(Len(X5Descri()))
Local cOldRecno := SX5->(Recno())

If SX5->(dbSeek(xFilial('SX5') + cTab + cItem, .F.))
	cDescArea := X5Descri()
Else
	cDescArea := STR0013 + Space(35) //'** Nao Cadastrado **'
EndIf

SX5->(dbGoto(cOldRecno))

Return(cDescArea)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � x3Cbox � Autor � Marcelo Faria           � Data � 23.01.17 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a Descricao do x3 cbox                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function x3Cbox(cCampo, cConteudo)
Local nPos
Local nPosCpo
Local cRet := ""
Static aCbox := {}

If (nPosCpo := Ascan(aCbox,{|x| x[3] = cCampo}) ) == 0
	aCbox := x3CboxToArray(cCampo)
Endif
nPos  := aScan(aCbox[2], cConteudo)
cRet  := If(nPos > 0, aCbox[1, nPos], "")

Return(cRet)

