#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "EXTRABH.CH"

#IFNDEF CRLF
	#DEFINE CRLF ( chr(13)+chr(10) )
#ENDIF	

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � EXTRABH  � Autor � Equipe Advanced RH    � Data � 11.12.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Extrato de Banco de Horas                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � EXTRATBH                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ�� 
���Mauricio MR �05/09/01�      � Correcao impressao de saldo anterior     ���
���Marinaldo   �27/09/01�Melhor�Tratamento para o Terminal de Consulta    ���
���Marinaldo   �12/11/01�Melhor�Redefinicao do Codigo HTML para o Terminal���
���            �--------�------�de Consultar (RH OnLine)                  ���
���Mauricio MR �20/09/02�059512�Renomeacao da variavel cFilAnt p/ cFilTmp ���
���            �--------�------�para preservar o conteudo da variavel pri-���
���            �--------�------�vate cFilAnt reservada ao Sistema.        ���
���Mauricio MR �08/09/03�066270�Correcao da Impressao do Saldo Anterior p/���
���            �--------�------�varias quantidades de copias.			  ���
��������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Programador  � Data     � FNC            �  Motivo da Alteracao                      ���
���������������������������������������������������������������������������������������ĳ��
���Rogerio R.   �29/07/2009�00000018267/2009�Compatibilizacao dos fontes para aumento do���
���             �          �                �campo filial e gest�o corporativa.         ���
���Gustavo M.   �17/05/2012�00000005626/2012�Ajuste para considerar o periodo de um ano ���
���             �          �                �na consulta de banco de horas via rhonline.���
���Emerson Camp �11/06/2012�      REQ126-008�Adaptacao de fonte para emitir o relatorio ���
���             �          �                �no novo formato do Portal.                 ���
���Allyson M.   �29/08/2016�          TVYPZL�Ajuste no bot�o de impress�o do portal RH  ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
Function PONR190()

Local aOrd		:= { STR0006 , STR0007 , STR0008 , STR0009 , STR0010 } //'Matricula'###'Centro de Custo'###'Nome'###'Turno'###'C.Custo + Nome'
Local cHtml		:= "" 
Local cAviso		
Local cDesc1    := STR0003	//'Extrato de Banco de Horas'
Local cDesc2    := STR0004	//'Ser� impresso de acordo com os parametros solicitados pelo'
Local cDesc3    := STR0005	//'usuario.'
Local cString	:= 'SRA' 	//-- Alias do arquivo principal (Base)
Local lEnd		:= .F.  
//-- Tratamento dos arquivos envolvidos no Fechamento Mensal (Para evitar que o processo nao seja finalizado)
Local aFilesOpen :={"SP5", "SPN", "SP8", "SPG","SPB","SPL","SPC", "SPH", "SPF"}
Local bCloseFiles:= {|cFiles| If( Select(cFiles) > 0, (cFiles)->( DbCloseArea() ), NIL) }

Private aReturn  := { STR0001 , 1, STR0002 , 2, 2, 1, '',1 } //'Zebrado'###'Administra��o'
Private nomeprog := 'EXTRBH'
Private aLinha   := {}
Private nLastKey := 0
Private cPerg    := 'EXTRBH'
Private Titulo   := OemToAnsi( STR0011 ) //'Extrato de Banco de Horas'
Private cCabec   := ''
Private AT_PRG   := 'EXTRBH'
Private wCabec0  := 1
Private wCabec1  := ''
Private CONTFL   := 1
Private LI       := 1 //Inicializa Li com 1 para Nao Imprimir Cabecalho Padrao.
Private nTamanho := 'M'
Private aInfo    := {}
Private wnrel
Private nOrdem

If Type("Paramixb") == "A"
	lTerminal 		:= Paramixb[1]
	cFilTerminal 	:= Paramixb[2]
	cMatTerminal 	:= Paramixb[3]
	lPortal			:= Paramixb[4]
EndIf

lTerminal := IF( lTerminal == NIL , .F. , lTerminal )
lPortal 	:= IF( lPortal == NIL , .F. , lPortal )

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte( cPerg , .F. )

IF !lTerminal

	//��������������������������������������������������������������Ŀ
	//� Envia controle para a funcao SETPRINT                        �
	//����������������������������������������������������������������
	wnrel := 'EXTRBH' //-- Nome Default do relatorio em Disco
	wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,nTamanho)

EndIF	

//��������������������������������������������������������������Ŀ
//� Retorna a Ordem do Relatorio.                                �
//����������������������������������������������������������������
nOrdem    := IF( !lTerminal , aReturn[8] , 1 )

//��������������������������������������������������������������Ŀ
//� Carregando variaveis MV_PAR?? para Variaveis do Sistema.     �
//����������������������������������������������������������������
Private FilialDe  := IF( !lTerminal , MV_PAR01 , cFilTerminal	)	//Filial  De
Private FilialAte := IF( !lTerminal , MV_PAR02 , cFilTerminal	)	//Filial  Ate
Private CcDe      := IF( !lTerminal , MV_PAR03 , SRA->RA_CC		)	//Centro de Custo De
Private CcAte     := IF( !lTerminal , MV_PAR04 , SRA->RA_CC		)	//Centro de Custo Ate
Private TurDe     := IF( !lTerminal , MV_PAR05 , SRA->RA_TNOTRAB)	//Turno De
Private TurAte    := IF( !lTerminal , MV_PAR06 , SRA->RA_TNOTRAB)	//Turno Ate
Private MatDe     := IF( !lTerminal , MV_PAR07 , cMatTerminal	)	//Matricula De
Private MatAte    := IF( !lTerminal , MV_PAR08 , cMatTerminal	)	//Matricula Ate
Private NomDe     := IF( !lTerminal , MV_PAR09 , SRA->RA_NOME	)	//Nome De
Private NomAte    := IF( !lTerminal , MV_PAR10 , SRA->RA_NOME	)	//Nome Ate
Private RegDe     := IF( !lTerminal , MV_PAR11 , SRA->RA_REGRA	)	//Regra De
Private RegAte    := IF( !lTerminal , MV_PAR12 , SRA->RA_REGRA	)	//Regra Ate
Private dDtIni    := IF( !lTerminal , MV_PAR13 , YearSub(dDataBase, 1))	//Data Inicial
Private dDtFim    := IF( !lTerminal , MV_PAR14 , dDataBase		)	//Data Final
Private cSit      := IF( !lTerminal , MV_PAR15 , fSituacao(,.F.))	//Situacao
Private cCat      := IF( !lTerminal , MV_PAR16 , fCategoria(,.F.))	//Categoria
Private nHoras    := IF( !lTerminal , MV_PAR17 , 1				)	//Horas Normais/Valorizadas
Private nCopias   := IF( !lTerminal , MV_PAR18 , 1				)	//Numero de Copias
Private nSalBH	  := IF( !lTerminal , MV_PAR19 , 1				)	//Imprimir com Saldo(Result/Credor/Devedor)
Private nTpEvento := IF( !lTerminal , MV_PAR20 , 3				)	//Imprimir Eventos(Autoriz/N.Autoriz/Ambos)

IF lTerminal

	//-- Verifica se foi possivel abrir os arquivos sem exclusividade
	If Pn090Open(@cHtml, @cAviso)
		cHtml := ""	
		cHtml := ImpExtraBh( @lEnd , wNRel , cString , lTerminal, lPortal  ) 
	    /*
		��������������������������������������������������������������Ŀ
		� Apos a obtencao da consulta solicitada fecha os arquivos     �
		� utilizados no fechamento mensal para abertura exclusiva      �
		����������������������������������������������������������������*/
	    Aeval(aFilesOpen, bCloseFiles)
	Else
	   cHtml := HtmlDefault( cAviso , cHtml )   
	Endif
	
ElseIF !( nLastKey == 27 )

	SetDefault( aReturn , cString )

	IF !( nLastKey == 27 )

	    RptStatus( { |lEnd| ImpExtraBh( @lEnd , wNRel , cString ) } , Titulo )

	EndIF

EndIF

Return( cHtml )

Static Function ImpExtraBh( lEnd, wNRel, cString , lTerminal, lPortal )

Local cAcessaSRA	:= &("{ || " + ChkRH("EXTRABH","SRA","2") + "}")
Local cHtml			:= ""
Local cFil       	:= ''
Local cMat       	:= ''
Local cTno       	:= ''
Local cFilTmp    	:= Replicate("�", FWGETTAMFILIAL)
Local cTnoAnt    	:= Replicate("�", GetSx3Cache("RA_TNOTRAB", "X3_TAMANHO"))
Local lLoop      	:= .F.
Local nX         	:= 0
Local nY         	:= 0
Local nCount		:= 0
Local nDebValrz		:= 0
Local nCreValrz		:= 0
Local nSldValorz	:= 0
Local nSldAntVal	:= 0
Local lImpBaixad	:= SuperGetMv("MV_IMPBHBX",,.T.) // Lista horas baixadas?

Private aValoriz

lTerminal := IF( lTerminal == NIL , .F. , lTerminal )

lEnd:=.F.

dbSelectArea('SRA')
dbSetOrder(nOrdem)
If nOrdem == 1 .or. lTerminal
	cInicio  := 'RA_FILIAL + RA_MAT'
	IF !lTerminal
		dbSeek(FilialDe + MatDe,.T.)
		cFim     := FilialAte + MatAte
	Else
		cFim     := &( cInicio )
	EndIF		
ElseIf nOrdem == 2
   dbSeek(FilialDe + CcDe + MatDe,.T.)
   cInicio  := 'RA_FILIAL + RA_CC + RA_MAT'
   cFim     := FilialAte + CcAte + MatAte
ElseIf nOrdem == 3
   dbSeek(FilialDe + NomDe + MatDe,.T.)
   cInicio  := 'RA_FILIAL + RA_NOME + RA_MAT'
   cFim     := FilialAte + NomAte + MatAte
ElseIf nOrdem == 4
   dbSeek(FilialDe + TurDe + MatDe,.T.)
   cInicio  := 'RA_FILIAL + RA_TNOTRAB + RA_MAT'
   cFim     := FilialAte + TurAte + MatAte
ElseIf nOrdem == 5
   dbSetOrder(8)
   dbSeek(FilialDe + CcDe + NomDe,.T.)
   cInicio  := 'RA_FILIAL + RA_CC + RA_NOME'
   cFim     := FilialAte + CcAte + NomAte
Endif

//-- Inicializa R�gua de Impress�o
IF !lTerminal
	SetRegua(RecCount())
EndIF	

dbSelectArea("SRA")
While SRA->( !Eof() .and. &(cInicio) <= cFim )

   IF !lTerminal
   
	   //-- Incrementa a R�gua de Impress�o
	   IncRegua()
	
	   //-- Cancela a Impress�o case se pressione Ctrl + A
	   If lEnd
	      IMPR(cCancela,'C')
	      Exit
	   EndIF
	
	   //��������������������������������������������������������������Ŀ
	   //� Consiste Parametrizacao do Intervalo de Impressao            �
	   //����������������������������������������������������������������
	   If (SRA->RA_TNOTRAB < Turde) .Or. (SRA->RA_TNOTRAB > TurAte) .Or. ;
	      (SRA->Ra_NOME < NomDe) .Or. (SRA->RA_NOME > NomAte) .Or. ;
	      (SRA->Ra_MAT < MatDe) .Or. (SRA->RA_MAT > MatAte)  .Or. ;
	      (SRA->Ra_CC < CCDe) .Or. (SRA->RA_CC > CCAte) .Or. ;
	      (SRA->Ra_REGRA < RegDe) .Or. (SRA->RA_REGRA > RegAte)
	      dbSkip()
	      Loop
	   Endif
	
	   //-- Consiste Preenchimento de Cracha e data de Demiss�o
	   If !Empty(SRA->RA_DEMISSA) .And. SRA->RA_DEMISSA < dDtIni
	      DbSkip()
	      Loop
	   Endif
	
	   //-- Consiste Situacao e Categoria
	   If !(Sra->Ra_SitFolh $ cSit) .Or. ;
	      !(Sra->Ra_CatFunc $ cCat)
	      DbSkip()
	      Loop
	   Endif
	
		//��������������������������������������������������������������Ŀ
		//� Consiste controle de acessos e filiais validas               �
		//����������������������������������������������������������������
		If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
			SRA->(dbSkip())
			Loop
		EndIf
	
	EndIF
	
	If SRA->RA_FILIAL != cFilTmp
		cFilTmp    := SRA->RA_FILIAL
		cTnoAnt    := Replicate("�", GetSx3Cache("RA_TNOTRAB", "X3_TAMANHO"))
		//-- Atualiza o Array de Informa��es sobre a Empresa.
		aInfo := {}
		fInfo(@aInfo, SRA->RA_FILIAL)
	Endif

	IF !lTerminal
		Set Device to Printer
	EndIF	

	//-- Carrega os Totais de Horas e Abonos.
	nSaldo   	:=0
	nSldValorz	:=0
	nSaldoAnt	:=0
	nSldAntVal	:=0
	aDet     	:={}
	aValoriz 	:={}

   // 1 - Data
   // 2 - Codigo do Evento
   // 3 - Descricao do Evento
   // 4 - Quantidade de Horas Debito
   // 5 - Quantidade de Horas Credito
   // 6 - Saldo
   // 7 - Status

   //��������������������������������������������������������������Ŀ
   //� Verifica lancamentos no Banco de Horas                       �
   //����������������������������������������������������������������
   dbSelectArea( "SPI" )
   dbSetOrder(2)
   dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
   While !Eof() .And. SPI->PI_FILIAL+SPI->PI_MAT == SRA->RA_FILIAL+SRA->RA_MAT
      // Totaliza Saldo Anterior
      If SPI->PI_STATUS == " " .And. SPI->PI_DATA < dDtIni
         If PosSP9( SPI->PI_PD , SRA->RA_FILIAL, "P9_TIPOCOD") $ "1*3" 
				If nHoras == 1	// Horas Normais
					nSaldoAnt	:= SomaHoras(nSaldoAnt,SPI->PI_QUANT)
					nSldAntVal	:= SomaHoras(nSldAntVal,SPI->PI_QUANTV)
				Else
					nSaldoAnt:=SomaHoras(nSaldoAnt,SPI->PI_QUANTV)
				Endif
	      Else
				If nHoras == 1
		         nSaldoAnt	:= SubHoras(nSaldoAnt,SPI->PI_QUANT)
		         nSldAntVal := SubHoras(nSldAntVal,SPI->PI_QUANTV)
				Else
		         nSaldoAnt:=SubHoras(nSaldoAnt,SPI->PI_QUANTV)
				Endif
	      Endif
			nSaldo := nSaldoAnt
			nSldValorz := nSldAntVal
		Endif

		//��������������������������������������������������������������Ŀ
		//� Verifica os Lancamentos a imprimir                           �
		//����������������������������������������������������������������
		If	SPI->PI_DATA < dDtIni .Or. SPI->PI_DATA > dDtFim .Or. (SPI->PI_STATUS == "B" .And. !lImpBaixad) 
			dbSkip()
			Loop
		Endif

		//-- Verifica tipo de Evento quando for diferente de Ambos
		If nTpEvento <> 3
			If !fBscEven(SPI->PI_PD,2,nTpEvento)
				SPI->(dbSkip())
				Loop
			EndIf
		Else
			PosSP9( SPI->PI_PD ,SRA->RA_FILIAL )
		Endif

		//��������������������������������������������������������������Ŀ
		//� Acumula os lancamentos de Proventos/Desconto em Array        �
		//����������������������������������������������������������������

		If SP9->P9_TIPOCOD $ "1*3"
			nSaldo:=SomaHoras(nSaldo,If(SPI->PI_STATUS=="B",0,If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV)))
		Else
			nSaldo:=SubHoras (nSaldo,If(SPI->PI_STATUS=="B",0,If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV)))
		Endif

		aAdd(aDet,{padr(DTOC(SPI->PI_DATA),10),SPI->PI_PD,;
					  Left(DescPdPon(SPI->PI_PD,SPI->PI_FILIAL),20),;
					  Transform(If(SP9->P9_TIPOCOD $ "1*3",0,If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV)),"9999999.99"),;
					  Transform(If(SP9->P9_TIPOCOD $ "1*3",If(nHoras==1,SPI->PI_QUANT,SPI->PI_QUANTV),0),"9999999.99"),;
					  Transform(nSaldo,"99999999.99"),IF(SPI->PI_STATUS=="B","Baixado","Pendente") })

		// Totaliza Horas Valorizadas para exibi��o no Portal GCH
		If lPortal .And. nHoras==1
			If SP9->P9_TIPOCOD $ "1*3"
				nCreValrz	:= SPI->PI_QUANTV
				nDebValrz	:= 0
				nSldValorz	:= SomaHoras(nSldValorz,If(SPI->PI_STATUS=="B",0,SPI->PI_QUANTV))
			Else
				nCreValrz	:= 0
				nDebValrz	:= SPI->PI_QUANTV
				nSldValorz	:= SubHoras(nSldValorz,If(SPI->PI_STATUS=="B",0,SPI->PI_QUANTV))
			EndIf
		EndIf
		aAdd(aValoriz,{ Transform(nDebValrz,"9999999.99"),Transform(nCreValrz,"9999999.99"),Transform(nSldValorz,"9999999.99")})

		dbSelectArea( "SPI" )
		SPI->( dbSkip() )

	Enddo

   If (Len(aDet) > 0 .OR. !EMPTY(nSaldo)) .OR. lPortal
		If nSalBH == 1	.Or. (nSalBH == 2 .And. nSaldo >= 0) .Or.;
								  (nSalBH == 3 .And. nSaldo < 0)
      	//-- Imprime o Espelho para um Funcionario.
	      For nCount := 1 To nCopias
	      	If lPortal
	      		cHtml := fImpPortal( )	
	      	Else
	          cHtml := fImpFun( lTerminal )
	      	EndIf
	      Next
		Endif
	Endif

   dbSelectArea("SRA")
   dbSkip()

Enddo

IF !lTerminal

	//��������������������������������������������������������������Ŀ
	//� Termino do relatorio                                         �
	//����������������������������������������������������������������
	dbSelectArea('SPI')
	dbSetOrder(1)
	
	dbSelectArea('SRA')
	dbSetOrder(1)
	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
	   Set Printer To
	   dbCommit()
	   OurSpool(wnrel)
	Endif
	MS_FLUSH()

EndIF

Return( cHtml )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FImpFun   � Autor � Equipe Advanced RH    � Data � 11.12.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o Extrato de Banco de Horas                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � POR010IMP                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fImpFun( lTerminal  )

Local cHtml		:= ""
Local cDet      := ""
Local nX        := 0
Local nDet	  	:= 0	
Local lZebrado	:= .F.

//-- O valor inicial do Saldo passa a ser do Saldo Anterior ao Periodo Solicitado
nSaldo := nSaldoAnt
lTerminal := IF( lTerminal == NIL , .F. , lTerminal )

/*
-------------------------------------------------------------------------------
  Data     Evento                       Debito    Credito       Saldo  Status
-------------------------------------------------------------------------------
                      Saldo Anterior 999999.99       0,00        0,00
99/99/99   999-XXXXXXXXXXXXXXXXXXXX 9999999,99 9999999,99 99999999,99  Baixado
*/

//-- Inicializa Li com 1 para n�o imprimir cabecalho padrao
Li := 01

IF lTerminal
	cHtml += HtmlProcId() + CRLF
	cHtml += '<html>'  + CRLF
	cHtml += 	'<head>'  + CRLF
	cHtml += 		'<title>RH Online</title>'  + CRLF
	cHtml +=		'<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'  + CRLF
	cHtml +=		'<link rel="stylesheet" href="css/rhonline.css" type="text/css">'  + CRLF 
	cHtml +=	'</head>'  + CRLF
	cHtml +=	'<body bgcolor="#FFFFFF" text="#000000">'  + CRLF
	cHtml +=		'<table width="515" border="0" cellspacing="0" cellpadding="0">'  + CRLF
  	cHtml +=			'<tr>'  + CRLF
    cHtml +=				'<td class="titulo">'  + CRLF
    cHtml +=					'<p>'  + CRLF
    cHtml +=						'<img src="'+TcfRetDirImg()+'/icone_titulo.gif" width="7" height="9">'  + CRLF
    cHtml +=							'<span class="titulo_opcao">'  + CRLF
    cHtml +=								STR0003 + CRLF	//'Extrato de Banco de Horas'
    cHtml +=							'</span>' + CRLF
    cHtml +=							'<br><br>' + CRLF
	cHtml +=					'</p>' + CRLF
	cHtml +=				'</td>' + CRLF
  	cHtml +=			'</tr>' + CRLF
  	cHtml +=			'<tr>' + CRLF
    cHtml +=				'<td>' + CRLF
    cHtml +=					'<p><img src="'+TcfRetDirImg()+'/tabela_conteudo.gif" width="515" height="12" align="center"></p>' + CRLF
    cHtml +=				'</td>' + CRLF
  	cHtml +=			'</tr>' + CRLF
  	cHtml +=			'<tr>' + CRLF
    cHtml +=				'<td>' + CRLF
    cHtml +=					'<table width="515" border="0" cellspacing="0" cellpadding="1">' + CRLF
    cHtml +=						'<tr>' + CRLF
    cHtml +=							'<td background="'+TcfRetDirImg()+'/tabela_conteudo_1.gif" width="10">&nbsp;</td>' + CRLF
    cHtml +=							'<td class="titulo" width="498">' + CRLF
    cHtml +=								'<table width="498" border="0" cellspacing="0" cellpadding="0">' + CRLF
	cHtml +=									'<tr>' + CRLF
	cHtml +=										'<td class="etiquetas" bgcolor="#FAFBFC" nowrap>' + CRLF
    cHtml +=											'<div align="left">' + CRLF
    cHtml +=												STR0025 + CRLF	//"Data"
    cHtml +=											'</div>' + CRLF
    cHtml +=										'</td>' + CRLF
    cHtml +=										'<td class="etiquetas" bgcolor="#FAFBFC" nowrap>' + CRLF
    cHtml +=											'<div align="left">' + CRLF
    cHtml +=												STR0026 + CRLF	//"Evento"
    cHtml +=											'</div>' + CRLF
    cHtml +=										'</td>' + CRLF
    cHtml +=										'<td class="etiquetas" bgcolor="#FAFBFC" nowrap>' + CRLF
    cHtml +=											'<div align="right">' + CRLF
    cHtml +=												STR0027 + CRLF	//'D&eacute;bito'
    cHtml +=											'</div>' + CRLF
    cHtml +=										'</td>' + CRLF
    cHtml +=										'<td class="etiquetas" bgcolor="#FAFBFC" nowrap>' + CRLF
    cHtml +=											'<div align="right">' + CRLF
    cHtml +=												STR0028 + CRLF	//'Cr&eacute;dito'
    cHtml +=											'</div>' + CRLF
    cHtml +=										'</td>' + CRLF
    cHtml +=										'<td class="etiquetas" bgcolor="#FAFBFC" nowrap>' + CRLF
    cHtml +=											'<div align="right">' + CRLF
    cHtml +=												STR0029 + CRLF	//'Saldo'
    cHtml +=											'</div>' + CRLF
    cHtml +=										'</td>' + CRLF
    cHtml +=										'<td class="etiquetas" bgcolor="#FAFBFC" nowrap>' + CRLF
    cHtml +=											'<div align="center">' + CRLF
    cHtml +=												STR0030 + CRLF	//'Status'
    cHtml +=											'</div>' + CRLF
    cHtml +=										'</td>' + CRLF
    cHtml +=									'</tr>' + CRLF
    cHtml +=									'<tr>' + CRLF
    cHtml +=										'<td colspan="06" class="etiquetas" bgcolor="#FAFBFC"><hr size="1"></td>' + CRLF
    cHtml +=									'</tr>' + CRLF
EndIF

//-- Imprime Cabecalho Especifico.
IF !lTerminal
	Imp_Cabec() //aqui
EndIF	

//-- Imprime Marca��es
nDet := Len(aDet)
For nX := 1 To nDet
	lZebrado := ( nX%2 == 0.00 )
	IF nX > 1
		nSaldo := Val(aDet[nX-1,6])
	EndIF
	IF !lTerminal
		IF Li >57
			Li := 01
			Imp_Cabec()
		EndIF
		cDet :=	aDet[nX,1] + " "
		cDet +=	aDet[nX,2] + "-"
		cDet += aDet[nX,3] + " "
		cDet += aDet[nX,4] + " "
		cDet += aDet[nX,5] + " "
		cDet += aDet[nX,6] + "  "
		cDet += aDet[nX,7]
		Impr(cDet, 'C')
	Else
		IF lZebrado
			cHtml += '<tr bgcolor="#FAFBFC">' + CRLF
			cHtml += 	'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="center">' + CRLF
			cHtml +=	aDet[nX,1] + CRLF
			cHtml += 	'</td>' + CRLF
			cHtml += 	'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="left">' + CRLF
			cHtml += 		aDet[nX,2] + " - " + Capital( AllTrim( aDet[nX,3] ) ) + CRLF
			cHtml += 	'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="right">' + CRLF
			cHtml += 		aDet[nX,4] + CRLF
			cHtml += 	'</td>' + CRLF
			cHtml += 	'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="right">' + CRLF
			cHtml += 		aDet[nX,5] + CRLF
			cHtml += 	'</td>' + CRLF
			cHtml +=	 '<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="right">' + CRLF
			cHtml +=		aDet[nX,6] + CRLF
			cHtml += 	'</td>' + CRLF
			cHtml += 	'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="center">' + CRLF
			cHtml += 		aDet[nX,7] + CRLF
			cHtml += 	'</td>' + CRLF
			cHtml += '<tr>' + CRLF
		Else
			cHtml += '<tr>' + CRLF
			cHtml += 	'<td class="dados_2" nowrap><div align="center">' + CRLF
			cHtml +=	aDet[nX,1] + CRLF
			cHtml += 	'</td>' + CRLF
			cHtml += 	'<td class="dados_2" nowrap><div align="left">' + CRLF
			cHtml += 		aDet[nX,2] + " - " + Capital( AllTrim( aDet[nX,3] ) ) + CRLF
			cHtml += 	'</td>' + CRLF
			cHtml += 	'<td class="dados_2" nowrap><div align="right">' + CRLF
			cHtml += 		aDet[nX,4] + CRLF
			cHtml += 	'</td>' + CRLF
			cHtml += 	'<td class="dados_2" nowrap><div align="right">' + CRLF
			cHtml += 		aDet[nX,5] + CRLF
			cHtml += 	'</td>' + CRLF
			cHtml +=	 '<td class="dados_2" nowrap><div align="right">' + CRLF
			cHtml +=		aDet[nX,6] + CRLF
			cHtml += 	'</td>' + CRLF
			cHtml += 	'<td class="dados_2" nowrap><div align="center">' + CRLF
			cHtml += 		aDet[nX,7] + CRLF
			cHtml += 	'</td>' + CRLF
			cHtml += '<tr>' + CRLF
		EndIF	
	EndIF
Next nx

IF !lTerminal

	//-- Atualiza saldo anterior para o ultimo registro lido
	//-- Senao, ao findar a pagina na ultima linha detalhe, o saldo anterior a se impresso
	//-- ira exibir o saldo anterior como o penultimo calculado. 
	nSaldo := iif(Empty(Len(aDet)),nSaldo,Val(aDet[Len(aDet),6]))
	If (Li+4) >57
		Li := 01
		Imp_Cabec()
	Endif
	Impr(__PrtThinLine(),'C') 
	Impr(' ','C')
	Impr(Space(55) +  Repl('_',31), 'C')
	Impr(Space(58) + STR0012 , 'C') //"Assinatura do Funcionario "
Else
	cHtml +=								'</table>'
	cHtml +=								'<br>'
	cHtml +=							'</td>'
    cHtml +=							'<td background="'+TcfRetDirImg()+'/tabela_conteudo_2.gif" width="7">&nbsp;</td>'
    cHtml +=						'</tr>'
    cHtml +=					'</table>'
    cHtml +=				'</td>'
  	cHtml +=			'</tr>'
  	cHtml +=			'<tr>' 
    cHtml +=				'<td><img src="'+TcfRetDirImg()+'/tabela_conteudo_3.gif" "515" height="14" align="center"></td>'
  	cHtml +=			'</tr>'
	cHtml +=		'</table>'
	cHtml +=		'<p align="right"><a href="javascript:self.print()"><img src="'+TcfRetDirImg()+'/imprimir.gif" width="90" height="28" hspace="20" border="0"></a></p>'
	cHtml +=	'</body>'
	cHtml += '</html>'
EndIF
	
Return( cHtml )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Imp_Cabec � Autor � Equipe Advanced RH    � Data � 11.12.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o cabecalho do Extrato do Banco de horas           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � POR010IMP                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Imp_Cabec()

cDet      := ''
cDescCc   := ''


@ 0,0 PSAY AvalImp(132)
  


//-- Linha 01
//-- Emp...: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX Matr..: 99-999999  Chapa : 9999999999
cDet := STR0013 + Left( If(Len(aInfo)>0,aInfo[03],SM0->M0_NomeCom) + Space(44), 51) //'Emp...: '
cDet := cDet + STR0014 + SRA->RA_FILIAL + '-' + SRA->RA_Mat	//' Matr..: '
cDet := cDet + STR0015  + SRA->RA_ChapA //'  Chapa : '
Impr(cDet,'C')

//-- Linha 02
//-- End...: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX Nome..: XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
cDet := STR0016 + Left( If(Len(aInfo)>0,aInfo[04],SM0->M0_EndCob) + Space(43), 50) //'End...: '
cDet := cDet + STR0017 + Left(SRA->RA_Nome + Space(30), 30) //' Nome..: '
Impr(cDet,'C')

//-- Linha 03
//-- CGC...: 99.999.999/9999-99                Funcao: 9999-XXXXXXXXXXXXXXXXXXXX
cDet := STR0018 + Transform( If(Len(aInfo)>0,aInfo[08],SM0->M0_CGC),'@R 99.999.999/9999-99') + Space(33) //'CGC...: '
cDet := cDet + STR0019 + SRA->RA_CodFunc + '-' + Left(DescFun(SRA->RA_CodFunc , SRA->RA_FILIAL) + Space(20), 20) //'Funcao: '
Impr(cDet,'C')

//-- Linha 04
//-- C.C...: 99999999-XXXXXXXXXXXXXXXXXXXXXXX  Categ.: XXXXXXXXXXXXXXX
cDet := STR0020 + Left(SUBS(SRA->RA_CC,1,20) + '-' + Left(DescCc(SRA->RA_CC, SRA->RA_FILIAL,30) + Space(33), 33) + Space(50), 50) //'C.C...: '
cDet := cDet + STR0021 + DescCateg(SRA->RA_CatFunc,15) //' Categ.: '
Impr(cDet,'C')

//-- Linha 05
//-- Turno.: 999-XXXXXXXXXXXXXXXXXXXXX
cDescTno := Space(50)
cFil := xFilial('SR6', SRA->RA_FILIAL)

dbSelectArea("SR6")
If dbSeek(cFil+SRA->RA_TNOTRAB,.F.)
   cDescTno := Left(AllTrim(SR6->R6_Desc),50)
EndIf
cDet := STR0022 + AllTrim(SRA->RA_TnoTrab) + '-' + cDescTno //'Turno.: '

Impr(cDet,'C')

//-- Monta e Imprime Cabecalho das Marcacoes
cDet := STR0023 //'  Data     Evento                       Debito    Credito       Saldo  Status'

Impr(__PrtThinLine(),'C') 
Impr(cDet, 'C')
Impr(__PrtThinLine(),'C') 

cDet := Space(43) + STR0024 + Transform(nSaldo,"99999999.99") //"Saldo Anterior "
Impr( cDet ,"C")

Return( NIL )

/*
*******************************************************************************

Data               Saldo Anterior     Debito    Credito       Saldo  Status
  Data   Evento                       Debito    Credito       Saldo  Status
*******************************************************************************
                                         Saldo Anterior 99999999,99
99/99/99 999-XXXXXXXXXXXXXXXXXXXX 9999999,99 9999999,99 99999999,99  Pendente
99/99/99 999-XXXXXXXXXXXXXXXXXXXX 9999999,99 9999999,99 99999999,99  Baixado
99/99/99                999999.99 9999999,99 9999999,99 99999999,99  Baixado

*******************************************************************************

Data                 Saldo Anterior     Debito    Credito       Saldo  Status
  Data     Evento                       Debito    Credito       Saldo  Status
*******************************************************************************
                                           Saldo Anterior 99999999,99
99/99/9999 999-XXXXXXXXXXXXXXXXXXXX 9999999,99 9999999,99 99999999,99  Pendente
99/99/9999 999-XXXXXXXXXXXXXXXXXXXX 9999999,99 9999999,99 99999999,99  Baixado
99/99/9999                999999.99 9999999,99 9999999,99 99999999,99  Baixado

*/


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fImpPortal� Autor � Emerson Campos        � Data � 28/05/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o Extrato de Banco de Horas para o padr�o do Portal���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � WSPON010                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fImpPortal( )
                                               
Local cHtml		:= ""
Local nX        := 0
Local nDet	  	:= 0

//-- O valor inicial do Saldo passa a ser do Saldo Anterior ao Periodo Solicitado
nSaldo := nSaldoAnt

cHtml +=	'<?xml version="1.0" encoding="iso-8859-1"?>'  + CRLF
cHtml +=	'<!doctype html public "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'  + CRLF
cHtml +=	'<html xmlns="http://www.w3.org/1999/xhtml">'  + CRLF
cHtml +=	'<head>'  + CRLF
cHtml +=	'<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'  + CRLF
cHtml +=	'<script src="scripts/prototype.js" language="JavaScript" type="text/javascript"></script>'  + CRLF
cHtml +=	'<script src="scripts/scriptaculous.js" language="JavaScript" type="text/javascript"></script>'  + CRLF
cHtml +=	'<link href="styles/estilo.css" rel="stylesheet" type="text/css">'  + CRLF 
cHtml +=	'<link href="styles/consulta.css" rel="stylesheet" type="text/css">'  + CRLF
cHtml +=	'<title>Untitled Document</title>'  + CRLF
cHtml +=	'<style type="text/css">'  + CRLF
cHtml +=	'<!--'  + CRLF
cHtml +=	'.TitleEmployee, .ValueEmployee {'  + CRLF
cHtml +=	'	float: left;'  + CRLF
cHtml +=	'}'  + CRLF
cHtml +=	'.TitleEmployee {'  + CRLF
cHtml +=	'	width: 100px;'  + CRLF
cHtml +=	'	text-align: right;'  + CRLF
cHtml +=	'	padding-right: 5px;'  + CRLF
cHtml +=	'}'  + CRLF
cHtml +=	'.ValueEmployee {'  + CRLF
cHtml +=	'	padding-top: 1px;'  + CRLF
cHtml +=	'}'  + CRLF
cHtml +=	'.RowEmployee {'  + CRLF
cHtml +=	'	display: block;'  + CRLF
cHtml +=	'	clear: both;'  + CRLF
cHtml +=	'	height: 25px;'  + CRLF
cHtml +=	'}'  + CRLF
cHtml +=	'-->'  + CRLF
cHtml +=	'</style>'  + CRLF
cHtml +=	'</head>'  + CRLF
cHtml += 	'<body>'  + CRLF
cHtml += 	'<h3>'+STR0036+'</h3><!--Lista do Banco de Horas-->'  + CRLF
cHtml +=	'	<table width="800">'  + CRLF
cHtml +=	'		<tr>'  + CRLF
cHtml +=	'			<th>'  + CRLF
cHtml +=	'					'+STR0025+' <!-- Data -->'  + CRLF
cHtml +=	'			</th>'  + CRLF
cHtml +=	'			<th>'  + CRLF
cHtml +=	'		   			'+STR0026+' <!-- Evento -->'  + CRLF
cHtml +=	'			</th>'  + CRLF
cHtml +=	'  			<th>'  + CRLF
cHtml +=	'					'+STR0027+' <!-- D�bito -->'  + CRLF
cHtml +=	'			</th>'  + CRLF
cHtml +=	'			<th>'  + CRLF
cHtml +=	'					'+STR0037+' <!-- D�bt.Valorizado -->'  + CRLF
cHtml +=	'			</th>'  + CRLF
cHtml +=	'			<th>'  + CRLF
cHtml +=	'					'+STR0028+' <!-- Credito -->'  + CRLF
cHtml +=	'			</th>'  + CRLF
cHtml +=	'			<th>'  + CRLF
cHtml +=	'					'+STR0038+' <!-- Cr�d.Valorizado -->'  + CRLF
cHtml +=	'			</th>'  + CRLF
cHtml +=	'			<th>'  + CRLF
cHtml +=	'					'+STR0029+' <!-- Saldo -->'  + CRLF
cHtml +=	'			</th>'  + CRLF
cHtml +=	'			<th>'  + CRLF
cHtml +=	'					'+STR0039+' <!-- Sal.Valorizado -->'  + CRLF
cHtml +=	'			</th>'  + CRLF
cHtml +=	'			<th>'  + CRLF
cHtml +=	'					'+STR0030+' <!-- Status -->'  + CRLF
cHtml +=	'			</th>'  + CRLF
cHtml +=	'		</tr>'  + CRLF

If Len(aDet) > 0
	nDet := Len(aDet)
	For nX := 1 To nDet
		If nX > 1
			nSaldo := Val(aDet[nX-1,6])
		EndIf
		cHtml +=	'		<tr>'  + CRLF
		cHtml +=	'			<td class="info-cent">'  + CRLF
		cHtml +=					aDet[nX,1] + CRLF
		cHtml +=	'			</td>'  + CRLF
		cHtml +=	'			<td class="info-cent">'  + CRLF
		cHtml +=					aDet[nX,2] + " - " + Capital( AllTrim( aDet[nX,3] ) ) + CRLF
		cHtml +=	'			</td>'  + CRLF
		cHtml +=	'			<td class="info-cent">'  + CRLF
		cHtml +=					aDet[nX,4] + CRLF
		cHtml +=	'			</td>'  + CRLF
		cHtml +=	'			<td class="info-cent">'  + CRLF
		cHtml +=					aValoriz[nX][1] + CRLF
		cHtml +=	'			</td>'  + CRLF
		cHtml +=	'			<td class="info-cent">'  + CRLF
		cHtml +=					aDet[nX,5] + CRLF
		cHtml +=	'			</td>'  + CRLF
		cHtml +=	'			<td class="info-cent">'  + CRLF
		cHtml +=					aValoriz[nX][2] + CRLF
		cHtml +=	'			</td>'  + CRLF
		cHtml +=	'			<td class="info-cent">'  + CRLF
		cHtml +=					aDet[nX,6] + CRLF
		cHtml +=	'			</td>'  + CRLF
		cHtml +=	'			<td class="info-cent">'  + CRLF
		cHtml +=					aValoriz[nX][3] + CRLF
		cHtml +=	'			</td>'  + CRLF
		cHtml +=	'			<td class="info-cent">'  + CRLF
		cHtml +=					aDet[nX,7] + CRLF
		cHtml +=	'			</td>'  + CRLF
		cHtml +=	'		</tr>'  + CRLF		
	Next nX 
cHtml += 	'			</table>'  + CRLF
cHtml += 	'			<p>&nbsp;</p>'  + CRLF
cHtml += 	'			<a href="W_PWSA300.APW" class="links"><input class="botoes" type="button" value="'+STR0035+'" name="Voltar"></a>'  + CRLF
cHtml += 	'			<input class="botoes" type="button" value="'+STR0034+'" name="Imprimir" onClick="javascript:self.print()" >&nbsp;&nbsp;&nbsp;&nbsp;'  + CRLF
Else
cHtml += 	'				<tr><td colspan="6" class="info-cent">'+STR0033+'</td></tr> <!-- N�o h� lan�amentos no banco de horas. -->'  + CRLF
cHtml += 	'	</table>'  + CRLF
cHtml += 	'		<a href="W_PWSA300.APW" class="links"><input class="botoes" type="button" value="'+STR0035+'" name="Voltar"></a>'  + CRLF
EndIf
cHtml += 	'</body>'  + CRLF
cHtml += 	'</html>'  + CRLF

	
Return( cHtml )
