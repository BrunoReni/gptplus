#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �WFInformat�Autor  �Vendas Clientes     � Data �  06/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Classe que cotempla as rotinas referentes ao acesso a dados ���
���          �CodeBase.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class WFInformationCodebase From PersistWFInformation

Method new() Constructor 
Method load(obj)


EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New          �Autor  �Vendas Clientes  � Data �  07/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class WFInformationCodebase
Return Self     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �load         �Autor  �Vendas Clientes  � Data �  07/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por carregar o registro de Workflow na   ���
���          �base de dados (Codebase)                                    ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method load(obj) Class WFInformationCodebase
Local lRet		:= .F.
Local cAlias	:= "SKW"

DbSelectArea(cAlias) 
DbSetOrder(1)
If DbSeek(xFilial(cAlias)+obj:id)
	Self:fillClass(obj, cAlias)
	lRet := .T.
EndIf

Return lRet

     
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_TMKA520F     �Autor  �Vendas Clientes � Data �  06/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                   
FUNCTION _TMKA520F()

RETURN NIL