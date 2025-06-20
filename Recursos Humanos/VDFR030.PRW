#Include "VDFR030.Ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � VDFR030  � Autor � Robson Soares Morais  � Data �  03.12.13  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Relat�rio de Servidores em Hor�rio Especial                  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR030(void)                                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���            �          �      �                                          ���
�������������������������������������������������������������������������������*/
Function VDFR030()

Private oReport
Private cString	:= "SRA"
Private cPerg	:= "VDFR030"
Private nSeq 	:= 0
Private cTitulo	:= STR0001 //'Relat�rio de Servidores em Hor�rio Especial'
Private cAliasQRY := ""

Pergunte(cPerg, .F.)

M->RA_FILIAL := ""	// Variavel para controle da numera��o

oReport := ReportDef()
oReport:PrintDialog()

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportDef  � Autor � Robson Soares Morais  � Data � 03.12.13 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Montagem das defini��es do relat�rio VDFR030                 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR030                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR030 - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function ReportDef()

Local cDescri := STR0001 //'Relat�rio de Servidores em Hor�rio Especial'
Local cWhere 	:= ""

cAliasQRY := GetNextAlias()
oReport   := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri)

oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, 	(oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

oFilial := TRSection():New(oReport, STR0003, { "SM0" }) //'Filiais'
oFilial:SetLineStyle()
oFilial:cCharSeparator := ""

TRCell():New(oFilial,"RA_FILIAL","SRA")
TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM") } )

oFunc := TRSection():New(oFilial, STR0002,( "SRA", "SQB", "SQ3" )) //'Servidores'

TRCell():New(oFunc,	"","",'N�', "99999", 5, /*lPixel*/,/*bBlock*/ { || (	If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
																					AllTrim(Str(++ nSeq))) } ) //Para incluir o n�mero(sequencial) na linha de impress�o
TRCell():New(oFunc,"RA_MAT","SRA", STR0004,, 10 ) 		//'Matricula'
TRCell():New(oFunc,"RA_NOME","SRA", STR0005,, 40) 	//'Nome do Servidor'
TRCell():New(oFunc,"QB_DESCRIC","SQB", STR0006,, 40) 	//'Lota��o'
TRCell():New(oFunc,"Q3_DESCSUM","SQ3", STR0007,, 40) 	//'Cargo'
TRCell():New(oFunc,"","", STR0008, "", 10, /*lPixel*/,/*bBlock*/ { || X3COMBO("RA_TPCUEST", (cAliasQRY)->RA_TPCUEST) }) //'Curso'
TRCell():New(oFunc,"","", STR0009, "", 15, /*lPixel*/,/*bBlock*/ { || AllTrim(Str((cAliasQRY)->RA_ANOSEME)) + "�" })	 //'Semestre/Ano'
TRCell():New(oFunc,"","", STR0010, "", 10, /*lPixel*/,/*bBlock*/ { || X3COMBO("RA_PERESTU", (cAliasQRY)->RA_PERESTU) }) //'Per�odo'

Return(oReport)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportPrint � Autor � Robson Soares Morais � Data � 05.12.13 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Impress�o do conte�do do relat�rio                           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR030                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR030 - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function ReportPrint(oReport)

Local oFilial := oReport:Section(1), oFunc := oReport:Section(1):Section(1)

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)

cWhere := "% SRA.RA_TPCUEST IN ('1','2')"
If ! Empty(mv_par01)		//-- Filial
	cWhere += " AND " + mv_par01
EndIf

If ! Empty(mv_par02)		//-- Lota��o/Departamento
	cWhere += " AND " + mv_par02
EndIf

If ! Empty(mv_par03)		//-- Cargo
	cWhere += " AND " + mv_par03
EndIf
cWhere += "%"

oFilial:BeginQuery()

BeginSql Alias cAliasQRY
	SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SQB.QB_DESCRIC, SQ3.Q3_DESCSUM, SRA.RA_TPCUEST, SRA.RA_ANOSEME, SRA.RA_PERESTU
	  FROM %table:SRA% SRA
	  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO
	  LEFT JOIN %table:SQB% SQB ON SQB.%notDel% AND SQB.QB_FILIAL = %Exp:xFilial("SQB")% AND SQB.QB_DEPTO = SRA.RA_DEPTO
     WHERE SRA.%notDel% AND SRA.RA_DEMISSA = %Exp:''% AND %Exp:cWhere%
  ORDER BY SRA.RA_FILIAL, SRA.RA_NOME
EndSql

oFilial:EndQuery()

oFunc:SetParentQuery()    
oFunc:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL  })

oFilial:Print()

Return
