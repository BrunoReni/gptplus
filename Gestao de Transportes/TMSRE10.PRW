#INCLUDE "TMSRE10.ch"
#INCLUDE "protheus.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSRE10  � Autor � Gustavo Almeida       � Data �06/07/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � EDI - Relatorio de divergencias de valores de componentes. ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSRE10()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMS                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSRE10() 
            
Local oRptEDI
Local cPerg := "TMSRE10"
Local aArea := GetArea()

	Pergunte(cPerg,.F.)
	
	oRptEDI:= ReportDef(cPerg)
	oRptEDI:PrintDialog()

		
	RestArea(aArea)
Return NIL  

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Gustavo Almeida       � Data �06.07.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o da estrutura do relat�rio                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
                        
Static Function ReportDef(cPerg)
 
Local oRptEDI
Local oItens
Local cAliasQry := GetNextAlias()
Local oCelValor
Local oCelValCal
Local oCelValDif
Local oBreak

oRptEDI:= TReport():New(cPerg,STR0001,cPerg,{|oRptEDI| ReportPrint(oRptEDI, cAliasQry )},STR0002) //"Diverg�ncias de Frete Assumido no EDI Autom�tico"###"Este relat�rio ir� imprimir diverg�ncias de valores em composi��es de frete ap�s efetuado o EDI Autom�tico"
oRptEDI:SetTotalInLine(.F.)

oItens := TRSection():New(oRptEDI,"Itens",{"DE5","DET"})
oItens:SetTotalInLine(.F.)

TRCell():New(oItens,"DE5_CGCREM",,,,,, { || (cAliasQry)->DE5_CGCREM } )
TRCell():New(oItens,"DE5_NOMREM",,,,,, { || Posicione("SA1",3,xFilial("SA1")+(cAliasQry)->DE5_CGCREM,"A1_NREDUZ") } )
TRCell():New(oItens,"DE5_CGCDES",,,,,, { || (cAliasQry)->DE5_CGCDES } )
TRCell():New(oItens,"DE5_NOMDES",,,,,, { || Posicione("SA1",3,xFilial("SA1")+(cAliasQry)->DE5_CGCDES,"A1_NREDUZ") } )
TRCell():New(oItens,"DET_LOTEDI",,,,,, { || (cAliasQry)->DET_LOTEDI } )
TRCell():New(oItens,"DET_VALOR" ,,,,,, { || (cAliasQry)->DET_VALOR  } )
TRCell():New(oItens,"DET_VALCAL",,,,,, { || (cAliasQry)->DET_VALCAL } )
TRCell():New(oItens,"DET_VALCAL",,STR0003, "@E 999,999,999.99", 14,,{ || (cAliasQry)->DET_VALCAL - (cAliasQry)->DET_VALOR } ) //"Diverg�ncia"
TRCell():New(oItens,"DET_CODPAS",,,,,, { || (cAliasQry)->DET_CODPAS } )
TRCell():New(oItens,"DT3_DESCRI",,,,,, { || Posicione("DT3",1,xFilial("DT3")+(cAliasQry)->DET_CODPAS,"DT3_DESCRI") } )

oBreak := TRBreak():New(oItens,oItens:Cell("DET_LOTEDI"),STR0004) //"Total Lote EDI"

oCelValor  := TRFunction():New(oItens:Cell("DET_VALOR") ,NIL,"SUM",oBreak)
oCelValCal := TRFunction():New(oItens:Cell("DET_VALCAL"),NIL,"SUM",oBreak)
oCelValDif := TRFunction():New(oItens:Cell("Divergencia"),NIL,"SUM",oBreak) //"Diverg�ncia"

oRptEDI:SetLandScape(.T.)
oCelValor:SetEndSection(.F.)
oCelValCal:SetEndSection(.F.)
oCelValDif:SetEndSection(.F.)

Return oRptEDI

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor � Gustavo Almeida       � Data �06.07.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Sele��o das informa��es                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
                          
Static Function ReportPrint(oRptEDI,cAliasQry)

oRptEDI:Section(1):BeginQuery()
		
	BeginSql alias cAliasQry 
		SELECT DE5_CGCREM, DE5_CGCDES, DET_CODPAS, DET_LOTEDI, DET_VALOR, DET_VALCAL
		  FROM %table:DET% DET
		  JOIN %table:DE5% DE5 
			 ON DE5_FILIAL = %xfilial:DE5% 
         AND DE5_EDIFRT = "1" //-- Assume Frete 
         AND DE5_STATUS <> "1" //-- Status Conclu�do 
         AND DE5_CGCREM BETWEEN %exp:mv_par03% AND %exp:mv_par04%
			AND DE5_CGCDES BETWEEN %exp:mv_par05% AND %exp:mv_par06%
			AND DE5_EMINFC BETWEEN %exp:mv_par01% AND %exp:mv_par02%
			AND DE5_LOTEDI = DET_LOTEDI
			AND DE5.%notDel%        
	  	 WHERE DET_FILIAL = %xfilial:DET%
		   AND DET_VALOR  < DET_VALCAL  //-- Valor informado � menor que o calculado            
		   AND DET.%notDel%
		ORDER BY DE5_CGCREM
	EndSql

oRptEDI:Section(1):EndQuery()

oRptEDI:Section(1):SetParentQuery()

oRptEDI:SetMeter((cAliasQry)->(LastRec()))
oRptEDI:Section(1):Print()

Return NIL 
