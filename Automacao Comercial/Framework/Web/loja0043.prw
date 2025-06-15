#INCLUDE "PROTHEUS.CH"

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA0043() ; Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCFileDownloaderDownloadProgress � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Representativo do progresso da baixa do arquivo.                       ���
���             �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCFileDownloaderDownloadProgress From FWSerialize
	Data cFileName
	Data nTotalBytes
	Data nDownloadedBytes
	Data nBytesPerSecond
	Data nBufferSize
	Data nSecondsLeft
	Data nStatus
	
	Method New()
EndClass

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � New                               � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Contrutor                                                              ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cFileName: Nome do arquivo.                                            ���
���             � nTotalBytes: Tamanho total do arquivo em bytes.                        ���
���             � nDownloadedBytes: Bytes j� baixados do arquivo.                        ���
���             � nBytesPerSecond: Taxa de transfer�ncia de bytes por segundo.           ���
���             � nBufferSize: Tamanho do pacote de cada parte baixada.                  ���
���             � nSecondsLeft: Segundos que falta para baixar completamente o arquivo.  ���
���             � nStatus: Status do download do arquivo, sendo:                         ���
���             �          1 - Iniciado.                                                 ���
���             �          2 - Baixando.                                                 ���
���             �          3 - Finalizado.                                               ���
���             �          4 - Erro.                                                     ���
����������������������������������������������������������������������������������������͹��
���    Retorno: �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New( cFileName, nTotalBytes, nDownloadedBytes, nBytesPerSecond, nBufferSize, nSecondsLeft, nStatus ) Class LJCFileDownloaderDownloadProgress
	Default cFileName		:= ""
	Default nTotalBytes		:= 0
	Default nDownloadedBytes:= 0
	Default nBytesPerSecond	:= 0
	Default nBufferSize		:= 0
	Default nSecondsLeft	:= 0
	Default nStatus			:= 0

	Self:cFileName			:= cFileName
	Self:nTotalBytes		:= nTotalBytes
	Self:nDownloadedBytes	:= nDownloadedBytes
	Self:nBytesPerSecond	:= nBytesPerSecond
	Self:nBufferSize		:= nBufferSize
	Self:nSecondsLeft		:= nSecondsLeft
	Self:nStatus			:= nStatus
Return
