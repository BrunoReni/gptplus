#INCLUDE "QDOR052.CH"
#INCLUDE "Report.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QDOR052  � Autor � Leandro S. Sabino     � Data � 30/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Solicitacoes       			                  ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR052	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QDOR052()
Local oReport
Private cPerg	:= "QDR052"

If TRepInUse()
	Pergunte(cPerg,.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	QDOR052R3() //Executa vers�o anterior do fonte
EndIf
           
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 22.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR052                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport                                             
Local oSection1 

DEFINE REPORT oReport NAME "QDOR052" TITLE OemToAnsi(STR0001) PARAMETER "QDR052" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION OemToAnsi(STR0002)+OemToAnsi(STR0003)
oReport:SetLandscape(.T.)
//"LISTA DE SOLICITACOES"##"Este programa ira imprimir uma rela�ao de Solicitacoes"##"de acordo com os par�metros definidos pelo usu�rio."

DEFINE SECTION oSection1 OF oReport TABLES "QDP" TITLE OemToAnsi(STR0030)
DEFINE CELL NAME "QDP_NUMSEQ" OF oSection1 ALIAS "QDP" SIZE 12
DEFINE CELL NAME "QDP_DESSOL" OF oSection1 ALIAS "QDP" Picture "@!"
DEFINE CELL NAME "QDP_DTGERA" OF oSection1 ALIAS "QDP" SIZE 10 TITLE STR0027 //"DT Sol."
DEFINE CELL NAME "cDESC"      OF oSection1 ALIAS ""    AUTO SIZE TITLE TitSX3("ABF_SOLIC")[1]  BLOCK{|| Alltrim(QA_NUSR(QDP->QDP_FILMAT,QDP->QDP_MAT,.T.,"A"))}//Apelido
DEFINE CELL NAME "cDEPTO"     OF oSection1 ALIAS ""    SIZE 36 TITLE TitSX3("EE3_DEPART")[1]
DEFINE CELL NAME "QDP_SITSOL" OF oSection1 ALIAS "QDP" SIZE 12 BLOCK{|| IIf(!Empty(QDP->QDP_SITSOL),If(QDP->QDP_SITSOL=="R",OemToAnsi(STR0017),If(QDP->QDP_SITSOL=="A",OemToAnsi(STR0018),OemToAnsi(STR0022))),"")}// "Reprovada" ### "Aprovada" ### "Em Analise"
DEFINE CELL NAME "cDESC"      OF oSection1 ALIAS ""    AUTO SIZE TITLE STR0028 BLOCK{|| AllTrim(QA_NUSR(QDP->QDP_FMATBX,QDP->QDP_MATBX,.T.,"A"))}//"Resp. Baixa"
DEFINE CELL NAME "QDP_DEPBX"  OF oSection1 ALIAS "QDP" SIZE 36 TITLE STR0029
DEFINE CELL NAME "QDP_DTOORI" OF oSection1 ALIAS "QDP" AUTO SIZE
DEFINE CELL NAME "QDP_RV"     OF oSection1 ALIAS "QDP" AUTO SIZE
DEFINE CELL NAME "QDP_TITULO" OF oSection1 ALIAS "QDP" AUTO SIZE BLOCK{||Substr(QDP->QDP_TITULO,1,41)}

Return oReport


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 30.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)  	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR052                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintReport( oReport )
Local oSection1  := oReport:Section(1)
Local cFiltro 
Local cDesc := ""

MakeAdvplExpr("QDR052")
              
DbSelectarea("QDP")

cFiltro:= 'QDP_FILIAL=="'  +xFilial("QDP")+'" .And. '
cFiltro+= 'QDP_NUMSEQ >= "' +mv_par01+'" .And. QDP_NUMSEQ <= "' +mv_par02+'".And. '

If mv_par03 == 2
	cFiltro+= 'QDP_SITSOL == "E" .And.'
ElseIf mv_par03 == 3
	cFiltro+= 'QDP_SITSOL == "R" .And.'
ElseIf mv_par03 == 4
	cFiltro+= 'QDP_SITSOL == "A" .And.'
EndIf	

cFiltro+= 'DTOS(QDP_DTGERA) >= "'+DTOS(mv_par04)+'" .And. DTOS(QDP_DTGERA) <= "'+DTOS(mv_par05)+'".And. '
cFiltro+= 'QDP_FILMAT >= "' +mv_par12+'" .And. QDP_FILMAT <= "' +mv_par13+'".And. '
cFiltro+= 'QDP_MAT >= "' +mv_par06+'" .And. QDP_MAT <= "' +mv_par07+'".And. '
cFiltro+= 'QDP_DTOORI >= "' +mv_par08+'" .And. QDP_DTOORI <= "' +mv_par09+'".And. '
cFiltro+= 'QDP_RV >= "'+mv_par10+'" .And. QDP_RV <= "'+mv_par11+'"'

oSection1:SetFilter(cFiltro)

While !oReport:Cancel() .And. QDP->(!Eof())
	oSection1:Init()
    
    cDesc:=QA_NDEPT(QDP->QDP_DEPTO,.T.,QDP->QDP_FILMAT)
    If !Empty(cDesc)
		oSection1:Cell("cDEPTO"):SetValue(cDesc)
	Endif	
	
	cDesc:= AllTrim(QA_NDEPT(QDP->QDP_DEPBX,.T.,QDP->QDP_FMATBX))
	If !Empty(cDesc)
		oSection1:Cell("QDP_DEPBX"):SetValue(cDesc)	
	Endif
	oSection1:PrintLine()	
	QDP->(DbSkip())
	cDesc:=""
EndDo

oSection1:Finish()

Return


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � QDOR052R3� Autor � Eduardo de Souza      � Data � 23/11/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Solicitacoes                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR052                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Eduardo S.  �28/01/02� ---- � Acerto para apresentar corretamente Sta- ���
���            �        �      � tus "Em Analise"                         ���
���Eduardo S.  �28/03/02� META � Retirada a funcao QA_AjustSx1()          ���
���Eduardo S.  �21/08/02�059354� Acertado para listar corretamente datas  ���
���            �        �      � com 4 digitos.                           ���
���Eduardo S   |13/12/02� ---- � Incluido a pergunta 12 e 13 permitindo   ���
���            �        �      � filtrar por filial de departamento.      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QDOR052R3()

Local cTitulo   := OemToAnsi(STR0001) // "LISTA DE SOLICITACOES"
Local cDesc1    := OemToAnsi(STR0002) // "Este programa ira imprimir uma rela�ao de Solicitacoes"
Local cDesc2    := OemToAnsi(STR0003) // "de acordo com os par�metros definidos pelo usu�rio."
Local cString   := "QDP"
Local wnrel     := "QDOR052"
Local Tamanho   := "G"

Private cPerg   := "QDR052"
Private aReturn := {STR0004,1,STR0005,1,2,1,"",1} // "Zebrado" ### "Administra�ao"
Private nLastKey:= 0
Private INCLUI  := .F.	// Colocada para utilizar as funcoes

//��������������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                                 �
//����������������������������������������������������������������������
//��������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                               �
//� mv_par01	// De Solicitacao                                       �
//� mv_par02	// Ate Solicitacao                                      �
//� mv_par03	// Situacao (Ambas/Em Analise/Reprovada/Aprovada)       �
//� mv_par04	// De Dt Solicitacao                                    �
//� mv_par05	// Ate Dt Solicitacao                                   �
//� mv_par06	// De Solicitante                                       �
//� mv_par07	// Ate Solicitante                                      �
//� mv_par08	// De Documento                                         �
//� mv_par09	// Ate Documento                                        �
//� mv_par10	// De Revisao                                           �
//� mv_par11	// Ate Revisao                                          �
//� mv_par12	// De Filial Solicitante                                �
//� mv_par13	// Ate Filial Solicitante                               �
//����������������������������������������������������������������������
Pergunte(cPerg,.F.)

wnrel := AllTrim(SetPrint(cString,wnrel,cPerg,ctitulo,cDesc1,cDesc2,"",.F.,,.F.,Tamanho))

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| QDOR052Imp(@lEnd,ctitulo,wnRel,tamanho)},ctitulo)

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �QDOR052Imp� Autor � Eduardo de Souza      � Data � 23/11/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Envia para funcao que faz a impressao do relatorio.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QDOR052Imp(ExpL1,ExpC1,ExpC2,ExpC3)                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpL1 - lEnd                                               ���
���          � ExpC1 - Titulo do Relatorio                                ���
���          � ExpC2 - Nome do Relatorio                                  ���
���          � ExpC3 - Tamanho do Relatorio (P/M/G)                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR052                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function QDOR052Imp(lEnd,ctitulo,wnRel,tamanho)

Local cCabec1  := ""
Local cCabec2  := ""
Local cbtxt    := SPACE(10)
Local nTipo		:= GetMV("MV_COMP")
Local cbcont   := 0
Local cIndex1  := ""
Local cFiltro  := ""
Local cKey     := ""
Local cFilDep  := ""
Local cFilDepBx:= ""

//�������������������������������������������������Ŀ
//� Cria Indice Condicional nos arquivos utilizados �
//���������������������������������������������������
cIndex1 := CriaTrab(Nil,.F.)

DbSelectarea("QDP")

cFiltro:= 'QDP_FILIAL=="'  +xFilial("QDP")+'" .And. '
cFiltro+= 'QDP_NUMSEQ >= "' +mv_par01+'" .And. QDP_NUMSEQ <= "' +mv_par02+'".And. '

If mv_par03 == 2
	cFiltro+= 'QDP_SITSOL == "E" .And.'
ElseIf mv_par03 == 3
	cFiltro+= 'QDP_SITSOL == "R" .And.'
ElseIf mv_par03 == 4
	cFiltro+= 'QDP_SITSOL == "A" .And.'
EndIf	

cFiltro+= 'DTOS(QDP_DTGERA) >= "'+DTOS(mv_par04)+'" .And. DTOS(QDP_DTGERA) <= "'+DTOS(mv_par05)+'".And. '
cFiltro+= 'QDP_FILMAT >= "' +mv_par12+'" .And. QDP_FILMAT <= "' +mv_par13+'".And. '
cFiltro+= 'QDP_MAT >= "' +mv_par06+'" .And. QDP_MAT <= "' +mv_par07+'".And. '
cFiltro+= 'QDP_DTOORI >= "' +mv_par08+'" .And. QDP_DTOORI <= "' +mv_par09+'".And. '
cFiltro+= 'QDP_RV >= "'+mv_par10+'" .And. QDP_RV <= "'+mv_par11+'"'

cKey:= 'QDP_FILIAL+QDP_NUMSEQ+QDP_DTOORI+QDP_RV'

IndRegua("QDP",cIndex1,cKey,,cFiltro,OemToAnsi(STR0020)) // "Selecionando Registros.."

Li     := 80
m_Pag  := 1
cCabec1:= OemToAnsi(STR0021) // "DT TRANSF. RESPONSAVEL        DEPTO                     MOTIVO                          TIPO"                          

DbSelectArea("QDP")
DbSeek(xFilial("QDP"))

SetRegua(RecCount()) // Total de Elementos da Regua

While QDP->(!Eof())
	IncRegua()
	If FWModeAccess("QAD")=="E"  //!Empty(xFilial("QAD"))
		cFilDep  := QDP->QDP_FILMAT
		cFilDepBx:= QDP->QDP_FMATBX
	EndIf
	If lEnd
		Li++
		@ PROW()+1,001 PSAY OemToAnsi(STR0023) // "CANCELADO PELO OPERADOR"
		Exit
	EndIf
	If Li > 60
		Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
	EndIf

    @ Li,000 PSay QDP->QDP_NUMSEQ
    @ Li,021 PSay QDP->QDP_DESSOL
    @ Li,052 PSay QDP->QDP_DTGERA
	@ Li,063 PSay QA_NUSR(QDP->QDP_FILMAT,QDP->QDP_MAT,.T.,"A") // Apelido
	@ Li,079 PSay AllTrim(QA_NDEPT(QDP->QDP_DEPTO,.T.,cFilDep))
    @ Li,105 PSay If(!Empty(QDP->QDP_SITSOL),If(QDP->QDP_SITSOL=="R",OemToAnsi(STR0017),If(QDP->QDP_SITSOL=="A",OemToAnsi(STR0018),OemToAnsi(STR0022))),"") // "Reprovada" ### "Aprovada" ### "Em Analise"
	If !Empty(QDP->QDP_MATBX)
		@ Li,116 PSay QA_NUSR(QDP->QDP_FMATBX,QDP->QDP_MATBX,.T.,"A") // Apelido
		@ Li,132 PSay AllTrim(QA_NDEPT(QDP->QDP_DEPBX,.T.,cFilDepBx))
	EndIf
	@ Li,158 PSay QDP->QDP_DTOORI
	@ Li,175 PSay QDP->QDP_RV
	@ Li,179 PSay Substr(QDP->QDP_TITULO,1,41)
    Li++
	QDP->(DbSkip())
EndDo

If Li != 80
	Roda(cbcont,cbtxt,tamanho)
EndIf

RetIndex("QDP")
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
