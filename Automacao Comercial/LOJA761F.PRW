#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA761F; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCTelReMn       �Autor  �Vendas Clientes     � Data �  15/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em manipular tela		.                   	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCTelReMn

	Data cSayEnt 		
	Data oSayEnt 		
	Data oSayDifPar		
	Data cSayDifPar		
	Data OSayVFin 		
	Data cSayVFin 		
	Data oSayQPac		
	Data cSayQPac		
	Data oSayVParc 		
	Data cSayVParc 		
	Data oSayTotG 		
	Data cSayTotG 		
	Data oSayNcc
	Data cSayNcc
	

	Method New()
	Method AtuTudo(oItensSim, nNumIten,aRecTotal)
	Method Zera()
	Method Formata(nConten)
EndClass
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCTelReMn. 				              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCTelReMn
Self:Zera()
Return()
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCTelReMn. 				              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AtuTudo(oItensSim, nNumIten,aRecTotal) Class LJCTelReMn

Local nTotG		:= 0 // Total Geral   
Local nTotP     := 0 // Total Prazo
Local nX		:= 0     
Local cCFM      := ""

Default oItensSim	:= Nil 
Default nNumIten  	:= 0

If Valtype(oItensSim) == "O" .And. oItensSim:oRetPagMn:Count() > 0 .And. nNumIten > 0
	If Len(aRecTotal) > 0 
		nTotG := oItensSim:oRetPagMn:Elements(nNumIten):nVlrEnt
		For nX := 1 to Len(aRecTotal)
			nTotG += aRecTotal[nX][3]//oItensSim:Elements(nNumIten):nTotPrz
			nTotP += aRecTotal[nX][3]
			cCFM := oItensSim:oRetPagMn:Elements(nX):CFM				
		Next nX  
	Else	
		nTotG := oItensSim:oRetPagMn:Elements(nNumIten):nVlrEnt + oItensSim:oRetPagMn:Elements(nNumIten):nTotPrz 
		nTotP := oItensSim:oRetPagMn:Elements(nNumIten):nTotPrz 
		cCFM := oItensSim:oRetPagMn:Elements(nNumIten):CFM
	EndIf
		
		Self:cSayVFin := Self:Formata(nTotP)
		Self:OSayVFin:Refresh()
		
		Self:cSayTotG := Self:Formata(nTotG)
		Self:oSayTotG:Refresh()

		Self:cSayNcc := Self:Formata(oItensSim:oRetPagMn:Elements(nNumIten):nValNcc)
		Self:oSayNcc:Refresh()

EndIf	

Return()		


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Zera      �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Zera totais de dos objetos       				              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�	  			                                              ���
���          �          			                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Zera() Class LJCTelReMn

Self:cSayEnt 		:= PADL("0,00",15)
Self:cSayDifPar		:= PADL("0,00",15)
Self:cSayVFin 		:= PADL("0,00",15)
Self:cSayQPac		:= PADL("0", 15) 
Self:cSayVParc 		:= PADL("0,00",15) 
Self:cSayTotG 		:= PADL("0,00",15)

If ValType(Self:oSayDifPar) <> "U"
	Self:oSayDifPar:Refresh()
	Self:oSayEnt:Refresh()
	Self:oSayDifPar:Refresh()
	Self:oSayVFin:Refresh()
	Self:oSayTotG:Refresh()
	Self:oSayNcc:Refresh()
EndIf
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Formata   �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Formata valores. 				              				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Formata(nConten) Class LJCTelReMn
Local cRet := ""									// Retorno
Local cFormtTrs := PesqPict("SL1","L1_VLRTOT")		// maska

Default nConten := 0

cRet := PadL(AllTrim(TRANSFORM(nConten,cFormtTrs)),15)

Return(cRet)
