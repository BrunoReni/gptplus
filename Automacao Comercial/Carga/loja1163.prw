#INCLUDE "PROTHEUS.CH"

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA1163() ; Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCInitialLoadSpecialTable        � Autor: Vendas CRM � Data: 16/10/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Classe que representa uma tabela de transfer�ncia especial.            ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCInitialLoadSpecialTable From FWSerialize
	Data cTable
	Data aParams
	Data cQtyRecords
	
	Method New()    
EndClass

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � New                               � Autor: Vendas CRM � Data: 16/10/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Construtor.                                                            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cTable: Alias da tabela completa.                                      ���
���             � aParams: Par�metros da transfer�ncia especial.                         ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New( cTable, aParams ) Class LJCInitialLoadSpecialTable
	If !Empty( cTable )
		Self:cTable := cTable
	Else
		cTable := ""
	EndIf
	
	If !Empty( aParams )
		Self:aParams := aParams
	Else
		Self:aParams := {}
	EndIf	
Return