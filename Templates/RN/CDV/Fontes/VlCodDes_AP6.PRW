#INCLUDE "VlCodDes_AP6.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VLCODDES  �Autor  �Willy               � Data �  07/01/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Valida Codigo da Despesa, e incrementa zeros na digitacao ���
�������������������������������������������������������������������������͹��
���Uso       � AP7                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function VlCodDes(_cSistem)
Local _lVlCodDes 	:= .T.
Local lPermissao 	:= .F.
Local _cCargo		:= Space(06)
Local _cTipo 		:= Space(06)
Local _aReturn 	:= {}
Local aCpos 		:= {}

ChkTemplate("CDV")

//Verificar se o colaborador tem permissao de uso da despesa selecionada
//_cFunc --> Essa variavel vem das rotinas AE_DV001

//Procura na tabela de permissoes por colaborador
DbSelectArea("LJI")
DbSetOrder(1)
If MsSeek(xFilial() + _cFunc + M->LHR_CodDes)
	If LJI->LJI_AUTRZA = .T.
		lPermissao := .T. //Achou a despesa na tabela de permissoes por colaborador e o colaborador possui permissao de uso
	Endif
Else	
	//Selecionar o cargo do colaborador e procurar na tabela de permissoes por cargo
	DbSelectArea("LHT")	
	DbSetOrder(1)
	If MsSeek(xFilial() + _cFunc)
		_cCargo := LHT->LHT_CARGO
		//Verificar permiss�o de uso de despesas na tabela de Cargos
		DbSelectArea("LJJ")	
		DbSetOrder(1)
		If MsSeek(xFilial() + _cCargo + M->LHR_CodDes)
			lPermissao := .T.
		EndIf
	EndIf
EndIf	

If !lPermissao
	MsgInfo(STR0001) //"Colaborador n�o possui permiss�o para utilizar essa despesa."
	_lVlCodDes := .F.
Else
	DbSelectArea('LHS')
	DbSetOrder(1)
	If !MsSeek(xFilial('LHS') + M->LHR_CodDes)
		_lVlCodDes := .F.
		MsgInfo(STR0002, STR0003) //'C�digo de Despesa n�o Cadastrado'###'Aten��o'
	Else
		aCols[n][_nPosDesc] := LHS_DESCRI
		aCols[n][_nPosTCal] := LHS_TIPCAL
		_cTipo := LHS->LHS_TIPCAL  
	EndIf
EndIf
                                  	
If _lVlCodDes
	If _cTipo == "KM__M1"
		If AllTrim(LHP->LHP_KmI) == ""
			aCols[n][_nPosVrt] := aCols[n][_nPosQtd] * Val(SubStr(Trim(GetMV('MV_KmI')),8,10))
    	Else
			aCols[n][_nPosVrt] := aCols[n][_nPosQtd] * Val(SubStr(Trim(LHP->LHP_KmI),8,10))
		EndIf
	EndIf
	
	If 	DTOS(aCols[n][_nPosDat]) != "" .And. ;
		aCols[n][_nPosQtd] != 0 .And. ;
		aCols[n][_nPosVrt] > 0

		T_ValidLim(aCols[n][_nPosDat], M->LHR_CodDes, aCols[n][_nPosQtd], aCols[n][_nPosVrt])
	EndIf
EndIf       

AADD(aCpos,{"LHR_Item","LHR_Data","LHR_CodDes","LHR_Qtdade","LHR_VlrTot","LHR_MOEDA","LHR_ValRbN",;
				"LHR_ValRbS","LHR_Descr","LHR_TipCal",.F.})

If _lVlCodDes
	If ExistBlock("PC_Calc")
		_aReturn := ExecBlock("PC_Calc", .F., .F.,{M->LHR_CodDes,_dVooS,_cVooS,_dVooC,_cVooC,aCpos,aCols})
		//_aReturn[1] == VALOR TOTAL
		aCols[n][_nPosVrt] := _aReturn[1]
	EndIf
EndIf

Return(_lVlCodDes)                                              