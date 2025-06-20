#INCLUDE "QDOR050.CH"
#INCLUDE "Totvs.CH"
#include "report.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QDOR050   �Autor  �Telso Carneiro      � Data �  19/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Relatorio de Pendencias                                    ���
���          � (Versao Relatorio Personalizavel)                          ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function QDOR050()
Local oReport

If TRepInUse()
	Pergunte("QDR050",.F.)
	
	oReport := ReportDef()
	oReport:PrintDialog()
Else
    Return QDOR050R3()	// Executa vers�o anterior do fonte
EndIf

Return


Static Function ReportDef()
Local cDesc1      := OemToAnsi(STR0002) //"Este programa ir� imprimir uma rela��o das pend�ncias de cada"
Local cDesc2      := OemToAnsi(STR0003) //"respons�vel, mencionando o tipo de pend�ncia e sua data de"
Local cDesc3      := OemToAnsi(STR0004) //"cria��o, de acordo com os par�metros definidos pelo usu�rio."
Local cPerg       := "QDR050"
Local cTitulo     := OemToAnsi(STR0001) //"PENDENCIAS"
Local nSizeDept   := GetSX3Cache("QD1_DEPTO","X3_TAMANHO")  + GetSX3Cache("QAD_DESC","X3_TAMANHO") + 5
Local nSizeMat    := GetSX3Cache("QD1_FILMAT","X3_TAMANHO") + GetSX3Cache("QD1_MAT","X3_TAMANHO") + GetSX3Cache("QAA_NOME","X3_TAMANHO") + 5
Local oBreak1     := Nil
Local oReport     := Nil
Local oSection1   := Nil
Local oSection3   := Nil
Local wnrel       := "QDOR050"

Private cAliasQD1 := "QD1"
Private cFildep   := xFilial("QAD")

	DEFINE REPORT oReport NAME wnrel TITLE cTitulo PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1+" "+cDesc2+" "+cDesc3)
	oReport:SetLandScape() 
	DEFINE SECTION oSection1 OF oReport TITLE STR0015 TABLES "QD1" //"Depto"

	DEFINE CELL NAME "QD1_DEPTO"  OF oSection1 ALIAS "QD1" SIZE nSizeDept BLOCK {|| Alltrim((cAliasQD1)->QD1_DEPTO)+" "+Alltrim(QA_NDEPT((cAliasQD1)->QD1_DEPTO,.T.,IF(FWModeAccess("QAD") == "E",(cAliasQD1)->QD1_FILMAT,cFildep)))} //!Empty(cFildep)
	DEFINE CELL NAME "QD1_MAT"    OF oSection1 ALIAS "QD1" SIZE nSizeMat  BLOCK {|| Alltrim((cAliasQD1)->QD1_FILMAT)+"-"+Alltrim((cAliasQD1)->QD1_MAT)+" "+Alltrim(QA_NUSR((cAliasQD1)->QD1_FILMAT,(cAliasQD1)->QD1_MAT,.T.))} 
	DEFINE BREAK oBreak1 OF oSection1 WHEN {|| (cAliasQD1)->QD1_DEPTO+(cAliasQD1)->QD1_FILMAT+(cAliasQD1)->QD1_MAT} TITLE STR0015 PAGE BREAK //"Depto" 

	DEFINE SECTION oSection3 OF oSection1 TITLE STR0016 TABLES "QD1" //"Pendencias"
	DEFINE CELL NAME "QD1_DOCTO"  OF oSection3 ALIAS "QD1"
	DEFINE CELL NAME "QD1_RV"     OF oSection3 ALIAS "QD1"
	DEFINE CELL NAME "QDH_TITULO" OF oSection3 ALIAS "QD1" 
	DEFINE CELL NAME "QD1_TPPEND" OF oSection3 ALIAS "QD1" SIZE 30 BLOCK {|| SX5->(DbSeek(xFilial("SX5")+"Q7"+(cAliasQD1)->QD1_TPPEND)) , X5Descri() }
	DEFINE CELL NAME "QD1_DTGERA" OF oSection3 ALIAS "QD1" SIZE GetSX3Cache("QD1_DTGERA","X3_TAMANHO") + 6
	DEFINE CELL NAME "QD1_DTBAIX" OF oSection3 ALIAS "QD1" SIZE GetSX3Cache("QD1_DTBAIX","X3_TAMANHO") + 6
	DEFINE CELL NAME "QD1_PENDEN" OF oSection3 ALIAS "QD1" SIZE 10 BLOCK {|| IF((cAliasQD1)->QD1_PENDEN =="P",OemToAnsi(STR0013),OemToAnsi(STR0014)) } // "Pendente"###"Baixado"
	DEFINE CELL NAME "DiasPend"   OF oSection3 ALIAS NIL  TITLE "Dias"  SIZE 5 BLOCK {|| IF((cAliasQD1)->QD1_PENDEN =="P",Right(Str(dDataBase - (cAliasQD1)->QD1_DTGERA),4),"") }

Return oReport

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportPrin�Autor  �Telso Carneiro      � Data �  19/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Relatorio Personalizavel                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �QDOR050()                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
                  
Static Function PrintReport(oReport) 
  
Local cQueryQD1	:= ""
Local cQueryQDH	:= ""
Local cMVPAR1		:= mv_par01
Local nCont		:= 0

Local cDtVig   := GetMv("MV_QIMPENL",.f.,"1") // Habilita Impressao da Pendecia de leitura de doc. vencidos 1=Sim / 2=Nao   

cAliasQD1	:= "QD1"
cFildep	:= xFilial("QAD")

//��������������������������������������������������������������Ŀ
//� VerIfica as perguntas selecionadas                           �
//����������������������������������������������������������������
//���������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                                �
//� mv_par01	// Situacao do Documento   O - Todos                    �
//� mv_par02	// Criterio 1- Todas as Revisoes 2- Ultima Revisao      �
//� mv_par03	// De  Tipo de Documento                                �
//� mv_par04	// Ate Tipo de Documento                                �
//� mv_par05	// De  Depto. Destino                                   �
//� mv_par06	// Ate Depto. Destino                                   �
//� mv_par07	// De  Usuario    *                                      �
//� mv_par08	// Ate Usuario    *                                      �
//� mv_par09	// De  Documento  *                                      �
//� mv_par10	// Ate Documento  *                                      �
//� mv_par11	// De  Revisao    *                                      �
//� mv_par12	// Ate Revisao    *                                      �
//� mv_par13	// Lista 1 -Pendentes 2 - Baixados 3 - Ambos            �
//� mv_par14	// Quebra por Departamentos : 1 - Sim 2 - Nao           �
//� mv_par15	// Filtro Situacao por : 1 - Documento 2 - Usuario      �
//� mv_par16	// Filial de                                            �
//� mv_par17	// Filial Ate                                           �
//�����������������������������������������������������������������������         


//��������������������������������������������������������������Ŀ
//� Se lRelease                          �
//����������������������������������������������������������������
//���������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                                �
//� mv_par01	// Situacao do Documento   O - Todos                    �
//� mv_par02	// Criterio 1- Todas as Revisoes 2- Ultima Revisao      �
//� mv_par03	// Tipo de Documento                                    �
//� mv_par04	// Depto. Destino                                       �
//� mv_par05	// Usuario    *                                         �
//� mv_par06	// Documento  *                                         �
//� mv_par07	// Revisao    *                                         �
//� mv_par08	// Lista 1 -Pendentes 2 - Baixados 3 - Ambos            �
//� mv_par09	// Quebra por Departamentos : 1 - Sim 2 - Nao           �
//� mv_par10	// Filtro Situacao por : 1 - Documento 2 - Usuario      �
//� mv_par11	// Filial                                               �
//�����������������������������������������������������������������������

//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������

	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao SQL                            �
	//��������������������������������������������������������������������������
	MakeSqlExpr(oReport:uParam) 
	
	//��������������������������������������������������������������Ŀ
	//� VerIfica Tipo da pendencia                                   �
	//����������������������������������������������������������������
	cQueryQD1:="% "
	
	If mv_par13	== 1 	//Pendentes
		cQueryQD1+= " And QD1.QD1_PENDEN = 'P' And QD1.QD1_SIT <> 'I' "
	ElseIf mv_par13 == 2	//Baixados
		cQueryQD1+= " And QD1.QD1_PENDEN = 'B'"
	EndIf
	
	If mv_par15 == 2 // Filtro Situacao por Usuario		
		nCont:=4
		While nCont<=((Len(mv_par01)*2)-3)
			cMVPAR1:=STUFF(cMVPAR1,nCont,0,"','") 
			nCont+=6
		EndDo	
		cQueryQD1+= " And QD1.QD1_TPPEND IN ('"+cMVPAR1+"')"
	Endif
	
	cQueryQD1+=" %"                                          
	
	// Filtro Situacao por Documento	
	cQueryQDH:="% "
	
	If mv_par15 == 1 // Filtro Situacao por Documento	 
		nCont:=4
		While nCont<=((Len(mv_par01)*2)-3)
			cMVPAR1:=STUFF(cMVPAR1,nCont,0,"','") 
			nCont+=6
		EndDo	
	  	cQueryQDH+= " AND QDH.QDH_STATUS IN ('"+cMVPAR1+"')" 
   		cQueryQDH+= " AND QD1.QD1_TPPEND IN ('"+cMVPAR1+"')"
	Endif
	
	//� VerIfica se � ultima versao                                  �	
	If mv_par02 == 2
		cQueryQDH+= " And QDH.QDH_OBSOL = 'N'"
	EndIf	
	cQueryQDH+=" %"
	
	//������������������������������������������������������������������������Ŀ
	//�Query do relat�rio da secao 1                                           �
	//��������������������������������������������������������������������������
	
	BEGIN REPORT QUERY oReport:Section(1)
	
	cAliasQD1 := GetNextAlias()
	BeginSql Alias cAliasQD1

	SELECT QD1.QD1_DEPTO,QD1.QD1_FILMAT,QD1.QD1_MAT,QD1.QD1_DOCTO,QD1.QD1_RV,QDH.QDH_TITULO,QD1.QD1_TPPEND,
		QD1.QD1_DTGERA,QD1.QD1_DTBAIX,QD1.QD1_PENDEN, QDH.QDH_DTLIM, QDH.QDH_STATUS
	 	
	 	FROM %table:QD1% QD1 	
        JOIN %table:QDH% QDH
        	ON QDH.QDH_FILIAL=QD1.QD1_FILIAL AND 
			QDH.QDH_DOCTO=QD1.QD1_DOCTO AND 
			QDH.QDH_RV=QD1.QD1_RV AND 
			QDH.QDH_CODTP BETWEEN %Exp:mv_par03% And %Exp:mv_par04% And
			QDH.%notDel%       
			%Exp:cQueryQDH% 				       			
		WHERE QD1_FILIAL = %xFilial:QD1% AND 
			QD1.QD1_DEPTO BETWEEN %Exp:mv_par05% AND %Exp:mv_par06% AND
			QD1.QD1_FILMAT BETWEEN %Exp:mv_par16% AND %Exp:mv_par17% AND
			QD1.QD1_MAT BETWEEN %Exp:mv_par07% AND %Exp:mv_par08% AND
			QD1.QD1_DOCTO BETWEEN %Exp:mv_par09% AND %Exp:mv_par10% AND
			QD1.QD1_RV BETWEEN %Exp:mv_par11% AND %Exp:mv_par12% AND
			QD1.%notDel%  		                
			%Exp:cQueryQD1% 
			   
		ORDER BY QD1_FILIAL,QD1_DEPTO,QD1_FILMAT,QD1_MAT,QD1_DOCTO,QD1_RV,QD1_DTGERA,QD1_TPPEND
	
	EndSql 
	END REPORT QUERY oReport:Section(1) 
	    	
	oReport:Section(1):Section(1):SetParentQuery()	
	oReport:Section(1):Section(1):SetParentFilter( { |cParam| (cAliasQD1)->QD1_DEPTO+(cAliasQD1)->QD1_FILMAT+(cAliasQD1)->QD1_MAT == cParam },{ || (cAliasQD1)->QD1_DEPTO+(cAliasQD1)->QD1_FILMAT+(cAliasQD1)->QD1_MAT })
	oReport:Section(1):Section(1):SetLineCondition({||QDOR50FIL((cAliasQD1)->QD1_TPPEND,(cAliasQD1)->QDH_DTLIM) })	    	

IF mv_par14 == 2
	oReport:Section(1):ABREAK[1]:LPAGEBREAK:=.F.	
Endif       
       

oReport:Section(1):Print()

Return NIL



/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QDOR050  � Autor � Rodrigo de A. Sartorio� Data � 15/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio Pendencias                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���  Data  � BOPS � Programador �Alteracao                                ���
�������������������������������������������������������������������������Ĵ��
���31/08/01� xxxx � Eduardo S.  � Posicionado as colunas corretamente     ���
���        �      �             � para imprimir Revisao com 3 caracter    ���
���28/03/02� xxxx � Eduardo S.  � Acerto para imprimir corretamente o Dept���
���21/08/02� 59354� Eduardo S.  � Acertado para listar corretamente datas ���
���        �      �             � com 4 digitos.                          ���
���19/11/02� xxxx � Eduardo Ju  � Alterado para listar o Status da Penden-���
���        �      �             � cia e a Qtde de dias pendente.          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QDOR050R3()

Local cTitulo:= OemToAnsi(STR0001) //"PENDENCIAS"
Local cDesc1 := OemToAnsi(STR0002) //"Este programa ir� imprimir uma rela��o das pend�ncias de cada"
Local cDesc2 := OemToAnsi(STR0003) //"respons�vel, mencionando o tipo de pend�ncia e sua data de"
Local cDesc3 := OemToAnsi(STR0004) //"cria��o, de acordo com os par�metros definidos pelo usu�rio."
Local cString:= "QDH"
Local wnrel  := "QDOR050"
Local Tamanho:= "G"

Private cPerg   := "QDR050"
Private aReturn := {STR0005,1,STR0006, 1, 2, 1, "",1} //"Zebrado"###"Administra��o"
Private nLastKey:= 0
Private INCLUI  := .F.	// Colocada para utilizar as funcoes

//���������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                                �
//� mv_par01	// Situacao do Documento   O - Todos                    �
//� mv_par02	// Criterio 1- Todas as Revisoes 2- Ultima Revisao      �
//� mv_par03	// De  Tipo de Documento                                �
//� mv_par04	// Ate Tipo de Documento                                �
//� mv_par05	// De  Depto. Destino                                   �
//� mv_par06	// Ate Depto. Destino                                   �
//� mv_par07	// De  Usuario                                          �
//� mv_par08	// Ate Usuario                                          �
//� mv_par09	// De  Documento                                        �
//� mv_par10	// Ate Documento                                        �
//� mv_par11	// De  Revisao                                          �
//� mv_par12	// Ate Revisao                                          �
//� mv_par13	// Lista 1 -Pendentes 2 - Baixados 3 - Ambos            �
//� mv_par14	// Quebra por Departamentos : 1 - Sim 2 - Nao           �
//� mv_par15	// Filtro Situacao por : 1 - Documento 2 - Usuario      �
//� mv_par16	// Filial de                                            �
//� mv_par17	// Filial Ate                                           �
//�����������������������������������������������������������������������
Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,ctitulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)

If nLastKey = 27
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
EndIf

RptStatus({|lEnd| QDOR050Imp(@lEnd,ctitulo,wnRel,tamanho)},ctitulo)

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QDOR050Imp� Autor � Rodrigo de A. Sartorio� Data � 15/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia para funcao que faz a impressao do relatorio.        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function QDOR050Imp(lEnd,ctitulo,wnRel,tamanho)

Local cCabec1  := " "
Local cCabec2  := " "
Local cbtxt    := SPACE(10)
Local nTipo		:= GetMV("MV_COMP")
Local cbcont   := 0
Local cDepatu  := " "
Local cSeek    := " "
Local cCompara := " "
Local cIndex1  := CriaTrab(Nil,.F.)
Local cIndex2  := CriaTrab(Nil,.F.)
Local cKey     := " "
Local cFiltro  := " "
Local cDocto1  := " "
Local cFilDep  := xFilial("QAD")
Local cDtVig   := GetMv("MV_QIMPENL",.f.,"1") // Habilita Impressao da Pendecia de leitura de doc. vencidos 1=Sim / 2=Nao   

DbSelectarea("QD1")
DbSetOrder(1)

DbSelectarea("QDH")
DbSetOrder(1)
cKey:= QDH->(IndexKey())

cFiltro:= 'QDH->QDH_FILIAL == "'+xFilial("QDH")+'".And.'
If mv_par15 == 1 // Filtro Situacao por Documento
	cFiltro+= 'QDH->QDH_STATUS $ "'+mv_par01+'" .And. '
Endif
cFiltro+= 'QDH->QDH_CODTP >= "'+mv_par03+'" .And. '
cFiltro+= 'QDH->QDH_CODTP <= "'+mv_par04+'" .And. QDH->QDH_DOCTO >= "'+mv_par09+'" .And. '
cFiltro+= 'QDH->QDH_DOCTO <= "'+mv_par10+'" .And. QDH->QDH_RV >= "'+mv_par11+'" .And. '
cFiltro+= 'QDH->QDH_RV <= "'+mv_par12+'"'

//��������������������������������������������������������������Ŀ
//� VerIfica se � ultima versao                                  �
//����������������������������������������������������������������
If mv_par02 == 2
	cFiltro+= ' .And. QDH->QDH_OBSOL == "N"'
EndIf

IndRegua("QDH",cIndex1,cKey,,cFiltro,OemToAnsi(STR0007))	//"Selecionando Registros.."

cKey:= "QD1->QD1_FILIAL+QD1->QD1_DEPTO+QD1->QD1_FILMAT+QD1->QD1_MAT+QD1->QD1_DOCTO+QD1->QD1_RV+DTOS(QD1->QD1_DTGERA)+QD1->QD1_TPPEND"

cFiltro:= 'QD1->QD1_DEPTO >= "'+mv_par05+'" .And. QD1->QD1_DEPTO <= "'+mv_par06+'" .And. '
cFiltro+= 'QD1->QD1_FILMAT >= "'+mv_par16+'" .And. QD1->QD1_FILMAT <= "'+mv_par17+'" .And. '
cFiltro+= 'QD1->QD1_MAT >= "'+mv_par07+'" .And. QD1->QD1_MAT <= "'+mv_par08+'" .And. '
cFiltro+= 'QD1->QD1_DOCTO >= "'+mv_par09+'" .And. QD1->QD1_DOCTO <= "'+mv_par10+'" .And. '
cFiltro+= 'QD1->QD1_RV >= "'+mv_par11+'" .And. QD1->QD1_RV <= "'+mv_par12+'"'

//��������������������������������������������������������������Ŀ
//� VerIfica Tipo da pendencia                                   �
//����������������������������������������������������������������

If mv_par15 == 1 .Or. mv_par15 == 2 // Filtro Situacao por Documento (1) ou Usuario (2)
	cFiltro+= '.And.QD1->QD1_TPPEND $ "'+mv_par01+'"'
Endif

If mv_par13	== 1 	//Pendentes
	cFiltro+= ' .And. QD1->QD1_PENDEN == "P" .And. QD1->QD1_SIT <> "I" '
ElseIf mv_par13 == 2	//Baixados
	cFiltro+= ' .And. QD1->QD1_PENDEN == "B"'
EndIf

IndRegua("QD1",cIndex2,cKey,,cFiltro,OemToAnsi(STR0007))	//"Selecionando Registros.."

//         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16         17        18
//1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123145678901234567890
//DOCUMENTO/REVISAO    TITULO                                                                                               PENDENCIA                DATA DE   DATA DA   STATUS     DIAS
//                                                                                                                                                   CRIACAO   BAIXA     DA BAIXA


cCabec1:= OemToAnsi(STR0008) //"DOCUMENTO/REVISAO    TITULO                                                                                             PENDENCIA                DATA DE  DATA DA  STATUS     DIAS"
cCabec2:= OemToAnsi(STR0009) //"                                                                                                                                                 CRIACAO  BAIXA    DA BAIXA"

li       := 80
m_pag    := 1

QD1->(DbSeek(xFilial()))
SetRegua(QD1->(LastRec())) // Total de Elementos da Regua

cDepatu := QD1->QD1_FILIAL+QD1->QD1_DEPTO

While QD1->(!Eof()) .And. QD1->QD1_FILIAL == xFilial("QD1")
	cDocto1 := " "
	cSeek   := QD1->QD1_FILIAL+QD1->QD1_DEPTO+QD1->QD1_FILMAT+QD1->QD1_MAT
	cCompara:= "QD1->QD1_FILIAL+QD1->QD1_DEPTO+QD1->QD1_FILMAT+QD1->QD1_MAT"
	If FWModeAccess("QAD") == "E" //!Empty(cFildep)
		cFilDep:= QD1->QD1_FILMAT
	EndIf
	
	If lEnd
		li++
		@ PROW()+1,001 PSAY OemToAnsi(STR0010)	//"CANCELADO PELO OPERADOR"
		Exit
	EndIf
	If !QDOR050Vld(@cDocto1)
		IncRegua()
		QD1->(DbSkip())
		Loop
	EndIf
	If li > 58 .Or. (cDepatu <> QD1->QD1_FILIAl+QD1->QD1_DEPTO .And. mv_par14 == 1)
		Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
		cDepatu:= QD1->QD1_FILIAL+QD1->QD1_DEPTO
	EndIf
	@ li,00 PSay Upper(STR0011)+QD1->QD1_DEPTO+" - "+QA_NDEPT(QD1->QD1_DEPTO,.T.,cFilDep) //"Departamento: "
	li++
	@ li,00 PSay OemToAnsi(STR0017) + QD1->QD1_FILMAT //"FILIAL: "
	@ li,21 Psay OemToAnsi(STR0018) + QD1->QD1_MAT //"MATRICULA: "
	@ li,58 PSay Upper(STR0012)+QA_NUSR(QD1->QD1_FILMAT,QD1->QD1_MAT,.T.) //"Responsavel : "
	li++
	@ li,000 PSay __PrtFatLine()
	li++
	While QD1->(!Eof()) .And. cSeek == &(cCompara)
		IncRegua()
		cDocto1:= " "
		If lEnd
			li++
			@ PROW()+1,001 PSAY STR0010	//"CANCELADO PELO OPERADOR"
			Exit
		EndIf
		If !QDOR050Vld(@cDocto1)
			QD1->(DbSkip())
			Loop
		EndIf
		If li > 58 .Or. (cDepatu <> QD1->QD1_FILIAL+QD1->QD1_DEPTO .And. mv_par14 == 1)
			Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
			cDepatu:= QD1->QD1_FILIAL+QD1->QD1_DEPTO
		EndIf
		@ li,000 PSay AllTrim(QD1->QD1_DOCTO)+"/"+QD1->QD1_RV
		@ li,021 PSay cDocto1
		DbSelectArea("SX5")
		If SX5->(DbSeek(xFilial("SX5")+"Q7"+QD1->QD1_TPPEND))
			@ li,122 PSay Substr(X5Descri(),1,25)
		EndIf
		@ li,147 PSay QD1->QD1_DTGERA
		@ li,158 PSay QD1->QD1_DTBAIX
		If QD1->QD1_PENDEN =="P"
			@ li,170 PSay OemToAnsi(STR0013) // "Pendente"
			@ li,181 Psay Right(Str(dDataBase - QD1->QD1_DTGERA),4)
		ElseIf QD1->QD1_PENDEN == "B"
			@ li,170 PSay OemToAnsi(STR0014) // "Baixado"
		Endif
		li++
		QD1->(DbSkip())
	EndDo
	@ li,000 Psay __PrtThinLine()
	li+=2
	cFilDep:= xFilial("QAD")
EndDo

If li <> 80
	Roda(cbcont,cbtxt,tamanho)
EndIf

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
cIndex1 += OrDbagExt()
Delete File &(cIndex1)

cIndex2 += OrDbagExt()
Delete File &(cIndex2)

Set Device To Screen

If aReturn[5] = 1
	Set Printer TO
	DbCommitAll()
	ourspool(wnrel)
EndIf
MS_FLUSH()

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QDOR050Vld� Autor � Rodrigo de A. Sartorio� Data � 15/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida registro para impressao e recupera titulo do doc.   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QDOR050Vld(ExpC1,ExpC2)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Titulo do Documento                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function QDOR050Vld(cDocto1)
Local lRet   := .F.
Local cDtVig   := GetMv("MV_QIMPENL",.f.,"1") // Habilita Impressao da Pendecia de leitura de doc. vencidos 1=Sim / 2=Nao   

//�������������������������������������������������������Ŀ
//� Verifica se Documento Existe no Cadastro de Documento �
//���������������������������������������������������������
If QDH->(DbSeek(QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV))
	cDocto1:= Substr(AllTrim(QDH->QDH_TITULO),1,100)
	lRet:= .T.
	//���������������������������������������������������������������������������������Ŀ
	//�Valida se a data de implantacao e menor que a data dosistema (documento vencido )�
	//�����������������������������������������������������������������������������������
	If QDH->QDH_DTLIM <= dDatabase .and. QD1->QD1_TPPEND $"L  "
		If cDtVig <> "1"  
			lRet:= .F.
		Endif 
	Endif
EndIf
Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QDO50VSEL �Autor  �Leandro Sabino      � Data �  12/03/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Controla a impressao das Pendencias atraves da verificacao ���
���          � do parametro "MV_QIMPENL"                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QDOR50SEL(cSeekQDH,cSel)
Local lRet		:=.T.

If QDH->(DbSeek(cSeekQDH))
 	lRet:= .T.
	//���������������������������������������������������������������������������������Ŀ
	//�Valida se a data de implantacao e menor que a data dosistema (documento vencido )�
	//�����������������������������������������������������������������������������������
	If QDH->QDH_DTLIM <= dDatabase .and. QD1->QD1_TPPEND $"L  "
		If cSel <> "1"  
			lRet:= .F.
		Endif 
	Endif
EndIf

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QDO50VSEL �Autor  �Leandro Sabino      � Data �  12/03/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Controla a impressao das Pendencias atraves da verificacao ���
���          � do parametro "MV_QIMPENL"                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QDOR50FIL(cTPPend,dDTLIM)
Local lRet	 :=.T.
Local cDtVig   := GetMv("MV_QIMPENL",.f.,"1") // Habilita Impressao da Pendecia de leitura de doc. vencidos 1=Sim / 2=Nao   

If cDtVig <> "1" .and. cTPPend =="L  " .and. dDTLIM < dDatabase 
   	lRet := .F.
Endif

Return(lRet)


