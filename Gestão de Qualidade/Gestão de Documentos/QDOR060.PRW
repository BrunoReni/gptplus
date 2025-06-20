#INCLUDE "QDOR060.CH"
#INCLUDE "Report.CH"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QDOR060  � Autor � Leandro S. Sabino     � Data � 01/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Protocolo de Entrega de Documentos		                  ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR060	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QDOR060(lBat)
Local oReport
//��������������������������������������������������������������Ŀ
//� Variavel utiLizada para verificar se o relatorio foi iniciado�
//� pelo MNU ou pela rotina de documentos.                       �
//����������������������������������������������������������������
lBat:= If(lBat == NIL,.F.,lBat)
Private cPerg	:= If(lBat,"QDR061","QDR060")

//������������������������������Ŀ
//�Salva a posicao do Documento  �
//��������������������������������
	If lBat
		Private cChave:= M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
	Endif

	If TRepInUse()
		// Interface de impressao
		//��������������������������������������������������������������������Ŀ
		//� Variaveis utiLizadas para parametros                               �
		//� mv_par01	// Quebra por Departamento 1- Sim 2-Nao                 �
		//� mv_par02	// De Documento                                         �
		//� mv_par03	// Ate Documento                                        �
		//� mv_par04	// De  Revisao                                          �
		//� mv_par05	// Ate Revisao                                          �
		//� mv_par06	// De  Depto. Destino                                   �
		//� mv_par07	// Ate Depto. Destino  
		//� mv_par08	// Tipo de Distribuicao                                    �
		//����������������������������������������������������������������������
		Pergunte(cPerg,.F.) 
		oReport := ReportDef(lBat)
		oReport:PrintDialog()
	Else
		QDOR060R3(lBat) 
	EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 01/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef(lBat)
Local oReport                                             
Local oSection1, oSection2 

DEFINE REPORT oReport NAME "QDOR060" TITLE OemToAnsi(STR0001) PARAMETER cPerg   ACTION {|oReport| PrintReport(oReport,lBat)} DESCRIPTION (OemToAnsi(STR0002)+OemToAnsi(STR0003)+OemToAnsi(STR0004))
//"PROTOCOLO DE ENTREGA DE DOCUMENTOS E REGISTROS DA QUALIDADE"
//"Este programa ir� imprimir o Protocolo de Entrega de Documentos"
//"e Registros da QuaLidade, que assegura o recebimento de documentos"
//"por todos os envolvidos em sua implementa��o"

oReport:SetPortrait() 


DEFINE SECTION oSection1 OF oReport TABLES "TRB","QDH" TITLE STR0019 
DEFINE CELL NAME "DOCTO"  OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0019) SIZE 50// "Documento"
DEFINE CELL NAME "RV"     OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0020) SIZE 03//"Revisao" 
DEFINE CELL NAME "TITULO" OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0021) AUTO SIZE//"Titulo" 
DEFINE CELL NAME "DESCTP" OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0022) SIZE 80//"Texto do protocolo"
oSection1:Cell("DESCTP"):SeTLineBREAK(.T.)


DEFINE SECTION oSection2 OF oSection1 TITLE Oemtoansi(STR0025) //"Responsavel"
DEFINE CELL NAME "DEPTO" OF oSection2 TITLE OemToAnsi(STR0023) SIZE 30//"Depto"
DEFINE CELL NAME "SETOR" OF oSection2 TITLE OemToAnsi(STR0024) SIZE 26//"Setor"
DEFINE CELL NAME "RESP"  OF oSection2 TITLE OemToAnsi(STR0025) SIZE 30//"Responsavel"
DEFINE CELL NAME "TIPO"  OF oSection2 TITLE OemToAnsi(STR0026) SIZE 20//"Tipo"
DEFINE CELL NAME "NCOP"  OF oSection2 TITLE OemToAnsi(STR0027) SIZE 23//"Copias"
DEFINE CELL NAME "DATADOC"  OF oSection2 TITLE OemToAnsi(STR0028) SIZE 12//"Data"
DEFINE CELL NAME "Assin" OF oSection2 TITLE OemToAnsi(STR0029) SIZE 25  //"Assinatura"
Return oReport


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 01/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1,ExpO21)   	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          | ExpO2 = variavel lBat									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR080                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintReport( oReport,lBat)
Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(1):Section(1)
Local cTipPro    := GETMV("MV_QDOTPPR") // Parametro para impressao de somente copias em pael ou nao
Local cAliasQDH  := "QDH"
Local cAliasQD1  := "QD1"
Local cBreak	 := .F. 
Local cFiltro	 := ""
Local cKey		 := ""
Local cTPDIST	 := ""
Local cChave1	 := ""             
Local cChave2	 := ""             
Local cChave3	 := ""             
Local cProtocolo := "" 
Local aCampos    := {}
Local aTexC      := {}
Local nI        
Local cNomArq    := ""
Local cIndex     := ""
Local cIndex2    := ""
Local aRegQDG	 := {}
Local lPrim      :=.F.
Local cTpDistr  := iif(!lbat,iif(type("MV_PAR08")='N', cvaltochar(mv_par08),mv_par08),iif(type("MV_PAR02")='N', cvaltochar(mv_par02), mv_par02))
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
	if lbat
	mv_par08 :=mv_par02
	EndIf

DbSelectArea("QD2")
DbSetOrder(1)

DbSelectArea("QDG")
DbSetOrder(3)

DbSelectarea("QD1")
DbSetOrder(1)

DbSelectarea("QDH")                                                           
DbSetOrder(1)

//��������������������������������������Ŀ
//� Cria Arquivo de Trabalho temporario  �
//����������������������������������������
Aadd(aCampos,{"DOCTO"	,"C",18,0})
Aadd(aCampos,{"RV"  	,"C",03,0})
Aadd(aCampos,{"TITULO"	,"C",100,0})
Aadd(aCampos,{"DESCTP"	,"C",1000,0})
Aadd(aCampos,{"DEPTO"	,"C",30,0})
Aadd(aCampos,{"SETOR"	,"C",26,0})
Aadd(aCampos,{"RESP"	,"C",30,0})
Aadd(aCampos,{"TIPO"	,"C",20,0})
Aadd(aCampos,{"NCOP"	,"C",23,0})
Aadd(aCampos,{"DATADOC"	,"C",12,0})
Aadd(aCampos,{"Assin"	,"C",25,0})	
Aadd(aCampos,{"QDHREC"  ,"N",10,0})
Aadd(aCampos,{"QD1REC"  ,"N",10,0})

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("indice1", {"DOCTO","RV","DEPTO"} )
oTempTable:Create()

//����������������������������������Ŀ
//� Manipula dados do arquivos QDH 	 �
//������������������������������������
	If !lBat
	cIndex	:= CriaTrab(NIL,.F.)
	cFiltro:= 'QDH->QDH_FILIAL == "'+xFiLial("QDH")+'".And. '
	cFiltro+= 'QDH->QDH_DOCTO >= "'+mv_par02+'".And. QDH->QDH_DOCTO <= "'+mv_par03+'".And. '
	cFiltro+= 'QDH->QDH_RV >= "'+mv_par04+'".And. QDH->QDH_RV <= "'+mv_par05+'"'
		If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QDH")))
		cFiltro+= ' .And. '+oReport:Section(1):GetAdvplExp("QDH")
		Endif
	IndRegua(cAliasQDH,cIndex,QDH->(IndexKey()),,cFiltro,OemToAnsi(STR0007))	//"Selecionando Registros.."
	dbGoTop()
	Else
	QDH->(DbSeek(cChave))//Retorna a Posicao do QDH - Documentos
	EndIf

//����������������������������������Ŀ
//� Manipula dados do arquivos QD1 	 �
//������������������������������������
cIndex2:= CriaTrab(Nil,.F.)
cKey   := QD1->(IndexKey())
	If !lBat
		cFiltro:= 'QD1->QD1_FILIAL == "'+xFiLial("QD1")+'".And. '
		cFiltro+= 'QD1->QD1_DOCTO >= "'+mv_par02+'".And. QD1->QD1_DOCTO <= "'+mv_par03+'".And. '
		cFiltro+= 'QD1->QD1_RV >= "'+mv_par04+'".And. QD1->QD1_RV <= "'+mv_par05+'".And. '
		cFiltro+= 'QD1->QD1_DEPTO >= "'+mv_par06+'".And. QD1->QD1_DEPTO <= "'+mv_par07+'".And. '
		cFiltro+= 'QD1->QD1_TPPEND == "L  " .And. QD1->QD1_SIT <> "I"'
	Else
		cFiltro:= 'QD1->QD1_FILIAL == "'+QDH->QDH_FILIAL+'".And. '
		cFiltro+= 'QD1->QD1_DOCTO == "'+QDH->QDH_DOCTO+'".And. '
		cFiltro+= 'QD1->QD1_RV == "'+QDH->QDH_RV+'".And. '
		cFiltro+= 'QD1->QD1_TPPEND == "L  " .And. QD1->QD1_SIT <> "I"'
	EndIf

	If cTipPro == "S"
		cFiltro+= '.And. QD1->QD1_TPDIST $ "2,3"'
	Else
		If mv_par08 == 3
			cFiltro +=  " .And. (QD1->QD1_TPDIST == '1' "
			cFiltro +=  " .Or. QD1->QD1_TPDIST == '2' "
			cFiltro +=  " .Or. QD1->QD1_TPDIST == '3') "
		Else
			cFiltro +=  " .And. (QD1->QD1_TPDIST == '" + cvaltochar(mv_par08) + "' "	
			cFiltro +=  " .Or. QD1->QD1_TPDIST == '3') "
		Endif
	Endif 
	If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QD1")))
		cFiltro+= ' .And. '+oReport:Section(1):GetAdvplExp("QD1")
	Endif

	IndRegua(cAliasQD1,cIndex2,cKey,,cFiltro,OemToAnsi(STR0007))	//"Selecionando Registros.."
	dbGoTop()

	//������������������������������Ŀ
	//� Processando os arquivos 	 �
	//�������������������������������� 
	If !lBat //Relat�rios via menu
		
		cQuery :=  " SELECT DISTINCT QD1.QD1_FILIAL, "
		cQuery +=  "                 QD1.QD1_FILMAT, "
		cQuery +=  "                 QD1.QD1_MAT, "
		cQuery +=  "                 QD1.QD1_TPDIST, "
		cQuery +=  "                 QD1.QD1_DOCTO, "
		cQuery +=  "                 QD1.QD1_RV, "
		cQuery +=  "                 QD1.QD1_DEPTO, "
		cQuery +=  "                 QD1.QD1_SIT "
		cQuery +=  "            FROM " +RetSQLName("QD1") +" QD1 "
		cQuery +=  "           WHERE QD1.QD1_FILIAL = '"+xFiLial("QD1")+"' "
		cQuery +=  "             AND QD1.QD1_DOCTO >= '"+mv_par02+"' " //Documento
		cQuery +=  "             AND QD1.QD1_DOCTO <= '"+mv_par03+"' " //Documento
		cQuery +=  "             AND QD1.QD1_RV    >= '"+mv_par04+"' " //Revis�o
		cQuery +=  "             AND QD1.QD1_RV    <= '"+mv_par05+"' " //Revis�o
		cQuery +=  "             AND QD1.QD1_DEPTO >= '"+mv_par06+"' " //Departamento
		cQuery +=  "             AND QD1.QD1_DEPTO <= '"+mv_par07+"' " //Departamento
		cQuery +=  "             AND QD1.QD1_SIT <> 'I' "
		cQuery +=  "             AND QD1.D_E_L_E_T_ <> '*' "
		cQuery +=  "             AND QD1.QD1_TPPEND = 'L'  "
		cQuery +=  "             AND QD1.QD1_TPDIST = '" + cTpDistr + "' " 
			
		cQuery +=  "           UNION "
			
		cQuery +=  " SELECT DISTINCT QDG.QDG_FILIAL, "
		cQuery +=  "                 QDG.QDG_FILMAT, "
		cQuery +=  "                 QDG.QDG_MAT, "
		cQuery +=  "                 QDG.QDG_TPRCBT, "
		cQuery +=  "                 QDG.QDG_DOCTO, "
		cQuery +=  "                 QDG.QDG_RV, "
		cQuery +=  "                 QDG.QDG_DEPTO, "
		cQuery +=  "                 QDG.QDG_SIT "
		cQuery +=  "            FROM " +RetSQLName("QDG") +" QDG "
		cQuery +=  "           WHERE QDG.QDG_FILIAL = '"+xFiLial("QDG")+"' "
		cQuery +=  "             AND QDG.QDG_DOCTO >= '"+mv_par02+"' " //Documento
		cQuery +=  "             AND QDG.QDG_DOCTO <= '"+mv_par03+"' " //Documento
		cQuery +=  "             AND QDG.QDG_RV    >= '"+mv_par04+"' " //Revis�o
		cQuery +=  "             AND QDG.QDG_RV    <= '"+mv_par05+"' " //Revis�o
		cQuery +=  "             AND QDG.QDG_DEPTO >= '"+mv_par06+"' " //Departamento
		cQuery +=  "             AND QDG.QDG_DEPTO <= '"+mv_par07+"' " //Departamento
		cQuery +=  "             AND QDG.QDG_SIT <> 'I' "
		cQuery +=  "             AND QDG.D_E_L_E_T_ <> '*' "
		cQuery +=  "             AND QDG.QDG_TPRCBT = '" + cTpDistr + "' "

	Else

		cQuery :=  " SELECT DISTINCT QD1.QD1_FILIAL, "
		cQuery +=  "                 QD1.QD1_FILMAT, "
		cQuery +=  "                 QD1.QD1_MAT, "
		cQuery +=  "                 QD1.QD1_TPDIST, "
		cQuery +=  "                 QD1.QD1_DOCTO, "
		cQuery +=  "                 QD1.QD1_RV, "
		cQuery +=  "                 QD1.QD1_DEPTO, "
		cQuery +=  "                 QD1.QD1_SIT "
		cQuery +=  "            FROM " +RetSQLName("QD1") +" QD1 "
		cQuery +=  "           WHERE QD1.QD1_FILIAL = '" + (cAliasQDH)->QDH_FILIAL + "' " 
		cQuery +=  "             AND QD1.QD1_DOCTO = '"+ (cAliasQDH)->QDH_DOCTO +"' " 
		cQuery +=  "             AND QD1.QD1_RV = '" + (cAliasQDH)->QDH_RV + "' "
		cQuery +=  "             AND QD1.QD1_SIT <> 'I' "
		cQuery +=  "             AND QD1.D_E_L_E_T_ <> '*' "
		cQuery +=  "             AND QD1.QD1_TPPEND = 'L'  "
		cQuery +=  "             AND QD1.QD1_TPDIST = '" + cTpDistr + "' "
			
		cQuery +=  "           UNION "
			
		cQuery +=  " SELECT DISTINCT QDG.QDG_FILIAL, "
		cQuery +=  "                 QDG.QDG_FILMAT, "
		cQuery +=  "                 QDG.QDG_MAT, "
		cQuery +=  "                 QDG.QDG_TPRCBT, "
		cQuery +=  "                 QDG.QDG_DOCTO, "
		cQuery +=  "                 QDG.QDG_RV, "
		cQuery +=  "                 QDG.QDG_DEPTO, "
		cQuery +=  "                 QDG.QDG_SIT "
		cQuery +=  "            FROM " +RetSQLName("QDG") +" QDG "
		cQuery +=  "           WHERE QDG.QDG_FILIAL = '" + (cAliasQDH)->QDH_FILIAL + "' " 
		cQuery +=  "             AND QDG.QDG_DOCTO = '"+ (cAliasQDH)->QDH_DOCTO +"' " 
		cQuery +=  "             AND QDG.QDG_RV = '" + (cAliasQDH)->QDH_RV + "' "
		cQuery +=  "             AND QDG.QDG_SIT <> 'I' "
		cQuery +=  "             AND QDG.D_E_L_E_T_ <> '*' "
		cQuery +=  "             AND QDG.QDG_TPRCBT = '" + cTpDistr + "' "

	EndIf

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), cAliasQry, .T., .T.)
   
    While (cAliasQDH)->(!Eof()) 
		
		While (cAliasQry)->(!Eof())

			If (cAliasQDH)->QDH_DOCTO+(cAliasQDH)->QDH_RV == (cAliasQry)->QD1_DOCTO+(cAliasQry)->QD1_RV

				RecLock("TRB",.T.)
			
				TRB->DOCTO := (cAliasQDH)->QDH_DOCTO
				TRB->RV    := (cAliasQDH)->QDH_RV
				TRB->TITULO:= (cAliasQDH)->QDH_TITULO
				TRB->QDHREC := (cAliasQDH)->(RECNO())	

				TRB->DEPTO := (cAliasQry)->QD1_DEPTO
				TRB->SETOR := QA_NDEPT((cAliasQry)->QD1_DEPTO,.T.,xFilial("QAD"))
				TRB->RESP  := (SubsTr(QA_NUSR((cAliasQry)->QD1_FILMAT,(cAliasQry)->QD1_MAT,.T.),1,30)) 

				cProtocolo:=""
			
				If QD2->(DbSeek(xFilial("QD2")+(cAliasQDH)->QDH_CODTP))
						aTexC:=JustificaTXT(MSMM(QD2->QD2_PROTOC,80),80,.T.)	
					For nI:=1 to Len(aTexC)
							cProtocolo += aTexC[nI]
					Next
						TRB->DESCTP := cProtocolo
				EndIf
				If (cAliasQry)->QD1_TPDIST <> "4"
					If QDG->(DbSeek((cAliasQry)->QD1_FILIAL+(cAliasQry)->QD1_DOCTO+(cAliasQry)->QD1_RV+(cAliasQry)->QD1_FILMAT+(cAliasQry)->QD1_DEPTO+(cAliasQry)->QD1_MAT))
						While QDG->(!Eof()) .And. QDG->QDG_DOCTO+QDG->QDG_RV+QDG->QDG_FILMAT+QDG->QDG_DEPTO+QDG->QDG_MAT == (cAliasQry)->QD1_DOCTO+(cAliasQry)->QD1_RV+(cAliasQry)->QD1_FILMAT+(cAliasQry)->QD1_DEPTO+(cAliasQry)->QD1_MAT
							If aScan(aRegQDG,{ |X| X == QDG->(Recno()) }) == 0 .AND. QDG->QDG_TPRCBT == (cAliasQry)->QD1_TPDIST
								aAdd(aRegQDG,QDG->(Recno()))
								Exit
							EndIf
							QDG->(DbSkip())
						EndDo
						If (QDG->QDG_TIPO == "D")
							TRB->TIPO :=OemToAnsi(STR0017)
						Else	
							TRB->TIPO :=OemToAnsi(STR0018)
						Endif

						TPDIST := QDORSTR60((cAliasQry)->QD1_TPDIST)

						TRB->NCOP := (StrZero(QDG->QDG_NCOP,4))+" "+TPDIST
					Endif
				Else
				
					TPDIST := QDORSTR60((cAliasQry)->QD1_TPDIST)

					TRB->NCOP := (StrZero(00,4))+" "+TPDIST

				Endif
				TRB->QD1REC := (cAliasQry)->(RECNO())	        
				TRB->DATADOC  := "___/___/___"
				TRB->Assin := RepLicate("_",40)
				TRB->(MsUnlock())
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbGoTop())

		(cAliasQDH)->(dbSkip())
	EndDo

	If mv_par01 == 1
		cBreak:= .T.
	Else
		cBreak:= .F.
	Endif
	
	//���������������������������������Ŀ
	//� Impressao do arquivo temporario �
	//|����������������������������������
	dbSelectArea("TRB")
	dbGoTop()
	oSection2:SetLinesBefore(3)
	While !oReport:Cancel() .And. TRB->(!Eof())
		dbselectarea("QDH")// posiciona tabelas para posibilitar personalizar campos no relatorio
		QDH->(dbgoto(TRB->QDHREC))
		dbselectarea("QD1")
		QD1->(dbgoto(TRB->QD1REC))
		If cChave3 = TRB->DOCTO+TRB->RV+TRB->DEPTO+TRB->RESP
			TRB->(dbSkip())
			loop
		EndIf
		If cChave1 <> TRB->DOCTO+TRB->RV
			oSection1:Finish()
			oSection2:Finish()
			oSection1:Init()
			oSection1:PrintLine()
			oSection2:Init()
			oSection1:SetPageBreak(.T.)
			lPrim := .T.
		Else
			If cChave2 <> TRB->DOCTO+TRB->RV+TRB->DEPTO
				If cBreak
					oSection1:SetPageBreak(.T.) 
					oSection1:Finish()
					oSection2:Finish()
					oSection1:Init()
					oSection1:PrintLine()
					oSection2:Init()					
					lPrim := .T.
				Endif
			Endif
		EndIf
		cChave1 := TRB->DOCTO+TRB->RV
		cChave2 := TRB->DOCTO+TRB->RV+TRB->DEPTO

		If lPrim
			oSection2:Cell("DEPTO"):SetValue("")
			oSection2:Cell("SETOR"):SetValue("")
			oSection2:Cell("RESP"):SetValue("")
			oSection2:Cell("Tipo"):SetValue("")
			oSection2:Cell("NCOP"):SetValue("")
			oSection2:Cell("DATADOC"):SetValue("")
			oSection2:Cell("Assin"):SetValue("")
			lPrim := .F.

		Else
			oSection2:Cell("DEPTO"):SetValue(TRB->DEPTO)
			oSection2:Cell("SETOR"):SetValue(TRB->SETOR)
			oSection2:Cell("RESP"):SetValue(TRB->RESP)
			oSection2:Cell("Tipo"):SetValue(TRB->Tipo)
			oSection2:Cell("NCOP"):SetValue(TRB->NCOP)
			oSection2:Cell("DATADOC"):SetValue(TRB->DATADOC)
			oSection2:Cell("Assin"):SetValue(TRB->Assin)

			cChave3 := TRB->DOCTO+TRB->RV+TRB->DEPTO+TRB->RESP
			TRB->(dbSkip())
		Endif
		oSection2:PrintLine()
		oReport:SkipLine(3)
	Enddo
             
TRB->(DbCloseArea())
//��������������������������������������������������������������Ŀ
//� Devolve as ordens originais dos arquivos                     �
//����������������������������������������������������������������
RetIndex("QDH")
Set Filter to

RetIndex("QD1")
Set Filter to

QDG->(DbSetOrder(1))

//��������������������������������������������������������������Ŀ
//� Apaga indices de trabalho                                    �
//����������������������������������������������������������������
oTempTable:Delete()

cIndex  += OrdBagExt()
Delete File &(cIndex)

cIndex2 += OrdBagExt()
Delete File &(cIndex2)

Return



/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QDOR060  � Autor � Rodrigo de A. Sartorio� Data � 15/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Protocolo de Entrega de Documentos e Registros da QuaLidade���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR060R3                                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALiZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Eduardo S.  �28/03/02� ---- � Otimizacao e Melhoria.                   ���
���Eduardo S.  �03/09/02� ---- � Acerto para listar corretamente o texto  ���
���            �        �      � do protocolo.                            ���
���Eduardo S.  �08/11/02� ---- � Acerto para imprimir o docto correto.    ���
���Eduardo S.  �16/01/03�061944� Acerto para listar somente os usuarios   ���
���            �        �      � ativos.                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QDOR060R3(lBat)

Local cTitulo:= OemToAnsi(STR0001) //"PROTOCOLO DE ENTREGA DE DOCUMENTOS E REGISTROS DA QUALIDADE"
Local cDesc1 := OemToAnsi(STR0002) //"Este programa ir� imprimir o Protocolo de Entrega de Documentos"
Local cDesc2 := OemToAnsi(STR0003) //"e Registros da QuaLidade, que assegura o recebimento de documentos"
Local cDesc3 := OemToAnsi(STR0004) //"por todos os envolvidos em sua implementa��o"
Local cString:= "QDH"
Local wnrel	 := "QDOR060"
Local Tamanho:= "P"

//��������������������������������������������������������������Ŀ
//� Variavel utiLizada para verificar se o relatorio foi iniciado�
//� pelo MNU ou pela rotina de documentos.                       �
//����������������������������������������������������������������
lBat:= If(lBat == NIL,.F.,lBat)

Private cPerg	 := If(lBat,"QDR061","QDR060")
Private aReturn := { STR0005,1,STR0006, 2, 2, 1, "",1 } //"Zebrado"###"Administra��o"
Private nLastKey:= 0
Private INCLUI	 := .F.	// Colocada para utiLizar as funcoes

//������������������������������Ŀ
//�Salva a posicao do Documento  �
//��������������������������������
	If lBat
	Private cChave:= M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
	Endif

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������������Ŀ
//� Variaveis utiLizadas para parametros                               �
//� mv_par01	// Quebra por Departamento 1- Sim 2-Nao                 �
//� mv_par02	// De Documento                                         �
//� mv_par03	// Ate Documento                                        �
//� mv_par04	// De  Revisao                                          �
//� mv_par05	// Ate Revisao                                          �
//� mv_par06	// De  Depto. Destino                                   �
//� mv_par07	// Ate Depto. Destino                                   �
//����������������������������������������������������������������������
Pergunte(cPerg,.F.)

wnrel  := SetPrint(cString,wnrel,cPerg,ctitulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)
cTitulo:= If(TYPE("NewHead") <> "U",NewHead,cTitulo)

	If nLastKey == 27
	Return
	Endif

SetDefault(aReturn,cString)

	If nLastKey == 27
	Return
	Endif

RptStatus({|lEnd| QDOR060Imp(@lEnd,ctitulo,wnRel,tamanho,lBat)},ctitulo)

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QDOR060Imp� Autor � Rodrigo de A. Sartorio� Data � 15/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia para funcao que faz a impressao do relatorio.        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function QDOR060Imp(lEnd,ctitulo,wnRel,tamanho,lBat)

Local cCabec1  := ""
Local cOldDoc	:= ""
Local cOldDepto:= ""
Local cCompara	:= ""
Local cCompara2:= ""
Local cIndex1	:= ""
Local cIndex2	:= ""
Local cFiltro	:= ""
Local cKey		:= ""
Local cFilDep  := xFilial("QAD")
Local cTipPro  := GETMV("MV_QDOTPPR") // Parametro para impressao de somente copias em pael ou nao
Local aRegQDG  := {}
Local cTpDistr  := iif(!lbat,iif(type("MV_PAR08")='N', cvaltochar(mv_par08),mv_par08),iif(type("MV_PAR02")='N', cvaltochar(mv_par02), mv_par02))
	if lbat
		mv_par08 :=mv_par02
	EndIf

	Private aDriver := ReadDriver()

	DbSelectArea("QD2")
	DbSetOrder(1)

	DbSelectArea("QDG")
	DbSetOrder(3)

	DbSelectarea("QD1")
	DbSetOrder(1)

	DbSelectarea("QDH")
	DbSetOrder(1)

	If !lBat
		//�������������������������������������������������Ŀ
		//� Cria Indice Condicional nos arquivos utiLizados �
		//���������������������������������������������������
		cIndex1:= CriaTrab(Nil,.F.)
		cKey   := QDH->(IndexKey())	
		cFiltro:= 'QDH->QDH_FILIAL == "'+xFiLial("QDH")+'".And. '
		cFiltro+= 'QDH->QDH_DOCTO >= "'+mv_par02+'".And. QDH->QDH_DOCTO <= "'+mv_par03+'".And. '
		cFiltro+= 'QDH->QDH_RV >= "'+mv_par04+'".And. QDH->QDH_RV <= "'+mv_par05+'"'
		IndRegua("QDH",cIndex1,cKey,,cFiltro,OemToAnsi(STR0007))	//"Selecionando Registros.."
	Else
		//���������������������������������������Ŀ
		//�Retorna a Posicao do QDH - Documentos  �
		//�����������������������������������������
		QDH->(DbSeek(cChave))
	EndIf

	cIndex2:= CriaTrab(Nil,.F.)
	cKey   := QD1->(IndexKey())
	If !lBat
		cFiltro:= 'QD1->QD1_FILIAL == "'+xFiLial("QD1")+'".And. '
		cFiltro+= 'QD1->QD1_DOCTO >= "'+mv_par02+'".And. QD1->QD1_DOCTO <= "'+mv_par03+'".And. '
		cFiltro+= 'QD1->QD1_RV >= "'+mv_par04+'".And. QD1->QD1_RV <= "'+mv_par05+'".And. '
		cFiltro+= 'QD1->QD1_DEPTO >= "'+mv_par06+'".And. QD1->QD1_DEPTO <= "'+mv_par07+'".And. '
		cFiltro+= 'QD1->QD1_SIT <> "I" '
		if mv_par08 <> 4
			cFiltro+= '.And. QD1->QD1_TPPEND == "L  "	'		
		endif
	Else
		cFiltro:= 'QD1->QD1_FILIAL == "'+QDH->QDH_FILIAL+'".And. '
		cFiltro+= 'QD1->QD1_DOCTO == "'+QDH->QDH_DOCTO+'".And. '
		cFiltro+= 'QD1->QD1_RV == "'+QDH->QDH_RV+'".And. '
		cFiltro+= 'QD1->QD1_SIT <> "I" '
		If mv_par08 <> IIF(Valtype(mv_par08) = "C", "4", 4)
			cFiltro+= '.And. QD1->QD1_TPPEND == "L  "	'		
		endif
	EndIf

	If cTipPro == "S"
		cFiltro+= '.And. QD1->QD1_TPDIST $ "2,3"'
	Else
		if MV_PAR08 == 3
			cFiltro+=  ' .AND. (QD1->QD1_TPDIST == "3") '
		Elseif mv_par08 == 4
			cFiltro+= ' .AND. (QD1->QD1_TPDIST == "4") '
		Else
			cFiltro+=  ' .AND. (QD1->QD1_TPDIST == "'+ cvaltochar(mv_par08)+'"
			cFiltro+=  ' .OR. QD1->QD1_TPDIST == "3") '
		Endif
	Endif

IndRegua("QD1",cIndex2,cKey,,cFiltro,OemToAnsi(STR0007))	//"Selecionando Registros.."

//          1         2         3         4         5         6         7         8
//012345678901234567890123456789012345678901234567890123456789012345678901234567890
//RESPONSAVEL                  TIPO    COPIAS                DATA    ASSINATURA

cCabec1:= OemToAnsi(STR0008) // "RESPONSAVEL                  TIPO    COPIAS                DATA    ASSINATURA"

Li   := 80
m_pag:= 1

SetRegua(If(!lBat,QDH->(LastRec()),QD1->(LastRec()))) // Total de Elementos da Regua

	While QDH->(!Eof())
	cCompara:= "QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV"	
		If QD1->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV))
		//COMPARACAO DO QDH COM O QD1
			While QD1->(!Eof()) .And. QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV == &(cCompara)
             
				If QDH->QDH_DOCTO+QDH->QDH_RV <> cOldDoc
				cOldDoc:= QDH->QDH_DOCTO+QDH->QDH_RV
				Li:= 80
				EndIf
			//��������������������������������������������������������������Ŀ
			//� Caso parametrizado, quebra pagina por departamento destino   �
			//����������������������������������������������������������������
				If QD1->QD1_DEPTO <> cOldDepto
					If !Empty(cOldDepto) .And. mv_par01 == 1
					Li:= 80
					Else
						If Li > 54
						Cabec060(@Li,cTitulo)
						EndIf
					cOldDepto:= QD1->QD1_DEPTO
					EndIf
				EndIf
				If Li > 58
				Cabec060(@Li,cTitulo)
				EndIf
				If lEnd
				Li++
				@ PROW()+1,001 PSAY OemToAnsi(STR0009) //"CANCELADO PELO OPERADOR"
				Exit
				EndIf
				If FWModeAccess("QAD") == "E" //!Empty(cFilDep)
				cFilDep:= QD1->QD1_FILMAT
				EndIf
			@ Li,000 PSay Upper(OemToAnsi(STR0010))+AllTrim(QD1->QD1_DEPTO)+" - "+QA_NDEPT(QD1->QD1_DEPTO,.T.,cFilDep) //"Departamento: "
			Li++			
			cSeek2   := QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_DEPTO
			cCompara2:= "QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_DEPTO"
				If QD1->(DbSeek(cSeek2))
				@ Li,000 PSay cCabec1
				Li++
				@ Li,000 PSay __PrtFatLine()
				Li++
				aRegQDG := {}
					While QD1->(!Eof()) .And. cSeek2 == &(cCompara2)

						If QD1->QD1_SIT == "I"
						QD1->(DbSkip())
						Loop
						EndIf

					IncRegua()
						If Li > 58
						Cabec060(@Li,cTitulo)
							If FWModeAccess("QAD") == "E" //!Empty(cFilDep)
							cFilDep:= QD1->QD1_FILMAT
							EndIf
						@ Li,000 PSay Upper(OemToAnsi(STR0010))+AllTrim(QD1->QD1_DEPTO)+" - "+QA_NDEPT(QD1->QD1_DEPTO,.T.,cFilDep) //"Departamento: "
						Li++
						@ Li,000 PSay cCabec1
						Li++
						@ Li,000 PSay __PrtFatLine()
						Li++
						EndIf
						If lEnd
						Li++
						@ PROW()+1,001 PSAY OemToAnsi(STR0009) //"CANCELADO PELO OPERADOR"
						Exit
						EndIf
					Li++
					@ Li,000 PSay SubsTr(QA_NUSR(QD1->QD1_FILMAT,QD1->QD1_MAT,.T.),1,23)
					
						If QDG->(DbSeek(QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_FILMAT+QD1->QD1_DEPTO+QD1->QD1_MAT))
							While QDG->(!Eof()) .And. QDG->QDG_DOCTO+QDG->QDG_RV+QDG->QDG_FILMAT+QDG->QDG_DEPTO+QDG->QDG_MAT == QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_FILMAT+QD1->QD1_DEPTO+QD1->QD1_MAT
								If aScan(aRegQDG,{ |X| X == QDG->(Recno()) }) == 0 .AND. QDG->QDG_TPRCBT == QD1->QD1_TPDIST
								aAdd(aRegQDG,QDG->(Recno()))
								Exit
								Endif
							QDG->(DbSkip())
							Enddo
						@ Li,024 PSay If(QDG->QDG_TIPO == "D",OemToAnsi(STR0017),OemToAnsi(STR0018)) // "Usuario" ### "Pasta"
						@ Li,032 PSay StrZero(QDG->QDG_NCOP,4)					
						EndIf
					
					@ Li,036 PSay QDORSTR60(QD1->QD1_TPDIST)
					@ Li,055 PSay "___/___/___"
					@ Li,068 PSay RepLicate("_",12)					
					Li++
					QD1->(DbSkip())
					EndDo
				EndIf
			@ Li,000 Psay __PrtThinLine()
			Li+=2
			EndDo
		EndIf
		If lBat
		Exit
		EndIf
	QDH->(DbSkip())
	EndDo

//��������������������������������������������������������������Ŀ
//� Devolve as ordens originais dos arquivos                     �
//����������������������������������������������������������������
RetIndex("QDH")
Set Filter to

RetIndex("QD1")
Set Filter to

QDG->(DbSetOrder(1))

//��������������������������������������������������������������Ŀ
//� Apaga indices de trabalho                                    �
//����������������������������������������������������������������
cIndex1 += OrdBagExt()
Delete File &(cIndex1)

cIndex2 += OrdBagExt()
Delete File &(cIndex2)

Set Device To Screen

	If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
	Endif
MS_FLUSH()

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Cabec060  � Autor � Rodrigo de A. Sartorio� Data � 16/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime dados pertinentes ao cabecalho do programa.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cabec060(ExpN1,ExpC1)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Posicao da Linha                                   ���
���          � ExpC1 - Titulo do Relatorio                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function Cabec060(Li,cTitulo)

Local nCnt     := 0
Local cArqTexto:= " "
Local aTexC    := {}
Local nI       := 1

	If aReturn[4] == 1  // Comprimido
	@ 0,0 PSAY &(aDriver[1])
	Else					  // Normal
	@ 0,0 PSAY &(aDriver[2])
	Endif

Li:= 0
@ Li,000 PSay __PrtLogo()

Li+=3
@ Li,000 PSay __PrtCenter(cTitulo) //"PROTOCOLO DE ENTREGA DE DOCUMENTOS E REGISTROS DA QUALIDADE"

Li+=3
@ Li,000 PSay Upper(OemToAnsi(STR0015))+AllTrim(QDH->QDH_DOCTO)+"/"+QDH->QDH_RV	// "Documento: "

Li++
@ Li,000 PSay OemToAnsi(STR0016)+Substr(Alltrim(QDH->QDH_TITULO),1,70) // "T�tulo :"

	If !Empty(Substr(Alltrim(QDH->QDH_TITULO),71))
	Li++
	@ Li,009 PSay Substr(Alltrim(QDH->QDH_TITULO),71)
	EndIf
Li++

//������������������������������������������������������������Ŀ
//� Imprime Texto do protocolo                          	   �
//��������������������������������������������������������������
	If QD2->(DbSeek(xFilial("QD2")+QDH->QDH_CODTP))
	Li++
  	aTexC:=JustificaTXT(MSMM(QD2->QD2_PROTOC,80),80,.T.)	
		For nI:=1 to Len(aTexC)
      	@ Li,000 PSay aTexC[nI]
      	Li++
		Next
	EndIf
Li++

Return

/*/{Protheus.doc} QDORSTR60
Fun��o gen�rica para validar o tipo de distribui��o
@type function
@version 
@author thiago.rover
@since 20/02/2020
@param cTPDIST, character, param_description
@return return_type, return_description
/*/
Function QDORSTR60(cTPDIST)

	Local cSTRDIST := ""

	Do Case 
		Case cTPDIST == "1"
			cSTRDIST:=OemToAnsi(STR0011)// " Eletronicas"
		Case cTPDIST == "2"
			cSTRDIST:=OemToAnsi(STR0012)// " Em Papel"
		Case cTPDIST == "3"
			cSTRDIST:=OemToAnsi(STR0013)// " Eletronica/Papel"
		Case cTPDIST == "4"
			cSTRDIST:=OemToAnsi(STR0014)// " Nao Recebe"
	EndCase

Return cSTRDIST