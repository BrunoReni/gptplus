#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SLAResponsibleTop �Autor: Vendas Clientes     �Data:08/01/08���
�������������������������������������������������������������������������͹��
���Desc.     �Classe que contempla as rotinas referentes a banco de dados ���
���          �Top.                                                        ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class SLAResponsibleTop From PersistSLAResponsible
Method new() Constructor
Method load(obj)

EndClass


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �new       �Autor  �Vendas Clientes     � Data �  10/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Construtor da classe SLAResponsibleTop                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class SLAResponsibleTop

Return Self


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �load      �Autor  �Vendas Clientes     � Data �  11/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �														      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method load(obj) Class SLAResponsibleTop
Local lRet	 := .T.
Local cAlias :=	GetNextAlias() 

BeginSQL alias cAlias
	SELECT 	K8_CODRESP,		K8_NOME, 		K8_EMAIL, 
			K8_CODUSU,		K8_SUPERIO

	FROM	%table:SK8% SK8
	WHERE	SK8.K8_FILIAL = %xFilial:SK8% AND 	
			SK8.%NOTDEL% AND
			SK8.K8_CODRESP = %EXP:obj:id%
EndSql                                  

If (cAlias)->(!Eof())
	obj:id				:= (cAlias)->K8_CODRESP
	obj:name			:= (cAlias)->K8_NOME
	obj:email			:= (cAlias)->K8_EMAIL
	obj:codProtheusUser	:= (cAlias)->K8_CODUSU
	obj:codSuperior		:= (cAlias)->K8_SUPERIO
	DbSelectArea(cAlias)
	DbCloseArea()
Else
	lRet := .F.
EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_TMKA530P     �Autor  �Vendas Clientes � Data �  08/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION _TMKA530P()
RETURN NIL