#INCLUDE "FINR139.CH"
#INCLUDE "PROTHEUS.CH"

Static lFWCodFil := FindFunction("FWCodFil")

// 17/08/2009 - Compilacao para o campo filial de 4 posicoes
// 18/08/2009 - Compilacao para o campo filial de 4 posicoes                                                            

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � FINR139  � Autor � Adrianne Furtado      � Data � 20.10.06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Posi噭o dos Titulos a Receber - NF-e				          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe e � FINR139(void)                                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Generico                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Function FINR139()

/*Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else*/
	Return FINR139R3() // Executa vers鉶 anterior do fonte
//Endif

Return


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o	 � FINR139R3� Autor � Adrianne Furtado      � Data � 20.10.06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Posi噭o dos Titulos a Receber - NF-e			 	  		  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe e � FINR139R3(void)											  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � Generico 												  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
Function FINR139R3()
Local cDesc1 :=OemToAnsi(STR0001)  //"Imprime os titulos a receber com o n鷐ero "
Local cDesc2 :=OemToAnsi(STR0002)  //"da NF-e"
Local cDesc3 :=""
Local wnrel
Local cString:="SE1"
Local nRegEmp:=SM0->(RecNo())
Local dOldDtBase := dDataBase
Local dOldData	:= dDatabase

Private titulo  :=""
Private cabec1  :=""
Private cabec2  :=""

Private aLinha  :={}
Private aReturn :={ OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"
Private cPerg	 :="FIN139"
Private nJuros  :=0
Private nLastKey:=0
Private nomeprog:="FINR139"
Private tamanho :="G"

//谀哪哪哪哪哪哪哪哪哪哪哪哪目
//� Defini噭o dos cabe嘺lhos �
//滥哪哪哪哪哪哪哪哪哪哪哪哪馁
titulo := OemToAnsi(STR0005)  //"Posicao dos Titulos a Receber"
cabec1 := OemToAnsi(STR0006)  //"Codigo Nome do Cliente      Prf-Numero         TP  Natureza    Data de  Vencto   Vencto  Banco  Valor Original |        Titulos Vencidos          | Titulos a Vencer | Num        Vlr.juros ou  Dias   Historico     "
cabec2 := OemToAnsi(STR0007)  //"                            Parcela                            Emissao  Titulo    Real                         |  Valor Nominal   Valor Corrigido |   Valor Nominal  | Banco       permanencia  Atraso               "

pergunte("FIN139",.F.)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Variaveis utilizadas para parametros								   �
//� mv_par01		 // Do Cliente 										   �
//� mv_par02		 // Ate o Cliente									   �
//� mv_par03		 // Do Prefixo										   �
//� mv_par04		 // Ate o prefixo 									   �
//� mv_par05		 // Do Titulo										   �
//� mv_par06		 // Ate o Titulo									   �
//� mv_par07		 // Da NF-e											   �
//� mv_par08		 // Ate a NF-e										   �
//� mv_par09		 // Do Vencimento 									   �
//� mv_par10		 // Ate o Vencimento								   �
//� mv_par11		 // da filial										   �
//� mv_par12		 // a flial											   �
//� mv_par13		 // Da Emissao										   �
//� mv_par14		 // Ate a Emissao									   �
//� mv_par15		 // Qual Moeda										   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Envia controle para a fun噭o SETPRINT �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

wnrel:="FINR139"            //Nome Default do relatorio em Disco
aOrd :={OemToAnsi(STR0014),; //"Por NF-e"  1.
	   	OemToAnsi(STR0009),; //"Por Prefixo/Numero" 2.
		OemToAnsi(STR0020),; //"Por Numero/Tipo/Prefixo" 3.
	    OemToAnsi(STR0008),; //"Por Cliente" 4.
		OemToAnsi(STR0015)} //"Por Cod.Cli." 5.

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| FA139Imp(@lEnd,wnRel,cString)},titulo)  // Chamada do Relatorio

SM0->(dbGoTo(nRegEmp))
cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o	 � FA139Imp � Autor � Adrianne Furtado		� Data � 20.10.06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Imprime relatio dos Tulos a Receber - NF-e			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe e � FA139Imp(lEnd,WnRel,cString)								  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� lEnd	  - A嚻o do Codeblock				    			  潮�
北�			 � wnRel   - Tulo do relatio 							  潮�
北�			 � cString - Mensagem										  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � Generico 												  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function FA139Imp(lEnd,WnRel,cString)
Local nOrdem
Local lContinua := .T.
Local cCond1,cCond2,cCarAnt
Local nSaldo:=0
Local dDataReaj
Local dDataAnt := dDataBase
Local cIndexSe1
Local cChaveSe1
Local nIndexSE1
Local dDtContab
Local cTipos  := ""
#IFDEF TOP
	Local aStru := SE1->(dbStruct()), ni
#ENDIF	
Local nTotsRec := SE1->(RecCount())
Local aTamCli  := TAMSX3("E1_CLIENTE")
// variavel  abaixo criada p/pegar o nr de casas decimais da moeda
Local ndecs := Msdecimais(mv_par15)
Local nAbatim := 0
Local nDescont:= 0
Local nVlrOrig:= 0
Private nRegSM0 := SM0->(Recno())
Private nAtuSM0 := SM0->(Recno())
PRIVATE dBaixa := dDataBase
PRIVATE cFilDe,cFilAte

nOrdem:=aReturn[8]
cMoeda:=Str(mv_par15,1)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Vari爒eis utilizadas para Impress刼 do Cabe嘺lho e Rodap� �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
li 		:= 80
m_pag 	:= 1

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� POR MAIS ESTRANHO QUE PARE�A, ESTA FUNCAO DEVE SER CHAMADA AQUI! �
//�                                                                  �
//� A fun噭o SomaAbat reabre o SE1 com outro nome pela ChkFile para  �
//� efeito de performance. Se o alias auxiliar para a SumAbat() n刼  �
//� estiver aberto antes da IndRegua, ocorre Erro de & na ChkFile,   �
//� pois o Filtro do SE1 uptrapassa 255 Caracteres.                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
SomaAbat("","","","R")

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Atribui valores as variaveis ref a filiais                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
cFilDe := mv_par11	// Todas as filiais
cFilAte:= mv_par12

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilDe,.T.)

nRegSM0 := SM0->(Recno())
nAtuSM0 := SM0->(Recno())

While !Eof() .and. M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
	
	dbSelectArea("SE1")
	cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	Set Softseek On
	
	
	
	#IFDEF TOP
		
		If nOrdem = 4
			cQuery := ""
			aEval(SE1->(DbStruct()),{|e| If(!Alltrim(e[1])$"E1_FILIAL#E1_NOMCLI#E1_CLIENTE#E1_LOJA#E1_PREFIXO#E1_NUM#E1_PARCELA#E1_TIPO", cQuery += ","+AllTrim(e[1]),Nil)})
			cQuery := "SELECT E1_FILIAL, E1_NOMCLI, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM,E1_PARCELA, E1_TIPO, "+ SubStr(cQuery,2)
		Else
			cQuery := "SELECT * "
		EndIf
		
		cQuery += "  FROM "+	RetSqlName("SE1") + " SE1"
		cQuery += " WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
		cQuery += "   AND D_E_L_E_T_ = ' ' "
	#ENDIF
	
	IF nOrdem = 1
		SE1->(dbSetOrder(19))
		#IFNDEF TOP
			dbSeek(cFilial)
		#ELSE
			cOrder := SqlOrder(IndexKey())
		#ENDIF
		cCond1 := "E1_NFELETR >= ''"
		cCond2 := "E1_NFELETR"
		titulo := titulo + OemToAnsi(STR0016)  //" - Por NF-e"*/"
		
	Elseif nOrdem = 2
		SE1->(dbSetOrder(1))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par03+mv_par05)
		#ELSE
			cOrder := SqlOrder(IndexKey())
		#ENDIF
		cCond1 := "E1_NUM <= mv_par06"
		cCond2 := "E1_NUM"
		titulo := titulo + OemToAnsi(STR0018)  //" - Por Numero"
	ElseIf nOrdem == 3
		cChave := "E1_FILIAL+E1_NUM+E1_TIPO+E1_PREFIXO+E1_PARCELA"
		#IFNDEF TOP
			dbSelectArea("SE1")
			cIndex := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndex,cChave,,,OemToAnsi(STR0022))
			nIndex := RetIndex("SE1")
			dbSetIndex(cIndex+OrdBagExt())
			dbSetOrder(nIndex+1)
			dbSeek(xFilial("SE1")+mv_par05)
		#ELSE
			cOrder := SqlOrder(cChave)
		#ENDIF
		cCond1 := "E1_NUM <= mv_par06"
		cCond2 := "E1_NUM"
		titulo := titulo + OemToAnsi(STR0021)  //" - Numero/Prefixo"	
	Elseif nOrdem = 4
		cChaveSe1 := "E1_FILIAL+E1_NOMCLI+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
		#IFDEF TOP
			cOrder := SqlOrder(cChaveSe1)
		#ELSE
			cIndexSe1 := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndexSe1,cChaveSe1,,fr139IndR(),OemToAnsi(STR0022))
			nIndexSE1 := RetIndex("SE1")
			dbSetIndex(cIndexSe1+OrdBagExt())
			dbSetOrder(nIndexSe1+1)
			dbSeek(xFilial("SE1"))
		#ENDIF
		cCond1 := "E1_CLIENTE <= mv_par02"
		cCond2 := "E1_CLIENTE + E1_LOJA"
		titulo := titulo + OemToAnsi(STR0017)  //" - Por Cliente
	Elseif nOrdem = 5
		SE1->(dbSetOrder(2))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par01,.T.)
		#ELSE
			cOrder := SqlOrder(IndexKey())
		#ENDIF
		cCond1 := "E1_CLIENTE <= mv_par02"
		cCond2 := "E1_CLIENTE"
		titulo := titulo + OemToAnsi(STR0019)  //" - Por Cod.Cliente"	
	Endif
	
	cFilterUser:=aReturn[7]
	Set Softseek Off
	
	#IFDEF TOP
		cQuery += " AND E1_CLIENTE between '" + mv_par01        + "' AND '" + mv_par02 + "'"
		cQuery += " AND E1_PREFIXO between '" + mv_par03        + "' AND '" + mv_par04 + "'"
		cQuery += " AND E1_NUM     between '" + mv_par05        + "' AND '" + mv_par06 + "'"
		cQuery += " AND E1_NFELETR between '" + mv_par07        + "' AND '" + mv_par08 + "'"
		cQuery += " AND E1_VENCREA between '" + DTOS(mv_par09)  + "' AND '" + DTOS(mv_par10) + "'"
		cQuery += " AND E1_EMISSAO between '" + DTOS(mv_par13)  + "' AND '" + DTOS(mv_par14) + "'"
		cQuery += " ORDER BY "+ cOrder
		
		cQuery := ChangeQuery(cQuery)
		
		dbSelectArea("SE1")
		dbCloseArea()
		dbSelectArea("SA1")
		
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1', .F., .T.)
		
		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField('SE1', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next
	#ENDIF
	SetRegua(nTotsRec)
	
	While &cCond1 .and. !Eof() .and. lContinua .and. E1_FILIAL == xFilial("SE1")
		
		IF	lEnd
			@PROW()+1,001 PSAY OemToAnsi(STR0023)  //"CANCELADO PELO OPERADOR"
			Exit
		Endif
		
		IncRegua()
		
		cCarAnt := &cCond2
		
		While &cCond2==cCarAnt .and. !Eof() .and. lContinua .and. E1_FILIAL == xFilial("SE1")
			
			IF lEnd
				@PROW()+1,001 PSAY OemToAnsi(STR0023)  //"CANCELADO PELO OPERADOR"
				lContinua := .F.
				Exit
			EndIF
			
			IncRegua()
			
			dbSelectArea("SE1")
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Filtrar com base no Pto de entrada do Usuario...             �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪Jose Lucas, Localiza嚁es Argentina馁
			If !Empty(cTipos)
				If !(SE1->E1_TIPO $ cTipos)
					dbSkip()
					Loop
				Endif
			Endif
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Considera filtro do usuario                                  �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			If !Empty(cFilterUser).and.!(&cFilterUser)
				dbSkip()
				Loop
			Endif
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Verifica se titulo, apesar do E1_SALDO = 0, deve aparecer ou �
			//� n苚 no relatio quando se considera database �
			//� ou caso n苚 se considere a database, se o titulo foi totalmen�
			//� te baixado.																  �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			dbSelectArea("SE1")
			IF !Empty(SE1->E1_BAIXA) .and. (SE1->E1_SALDO == 0 .and. SE1->E1_BAIXA <= dDataBase)
				dbSkip()
				Loop
			EndIF
							
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Verifica se esta dentro dos parametros �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			dbSelectArea("SE1")
			IF SE1->E1_CLIENTE < mv_par01 .OR. SE1->E1_CLIENTE > mv_par02 .OR. ;
				SE1->E1_PREFIXO < mv_par03 .OR. SE1->E1_PREFIXO > mv_par04 .OR. ;
				SE1->E1_NUM	 	 < mv_par05 .OR. SE1->E1_NUM 		> mv_par06 .OR. ;
				SE1->E1_NFELETR  < mv_par07 .OR. SE1->E1_NFELETR	> mv_par08 .OR. ;
				SE1->E1_VENCREA < mv_par09 .OR. SE1->E1_VENCREA > mv_par10 .OR. ;
				SE1->E1_EMISSAO < mv_par13 .OR. SE1->E1_EMISSAO > mv_par14 .OR. ;
				!&(fr139IndR())
				dbSkip()
				Loop
			Endif
							
			dbSelectArea("SA1")
			MSSeek(cFilial+SE1->E1_CLIENTE+SE1->E1_LOJA)
			dbSelectArea("SA6")
			MSSeek(cFilial+SE1->E1_PORTADO)
			dbSelectArea("SE1")
			
			IF li > 58
				nAtuSM0 := SM0->(Recno())
				SM0->(dbGoto(nRegSM0))
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
				SM0->(dbGoTo(nAtuSM0))
			EndIF
			
			@li, 0 PSAY SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"-"+SE1->E1_PARCELA
			
			@li, 19 PSAY SE1->E1_NFELETR
	
			@li, 27 PSAY SE1->E1_CLIENTE + " " + SE1->E1_LOJA + "   " + SubStr(SA1->A1_NREDUZ,1,17)
			li := IIf (aTamCli[1] > 6,li+1,li)

			If SE1->E1_TIPO$MVABATIM
				@li,59 PSAY "["
			Endif
			@li, 60 PSAY SE1->E1_TIPO
			If SE1->E1_TIPO$MVABATIM
				@li,63 PSAY "]"
			Endif
			@li, 64 PSAY SE1->E1_NATUREZ
			@li, 75 PSAY SE1->E1_EMISSAO
			@li, 86 PSAY SE1->E1_VENCTO
			@li, 97 PSAY SE1->E1_VENCREA
			@li, 108 PSAY SE1->E1_PORTADO+" "+SE1->E1_SITUACA
			nVlrOrig := Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))* If(SE1->E1_TIPO$MVABATIM+"/"+MV_CRNEG+"/"+MVRECANT, -1,1),nDecs+1),nDecs)
			@li,114 PSAY nVlrOrig Picture TM(nVlrOrig,15,nDecs)
						
			dbSkip()
			li++
		Enddo
		
	Enddo
	
	dbSelectArea("SE1")		// voltar para alias existente, se nao, nao funciona
	
	If Empty(FwFilial("SE1"))
		Exit
	Endif
	
	#IFDEF TOP
		dbSelectArea("SE1")
		dbCloseArea()
		ChKFile("SE1")
		dbSelectArea("SE1")
		dbSetOrder(1)
	#ENDIF
	
	dbSelectArea("SM0")
	dbSkip()
Enddo

SM0->(dbGoTo(nRegSM0))
cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
IF li != 80
	IF li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	EndIF
EndIF

Set Device To Screen

#IFNDEF TOP
	dbSelectArea("SE1")
	dbClearFil()
	RetIndex( "SE1" )
	If !Empty(cIndexSE1)
		FErase (cIndexSE1+OrdBagExt())
	Endif
	dbSetOrder(1)
#ELSE
	dbSelectArea("SE1")
	dbCloseArea()
	ChKFile("SE1")
	dbSelectArea("SE1")
	dbSetOrder(1)
#ENDIF

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	Ourspool(wnrel)
Endif
MS_FLUSH()

Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o	 砯r139IndR � Autor � Adrianne Furtado	    � Data � 20.10.06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 矼onta Indregua para impressao do relatio				  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � Generico 												  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function fr139IndR()
Local cString

cString := 'E1_FILIAL=="'+xFilial("SE1")+'".And.'
cString += 'E1_CLIENTE>="'+mv_par01+'".and.E1_CLIENTE<="'+mv_par02+'".And.'
cString += 'E1_PREFIXO>="'+mv_par03+'".and.E1_PREFIXO<="'+mv_par04+'".And.'
cString += 'E1_NUM>="'+mv_par05+'".and.E1_NUM<="'+mv_par06+'".And.'
cString += 'DTOS(E1_VENCREA)>="'+DTOS(mv_par09)+'".and.DTOS(E1_VENCREA)<="'+DTOS(mv_par10)+'".And.'
cString += 'E1_NFELETR>="'+mv_par07+'".and.E1_NFELETR<="'+mv_par08+'".And.'
cString += 'DTOS(E1_EMISSAO)>="'+DTOS(mv_par13)+'".and.DTOS(E1_EMISSAO)<="'+DTOS(mv_par14)+'"'

Return cString
