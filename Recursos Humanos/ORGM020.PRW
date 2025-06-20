#include "Protheus.ch"
#include "ORGM020.CH"
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ORGM020  � Autor � Marcos Alves          � Data � 30/08/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Carga dos departamento a partir do Centro de Custo         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ORGM020(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAORG                                                    ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
�������������������������������������������������������������������������Ĵ��
���Obs.      �                                                            ��� 
�������������������������������������������������������������������������Ĵ��
���Program.  � Data   � BOPS �  Motivo da Alteracao                       ���
�������������������������������������������������������������������������Ĵ��
���Cecilia C.�01/08/14�TQEIB9�Incluido o fonte da 11 para a 12 e efetuada ���
���          �        �      �a limpeza.                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function ORGM020()
Local aSays			:= {}		// Array de Mensagens da tela de parametros
Local aButtons		:= {} 		// array locais de preferencia
Local nOpca 		:= 0		// Variavel de opcao
Local lEmpProc		:= SuperGetMV("MV_ORGCEMP",.F.,"N")=="S" //Processa todas as empreas?
Private cCadastro 	:= STR0001	// Titulo da Tela ->"Carga dos Departamento"
/*
VALIDA��O DE COMPARTILHAMENTO DE TABELAS RCL E SQB
*/
If FindFunction("fVldCompt")
	If !fVldCompt()
		Return .F.
	EndIf
EndIf	
Pergunte("ORGM020",.F.)

AADD(aSays, STR0002	)	//"Este programa tem a finalidade de gerar a carga inicial"  
AADD(aSays, STR0003	)	//"dos departamento a partir do cadastro de Centro de Custo"  	

AADD(aButtons, { 5,.T.,{|| Pergunte("ORGM020",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,If(GpConfOK(),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
FormBatch( cCadastro, aSays, aButtons )

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//����������������������������������������������������������������
If nOpca == 1
	//���������������������������������������������������������������Ŀ
	//� Seleciona os participante do Criterio e Visao                 �
	//�����������������������������������������������������������������
	Proc2BarGauge(	{ || OrgM20Processa(lEmpProc) }	,;	//Acao a ser Executada
						NIL							,;	//Titulo do Dialogo         
						NIL							,;	//Mensagem para a 1a. BarGauge 
						NIL 						,;	//Mensagem para a 2a. BarGauge
						.T.							,;	//Se habilitara o botao para "Abortar" o processo
						.T.							,;	//Se havera controle de estimativa de tempo na 1a. BarGauge
						.T.							,;	//Se havera conteole de estimativa de tempo na 2a. BarGauge
						lEmpProc					 ;	//Se ira mostrar a 2a. BarGauge / Caso parametro esteja para todas as empreas
					  )
EndIf

Return Nil

/*�������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �OrgM20Processa� Autor � Marcos Alves          � Data � 30/08/07 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Processamento da carga inicial dos departamentos				  ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �OrgM20Processa(lEmpProc)										  ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�lEmpProc - Carga completa as empresas							  ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                          ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAORG														  ���
�����������������������������������������������������������������������������Ĵ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/
Function OrgM20Processa(lEmpProc)
Local nCountTime					// Laco For Next
Local aEmp				:={}		// Array da Empresa
Local nLoop				:=0			// Total do Laco For Next
Local cMsg1							// Mensagem do Bauge 1			
Local cEmpBack			:=cEmpAnt	// Backup da empresa atual
Local cFilBack			:=cFilAnt	// Backup da Filial atual
Local aFiles			:={}		// Array das tabelas a serem abertas
Local nPosAlias 		:= 0		//Posicionamento do array das tabelas
Local lProc				:=.F.
Local cMV_Par01			:= ""
Local nX				:= 0
Local aRetSM0	        := {}
Local lFWLoadSM0		:= FindFunction("FWLoadSM0")

Private cFilSQB			:=xFilial("SQB")				//Filial da Tabela SQB
Private	cFilCTT			:=xFilial("CTT")   				//Filial da Tabela CTT
Private	cModoSQB		:=If(Empty(cFilSQB),"C","E")	//Modo acesso da tabela SQB
Private	cModoCTT		:=If(Empty(cFilCTT),"C","E")	//Modo acesso da tabela CTT

//���������������������������������������������������������������Ŀ
//� Tabelas a serem abertas de outra empresa				      �
//�����������������������������������������������������������������
aadd(aFiles,{"CTT",""})
aadd(aFiles,{"SQB",""})

//���������������������������������������������������������������Ŀ
//� Formatar os parametros Ranger em expressao ADVPL SM0          �
//�����������������������������������������������������������������
//MakeAdvplExpr("ORGM020")
//cMV_Par01	:=mv_par01
//���������������������������������������������������������������Ŀ
//� Formatar os parametros Ranger em expressao SQL			      �
//�����������������������������������������������������������������
MakeSqlExpr("ORGM020")

//���������������������������������������������������������������Ŀ
//� Carrega todas as empresa no Array aEmp						  �
//�����������������������������������������������������������������
If lEmpProc	
	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
		For nX := 1 To Len(aRetSM0)
			If Alltrim(aRetSM0[nx][2]) $ MV_PAR01
				aadd(aEmp,{aRetSM0[nx][1],aRetSM0[nx][2],aRetSM0[nx][7]})
			EndIf
		Next
	Else
		SM0->(dbGoTop())
		Do While !SM0->(Eof())
			If Alltrim(SM0->M0_CODFIL) $ MV_PAR01
				aadd(aEmp,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL})
			EndIf
			SM0->(dbSkip())
		EndDo
	EndIf
Else
	aadd(aEmp,{SM0->M0_CODIGO,FWCodFil(),SM0->M0_FILIAL})
EndIf	

//���������������������������������������������������������������Ŀ
//� Processar cargas dos departamentos das empresas				  �
//�����������������������������������������������������������������
cTimeIni	:= Time()
dMsDate		:= MsDate()
nLoops		:=Len(aEmp)
BarGauge1Set( nLoops )
For nCountTime:=1 to nLoops
	//�������������������������������������������������������������������Ŀ
	//� Abrir tabelas da respectiva empresa								  �
	//���������������������������������������������������������������������
    If cEmpAnt<>aEmp[nCountTime,1]
		cEmpAnt		:=aEmp[nCountTime,1]
		OrgxOpenFile(aFiles,aEmp[nCountTime,1])

		nPosAlias 	:= Ascan(aFiles,{|x| x[1] == "SQB"})
		cModoSQB		:=aFiles[nPosAlias,2]

		nPosAlias 	:= Ascan(aFiles,{|x| x[1] == "CTT"})
		cModoCTT	:=aFiles[nPosAlias,2]
		lProc		:=.F.
	EndIf	

    If lEmpProc
		//�������������������������������������������������������������������Ŀ
		//� Calculo do tempo de processamento + incremento da regua IncPrcG1()�
		//���������������������������������������������������������������������
		cMsg1:=STR0004+" - "+aEmp[nCountTime,1]+" "+aEmp[nCountTime,3]   //"Processando empresa"
		IncPrcG1Time(	cMsg1				,;	//01 -> Inicio da Mensagem
						nLoops		 		,;	//02 -> Numero de Registros a Serem Processados
						cTimeIni			,;	//03 -> Tempo Inicial
						.T.					,;	//04 -> Defina se eh um processo unico ou nao ( DEFAULT .T. )
						NIL					,;	//05 -> Contador de Processos
						1			 		,;	//06 -> Percentual para Incremento
						NIL					,;	//07 -> Se Deve Incrementar a Barra ou Apenas Atualizar a Mensagem
						NIL					 ;	//08 -> Se Forca a Atualizacao das Mensagens
						)

	EndIf
	//���������������������������������������������������������������������������Ŀ
	//� Quando as duas tabelas forem compatilhada nao precisa processar as filiais�
	//�����������������������������������������������������������������������������
	If (cFilSQB == cFilCTT) .AND. lProc
		Loop
	EndIf	
	//���������������������������������������������������������������Ŀ
	//� Selecao e gravacao dos centro de custo no departamento		  �
	//�����������������������������������������������������������������
	OrgM20PrcFil(	aEmp[nCountTime,1]	,;   	//Empresa
			  		aEmp[nCountTime,2]	,;		//Filial
					mv_par01			,;		//Filtro Filial
					mv_par02			,;		//Filtro Cento de Custo
					nCountTime			,;		//Sequencia de processamento
					lEmpProc			)		//Tipo do processamento .T. - Todas as empresas, .F. - Unica empresa
	lProc:=.T.			
Next nCountTime
//���������������������������������������������������������������Ŀ
//� Restauranto o ambiente original								  �
//�����������������������������������������������������������������
If cEmpBack<>cEmpAnt.OR.cFilBack<>cFilAnt
	cEmpAnt:=cEmpBack
	cFilAnt:=cFilBack
	OrgxOpenFile(aFiles,cEmpBack)
EndIf
//���������������������������������������������������������������Ŀ
//� Processar resultado da query								  �
//�����������������������������������������������������������������
MsgInfo(OemToAnsi(STR0005))		//Fim do Processamento
Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �OrgM20PrcFil  � Autor �Marcos Alves       � Data �11/09/07  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processas a caga das filias  							  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/ 
Function OrgM20PrcFil(  cProcEmp	,;   	//Empresa
						cFilProc	,;		//Filial a ser processada
						cParFilial	,;		//Filtro Filial
						cParCC		,;		//Filtro Cento de Custo
						nCountTime	,;		//Sequencia de processamento
						lEmpProc)			//Tipo do processamento .T. - Todas as empresas, .F. - Unica empresa

	Local cAliasTMP		:= "CTTTMP"  										//Alias do result set da query
	Local nOrdSQB		:=	RetOrdem( "SQB" ,"QB_FILIAL+QB_CC+QB_DEPTO")	//Ordem da Tabela SQB
	Local nOrdCTT		:=	RetOrdem( "CTT" ,CTT->(IndexKey()))			//Ordem da tebale S
	Local nRegTMP		:=0													//Numero de registro do ResultSet
	Local cTimeIni		:=""												//Hora inicial do processamento
	Local cMsg2			:=STR0006+cFilProc									//Mensagem da tela Baug - #"Processando centros de custos - Filial "
	Local cWhere		:="" 
	
	cWhere	:= " CTT.CTT_CLASSE = '2'"
	cWhere	+= " AND CTT.D_E_L_E_T_ = ' '"
	cWhere	+= IIF(Empty(cParFilial), "", " AND " + AllTrim(cParFilial))
	cWhere	+= IIF(Empty(cParCC) , "", " AND " + AllTrim(cParCC))
	cWhere	:= '%' + cWhere	+ '%'

	
	dbSelectArea("CTT")
	dbSetorder(1)
	//���������������������������������������������������������������������Ŀ
	//�  Query para retornar o total de registros a serem processados.		�
	//�����������������������������������������������������������������������		    
	BEGINSQL ALIAS cAliasTMP
		SELECT 
			COUNT(*) AS RECORDNUM
		FROM  
			%table:CTT% CTT 
		WHERE 
			%exp:cWhere%
	ENDSQL
	
	nRegTMP:=(cAliasTMP)->(RECORDNUM)
	(cAliasTMP)->(DbCloseArea())
	
	
	
	//���������������������������������������������������������������������Ŀ
	//�  Query para retornar os dados a serem processados.					�
	//�����������������������������������������������������������������������		    
	BEGINSQL ALIAS cAliasTMP
		SELECT 
			CTT.CTT_FILIAL,
			CTT.CTT_CUSTO, 
			CTT.CTT_DESC01
		FROM  
			%table:CTT% CTT 
		WHERE 
			%exp:cWhere%
		ORDER BY 
			%Order:CTT,1%
	ENDSQL
	
	//���������������������������������������������������������������������������������Ŀ
	//� Caracteritiscas operacionais para Depuracao:									�
	//� aRet:=GetLastQuery()															�
	//� aRet[1] cAlias - Alias usado para abrir o Cursor.								�
	//� aRet[2] cQuery - Query executada.												�
	//� aRet[3] aCampos - Array de campos com crit�rio de convers�o especificados.		�
	//� aRet[4] lNoParser - Caso .T., n�o foi utilizada ChangeQuery() na String original�
	//� aRet[5] nTimeSpend - Tempo, em segundos, utilizado para a abertura do Cursor	�
	//�����������������������������������������������������������������������������������
	//�����������������������������������������������������������������������������Ŀ
	//� Processamento do Result Set				   									�
	//�������������������������������������������������������������������������������
	cTimeIni	:=Time()			// Tempo inicial da calculo do tempo de processamento
	dMsDate		:=MsDate()			// Data do inicio do processamento
	//�����������������������������������������������������������������������������Ŀ
	//� Seta o totalizador da Gauge 2			   									�
	//�������������������������������������������������������������������������������
	If lEmpProc  //Se processa todas as empresa usa 2 Gauge
		BarGauge2Set( nRegTMP )
	Else	
		BarGauge1Set( nRegTMP )
	EndIf
	
	dbSelectArea("SQB")
	dbSetorder(nOrdSQB) //QB_FILIAL+QB_CC+QB_DEPTO
	While !(cAliasTMP)->(Eof())    
		If lEmpProc  //Se processa todas as empresa usa 2 Gauge
			IncPrcG2Time(		cMsg2			,;	//01 -> Inicio da Mensagem
								nRegTMP			,;	//02 -> Numero de Registros a Serem Processados
								cTimeIni		,;	//03 -> Tempo Inicial
								.T.				,;	//04 -> Defina se eh um processo unico ou nao ( DEFAULT .T. )
								nCountTime		,;	//05 -> Contador de Processos
								1			 	,;	//06 -> Percentual para Incremento
								NIL				,;	//07 -> Se Deve Incrementar a Barra ou Apenas Atualizar a Mensagem
								NIL				 ;	//08 -> Se Forca a Atualizacao das Mensagens
							)
		Else
			IncPrcG1Time(		cMsg2			,;	//01 -> Inicio da Mensagem
								nRegTMP			,;	//02 -> Numero de Registros a Serem Processados
								cTimeIni		,;	//03 -> Tempo Inicial
								.T.				,;	//04 -> Defina se eh um processo unico ou nao ( DEFAULT .T. )
								nCountTime		,;	//05 -> Contador de Processos
								1			 	,;	//06 -> Percentual para Incremento
								NIL				,;	//07 -> Se Deve Incrementar a Barra ou Apenas Atualizar a Mensagem
								NIL				 ;	//08 -> Se Forca a Atualizacao das Mensagens
							)
	
		EndIf
		//���������������������������������������������������������������������Ŀ
		//� Se ja estiver cadastrado atualiza, senao inclui						�
		//�����������������������������������������������������������������������
		lLock:=SQB->(dbSeek(cFilSQB + (cAliasTMP)->CTT_CUSTO , .F. ) )
		SQB->(RecLock("SQB",!lLock))
	    If !lLock 
			SQB->(FieldPut(FieldPos("QB_FILIAL"), cFilSQB) ) 										//Grava a filial da empresa aberta
			SQB->(FieldPut(FieldPos("QB_DEPTO")	, &(GetSx3Cache( "QB_DEPTO" , "X3_RELACAO" ))) ) 	//Pegar a fun��o do dicionario - SX8Num("SQB","QB_DEPTO")
		EndIf

		SQB->(FieldPut(FieldPos("QB_DESCRIC")	, (cAliasTMP)->CTT_DESC01))
		SQB->(FieldPut(FieldPos("QB_CC")		, (cAliasTMP)->CTT_CUSTO))
		SQB->( MsUnLock() )
		ConfirmSX8()
		(cAliasTMP)->(DbSkip())
	End
                                                    
	                                               
	//�����������������������������������������������������������������Ŀ
	//�  Fechar o arquivo TMP da Query.									�
	//�������������������������������������������������������������������		
	If Select(cAliasTMP) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf  
Return NIL
