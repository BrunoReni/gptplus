#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFECF.CH"

Function LOJA1346 ; Return 	 // "dummy" function - Internal Use 

/*

	A partir dessa vers�o de fonte a impressora Bematech N�o Fiscal, passa a ser chamada somente 
	pela SIGALOJA.DLL, pois para efeito de manuten��o os fontes LOJA13** estavam ficando obsoletos
	sem as atualiza��es recentes, j� na SIGALOJA acontece a manuten��o ativamente.

*/

/*����������������������������������������������������������������������������������������
���Classe    �LJCNfBemaMP4200        �Autor  �Vendas Clientes     � Data �  26/03/13   ���
��������������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em se comunicar com a impressora LJANfBematech	           ���
��������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		       ���
����������������������������������������������������������������������������������������*/
Class LJCNfBemaMP4200 From LJANfBematech
	
	Method New(oTovsApi)										//Metodo construtor
					 
EndClass

/*����������������������������������������������������������������������������������
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  26/03/13   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCNfBemaMP4200.			    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oTotvsAPI) - Objeto do tipo LJCTotvsApi.				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method New(oTovsApi) Class LJCNfBemaMP4200
	
	_Super:New(oTovsApi)
	
Return Self          