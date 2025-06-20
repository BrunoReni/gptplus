#INCLUDE "QDOR061.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Report.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QDOR061   �Autor  �Leandro Sabino      � Data �  05/07/06	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Aviso de Recebimento de Documentos e Registros da Qualidade ���
���          � (Versao Relatorio Personalizavel)                          ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                            
Function QDOR061(lBat)
Local oReport

//�������������������������������������������������������������������������Ŀ
//� Variavel utilizada para verificar se o relatorio foi iniciado           �
//� pelo MNU ou pela rotina de documentos.                                  �
//���������������������������������������������������������������������������
lBat:=IF(lBat == NIL,.F.,lBat)
                                 
Private cPerg   := If(lBat,"QDR061","QDR060")

If TRepInUse()
	Pergunte(cPerg,.F.) 
    oReport := ReportDef(oReport,lBat)
    oReport:PrintDialog()
Else
	Return QDOR061R3(lBat)	// Executa vers�o anterior do fonte
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 05/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR061                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef(oReport,lBat)
Local cTitulo  := OemToAnsi(STR0001) // "AVISO DE RECEBIMENTO DE DOCUMENTOS E REGISTROS DA QUALIDADE"
Local cDesc1   := OemToAnsi(STR0002) // "Este programa ir� imprimir o Aviso de Recebimento de Documentos"
Local cDesc2   := OemToAnsi(STR0003	) // "e Registros da Qualidade, que assegura o recebimento de documentos"
Local cDesc3   := OemToAnsi(STR0004) // "por todos os envolvidos em sua implementa��o"
Local oSection1 
Local oSection2 
Local oSection3 
Local oSection4

DEFINE REPORT oReport NAME "QDOR061" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| PrintReport(oReport,lBat)} DESCRIPTION (cDesc1+cDesc2+cDesc3)
oReport:SetLandscape()

DEFINE SECTION oSection1 OF oReport TABLES "TRB","QDH" TITLE STR0018	//"Documento"
DEFINE CELL NAME "DOC"    OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0018) SIZE 16 //"Documento"
DEFINE CELL NAME "REVISAO"    OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0019) SIZE 03 //"Revisao"
DEFINE CELL NAME "TITULO" OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0020) SIZE 70 //"Titulo"

DEFINE SECTION oSection2 OF oSection1 TABLES "TRB","QD2" TITLE OemToAnsi(STR0021)  //"Protocolo"
DEFINE CELL NAME "QD2_MEMO1" OF oSection2 ALIAS "QD2" TITLE OemToAnsi(STR0021) SIZE 80 LINE BREAK //"Protocolo"
oReport:OnPageBreak({|| oSection2:Init(),;
						oSection2:Cell("QD2_MEMO1"):SetValue(MSMM(QD2->QD2_PROTOC)),;
                        oSection2:PrintLine(),;
                        oSection2:Finish(),;
                        oReport:SkipLine(1) })

DEFINE SECTION oSection3 OF oSection2 TABLES "TRB" TITLE OemToAnsi(STR0022) //"Departamento"
DEFINE CELL NAME "DEPTO" OF oSection3 ALIAS "TRB" TITLE OemToAnsi(STR0022) SIZE 50 //"Departamento"

DEFINE SECTION oSection4 OF oSection3 TABLES "TRB" TITLE OemToAnsi(STR0023) //"Responsavel"
DEFINE CELL NAME "Usu"   OF oSection4 ALIAS "TRB" TITLE OemToAnsi(STR0023) SIZE 20 //"Responsavel"
DEFINE CELL NAME "Tipo"  OF oSection4 ALIAS "TRB" TITLE OemToAnsi(STR0024) SIZE 13 //"Tipo"
DEFINE CELL NAME "Copia" OF oSection4 ALIAS "TRB" TITLE OemToAnsi(STR0025) SIZE 22 //"Copias"
DEFINE CELL NAME "DataDOC"  OF oSection4 ALIAS "TRB" TITLE OemToAnsi(STR0026) SIZE 10 //"Data"
DEFINE CELL NAME "Assin" OF oSection4 ALIAS "TRB" TITLE OemToAnsi(STR0027) SIZE 13 //"Assinatura"

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
Local oSection3  := oReport:Section(1):Section(1):Section(1)
Local oSection4  := oReport:Section(1):Section(1):Section(1):Section(1)
Local cTipPro    := GETMV("MV_QDOTPPR") // Parametro para impressao de somente copias em pael ou nao
Local cIndex1    := CriaTrab(Nil,.F.)
Local cIndex2    := CriaTrab(Nil,.F.)
Local cFilDep    := xFilial("QAD")
Local cAliasQDH  := "QDH"
Local cAliasQD1  := "QD1"
Local aRegQDG    := {}
Local aCampos    := {}
Local cFiltro    := " " 
Local cProtocolo := " " 
Local cChave	 := " "
Local lBreak     := .F.
Local nI         := 0
Local oTempTable := NIL

DbSelectArea("QDG")
DbSetOrder(3)

DbSelectarea("QD1")
DbSetOrder(1)

DbSelectArea("QDH")
DbSetOrder(1)

//��������������������������������������Ŀ
//� Cria Arquivo de Trabalho temporario  �
//����������������������������������������
Aadd(aCampos,{"DOC"	    ,"C",016,0})
Aadd(aCampos,{"REVISAO"	    ,"C",003,0})
Aadd(aCampos,{"TITULO"	    ,"C",100,0})
Aadd(aCampos,{"PROTOCOLO"	,"C",080,0})
Aadd(aCampos,{"DEPTO"      ,"C",050,0})
Aadd(aCampos,{"Usu"	    ,"C",020,0})
Aadd(aCampos,{"Tipo"	    ,"C",008,0})
Aadd(aCampos,{"Copia"	    ,"C",020,0})
Aadd(aCampos,{"DataDOC"	    ,"C",010,0})
Aadd(aCampos,{"Assin"	    ,"C",013,0})

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("indice1", {"DOC","REVISAO","DEPTO"} )
oTempTable:Create()

If lBat
	QDH->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV)) // Retorna a Posicao do QDH - Documentos
Endif

If !lBat
	//�������������������������������������������������Ŀ
	//� Cria Indice Condicional nos arquivos utiLizados �
	//���������������������������������������������������
	cIndex1:= CriaTrab(Nil,.F.)
	cKey   := QDH->(IndexKey())	
	cFiltro:='QDH_FILIAL=="'+xFilial("QDH")+'".And.'
	cFiltro+='QDH_DOCTO>="'+mv_par02+'".And.QDH_DOCTO<="'+mv_par03+'".And.'
	cFiltro+='QDH_RV>="'+mv_par04+'".And.QDH_RV<="'+mv_par05+'"'
	If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QDH")))
		cFiltro+= ' .And. '+oReport:Section(1):GetAdvplExp("QDH")
	Endif
	IndRegua("QDH",cIndex1,QDH->(IndexKey()),,cFiltro,STR0007)	//"Selecionando Registros.."
	dbGoTop()
EndIf

cIndex2:= CriaTrab(Nil,.F.)
cKey   := QD1->(IndexKey())
If !lBat
	cFiltro:='QD1_FILIAL=="'+xFilial("QD1")+'".And.'
	cFiltro+='QD1_DOCTO>="'+mv_par02+'".And.QD1_DOCTO<="'+mv_par03+'".And.'
	cFiltro+='QD1_RV>="'+mv_par04+'".And.QD1_RV<="'+mv_par05+'".And.'
	cFiltro+='QD1->QD1_DEPTO>="'+mv_par06+'".And.QD1->QD1_DEPTO<="'+mv_par07+'"'
	cFiltro+='.And.QD1->QD1_TPPEND=="L  ".And.QD1->QD1_SIT<>"I"'
Else
	cFiltro:='QD1_FILIAL=="'+QDH->QDH_FILIAL+'".And.'
	cFiltro+='QD1_DOCTO=="'+QDH->QDH_DOCTO+'".And.'
	cFiltro+='QD1_RV=="'+QDH->QDH_RV+'".And.'
	cFiltro+='QD1->QD1_TPPEND=="L  ".And.QD1->QD1_SIT<>"I"'
EndIf

If cTipPro == "S"
	cFiltro += '.And. QD1->QD1_TPDIST$"2,3"'
Endif
If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QD1")))
	cFiltro+= ' .And. '+oReport:Section(1):GetAdvplExp("QD1")
Endif

IndRegua(cAliasQD1,cIndex2,cKey,,cFiltro,OemToAnsi(STR0007))	//"Selecionando Registros.."
dbGoTop()

//������������������������������Ŀ
//� Processando os arquivos 	 �
//��������������������������������
While (cAliasQDH)->(!Eof())

	If (cAliasQD1)->(DbSeek((cAliasQDH)->QDH_FILIAL+(cAliasQDH)->QDH_DOCTO+(cAliasQDH)->QDH_RV))
		
		While (cAliasQD1)->(!Eof()) .And. (cAliasQDH)->QDH_FILIAL+(cAliasQDH)->QDH_DOCTO+(cAliasQDH)->QDH_RV ==;
									       (cAliasQD1)->QD1_FILIAL+(cAliasQD1)->QD1_DOCTO+(cAliasQD1)->QD1_RV

		If (cAliasQD1)->QD1_SIT == "I"
			Loop
		EndIf
         
		RecLock("TRB",.T.)
		
		TRB->DOC   := (cAliasQDH)->QDH_DOCTO
		TRB->REVISAO   := (cAliasQDH)->QDH_RV
		TRB->TITULO:= (cAliasQDH)->QDH_TITULO
		
		TRB->USU  := (SubsTr(QA_NUSR((cAliasQD1)->QD1_FILMAT,(cAliasQD1)->QD1_MAT,.T.),1,23)) 

		DbSelectArea("QD2")
		DbSetOrder(1)
		If QD2->(DbSeek(xFilial("QD2")+(cAliasQDH)->QDH_CODTP))
			TRB->Protocolo := QD2->QD2_PROTOC
		EndIf
	    
		TRB->DEPTO := (cAliasQD1)->QD1_DEPTO +" - "+QA_NDEPT(QD1->QD1_DEPTO,.T.,cFilDep)
		If QDG->(DbSeek((cAliasQD1)->QD1_FILIAL + (cAliasQD1)->QD1_DOCTO + (cAliasQD1)->QD1_RV + (cAliasQD1)->QD1_FILMAT + (cAliasQD1)->QD1_DEPTO + (cAliasQD1)->QD1_MAT))
				While QDG->(!Eof()) .And. QDG->QDG_DOCTO + QDG->QDG_RV + QDG->QDG_FILMAT + QDG->QDG_DEPTO + QDG->QDG_MAT == (cAliasQD1)->QD1_DOCTO + (cAliasQD1)->QD1_RV + (cAliasQD1)->QD1_FILMAT + (cAliasQD1)->QD1_DEPTO + (cAliasQD1)->QD1_MAT
					If aScan(aRegQDG,{ |X| X == QDG->(Recno()) }) == 0
						aAdd(aRegQDG,QDG->(Recno()))
						Exit
					Endif
					QDG->(DbSkip())
				Enddo  
			If (QDG->QDG_TIPO == "D")
				TRB->TIPO :=OemToAnsi(STR0016)//"Usuario" 
			Else	
				TRB->TIPO :=OemToAnsi(STR0017)//"Pasta"
			Endif	

		EndIf   

		If	(cAliasQD1)->QD1_TPDIST == "1" .Or. (cAliasQD1)->QD1_TPDIST == "2" .Or. (cAliasQD1)->QD1_TPDIST == "3"
			TRB->Copia := OemToAnsi(STR0011) // "Recebe"
		ElseIf QD1->QD1_TPDIST == "4"
			TRB->Copia := OemToAnsi(STR0012) // "N�o Recebe"
		EndIf
        

		TRB->DATADOC  := "___/___/___"
		TRB->Assin := RepLicate("_",16)
      
		MsUnlock()		
	    (cAliasQD1)->(dbSkip())
	EndDo
  Endif
  (cAliasQDH)->(dbSkip())
EndDo


//���������������������������������Ŀ
//� Impressao do arquivo temporario �
//|����������������������������������
If MV_PAR01 == 1
	lBreak := .T.
Endif	

dbSelectArea("TRB")
dbGoTop()
While !oReport:Cancel() .And. TRB->(!Eof())
   
   	If cChave <> TRB->DOC+TRB->REVISAO+TRB->DEPTO
		If lBreak
			oSection1:SetPageBreak(.T.) 
        Endif
        
		oSection1:Finish()
		oSection3:Finish()
		oSection4:Finish()
		oSection1:Init()
		oSection1:PrintLine()
		oSection3:Init()
		oSection3:PrintLine()
		oSection4:Init()

	EndIf

	oSection4:PrintLine()
	oReport:SkipLine(1)	      	
			
	cChave := TRB->DOC+TRB->REVISAO+TRB->DEPTO

	TRB->(dbSkip())

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

cIndex1  += OrdBagExt()
Delete File &(cIndex1)

cIndex2 += OrdBagExt()
Delete File &(cIndex2)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QDOR061R3� Autor � Newton R. Ghiraldelli � Data � 18/05/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Aviso de Recebimento de Documentos e Registros da Qualidade���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR061                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALiZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Eduardo S.  �26/12/01�012341� Acerto para posicionar corretamente na   ���
���            �        �      � filial do docto.                         ���
���Eduardo S.  �01/04/02� xxxx � Otimizacao e Melhoria.                   ���
���Eduardo S.  �03/09/02� ---- � Acerto para listar corretamente o texto  ���
���            �        �      � do protocolo.                            ���
���Eduardo S.  �08/11/02� ---- � Acerto para imprimir o docto correto.    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QDOR061R3(lBat)

Local cTitulo 	:= OemToAnsi(STR0001) // "AVISO DE RECEBIMENTO DE DOCUMENTOS E REGISTROS DA QUALIDADE"
Local cDesc1   := OemToAnsi(STR0002) // "Este programa ir� imprimir o Aviso de Recebimento de Documentos"
Local cDesc2 	:= OemToAnsi(STR0003	) // "e Registros da Qualidade, que assegura o recebimento de documentos"
Local cDesc3   := OemToAnsi(STR0004) // "por todos os envolvidos em sua implementa��o"
Local cString  := "QDH"
Local wnrel    := "QDOR061"
Local Tamanho	:= "P"

//�������������������������������������������������������������������������Ŀ
//� Variavel utilizada para verificar se o relatorio foi iniciado           �
//� pelo MNU ou pela rotina de documentos.                                  �
//���������������������������������������������������������������������������
lBat:=IF(lBat == NIL,.F.,lBat)

Private cPerg   := If(lBat,"QDR061","QDR060")
Private aReturn := {STR0005,1,STR0006, 2, 2, 1, "",1} //"Zebrado"###"Administra��o"
Private nLastKey:= 0
Private INCLUI  := .F.	// Colocada para utilizar as funcoes

//������������������������������Ŀ
//�Salva a posicao do Documento  �
//��������������������������������
If lBat
	Private cChave:= M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
Endif

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01	// Quebra por Departamento 1- Sim 2-Nao          �
//� mv_par02	// De Documento                                  �
//� mv_par03	// Ate Documento                                 �
//� mv_par04	// De  Revisao                                   �
//� mv_par05	// Ate Revisao                                   �
//� mv_par06	// De  Depto. Destino                            �
//� mv_par07	// Ate Depto. Destino                            �
//����������������������������������������������������������������
Pergunte(cPerg,.F.)

wnrel :=SetPrint(cString,wnrel,cPerg,ctitulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| QDOR061Imp(@lEnd,ctitulo,wnRel,tamanho,lBat)},ctitulo)

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QDOR061Imp� Autor � Newton R. Ghiraldelli � Data � 18/05/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia para funcao que faz a impressao do relatorio.        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR061                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function QDOR061Imp(lEnd,ctitulo,wnRel,tamanho,lBat)

Local cCabec1  := " "
Local cTxtCopia:= " "
Local cOldDoc	:= " "
Local cOldDepto:= " "
Local cCompara := " "
Local cSeek2   := " "
Local cCompara2:= " "
Local cIndex1  := CriaTrab(Nil,.F.)
Local cIndex2  := CriaTrab(Nil,.F.)
Local cFiltro  := " "
Local cTipPro  := GETMV("MV_QDOTPPR") // Parametro para impressao de somente copias em pael ou nao
Local aRegQDG  := {}
Local cFilDep  := xFilial("QAD")

DbSelectArea("QDG")
DbSetOrder(3)

DbSelectarea("QD1")
DbSetOrder(1)

DbSelectarea("QDH")
DbSetOrder(1)

If lBat
	QDH->(DbSeek(cChave)) // Retorna a Posicao do QDH - Documentos
Endif

If !lBat
	//�������������������������������������������������Ŀ
	//� Cria Indice Condicional nos arquivos utilizados �
	//���������������������������������������������������
	
	cFiltro:='QDH_FILIAL=="'+xFilial("QDH")+'".And.'
	cFiltro+='QDH_DOCTO>="'+mv_par02+'".And.QDH_DOCTO<="'+mv_par03+'".And.'
	cFiltro+='QDH_RV>="'+mv_par04+'".And.QDH_RV<="'+mv_par05+'"'
	IndRegua("QDH",cIndex1,QDH->(IndexKey()),,cFiltro,STR0007)	//"Selecionando Registros.."
EndIf

If !lBat
	cFiltro:='QD1_FILIAL=="'+xFilial("QD1")+'".And.'
	cFiltro+='QD1_DOCTO>="'+mv_par02+'".And.QD1_DOCTO<="'+mv_par03+'".And.'
	cFiltro+='QD1_RV>="'+mv_par04+'".And.QD1_RV<="'+mv_par05+'".And.'
	cFiltro+='QD1->QD1_DEPTO>="'+mv_par06+'".And.QD1->QD1_DEPTO<="'+mv_par07+'"'
	cFiltro+='.And.QD1->QD1_TPPEND=="L  ".And.QD1->QD1_SIT<>"I"'
Else
	cFiltro:='QD1_FILIAL=="'+QDH->QDH_FILIAL+'".And.'
	cFiltro+='QD1_DOCTO=="'+QDH->QDH_DOCTO+'".And.'
	cFiltro+='QD1_RV=="'+QDH->QDH_RV+'".And.'
	cFiltro+='QD1->QD1_TPPEND=="L  ".And.QD1->QD1_SIT<>"I"'
EndIf

If cTipPro == "S"
	cFiltro += '.And. QD1->QD1_TPDIST$"2,3"'
Endif

IndRegua("QD1",cIndex2,QD1->(IndexKey()),,cFiltro,STR0007)	//"Selecionando Registros.."

//          1         2         3         4         5         6         7         8
//012345678901234567890123456789012345678901234567890123456789012345678901234567890
//RESPONSAVEL                     TIPO    COPIA          DATA     ASSINATURA

cCabec1:= OemToAnsi(STR0008) // "RESPONSAVEL                     TIPO    COPIA          DATA     ASSINATURA"

Li       := 80
m_pag    := 1

SetRegua(If(!lBat,QDH->(LastRec()),QD1->(LastRec()))) // Total de Elementos da Regua

While QDH->(!Eof())
	cCompara:= "QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV"	

	QD1->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV))
	While QD1->(!Eof()) .And. QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV == &(cCompara)

		If !(QDH->QDH_DOCTO+QDH->QDH_RV == cOldDoc)
			cOldDoc:= QDH->QDH_DOCTO+QDH->QDH_RV
			Li:=80
		EndIf		

		cSeek2   := QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_DEPTO
		cCompara2:="QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_DEPTO"
		
		//��������������������������������������������������������������Ŀ
		//� Caso parametrizado, quebra pagina por departamento destino   �
		//����������������������������������������������������������������
		If QD1->QD1_DEPTO <> cOldDepto
			If !Empty(cOldDepto) .And. mv_par01 == 1
				Li:= 80
			Else
				If Li > 54
					Cabec061(@Li)
				EndIf
			EndIf
			cOldDepto:=QD1->QD1_DEPTO
		EndIf
		
		If Li > 58
			Cabec061(@li)
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
		@ Li,00 PSay cCabec1
		Li++
		@ Li,00 PSay __PrtFatLine()
		Li++
		aRegQDG := {}
		QD1->(DbSeek(cSeek2))
		While QD1->(!Eof()) .And. cSeek2 == &(cCompara2)
			IncRegua()
			If Li > 58
				Cabec061(@li)
				@ Li,00 PSay Upper(OemToAnsi(STR0010))+AllTrim(QD1->QD1_DEPTO)+" - "+QA_NDEPT(QD1->QD1_DEPTO,.T.,cFilDep) //"Departamento: "
				Li++
				@ li,00 PSay cCabec1
				Li++
				@ Li,00 PSay __PrtFatLine()
				Li++
			EndIf
			If lEnd
				Li++
				@ PROW()+1,001 PSAY OemToAnsi(STR0009)	//"CANCELADO PELO OPERADOR"
				Exit
			EndIf
			Li++
			@ Li,000 PSay Substr(QA_NUSR(QD1->QD1_FILMAT,QD1->QD1_MAT,.T.),1,28)
			
			If QDG->(DbSeek(QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_FILMAT + QD1->QD1_DEPTO + QD1->QD1_MAT ))
				While QDG->(!Eof()) .And. QDG->QDG_DOCTO + QDG->QDG_RV + QDG->QDG_FILMAT + QDG->QDG_DEPTO + QDG->QDG_MAT == QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_FILMAT + QD1->QD1_DEPTO + QD1->QD1_MAT
					If aScan(aRegQDG,{ |X| X == QDG->(Recno()) }) == 0
						aAdd(aRegQDG,QDG->(Recno()))
						Exit
					Endif
					QDG->(DbSkip())
				Enddo				
				@ Li,032 PSay If(QDG->QDG_TIPO == "D",OemToAnsi(STR0016),OemToAnsi(STR0017))	// "Usuario" ### "Pasta"
			EndIf
			
			If	QD1->QD1_TPDIST == "1" .Or. QD1->QD1_TPDIST == "2" .Or. QD1->QD1_TPDIST == "3"
				cTxtCopia:= OemToAnsi(STR0011) // "Recebe"
			ElseIf QD1->QD1_TPDIST == "4"
				cTxtCopia:= OemToAnsi(STR0012) // "N�o Recebe"
			EndIf
			
			@ Li,040 PSay cTxtCopia
			@ Li,052 PSay "___/___/___"
			@ Li,064 PSay Replicate("_",16)			
			Li++
			QD1->(DbSkip())
		EndDo
		@ Li,000 Psay __PrtThinLine()
		Li+=2
	EndDo
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

//��������������������������������������������������������������Ŀ
//� Apaga indices de trabalho                                    �
//����������������������������������������������������������������
cIndex1 += OrdBagExt()
Delete File &(cIndex1)

cIndex2 += OrdBagExt()
Delete File &(cIndex2)

Set Device To Screen

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
EndIf
MS_FLUSH()

Return (.T.)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Cabec061  � Autor � Newton R. Ghiraldelli � Data � 18/05/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime dados pertinentes ao cabecalho do programa.        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR061                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function Cabec061(li)

Local nCnt:=0
Local cArqTexto := " "

Li:= 0
@ Li,000 PSay __PrtLogo()
Li+=3
@ Li,000 PSay __PrtCenter(STR0001) //"AVISO DE RECEBIMENTO DE DOCUMENTOS E REGISTROS DA QUALIDADE"
Li+=3
@ Li,000 PSay Upper(OemToAnsi(STR0013))+AllTrim(QDH->QDH_DOCTO)+"/"+QDH->QDH_RV	//"Documento: "
Li++
@ Li,00 PSay Upper(OemToAnsi(STR0014))+Substr(Alltrim(QDH->QDH_TITULO),1,70)      //"T�tulo :"
If !Empty(Substr(Alltrim(QDH->QDH_TITULO),71))
	Li++
	@ Li,09 PSay Substr(Alltrim(QDH->QDH_TITULO),71)
EndIf
Li++
//������������������������������������������������������������Ŀ
//� Imprime Texto do protocolo                          	   �
//��������������������������������������������������������������
DbSelectArea("QD2")
DbSetOrder(1)
If DbSeek(QDH->QDH_FILIAL+QDH->QDH_CODTP) 
	nCnt:= 1
	cArqTexto:= Substr(MSMM(QD2->QD2_PROTOC,80),nCnt,80) 
	If !Empty(cArqTexto)
		Li++
		@Li,00 PSAY cArqTexto 
		Li++
		nCnt:= 81
		While !Empty(Substr(MSMM(QD2->QD2_PROTOC,80),nCnt,80))
			@Li,00 PSAY Substr(MSMM(QD2->QD2_PROTOC,80),nCnt,80)
			Li++
			nCnt:= nCnt + 80
		EndDo
	EndIf
EndIf	

DbSelectArea("QD1")
Li++
Return
