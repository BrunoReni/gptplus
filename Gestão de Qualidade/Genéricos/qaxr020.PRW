#INCLUDE "QAXR020.CH"
#INCLUDE "Protheus.CH"
#INCLUDE "Report.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QDOR020   �Autor  �Leandro Sabino      � Data �  21/06/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Relatorio de Ausencia Temporaria                           ���
���          � (Versao Relatorio Personalizavel)                          ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                            
Function QAXR020()
Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//��������������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                               �
	//� mv_par01	// De Ano                                               �
	//� mv_par02	// Ate Ano                                              �
	//� mv_par03	// De Numero                                            �
	//� mv_par04	// Ate Numero                                           �
	//� mv_par05	// De Fil Usr Origem                                    �
	//� mv_par06	// De Usr Origem                                        �
	//� mv_par07	// Ate Fil Usr Origem                                   �
	//� mv_par08	// Ate Usr Origem                                       �
	//� mv_par09	// De Depto Origem                                      �
	//� mv_par10	// Ate Depto Origem                                     �
	//� mv_par11	// De Dt Inicial                                        �
	//� mv_par12	// Ate Dt Inicial                                       �
	//� mv_par13	// De Dt Prevista                                       �
	//� mv_par14	// Ate Dt Prevista                                      �
	//� mv_par15	// Imprime Ausencia (Ambas/Pendente/Finalizada)         �
	//����������������������������������������������������������������������
	Pergunte("QXR020",.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	QAXR020R3()	// Executa vers�o anterior do fonte
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 21/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXR020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local cTitulo:= OemToAnsi(STR0001) // "LISTA AUSENCIA TEMPORARIA"
Local cDesc1 := OemToAnsi(STR0002) // "Este programa ira imprimir uma lista de Ausencia Temporaria"
Local cDesc2 := OemToAnsi(STR0003) // "de acordo com os par�metros definidos pelo usu�rio."
Local oSection1 
Local oSection2

DEFINE REPORT oReport NAME "QAXR020" TITLE cTitulo PARAMETER "QXR020" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1+cDesc2)

DEFINE SECTION oSection1 OF oReport TABLES "QAE" TITLE  STR0021//AUSENCIA
DEFINE CELL NAME "QAE_NUMERO" OF oSection1 ALIAS "QAE"
DEFINE CELL NAME "QAE_ANO"    OF oSection1 ALIAS "QAE"
DEFINE CELL NAME "QAE_DTINIC" OF oSection1 ALIAS "QAE" 
DEFINE CELL NAME "QAE_DTPREV" OF oSection1 ALIAS "QAE"
DEFINE CELL NAME "QAE_DTFIM"  OF oSection1 ALIAS "QAE"
DEFINE CELL NAME "cUsuario"   OF oSection1 ALIAS "   " TITLE OemToAnsi(STR0017)  SIZE 31 BLOCK {|| QA_NUSR(QAE->QAE_FILMAT,QAE->QAE_MAT,.T.)}//USUARIO
DEFINE CELL NAME "cDepto"     OF oSection1 ALIAS "   " TITLE OemToAnsi(STR0020)  SIZE 20 BLOCK {|| QA_NDEPT(QAE->QAE_DEPTO,.T.,QAE->QAE_FILMAT)}//DEPTO
DEFINE CELL NAME "cMot"       OF oSection1 ALIAS "   " TITLE OemToAnsi(STR0018)  SIZE 40 BLOCK {|| QXR20Mot(QAE->QAE_MOT)}//MOTIVO

DEFINE SECTION oSection2 OF oSection1 TABLES "QAF" TITLE STR0022//PENDENCIA
DEFINE CELL NAME "cTPPEND"    OF oSection2 ALIAS "" TITLE (TitSX3("QAF_TPPEND")[1]) SIZE 30 BLOCK {|| IIf (nModulo == 24,QA_NSIT(QAF->QAF_TPPEND),"")}
DEFINE CELL NAME "cUsuario"   OF oSection2 ALIAS "" TITLE OemToAnsi(STR0019)		 SIZE 31 BLOCK {|| QA_NUSR(QAF->QAF_FILMAT,QAF->QAF_MAT,.T.)}//USUARIO DESTINO
DEFINE CELL NAME "cDepto"     OF oSection2 ALIAS "" TITLE OemToAnsi(STR0020)         SIZE 50 BLOCK {|| QA_NDEPT(QAF->QAF_DEPTO,.T.,QAF->QAF_FILMAT)}//DEPTO

Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 21/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)  	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXR020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                  
Static Function PrintReport(oReport) 
Local oSection1 := oReport:Section(1)
Local oSection2   := oReport:Section(1):Section(1)
Local cFiltro   := " "

MakeAdvplExpr(oReport:uParam)

DbSelectarea("QAE")
DbSetOrder(1)

DbSelectarea("QAF")
DbSetOrder(1)

cFiltro:= 'QAE->QAE_FILIAL == "'+xFilial("QAE")+'".And. '
cFiltro+= 'QAE->QAE_ANO    >= "'+mv_par01+'" .And. QAE->QAE_ANO    <= "'+mv_par02+'" .And. '
cFiltro+= 'QAE->QAE_NUMERO >= "'+mv_par03+'" .And. QAE->QAE_NUMERO <= "'+mv_par04+'" .And. '
cFiltro+= 'QAE->QAE_FILMAT >= "'+mv_par05+'" .And. '
cFiltro+= 'QAE->QAE_MAT >= "'+mv_par06+'" .And. '
cFiltro+= 'QAE->QAE_FILMAT <= "'+mv_par07+'" .And. '
cFiltro+= 'QAE->QAE_MAT <= "'+mv_par08+'" .And. '
cFiltro+= 'QAE->QAE_DEPTO  >= "'+mv_par09+'" .And. QAE->QAE_DEPTO  <= "'+mv_par10+'" .And. '
cFiltro+= 'DTOS(QAE->QAE_DTINIC) >= "'+DTOS(mv_par11)+'".And. DTOS(QAE->QAE_DTINIC) <= "'+DTOS(mv_par12)+'" .And. '
cFiltro+= 'DTOS(QAE->QAE_DTPREV) >= "'+DTOS(mv_par13)+'".And. DTOS(QAE->QAE_DTPREV) <= "'+DTOS(mv_par14)+'"'

If mv_par15 == 2
	cFiltro+= '.And. QAE->QAE_STATUS == "1"'
ElseIf mv_par15 == 3
	cFiltro+= '.And. QAE->QAE_STATUS == "2"'
EndIf

oSection1:SetFilter(cFiltro)

dbGoTop()

While !oReport:Cancel() .And. QAE->(!Eof())
	oSection1:Init()
	oSection1:PrintLine()
	If QAF->(DbSeek(QAE->QAE_FILIAL+QAE->QAE_ANO+QAE->QAE_NUMERO))
		oSection2:Init()
		While QAF->(!Eof()) .And. QAF->QAF_FILIAL+QAF->QAF_ANO+QAF->QAF_NUMERO == QAE->QAE_FILIAL+QAE->QAE_ANO+QAE->QAE_NUMERO
			oSection2:PrintLine()
			QAF->(DbSkip())
		EndDo
		oSection2:Finish()
	EndIf
	QAE->(DbSkip())
	oSection1:Finish()
EndDo

QAE->(DbCloseArea())
QAF->(DbCloseArea())

Return NIL

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � QAXR020r3� Autor � Eduardo de Souza      � Data � 11/06/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Ausencia Temporaria                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXR020                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Eduardo S.  �21/08/02�059354� Acertado para listar corretamente datas  ���
���            �        �      � com 4 digitos.                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QAXR020R3()

Local cTitulo:= OemToAnsi(STR0001) // "LISTA AUSENCIA TEMPORARIA"
Local cDesc1 := OemToAnsi(STR0002) // "Este programa ira imprimir uma lista de Ausencia Temporaria"
Local cDesc2 := OemToAnsi(STR0003) // "de acordo com os par�metros definidos pelo usu�rio."
Local cString:= "QAE"
Local wnrel  := "QAXR020"
Local Tamanho:= "P"

Private cPerg   := "QXR020"
Private aReturn := {STR0004,1,STR0005,1,2,1,"",1} // "Zebrado" ### "Administra�ao"
Private nLastKey:= 0
Private INCLUI  := .F.	// Colocada para utilizar as funcoes

//��������������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                                 �
//����������������������������������������������������������������������
//��������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                               �
//� mv_par01	// De Ano                                               �
//� mv_par02	// Ate Ano                                              �
//� mv_par03	// De Numero                                            �
//� mv_par04	// Ate Numero                                           �
//� mv_par05	// De Fil Usr Origem                                    �
//� mv_par06	// De Usr Origem                                        �
//� mv_par07	// Ate Fil Usr Origem                                   �
//� mv_par08	// Ate Usr Origem                                       �
//� mv_par09	// De Depto Origem                                      �
//� mv_par10	// Ate Depto Origem                                     �
//� mv_par11	// De Dt Inicial                                        �
//� mv_par12	// Ate Dt Inicial                                       �
//� mv_par13	// De Dt Prevista                                       �
//� mv_par14	// Ate Dt Prevista                                      �
//� mv_par15	// Imprime Ausencia (Ambas/Pendente/Finalizada)         �
//����������������������������������������������������������������������
Pergunte(cPerg,.F.)

wnrel := AllTrim(SetPrint(cString,wnrel,cPerg,ctitulo,cDesc1,cDesc2,"",.F.,,,Tamanho))

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| QAXR020Imp(@lEnd,ctitulo,wnRel,tamanho)},ctitulo)

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �QAXR020Imp� Autor � Eduardo de Souza      � Data � 11/06/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Envia para funcao que faz a impressao do relatorio.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QAXR020Imp(ExpL1,ExpC1,ExpC2,ExpC3)                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXR020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function QAXR020Imp(lEnd,ctitulo,wnRel,tamanho)

Local cCabec1 := " "
Local cCabec2 := " "
Local cbtxt   := SPACE(10)
Local nTipo	  := GetMV("MV_COMP")
Local cbcont  := 0
Local cIndex1 := CriaTrab(Nil,.F.)
Local cFiltro := " "
Local cFilDep := xFilial("QAD")

li   := 80
m_Pag:= 1

DbSelectarea("QAE")
DbSetOrder(1)

cFiltro:= 'QAE->QAE_FILIAL == "'+xFilial("QAE")+'".And. '
cFiltro+= 'QAE->QAE_ANO    >= "'+mv_par01+'" .And. QAE->QAE_ANO    <= "'+mv_par02+'" .And. '
cFiltro+= 'QAE->QAE_NUMERO >= "'+mv_par03+'" .And. QAE->QAE_NUMERO <= "'+mv_par04+'" .And. '
cFiltro+= 'QAE->QAE_FILMAT >= "'+mv_par05+'" .And. '
cFiltro+= 'QAE->QAE_MAT >= "'   +mv_par06+'" .And. '
cFiltro+= 'QAE->QAE_FILMAT <= "'+mv_par07+'" .And. '
cFiltro+= 'QAE->QAE_MAT <= "'   +mv_par08+'" .And. '
cFiltro+= 'QAE->QAE_DEPTO  >= "'+mv_par09+'" .And. QAE->QAE_DEPTO  <= "'+mv_par10+'" .And. '
cFiltro+= 'DTOS(QAE->QAE_DTINIC) >= "'+DTOS(mv_par11)+'".And. DTOS(QAE->QAE_DTINIC) <= "'+DTOS(mv_par12)+'" .And. '
cFiltro+= 'DTOS(QAE->QAE_DTPREV) >= "'+DTOS(mv_par13)+'".And. DTOS(QAE->QAE_DTPREV) <= "'+DTOS(mv_par14)+'"'

If mv_par15 == 2
	cFiltro+= '.And. QAE->QAE_STATUS == "1"'
ElseIf mv_par15 == 3
	cFiltro+= '.And. QAE->QAE_STATUS == "2"'
EndIf

IndRegua("QAE",cIndex1,QAE->(IndexKey()),,cFiltro,OemToAnsi(STR0006)) // "Selecionando Registros.."

//         1         2         3         4         5         6         7         8
//12345678901234567890123456789012345678901234567890123456789012345678901234567890
//PENDENCIA               USUARIO DESTINO                DEPTO

cCabec1:= OemToAnsi(STR0007) // "PENDENCIA               USUARIO DESTINO                DEPTO"

QAF->(DbSetOrder(1))
QAE->(DbSeek(xFilial("QAE")))
SetRegua(QAE->(RecCount())) // Total de Elementos da Regua

While QAE->(!Eof())
	QAE->(IncRegua())
	If lEnd
		Li++
		@ PROW()+1,001 PSAY OemToAnsi(STR0008) // "CANCELADO PELO OPERADOR"
		Exit
	EndIf
	If Li > 60
		Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
	EndIf
	cMotivo:= " "
    @ Li,000 PSay OemToAnsi(STR0009)+" "+QAE->QAE_ANO+"/"+QAE->QAE_NUMERO // "AUSENCIA:"
    @ Li,021 PSay OemToAnsi(STR0010)+" "+DTOC(QAE->QAE_DTINIC) // "DT INIC.:"
    @ Li,042 PSay OemToAnsi(STR0011)+" "+DTOC(QAE->QAE_DTPREV) // "DT PREV.:"
    @ Li,062 PSay OemToAnsi(STR0012)+" "+DTOC(QAE->QAE_DTFIM)  // "DT FIM:"
    Li++
    @ Li,000 PSay OemToAnsi(STR0013)+" "+SubStr(QA_NUSR(QAE->QAE_FILMAT,QAE->QAE_MAT,.T.),1,31) // "USUARIO.:"
	If FWModeAccess("QAD")=="E"//!Empty(xFilial("QAD"))
		cFilDep:= QAE->QAE_FILMAT
	EndIf
    @ Li,041 PSay OemToAnsi(STR0014)+" "+QA_NDEPT(QAE->QAE_DEPTO,.T.,cFilDep) // "DEPTO.:"
	Li++
	If	SX5->(DbSeek(xFilial("SX5")+"QG"+QAE->QAE_MOT))
	   @ Li,000 PSay OemToAnsi(STR0015)+" "+ Left(X5Descri(),55) // "MOTIVO..:"
		Li++
	EndIf
  	@ Li,000 PSay __PrtFatLine()
    Li++
	If QAF->(DbSeek(QAE->QAE_FILIAL+QAE->QAE_ANO+QAE->QAE_NUMERO))
		While QAF->(!Eof()) .And. QAF->QAF_FILIAL+QAF->QAF_ANO+QAF->QAF_NUMERO == QAE->QAE_FILIAL+QAE->QAE_ANO+QAE->QAE_NUMERO
			If lEnd
				Li++
				@ PROW()+1,001 PSAY OemToAnsi(STR0008) // "CANCELADO PELO OPERADOR"
				Exit
			EndIf
			If Li > 60
				Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
			EndIf
			@ Li,000 PSay QXR20TPend(QAF->QAF_TPPEND)
			@ Li,024 PSay SubStr(QA_NUSR(QAF->QAF_FILMAT,QAF->QAF_MAT,.T.),1,31)
			If FWModeAccess("QAD")=="E" //!Empty(xFilial("QAD"))
				cFilDep:= QAF->QAF_FILMAT
			EndIf
		   @ Li,055 PSay QA_NDEPT(QAF->QAF_DEPTO,.T.,cFilDep)
			Li++
			QAF->(DbSkip())
		EndDo
	  	@ Li,000 PSay __PrtThinLine()
	   Li+=2
	EndIf
	QAE->(DbSkip())
EndDo

If Li != 80
	Roda(cbcont,cbtxt,tamanho)
EndIf

RetIndex("QAE")
Set Filter to

//��������������������������������������������������������������Ŀ
//� Apaga indice de trabalho                                     �
//����������������������������������������������������������������
cIndex1 += OrdBagExt()
Delete File &(cIndex1)

Set Device To Screen

If aReturn[5] = 1
	Set Printer TO 
	DbCommitAll()
	Ourspool(wnrel)
Endif
MS_FLUSH()

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �QXR20TPend� Autor � Eduardo de Souza      � Data � 11/06/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Retorna o Tipo de Pendencia.                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QXR20TPend(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXR020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function QXR20TPend(cTpPend)

If nModulo == 24
	cTpPend:= QA_NSIT(cTpPend)
EndIf

Return UPPER(SubStr(cTpPend,1,22))


/*��������������������������������������������������������������������
����������������������������������������������������������������������
������������������������������������������������ �����������������Ŀ��
���Fun�ao    �QXR20Mot  � Autor � Leandro Sabino � Data � 11/06/02 ���
������������������������������������������������������������������Ĵ��
���Descri�ao � Retorna o Tipo de Pendencia.                        ���
������������������������������������������������������������������Ĵ��
���Sintaxe   � QXR20Mot(ExpC1)                                     ���
������������������������������������������������������������������Ĵ��
��� Uso      � QAXR020                                             ���
�������������������������������������������������������������������ٱ�
����������������������������������������������������������������������
���������������������������������������������������������������������*/
Static Function QXR20Mot(cMotivo)
 SX5->(DbSeek(xFilial("SX5")+"QG"+QAE->QAE_MOT))
 cMotivo:= Left(X5Descri(),55) 
Return cMotivo
