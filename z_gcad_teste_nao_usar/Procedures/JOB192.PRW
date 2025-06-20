#INCLUDE "PROTHEUS.CH"
#INCLUDE "JOB192.CH"
#DEFINE __TENTATIVAS 5
Static lDebug	:=	.F.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �JOB192    �Autor  �Microsiga           � Data �  01/06/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                					          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8 - Controladoria - CTB                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function JOB192( aParams )
Local lDoProc    := .F.
Local lManual    := aParams[1][1]
Local cEmpresa   := aParams[1][2]
Local cFilProc   := aParams[1][3]
Local cNomeJob   := aParams[1][4]
Local cArquivo   := aParams[1][5]
Local cArqLog    := aParams[1][6]
Local dDataIni   := aParams[1][7]
Local dDataFim   := aParams[1][8]
Local cTpSald    := aParams[1][9]
Local cMoeda     := aParams[1][10]
Local cMoedaEsp  := aParams[1][11]
Local lCusto     := aParams[1][12]
Local lItem      := aParams[1][13] 
Local lCLVL      := aParams[1][14]                             
Local nFKInUse   := aParams[1][15]
Local lDelFisico := aParams[1][16]
Local nIdJob     := aParams[1][17]
Local nQtdJobs   := aParams[1][18]
Local cUsuarioCTB:= aParams[1][19]
Local cMV_SOMA   := aParams[1][21]
Local nTimeOut   := 0
Local lProcNext	 :=	.T.
Local nREcAtu    := 0
Local nProxRec   := 0
Local cQuery     := ""

Private nTipoLog := aParams[1][20]

//BEGIN SEQUENCE

//��������������������������������������������������������������Ŀ
//� Se nao for manual abre as tabelas							 �
//����������������������������������������������������������������
If ! lManual
	RpcSetType( 3 )
	RpcSetEnv( cEmpresa, cFilProc,,,'CTB' )	
EndIf	                     
If IsThreadOn(Val(GetGlbValue(cNomeJob+"_ID")) )
	//��������������������������������������������������������������Ŀ
	//� STATUS 2 - Conexao efetuada com sucesso 					 �
	//����������������������������������������������������������������
	PutGlbValue( cNomeJob , "2" )
	CTB192Proc( nTipoLog,STR0001,TConout("JOB "+cNomeJob+STR0002),,cUserName)  //"MENSAGEM"," ja foi iniciado..."
	Return Nil
Endif	

nTimeOut := GetNewPar( 'MV_CTB192T' , 3000 )

If Select("TMPCTA")==0	
	dbUseArea(.T.,"TOPCONN","TMPCTA","TMPCTA", .T., .F. )
EndIf	

//cria um arquivo de controle para saber se o JOB esta no "ar"
//��������������������������������������������������������������Ŀ
//� STATUS 1 - Iniciando execucao do Job						 �
//����������������������������������������������������������������
PutGlbValue(cNomeJob, "1" )
cUserName	:=	cUsuarioCTB

//��������������������������������������������������������������Ŀ
//� STATUS 2 - Conexao efetuada com sucesso 					 �
//����������������������������������������������������������������
PutGlbValue( cNomeJob , "2" )
PutGlbValue( cNomeJob+"_ID" ,str(threadid(),10))
//��������������������������������������������������������������Ŀ
//� Iniciando o jobs                        					 �
//����������������������������������������������������������������
cHoraIni := Time()
If lDebug
	ConOut( Replicate( "-" , 65 ))
	ConOut( cNomeJob + STR0003 + DToC( Date() ) + " - " + cHoraIni )  //" - Inicio: "
	ConOut( Replicate( "-" , 65 ))
Endif
CTB192Proc( nTipoLog,STR0001,STR0004+cNomeJob,,cUserName) //"MENSAGEM",'Iniciado JOB :'

DbSelectArea( "CT1" )
DbSetOrder( 1 )
//��������������������������������������������������������������Ŀ
//� Setando a condi��o do filtro                   				  �
//����������������������������������������������������������������
cNextFil	:=	GetNextFil(cArquivo)
TConout("NEXT FIL/"+CNOMEJOB+CNEXTFIL)
cFilAnt	:=	cNextFil
cArquivo := Padr(cArquivo, Len(TMPCTA->ARQUIVO))

dbSelectArea("TMPCTA")
DbSetFilter( {|| &("(TMPCTA->SITUAC == '1' .Or. TMPCTA->SITUAC == '0') .And. '"+cFilAnt+"' == TMPCTA->FILPROC .And. TMPCTA->ARQUIVO =='"+cArquivo+"'") },"(TMPCTA->SITUAC == '1' .Or. TMPCTA->SITUAC == '0') .And. '"+cFilAnt+"' == TMPCTA->FILPROC .And. TMPCTA->ARQUIVO == '"+cArquivo+"'")

TMPCTA->( Dbgotop() )

CTB192Proc( nTipoLog,STR0001,TConout(STR0012+cFilAnt+"."),"JOB "+cNomeJob,cUserName)  //"MENSAGEM","Inicio processo filial "
nCont := 0                   

While !TMPCTA->(EOF()) .Or. lProcNext
	nREcAtu := 	TMPCTA->(RECNO())
	TMPCTA->(DbSkip())
	nProxRec := TMPCTA->(RECNO())
	TMPCTA->(DbGoto(nRecAtu))
	lProcNext	:=	.F.
	lDoProc := .F.
	dbSelectArea( "TMPCTA" )
	nCont++	
	lLocked	:=	.F.
	If !Eof()		
		If TMPCTA->(DBRLock(Recno()))
			lLocked	:=	.T.
			IF TMPCTA->SITUAC == '1' .Or. TMPCTA->SITUAC == '0'				
				If TMPCTA->VEZES <= __TENTATIVAS					
					If CT1->( DBSeek( xFilial('CT1') + TMPCTA->CONTA ) )						
						IF Ct1MLock({TMPCTA->CONTA})// tenta fazer o travamento pela conta
 							lDoProc := .T.
							CTB192Proc( nTipoLog,STR0001,TConout(STR0005+Alltrim(TMPCTA->CONTA)+"/"+cFilAnt+"."),"JOB "+cNomeJob,cUserName) //"MENSAGEM","Inicio processo conta "
						Else
							CTB192Proc( nTipoLog,STR0001,TConout(STR0006+Alltrim(TMPCTA->CONTA)+"/"+cFilAnt+STR0007),"JOB "+cNomeJob,cUserName)  //"MENSAGEM","Conta "," nao pode ser travada, continuando com a proxima..."
						Endif
					Else
						CTB192Proc( nTipoLog,STR0008,TConout(STR0009+Alltrim(TMPCTA->CONTA)+"/"+cFilAnt),"JOB "+cNomeJob,cUserName)  //"ALERTA","ATENCAO : Conta nao encontrada no cadastro de contas : "
						REPLACE TMPCTA->SITUAC  WITH "3"
					Endif
				Else
					CTB192Proc( nTipoLog,STR0008,Tconout(STR0006+Alltrim(TMPCTA->CONTA)+"/"+cFilAnt+STR0010),"JOB "+cNomeJob,cUserName)  //"ALERTA","Conta "," falhou o processo 5 vezes, analisando a proxima."
				Endif
			Endif
		ElseIf !Empty(TMPCTA->JOB)
			CTB192Proc( nTipoLog,STR0001,TConout(STR0006+Alltrim(TMPCTA->CONTA)+"/"+cFilAnt+STR0011),"JOB "+cNomeJob,cUserName) //"MENSAGEM","Conta "," em processamento."
		Endif
				
	    If lDoProc
			REPLACE TMPCTA->JOB	   WITH cNomeJob
			REPLACE TMPCTA->INICIO WITH Time()
			REPLACE TMPCTA->DATAINI WITH Date()
			REPLACE TMPCTA->SITUAC  WITH "0" //Processando
	
			// Chama a procedure
			lOK := ProcCTB020(lCusto, lItem, lClvl, cFilAnt, dDataIni, dDataFim, cMoedaEsp, cMoeda, cTpSald, nFkInUse, lDelFisico, TMPCTA->CONTA, nIdJob, cNomeJob, cMV_SOMA )
		      
			dbSelectArea( "TMPCTA" )
			If lOk
				CTB192Proc( nTipoLog,STR0001,Tconout( STR0013+Alltrim(TMPCTA->CONTA) +"/"+cFilAnt+"."),"JOB "+cNomeJob,cUserName)  //"MENSAGEM","Finalizada conta "
	
				REPLACE TMPCTA->FIM 	WITH Time()
				REPLACE TMPCTA->DURACAO WITH ElapTime(TMPCTA->INICIO, TMPCTA->FIM)
				REPLACE TMPCTA->SITUAC  WITH "2"
				
				// adiciona na tabela de log o registro processado
				dbSelectArea( "TMPCTA" )
			Else
				CTB192Proc( nTipoLog,STR0014,TConout( STR0015+ Alltrim(TMPCTA->CONTA)+"/"+cFilAnt+STR0016+Str(__TENTATIVAS-TMPCTA->VEZES+1)+ STR0017 ),"JOB "+cNomeJob,cUserName)  //"ERRO","Falha na Procedure para a conta ",". Serao feitas mais "," tentativas."
				REPLACE TMPCTA->SITUAC  WITH "1"
				REPLACE TMPCTA->VEZES WITH TMPCTA->VEZES + 1
				IF TMPCTA->VEZES > __TENTATIVAS
					// se tentou mais que 5 vezes preenche os campos com os dados do erro
					REPLACE TMPCTA->FIM 	WITH Time()
					REPLACE TMPCTA->DURACAO WITH ElapTime(TMPCTA->INICIO, TMPCTA->FIM)
					REPLACE TMPCTA->SITUAC  WITH "3"
				Endif
			Endif		
		Endif

		// Solta locks do JOB e do CT1
		If lLocked			
			TMPCTA->(DBRUnLock(Recno()))		
			CT1MUnlock()
		Endif
		FKCOMMIT()	
	Endif
	dbSelectArea( "TMPCTA" )
	TMPCTA->(DbGoto(nProxRec))
	If EOF()   
		// Bateu em EOF, mas houveram registros "pulados" na base ... 
		// ou em processamento por outro job, ou por mim mesmo
		CTB192Proc( nTipoLog,STR0001,TConout(STR0018),"JOB "+cNomeJob,cUserName)  //"MENSAGEM","Verificando pendencias..."
		Sleep(1000)
		cNextFil	:=	GetNextFil(cArquivo)
		TConout("NEXT FIL/"+CnOMEjob +CNEXTFIL)
		If !Empty(cNextFil)
			cFilAnt	:=	cNextFil
			dbSelectArea( "TMPCTA" )
			SET FILTER TO
			DbSetFilter( {|| &("(TMPCTA->SITUAC == '1' .Or. TMPCTA->SITUAC == '0') .And. '"+cFilAnt+"' == TMPCTA->FILPROC .And. TMPCTA->ARQUIVO =='"+cArquivo+"'") },"(TMPCTA->SITUAC == '1' .Or. TMPCTA->SITUAC == '0') .And. '"+cFilAnt+"' == TMPCTA->FILPROC .And. TMPCTA->ARQUIVO =='"+cArquivo+"'")
			Tconout("Filter : (TMPCTA->SITUAC == '1' .Or. TMPCTA->SITUAC == '0') .And. '"+cFilAnt+"' == TMPCTA->FILPROC .And. TMPCTA->ARQUIVO =='"+cArquivo+"'")
			lProcNext	:=	.T.
			CTB192Proc( nTipoLog,STR0001,TConout(STR0019+cNextFil+"."),"JOB "+cNomeJob,cUserName)  //"MENSAGEM","Inicio processo filial "
		Endif         
		TMPCTA->( DbGotop() )
		//Garante que entre no Loop novamente, mesmo estando em EOF para voltar a passar por aqui
	EndIf                                                               
EndDo
dbSelectArea( "TMPCTA" )
dbCloseArea()
CTB192Proc( nTipoLog,STR0001,TConout(STR0020),"JOB "+cNomeJob,cUserName)  //"MENSAGEM","Fim do processo. Sem pendencias."

//��������������������������������������������������������������Ŀ
//� Se nao for manual limpa o que foi carregado					 �
//����������������������������������������������������������������
CTB192Proc( nTipoLog,STR0001,STR0021+cNomeJob,"JOB "+cNomeJob,cUserName) //"MENSAGEM",'Finalizado  JOB'

If ! lManual
	RpcClearEnv()
EndIf	

//END SEQUENCE

//ErrorBlock( bErrBlock )

//��������������������������������������������������������������Ŀ
//�  STATUS 3 - Processamento finalizado com sucesso			 �
//����������������������������������������������������������������
PutGlbValue( cNomeJob, "3" )


cHoraFim := Time()
cDuracao := ElapTime( cHoraIni, cHoraFim )


Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ProcCTB020�Autor  �Microsiga           � Data �  01/06/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                					          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8 - Controladoria - CTB                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ProcCTB020(lCusto, lItem, lClvl, cFilExec, dDataIni, dDataFim, cMoedaEsp, cMoeda, cTpSald, nFkInUse, lDelFisico, cConta, nSomaProc, cNomeJob, cMV_SOMA )
Local lRet := .F.
Local aResult
Private cCTB165  := IIF(FindFunction("GetSPName"), GetSPName("CTB165","07"), "CTB165")
Default nSomaProc	:=	0  
// Verifica se a procedure esta compilada no banco de dados
///*ver ID !!!!!
If !ExistProc( cCTB165 , VerIDProc() )
  	CTB192Proc( nTipoLog,STR0014,Tconout(STR0022),"JOB "+cNomeJob,cUserName)  //"ERRO","Procedure CTB165 nao encontrada."
Else          
	aResult := TCSPEXEC( xProcedures(cCTB165),;
							Iif(lCusto,'1','0'),;
							Iif(lItem,'1','0'),;
							Iif(lClVl,'1','0'),;
							cFilExec,;
							Dtos(dDataIni),;
							Dtos(dDataFim),;
							cMoedaEsp,;
							cMoeda,;
							cTpSald,;
							If(nFKInUse > 0, '1' , '0' ),;
							If(lDelFisico, '1', '0'),;
							cConta,;
							cMV_SOMA)

	IF Len( aResult ) > 0 .And.  ( ValType( aResult[1] ) == "C" )
		lRet := aResult[1] == '1'
	Else
		lRet := .F.
		CTB192Proc( nTipoLog,STR0014,TConOut( STR0023 ),"JOB "+cNomeJob,cUserName)  //"ERRO","Erro no retorno da procedure."
	Endif
EndIf							

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �VerIDProc � Autor � Marcelo Pimentel      � Data �24.07.2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Identifica a sequencia de controle do fonte ADVPL com a     ���
���          �stored procedure, qualquer alteracao que envolva diretamente���
���          �a stored procedure a variavel sera incrementada.            ���
���          �Procedure CTB165                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/         
Static Function VerIDProc()
Return '010'
/*-------------------------------------------------------------------------
Funcao		  : TConout
Autor         : 
Data          : 30/07/2018
Uso           : Conout do Job
-------------------------------------------------------------------------*/
Static function TConout(cMsg)
cMsg	:="["+Str(ThreadId(),10)+"] "+cMsg
If lDebug
	Conout( cMsg)
Endif
PtInternal(1,cMsg)
Return cMsg
/*-------------------------------------------------------------------------
Funcao		  : GetNextFil
Autor         : 
Data          : 30/07/2018
Uso           : Retorna Filtro Filial
-------------------------------------------------------------------------*/
Static Function GetNextFil(cArquivo)
Local cQryCta	:=	""
Local cNextAlias	:=	GetNextAlias()
Local cNextFil		:=	""

cQryCta	:=	" SELECT MIN(FILPROC) FILIAL , COUNT(*) CONTA  FROM TMPCTA "
cQryCta	+=	"   WHERE SITUAC in ('0','1') "
cQryCta	+=	"   AND ARQUIVO = '"+cArquivo+"'"
cQryCta	+=	"   AND D_E_L_E_T_ =' ' "
cQryCta	+=	"   HAVING COUNT(*) > 0 "
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryCta), cNextAlias, .F., .T.)
If !Eof()
	cNextFil	:=	FILIAL
Endif
DbCloseArea()
Return cNextFil                                                              