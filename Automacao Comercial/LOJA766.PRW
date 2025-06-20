#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA766.CH"

Function LOJA766; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCDadNeg        �Autor  �Vendas Clientes     � Data �  15/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em manipular um arquivo.                   	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCRetNeg

	Data nSeq
	Data cCodigo
	Data cProduto
	Data cDescProd	
	Data cForma
	Data cAdm
	Data cDescAdm	
	Data nParcelas
	Data nIntervalo
	Data nVencimento
	Data nTxJuro
	Data cTpJuro
	Data nParMin
	Data nParMax      	
	Data nEntrada    	
	Data FPEnt
	Data nValEnt    	
	Data nPerEn    		
	Data nJur1Pa    	
	Data nCar1Pa    	
	Data nLim1Pa    	
	Data nFixaDia    	

	Method New()
	Method SetRetDados()
	Method DelRetDados()
	Method TrataProd()
	Method TrataAdm()
	Method GetValEnt(nValTot)
		
EndClass
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJC_DadosCDes. 				          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
���          �  			      										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCRetNeg
	
	//��������������������������������������������Ŀ
	//�Metedo contrutor, inicializa as propriedades�
	//����������������������������������������������
	Self:DelRetDados()

Return()                                                                            	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �SetRetDado�Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCRetNeg. 					          ���
�������������������������������������������������������������������������͹��
���Parametros�nExp1 -Valor total										  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SetRetDados(nValTot)Class LJCRetNeg
	
	//���������������������������������������������Ŀ
	//�Metedo conDtrutor, inicializa as propriedades�
	//�����������������������������������������������
	Self:nSeq			:= Self:nSeq + 1
	Self:cCodigo		:= MBT->MBT_CODIGO
	Self:cAdm			:= MBT->MBT_ADM
	Self:cDescAdm		:= Self:TrataAdm(Self:cAdm)
	Self:cForma			:= MBT->MBT_FORMPG
	Self:nParMin      	:= MBT->MBT_MINPAR	
	Self:nParMax      	:= MBT->MBT_PARCEL
	Self:nIntervalo     := MBT->MBT_INTERV
	Self:nVencimento    := MBT->MBT_VENCIM
	Self:nTxJuro		:= MBT->MBT_TXJURO    
	Self:FPEnt    		:= MBT->MBT_FPENT	
	Self:nValEnt    	:= MBT->MBT_VALENT             
	Self:nPerEn    		:= MBT->MBT_PERENT
	Self:nEntrada    	:= Self:GetValEnt(nValTot)
	Self:nJur1Pa    	:= MBT->MBT_JUR1PA
	Self:nCar1Pa    	:= MBT->MBT_CAR1PA
	Self:nLim1Pa    	:= MBT->MBT_LIM1PA                                          	
	Self:nFixaDia       := MBT->MBT_VDFIXO                                 	

	Do Case 
		Case MBT->MBT_TPJURO == "1"
			Self:cTpJuro    	:= STR0001  //"1 - Simples"
		Case MBT->MBT_TPJURO == "2"
			Self:cTpJuro    	:= STR0002	//"2 - Composto"
		Case MBT->MBT_TPJURO == "3"
			Self:cTpJuro    	:= STR0003  //"3 - Price"
	EndCase

Return()
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �DelRetDado�Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJC_DadosCDes. 				          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method DelRetDados() Class LJCRetNeg
	
	Self:nSeq			:= 0
	Self:cCodigo		:= ''
	Self:cForma			:= ''
	Self:cAdm			:= ''
	Self:nParcelas      := 0
	Self:nIntervalo     := 0
	Self:nVencimento    := 0

Return()





/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TrataAdm  �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Chama tela de classificacao de desconto                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�	  			                                              ���
���          �                                           			      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TrataAdm(cCodigo) Class LJCRetNeg

	Local aBkArea 	:= GetArea() 	// Backup da Area
	Local cRet		:= ""			// Retorno
	
	DbSelectArea("SAE")
	DbSetOrder(1)
	
	If DbSeek(xFilial("SAE")+cCodigo)
		
		cRet := SAE->AE_DESC 
	
	EndIf
	
	RestArea(aBkArea)	

Return(cRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TrataProd �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Chama tela de classificacao de desconto                     ���
�������������������������������������������������������������������������͹��
���Parametros�CExp1 -Codigo do Produto									  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TrataProd(cCodigo) Class LJCRetNeg

	Local aBkArea 	:= GetArea() 	// Backup da Area
	Local cRet		:= "***"		// Retorno
	
	Default cCodigo := "" 
	
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	If DbSeek(xFilial("SB1")+cCodigo)
		cRet := SB1->B1_DESC 
	Else
		cRet := "***"
	EndIf
	
	RestArea(aBkArea)	

Return(cRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetValEnt �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Chama tela de classificacao de desconto                     ���
�������������������������������������������������������������������������͹��
���Parametros�nExp1 -Valor total										  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Method GetValEnt(nValTot) Class LJCRetNeg
Local nRet := 0

If Self:nValEnt > 0   	      
	nRet := Self:nValEnt
ElseIf Self:nPerEn > 0
	nRet := A410Arred(((Self:nPerEn   * nValTot) / 100),"L1_VLRTOT")      
Else
	nRet := 0
EndIf
Return(nRet)
