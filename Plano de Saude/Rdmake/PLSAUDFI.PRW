#INCLUDE "RWMAKE.CH"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLSAUDFI  � Autor � Totvs					� Data � 07/03/11 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Abre o pergunte e retorna filtro conforme selecao  		  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
User Function PLSAUDFI()
LOCAL aMatFil := {}
LOCAL cTpGui  := ""
LOCAL cTpAdm  := ""                                   
LOCAL nPos	  := 0
LOCAL cExpre  := ""

Pergunte("PLS790FILP",.T.,"Parametriza��o")

cExpre := "B53_FILIAL = '" + xFilial("B53") + "'"
AaDd(aMatFil,{"Filial","B53",cExpre} )

//---------------------------------------------------
// Departamento - MV_PAR01
//---------------------------------------------------
If !Empty(MV_PAR01)
    cExpre := "B53_CODDEP = '" + MV_PAR01 + "' "
Else
    cExpre := "B53_CODDEP = B53_CODDEP"
EndIf
 
If ( nPos := AsCan(aMatFil,{|x| x[2] == "B53" }) ) > 0
    aMatFil[nPos,3] += " .AND. " + cExpre
Else
    AaDd(aMatFil, {"Departamento","B53",cExpre } )
EndIf   

//---------------------------------------------------
// Guia j� analisada - MV_PAR02
//  1 - Todas
//  2 - Ainda n�o analisadas ou em an�lise  B53_SITUAC = '0'
//  3 - J� analisadas                       B53_SITUAC = '1'
//---------------------------------------------------
If (MV_PAR02 == 2)
    //Guias n�o analisadas
    cExpre := "(B53_SITUAC == '0' .OR. B53_SITUAC == '2')"
ElseIf (MV_PAR02 == 3)
    //Guias analisadas
    cExpre := "B53_SITUAC == '1'"
Else
    //Todas as guias
    cExpre := "B53_SITUAC = B53_SITUAC"
EndIf
    
If ( nPos := AsCan(aMatFil,{|x| x[2] == "B53" }) ) > 0
    aMatFil[nPos,3] += " .AND. " + cExpre
Else
    AaDd(aMatFil, {"Guias sem Analise","B53",cExpre } )
Endif

//---------------------------------------------------
// Origem guia - MV_PAR03
//  1 - Todas
//  2 - Autoriza��o     B53_ORIMOV = '1,2'
//  3 - Reembolso       B53_ORIMOV = '3' (Outros)
//---------------------------------------------------
if (MV_PAR03 == 1)
    cExpre := "B53_ORIMOV = B53_ORIMOV"
elseif (MV_PAR03 == 2)
    cExpre := "(B53_ORIMOV = '1' .OR. B53_ORIMOV = '2')"
else
    cExpre := "B53_ORIMOV = '3'"
endif
    
If ( nPos := AsCan(aMatFil,{|x| x[2] == "B53" }) ) > 0
    aMatFil[nPos,3] += " .AND. " + cExpre
Else
    AaDd(aMatFil, {"Origem Movto","B53", cExpre} )
EndIf

//---------------------------------------------------
// Prioridade - MV_PAR04
//  1 - Todas
//  2 - Alta    B53_PRIORI = '0'
//  3 - M�dia   B53_PRIORI = '1'
//  4 - Baixa   B53_PRIORI = '2'
//---------------------------------------------------
If MV_PAR04 > 1
    cExpre := "B53_PRIORI = '" + cValToChar( MV_PAR04-2 ) + "'" 
Else
    cExpre := "B53_PRIORI = B53_PRIORI"
EndIf

If ( nPos := AsCan(aMatFil,{|x| x[2] == "B53" }) ) > 0
    aMatFil[nPos,3] += " .AND. " + cExpre
Else
    AaDd(aMatFil, {"Prioridade","B53",cExpre} )
EndIf   

//---------------------------------------------------
// Regime Interna��o - MV_PAR05
//---------------------------------------------------
If MV_PAR05 > 1
    cExpre := "B53_ORIMOV = '2' .AND. B53_REGINT = '" + cValToChar( MV_PAR05-2 ) + "'"
Else
    cExpre := "B53_REGINT = B53_REGINT" 
EndIf

If ( nPos := AsCan(aMatFil,{|x| x[2] == "B53" }) ) > 0
    aMatFil[nPos,3] += " .AND. " + cExpre
Else
    AaDd(aMatFil, {"Regime Interna��o","B53",cExpre } )
EndIf   

//---------------------------------------------------
// Municipio - MV_PAR06
//---------------------------------------------------
If !Empty(MV_PAR06)
    cExpre := "B53_CODMUN = '" + cValToChar( MV_PAR06 ) + "'"
Else
    cExpre := "B53_CODMUN = B53_CODMUN"
EndIf
    
If ( nPos := AsCan(aMatFil,{|x| x[2] == "B53" }) ) > 0
    aMatFil[nPos,3] += " .AND. " + cExpre
Else
    AaDd(aMatFil, {"Municipio","B53",cExpre } )
EndIf

//---------------------------------------------------
// Rede de Atendimento - MV_PAR07
//---------------------------------------------------
If !Empty(MV_PAR07)
    cExpre := "B53_CODRDA = '" + MV_PAR07 + "' " 
Else
    cExpre := "B53_CODRDA = B53_CODRDA"
Endif

If ( nPos := AsCan(aMatFil,{|x| x[2] == "B53" }) ) > 0
    aMatFil[nPos,3] += " .AND. " + cExpre
Else
    AaDd(aMatFil, {"Rede de Atendimento","B53",cExpre} )
EndIf 

//---------------------------------------------------
// Data Movimento De Ate
//---------------------------------------------------
If !Empty(MV_PAR08) .And. !Empty(MV_PAR09)
	cExpre := "DtoS(B53_DATMOV) >= '" + DtoS(MV_PAR08) + "' .AND. DtoS(B53_DATMOV) <= '" + DtoS(MV_PAR09) + "' "
Else
    cExpre := "B53_DATMOV = B53_DATMOV"
EndIf   

If ( nPos := AsCan(aMatFil,{|x| x[2] == "B53" }) ) > 0
	aMatFil[nPos,3] += " .AND. " + cExpre
Else
	AaDd(aMatFil, {"Movimenta��o De/Ate","B53",cExpre} )
EndIf

//---------------------------------------------------
// Guias que analisei
//---------------------------------------------------
If MV_PAR10 > 1	
	cExpre := Iif(MV_PAR10 == 3,"B53_OPERAD = '" + RETCODUSR() + "' ","B53_OPERAD <> '" + RETCODUSR() + "' ")
    
    If ( nPos := AsCan(aMatFil,{|x| x[2] == "B53" }) ) > 0
		aMatFil[nPos,3] += " .AND. " + cExpre
    Else
		AaDd(aMatFil, {"Guias que Analisei","B53",cExpre } )
	EndIf	
EndIf

//---------------------------------------------------
// Ajusta filtro
//---------------------------------------------------
aMatFil := aSort(aMatFil,,,{|x,y| x[2] < y[2] } )

Return(aMatFil)