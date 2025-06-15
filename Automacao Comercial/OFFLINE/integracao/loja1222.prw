#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "ERROR.CH"

Function LOJA1222()

	//���������������������������������������������������������������������Ŀ
	//�  Declaracao de Variaveis                                            �
	//�����������������������������������������������������������������������
	
	Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
	
	Private cString := "SLY"
	
	dbSelectArea("SLY")
	dbSetOrder(1)
	
	AxCadastro(cString,"Cadastro de regras de integra��o - Importacao",cVldExc,cVldAlt)

Return Nil