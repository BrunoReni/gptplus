#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TMKA530.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SLAManager�Autor  �Vendas Clientes     � Data �  07/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza operacoes de gerenciamento de multiplos SLAs que    ���
���          �atendam a um criterio de busca                              ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class SLAManager	
Method new() Constructor
Method create()
Method load(oParam)
Method getHistory(register)
Method updSLARegister(register,cNextResponsible)
Method notify(oSLARegister,cNextResponsible)
Method RetFunName(cCodeBlock)

EndClass


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �New          �Autor  � Vendas Clientes � Data �  19/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe SLAManager                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class SLAManager

Return Self


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �create       �Autor  � Vendas Clientes � Data �  19/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que cria e retorna um objeto do tipo SLARegister     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method create() Class SLAManager
Local oSLARegister	:= SLARegister():New()

Return oSLARegister


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �load         �Autor  � Vendas Clientes � Data �  19/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carregar uma lista de registros de SLA que atendam a um     ���
���          �determinado criterio de busca                               ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method load(oParam) Class SLAManager
Local aSLARegister	:= {}					//Array de objetos SLARegister
Local cAlias 		:= "SK5"				//Alias temporario da query
Local lNotifyAll	:= SuperGetMV("MV_SLASEND",,.F.)	//Considera registros de SLA ja notificados
Local cWhere 		:= "% %"							//Condicao a ser adicionada na query
Local lDelayed 		:= .T.					//Indica se o registro de SLA esta atrasado

If !lNotifyAll 
	//Nao considerar os usuarios ja notificados 
	cWhere := "% AND SK5.K5_STATUS <> '1' %"
EndIf

//���������������������������������������Ŀ
//� Efetua a busca conforme os parametros �
//�����������������������������������������
cAlias 	:= GetNextAlias()
BeginSQL alias cAlias
	
	SELECT 	K5_CODIGO,	K5_DATA,	K5_DTEXPIR,		K5_HREXPIR,		K5_STATUS, 
			K5_ITEM
	FROM	%table:SK5% SK5
	WHERE	SK5.K5_FILIAL = %xFilial:SK5% AND 
			SK5.%NOTDEL% 	AND
			SK5.K5_DATA >= %EXP:DtoS(oParam:createdDateBegin)% AND
			SK5.K5_DATA <= %EXP:DtoS(oParam:createdDateEnd)% AND
			SK5.K5_DTEXPIR >= %EXP:DtoS(oParam:dateToExpireBegin)% AND
			SK5.K5_DTEXPIR <= %EXP:DtoS(oParam:dateToExpireEnd)% AND
			SK5.K5_STATUS <> '2'
			%exp:cWhere% 
			ORDER BY SK5.K5_ITEM
EndSql

While (cAlias)->(!Eof())

	lDelayed := .T.

	If (cAlias)->K5_DTEXPIR == DTOS(oParam:dateToExpireBegin)
		//Verifica criterio por hora inicial 
		If (cAlias)->K5_HREXPIR < oParam:hourToExpireBegin
			lDelayed := .F.
		EndIf
		
	ElseIf (cAlias)->K5_DTEXPIR == DTOS(oParam:dateToExpireEnd)
		//Verifica criterio por hora final 
		If (cAlias)->K5_HREXPIR > oParam:hourToExpireEnd
			lDelayed := .F.	
		EndIf
		
	EndIf

	//�����������������������������������������������������������������������������������Ŀ
	//� Armazena no array os registros de SLA encontrados conforme os parametros enviados �
	//�������������������������������������������������������������������������������������
	If lDelayed  
		//������������������������������������������Ŀ
		//� Atualiza status do registro de SLA atual �
		//��������������������������������������������
		DbSelectArea("SK5")
		DbSetOrder(1) 
		If DbSeek(xFilial("SK5") + (cAlias)->K5_CODIGO + (cAlias)->K5_ITEM)
			RecLock("SK5",.F.)
			REPLACE SK5->K5_DTATUA	WITH If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
			REPLACE SK5->K5_HRATUA	WITH Time()
			REPLACE SK5->K5_STATUS 	WITH "1"	//Notificado
			MsUnLock()
		EndIf	
		AAdd(aSLARegister, {(cAlias)->K5_CODIGO, (cAlias)->K5_ITEM})
	EndIf

	(cAlias)->( DbSkip() )
End 


DbSelectArea(cAlias)
DbCloseArea()

Return aSLARegister


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �getHistory   �Autor  � Vendas Clientes � Data �  19/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carregar o historico de um SLA, com informacoes das         ���
���          �ocorrencias envolvidas com o SLA                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method getHistory(register) Class SLAManager
Local aSLARegSteps	:= {}             		//Array de objetos SLARegisterSteps
Local oSLARegSteps	:= NIL					//Objeto do tipo SLARegisterSteps
Local cAlias 		:= "SK5"				//Alias temporario da query
Local aStru			:= SK5->(dbStruct())	//Estrutura de campos do arquivo SK5
Local nStru			:= 0

//���������������������������������������Ŀ
//� Efetua a busca conforme os parametros �
//�����������������������������������������
cAlias 	:= GetNextAlias()
If TK510NewFields()
	BeginSQL alias cAlias
		
		SELECT 	K5_CODIGO,		K5_ITEM,		K5_CHAVE, 		K5_STATUS,	
				K5_DATA,		K5_HORA,		K5_DTEXPIR,		K5_HREXPIR,
				K5_DTENCER,		K5_SEVE,		K5_CODSLA,		K5_CODRESP
	
		FROM	%table:SK5% SK5
		WHERE	SK5.K5_FILIAL = %xFilial:SK5% AND 
				SK5.%NOTDEL% 	AND
				SK5.K5_CODIGO = %EXP:register:registerID%

	EndSql
Else
	BeginSQL alias cAlias
	
		SELECT 	K5_CODIGO,		K5_ITEM,		K5_CHAVE, 		K5_STATUS,	
				K5_DATA,		K5_HORA,		K5_DTEXPIR,		K5_HREXPIR,
				K5_DTENCER,		K5_SEVERID,		K5_CODSLA,		K5_CODRESP
	
		FROM	%table:SK5% SK5
		WHERE	SK5.K5_FILIAL = %xFilial:SK5% AND 
				SK5.%NOTDEL% 	AND
				SK5.K5_CODIGO = %EXP:register:registerID%

	EndSql	
EndIf

For nStru := 1 To Len(aStru)
	If aStru[nStru,2] <> "C" .AND. aStru[nStru,2] <> "M"
		TcSetField(cAlias,aStru[nStru,1],aStru[nStru,2],aStru[nStru,3],aStru[nStru,4])
	EndIf
Next nStru
	
While (cAlias)->(!Eof())
	//���������������������������������������������������������Ŀ
	//� Cria um objeto do tipo SLARegisterSteps e carrega dados �
	//� de historico dos registros de SLA                       �
	//�����������������������������������������������������������
	oSLARegSteps	:= SLARegisterSteps():New()
	oSLARegSteps:updatedDate	:= (cAlias)->K5_DTATUA
	oSLARegSteps:userNotified	:= (cAlias)->K5_CODRESP	
	
	If (cAlias)->K5_DTEXPIR < If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
		oSLARegSteps:delayed := .T.
	ElseIf (cAlias)->K5_DTEXPIR == If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
		If (cAlias)->K5_HREXPIR <= Time()
			oSLARegSteps:delayed := .T.	
		Else
			oSLARegSteps:delayed := .F.	
		EndIf
	Else
		oSLARegSteps:delayed := .F.
	EndIf
	
	AAdd(aSLARegSteps, oSLARegSteps)
	(cAlias)->( DbSkip() )	
End

DbSelectArea(cAlias)
DbCloseArea()

Return aSLARegSteps


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �updSLARegiste�Autor  � Vendas Clientes � Data �  25/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualizar registro de SLA, incluindo um novo item para o    ���
���          �mesmo apos a notificacao do responsavel                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method updSLARegister(oSLARegister,cNextResponsible) Class SLAManager
Local lRet		:= .T.								//Retorno da funcao
Local cNewItem	:= Soma1(oSLARegister:item) 		//Cod. do novo item a ser gerado
Local dDataExpir:= oSLARegister:dateToExpire		//Data p/ expirar o reg. de SLA
Local cHoraExpir:= oSLARegister:hourToExpire		//Hora p/ expirar o reg. de SLA

//������������������������������������������Ŀ
//� Atualiza status do registro de SLA atual �
//��������������������������������������������
DbSelectArea("SK5")
DbSetOrder(1) 
If DbSeek(xFilial("SK5") + oSLARegister:registerID + oSLARegister:item)
	RecLock("SK5",.F.)
	REPLACE SK5->K5_DTATUA	WITH If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
	REPLACE SK5->K5_HRATUA	WITH Time()
	REPLACE SK5->K5_STATUS 	WITH "1"	//Notificado
	MsUnLock()
EndIf

//������������������������������Ŀ
//� Localiza a severidade do SLA �
//��������������������������������
DbSelectArea("SK9")
DbSetOrder(1) 
If DbSeek(xFilial("SK9") + Alltrim(Str(oSLARegister:severityCode)) + oSLARegister:SlaFound)
	//�������������������������������������������������������������������������������Ŀ
	//� Chama a funcao que calcula data e hora p/ a proxima notificacao do SLA		  |
	//���������������������������������������������������������������������������������
	nSomaHs := SK9->K9_HRPSEXP		//Nr. de horas p/ notificar apos expirar SLA
	SomaDiaHor(@dDataExpir, @cHoraExpir, nSomaHs)

	//������������������������������������������������������������Ŀ
	//� Verifica se deve considerar somente os dias uteis 		   �
	//��������������������������������������������������������������
	DbSelectArea("SK6")
	DbSetOrder(1) 
	If DbSeek(xFilial("SK6") + oSLARegister:SlaFound) .AND. SK6->K6_DSUTEIS == '1'
		dDataExpir := DataValida(dDataExpir) 
	EndIf	 
	
	//�������������������������������������������������������������������������������Ŀ
	//� Inclui novo item p/ o registro de SLA e atualiza data/hora para notificar SLA �
	//���������������������������������������������������������������������������������	
	oSLARegister:item 			:= cNewItem
	oSLARegister:dateToExpire	:= dDataExpir
	oSLARegister:hourToExpire	:= cHoraExpir
	oSLARegister:SlaResponsible	:= cNextResponsible
	oSLARegister:StatusRegister	:= "0"
	
	//�����������������������Ŀ
	//� Salva o novo registro �
	//�������������������������
	oSLARegister:save()
	
Else
	ConOut("Severidade " + Str(oSLARegister:severityCode) + " nao encontrada p/ o SLA " + oSLARegister:SlaFound)
	lRet := .F.
EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �notify	   �Autor  � Vendas Clientes � Data �  25/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Envia notificacao de SLA atrasado ao responsavel            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method notify(oSLARegister,cNextResponsible) Class SLAManager
Local oSLAResponsible 	:= SLAResponsible():New()				//Obj. SLAResponsible
Local oWFTemplate		:= Nil									//Obj. WFTemplate
Local oWFInfo 			:= Nil									//Obj. WFInfo
Local lRet 				:= .F.                              	//Retorno da funcao
Local cCodUser			:= ""									//Cod. interno do usuario
Local cCodTemplate		:= ""									//Cod. do modelo de WF
Local aWFs				:= {}
Local nCount			:= 0

DbSelectArea("SK6")
DbSetOrder(1)
If dbSeek(xFilial("SK6")+oSLARegister:SlaFound)
	cCodTemplate := SK6->K6_MODWF
	//��������������������������������������������Ŀ
	//� Usar o template de WF p/ enviar notificacao�
	//����������������������������������������������
	oWFTemplate := WFTemplate():New()
	lRet := oWFTemplate:load( cCodTemplate )
EndIf    

If lRet
	//������������������������������������Ŀ
	//�Posiciona no item do registro de SLA�
	//��������������������������������������
	DbSelectArea("SK5")
	DbSetOrder(1) //K5_FILIAL+K5_CODIGO+K5_ITEM
	DbSeek(xFilial("SK5")+oSLARegister:registerID+oSLARegister:item)

	//���������������������������������Ŀ
	//� Carrega os dados do responsavel �
	//�����������������������������������
	oSLAResponsible:load( cNextResponsible )
	oWFTemplate:cbTo := "'" + oSLAResponsible:email + "'"
	cCodUser := oSLAResponsible:codProtheusUser
	
	//��������������������������������������������������������������Ŀ
	//� Prepara o objeto p/ envio do Workflow baseado no Template WF �
	//����������������������������������������������������������������
	aWFs := oWFTemplate:buildWF(cCodUser, .T.)
	
	If ValType(aWFs) != "A"
		aWFs := { aWFs }
	EndIf
	
	For nCount := 1 To Len( aWFs )
		oWFInfo := aWFs[nCount]
		oWFInfo:Header:addField(STR0001, oSLARegister:registerID) //"Registro de SLA:"
		oWFInfo:Header:addField(STR0002, oSLARegister:item) //"Item:"
		//oWFInfo:Header:addField('Severidade:', oSLARegister:severityCode)
		oWFInfo:Header:addField(STR0003, oSLARegister:dateToExpire) //"Data que expirou:"
		oWFInfo:Header:addField(STR0004, oSLARegister:hourToExpire)	 //"Hora que expirou:"
		oWFInfo:Header:addField(STR0005, oSLARegister:SlaResponsible + ' - ' + Posicione("SK8", 1, xFilial("SK8")+oSLARegister:SlaResponsible, 'K8_NOME') ) //"Respons�vel:"
	Next
	
	//����������������������������������������������Ŀ
	//� Executa os processos de envio de Workflow    �
	//������������������������������������������������	
	If Len(aWFs) > 0
		oWFTemplate:fillFields(aWFs[1], cCodUser, aWFs)                
	EndIf
	
	For nCount := 1 To Len( aWFs )
		aWFs[nCount]:start()
		aWFs[nCount]:save()
	Next
	
	ConOut("Responsavel notificado")
Else
	ConOut("Nao foi possivel carregar o Modelo de Workflow: " + cCodTemplate) 
EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �TK530JOBSLA   �Autor  �Vendas Clientes � Data �  21/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao responsavel por disparar o JOB de controle de SLAs   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                   
Main Function TK530JOBSLA()

StartJob("TkJobSLA",GetEnvServer(),.F.)

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �TK530JOBSLA   �Autor  �Vendas Clientes � Data �  21/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao responsavel por disparar o JOB de controle de SLAs   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/   
Main Function TkJobSLA()
Local oManager								//Obj. SLAManager
Local oParam								//Obj. SLALoadParam
Local oSLARegister							//Obj. SLARegister
Local aSLARegister		:= {}				//Array com os registros de SLA
Local cNextResponsible	:= ""				//Proximo responsavel pelo SLA
Local nI 				:= 0				//Usado em lacos For...Next
Local cJobName			:=	getWebJob()		//Nome do Job (Working Thread) em execucao
Local cCodEmp			:=	""				//Codigo da empresa p/ preparar ambiente
Local cCodFil			:=	""				//Codigo da filial p/ preparar ambiente
Local cFuncName			:= ""				//Nome da funcao a executar
Local lTK530SLA 		:= ExistBlock("TK530SLA")		//Indica se existe o P.E. TK530SLA

//������������������������������������Ŀ
//� Iniciando o ambiente para execucao �
//��������������������������������������
While Right(cJobName,1) == "_"
	cJobName := Substr(cJobName, 1, rat("_", cJobName)-1)
Enddo
cCodEmp := GetPvProfString(cJobName,"EMPRESA","01",GetAdv97())
cCodFil := GetPvProfString(cJobName,"FILIAL","01",GetAdv97())

ConOut(Repl("-", 80))
ConOut("TkJobSLA(): "+"Starting environment - " + cCodEmp + "/" + cCodFil)
ConOut(Repl("-",80))
RpcSetType ( 3 )

PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil MODULO "TMK"

//������������������������������Ŀ
//� Preenche parametros de busca �
//��������������������������������
oParam	:= SLALoadParam():New()
oParam:createdDateBegin		:= CTOD('01/01/1990')
oParam:createdDateEnd		:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
oParam:dateToExpireBegin	:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase ) - 365 
oParam:hourToExpireBegin	:= "00:00"
oParam:dateToExpireEnd		:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
oParam:hourToExpireEnd		:= Time()

//����������������������������������������������Ŀ
//� Carregar registros de SLA atrasados e ativos �
//������������������������������������������������
oManager:= SLAManager():New()
aSLARegister := oManager:load( oParam )	

For nI := 1 To Len(aSLARegister)
	//���������������������������������������������������������Ŀ
	//� Cria um objeto do tipo SLARegister e carrega seus dados �
	//�����������������������������������������������������������
	oSLARegister := oManager:create()
	oSLARegister:load( aSLARegister[nI][1], , aSLARegister[nI][2])

	//��������������������������������������Ŀ
	//� Encontra o proximo respons. pelo SLA �
	//����������������������������������������
	cNextResponsible := oSLARegister:getNextResponsible()

	//������������������������������������Ŀ
	//� Enviar notificacao de SLA atrasado �
	//��������������������������������������
    If !Empty(cNextResponsible)
	    oManager:notify(oSLARegister,cNextResponsible)

		//�����������������������������������������������������������Ŀ
		//� Atualiza o registro de SLA atual e cria um novo item para �
		//� acompanhamento do registro de SLA                         �
		//�������������������������������������������������������������
		If oManager:updSLARegister(oSLARegister,cNextResponsible)
			ConOut("Registro de SLA " + oSLARegister:registerID +" atualizado")
		Else 
			ConOut("Nao foi possivel atualizar o registro de SLA " + oSLARegister:registerID)
		EndIf
	    
		//����������������������������������������������������������������������Ŀ
		//� Ponto de Entrada p/ permitir integracoes c/ a aplicacao que usa  SLA �
		//������������������������������������������������������������������������
		If lTK530SLA 
			ExecBlock("TK530SLA", .F., .F., {oSLARegister, cNextResponsible} )
		EndIf
		
		//���������������������������������������������Ŀ
		//� Executa o codeblock de acao p/ SLA atrasado �
		//�����������������������������������������������
		cFuncName := oManager:RetFunName(oSLARegister:cbWhenDelayed) 
		If !Empty( cFuncName ) 
			If FindFunction(cFuncName)
				Eval(&("{|oSLARegister|" + cFuncName + "(oSLARegister)}"), oSLARegister)
			Else
				ConOut("Aviso, funcao nao encontrada no RPO: " + cFuncName)
			EndIf
		EndIf

	Else
		ConOut("Nao foi possivel notificar. O proximo responsavel nao foi encontrado, verificar cad. de responsaveis")
	EndIf
    
Next nI


//������������������������������������������������������������������������Ŀ
//� Finalizando o ambiente 				                                   �
//��������������������������������������������������������������������������
ConOut(Repl("-",80))
ConOut("TkJobSLA(): "+"Environment reseted")
ConOut(Repl("-",80))
RESET ENVIRONMENT	

Return .T.



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �RetFunName   �Autor  � Vendas Clientes � Data �  08/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o nome da funcao sem os parenteses                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method RetFunName(cCodeBlock) Class SLAManager
Local cFunName := AllTrim(cCodeBlock)
Local cPosBracket := At("(", cFunName)

If cPosBracket > 0 
	cFunName := SubStr(cFunName, 1, cPosBracket - 1)
EndIf

Return cFunName


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_TMKA530      �Autor  �Vendas Clientes � Data �  07/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                   
FUNCTION _TMKA530()
RETURN NIL
