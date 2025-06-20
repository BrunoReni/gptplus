#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Classe    �PersistSLARegister�Autor: Vendas Clientes     �Data:08/01/08���
�������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata contemplando as funcionalidades comuns uti- ���
���          �lizadas no acesso ao banco de dados.                        ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class PersistSLARegister From Persist

Method save(obj)
Method delete(obj)
Method UpdateDBFields(obj,lUpdate)

EndClass


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �save      �Autor  �Vendas Clientes     � Data �  18/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Salva um registro de SLA (SK5)                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method save(obj) Class PersistSLARegister
Local lRet	 := .F.		//Retorno da funcao   

BEGIN TRANSACTION 
	DbSelectArea("SK5")
	DbSetOrder(1) 
	If Empty(obj:registerID)
		//Insere SK5
		RecLock("SK5",.T.)
		obj:item := "000001"
		Self:UpdateDBFields(obj, .F.)
		SK5->K5_CODIGO := TkNumero("SK5", "K5_CODIGO")	
		MsUnlock()
		ConfirmSX8()
		obj:registerID := SK5->K5_CODIGO 
		lRet := .T. 
	Else
		//Atualiza SK5  
		If DbSeek(xFilial("SK5") + obj:registerID + obj:item)
			RecLock("SK5",.F.)       
			Self:UpdateDBFields(obj, .T.)
		Else
			//Inclui novo item no SK5
			RecLock("SK5",.T.)
			SK5->K5_CODIGO := obj:registerID
			Self:UpdateDBFields(obj, .F.)
		EndIf
		MsUnlock()                        
		lRet := .T. 
	EndIf                                  
	DbCommit()
END TRANSACTION    

Return lRet                      


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �delete    �Autor  �Vendas Clientes     � Data �  18/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Exclui o registro de SLA (SK5)                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method delete(obj) Class PersistSLARegister
Local lRet := .F.		//Indica retorno da funcao

BEGIN TRANSACTION

	DbSelectArea("SK5")
	DbSetOrder(1) //K5_FILIAL+K5_CODIGO+K5_ITEM
	If DbSeek(xFilial("SK5") + obj:registerID + obj:item)
		Reclock("SK5",.F.,.T.)
		DbDelete()
		MsUnlock()		   
		lRet := .T.
	EndIf
	
END TRANSACTION
Return lRet               


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �UpdateDBFields�Autor  �Vendas Clientes � Data �  18/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza os campos da tabela.                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method UpdateDBFields(obj,lUpdate) Class PersistSLARegister
         
REPLACE SK5->K5_FILIAL	WITH xFilial("SK5")
REPLACE SK5->K5_ITEM	WITH obj:item
REPLACE SK5->K5_CHAVE	WITH obj:keyInfo
REPLACE SK5->K5_OBS		WITH obj:details
REPLACE SK5->K5_DATA	WITH obj:createdDate
REPLACE SK5->K5_HORA 	WITH obj:createdHour
REPLACE SK5->K5_DTEXPIR	WITH obj:dateToExpire
REPLACE SK5->K5_HREXPIR	WITH obj:hourToExpire
If !Empty(obj:finishedDate)
	//Campos que indicam encerramento de SLA
	REPLACE SK5->K5_DTENCER	WITH obj:finishedDate
	REPLACE SK5->K5_HRENCER	WITH Time()
EndIf
If TK510NewFields()
	REPLACE SK5->K5_SEVE	WITH AllTrim(Str(obj:severityCode))
Else
	REPLACE SK5->K5_SEVERID	WITH obj:severityCode
EndIf
REPLACE SK5->K5_CODSLA 	WITH obj:SlaFound
REPLACE SK5->K5_CODRESP WITH obj:SlaResponsible
REPLACE SK5->K5_STATUS	WITH obj:StatusRegister
REPLACE SK5->K5_CODBLK 	WITH obj:cbWhenDelayed
If lUpdate
	REPLACE SK5->K5_DTATUA	WITH If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
	REPLACE SK5->K5_HRATUA	WITH Time()
EndIf

If !Empty(obj:OldRegister)
	REPLACE SK5->K5_CODANT	WITH obj:OldRegister
EndIf
REPLACE SK5->K5_PAUSED WITH obj:Paused
REPLACE SK5->K5_PAUSEDT WITH obj:PausedTime

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_TMKA530H     �Autor  �Vendas Clientes � Data �  08/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION _TMKA530H()
RETURN NIL
