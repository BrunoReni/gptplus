// 浜様様様曜様様様様�
// � Versao � 14     �
// 藩様様様擁様様様様�

#include "Protheus.ch"
#include "OFIOR240.CH"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � OFIOR240 � Autor � Eveli Morasco         � Data � 25/02/93 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Saldos em Estoques                                         咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � Generico                                                   咳�
臼団陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     咳�
臼団陳陳陳陳陳陳賃陳陳陳陳堕陳陳賃陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   咳�
臼団陳陳陳陳陳陳津陳陳陳陳田陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Rodrigo Sart.�07/08/98�16964A�Acerto na filtragem dos almoxarifados   咳�
臼� Fernando Joly�23/10/98�15013A�Acerto na filtragem de Filiais          咳�
臼� Fernando Joly�03/12/98�XXXXXX�S� imprimir "Total do Produto" quando   咳�
臼�              �        �      �houver mais de 1 produto.               咳�
臼� Fernando Joly�21/12/98�18920A�Possibilitar filtragem pelo usuario.    咳�
臼� Cesar Valadao�30/03/99�XXXXXX�Manutencao na SetPrint()                咳�
臼� Aline        �27/04/99�21147 �Considerar o NewHead do Titulo          咳�
臼� Cesar Valadao�28/04/99�17188A�Inclusao da Pergunta - Descricao Produto咳�
臼�              �        �      �Descricao Cientifica ou Generica.       咳�
臼� Cesar Valadao�08/12/99�25510A�Erro na Totalizacao de Produto Por      咳�
臼�              �        �      �Almoxarifado com Saldo Zerado.          咳�
臼� Patricia Sal.�11/07/00�005086�Acerto Salto de linha (P/ Almoxarifado) 咳�
臼青陳陳陳陳陳陳珍陳陳陳陳祖陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�*/
Function OFIOR240

Local oReport
               
Private nSizFil := 0
Private cStr    := ""
Private aReturn := {(STR0008), 1,(STR0009), 2, 2, 1, '',1 } // 'Zebrado'###'Administracao'

If !(FindFunction("TRepInUse") .And. TRepInUse())
	Return OR240R3() // Executa vers�o anterior do fonte
Else
	Pergunte('OFR240',.F.)
	oReport := ReportDef()
	oReport:PrintDialog()
Endif

Return


/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � ReportDef� Autor � ANDRE                 � Data � 23/02/06 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Relatorio usando o TReport                                 咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function ReportDef()

Local oReport
Local oSection1
Local oCell

oReport := TReport():New("OFIOR240",(STR0015),"OFR240",{|oReport| OR240Imp(oReport)}) //Saldos em Estoques

oSection1 := TRSection():New(oReport,STR0019,{"SB1","SB2"})
TRCell():New(oSection1,"",,"","@!",220,, {|| cStr } )

Return oReport

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OR240Imp � Autor � ANDRE                 � Data � 23/02/06 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Executa a impressao do relatorio do TReport                咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OR240Imp(oReport)

Local oSection1 := oReport:Section(1)

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Define Variaveis                                             �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰

Local cRodaTxt   := 'REG(S)'
Local nCntImpr   := 0
Local nTipo      := 0
Local aOrd       := {(STR0004),(STR0005),(STR0006),(STR0007)} // ' Por Codigo         '###' Por Tipo           '###' Por Descricao    '###' Por Grupo        '

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Variaveis locais exclusivas deste programa                   �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
Local lImpr      :=.F.
Local nSoma      := 0
Local nSavRec    := 0
Local nTotSoma   := 0
Local nX         := 0
Local nRegM0     := 0
Local nIndB1     := 0
Local nIndB2     := 0
Local nQtdProd   := 0
Local aSalProd   := {}
Local cFilialDe  := ''
Local cQuebra1   := ''
Local cCampo     := ''
Local cMens      := ''
Local aProd      := {}
Local aProd1     := {}
Local aProd2     := {}
Local aProd3     := {}
Local cFilOld    := '��'
Local cCodAnt    := '��'
Local cDesc
Local lIsCient
Local cPict      := "@E 9,999,999.99"

//
Local cGruVei    := PadR(AllTrim(GetNewPar("MV_GRUVEI","VEIC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local cGruSrv    := PadR(AllTrim(GetNewPar("MV_GRUSRV","SRVC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Servico
//

oReport:SetMeter(RecCount())
oSection1:Init(.f.)
oReport:SetMeter(SE1->(RecCount()))

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Variaveis Private exclusivas deste programa                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
Private cQuebra2   := ''
Private cCond2     := ''
Private cFiltroB1  := ''
Private cIndB1     := ''
Private aFilAtu        := FWArrFilAtu() // carrega os dados da Filial logada ( Grupo de Empresa / Empresa / Filial ) 
Private aFiliais       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Levanta todas as Filiais da Empresa logada (vetor utilizado no FOR das Filiais)
Private nCont          := 0
Private cBkpFilAnt := cFilAnt // salvar cFilAnt
Private cFiltroB2  := ''
Private cIndB2     := ''
Private lContinua  := .T.
Private cNomArqB1  := ''
Private cNomArqB2  := ''

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Contadores de linha e pagina                                 �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
Private Li         := 80
Private m_pag      := 1

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
//� Inicializa os codigos de caracter Comprimido/Normal da impressora �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
nTipo := iif(aReturn[4]==1,15,18)

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Adiciona a ordem escolhida ao Titulo do relatorio          �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
If Type('NewHead') # 'U'
	NewHead := AllTrim(NewHead)
	NewHead += ' (' + AllTrim(SubStr(aOrd[aReturn[8]],6,20)) + ')'
Else
	Titulo := STR0015 //AllTrim("Saldos em Estoques")
	Titulo += ' (' + AllTrim(SubStr(aOrd[aReturn[8]],6,20)) + ')'
EndIf

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Monta os Cabecalhos                                          �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
cCabec1 := (STR0010) // 'CODIGO          TP GRUP DESCRICAO                      UM FL ALM      QUANTIDADE'
cCabec2 := ''
//-- 123456789012345 12 1234 123456789012345678901234567890 12 12 12 999,999,999.99
//-- 0         1         2         3         4         5         6         7
//-- 012345678901234567890123456789012345678901234567890123456789012345678901234567890


//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Processos de Inicia��o dos Arquivos Utilizados               �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰

//-- SB2 (Saldos em Estoque)
dbSelectArea('SB2')
dbSetOrder(1)

cFiltroB2 := 'B2_COD>="'+mv_par06+'".And.B2_COD<="'+mv_par07+'".And.'
cFiltroB2 += 'B2_LOCAL>="'+mv_par04+'".And.B2_LOCAL<="'+mv_par05+'"'
If !Empty(xFilial('SB2'))
	cFiltroB2 += '.And.B2_FILIAL>="'+mv_par02+'".And.B2_FILIAL<="'+mv_par03+'"'
EndIf

Pergunte('OFR240',.F.)
If mv_par01 == 3
	cIndB2 := 'B2_COD + B2_FILIAL + B2_LOCAL'
ElseIf mv_par01 == 2
	cIndB2 := 'B2_FILIAL + B2_COD + B2_LOCAL'
Else
	cIndB2 := 'B2_COD + B2_FILIAL + B2_LOCAL'
EndIf

cNomArqB2 := Left(CriaTrab('',.F.),7) + 'a'

IndRegua('SB2',cNomArqB2,cIndB2,,cFiltroB2,STR0017)  //Selecionando Registros...
nIndB2 := RetIndex('SB2')
#IFNDEF TOP
	dbSetIndex(cNomArqB2 + OrdBagExt())
#ENDIF
dbSetOrder(nIndB2 + 1)
dbGoTop()

//-- SB1 (Produtos)
dbSelectArea('SB1')
dbSetOrder(aReturn[8])

cFiltroB1 := 'B1_COD>="'+mv_par06+'".And.B1_COD<="'+mv_par07+'".And.'
cFiltroB1 += 'B1_TIPO>="'+mv_par08+'".And.B1_TIPO<="'+mv_par09+'".And.'
cFiltroB1 += 'B1_GRUPO>="'+mv_par10+'".And.B1_GRUPO<="'+mv_par11+'"'
If !Empty(xFilial('SB1'))
	cFiltroB1 += '.And.B1_FILIAL>="'+mv_par02+'".And.B1_FILIAL<="'+mv_par03+'"'
EndIf

If aReturn[8] == 4
	cIndB1 := 'B1_GRUPO+B1_COD+B1_FILIAL'
	cCampo := 'B1_GRUPO'
	cMens  := (STR0012) // 'Grupo.........'
ElseIf aReturn[8] == 3
	cIndB1 := 'B1_DESC+B1_COD+B1_FILIAL'
	cCampo := .T.
ElseIf aReturn[8] == 2
	cIndB1 := 'B1_TIPO+B1_COD+B1_FILIAL'
	cCampo := 'B1_TIPO'
	cMens  := (STR0011) // 'Tipo..........'
Else
	cIndB1 := 'B1_COD+B1_FILIAL'
	cCampo := .T.
Endif

cNomArqB1 := Left(CriaTrab('',.F.),7) + 'b'

IndRegua('SB1',cNomArqB1,cIndB1,,cFiltroB1,STR0017) //Selecionando Registros...
nIndB1 := RetIndex('SB1')
#IFNDEF TOP
	dbSetIndex(cNomArqB1 + OrdBagExt())
#ENDIF
dbSetOrder(nIndB1 + 1)
dbGoTop()

cFilialDe := iif(Empty(xFilial('SB2')),xFilial('SB2'),mv_par02)

If aReturn[8] == 4
	dbSeek(mv_par10, .T.)
ElseIf aReturn[8] == 3
	//-- Pesquisa Somente se a Descricao For Generica.
	If mv_par17 == 2
		dbSeek(mv_par12, .T.)
	Endif
ElseIf aReturn[8] == 2
	dbSeek(mv_par08, .T.)
Else
	dbSeek(mv_par06, .T.)
Endif

//-- 1� Looping no Arquivo Principal (SB1)

cStr :=(STR0010)
oSection1:PrintLine()
cStr :=""
oSection1:PrintLine()
Do While !SB1->(Eof()) .and. lContinua
	
	// Desconsiderar VEICULOS e SERVICOS
	If SB1->B1_GRUPO == cGruVei .or. SB1->B1_GRUPO == cGruSrv
		SB1->(dbSkip())
		Loop
	EndIf

	aProd  := {}
	aProd1 := {}
	
	//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
	//� Verifica se imprime nome cientifico do produto. Se Sim    �
	//� verifica se existe registro no SB5 e se nao esta vazio    �
	//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
	cDesc := SB1->B1_DESC
	lIsCient := .F.
	If mv_par17 == 1
		dbSelectArea("SB5")
		dbSeek(xFilial()+SB1->B1_COD)
		If Found() .and. !Empty(B5_CEME)
			cDesc := B5_CEME
			lIsCient := .T.
		EndIf
		dbSelectArea('SB1')
	Endif
	
	//-- Consiste Descri��o De/At�
	If cDesc < mv_par12 .Or. cDesc > mv_par13
		SB1->(dbSkip())
		Loop
	EndIf
	
	//-- Filtro do usuario
	If !Empty(aReturn[7]) .And. !&(aReturn[7])
		SB1->(dbSkip())
		Loop
	EndIf
	
	cQuebra1 := iif(aReturn[8]==1.Or.aReturn[8]==3,.T.,&(cCampo))
	
	//-- 2� Looping no Arquivo Principal (SB1)
	Do While !SB1->(Eof()) .And. (cQuebra1 == Iif(aReturn[8]==1.Or.aReturn[8]==3,.T.,&(cCampo))) .And. lContinua
		
		// Desconsiderar VEICULOS e SERVICOS
		If SB1->B1_GRUPO == cGruVei .or. SB1->B1_GRUPO == cGruSrv
			SB1->(dbSkip())
			Loop
		EndIf

		lImpr := .F.
		
		//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
		//� Verifica se imprime nome cientifico do produto. Se Sim    �
		//� verifica se existe registro no SB5 e se nao esta vazio    �
		//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
		cDesc := SB1->B1_DESC
		lIsCient := .F.
		If mv_par17 == 1
			dbSelectArea("SB5")
			dbSeek(xFilial()+SB1->B1_COD)
			If Found() .and. !Empty(B5_CEME)
				cDesc := B5_CEME
				lIsCient := .T.
			EndIf
			dbSelectArea('SB1')
		Endif
		
		//-- Consiste Descri��o De/At�
		If cDesc < mv_par12 .Or. cDesc > mv_par13
			SB1->(dbSkip())
			Loop
		EndIf
		
		//-- Filtro do usuario
		If !Empty(aReturn[7]) .And. !&(aReturn[7])
			SB1->(dbSkip())
			Loop
		EndIf
		
		For nX := 1 to Len(aFiliais)
			cFilAnt := aFiliais[nX]
			
			IF !lContinua
				Exit
			Endif
			
			//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
			//� Localiza produto no Cadastro de ACUMULADOS DO ESTOQUE        �
			//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
			dbSelectArea('SB2')
			If mv_par01 == 3
				dbSeek(SB1->B1_COD + xFilial('SB2'), .T.)
			ElseIf mv_par01 == 2
				dbSeek(xFilial('SB2') + SB1->B1_COD, .T.)
			Else
				dbSeek(SB1->B1_COD + xFilial('SB2') + mv_par04, .T.)
			EndIf
			
			//-- 1� Looping no Arquivo Secund�rio (SB2)
			Do While lContinua .And. !SB2->(Eof()) .And. xFilial("SB2") == B2_FILIAL .AND. B2_COD == SB1->B1_COD
				
				If mv_par01 == 3
					If Empty(xFilial('SB1'))
						cQuebra2  := B2_COD
						cCond2	 := 'B2_COD == cQuebra2'
					Else
						cQuebra2  := B2_COD + B2_FILIAL
						cCond2	 := 'B2_COD + B2_FILIAL == cQuebra2'
					EndIf
				ElseIf mv_par01 == 2
					cQuebra2 := B2_FILIAL + B2_COD
					cCond2   := 'B2_FILIAL + B2_COD == cQuebra2'
				Else
					cQuebra2 := B2_COD + B2_FILIAL + B2_LOCAL
					cCond2   := 'B2_COD + B2_FILIAL + B2_LOCAL == cQuebra2'
				EndIf
				
				//-- N�o deixa o mesmo Filial/Produto passar mais de 1 vez
				If Len(aProd) <= 4096
					If Len(aProd) == 0 .Or. Len(aProd[Len(aProd)]) == 4096
						aAdd(aProd, {})
					EndIf
					If aScan(aProd[Len(aProd)], cQuebra2) > 0
						SB2->(dbSkip())
						Loop
					Else
						aAdd(aProd[Len(aProd)], cQuebra2)
					EndIf
				Else
					If Len(aProd1) == 0 .Or. Len(aProd1[Len(aProd1)]) == 4096
						aAdd(aProd1, {})
					EndIf
					If aScan(aProd1[Len(aProd1)], cQuebra2) > 0
						SB2->(dbSkip())
						Loop
					Else
						aAdd(aProd1[Len(aProd1)], cQuebra2)
					EndIf
				EndIf
				
				//-- 2� Looping no Arquivo Secund�rio (SB2)
				Do While lContinua .And. !SB2->(Eof()) .And. &(cCond2)
					
					If aReturn[8] == 2 //-- Tipo
						If SB1->B1_TIPO # fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_TIPO')
							SB2->(dbSkip())
							Loop
						EndIf
					ElseIf aReturn[8] == 4 //-- Grupo
						If SB1->B1_GRUPO # fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_GRUPO')
							SB2->(dbSkip())
							Loop
						EndIf
					EndIf
					
					//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
					//� Carrega array com dados do produto na data base.             �
					//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
					IF mv_par15 > 2
						//-- Verifica se o SM0 esta posicionado na Filial Correta
						If !Empty(SB2->B2_FILIAL) .And. !(cFilAnt==SB2->B2_FILIAL)
							aSalProd := {0,0,0,0,0,0,0}
						Else
							aSalProd := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,dDataBase+1)
						EndIf
					Else
						aSalProd := {0,0,0,0,0,0,0}
					Endif
					
					//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
					//� Verifica se devera ser impressa o produto zerado             �
					//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
					If Iif(mv_par15==1,B2_QATU,Iif(mv_par15==2,B2_QFIM,aSalProd[1])) == 0 .And. mv_par14 == 2 .Or. ;
						Iif(mv_par15==1,B2_QATU,Iif(mv_par15==2,B2_QFIM,aSalProd[1])) > 0  .And. mv_par16 == 1
						cCodAnt := SB2->B2_COD
						SB2->(dbSkip())
						If mv_par01 == 1 .And. SB2->B2_COD # cCodAnt
							If nQtdProd > 1
								lImpr := .T.
							Else
								nSoma    := 0
								nQtdProd := 0
							EndIf
						EndIf
						Loop
					EndIf
					
					lImpr := .T.
					
					//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
					//� Adiciona 1 ao contador de registros impressos         �
					//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
					If mv_par01 == 1 
					    nSizFil := 12-FWSizeFilial()
						cStr := left(fContSB1(cFilOld, SB2->B2_COD, 'B1_GRUPO')+space(4),4)+" "+;
						left(fContSB1(cFilOld, SB2->B2_COD, 'B1_CODITE')+space(27),27)+" "+;
						left(SB2->B2_COD+space(15),15)+" "+;
						left(fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_TIPO')+space(2),2)+" "+;
						Left(Iif(lIsCient, cDesc,	fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_DESC')),17)+" "+;
						fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_UM')+" "+B2_FILIAL+space(nSizFil)+" "+B2_LOCAL+"   "+Transform( iif(mv_par15==1,B2_QATU,iif(mv_par15==2,B2_QFIM,aSalProd[1])), cPict)
						nQtdProd ++
						oSection1:PrintLine()
					EndIf
					
					nSoma += iif(mv_par15==1,B2_QATU,iif(mv_par15==2,B2_QFIM,aSalProd[1]))
					nTotSoma += iif(mv_par15==1,B2_QATU,iif(mv_par15==2,B2_QFIM,aSalProd[1]))
					
					cFilOld := SB2->B2_FILIAL
					cCodAnt := SB2->B2_COD
					
					SB2->(dbSkip())
					
				EndDo
				
				If lImpr
					
					If mv_par01 == 1
						If SB2->B2_COD # cCodAnt .And. ;
							(aReturn[8] # 2 .And. aReturn[8] # 4)
							If nQtdProd > 1
								cStr := (STR0014) + Space(1) + AllTrim(Left(cCodAnt,15)) + Space(1) + Replicate('.',21-Len(AllTrim(Left(cCodAnt,15))))+" "+; // 'Total do Produto'
								Transform(nSoma, cPict)
								oSection1:PrintLine()
								cStr :=""
								oSection1:PrintLine()
							EndIf
							nSoma    := 0
							nQtdProd := 0
						EndIf
					Else    
					    nSizFil := 12-FWSizeFilial()
						cStr := fContSB1(cFilOld, cCodAnt, 'B1_GRUPO')+" "+fContSB1(cFilOld, cCodAnt, 'B1_CODITE')+" "+;
						Left(cCodAnt+space(15),15)+" "+fContSB1(cFilOld, cCodAnt, 'B1_TIPO')+" "+Left(Iif(lIsCient, cDesc,	fContSB1(cFilOld, cCodAnt, 'B1_DESC')),17)+" "+;
						fContSB1(cFilOld, cCodAnt, 'B1_UM')+" "+Iif(mv_par01==2,cFilOld+space(nSizFil),Repl("*",FWSizeFilial())+space(nSizFil))+" **"+Transform(nSoma, cPict)
						nSoma := 0
						oSection1:PrintLine()
						
					EndIf
					
					lImpr := .F.
					
				EndIf
			EndDo
			
		Next nX
		cFilAnt := cBkpFilAnt
		
		dbSelectArea('SB1')
		SB1->(dbSkip())
		
	EndDo
	
	If (aReturn[8] == 2 .Or. aReturn[8] == 4) .And. ;
		nTotSoma # 0
		cStr := STR0018 + cMens+" "+Transform(nTotSoma, cPict)
		oSection1:PrintLine()
		nTotSoma := 0
	EndIf
	
EndDo

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Devolve as ordens originais dos arquivos                     �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
RetIndex('SB2')
Set Filter to

RetIndex('SB1')
Set Filter to

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Apaga indices de trabalho                                    �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
If File(cNomArqB2 += OrdBagExt())
	fErase(cNomArqB2)
EndIf
If File(cNomArqB1 += OrdBagExt())
	fErase(cNomArqB1)
EndIf

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Devolve a condicao original dos arquivos principal           �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
dbSelectArea('SB1')
Set Filter To
dbSetOrder(1)

dbSelectArea('SB2')
Set Filter To
dbSetOrder(1)

oSection1:Finish()

Return Nil


/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳賃陳陳陳堕陳陳陳陳朕臼
臼�Fun��o    � OR240R3  � Autor �  Thiago        � Data � 21/06/02 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳珍陳陳陳祖陳陳陳陳調臼
臼�Descri�ao � Demonstrativo de Metas de Vendas                    |臼
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Function OR240R3()

Local Tamanho    := 'G'
Local Titulo     := STR0001 // 'Saldos em Estoque'
Local cDesc1     := STR0002 // "Este programa ira' emitir um resumo dos saldos, em quantidade,"
Local cDesc2     := STR0003 // 'dos produtos em estoque.'
Local cDesc3     := ''
Local cString    := 'SB1'
Local aOrd       := {(STR0004),(STR0005),(STR0006),(STR0007)} // ' Por Codigo         '###' Por Tipo           '###' Por Descricao    '###' Por Grupo        '
Local WnRel      := 'OFIOR240'
Local limite       := 220

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Variaveis tipo Private padrao de todos os relatorios         �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
Private aReturn    := {(STR0008), 1,(STR0009), 2, 2, 1, '',1 } // 'Zebrado'###'Administracao'
Private nLastKey   := 0
Private cPerg      := 'OFR240'

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Verifica as perguntas selecionadas                           �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
//� Variaveis utilizadas para parametros                                  �
//� mv_par01     // Aglutina por: Almoxarifado / Filial / Empresa         �
//� mv_par02     // Filial de                                             �
//� mv_par03     // Filial ate                                            �
//� mv_par04     // Almoxarifado de                                       �
//� mv_par05     // Almoxarifado ate                                      �
//� mv_par06     // Produto de                                            �
//� mv_par07     // Produto ate                                           �
//� mv_par08     // tipo de                                               �
//� mv_par09     // tipo ate                                              �
//� mv_par10     // grupo de                                              �
//� mv_par11     // grupo ate                                             �
//� mv_par12     // descricao de                                          �
//� mv_par13     // descricao ate                                         �
//� mv_par14     // imprime qtde zeradas                                  �
//� mv_par15     // Saldo a considerar : Atual / Fechamento / Movimento   �
//� mv_par16     // Lista Somente Saldos Negativos                 		  �
//� mv_par17     // Descricao Produto : Cientifica / Generica      		  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
Pergunte(cPerg,.F.)

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Envia controle para a funcao SETPRINT                        �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
WnRel := SetPrint(cString,WnRel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey == 27
	Set Filter to
	Return Nil
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return Nil
Endif

RptStatus({|lEnd| C240Imp(aOrd,@lEnd,WnRel,Titulo,Tamanho)},Titulo)

Return Nil

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � C240IMP  � Autor � Rodrigo de A. Sartorio� Data � 11.12.95 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Chamada do Relatorio                                       咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � OFIOR240													  咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�*/
Static Function C240Imp(aOrd,lEnd,WnRel,Titulo,Tamanho)

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Define Variaveis                                             �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰

Local cRodaTxt   := 'REG(S)'
Local nCntImpr   := 0
Local nTipo      := 0

//
Local cGruVei    := PadR(AllTrim(GetNewPar("MV_GRUVEI","VEIC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local cGruSrv    := PadR(AllTrim(GetNewPar("MV_GRUSRV","SRVC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Servico
//

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Variaveis locais exclusivas deste programa                   �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
Local lImpr      :=.F.
Local nSoma      := 0
Local nSavRec    := 0
Local nTotSoma   := 0
Local nX         := 0
Local nRegM0     := 0
Local nIndB1     := 0
Local nIndB2     := 0
Local nQtdProd   := 0
Local aSalProd   := {}
Local cFilialDe  := ''
Local cQuebra1   := ''
Local cCampo     := ''
Local cMens      := ''
Local aProd      := {}
Local aProd1     := {}
Local aProd2     := {}
Local aProd3     := {}
Local cFilOld    := '��'
Local cCodAnt    := '��'
Local cDesc
Local lIsCient
Local cPict
// Fernando 09/11/99
If ( cPaisLoc=="CHI" )
	cPict:= "@E 999,999,999,999.99"
Else
	cPict:= PesqPictQt(Iif(mv_par15==1,'B2_QATU','B2_QFIM'),16)
Endif

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Variaveis Private exclusivas deste programa                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
Private cQuebra2   := ''
Private cCond2     := ''
Private cFiltroB1  := ''
Private cIndB1     := ''
Private aFilAtu        := FWArrFilAtu() // carrega os dados da Filial logada ( Grupo de Empresa / Empresa / Filial ) 
Private aFiliais       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Levanta todas as Filiais da Empresa logada (vetor utilizado no FOR das Filiais)
Private nCont          := 0
Private cBkpFilAnt := cFilAnt // salvar cFilAnt
Private cFiltroB2  := ''
Private cIndB2     := ''
Private lContinua  := .T.
Private cNomArqB1  := ''
Private cNomArqB2  := ''                              �



//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Contadores de linha e pagina                                 �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
Private Li         := 80
Private m_pag      := 1

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
//� Inicializa os codigos de caracter Comprimido/Normal da impressora �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
nTipo := Iif(aReturn[4]==1,15,18)

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Adiciona a ordem escolhida ao Titulo do relatorio          �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
If Type('NewHead') # 'U'
	NewHead := AllTrim(NewHead)
	NewHead += ' (' + AllTrim(SubStr(aOrd[aReturn[8]],6,20)) + ')'
Else
	Titulo := AllTrim(Titulo)
	Titulo += ' (' + AllTrim(SubStr(aOrd[aReturn[8]],6,20)) + ')'
EndIf

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Monta os Cabecalhos                                          �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
cCabec1 := (STR0010) // 'CODIGO          TP GRUP DESCRICAO                      UM FL ALM      QUANTIDADE'
cCabec2 := ''
//-- 123456789012345 12 1234 123456789012345678901234567890 12 12 12 999,999,999.99
//-- 0         1         2         3         4         5         6         7
//-- 012345678901234567890123456789012345678901234567890123456789012345678901234567890

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Processos de Inicia��o dos Arquivos Utilizados               �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰

//-- SB2 (Saldos em Estoque)
dbSelectArea('SB2')
dbSetOrder(1)

cFiltroB2 := 'B2_COD>="'+mv_par06+'".And.B2_COD<="'+mv_par07+'".And.'
cFiltroB2 += 'B2_LOCAL>="'+mv_par04+'".And.B2_LOCAL<="'+mv_par05+'"'
If !Empty(xFilial('SB2'))
	cFiltroB2 += '.And.B2_FILIAL>="'+mv_par02+'".And.B2_FILIAL<="'+mv_par03+'"'
EndIf

If mv_par01 == 3
	cIndB2 := 'B2_COD + B2_FILIAL + B2_LOCAL'
ElseIf mv_par01 == 2
	cIndB2 := 'B2_FILIAL + B2_COD + B2_LOCAL'
Else
	cIndB2 := 'B2_COD + B2_FILIAL + B2_LOCAL'
EndIf

cNomArqB2 := Left(CriaTrab('',.F.),7) + 'a'

IndRegua('SB2',cNomArqB2,cIndB2,,cFiltroB2,STR0017) //Selecionando Registros...
nIndB2 := RetIndex('SB2')
#IFNDEF TOP
	dbSetIndex(cNomArqB2 + OrdBagExt())
#ENDIF
dbSetOrder(nIndB2 + 1)
dbGoTop()

//-- SB1 (Produtos)
dbSelectArea('SB1')
dbSetOrder(aReturn[8])

cFiltroB1 := 'B1_COD>="'+mv_par06+'".And.B1_COD<="'+mv_par07+'".And.'
cFiltroB1 += 'B1_TIPO>="'+mv_par08+'".And.B1_TIPO<="'+mv_par09+'".And.'
cFiltroB1 += 'B1_GRUPO>="'+mv_par10+'".And.B1_GRUPO<="'+mv_par11+'"'
If !Empty(xFilial('SB1'))
	cFiltroB1 += '.And.B1_FILIAL>="'+mv_par02+'".And.B1_FILIAL<="'+mv_par03+'"'
EndIf

If aReturn[8] == 4
	cIndB1 := 'B1_GRUPO+B1_COD+B1_FILIAL'
	cCampo := 'B1_GRUPO'
	cMens  := (STR0012) // 'Grupo.........'
ElseIf aReturn[8] == 3
	cIndB1 := 'B1_DESC+B1_COD+B1_FILIAL'
	cCampo := .T.
ElseIf aReturn[8] == 2
	cIndB1 := 'B1_TIPO+B1_COD+B1_FILIAL'
	cCampo := 'B1_TIPO'
	cMens  := (STR0011) // 'Tipo..........'
Else
	cIndB1 := 'B1_COD+B1_FILIAL'
	cCampo := .T.
Endif

cNomArqB1 := Left(CriaTrab('',.F.),7) + 'b'

IndRegua('SB1',cNomArqB1,cIndB1,,cFiltroB1,STR0017) //Selecionando Registros...
nIndB1 := RetIndex('SB1')
#IFNDEF TOP
	dbSetIndex(cNomArqB1 + OrdBagExt())
#ENDIF
dbSetOrder(nIndB1 + 1)
dbGoTop()

SetRegua(LastRec())

cFilialDe := Iif(Empty(xFilial('SB2')),xFilial('SB2'),mv_par02)

If aReturn[8] == 4
	dbSeek(mv_par10, .T.)
ElseIf aReturn[8] == 3
	//-- Pesquisa Somente se a Descricao For Generica.
	If mv_par17 == 2
		dbSeek(mv_par12, .T.)
	Endif
ElseIf aReturn[8] == 2
	dbSeek(mv_par08, .T.)
Else
	dbSeek(mv_par06, .T.)
Endif

//-- 1� Looping no Arquivo Principal (SB1)
Do While !SB1->(Eof()) .and. lContinua
	
	// Desconsiderar VEICULOS e SERVICOS
	If SB1->B1_GRUPO == cGruVei .or. SB1->B1_GRUPO == cGruSrv
		SB1->(dbSkip())
		Loop
	EndIf

	aProd  := {}
	aProd1 := {}
	
	//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
	//� Verifica se imprime nome cientifico do produto. Se Sim    �
	//� verifica se existe registro no SB5 e se nao esta vazio    �
	//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
	cDesc := SB1->B1_DESC
	lIsCient := .F.
	If mv_par17 == 1
		dbSelectArea("SB5")
		dbSeek(xFilial()+SB1->B1_COD)
		If Found() .and. !Empty(B5_CEME)
			cDesc := B5_CEME
			lIsCient := .T.
		EndIf
		dbSelectArea('SB1')
	Endif
	
	//-- Consiste Descri��o De/At�
	If cDesc < mv_par12 .Or. cDesc > mv_par13
		SB1->(dbSkip())
		Loop
	EndIf
	
	//-- Filtro do usuario
	If !Empty(aReturn[7]) .And. !&(aReturn[7])
		SB1->(dbSkip())
		Loop
	EndIf
	
	If lEnd
		@ PROW()+1, 001 pSay (STR0013) // 'CANCELADO PELO OPERADOR'
		Exit
	EndIf
	
	cQuebra1 := Iif(aReturn[8]==1.Or.aReturn[8]==3,.T.,&(cCampo))
	
	//-- 2� Looping no Arquivo Principal (SB1)
	Do While !SB1->(Eof()) .And. (cQuebra1 == Iif(aReturn[8]==1.Or.aReturn[8]==3,.T.,&(cCampo))) .And. lContinua
		
		// Desconsiderar VEICULOS e SERVICOS
		If SB1->B1_GRUPO == cGruVei .or. SB1->B1_GRUPO == cGruSrv
			SB1->(dbSkip())
			Loop
		EndIf

		//-- Incrementa R�gua
		IncRegua()
		
		lImpr := .F.
		
		//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
		//� Verifica se imprime nome cientifico do produto. Se Sim    �
		//� verifica se existe registro no SB5 e se nao esta vazio    �
		//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
		cDesc := SB1->B1_DESC
		lIsCient := .F.
		If mv_par17 == 1
			dbSelectArea("SB5")
			dbSeek(xFilial()+SB1->B1_COD)
			If Found() .and. !Empty(B5_CEME)
				cDesc := B5_CEME
				lIsCient := .T.
			EndIf
			dbSelectArea('SB1')
		Endif
		
		//-- Consiste Descri��o De/At�
		If cDesc < mv_par12 .Or. cDesc > mv_par13
			SB1->(dbSkip())
			Loop
		EndIf
		
		//-- Filtro do usuario
		If !Empty(aReturn[7]) .And. !&(aReturn[7])
			SB1->(dbSkip())
			Loop
		EndIf
		
		For nX := 1 to Len(aFiliais)
			cFilAnt := aFiliais[nX]
			
			IF !lContinua
				Exit
			Endif
			
			//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
			//� Localiza produto no Cadastro de ACUMULADOS DO ESTOQUE        �
			//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
			dbSelectArea('SB2')
			If mv_par01 == 3
				dbSeek(SB1->B1_COD + xFilial('SB2'), .T.)
			ElseIf mv_par01 == 2
				dbSeek(xFilial('SB2') + SB1->B1_COD, .T.)
			Else
				dbSeek(SB1->B1_COD + xFilial('SB2') + mv_par04, .T.)
			EndIf
			
			//-- 1� Looping no Arquivo Secund�rio (SB2)
			Do While lContinua .And. !SB2->(Eof()) .And. xFilial("SB2") == B2_FILIAL .AND. B2_COD == SB1->B1_COD
				
				If mv_par01 == 3
					If Empty(xFilial('SB1'))
						cQuebra2  := B2_COD
						cCond2	 := 'B2_COD == cQuebra2'
					Else
						cQuebra2  := B2_COD + B2_FILIAL
						cCond2	 := 'B2_COD + B2_FILIAL == cQuebra2'
					EndIf
				ElseIf mv_par01 == 2
					cQuebra2 := B2_FILIAL + B2_COD
					cCond2   := 'B2_FILIAL + B2_COD == cQuebra2'
				Else
					cQuebra2 := B2_COD + B2_FILIAL + B2_LOCAL
					cCond2   := 'B2_COD + B2_FILIAL + B2_LOCAL == cQuebra2'
				EndIf
				
				//-- N�o deixa o mesmo Filial/Produto passar mais de 1 vez
				If Len(aProd) <= 4096
					If Len(aProd) == 0 .Or. Len(aProd[Len(aProd)]) == 4096
						aAdd(aProd, {})
					EndIf
					If aScan(aProd[Len(aProd)], cQuebra2) > 0
						SB2->(dbSkip())
						Loop
					Else
						aAdd(aProd[Len(aProd)], cQuebra2)
					EndIf
				Else
					If Len(aProd1) == 0 .Or. Len(aProd1[Len(aProd1)]) == 4096
						aAdd(aProd1, {})
					EndIf
					If aScan(aProd1[Len(aProd1)], cQuebra2) > 0
						SB2->(dbSkip())
						Loop
					Else
						aAdd(aProd1[Len(aProd1)], cQuebra2)
					EndIf
				EndIf
				
				//-- 2� Looping no Arquivo Secund�rio (SB2)
				Do While lContinua .And. !SB2->(Eof()) .And. &(cCond2)
					
					If aReturn[8] == 2 //-- Tipo
						If SB1->B1_TIPO # fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_TIPO')
							SB2->(dbSkip())
							Loop
						EndIf
					ElseIf aReturn[8] == 4 //-- Grupo
						If SB1->B1_GRUPO # fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_GRUPO')
							SB2->(dbSkip())
							Loop
						EndIf
					EndIf
					
					If lEnd
						@ PROW()+1, 001 pSay (STR0013) // 'CANCELADO PELO OPERADOR'
						lContinua := .F.
						Exit
					EndIf
					
					//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
					//� Carrega array com dados do produto na data base.             �
					//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
					IF mv_par15 > 2
						//-- Verifica se o SM0 esta posicionado na Filial Correta
						If !Empty(SB2->B2_FILIAL) .And. !(cFilAnt==SB2->B2_FILIAL)
							aSalProd := {0,0,0,0,0,0,0}
						Else
							aSalProd := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,dDataBase+1)
						EndIf
					Else
						aSalProd := {0,0,0,0,0,0,0}
					Endif
					
					//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
					//� Verifica se devera ser impressa o produto zerado             �
					//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
					If Iif(mv_par15==1,B2_QATU,Iif(mv_par15==2,B2_QFIM,aSalProd[1])) == 0 .And. mv_par14 == 2 .Or. ;
						Iif(mv_par15==1,B2_QATU,Iif(mv_par15==2,B2_QFIM,aSalProd[1])) > 0  .And. mv_par16 == 1
						cCodAnt := SB2->B2_COD
						SB2->(dbSkip())
						If mv_par01 == 1 .And. SB2->B2_COD # cCodAnt
							If nQtdProd > 1
								lImpr := .T.
							Else
								nSoma    := 0
								nQtdProd := 0
							EndIf
						EndIf
						Loop
					EndIf
					
					lImpr := .T.
					
					If Li > 55
						Cabec(Titulo,cCabec1,cCabec2,WnRel,Tamanho,nTipo)
					EndIf
					
					//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
					//� Adiciona 1 ao contador de registros impressos         �
					//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
					If mv_par01 == 1
						@ Li, 00 pSay fContSB1(cFilOld, SB2->B2_COD, 'B1_GRUPO')
						@ li, pcol()+1 pSay fContSB1(cFilOld, SB2->B2_COD, 'B1_CODITE')
						@ li, pcol()+1 pSay left(SB2->B2_COD+space(15),15)
						@ Li, pcol()+1 pSay fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_TIPO')
						@ Li, pcol()+1 pSay Left(Iif(lIsCient, cDesc,	fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_DESC')),17)
						@ Li, pcol()+1 pSay fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_UM')
					    nSizFil := 12-FWSizeFilial()
						@ Li, pcol()+1 pSay B2_FILIAL+space(nSizFil)
						@ Li, pcol()+1 pSay B2_LOCAL
						@ Li, pcol()+1 pSay Transform( Iif(mv_par15==1,B2_QATU,Iif(mv_par15==2,B2_QFIM,aSalProd[1])), cPict)
						Li++
						nQtdProd ++
					EndIf
					
					nSoma += Iif(mv_par15==1,B2_QATU,Iif(mv_par15==2,B2_QFIM,aSalProd[1]))
					nTotSoma += Iif(mv_par15==1,B2_QATU,Iif(mv_par15==2,B2_QFIM,aSalProd[1]))
					
					cFilOld := SB2->B2_FILIAL
					cCodAnt := SB2->B2_COD
					
					SB2->(dbSkip())
					
				EndDo
				
				If lImpr
					
					If Li > 55
						Cabec(Titulo,cCabec1,cCabec2,WnRel,Tamanho,nTipo)
						
					EndIf
					
					If mv_par01 == 1
						If SB2->B2_COD # cCodAnt .And. ;
							(aReturn[8] # 2 .And. aReturn[8] # 4)
							If nQtdProd > 1
								@ Li, 44 pSay (STR0014) + Space(1) + AllTrim(Left(cCodAnt,15)) + Space(5) + Replicate('.',21-Len(AllTrim(Left(cCodAnt,15)))) // 'Total do Produto'
								@ Li, 89 pSay Transform(nSoma, cPict)
								Li += 2
							EndIf
							nSoma    := 0
							nQtdProd := 0
						EndIf
					Else
						@ Li, 00 pSay fContSB1(cFilOld, cCodAnt, 'B1_GRUPO')
						@ Li, pcol()+1 pSay fContSB1(cFilOld, cCodAnt, 'B1_CODITE')
						@ Li, pcol()+1 pSay left(cCodAnt+space(15),15)
						@ Li, pcol()+1 pSay fContSB1(cFilOld, cCodAnt, 'B1_TIPO')
						@ Li, pcol()+1 pSay Left(Iif(lIsCient, cDesc,	fContSB1(cFilOld, cCodAnt, 'B1_DESC')),17)
						@ Li, pcol()+1 pSay fContSB1(cFilOld, cCodAnt, 'B1_UM') 
					    nSizFil := 12-FWSizeFilial()
						@ Li, pcol()+1 pSay Iif(mv_par01==2,cFilOld+space(nSizFil),Repl("*",FWSizeFilial())+space(nSizFil))
						@ Li, pcol()+1 pSay '**'
						@ Li, pcol()+1 pSay Transform(nSoma, cPict)
						Li++
						nSoma := 0
					EndIf
					
					lImpr := .F.
					
				EndIf
			EndDo
			
		Next nX
		cFilAnt := cBkpFilAnt

		dbSelectArea('SB1')
		SB1->(dbSkip())
		
	EndDo
	
	If Li > 55
		Cabec(Titulo,cCabec1,cCabec2,WnRel,Tamanho,nTipo)
		
	EndIf
	
	If (aReturn[8] == 2 .Or. aReturn[8] == 4) .And. ;
		nTotSoma # 0
		@ Li, 40 pSay STR0018 + cMens
		@ Li, 64 pSay Transform(nTotSoma, cPict)
		Li += 2
		nTotSoma := 0
	EndIf
	
EndDo

If Li # 80
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf


//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Devolve as ordens originais dos arquivos                     �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
RetIndex('SB2')
Set Filter to

RetIndex('SB1')
Set Filter to

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Apaga indices de trabalho                                    �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
If File(cNomArqB2 += OrdBagExt())
	fErase(cNomArqB2)
EndIf
If File(cNomArqB1 += OrdBagExt())
	fErase(cNomArqB1)
EndIf

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Devolve a condicao original dos arquivos principal           �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
dbSelectArea('SB1')
Set Filter To
dbSetOrder(1)

dbSelectArea('SB2')
Set Filter To
dbSetOrder(1)

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(WnRel)
Endif

Ms_Flush()

Return Nil

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � fContSB1 � Autor � Fernando Joly Siquini � Data � 13.10.98 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Procura produto em SB1 e retorna o conteudo do campo       咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe   � fContSB1( cChave, cCampo)                                  咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Par�metros� cFil   = Filial de procura                                 咳�
臼�Par�metros� cCod   = Codido de procura                                 咳�
臼�          � cCampo = Campo cujo conte�do se deseja retornar            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � Generico                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�*/
Static Function fContSB1(cFil, cCod, cCampo)

//-- Inicializa Variaveis
Local cCont      := &('SB1->' + cCampo)
Local cPesq      := ''
Local nPos       := 0
Local nOrdem     := SB1->(IndexOrd())
Local nRecno     := SB1->(Recno())

If Empty(xFilial('SB1')) .And. !Empty(cFil)
	cFil := xFilial('SB1')
EndIf

cPesq := cFil + cCod

If cPesq == Nil .Or. cCampo == Nil
	Return cCont
EndIf

SB1->(dbSetOrder(1))
If SB1->(dbSeek(cPesq, .F.)) .And. (nPos := SB1->(FieldPos(Upper(cCampo)))) > 0
	cCont := SB1->(FieldGet(nPos))
EndIf

SB1->(dbSetOrder(nOrdem))
SB1->(dbGoto(nRecno))

Return cCont
