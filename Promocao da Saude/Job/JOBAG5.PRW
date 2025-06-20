#INCLUDE "JOBAG5.ch"
#include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "TBICONN.CH"   

/*��������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Programa  � JOBAG5 	� Autor � Andreia Silva      � Data �  28/10/12  ���
������������������������������������������������������������������������͹��
���Desc.     � Atualiza a tabela de alertas quando o paciente faltar ao  ���
���          � evento em que estava inscrito - chamada do JOB     	 	 ���
������������������������������������������������������������������������͹��
���Uso       � SEGMENTO SAUDE		                                     ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������        
���������������������������������������������������������������������������*/
Function JOBAG5( aParams )

Local cJobName := GetWebJob()		//Nome do Job (Working Thread) em execucao
Local cCodEmp  := aParams[1]//GetPvProfString(cJobName,"EMPRESA","",GetAdv97())//99
Local cCodFil  := aParams[2]//GetPvProfString(cJobName,"FILIAL","",GetAdv97())//01

Default aParams  := {}

RPCSetType(3) //n�o consome licen�a. 
If len(aParams)>0
	PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil
Endif

// Trava para n�o executar o JOB se ja estiver em execucao

If !MayIUseCode( 'PLSJOBAG5' + cCodEmp )
	U_MsgConMon( STR0001 + cCodEmp + ' - Ja Esta Em Andamento' ,, .F. ) //"Job AG5 - Eventos" ### ' - Ja Esta Em Andamento'
	Return NIL
EndIf

//conout(STR0002+" - "+TIME()) //"Iniciou o JOB - Faltou ao Evento"

JobFaltEve()

//conout(STR0004) //"Terminou a atualiza��o da BOS - Tabela de Alerta para a Promo��o"

FreeUsedCode()

If len(aParams)>0
	//conout(STR0005) //" Job Processado com Sucesso"
	RESET ENVIRONMENT	
Endif

Return(Nil)   

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � JOBAG5    �Autor  �Microsiga          � Data �  11/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para alertar a promo�ao quando o paciente faltar no ���
���          � evento que estava inscrito.						          ���
�������������������������������������������������������������������������͹��
���Uso       � SEGMENTO SAUDE                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function JobFaltEve()
Local dData    := DTOS(dDataBase)
Local cSQL     := "" 
Local cResumo  := STR0006 //"N�o Compareceu ao Evento "
Local cTexto   := ""
Local cUsuario := "" 
Local cUser    := ""
Local cGrade   := ""
Local cPromo   := ""
Local dDatEve

cSQL := "SELECT "
cSQL += "	DISTINCT(AG5_EVENT), AG5_ENTID, AG5_GRADE, AG5_CODEN, BA1_MATVID, ACE_DATA, ACD_CODIGO, BOD_CODPRO, BOD_CODSIN "
cSQL += "	FROM "
cSQL += 		RetSQLName("AG5")
cSQL += "			INNER JOIN "+RetSQLName("BA1")+" ON "
cSQL += "				BA1_FILIAL = '"+xFilial("BA1")+"' AND "
If AllTrim(TCGetDB()) $  "MSSQL" 
	cSQL += "				BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU+BA1_TIPREG+BA1_DIGITO = AG5_CODEN OR "
	cSQL += "				BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO = AG5_CODEN AND "
Else

	cSQL += "				BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPUSU||BA1_TIPREG||BA1_DIGITO = AG5_CODEN OR "
	cSQL += "				BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO = AG5_CODEN AND "

Endif
cSQL += 				RetSQLName("BA1")+".D_E_L_E_T_ = ' ' "
cSQL += "			INNER JOIN "+RetSQLName("ACE")+" ON "
cSQL += "				ACE_FILIAL = '"+xFilial("ACE")+"' AND "
cSQL += "				ACE_CODIGO = AG5_EVENT AND "
cSQL += "				ACE_GRADE  = AG5_GRADE AND "
cSQL += "				ACE_DATA   < '"+dData+"' AND "
cSQL +=  				RetSQLName("ACE")+".D_E_L_E_T_ = ' ' "
cSQL += "			INNER JOIN "+RetSQLName("ACD")+" ON "
cSQL += "				ACD_FILIAL = '"+xFilial("ACD")+"' AND "
cSQL += "				ACD_CODIGO = ACE_CODIGO AND "
cSQL += 				RetSQLName("ACD")+".D_E_L_E_T_ = ' ' "
cSQL += "			INNER JOIN "+RetSQLName("BOM")+" ON " 
cSQL += "				BOM_FILIAL = '"+xFilial("BOM")+"' AND "
cSQL += "				BOM_VIDA = BA1_MATVID AND "
cSQL += 				RetSQLName("BOM")+".D_E_L_E_T_ = ' ' "	
cSQL += "			INNER JOIN "+RetSQLName("BOD")+" ON "	
cSQL += "			 	BOD_FILIAL = '"+xFilial("BOD")+"' AND "
cSQL += "			 	BOD_CODPRO = BOM_CODPRO AND "
cSQL += 				RetSQLName("BOD")+".D_E_L_E_T_ = ' ' 		
cSQL += "		WHERE "     
cSQL += "			AG5_PRESE = '2'   AND "
cSQL += "			AG5_ENTID = 'BA1' AND "
cSQL +=  			RetSQLName("AG5")+".D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)		
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"QRYAG5",.F.,.T.)   

TCSETFIELD("QRYAG5","ACE_DATA","D",17,2)

While !(QRYAG5->(EOF()))
	cCodPro  := QRYAG5->BOD_CODPRO  
	cUsuario := Posicione("BA1", 7, xFilial("BA1") + QRYAG5->BA1_MATVID, "BA1_NOMUSR")
	cTexto   := STR0008+QRYAG5->BA1_MATVID+" - "+AllTrim(cUsuario)+STR0009+cCodPro+; //"O paciente " ### ", particIpante do programa "
				 STR0010+QRYAG5->AG5_EVENT+STR0011  //", foi inscrito no Evento " ### " e n�o compareceu " 
	
	dbSelectArea("BOS")
	dbSetorder(4)//BOS_FILIAL, BOS_CODPRO, BOS_VIDA, BOS_CODEVE
	If !BOS->(MsSeek(xFilial("BOS")+cCodPro+QRYAG5->BA1_MATVID+QRYAG5->ACD_CODIGO+DTOS(QRYAG5->ACE_DATA)))
		dbSelectArea("BOJ")
		BOJ->(DbSetOrder(1))//BOJ_FILIAL, BOJ_CODSIN	
		If BOJ->(MsSeek(xFilial("BOJ")+QRYAG5->BOD_CODSIN))  
		
 			BOS->(RecLock("BOS",.T.))
			BOS->BOS_FILIAL	:= xFilial("BOS")
			BOS->BOS_NROSEQ	:= GETSXENUM('BOS','BOS_NROSEQ',, 1)
			BOS->BOS_RESUMO	:= cResumo  + QRYAG5->AG5_EVENT
			BOS->BOS_DATSIN := dDataBase
			BOS->BOS_HORAIN	:= Time()
			BOS->BOS_TEXTO	:= cTexto
			BOS->BOS_ACAO   := ""
			BOS->BOS_ORIGEM	:= FUNNAME()
			BOS->BOS_DESTIN	:= BOJ->BOJ_DESTIN
			BOS->BOS_CODSIN	:= BOJ->BOJ_CODSIN
			BOS->BOS_AUTOMA	:= '1'
			BOS->BOS_VIDA   := QRYAG5->BA1_MATVID
			BOS->BOS_STATUS := "0"
			BOS->BOS_CODPRO := QRYAG5->BOD_CODPRO     
			BOS->BOS_TPALER := '2'//EVENTO
			BOS->BOS_CODEVE := QRYAG5->ACD_CODIGO
			BOS->BOS_DATEVE := QRYAG5->ACE_DATA
			BOS->(MSUNLOCK())
		EndIf
  	EndIf
	QRYAG5->(dbSkip())
EndDo

QRYAG5->(DbCloseArea())
ConfirmSx8()						

Return