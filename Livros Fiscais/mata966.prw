#INCLUDE "MATA966.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA966   �Autor  �Mary C. Hergert     � Data �  11/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro das informacoes complementares a serem utilizadas  ���
���          �nos documentos fiscais.                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                    
Function Mata966()

AxCadastro("CCE",STR0001) // "Cadastro de informa��es complementares"

Return .T.
