#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �LjPrepar  � Autor � Venda Clientes        � Data �22/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Prapara Ambiente para o ws                           	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � LjPrepar(ExpC1,ExpX2)						              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Empresa              							  ���
���          � ExpX2 - Filial                    						  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nil        									              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � OFFLINE                           						  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LjPreparaWs(cEmp, cFil)
	
	//����������������������������������������������������������������������������������������������������Ŀ
	//�Caso nao exista no servico de WebService o parametro "PREPAREIN=nn,nn"ou nao foi executado o comando�
	//�"PREPARE ENVIROMENT" , essa fun��o executara automaticamente.                                         �
	//������������������������������������������������������������������������������������������������������
	RpcSetType(3)
	
	If Type('cEmpAnt') == 'U'
		// "FRT" > Liberacao de acesso PDV cTree para o modulo FrontLoja
		RpcSetEnv(cEmp,cFil,Nil,Nil,"FRT")
	ElseIf !(cEmp == cEmpAnt)
		RpcClearEnv()
		// "FRT" > Liberacao de acesso PDV cTree para o modulo FrontLoja
		RpcSetEnv(cEmp,cFil,Nil,Nil,"FRT")
		cFilAnt := cFil
	ElseIf !(cFil == cFilAnt)
		cFilAnt := cFil
	EndIf

Return .T.


//GERACAO PACOTE PAF-ECF 12/08/2010






