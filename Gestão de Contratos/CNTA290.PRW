#include "protheus.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "Topconn.ch"
#include "TbiCode.ch"
#include "CNTA290.ch"


#DEFINE DEF_SVIGE "05" //Vigente

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CNTA290  � Autor �                       � Data �24.11.2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � JOB para apropria��o do cronograma cont�bil                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CNTA290(cExp01,cExp02,cExp03)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp01 - Codigo da Empresa                                 ���
���          � cExp02 - Codigo da Filial                                  ���
���          � cExp03 - Horario da execicao HH:MM / Intervalo entre as    ���
���          �          execucoes                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

// funcao apenas para SCHE() apenas para debugar o fonte SCHED010()
Function CNTA290(aParam)

Private lMsErroAuto := .F.
Private lFail       := .F.
Private cPerg       := "CNTA290"

FwLogMsg("INFO", , "", "CNTA290", "", "01", STR0014, 0, -1, {}) //Inicio da Execu��o - CNTA290
//������������������������������������������������������Ŀ
//� Verifica se a rotina e executada atraves de um JOB   �
//� ou pelo menu                                         �
//��������������������������������������������������������
If GetRemoteType() == -1//Execucao por JOB
	//������������������������������������������������������Ŀ
	//� Verifica se a rotina e executada entre um intervalo  �
	//� ou em um horario estabelecido                        �
	//��������������������������������������������������������
	RpcSetType ( 3 )
	wfprepenv(aParam[1] , aParam[2] ,,{"SM0","CT2","CN9","CNW","CNV"})
	
	CHKFILE("SM0")
	DbGoTop()
	CN290Exc(.T.,SM0->M0_CODIGO,SM0->M0_CODFIL)
	RESET ENVIRONMENT
	
Else //Execucao por Menu

	//��������������������������������������������������������������Ŀ
	//� Verifica as perguntas selecionadas                           �
	//�MV_PAR01 - Periodo De?     										     �
	//�MV_PAR02 - Periodo Ate?       							           �
	//�MV_PAR03 - Tipo de Movimento?	                                �
	//����������������������������������������������������������������
	
	If Pergunte("CNT290")
		Processa( {|| CN290Exc(.F.) } )
	Endif
EndIf

FwLogMsg("INFO", , "", "CNTA290", "", "01", STR0015, 0, -1, {}) //"Fim da Execu��o - CNTA290"

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CN290Exc � Autor �                       � Data �24.11.2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Executa JOB para apropria��o do cronograma cont�bil        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN290Exc(lExp01)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lExp01 - Executado pelo job                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN290Exc(lJob)

Local cArqCtb       := ""
Local cLoteCtb      := ""
Local cNumCron
Local lContinua     :=.T.
Local lDigita       := If(lJob,.F.,If(MV_PAR04=1,.T.,.F.))
Local lAglutina     := If(lJob,.F.,If(MV_PAR05=1,.T.,.F.))
Local nTotalLCtb    := 0
Local dDataini      :=(dDatabase-SuperGetMv("MV_CNTDTIN"))
Local cRotThread	:= FunName()
Local cChave		:= cRotThread + "_" + AllTrim(SM0->M0_CODIGO) + "_" + StrTran(AllTrim(xFilial("SN4")), " ", "_")

Private lMsErroAuto := .F.

//�����������������������������������������������������������Ŀ
//� Verifica o numero do lote contabil                        �
//�������������������������������������������������������������
dbSelectArea("SX5")
dbSetOrder(1)
If MsSeek(xFilial()+"09GCT")
	cLoteCtb := AllTrim(X5Descri())
Else
	cLoteCtb := "GCT "
EndIf

//���������������������������������������Ŀ
//� Gera historico                        �
//�����������������������������������������

cTxLog := STR0001+" - "+DTOC(dDataBase)+" - "+time()+CHR(13)+CHR(10)//"Log de execucao "
cTxLog += Replicate("-",128)+CHR(13)+CHR(10)
DbselectArea("CNW")
DbSetOrder(1)

If lContinua
	If !LockByName( cChave, .F. , .F. ) //Semaforo para processamento da rotina.
		Help( " " ,1, cChave ,, STR0013 ,1, 0 ) //"Outro usu�rio est� usando a rotina. Tente novamente mais tarde."
	Else
		nStack := GetSX8Len()
		If lJob
			cTxLog +=STR0001+" - " + time()+CHR(13)+CHR(10) //"Gerando apropria��o do Cronograma Contabil"
			cTxLog += Replicate("-",128)+CHR(13)+CHR(10)
		EndIf
		//������������������������������������������Ŀ
		//� Filtra parcelas de contratos automaticos �
		//� pendentes para a data atual              �
		//��������������������������������������������
		
		cArqTrb	:= CriaTrab( nil, .F. )
		cQuery := "SELECT DISTINCT CNV.*,CNW.* FROM " + RetSQLName("CN9")+ " CN9, "  + RetSQLName("CNV") + " CNV, " + RetSQLName("CNW") + " CNW "
		cQuery += "WHERE "
		cQuery += "CNV.CNV_FILIAL = '"+ xFilial("CNV") +"' AND "
		cQuery += "CNW.CNW_FILIAL = '"+ xFilial("CNW") +"' AND "
		cQuery += "CN9.CN9_FILIAL = '"+ xFilial("CN9") +"' AND "
		
		cQuery += "CNV.CNV_NUMERO = CNW.CNW_NUMERO AND "
		cQuery += "CNV.CNV_REVISA = CNW.CNW_REVISA AND "
		cQuery += "CNV.CNV_CONTRA = CNW.CNW_CONTRA AND "
		cQuery += "CN9.CN9_NUMERO = CNW.CNW_CONTRA AND "
		If lJob
			cQuery += "CNW.CNW_DTPREV >= '"+ dtos(dDataini)  +"' AND "
			cQuery += "CNW.CNW_DTPREV <= '"+ dtos(dDataBase) +"' AND "
		Else
			cQuery += "CNW.CNW_DTPREV >= '"+ dtos(MV_PAR01)  +"' AND "
			cQuery += "CNW.CNW_DTPREV <= '"+ dtos(MV_PAR02)  +"' AND "
		Endif
		cQuery += "CN9.CN9_SITUAC = '"+ DEF_SVIGE +"' AND "
		cQuery += "CNV.CNV_REVISA = CN9.CN9_REVISA  AND "
		cQuery += "CNW.CNW_REVISA = CN9.CN9_REVISA  AND "

		If lJob
			cQuery += "CNW.CNW_FLGAPR in (' ','2') AND "
		Else
			If MV_PAR03=1
				cQuery += "CNW.CNW_FLGAPR in (' ','2') AND "
			ElseIf MV_PAR03=2
				cQuery += "CNW.CNW_FLGAPR = '1' AND "
			Endif
		Endif
		cQuery += "CN9.D_E_L_E_T_ = ' ' AND "
		cQuery += "CNV.D_E_L_E_T_ = ' ' AND "
		cQuery += "CNW.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY CNW.CNW_NUMERO,CNW.CNW_PARCEL"
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cArqTrb, .T., .T. )

		//�����������������������������������������������������������Ŀ
		//� Cabecalho da contabilizacao                               �
		//�������������������������������������������������������������
		If (cArqTrb)->(Eof())
			If lJob
				cTxLog += STR0009 + " - "+STR0002 + " - " + time()+CHR(13)+CHR(10)
			Else
				If Aviso(OemToAnsi(STR0009),OemToAnsi(STR0002),{OemToAnsi(STR0010)}) == 1
					lFail:=.F.
				Endif
			Endif
			Return lFail
		Endif
		nHdlPrv :=HeadProva(cLoteCtb,"CNTA290",Subs(cUsuario,7,6),@cArqCtb)
		
		While !(cArqTrb)->(Eof())
			CN9->(dbSetOrder(1))
			CN9->(dbSeek(xFilial("CN9")+(cArqTrb)->CNW_CONTRA+(cArqTrb)->CNW_REVISA))

			CNA->(dbSetOrder(1))
			CNA->(dbSeek(xFilial("CNA")+(cArqTrb)->CNW_CONTRA+(cArqTrb)->CNW_REVISA+(cArqTrb)->CNV_PLANIL))
		
			lContinua := .T.    
			DbselectArea("CNW")
			DbSetOrder(1)
			If MsSeek(xFilial()+(cArqTrb)->CNW_CONTRA+(cArqTrb)->CNW_REVISA+(cArqTrb)->CNW_NUMERO+(cArqTrb)->CNW_PARCEL)
				nTotalLCtb := 0
				ProcCNZ(nHdlPrv, cLoteCtb, @nTotalLCtb)/*Processa registros de rateios dos itens da planilha*/
				ProcMultNat(nHdlPrv, cLoteCtb, @nTotalLCtb)/*Processa registros das multiplas naturezas*/
				nTotalLCtb	+= DetProva(nHdlPrv,"693","CNTA290",cLoteCtb)
			Endif
			DbselectArea(cArqTrb)
			cNumCron:=(cArqTrb)->CNW_NUMERO
			if lJob
				cTxLog += STR0012 +" - "+(cArqTrb)->CNW_CONTRA+" - "+(cArqTrb)->CNW_REVISA+" - "+(cArqTrb)->CNW_NUMERO+" - "+(cArqTrb)->CNW_PARCEL+CHR(13)+CHR(10)
			Endif 
			
			(cArqTrb)->(dbSkip())			
			If nHdlPrv > 0
				DbselectArea("CT2")
				// Rodape do lancamento gerando os totais.
				Rodaprova(nHdlPrv,nTotallCtb)
				
				If nTotalLCtb > 0
					cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina)
				EndIf
				DbselectArea("CNW")
			Else
				if !lJob
					HELP(" ",1,"SEM_LANC")
				Endif   
				lCtbOnLine := .F.
			EndIf
		EndDo

		//�����������������������������������������������Ŀ
		//� Gravando os Flags e Data                      �
		//������������������������������������������������� 
		DbselectArea("CNW") 
		DbSetOrder(1)

		DbSelectArea(cArqTrb)
		DbGoTop()
		While !(cArqTrb)->(Eof())

			DbselectArea("CNW") 
			dbSetOrder(1)
			If MsSeek(xFilial()+(cArqTrb)->CNW_CONTRA+(cArqTrb)->CNW_REVISA+(cArqTrb)->CNW_NUMERO+(cArqTrb)->CNW_PARCEL)
				RecLock("CNW",.F.)
				CNW->CNW_FLGAPR := "1"
				CNW->CNW_DTLANC := DDatabase
				CNW->(MsUnLock())
			Endif
			DbSelectArea(cArqTrb)
			(cArqTrb)->(dbSkip())
		EndDo                

		(cArqTrb)->(dbCloseArea())

		If lJob
			cTxLog += STR0005 +" - " + time()+CHR(13)+CHR(10)
		Else  
			Aviso(OemToAnsi(STR0009),OemToAnsi(STR0005),{OemToAnsi(STR0010)})
		EndIf
		cTxLog += STR0005 + time()

		UnLockByName( cChave, .F. , .F. )
	EndIf
EndIf
//���������������������������������������������������Ŀ
//� Executa gravacao do arquivo de historico          �
//�����������������������������������������������������
MemoWrite(Criatrab(,.f.)+".LOG",cTxLog)

//���������������������������������������������������Ŀ
//� Emite alerta com o log do processamento           �
//�����������������������������������������������������
MEnviaMail("041",{cTxLog})

Return lFail

/*
���������������������������������������������������������������������������Ŀ��
���Funcao    � CN290ESTOR    �Autor �Andrews Egas          �Data� 25/08/2016 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Estorna apropria��o contabil por item da CNW    ���
����������������������������������������������������������������������������ٱ�
*/
Function CN290ESTOR(cContra)
Local aAreas	:= {CN9->(GetArea()), CNA->(GetArea()), CNW->(GetArea()), GetArea()}
Local cArqCtb	:= ""
Local cLoteCtb	:= ""
Local cNumCron	:= ""
Local lContinua	:=.T.
Local nTotalLCtb:= 0
Local lDigita	:= .F.
Local lAglutina	:= .F.
Private lMsErroAuto	:= .F.

//�����������������������������������������������������������Ŀ
//� Verifica o numero do lote contabil                        �
//�������������������������������������������������������������
dbSelectArea("SX5")
dbSetOrder(1)
If MsSeek(xFilial()+"09GCT")
	cLoteCtb := AllTrim(X5Descri())
Else
	cLoteCtb := "GCT "
EndIf

Pergunte("CNT290", .F.)
lDigita		:= IIF((MV_PAR04 == 1),.T.,.F.)
lAglutina	:= IIF((MV_PAR05 == 1),.T.,.F.)

DbselectArea("CNW")
DbSetOrder(1)

If lContinua
	nStack := GetSX8Len()
	
	//������������������������������������������Ŀ
	//� Filtra parcelas de contratos automaticos �
	//� pendentes para a data atual              �
	//��������������������������������������������
	
	cArqTrb	:= CriaTrab( nil, .F. )
	cQuery := "SELECT DISTINCT CNV.*,CNW.* FROM " + RetSQLName("CN9")+ " CN9, "  + RetSQLName("CNV") + " CNV, " + RetSQLName("CNW") + " CNW "
	cQuery += "WHERE "
	cQuery += "CNV.CNV_FILIAL = '"+ xFilial("CNV") +"' AND "
	cQuery += "CNW.CNW_FILIAL = '"+ xFilial("CNW") +"' AND "
	cQuery += "CN9.CN9_FILIAL = '"+ xFilial("CN9") +"' AND "
	
	cQuery += "CNV.CNV_NUMERO = CNW.CNW_NUMERO AND "
	cQuery += "CNV.CNV_REVISA = CNW.CNW_REVISA AND "
	cQuery += "CN9_NUMERO = '" + cContra + "'  AND " //Pega o contrato atual para desfazer as apropria��es
   	cQuery += "CNV.CNV_CONTRA = CNW.CNW_CONTRA AND "
	cQuery += "CN9.CN9_NUMERO = CNW.CNW_CONTRA AND "

	cQuery += "CN9.CN9_SITUAC = '"+ DEF_SVIGE +"' AND "
	cQuery += "CNV.CNV_REVISA = CN9.CN9_REVISA  AND "
	cQuery += "CNW.CNW_REVISA = CN9.CN9_REVISA  AND "

	cQuery += "CNW.CNW_FLGAPR = '1' AND " // s� os que ja foram contabilizados

	cQuery += "CN9.D_E_L_E_T_ = ' ' AND "
	cQuery += "CNV.D_E_L_E_T_ = ' ' AND "
	cQuery += "CNW.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY CNW.CNW_NUMERO,CNW.CNW_PARCEL"
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cArqTrb, .T., .T. )

	//�����������������������������������������������������������Ŀ
	//� Cabecalho da contabilizacao                               �
	//�������������������������������������������������������������
	If !(cArqTrb)->(Eof())

		nHdlPrv :=HeadProva(cLoteCtb,"CN290ESTOR",Subs(cUsuario,7,6),@cArqCtb)
		
		While !(cArqTrb)->(Eof())
			CN9->(dbSetOrder(1))
			CN9->(dbSeek(xFilial("CN9")+(cArqTrb)->CNW_CONTRA+(cArqTrb)->CNW_REVISA))
	
			CNA->(dbSetOrder(1))
			CNA->(dbSeek(xFilial("CNA")+(cArqTrb)->CNW_CONTRA+(cArqTrb)->CNW_REVISA+(cArqTrb)->CNV_PLANIL))
		
			lContinua := .T.    
			DbselectArea("CNW")
			DbSetOrder(1)
			If MsSeek(xFilial()+(cArqTrb)->CNW_CONTRA+(cArqTrb)->CNW_REVISA+(cArqTrb)->CNW_NUMERO+(cArqTrb)->CNW_PARCEL)
				nTotalLCtb := 0
				ProcCNZ(nHdlPrv, cLoteCtb, @nTotalLCtb, .T.)/*Processa registros de rateios dos itens da planilha*/
				ProcMultNat(nHdlPrv, cLoteCtb, @nTotalLCtb, .T.)/*Processa registros das multiplas naturezas*/
				nTotalLCtb	+= DetProva(nHdlPrv,"69J","CN290ESTOR",cLoteCtb)
			Endif
			DbselectArea(cArqTrb)
			cNumCron:=(cArqTrb)->CNW_NUMERO
	
			(cArqTrb)->(dbSkip())
			
			If nHdlPrv > 0
				DbselectArea("CT2")
				// Rodape do lancamento gerando os totais.
				Rodaprova(nHdlPrv,nTotallCtb)
				
				If nTotalLCtb > 0
					cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina)					
				EndIf
				DbselectArea("CNW")
			Else
				HELP(" ",1,"SEM_LANC")
				lCtbOnLine := .F.
			EndIf
		EndDo
	
		//�����������������������������������������������Ŀ
		//� Gravando os Flags e Data                      �
		//������������������������������������������������� 
		DbselectArea("CNW") 
	  	DbSetOrder(1)
	
		DbSelectArea(cArqTrb)
		DbGoTop()
		While !(cArqTrb)->(Eof())
	
	  		DbselectArea("CNW") 
	  		dbSetOrder(1)
			If MsSeek(xFilial()+(cArqTrb)->CNW_CONTRA+(cArqTrb)->CNW_REVISA+(cArqTrb)->CNW_NUMERO+(cArqTrb)->CNW_PARCEL)
				RecLock("CNW",.F.)
				CNW->CNW_FLGAPR := "2"
				CNW->CNW_DTLANC := CTOD("        ")
				CNW->(MsUnLock())
			Endif
			If MsSeek(xFilial()+(cArqTrb)->CNW_CONTRA+soma1((cArqTrb)->CNW_REVISA)+(cArqTrb)->CNW_NUMERO+(cArqTrb)->CNW_PARCEL)
				RecLock("CNW",.F.)
				CNW->CNW_FLGAPR := "2"
				CNW->CNW_DTLANC := CTOD("        ")
				CNW->(MsUnLock())
			Endif
			DbSelectArea(cArqTrb)
			(cArqTrb)->(dbSkip())
		EndDo                
	
		(cArqTrb)->(dbCloseArea())
	
	EndIf
EndIf

aEval(aAreas, {|x|RestArea(x)})
FwFreeArray(aAreas)
Pergunte("CNT100",.F.) //Restaura o pergunte do CNTA300 durante a revisao...
Return

/*/{Protheus.doc} ProcCNZ
	Processa os rateios da planilha(CNA) corrente
@author philipe.pompeu
@since 22/10/2021
@param nHead	, num�rico	, handle do arquivo
@param cLoteCtb	, caractere	, c�digo do lote GCT
@param nDet		, num�rico	, totalizador
@param lEstorno	, l�gico	, se � um processo de estorno
@return Nil, valor nulo
/*/
Static Function ProcCNZ(nHead, cLoteCtb, nDet, lEstorno)
	Local aAreas	:= {CNA->(GetArea()), CNB->(GetArea()), CNZ->(GetArea()), GetArea()}
	Local aTempArea := {}
	Local cLanPad	:= ""
	Local cChaveCNB	:= ""
	Local cChaveCNZ	:= ""
	Local cFilCNZ	:= xFilial("CNZ")
	Local cRotina	:= ""
	Default lEstorno:= .F.

	cLanPad := IIF(lEstorno, "69Q", "69P")
	cRotina := IIF(lEstorno, "CN290ESTOR", "CNTA290")

	CNB->(DbSetOrder(1))//CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
	cChaveCNB := CNA->(CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO)
	If CNB->(DbSeek(cChaveCNB))
		CNZ->(DbSetOrder(1))//CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_CODPLA+CNZ_ITCONT+CNZ_ITEM
		While CNB->(!Eof() .And. CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO == cChaveCNB) //Percorre os itens da Planilha			
			cChaveCNZ := cFilCNZ + CNB->(CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM)			
			If CNZ->(DbSeek(cChaveCNZ))
				While CNZ->(!Eof() .And. CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_CODPLA+CNZ_ITCONT == cChaveCNZ)//Percorre o rateio dos itens da planilha
					aTempArea := {CNB->(GetArea()), CNZ->(GetArea())}
					
					nDet += DetProva(nHead, cLanPad, cRotina, cLoteCtb)
					
					aEval(aTempArea, {|x|RestArea(x)}) //Restaura o posicionamento caso o usu�rio desposicione no lan�amento padr�o
					CNZ->(DbSkip())	
				EndDo	
			EndIf
			CNB->(DbSkip())	
		EndDo		
	EndIf
	aEval(aAreas, {|x|RestArea(x)})
	FwFreeArray(aAreas)
	FwFreeArray(aTempArea)
Return Nil

/*/{Protheus.doc} ProcMultNat
	Processa as m�ltiplas naturezas da planilha(CNA) corrente
@author philipe.pompeu
@since 22/10/2021
@param nHead	, num�rico	, handle do arquivo
@param cLoteCtb	, caractere	, c�digo do lote GCT
@param nDet		, num�rico	, totalizador
@param lEstorno	, l�gico	, se � um processo de estorno
@return Nil, valor nulo
/*/
Static Function ProcMultNat(nHead, cLoteCtb, nDet, lEstorno)
	Local aAreas	:= {CNA->(GetArea()), CXO->(GetArea()), CXP->(GetArea()), GetArea()}
	Local aTempArea := {}
	Local cLanPad	:= ""
	Local cChaveCXO	:= ""
	Local cChaveCXP	:= ""
	Local cFilCXP	:= xFilial("CXP")
	Local cRotina	:= ""
	Local cMedVazia := Space(GetSx3Cache('CXO_NUMMED','X3_TAMANHO'))
	Default lEstorno:= .F.

	cLanPad := IIF(lEstorno, "69S", "69R")
	cRotina := IIF(lEstorno, "CN290ESTOR", "CNTA290")	
	
	CXO->(DbSetOrder(4))//CXO_FILIAL+CXO_CONTRA+CXO_REVISA+CXO_NUMMED+CXO_NUMPLA
	cChaveCXO := xFilial("CXO") + CNA->(CNA_CONTRA+CNA_REVISA+cMedVazia+CNA_NUMERO)
	If CXO->(DbSeek(cChaveCXO))
		
		CXP->(DbSetOrder(1))//CXP_FILIAL+CXP_CONTRA+CXP_NUMMED+CXP_REVISA+CXP_NUMPLA+CXP_ITMNAT+CXP_ITEM
		While CXO->(!Eof() .And. CXO_FILIAL+CXO_CONTRA+CXO_REVISA+CXO_NUMMED+CXO_NUMPLA == cChaveCXO) //Percorre as naturezas			
			cChaveCXP := cFilCXP + CXO->(CXO_CONTRA+CXO_NUMMED+CXO_REVISA+CXO_NUMPLA+CXO_ITEM)			
			If CXP->(DbSeek(cChaveCXP))
				While CXP->(!Eof() .And. CXP_FILIAL+CXP_CONTRA+CXP_NUMMED+CXP_REVISA+CXP_NUMPLA+CXP_ITMNAT == cChaveCXP)//Percorre o rateio dos itens da planilha
					aTempArea := {CXO->(GetArea()), CXP->(GetArea())}
					
					nDet += DetProva(nHead, cLanPad, cRotina, cLoteCtb)
					
					aEval(aTempArea, {|x|RestArea(x)}) //Restaura o posicionamento caso o usu�rio desposicione no lan�amento padr�o
					CXP->(DbSkip())	
				EndDo
			Else //Caso n�o tenha CXP, chama a contabilizacao pra CXO
				aTempArea := CXO->(GetArea())
				
				nDet += DetProva(nHead, cLanPad, cRotina, cLoteCtb)
				
				RestArea(aTempArea)
			EndIf
			CXO->(DbSkip())	
		EndDo		
	EndIf
	aEval(aAreas, {|x|RestArea(x)})
	FwFreeArray(aAreas)
	FwFreeArray(aTempArea)
Return Nil
