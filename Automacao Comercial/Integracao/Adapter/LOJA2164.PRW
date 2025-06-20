#INCLUDE "PROTHEUS.CH"
#INCLUDE "DEFINTEGRA.CH"

Function LOJA2164() ; Return

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCAdapXmlEnvFactory  �Autor  �Vendas Clientes     � Data �28/09/09 ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe que fabrica o adapter xml de envio de uma tabela.            ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCAdapXmlEnvFactory
	
	Method New()
	Method Create()
	Method CreateByProcess()
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCAdapXmlEnvFactory.	              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCAdapXmlEnvFactory	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Create    �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que cria o adaptar xml de envio e o retorna.         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�cTable: Tabela que dever� ter seu adaptador xml criado.	  ���
�������������������������������������������������������������������������͹��
���Retorno   � Instancia do adaptardor de envio da tabela.                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Create( cTable ) Class LJCAdapXmlEnvFactory
	Local oLJCAdapXmlEnv := Nil

	Do Case
		Case cTable == "SA1"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSA1():New()
		Case cTable == "AC8"
			oLJCAdapXmlEnv := LJCAdapXMLEnvAC8():New()			
		Case cTable == "SA3"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSA3():New()
		Case cTable == "SFI"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSFI():New()						
		Case cTable == "SF2"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSF2():New()
		Case cTable == "SC5"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSC5():New()
		Case cTable == "SLG"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSLG():New()
		Case cTable == "SE1"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSE1():New()
		Case cTable == "SE5"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSE5():New()			
		Case cTable == "SEF"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSEF():New()			
		Case cTable == "SLX"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSLX():New()			
		Case cTable == "SX5"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSX5():New()			
		Case cTable == "SBM"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSBM():New()			
		Case cTable == "DA0"
			oLJCAdapXmlEnv := LJCAdapXMLEnvDA0():New()			
		Case cTable == "DA1"
			oLJCAdapXmlEnv := LJCAdapXMLEnvDA1():New()			
		Case cTable == "SE4"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSE4():New()			
		Case cTable == "SB1"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSB1():New()			
		Case cTable == "SM0"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSM0():New()					
		Case cTable == "SB2"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSB2():New()					
		Case cTable == "SA4"
			oLJCAdapXmlEnv := LJCAdapXMLEnvSA4():New()											
		Otherwise		
			Conout("LJCAdapXmlEnvFactory n�o tem programado o adapter xml da tabela " + cTable )
	EndCase
Return oLJCAdapXmlEnv     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Create    �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que cria o adaptar xml de envio e o retorna.         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�cTable: Tabela que dever� ter seu adaptador xml criado.	  ���
�������������������������������������������������������������������������͹��
���Retorno   � Instancia do adaptardor de envio da tabela.                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CreateByProcess( cProcess ) Class LJCAdapXmlEnvFactory
	Local oLJCAdapXmlEnv := Nil

	Do Case
		Case cProcess == _PRODUTOEGRUPO
			oLJCAdapXmlEnv := LJCAdapXMLEnvProduto():New()			
		Otherwise		
			UserException( "LJCAdapXmlEnvFactory n�o tem programado o adapter xml da tabela " + cProcess )
	EndCase
Return oLJCAdapXmlEnv
