#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � TMSA200S    � Autor � Felipe Barbiere    � Data �19/07/2021���
�������������������������������������������������������������������������Ĵ��
���Descricao � Schedule de C�lculo do Frete								  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMSA200S()
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()
Local cCalTpLt  := GetMV("MV_CALTPLT",,"2")	//-- Indica o Tipo de lote no c�lculo autom�tico 1=Normal, 2=Eletr�nico, 3=Todos
Local nDias 	:= 7

If Empty(cCalTpLt)
	cCalTplt := "2"	//-- Eletr�nico
EndIf
SetMVValue("TMB200","mv_par10", 2)    //-- Exibe Preview do Frete ? 

cQuery := "SELECT R_E_C_N_O_  DTPRECNO "
cQuery += "FROM " + RetSqlName("DTP")
cQuery += "WHERE DTP_FILIAL = '" + xFilial("DTP") + "'"
cQuery += " AND DTP_DATLOT >= '" + DToS(DaySub(dDataBase, nDias))  + "'"
cQuery += " AND DTP_STATUS = '2' "
If cCalTpLt == "1"	//-- Normal
	cQuery += " AND DTP_TIPLOT = '1' "
ElseIf cCalTpLt == "2"	//-- Eletr�nico
	cQuery += " AND DTP_TIPLOT IN ('3','4') "
EndIf
cQuery += " AND DTP_FILORI = '" + cFilAnt + "' "
cQuery += " AND D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

While (cAliasQry)->(!Eof())	
	If LockByName("SIGATMS_DTP_" + AllTrim(Str((cAliasQry)->DTPRECNO)), .T.,.F.)   
		DTP->(dbGoTo( (cAliasQry)->DTPRECNO ))
		lRet := TMSA200MNT("DTP", DTP->(RecNo()), 2, , .F.)
		UnLockByName("SIGATMS_DTP_" + AllTrim(Str((cAliasQry)->DTPRECNO)), .T.,.F.)  
	EndIf	
	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

Return 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Scheddef    � Autor � Felipe Barbiere    � Data �19/07/2021���
�������������������������������������������������������������������������Ĵ��
���Descricao � Fun��o Schedule  										  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function SchedDef()
Local aParam

aParam := {"P",;  	//Tipo R para relatorio P para processo   
		   "TMB200",;		// Pergunte do relatorio, caso nao use passar ParamDef            
		   "DTP",;  // Alias            
		   ,;   	//Array de ordens   
		   'Schedule - C�lculo do Frete'} //--> Schedule - Repom   

Return aParam
