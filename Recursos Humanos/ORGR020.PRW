#INCLUDE "orgr020.ch"
#INCLUDE "protheus.ch"      
#INCLUDE "report.ch"

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa     � ORGR020  � Autor � Tania Bronzeri        � Data �23/11/2006���
����������������������������������������������������������������������������Ĵ��
���Descri��o    � Relacao de Postos                                          ���
����������������������������������������������������������������������������Ĵ��
���Uso          � SigaOrg - Arquitetura Organizacional                       ���
����������������������������������������������������������������������������Ĵ��
���Programador  � Data   � BOPS �  Motivo da Alteracao                       ���  
����������������������������������������������������������������������������Ĵ�� 
���Cecilia Carv.�07/08/14�TQEQKP�Incluido o fonte da 11 para a 12 e efetuada ���
���             �        �      �a limpeza.                                  ���
���Cecilia Carv.�25/08/14�TQIDWA�Corrigido a impressao da descricao do depar-���
���             �        �      �tamento.                                    ���
���Luis Artuso  �15/01/15�TRGBLV�Correcao nos totalizadores  e melhorias     ���
���Gabriel A.   �19/08/16�TVUIZG�Ajuste p/ imprimir corretamente os totais.  ���
�����������������������������������������������������������������������������ٱ� 
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function ORGR020()  

Local oReport   
Local aArea 		:= GetArea()
Private cAliasQry	:= "RCL"

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("ORG20R",.F.) 

oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportDef  � Autor � Tania Bronzeri        � Data �23/11/2006���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Cadastro de Postos                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ORGR020                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � ORGR020 - Generico                                           ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function ReportDef()
Local oReport 
Local oSection1, oSection2
//Local bNomeOcup := {||Iif((cAliasQry)->RCL_TIPOCU=="1",fPesqOcu("SRA",(cAliasQry)->RCL_FILOCU,(cAliasQry)->RCL_CODOCU),fPesqOcu("RD0",(cAliasQry)->RCL_FILOCU,(cAliasQry)->RCL_CODOCU))}
//Local bNomeOcup := {|| ""}
Local cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0002)
	//"Cadastro de Postos" ### "Ser� impresso de acordo com os parametros solicitados pelo usu�rio."
Private aOrd    := {OemToAnsi(STR0003),OemToAnsi(STR0004),OemToAnsi(STR0005)}	
					//"Codigo do Posto" ### "Departamento" ### "Centro de Custo"
Private cTitulo	:= OemToAnsi(STR0001)	//"Cadastro de Postos"

//������������������������������������������������������������������������Ŀ
//�Criacao dos componentes de impressao                                    �
//��������������������������������������������������������������������������
DEFINE REPORT oReport NAME "ORGR020" TITLE cTitulo PARAMETER "ORG20R" ACTION {|oReport| ORG20Imp(oReport)} DESCRIPTION OemtoAnsi(STR0006)	//"Este relatorio emite relacao dos Postos cadastradas."

	DEFINE SECTION oSection1 OF oReport TITLE OemToAnsi(STR0007) TABLES "RCL", "SQB" ORDERS aOrd	//"Postos"
		DEFINE CELL NAME "RCL_FILIAL"  	OF oSection1 ALIAS "RCL"
		DEFINE CELL NAME "RCL_DEPTO"  	OF oSection1 /*SIZE (GetSx3Cache("RCL_DEPTO", "X3_TAMANHO") + 4)*/ ALIAS "RCL"
		DEFINE CELL NAME "QB_DESCRIC" 	OF oSection1 ALIAS "SQB" 
		DEFINE CELL NAME "RCL_CC"     	OF oSection1 /*SIZE (GetSx3Cache("RCL_CC", "X3_TAMANHO") + 4)*/ ALIAS "RCL"
		DEFINE CELL NAME "CTT_DESC01"  	OF oSection1 ALIAS "CTT"
		DEFINE CELL NAME "RCL_POSTO"	OF oSection1 SIZE (GetSx3Cache("RCL_POSTO", "X3_TAMANHO") + 4) ALIAS "RCL"
		TRPosition():New(oSection1, "CTT", 1, {|| RhFilial("CTT", (cAliasQry)->RCL_FILIAL) + (cAliasQry)->RCL_CC})
		TRPosition():New(oSection1, "SQB", 1, {|| RhFilial("SQB", xFilial("SQB",(cAliasQry)->RCL_FILIAL)) + (cAliasQry)->RCL_DEPTO})
		oSection1:cell("RCL_POSTO"):disable()
		
	DEFINE SECTION oSection2 OF oSection1 TITLE OemToAnsi(STR0007) TABLES "RCL", "CTT" ORDERS aOrd	//"Postos"		
		DEFINE CELL NAME "RCL_POSTO"	OF oSection2 SIZE (GetSx3Cache("RCL_POSTO", "X3_TAMANHO") + 4) ALIAS "RCL"
		
		DEFINE CELL NAME "RCL_FUNCAO"	OF oSection2 SIZE (GetSx3Cache("RCL_FUNCAO", "X3_TAMANHO") + 15) ALIAS "RCL"
		DEFINE CELL NAME "RCL_CARGO"	OF oSection2 /*SIZE (GetSx3Cache("RCL_CARGO", "X3_TAMANHO") + 4)*/ ALIAS "RCL"
		DEFINE CELL NAME "RCL_SALAR"	OF oSection2 ALIAS "RCL"
		DEFINE CELL NAME "RCL_BENEF"	OF oSection2 ALIAS "RCL"
		DEFINE CELL NAME "RCL_ENCARG"	OF oSection2 ALIAS "RCL" ALIGN RIGHT
		DEFINE CELL NAME "RCL_DEPTO"  	OF oSection2 /*SIZE (GetSx3Cache("RCL_DEPTO", "X3_TAMANHO") + 4)*/ ALIAS "RCL"
		DEFINE CELL NAME "RCL_CC"     	OF oSection2 /*SIZE (GetSx3Cache("RCL_CC", "X3_TAMANHO") + 4)*/ ALIAS "RCL"
		oSection2:cell("RCL_DEPTO"):disable()
		oSection2:cell("RCL_CC"):disable()

                                 
		oReport:SetColSpace(4)
Return(oReport)


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ORG20Imp   � Autor � Tania Bronzeri        � Data �23/11/2006���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Cadastro de Postos                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function ORG20Imp(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oSection1:Section(1)
Local cFiltro 	:= "" 
Local cTitCC	:= ""
Local cTitDep	:= ""
Local cTitFil	:= ""
Local lTotliz 	:= .T.	
Local lQuebra	:= .T. 

Private cOrdem	:= ""
Private nOrdem	:= oSection1:GetOrder()

lTotliz := Iif(mv_par05==1,.T.,.F.) 	//  Totaliza Sim / Nao
lQuebra	:= Iif(mv_par06==1,.T.,.F.) 	//  Quebra Pagina Sim / Nao  

If nOrdem == 3 // ordem por centro de custo
	oSection1:cell("RCL_DEPTO"):disable()
	oSection2:cell("RCL_CC"):disable()
	oSection2:cell("RCL_DEPTO"):enable()
Elseif nOrdem == 2 // departamento
	oSection1:cell("RCL_CC"):disable()
	oSection2:cell("RCL_DEPTO"):disable()
	oSection2:cell("RCL_CC"):enable()
Endif

If lTotliz
	If nOrdem == 3
		//-- Totalizar por Centro de Custo
		DEFINE BREAK oBreakCc OF oSection1  WHEN oSection1:Cell("RCL_CC") TITLE OemToAnsi(STR0014)	// "Total Centro de Custo"
		DEFINE FUNCTION oCcPostos     NAME "CCPOSTOS"     FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakCc TITLE OemToAnsi(STR0009) PICTURE "9999"		NO END SECTION											//"Numero de Postos"
		DEFINE FUNCTION oCcVagos      NAME "CCVAGOS"      FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakCc TITLE OemToAnsi(STR0011) PICTURE "9999"		NO END SECTION WHEN {||(cAliasQry)->RCL_STATUS=="1"}	//"Vagos"
		DEFINE FUNCTION oCcOcupados   NAME "CCOCUPADOS"   FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakCc TITLE OemToAnsi(STR0010) PICTURE "9999"		NO END SECTION WHEN {||(cAliasQry)->RCL_STATUS=="2"}	//"Ocupados"
		DEFINE FUNCTION oCcCongelados NAME "CCCONGELADOS" FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakCc TITLE OemToAnsi(STR0013) PICTURE "9999"		NO END SECTION WHEN {||(cAliasQry)->RCL_STATUS=="3"}	//"Congelados"
		DEFINE FUNCTION oCcCancelados NAME "CCCANCELADOS" FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakCc TITLE OemToAnsi(STR0012) PICTURE "9999"		NO END SECTION WHEN {||(cAliasQry)->RCL_STATUS=="4"}	//"Cancelados"		
		oBreakCc:OnBreak({|x,y|cTitCC:=OemToAnsi(STR0014)+x})	//"Total Centro de Custo"
    	oBreakCc:SetTotalText({||cTitCC})
		oCcPostos:SetTitle(OemToAnsi(STR0009))
		oCcOcupados:SetTitle(OemToAnsi(STR0010))
		oCcVagos:SetTitle(OemToAnsi(STR0011))
		oCcCancelados:SetTitle(OemToAnsi(STR0012))
		oCcCongelados:SetTitle(OemToAnsi(STR0013))
		oCcPostos:ShowHeader()                  
		oCcOcupados:ShowHeader()
		oCcVagos:ShowHeader()
		oCcCancelados:ShowHeader()
		oCcCongelados:ShowHeader()
		If lQuebra
			oBreakCC:SetPageBreak()
		EndIf
	ElseIf nOrdem == 1
		//-- Totalizar por Filial
		DEFINE BREAK oBreakFil OF oSection1  WHEN oSection1:Cell("RCL_FILIAL") TITLE OemToAnsi(STR0015)	// "Total Filial"
		DEFINE FUNCTION oFilPostos     NAME "FILPOSTOS"     FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakFil TITLE OemToAnsi(STR0009) PICTURE "9999"	NO END SECTION											//"Numero de Postos"
		DEFINE FUNCTION oFilVagos      NAME "FILVAGOS"      FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakFil TITLE OemToAnsi(STR0011) PICTURE "9999"	NO END SECTION WHEN {||(cAliasQry)->RCL_STATUS=="1"}	//"Vagos"
		DEFINE FUNCTION oFilOcupados   NAME "FILOCUPADOS"   FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakFil TITLE OemToAnsi(STR0010) PICTURE "9999"	NO END SECTION WHEN {||(cAliasQry)->RCL_STATUS=="2"}	//"Ocupados"
		DEFINE FUNCTION oFilCongelados NAME "FILCONGELADOS" FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakFil TITLE OemToAnsi(STR0013) PICTURE "9999"	NO END SECTION WHEN {||(cAliasQry)->RCL_STATUS=="3"}	//"Congelados"
		DEFINE FUNCTION oFilCancelados NAME "FILCANCELADOS" FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakFil TITLE OemToAnsi(STR0012) PICTURE "9999"	NO END SECTION WHEN {||(cAliasQry)->RCL_STATUS=="4"}	//"Cancelados"
		oBreakFil:OnBreak({|x,y|cTitFil:=OemToAnsi(STR0015)+x})	//"Total Filial"
    	oBreakFil:SetTotalText({||cTitFil})
		oFilPostos:SetTitle(OemToAnsi(STR0009))
		oFilOcupados:SetTitle(OemToAnsi(STR0010))
		oFilVagos:SetTitle(OemToAnsi(STR0011))
		oFilCancelados:SetTitle(OemToAnsi(STR0012))
		oFilCongelados:SetTitle(OemToAnsi(STR0013))
		oFilPostos:ShowHeader()                  
		oFilOcupados:ShowHeader()
		oFilVagos:ShowHeader()
		oFilCancelados:ShowHeader()
		oFilCongelados:ShowHeader()
		If lQuebra
			oBreakFil:SetPageBreak()
		EndIf
	Else	
		//-- Totalizar por Departamento
		DEFINE BREAK oBreakDep OF oSection1  WHEN oSection1:Cell("RCL_DEPTO") TITLE OemToAnsi(STR0016)	// "Total Departamento"
		DEFINE FUNCTION oDepPostos     NAME "DEPPOSTOS"     FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakDep TITLE OemToAnsi(STR0009) PICTURE "9999"	NO END SECTION											//"Numero de Postos"
		DEFINE FUNCTION oDepVagos      NAME "DEPVAGOS"      FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakDep TITLE OemToAnsi(STR0011) PICTURE "9999"	NO END SECTION WHEN {||(cAliasQry)->RCL_STATUS=="1"}	//"Vagos"
		DEFINE FUNCTION oDepOcupados   NAME "DEPOCUPADOS"   FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakDep TITLE OemToAnsi(STR0010) PICTURE "9999"	NO END SECTION WHEN {||(cAliasQry)->RCL_STATUS=="2"}	//"Ocupados"
		DEFINE FUNCTION oDepCongelados NAME "DEPCONGELADOS" FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakDep TITLE OemToAnsi(STR0013) PICTURE "9999"	NO END SECTION WHEN {||(cAliasQry)->RCL_STATUS=="3"}	//"Congelados"
		DEFINE FUNCTION oDepCancelados NAME "DEPCANCELADOS" FROM oSection2:Cell("RCL_FUNCAO") FUNCTION COUNT BREAK oBreakDep TITLE OemToAnsi(STR0012) PICTURE "9999"	NO END SECTION WHEN {||(cAliasQry)->RCL_STATUS=="4"}	//"Cancelados"
		oBreakDep:OnBreak({|x,y|cTitDep:=OemToAnsi(STR0016)+x})	//"Total Departamento"
    	oBreakDep:SetTotalText({||cTitDep})
		oDepPostos:SetTitle(OemToAnsi(STR0009))
		oDepOcupados:SetTitle(OemToAnsi(STR0010))
		oDepVagos:SetTitle(OemToAnsi(STR0011))
		oDepCancelados:SetTitle(OemToAnsi(STR0012))
		oDepCongelados:SetTitle(OemToAnsi(STR0013))
		oDepPostos:ShowHeader()                  
		oDepOcupados:ShowHeader()
		oDepVagos:ShowHeader()
		oDepCancelados:ShowHeader()
		oDepCongelados:ShowHeader()
		If lQuebra
			oBreakDep:SetPageBreak()
		EndIf
	EndIf
EndIf

cAliasQry := GetNextAlias()

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr("ORG20R")
	
BEGIN REPORT QUERY oSection1

If nOrdem == 2
	cOrdem  := "%RCL.RCL_FILIAL,RCL.RCL_DEPTO,RCL.RCL_POSTO%"		
ElseIf nOrdem == 1
	cOrdem  := "%RCL.RCL_FILIAL,RCL.RCL_POSTO%"
Else
	cOrdem  := "%RCL.RCL_FILIAL,RCL.RCL_CC,RCL.RCL_POSTO%"
EndIf
	
BeginSql alias cAliasQry
	SELECT 	
		RCL.RCL_FILIAL,
		RCL.RCL_POSTO,
		RCL.RCL_DEPTO,
		RCL.RCL_CC,
		RCL.RCL_FUNCAO,
		RCL.RCL_CARGO,
		RCL.RCL_SALAR,
		RCL.RCL_BENEF,
		RCL.RCL_ENCARG,
		RCL.RCL_STATUS 
	FROM 
		%table:RCL% RCL 
	WHERE 
		RCL.%notDel%  
	ORDER BY
		%exp:cOrdem%
EndSql

/*	BeginSql alias cAliasQry
	SELECT 	
		RCL.RCL_FILIAL,
		RCL.RCL_POSTO,
		RCL.RCL_DEPTO,
		RCL.RCL_CC,
		RCL.RCL_FUNCAO,
		RCL.RCL_CARGO,
		RCL.RCL_SALAR,
		RCL.RCL_BENEF,
		RCL.RCL_ENCARG,
		RCL.RCL_CODOCU,
		RCL.RCL_TIPOCU,
		RCL.RCL_FILOCU,
		RCL.RCL_STATUS 
	FROM 
		%table:RCL% RCL 
	WHERE 
		RCL.%notDel%  
	ORDER BY
		%exp:cOrdem%
EndSql
*/

/*
Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
pela funcao MakeSqlExpr para serem adicionados a query
*/
END REPORT QUERY oSection1 PARAM mv_par01, mv_par02, mv_par03

oSection1:EndQuery()
oSection2:SetParentQuery()	
If nOrdem == 1
	oSection2:SetParentFilter({|cParam| (cAliasQry)->RCL_POSTO == cParam },{|| (cAliasQry)->RCL_POSTO })
elseif nOrdem == 2
	oSection2:SetParentFilter({|cParam| (cAliasQry)->RCL_DEPTO == cParam },{|| (cAliasQry)->RCL_DEPTO })
else
	oSection2:SetParentFilter({|cParam| (cAliasQry)->RCL_CC == cParam },{|| (cAliasQry)->RCL_CC })
Endif

//�������������������������������������������Ŀ
//� Inicio da impressao do fluxo do relat�rio �
//���������������������������������������������
oReport:SetMeter( (cAliasQry)->(LastRec()) )  

oSection1:Print()	 //Imprimir

Return
                             
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � fPesqOcu � Autor � Tania Bronzeri        � Data � 27/11/2016 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Pesquisa o nome do Ocupante do Posto                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fPesqOcu(cTabOcu, cFilOcu, cCodOcu                           ���
���������������������������������������������������������������������������Ĵ��
���Par�metros� cTabOcu => Tabela do Ocupante SRA=Funcionariso/RD0=Pessoas   ���
���			 � cFilOcu => Filial do Ocupante                                ���
���			 � cCodOcu => Codigo do Ocupante ou Matricula do Funcionario    ���
���������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAORG  	 	 	 	 	 	 	 	 	 	 	 	    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
/*Static Function fPesqOcu(cTabOcu, cFilOcu, cCodOcu)
Local aArea := GetArea()
Local cNome	:= ""

DbSelectArea(cTabOcu)  
If dbSeek((cTabOcu)->(cFilOcu + cCodOcu))
	If cTabOcu == "SRA"
		cNome := (cTabOcu)->RA_NOME
	Else
		cNome := (cTabOcu)->RD0_NOME
	EndIf                                         
EndIf
	
RestArea( aArea )

Return cNome
*/            

