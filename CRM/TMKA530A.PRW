#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SLALoadPar�Autor  �Vendas Clientes     � Data �  07/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Descreve os parametros para busca de SLA                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class SLALoadParam
Data createdDateBegin
Data createdDateEnd
Data dateToExpireBegin
Data dateToExpireEnd
Data hourToExpireBegin
Data hourToExpireEnd
Data finishedDateBegin
Data finishedDateEnd

Method new() Constructor

EndClass


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �New          �Autor  � Vendas Clientes � Data �  07/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe SLALoadParam.                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class SLALoadParam
Self:createdDateBegin		:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
Self:createdDateEnd			:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
Self:dateToExpireBegin		:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
Self:dateToExpireEnd		:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
Self:hourToExpireBegin		:= ""
Self:hourToExpireEnd		:= ""
Self:finishedDateBegin		:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
Self:finishedDateEnd		:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )

Return Self


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_TMKA530A     �Autor  �Vendas Clientes � Data �  07/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                   
FUNCTION _TMKA530A()
RETURN NIL
