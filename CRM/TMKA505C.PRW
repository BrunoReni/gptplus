#INCLUDE "PROTHEUS.CH"

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Programa  �PersistTSToolbarList�Autor  �Michel Mosca     � Data �  01/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     |Classe abstrata contemplando as funcionalidades comuns utilizadas  ��� 
���          �no acesso ao banco de dados.                                       ���
��������������������������������������������������������������������������������͹��
���Uso       � MP10                                                              ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������     
*/
Class PersistTSToolbarList From Persist

Method save(obj)   
Method delete(obj, oButton)
Method fillClass(obj)               
Method UpdateDBFields(obj)
EndClass                               

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �UpdateDBFields�Autor  �Michel W. Mosca � Data �  01/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza os campos da tabela.                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method UpdateDBFields(obj) Class PersistTSToolbarList 
Local nCount := 0
Local oBtn
Local lFound := .T. 

For nCount := 1 To Len(obj:aButtons)
	oBtn := obj:aButtons[nCount]
	DbSelectArea("SKJ")
	If Empty(oBtn:id)
		oBtn:id := GetSx8Num("SKJ", "KJ_CODIGO")
		RecLock("SKJ",.T.)		
	Else
		DbSetOrder(3) //KJ_FILIAL+KJ_CODTELE+KJ_CODIGO		
		lFound := DbSeek(xFilial("SKJ")+obj:id+oBtn:id)
		If lFound
			RecLock("SKJ",.F.)	
		EndIf
	EndIf 
	If lFound                        
		REPLACE SKJ->KJ_FILIAL	WITH xFilial("SKJ")        
		REPLACE SKJ->KJ_CODTELE	WITH obj:id
		REPLACE SKJ->KJ_CODIGO 	WITH oBtn:id
		REPLACE SKJ->KJ_NOME 	WITH oBtn:name
		REPLACE SKJ->KJ_IMAGEM 	WITH oBtn:imageName
		REPLACE SKJ->KJ_CDBLOCK	WITH oBtn:codeBlock
		REPLACE SKJ->KJ_AJUDA	WITH oBtn:toolTipText
		REPLACE SKJ->KJ_POSICAO	WITH AllTrim(oBtn:pos) 
		REPLACE SKJ->KJ_TIPO	WITH obj:listType		  	
		REPLACE SKJ->KJ_USRLEVL	WITH oBtn:userLevel
	EndIf
	MsUnlock()
Next       
ConfirmSX8()
Return lFound

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fillClass     �Autor  �Michel W. Mosca � Data �  01/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Preenche a classe com a regra de negocios.                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method fillClass(obj, cAlias) Class PersistTSToolbarList  
Local oBtn
                    
While((cAlias)->(!EOF()) .AND. obj:id == (cAlias)->KJ_CODTELE)
	If obj:listType == (cAlias)->KJ_TIPO              
		oBtn 			:= TSToolbarButton():New()
		oBtn:id			:= (cAlias)->KJ_CODIGO
		oBtn:name		:= (cAlias)->KJ_NOME
		oBtn:imageName 	:= (cAlias)->KJ_IMAGEM
		oBtn:codeBlock	:= (cAlias)->KJ_CDBLOCK 
		oBtn:toolTipText:= (cAlias)->KJ_AJUDA	
		oBtn:pos		:= (cAlias)->KJ_POSICAO	 
		oBtn:codTele	:= (cAlias)->KJ_CODTELE	 
		oBtn:userLevel	:= (cAlias)->KJ_USRLEVL	   
		obj:add(oBtn)
	EndIf
	(cAlias)->(DbSkip())
End

Return obj                              

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SAVE      �Autor  �Michel W. Mosca     � Data �  01/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method save(obj) Class PersistTSToolbarList
Local lRet := .F. 

BEGIN TRANSACTION 
	lRet := Self:UpdateDBFields(obj)
END TRANSACTION
Return lRet                      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DELETE    �Autor  �Michel W. Mosca     � Data �  01/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method delete(obj, oButton) Class PersistTSToolbarList
Local lRet := .F.

BEGIN TRANSACTION
	DbSelectArea("SKJ")
	DbSetOrder(3) //KJ_FILIAL+KJ_CODTELE+KJ_CODIGO
	If DbSeek(xFilial("SKJ")+oButton:codTele+oButton:id)
		Reclock( "SKJ" ,.F.,.T.)
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
���Programa  �_TMKA500      �Autor  �Michel W. Mosca � Data �  09/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                   
FUNCTION _TMKA505C()
RETURN NIL