#INCLUDE "PROTHEUS.CH"
                            
// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA0041() ; Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJAFileDownloaderComunication     � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Class abstrata respons�vel pela comunica��o do baixador de arquivos.   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJAFileDownloaderComunication
	Method New()
	Method Connect()
	Method Disconnect()
	Method FileExist()
	Method GetTotalBytes()
	Method GetPart()
	Method GetMD5()
EndClass
