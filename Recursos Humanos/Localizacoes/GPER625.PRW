#Include "PROTHEUS.CH"
#INCLUDE "GPER625.CH"

Static cAliasTMP

/*/
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������Ŀ��
���Fun��o    � GPER625  � Autor � Ricardo Berti                   � Data �04/10/2013���
�����������������������������������������������������������������������������������Ĵ��
���Descri��o � Geracao do Informe de Assegurados por Empresa - 						���
���          � APORTE CAJA DE SALUD DE LA BANCA PRIVADA                             ���
�����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER625()                                                          	���
�����������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                      ���
�����������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                             ���
�����������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                       ���
�����������������������������������������������������������������������������������Ĵ��
���Analista	 � Data     � CHAMADO      �  Motivo da Alteracao                       ���
�����������������������������������������������������������������������������������Ĵ��
���Jonathan Glz�06/05/2015�    PCREQ-4256�Se elimina la funcion AjustaSX1, la cual  ���
���            �          �              �realiza la modificacion aldiccionario de  ���
���            �          �              �datos(SX1) por motivo de adecuacion  nueva���
���            �          �              �estructura de SXs para version 12         ���
���L.Enr�quez  �30/01/2017�SERINN001-824 �Merge 12.1.15 Se elimina utilizaci�n de   ���
���            �          �              �funci�n CriaTrab para utilizar clase      ���
���            �          �              �FWTemporaryTable y asi evitar creaci�n de ���
���            �          �              �archivo .dtc en carpeta system.           ���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
/*/
Function GPER625()
	/*
	��������������������������������������������������������������Ŀ
	� Define Variaveis Locais (Basicas)                            �
	����������������������������������������������������������������*/
	Local cDesc1 		:= STR0001		//"Aportes Caja de Salud de la Banca Privada"
	Local cDesc2 		:= STR0002		//"Se imprimira de acuerdo con los parametros solicitados por el usuario."
	Local cDesc3 		:= ""
	Local cString		:= "SRA"        // alias do arquivo principal (Base)
	Local aOrd      	:= {STR0004,STR0005,STR0006}	//"Sucursal + Matricula"###"Sucursal+ + C. Costo"###"Sucural + Nombre"

	/*
	��������������������������������������������������������������Ŀ
	� Define Variaveis Private(Basicas)                            �
	����������������������������������������������������������������*/
	Private nomeprog	:= "GPER625"
	Private aReturn 	:= { , 1,, 2, 2, 1,"",1 }
	Private nLastKey 	:= 0
	Private cPerg   	:= "GPR625"

	/*
	��������������������������������������������������������������Ŀ
	� Variaveis Utilizadas na funcao IMPR                          �
	����������������������������������������������������������������*/
	Private Titulo 		:= STR0001 // "Aportes Caja de Salud de la Banca Privada"
	Private nTamanho		:= "M"
	Private nOrdem
	Private cFilialDe   	:= ""
	Private cFilialAte  	:= ""
	Private cMes			:= ""
	Private cAno			:= ""
	Private cMatDe     	:= ""
	Private cMatAte     	:= ""
	Private cCustoDe    	:= ""
	Private cCustoAte   	:= ""
	Private cNomeDe     	:= ""
	Private cNomeAte    	:= ""
	Private cSit        	:= ""
	Private cCat        	:= ""

	Private oPrint

	//-- Objeto para impressao grafica
	oPrint 	:= TMSPrinter():New( STR0001 ) //"Aportes Caja de Salud de la Banca Privada"



	/*
	��������������������������������������������������������������Ŀ
	� Variaveis utilizadas para parametros                         �
	� mv_par01        //  Filial De						           �
	� mv_par02        //  Filial Ate					           �
	� mv_par03        //  Mes/Ano Competenc.MMAAAA?		           |
	� mv_par04        //  Matricula De                             �
	� mv_par05        //  Matricula Ate                            �
	� mv_par06        //  Centro de Custo De                       �
	� mv_par07        //  Centro de Custo Ate                      �
	� mv_par08        //  Nome De                                  �
	� mv_par09        //  Nome Ate                                 �
	� mv_par10        //  Situacoes ?       		               �
	� mv_par11        //  Categorias? 		                       �
	� mv_par12        //  Ordem                                    �
	����������������������������������������������������������������
	*/
	//oPrint:SetLandscape()	//Imprimir Somente Paisagem
	If Pergunte(cPerg,.T.,Titulo)

		If Empty(mv_par03)
			Help(" ",1,"XINVMESANO")
			Return (.F.)
		EndIf

		cFilialDe 	:= mv_par01
		cFilialAte  := mv_par02
		cMesAno		:= mv_par03
		cMes 		:= substr( mv_par03, 1, 2 )
		cAno 		:= substr( mv_par03, 3, 4 )
		cMatDe		:= mv_par04
		cMatAte     := mv_par05
		cCustoDe    := mv_par06
		cCustoAte   := mv_par07
		cNomeDe     := mv_par08
		cNomeAte    := mv_par09
		cSit        := mv_par10
		cCat        := mv_par11
		nOrdem		:= mv_par12

		MsgRun(STR0003,"",{|| CursorWait(), ImpAsCajaS() ,CursorArrow()}) //"Gerando relatorio, aguarde..."

		oPrint:Preview()	// Visualiza impressao grafica antes de imprimir

	Endif

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpAsCajaS�Autor  �Ricardo Berti       � Data �  04/10/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Obs.: O GPER625 e GPR624Proc() chamam esta mesma funcao,   ���
���			 � porem, os mesmos tem perguntes distintos (GPR625 e GPR624) ���
���		 	 �	 	   Considerar esta inf. ao alterar o SX1. 			  ���
�������������������������������������������������������������������������͹��
���Sintaxe   � ImpAsCajaS(ExpL1)                                          ���
�������������������������������������������������������������������������͹��
���Parametros� ExpL1: = .T., indica se deve gerar apenas o arq. TXT  (OPC)���
���          �        = .F.(Default) - imprime apenas o relatorio		  ���
�������������������������������������������������������������������������͹��
���Uso       � GPER625 / GPR624Proc()                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpAsCajaS(lTXT)

	Local cAcessaSRA	:= &( " { || " + ChkRH( "GPER625" , "SRA" , "2" ) + " } " )
	Local aPerAberto    := {}
	Local aPerFechado   := {}
	Local aPerTodos		:= {}
	Local aCodFol		:= {}
	Local aTabela		:= {}

	Local nAux		:= 0
	Local nLin		:= 0380
	Local cFilAnt
	Local cPeriodos	:= ''
	Local lAux		:= .F.
	Local lMsgS001	:= .F.

	/*
	��������������������������������������������������������������Ŀ
	� Variaveis para controle em ambientes TOP.                    �
	����������������������������������������������������������������*/
	Local cAlias   := ""
	Local cQrySRC  := "SRC"
	Local cQrySRD  := "SRD"
	Local cCateg   := ''
	Local cSitu    := ''
	Local cQuery   := ''
	Local cQueryOrd:= ""
	Local aStruct  := {}

	DEFAULT lTXT := .F.

	//variaveis contendo valores para impressao
	Private aInfo 	  := {}     //armazena dados da filial
	Private nNum	  := 0
	Private nTotGanad := 0
	Private nTotAport := 0
	Private nGTotGanad:= 0
	Private nGTotAport:= 0
	Private cQrySRA   := "SRA"
	Private dDataRef
	Private cTime	  := Time()
	Private dData	  := dDataBase

	Private oFont07, oFont07n, oFont09, oFont09n, oFont10, oFont12n
	oFont06	:= TFont():New("Courier New",06,06,,.F.,,,,.T.,.F.)
	oFont06n	:= TFont():New("Courier New",06,06,,.T.,,,,.T.,.F.) //Negrito//
	oFont07	:= TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
	oFont07n	:= TFont():New("Courier New",07,07,,.T.,,,,.T.,.F.) //Negrito//
	oFont08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
	oFont08n	:= TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.) //Negrito//
	oFont09	:= TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
	oFont09n	:= TFont():New("Courier New",09,09,,.T.,,,,.T.,.F.) //Negrito//
	oFont10 	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	oFont12n	:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.) //Negrito//

	nEpoca:= SET(5,1910)
	//-- MUDAR ANO PARA 4 DIGITOS
	SET CENTURY ON

	If nOrdem == 1
		cQueryOrd := "RA_FILIAL,RA_MAT"
	ElseIf nOrdem == 2
		cQueryOrd := "RA_FILIAL,RA_CC,RA_MAT"
	ElseIf nOrdem == 3
		cQueryOrd := "RA_FILIAL,RA_NOME,RA_MAT"
	EndIf

	cAlias := "SRA"
	cQrySRA := "QSRA"
	/*
	��������������������������������������������������������������Ŀ
	� Buscar Situacao e Categoria em formato para SQL              �
	����������������������������������������������������������������*/
	cSitu   := "("
	For nAux := 1 To (Len( cSit )-1)
		cSitu += "'" + Substr( cSit, nAux, 1) + "',"
	Next nAux
	cSitu 	+= "'" + Substr( cSit, len(cSit), 1) + "')"

	cCateg   := "("
	For nAux := 1 To (Len( cCat )-1)
		cCateg += "'" + Substr( cCat, nAux, 1) + "',"
	Next nAux
	cCateg	+= "'" + Substr( cCat, len(cCat)-1, 1) + "')"

	//montagem da query
	cQuery := "SELECT"
	cQuery += " RA_FILIAL, RA_MAT, RA_CC, RA_ADMISSA, RA_PROCES, RA_CIC, RA_UFCI,"
	cQuery += " RA_PRINOME, RA_SECNOME, RA_PRISOBR, RA_SECSOBR, RA_BCDEPSA"
	cQuery += " FROM " + RetSqlName(cAlias)
	cQuery += " WHERE "
	cQuery += " RA_FILIAL BETWEEN '" + cFilialDe + "' AND '" + cFilialAte + "'"
	cQuery += "  AND "
	cQuery += " RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "'"
	cQuery += "  AND "
	cQuery += " RA_NOME BETWEEN '" + cNomeDe + "' AND '" + cNomeAte + "'"
	cQuery += "  AND "
	cQuery += " RA_CC BETWEEN '" + cCustoDe + "' AND '" + cCustoAte + "'"
	cQuery += "  AND "
	cQuery += " RA_SITFOLH IN " + cSitu
	cQuery += "  AND "
	cQuery += " RA_CATFUNC IN " + cCateg
	cQuery += "  AND "
	cQuery += " D_E_L_E_T_ <> '*'
	cQuery += " ORDER BY " + cQueryOrd

	cQuery := ChangeQuery(cQuery)
	aStruct := (cAlias)->(dbStruct())

	If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRA,.T.,.T.)
		For nAux := 1 To Len(aStruct)
			If ( aStruct[nAux][2] <> "C" )
				TcSetField(cQrySRA,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
			EndIf
		Next nAux
	EndIf

	dbSelectArea(cQrySRA)
	(cQrySRA)->(dbGoTop())

	dDataRef := ctod(Transform(f_UltDia(cToD("01/"+cMes+"/"+cAno)),"99")+"/"+cMes+"/"+cAno)

	//carrega periodo da competencia selecionada
	fRetPerComp( cMes , cAno , , , , @aPerAberto , @aPerFechado , @aPerTodos )

	fInfo(@aInfo,cFilialDe)			// carrega dados da filial

	While (cQrySRA)->( !Eof() )

		If cFilAnt <> (cQrySRA)->RA_FILIAL

			/*
			��������������������������������������������������������������Ŀ
			� Carrega Variaveis Codigos Da Folha                           �
			����������������������������������������������������������������*/
			If !fP_CodFol(@aCodFol,(cQrySRA)->RA_FILIAL)
				Return
			EndIf
			cFilAnt := (cQrySRA)->RA_FILIAL

		EndIf

		If SRA->RA_ADMISSA > dDataRef  //se o funcionario foi admitido depois da competencia selecionada
			(cQrySRA)->(dbSkip())
			Loop
		EndIf

		/*
		�����������������������������������������������������������������������Ŀ
		�Consiste Filiais e Acessos                                             �
		�������������������������������������������������������������������������*/
		IF !((cQrySRA)->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
			dbSelectArea("SRA")
			SRA->( dbSkip() )
			Loop
		EndIf

		//zera as variaveis para cada funcionario
		nTotGanad := 0
		nTotAport := 0

		/*
		�����������������������������������������������������������������������Ŀ
		�Procura no SRC registros do funcionario no periodo aberto, se houver   |
		�������������������������������������������������������������������������*/
		If !(len(aPerAberto) < 1)
			cAlias := "SRC"
			cQrySRC := "QSRC"

			//busca periodos para formato Query
			cPeriodos   := "("
			For nAux:= 1 to (len(aPerAberto)-1)
				cPeriodos += "'" + aPerAberto[nAux][1] + "',"
			Next nAux
			cPeriodos += "'" + aPerAberto[len(aPerAberto)][1]+"')"

			//montagem da query
			cQuery := "SELECT"
			cQuery += " RC_FILIAL, RC_MAT, RC_PROCES, RC_ROTEIR, RC_PERIODO, RC_SEMANA, RC_VALOR, RC_PD"
			cQuery += " FROM " + RetSqlName(cAlias)
			cQuery += " WHERE"
			cQuery += " RC_FILIAL = '" + cFilAnt + "'"
			cQuery += " AND"
			cQuery += " RC_MAT = '" + (cQrySRA)->RA_MAT + "'"
			cQuery += " AND"
			cQuery += " RC_PERIODO IN " + cPeriodos
			cQuery += " AND"
			cQuery += " D_E_L_E_T_ <> '*'
			cQuery += " ORDER BY RC_FILIAL, RC_MAT, RC_PROCES, RC_ROTEIR, RC_PERIODO, RC_SEMANA"

			cQuery := ChangeQuery(cQuery)
			aStruct := (cAlias)->(dbStruct())

			If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRC,.T.,.T.)
				For nAux := 1 To Len(aStruct)
					If ( aStruct[nAux][2] <> "C" )
						TcSetField(cQrySRC,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
					EndIf
				Next nAux
			EndIf

			While (cQrySRC)->(!Eof()) .And. (cQrySRA)->(RA_FILIAL+RA_MAT) == (cQrySRC)->(RC_FILIAL+RC_MAT)
				Do Case
					Case (cQrySRC)->RC_PD == aCodFol[747,1]
					nTotGanad+= (cQrySRC)->RC_VALOR
					Case (cQrySRC)->RC_PD == aCodFol[0054,1] // desconta faltas do Ganho para bater liquido.
					nTotGanad -= (cQrySRC)->RC_VALOR
					Case (cQrySRC)->RC_PD == aCodFol[1237,1] // desconta domingos do Ganho para bater liquido.
					nTotGanad -= (cQrySRC)->RC_VALOR
				EndCase
				(cQrySRC)->(dbSkip())
			EndDo
			(cQrySRC)->(dbCloseArea())
		EndIf

		/*
		�����������������������������������������������������������������������Ŀ
		�Procura no SRD registros do funcionario no periodo fechado, se houver  |
		�������������������������������������������������������������������������*/
		If	!(len(aPerFechado) < 1)
			cAlias := "SRD"
			cQrySRD := "QSRD"

			//busca periodos para formato Query
			cPeriodos   := "("
			For nAux:= 1 to (len(aPerFechado)-1)
				cPeriodos += "'" + aPerFechado[nAux][1] + "',"
			Next nAux
			cPeriodos += "'" + aPerFechado[len(aPerFechado)][1]+"')"

			//montagem da query
			cQuery := "SELECT"
			cQuery += " RD_FILIAL, RD_MAT, RD_PROCES, RD_ROTEIR, RD_PERIODO, RD_SEMANA, RD_VALOR, RD_PD"
			cQuery += " FROM " + RetSqlName(cAlias)
			cQuery += " WHERE"
			cQuery += " RD_FILIAL = '" + cFilAnt + "'"
			cQuery += " AND"
			cQuery += " RD_MAT = '" + (cQrySRA)->RA_MAT + "'"
			cQuery += " AND"
			cQuery += " RD_PERIODO IN " + cPeriodos
			cQuery += " AND"
			cQuery += " D_E_L_E_T_ <> '*'
			cQuery += " ORDER BY RD_FILIAL, RD_MAT, RD_PROCES, RD_ROTEIR, RD_PERIODO, RD_SEMANA"

			cQuery := ChangeQuery(cQuery)
			aStruct := (cAlias)->(dbStruct())
			If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRD,.T.,.T.)
				For nAux := 1 To Len(aStruct)
					If ( aStruct[nAux][2] <> "C" )
						TcSetField(cQrySRD,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
					EndIf
				Next nAux
			EndIf

			While (cQrySRD)->(!Eof()) .And.  (cQrySRA)->(RA_FILIAL+RA_MAT) == (cQrySRD)->(RD_FILIAL+RD_MAT)
				Do Case
					Case (cQrySRD)->RD_PD == aCodFol[747,1]
					nTotGanad += (cQrySRD)->RD_VALOR
					Case (cQrySRD)->RD_PD == aCodFol[0054,1] // desconta faltas do Ganho para bater liquido.
					nTotGanad -= (cQrySRD)->RD_VALOR
					Case (cQrySRD)->RD_PD == aCodFol[1237,1] // desconta domingos do Ganho para bater liquido.
					nTotGanad -= (cQrySRD)->RD_VALOR
				EndCase
				(cQrySRD)->(dbSkip())
			EndDo
			(cQrySRD)->(dbCloseArea())
		EndIf

		If nTotGanad > 0

			nTotAport := Round(nTotGanad*0.1,2)  // 10% Aporte

			If lTXT
				G624Grava()	//Grava reg. arq. temporario
			Else
				//controle de impressao
				If nLin == 0380
					ImpCabec()
				EndIf

				ImpInfFunc(@nLin)
				nLin+= 30

				If nLin > 2200
					ImpRodape(@nLin)
					nLin := 0380
				EndIf
			EndIf

			nGTotGanad += nTotGanad
			nGTotAport += nTotAport

		EndIf

		(cQrySRA)->(dbSkip())
	EndDo

	If !lTXT

		If Empty(aInfo)
			fInfo(@aInfo,cFilialDe)
		EndIf

		If nLin > 2150
			ImpRodape(@nLin)
			nLin := 0380
			ImpCabec(.T.)
		EndIf

		If nGTotGanad > 0
			ImpTotais(@nLin)
		EndIf

	EndIf

	If Select(cQrySRA) > 0
		(cQrySRA)->(dbCloseArea())
	EndIf
	If Select(cQrySRD) > 0
		(cQrySRD)->(dbCloseArea())
	EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpCabec  �Autor  �Ricardo Berti       � Data �  04/10/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Impressao do cabecalho                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpCabec(lTotal)

	DEFAULT lTotal := .F.

	oPrint:StartPage() 			//Inicia uma nova pagina
	oPrint:say ( 0050, 0030, aInfo[3], oFont09)		//razao social da filial

	oPrint:say ( 0050, 1970, STR0007, oFont09)	//"FECHA: "
	oPrint:say ( 0050, 2120, DToC(dData), oFont09)

	oPrint:say ( 0090, 1970, STR0008, oFont09)	//"HORA: "
	oPrint:say ( 0090, 2120, cTime , oFont09)

	oPrint:say ( 0100, 0680, STR0001, oFont12n )   //"Aportes Caja de Salud de la Banca Privada"
	oPrint:say ( 0150, 0890, STR0009+Upper(ALLTrim(MesExtenso(cMes)))+" "+STR0010 +" "+cAno, oFont10  )   //"MES DE "   //"DE"

	oPrint:say ( 0185, 0660, Replicate("-", 52), oFont10)
	oPrint:say ( 0190, 0660, Replicate("-", 52), oFont10)

	If !lTotal

		oPrint:say ( 0290, 0060, STR0011, oFont07)		//"No."
		oPrint:say ( 0290, 0150, STR0012, oFont07)		//"CI"
		oPrint:say ( 0290, 0330, STR0013, oFont07)		//"Exp"
		oPrint:say ( 0290, 0400, STR0014, oFont07)		//"Sucursal"
		oPrint:say ( 0290, 0580, STR0015, oFont07)		//"Agencia"
		oPrint:say ( 0290, 0780, STR0016, oFont07)		//"Nombre"
		oPrint:say ( 0290, 1500, STR0017, oFont07)		//"Total Ganado Real"
		oPrint:say ( 0290, 1860, STR0018, oFont07)		//"Aporte 10%"
		oPrint:say ( 0305, 0060, Replicate("_", 93), oFont10)

	EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpInfFunc�Autor  �Erika Kanamori      � Data �  03/19/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Impressao das informacoes do funcionario.                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpInfFunc(nLin)

	Local cNome := 	Ltrim(Rtrim((cQrySRA)->RA_PRISOBR) + Space(1)) +;
	Ltrim(Rtrim((cQrySRA)->RA_SECSOBR) + Space(1)) +;
	Ltrim(Rtrim((cQrySRA)->RA_PRINOME) + Space(1)) +;
	Alltrim((cQrySRA)->RA_SECNOME)

	oPrint:say ( nLin, 0055, Str(++nNum,6), oFont07)
	oPrint:say ( nLin, 0150, (cQrySRA)->RA_CIC, oFont07)
	oPrint:say ( nLin, 0330, (cQrySRA)->RA_UFCI, oFont07)
	oPrint:say ( nLin, 0400, (cQrySRA)->RA_FILIAL, oFont07)
	oPrint:say ( nLin, 0580, (cQrySRA)->RA_BCDEPSA, oFont07)
	oPrint:say ( nLin, 0780, SubStr(cNome,1,40), oFont07)
	oPrint:say ( nLin, 1520, Transform(nTotGanad , "999,999,999.99"), oFont07)
	oPrint:say ( nLin, 1820, Transform(nTotAport , "999,999,999.99"), oFont07)

Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpTotais �Autor  �Luciana Silveira    � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Impressao dos Totais da Planilha.                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpTotais(nLin)
	nLin+=40
	oPrint:say ( nLin, 1090, Replicate("_", 50), oFont09)
	nLin+= 40
	oPrint:say ( nLin, 1110, "TOTAL ", oFont09n )
	oPrint:say ( nLin, 1520, Transform(nGTotGanad,	"999,999,999.99"), oFont07)
	oPrint:say ( nLin, 1820, Transform(nGTotAport,	"999,999,999.99"), oFont07)
	nLin+= 40
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpRodape �Autor  �Erika Kanamori      � Data �  03/19/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Impressao do rodape.                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpRodape(nLin)
	nLin+=50
	oPrint:EndPage()
Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � GPR624Proc � Autor � Ricardo Berti	      � Data �04/10/2013���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Geracao do TXT Asegurados Caja Salud							���
���������������������������������������������������������������������������Ĵ��
��� Uso      � GPER624                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function GPR624Proc()
	Private oTmpTable := Nil	

	Pergunte("GPR624",.F.)

	cFilialDe 	:= mv_par01
	cFilialAte	:= mv_par02
	cMesAno	:= mv_par03
	cMes 		:= substr( mv_par03, 1, 2 )
	cAno 		:= substr( mv_par03, 3, 4 )
	cMatDe		:= mv_par04
	cMatAte    := mv_par05
	cCustoDe   := mv_par06
	cCustoAte  := mv_par07
	cNomeDe    := mv_par08
	cNomeAte   := mv_par09
	cSit       := mv_par10
	cCat       := mv_par11
	nOrdem		:= 1
	cArqNome	:= mv_par12				// Nome arquivo TXT

	/*
	��������������������������������������������������������������Ŀ
	� Variaveis utilizadas para parametros                         �
	� mv_par01        //  Filial De						           �
	� mv_par02        //  Filial Ate					           �
	� mv_par03        //  Mes/Ano Competencia ? 		           |
	� mv_par04        //  Matricula De                             �
	� mv_par05        //  Matricula Ate                            �
	� mv_par06        //  Centro de Custo De                       �
	� mv_par07        //  Centro de Custo Ate                      �
	� mv_par08        //  Nome De                                  �
	� mv_par09        //  Nome Ate                                 �
	� mv_par10        //  Situacoes ?		                       �
	� mv_par11        //  Categorias ?      		               �
	� mv_par12        //  Path/Nome Arquivo TXT ?                  �
	����������������������������������������������������������������*/

	G624CriTMP()			//--- Cria arquivo temporario

	/*
	����������������������������������������������Ŀ
	� Processa os dados gravando arq. temporario   �
	������������������������������������������������*/
	ImpAsCajaS(.T.)

	/*
	����������������������������������������������Ŀ
	� Gera o arquivo texto                         �
	������������������������������������������������*/
	If Select(cAliasTMP) > 0 .And. (cAliasTMP)->(RecCount()) > 0

		G624GerTXT()

	Else
		MsgStop(STR0019+cArqNome)	// "Nao foi gerado o arquivo "
	Endif

	If Select(cAliasTMP) > 0
		If oTmpTable <> Nil   
			oTmpTable:Delete()  
			oTmpTable := Nil 
		EndIf 	
	EndIf

Return Nil

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � G624Grava  � Autor � Ricardo Berti	      � Data �02/04/2013���
���������������������������������������������������������������������������Ĵ��
���Desc.     � Grava um registro no arq. temporario		                 	���
���������������������������������������������������������������������������Ĵ��
��� Uso      � GPR624Proc()                                                 ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function G624Grava()

	RecLock(cAliasTMP,.T.)
	(cAliasTMP)->TMP_CI		:= (cQrySRA)->RA_CIC
	(cAliasTMP)->TMP_NOME	:= 	Ltrim(Rtrim((cQrySRA)->RA_PRISOBR) + Space(1)) +;
	Ltrim(Rtrim((cQrySRA)->RA_SECSOBR) + Space(1)) +;
	Ltrim(Rtrim((cQrySRA)->RA_PRINOME) + Space(1)) +;
	Alltrim((cQrySRA)->RA_SECNOME)
	(cAliasTMP)->TMP_APORTE	:= nTotAport
	(cAliasTMP)->(MsUnlock())

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �G624CriTMP� Autor � Ricardo Berti	      	� Data �02/04/2013���
�������������������������������������������������������������������������Ĵ��
���Descricao �Cria arquivo temporario                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �GPR624Proc()								  				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function G624CriTMP()

	Local aArea		:= GetArea()
	Local aCampos   := {}
	Local cTrab
	Local aOrdem := {}

	cAliasTMP := CriaTrab(aCampos,.F.) 

	aAdd( aCampos, { 'TMP_CI'		, "C", TamSX3('RA_CIC')[1]	, 0 } )
	aAdd( aCampos, { 'TMP_NOME'		, "C", 50	, 0 } )
	aAdd( aCampos, { 'TMP_APORTE'	, "N", 12	, 2 } )

	If Select(cAliasTMP) > 0
		dbSelectArea(cAliasTMP)
		dbCloseArea()
	EndIf

	oTmpTable := FWTemporaryTable():New(cAliasTMP)
	oTmpTable:SetFields( aCampos ) 
		
	aOrdem	:=	{"TMP_CI"}

	oTmpTable:AddIndex("IND", aOrdem)
	oTmpTable:Create() 

	RestArea( aArea )

Return Nil

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � G624GerTXT   � Autor � Ricardo Berti	     � Data � 04/10/13 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Funcao que gera o arquivo texto                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � GPR624Proc()                                                ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function G624GerTXT()

	Local cLinDet	:= ""
	Local cSep	  	:= "|"
	Local nHandle 	:= MSFCREATE(cArqNome)

	If FERROR() # 0 .Or. nHandle < 0
		Help('',1, "OPENERROR",,STR0020+cArqNome,1)  // "Erro na cria��o do arquivo "
		FClose(nHandle)
		Return Nil
	EndIf

	dbSelectArea(cAliasTMP)
	dbGoTop()

	While !Eof()

		cLinDet	:=	AllTrim(TMP_CI)	  			+cSep+;    //123456789|TARQUI SOLARES JULIO CESAR|204.12
		AllTrim(TMP_NOME)			+cSep+;
		LTrim(Str(TMP_APORTE,12,2))
		FWrite(nHandle,cLinDet+CRLF)

		dbSkip()
	EndDo
	FClose(nHandle)

	MsgInfo(STR0021) // "O arquivo foi gerado com sucesso."

Return Nil
