#INCLUDE "PROTHEUS.CH"
#INCLUDE "CSAR010.CH"

/*
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������Ŀ��
���Fun��o      � CSAR010  � Autor � Emerson Grassi Rocha         � Data �  22/06/06  ���
������������������������������������������������������������������������������������Ĵ��
���Descri��o   � Relatorio de Graduacao de Fatores (Personalizavel)                  ���
������������������������������������������������������������������������������������Ĵ��
���Sintaxe     � CSAR010(void)                                                       ���
������������������������������������������������������������������������������������Ĵ��
���Parametros  �                                                                     ���
������������������������������������������������������������������������������������Ĵ��
��� Uso        � CSAR010                                                             ���
������������������������������������������������������������������������������������Ĵ��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                      ���
������������������������������������������������������������������������������������Ĵ��
���Programador   � Data     � BOPS �  Motivo da Alteracao                            ���
������������������������������������������������������������������������������������Ĵ��
���Cecilia Carv. �30/07/2014�TPZVV4       �Incluido o fonte da 11 para a 12 e efetua-���
���              �          �             �da a limpeza.                             ���
���M. Silveira   �05/04/2017�DRHPONTP-51  �Substituida a funcao MSMM pela RHMSMM.    ���
�������������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������*/
Function CSAR010()
Local oReport
Local aArea := GetArea()

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("CS010R",.F.)
oReport := ReportDef()
oReport:PrintDialog()	

RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Emerson Grassi Rocha� Data � 22/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Definicao do Componente de Impressao do Relatorio           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local oSection1
Local oSection2         
Local cAliasQry := "SQ0"

#IFDEF TOP
	cAliasQry := GetNextAlias()
#ENDIF 
//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
oReport:=TReport():New("CSAR010",STR0007,"CS010R",{|oReport| PrintReport(oReport,cAliasQry)},STR0001+" "+STR0002+" "+STR0003)	//"RELACAO DE GRADUACAO DE FATORES "###"Rela��o de Gradua��o de Fatores"###"Ser� impresso de acordo com os parametros solicitados pelo"###"usuario."

oReport:SetTotalInLine(.F.) //Totaliza em linha

//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//��������������������������������������������������������������������������

//���������������������������Ŀ
//� Secao de Grupo			  �
//����������������������������� 
oSection1 := TRSection():New(oReport,STR0008,{"SQ0"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//"RELACAO DE GRADUACAO DE FATORES "
oSection1:SetTotalInLine(.F.)     
TRCell():New(oSection1,"Q0_GRUPO","SQ0")		//Codigo do Grupo
TRCell():New(oSection1,"Q0_DESCRIC","SQ0","")	//Descricao do Grupo  

//���������������������������Ŀ
//� Secao de Fator			  �
//�����������������������������
oSection2 := TRSection():New(oSection1,STR0009,{"SQ1"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//Fatores de Avaliacao
oSection2:SetTotalInLine(.F.) 
TRCell():New(oSection2,"Q1_FATOR","SQ1",,,10,.T.) 											//Codigo do Fator
TRCell():New(oSection2,"Q1_DESCSUM","SQ1")											//Descricao do Fator
TRCell():New(oSection2,"Q1_MEMO1","SQ1",,,,,{|| RHMSMM((cAliasQry)->Q1_DESCDET,,,,3,,,,,,,"SQ1") })		//Descricao Detalhada   
oSection2:Cell("Q1_MEMO1"):SetLineBreak()

//���������������������������Ŀ
//� Secao de Graduacao 		  �
//�����������������������������
oSection3 := TRSection():New(oSection2,STR0010,{"SQ2"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//Graduacao Fatores
oSection3:SetTotalInLine(.F.) 
TRCell():New(oSection3,"Q2_GRAU","SQ2") 	//Codigo do Grau
TRCell():New(oSection3,"Q2_DESC","SQ2")		//Descricao do Grau
TRCell():New(oSection3,"Q2_PONTOSI","SQ2") 	//Pontos Informados

Return oReport

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PrintReport � Autor � Emerson Grassi Rocha� Data � 22/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do Relatorio 						              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function PrintReport(oReport,cAliasQry)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)  
Local oSection3 := oReport:Section(1):Section(1):Section(1)  
Local lAcesso	:=	.F. // Tabela compartilhada ou Exclusiva
Local lGeraString	:=	.T.
Local nIni	:= 0
Local nAnd	:= 0
Local nFim	:= 0
Local cPar01	:=	""
Local nTamFil	:=	0
Local nTamPar	:= 0	

#IFDEF TOP
	Local lQuery    := .F. 
#ELSE	
	Local cFiltro := ""
#ENDIF

//������������������������������������������������������������������Ŀ
//� Variaveis utilizadas na pergunte                                 �
//� MV_PAR01				// Filial	                             �
//� MV_PAR02				// Grupo		                         �
//� MV_PAR03				// Fator	                             �
//� MV_PAR04				// Grau			                         �
//� MV_PAR05				// Imprime Pontos dos Fatores S/N        �
//� MV_PAR06				// Imprime Desc. Detalhada do Fator S/N  �
//��������������������������������������������������������������������
lAcesso	:=	FWModeAccess(cAliasQry)	== "C" // Verifica se a tabela eh compartilhada.
If ( lAcesso )
	nTamFil	:=	LEN(ALLTRIM(xFilial(cAliasQry)))
	nTamPar	:=	LEN(MV_PAR01)
	cPar01	:= 	""
	nIni	:= 0
	nFim	:= 0
	Do While ( lGeraString )
		nIni	:=	nFim
		++nFim
		If ( EMPTY(SUBSTR(MV_PAR01 , nFim , 1)) .OR. (nFim > nTamPar ) )
			lGeraString	:=	.F.
		Else
			nAnd	:= 0
			Do While ( (!SUBSTR(MV_PAR01 , nFim++ , 1) == ";") .AND. (nFim <= nTamPar ) )
				If ( SUBSTR(MV_PAR01 , nFim , 1) == "-")
					nAnd	:= nFim // Guarda a posicao do separador "E" da Query.
				EndIf
			EndDo
			If ( nAnd == 0 )			
				cPar01	+=	SUBSTR( MV_PAR01 , ++nIni , nTamFil ) + ";"
			Else				
				cPar01	+=	SUBSTR( MV_PAR01 , ++nIni , nTamFil ) + SUBSTR( MV_PAR01 , nAnd , nTamFil + 1 ) + ";"	
			EndIf
		EndIf
	EndDo
	MV_PAR01	:=	cPar01
EndIf
//-- Transforma parametros Range em expressao (intervalo)
MakeSqlExpr("CS010R") 	

If Empty(xFilial("SQ0"))
	MV_PAR01 := Space(FWGETTAMFILIAL)
EndIf

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
lQuery := .T.          
cOrder := "%Q2_FILIAL, Q2_GRUPO, Q2_FATOR, Q2_GRAU%"        

oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry

	SELECT	Q0_FILIAL, Q0_GRUPO, Q0_DESCRIC, Q1_FILIAL, Q1_GRUPO, Q1_FATOR, Q1_DESCSUM,Q1_DESCDET, Q2_FILIAL, Q2_GRUPO, Q2_FATOR, Q2_GRAU, Q2_DESC, Q2_PONTOSI //Nao colocar memo(virtual) 								
			
	FROM 	%table:SQ0% SQ0
	
	LEFT JOIN %table:SQ1% SQ1
		ON Q1_FILIAL = %xFilial:SQ1%
		AND Q1_GRUPO = Q0_GRUPO
		AND SQ1.%NotDel%      

	LEFT JOIN %table:SQ2% SQ2
		ON Q2_FILIAL = %xFilial:SQ2%
		AND Q2_GRUPO = Q1_GRUPO
		AND Q2_FATOR = Q1_FATOR
		AND SQ2.%NotDel%
	
	WHERE SQ0.%NotDel%   	
											
	ORDER BY %Exp:cOrder%                 		
	
EndSql

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�ExpA1 : Array com os parametros do tipo Range                           �
//��������������������������������������������������������������������������
oReport:Section(1):EndQuery( {MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04} )//Array com os parametros do tipo Range

oSection2:SetParentFilter({|cParam| (cAliasQry)->Q1_FILIAL + (cAliasQry)->Q1_GRUPO == cParam},{|| (cAliasQry)->Q0_FILIAL + (cAliasQry)->Q0_GRUPO}) 
oSection3:SetParentFilter({|cParam| (cAliasQry)->Q2_FILIAL + (cAliasQry)->Q2_GRUPO + (cAliasQry)->Q2_FATOR == cParam},{|| (cAliasQry)->Q1_FILIAL + (cAliasQry)->Q1_GRUPO + (cAliasQry)->Q1_FATOR})

//�������������������������Ŀ
//� Utiliza a query do Pai  �
//���������������������������
oSection2:SetParentQuery()
oSection3:SetParentQuery()

//���������������������������Ŀ
//� Impressao do Relatorio    �
//�����������������������������
oReport:SetMeter((cAliasQry)->(LastRec()))

//���������������������������Ŀ
//� Imprime Pontos dos Fatores�
//�����������������������������
If MV_PAR05 == 2 //Nao   
	oSection3:Cell("Q2_PONTOSI"):Disable()
EndIf                          

//���������������������������Ŀ
//� Imp. Desc. Detal. do Fator�
//�����������������������������
If MV_PAR06 == 2 //Nao   
	oSection2:Cell("Q1_MEMO1"):Disable()
EndIf                   	
	
oSection1:Print()	 //Imprimir

Return Nil