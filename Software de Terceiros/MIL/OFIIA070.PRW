#include "protheus.ch"  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIIA070 � Autor �  Fabio                � Data � 27/12/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exportacao dos dados da Venda de veiculos zero VV0->VI7    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Integracao                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIIA070(dPDataMovto,cPChassi,xOpc,lBrowse,lPTelaDig)
   Default dPDataMovto := dDataBase
   Default cPChassi    := ""
   Default xOpc        := {3}
   Default lBrowse     := .t.
   Default lPTelaDig   := .t.
   If ExistBlock("VWIA070")      // VW
      ExecBlock("VWIA070",.f.,.f.,{})
   ElseIf ExistBlock("GMIA070")  // GM
      ExecBlock("GMIA070",.f.,.f.,{dPDataMovto,cPChassi,xOpc,lBrowse,lPTelaDig})
   ElseIf ExistBlock("FIIA070")	// Fiat
      ExecBlock("FIIA070",.f.,.f.,{})
   ElseIf ExistBlock("FOIA070")  // Ford
      ExecBlock("FOIA070",.f.,.f.,{})
   ElseIf ExistBlock("HOIA070")  // Honda
      ExecBlock("HOIA070",.f.,.f.,{})
   EndIf
Return