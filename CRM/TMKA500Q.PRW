#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Classe    �PersistTsTable�Autor  �Vendas CRM      � Data �  30/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Classe para persistencia de customizacoes dos campos do     ���
���          �teleatendimento                                             ���
�������������������������������������������������������������������������͹��
���Uso       �P10                                                         ���
�������������������������������������������������������������������������ͼ��
���17/07/2018 - Atualizado para compila��o no teste sist�mico.            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class PersistTsTable from Persist

Method customizeField()
Method save()   
Method delete()

End Class

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �save      �Autor  �Vendas CRM          � Data �  30/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Persiste informacoes na tabela ADQ                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �P10                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method save(oField,cId) Class PersistTsTable

Local aArea	:= GetArea()
Local lAchou:= .F.
	
DbSelectArea("ADQ")
DbSetOrder(1)
lAchou := DbSeek(xFilial("ADQ") + cId + oField:name)

RecLock("ADQ",!lAchou)
ADQ->ADQ_FILIAL	:= xFilial("ADQ")
ADQ->ADQ_ATEND	:= cID
ADQ->ADQ_CAMPO	:= oField:name
ADQ->ADQ_TITSPA := oField:titleSpa
ADQ->ADQ_TITENG := oField:titleEng
ADQ->ADQ_TITPOR := oField:titlePor
ADQ->ADQ_INIPAD := oField:defValue
ADQ->ADQ_USADO 	:= oField:use
ADQ->ADQ_OBRIGA	:= oField:required
MsUnLock()      

RestArea(aArea)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �delete    �Autor  �Vendas CRM          � Data �  30/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Remove informacoes na tabela ADQ                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �P10                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method delete(oField,cId) Class PersistTsTable

Local aArea	:= GetArea()

	
DbSelectArea("ADQ")
DbSetOrder(1)

If DbSeek(xFilial("ADQ") + cId + oField:name)
	RecLock("ADQ",.F.)
	DbDelete()
	MsUnLock()
EndIf

RestArea(aArea)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �customizeField�Autor�Vendas CRM        � Data �  27/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Aplica as customizacoes de um campo                         ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method customizeField(oField,cFieldName,cId) Class PersistTsTable

Local aArea			:= GetArea()

If !Empty(cId)

	ADQ->(DbSetOrder(1))

	If ADQ->(DbSeek(xFilial("ADQ")+cId+SX3->X3_CAMPO))

		//Titulo
		oField:titleSpa := AllTrim(ADQ->ADQ_TITSPA)
		oField:titleEng := AllTrim(ADQ->ADQ_TITENG)
		oField:titlePor := AllTrim(ADQ->ADQ_TITPOR)
		
		//Inicializador
		If !Empty(ADQ->ADQ_INIPAD)
			oField:defValue := AllTrim(ADQ->ADQ_INIPAD)
		EndIf

		//Propriedades
		oField:use 			:= ADQ->ADQ_USADO	//Uso
		oField:required 	:= ADQ->ADQ_OBRIGA	//Obrigatorio
		oField:Customized	:= .T.
		
	EndIf

EndIf

RestArea(aArea)

Return Nil