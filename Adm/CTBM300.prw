#include "ctbm300.ch"
#include "protheus.ch"

Static __lBlind   := IsBlind()
Static __lConOutR := FindFunction( "CONOUTR" )
Static _oCtbm3001
Static _oCtbm3002
Static _lJobs 	  := IsCtbJob()
Static __lCTBM300 		:= .F.
Static __cCTBM300		:= ""
Static __oCTBM300		:= Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � CTBM300  �Autor  � Felipe Aurelio de Melo� Data � 17/11/08 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Permitir copiar saldos analiticos ou sinteticos de uma     ���
���          � determinada conta, cc, item ou classe de valor para um     ���
���          � segundo tipo de saldo informado pelo usuario.              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Contabilidade Gerencial - Movimentacoes                    ���
�������������������������������������������������������������������������Ĵ��
���            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.          ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS/FNC  �  Motivo da Alteracao                ���
�������������������������������������������������������������������������Ĵ��
��� Jose Glez  �        �  MMI-5346 �Numero de p�liza debe ser consecutivo���
���            �        �           �por mes.                             ���
���  Marco A.  �28/05/18�DMINA-2113 �Se modifica funcion CTM103ProxDoc(), ���
���            �        �           �para Numero de Poliza Consecutivo por���
���            �        �           �mes. (MEX)                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ctbm300(lAuto)

Local nOpca       := 0
Local aSays       := {}
Local aButt       := {}
Local aArea       := GetArea()
Local cPerg       := "CTBM30"
Local cProg       := "CTBM300"

Private cRetSX5SL := ""
Default lAuto     := .F.

//Guarda variaveis dos parametros em memoria
Pergunte(cPerg,.F.)

If IsBlind() .Or. lAuto
   If VldCtbm300(.T.)
		BatchProcess(STR0001,; //"C�pia de saldos"
						 STR0002 + Chr(13) + Chr(10) +; //"Esta rotina tem como objetivo copiar um conjunto de lan�amentos ou saldos de um"
						 STR0003 + Chr(13) + Chr(10) +; //"tipo de saldo origem para um tipo de saldo destino. � poss�vel c�piar tanto os"
						 STR0004 + Chr(13) + Chr(10) +; //"lan�amentos cont�beis como os saldos por conta, centro de custo, item e classe"
						 STR0005 + Chr(13) + Chr(10) ,; //"de valor, de acordo com a informa��o dos par�metros."
						 cProg,{|| ExeCtbm300(.T.) }, { || .F. })
	EndIf
Else
	aAdd(aSays, STR0002 )	// "Esta rotina tem como objetivo copiar um conjunto de lan�amentos ou saldos em um"
	aAdd(aSays, STR0003 )	// "tipo de saldo origem para um tipo de saldo destino. � poss�vel c�piar tanto os"
	aAdd(aSays, STR0004 )	// "lan�amentos cont�beis como dos saldos por conta, centro de custo, item e classe"
	aAdd(aSays, STR0005 )	// "de valor, de acordo com a sele��o do usu�rio."

	aAdd(aButt, { 5, .T., {|| Pergunte(cPerg,.T.) } } )
	aAdd(aButt, { 1, .T., {|| nOpca:= 1,IIf(VldCtbm300(.F.),FechaBatch(),nOpca:=0)}})
	aAdd(aButt, { 2, .T., {|| FechaBatch() }} )

	FormBatch(STR0001,aSays,aButt,,190) // Copia de saldos

	If nOpca == 1
		FWMsgRun(, {|oSay| ExeCtbm300(.F., oSay) }, STR0112, STR0113) // #"Processando" ##"Processando c�pia de saldos..."
	EndIf
EndIf

RestArea(aArea)

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ExeCtbm300�Autor  � Felipe Aurelio de Melo� Data � 17/11/08 ���
�������������������������������������������������������������������������͹��
���Descricao � Executa processo de copia de registros                     ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial - Movimentacoes                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ExeCtbm300(lAuto, oSay)

Local lAnalitico  := MV_PAR07 == 2 // 1=Sintetico / 2=Analitico
Local lTdsMoedas  := MV_PAR11 == 1 // 1=Totas     / 2=Especificar
Local dDataIni    := MV_PAR09     // Data Inicial
Local dDataFim    := MV_PAR10     // Data Final
Local lAtuSld1    := .F.          // Indicar se atualiza saldos apos o exclusao dos lancamentos
Local lAtuSld2    := .F.          // Indicar se atualiza saldos apos o gravacao de lancamentos de saldo
Local lAtuSld3    := .F.          // Indicar se atualiza saldos apos o gravacao de lancamentos de movimentos
Local lConfirma   := .F.          // Indicar se confirma exclusao dos lancamentos
Local cMsg        := ""
Local nX          := 0
Local lProcedure  := .F.
Local lRet        := .T.
Local nMaxLinha   := IIf(SuperGetMV("MV_NUMLIN")<1,999,CtbLinMax(GetMv("MV_NUMLIN")))
Local aDatabase	  :={}
Local cTDataBase  := ""
Local cTpSalDest  :=""
Local cAssProc    := EngSPS25Signature("25")
Local cMvsoma     := Str(SuperGetMV("MV_SOMA",.F.,1),1,0)
Default oSay := Nil

Private aResult   := {}

//Tratamento para caso usu�rio escolha
//metodo de copia = multiplos saldos 
If MV_PAR01 == 2
	MV_PAR02 := 2 //Sele��o dos saldos    = Mov. multi saldos
	MV_PAR05 := 1 //Metodo de copia       = Adicionar
	MV_PAR06 := 2 //Tipo de copia simples = Movimentos
	MV_PAR07 := 2 //Movimentos copiados   = Analiticos
	lAnalitico := .T.
EndIf

Do Case
	Case MV_PAR06 == 1  //Tipo de copia simples - saldos
		dDataIni := MV_PAR09
		dDataFim := MV_PAR10
	Case MV_PAR06 == 2  //Tipo de copia simples - movimentos
	    If lAnalitico
	    	dDataIni := MV_PAR09
	    Else
	    	dDataIni := MV_PAR10
	    EndIf
	Case MV_PAR06 == 3  //Tipo de copia simples - ambos
		dDataIni := MV_PAR09
EndCase
/*  O Processo sera executado via procedure nas situacoes abaixo
	1 - Copia simples de Movimentos ( Lancamentos ) com adicao de lancamentos
    2 - Copia de Multiplos Saldos
    3 - Se os cpos relativos a copia de multiplos saldos existir, CT2_CTLSLD, CT2_MLTSLD */

If TcSrvType() != 'AS/400'
	aadd(aDatabase,{"MSSQL" })
	aadd(aDatabase,{"MSSQL7" })
	aadd(aDatabase,{"ORACLE" })
	aadd(aDatabase,{"DB2" })
	aadd(aDatabase,{"SYBASE" })
//	aadd(aDatabase,{"INFORMIX" })
	If Trim(Upper(TcSrvType())) = "ISERIES"
		// Top 4 para AS400, instala procedures = DB2
		aadd(aDatabase,{"DB2/400"})
	EndIf
	cTDataBase = Trim(Upper(TcGetDb()))
	nPos:= Ascan( aDataBase, {|z| z[1] == cTDataBase })
	
	If nPos != 0 .and.;                           // bcos q instalam procedure
	  ((MV_PAR02 == 1 .and. mv_par05 == 1 .and. mv_par06 == 2 );  //copia simples, sem apagar lactos e de movitos, mv_par01=1, mv_par05=1,mv_par06=2
	   .or. mv_par02 == 2)                                       // copia Multiplos saldos   
		lProcedure := .T.
	EndIf
EndIf

//*Verificar se a rotina CTBA190 est� sendo executada
If !CT190ATUMV(dDataFim)
	If !isBlind()
		Help(" ", 1, "NOREPROC", , STR0115, 2, 0,,,,,,)//Existe uma execu��o do reprocessamento de saldos, aguarde o fim do processo. //Aten��o
	EndIF
	Return
EndIf

//*Valida��es para executar procedure
If lProcedure
	If SPSMigrated()//se j� est� usando o novo processo de procedures
		If !__lCTBM300 
			__oCTBM300	:= EngSPSStatus("25",cEmpAnt)
			__lCTBM300  := __oCTBM300["signature"] == cAssProc
			__cCTBM300	:= GetSPName("CTB301","25")
		EndIf
		//*Verifica se a procedure est� instalada e com mesma assinatura
		If __lCTBM300 
			//*Caso alguma das rotinas acima esteja em execu��o n�o permitir a execu��o da rotina via procedure.               
			If  CtbIsCube() .or. _lJobs  .or. ctb300val(MV_PAR03,MV_PAR04,dDataIni, dDataFim,lTdsMoedas,mv_par12)
			  lProcedure:= .F.
			Endif 
		EndIf	
	else
		lProcedure := .F. // execu��o em advpl
		If !isBlind()
			Help(" ", 1, "NOPROC25", , STR0116, 2, 0,,,,,,)//Para execu��o da procedure � necess�rio a instala��o do novo processo 25
		EndIF	
	EndIf
EndIF	
If lProcedure .and. __lCTBM300 //se regra de procedure e se est� com a mesma assinatura
		cTpSalDest := Trim(mv_par04)+"#"
		cTpSalDest := Strtran(StrTran(cTpSalDest,";"),"0")//tratamento para n�o ser enviado o tipo 0
		 MsgRun( STR0081+ STR0082, STR0083, {||aResult := TCSPExec( xProcedures(__cCTBM300),;  //"Processando, ""aguarde..", "Copia de Saldos"
						cFilAnt,;                         			// Filial corrente
						Dtos(dDataIni),;                        			// data inicio para o processo
						Dtos(dDataFim),;                        			// Data final para o processo
 						If(lTdsMoedas, "1", "0" ),;       			// '1' tds as moedas serao processadas, '0' moeda especifica
						If(lTdsMoedas,"00",Trim(mv_par12)),; 		//moeda a processar 
						cTpSalDest,;                 			//Tipos de saldos DESTINOS para copia simples
						MV_PAR01,;                       			//1 - Copia Simples , 2 - Multiplos Saldos
						MV_PAR03,;                       			//Tipo de saldo Origem
						MV_PAR13,;                       			//1-Mantem Lote e Sblote do Lancto Origem, 2 - pega do parametro
						MV_PAR16,;                       			//1 - Mantem historico do lancamento, 2 - Pegar historico do CT8 ( @IN_MVPAR17 )
						If(Empty(MV_PAR17), " ", Trim(MV_PAR17)),; //1 - Codigo do historico padrao usado para copia de lanctos CT8_HIST
						If(Empty(MV_PAR14), " ", Trim(MV_PAR14)),; //Lote do parametro
						If(Empty(MV_PAR15), " ", Trim(MV_PAR15)),; //Sblote
						nMaxLinha,;                                 // Nro maximo de linhas
						If( MV_PAR01 = 1, '1','0'),;// Se copias simples envio '1'
						cMvsoma	)})                //MV_SOMA
		If Empty(aResult) .Or. aResult[1] = "0"
			If !__lBlind
				MsgAlert(tcsqlerror(),STR0084)  //"Erro na Copia de Saldos!"
			EndIf
			lRet := .F.	
		EndIf                                                                    									
Else
	/* --------------------------------------------------------------------
		Execucao do processo sem as procedures
	   -------------------------------------------------------------------- */
	If MV_PAR05 == 2 .Or. MV_PAR05 == 3  // Metodo copia simples - 2=Sobrepor / 3=Apagar
		lConfirma := MsgYesNo( STR0101, STR0102 )
		If !lConfirma
			Return .T.
		EndIf

		lAtuSld1 := ApagaCtbm300( dDataIni, dDataFim, MV_PAR04, MV_PAR12, lTdsMoedas )
		If !lAtuSld1 .And. !lAuto
			Aviso( STR0006, STR0027, { "Ok" } )		//"N�o foram encontrados lan�amentos para exclus�o."
		EndIf
	EndIf
		
	If MV_PAR05 != 3
		Do Case
			// Gera lancamentos de saldo ateh a data
			Case MV_PAR06 == 1  //Tipo de copia simples - saldos
				lAtuSld2 := CTM300Proc( lAnalitico, .T., lTdsMoedas, MV_PAR08 )
				If !lAtuSld2 .And. !lAuto
					Aviso( STR0006, STR0028, { "Ok" } )		// "N�o foram encontrados lan�amentos de saldos at� a data inicial informada."
				EndIf
	
			// Gera lancamentos analiticos ou sinteticos (saldos) no periodo
			Case MV_PAR06 == 2  //Tipo de copia simples - movimentos
				lAtuSld3 := CTM300Proc( lAnalitico, .F., lTdsMoedas, MV_PAR08 )
				If !lAtuSld3 .And. !lAuto
					Aviso( STR0006, STR0026, { "Ok" } )		// "N�o foram encontrados movimentos no per�odo informado."
				EndIf
	
			// Gera lancamentos de saldo ateh a data e lancamentos analiticos ou sinteticos (saldos) no periodo
			Case MV_PAR06 == 3  //Tipo de copia simples - ambos
				lAtuSld2 := CTM300Proc( .F., .T., lTdsMoedas, MV_PAR08 )
				lAtuSld3 := CTM300Proc( lAnalitico, .F., lTdsMoedas, MV_PAR08 )
				If !lAtuSld2              	
					cMsg := STR0109 // "N�o foram encontrados lan�amentos de saldos sinteticos at� a data inicial informada."
				EndIf
				If !lAtuSld3
					cMsg := STR0024 //"N�o foram encontrados lan�amentos de saldos ou movimentos no per�odo informado."
				EndIf
				If !Empty(cMsg) .And. !lAuto
					Aviso( STR0006, cMsg, { "Ok" } )
				EndIf
		EndCase
	EndIf
	
	If lAtuSld1 .Or. lAtuSld2 .Or. lAtuSld3
		If !lAuto .And. oSay != Nil
			oSay:SetText(STR0114) // "Executando reprocessamento de saldos para os lan�amentos gerados..."
		EndIf

		If MV_PAR01 == 2
			// Tratamento para caso usu�rio escolha metodo de copia = multiplos saldos
			// Executa o reprocessamento de saldos para os lancamentos gerados
			CTBA190( .T., dDataIni, dDataFim,,,"*", (MV_PAR11 == 2), Iif( (MV_PAR11 == 2), MV_PAR12, "" ), .F. )
		Else
			// Executa o reprocessamento de saldos para os lancamentos gerados
			// N�o processar o saldo tipo 9 e tipo 0.
			cTpSalDest := alltrim(strtran(strtran(MV_PAR04,';'),'9'))
			For nX:=1 To len(cTpSalDest)
					CTBA190( .T., dDataIni, dDataFim,,,SubStr(cTpSalDest,nX,1), (MV_PAR11 == 2), Iif( (MV_PAR11 == 2), MV_PAR12, "" ), .F. )
			Next nX
		EndIf
	EndIf
EndIf	
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VldCtbm300�Autor  � Felipe Aurelio de Melo� Data � 17/11/08 ���
�������������������������������������������������������������������������͹��
���Descricao � Valida o preenchimento dos parametros da pergunta cPerg    ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial - Movimentacoes                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function VldCtbm300(lAuto)

Local x        := 1
Local lRet     := .T.
Local QtdParam := 18  

For x:=1 To QtdParam
	lRet := PrmCtbm300(StrZero(x,2))
	If !lRet
		x:=QtdParam
	EndIf
Next x

//Pergunta se confirma configuracoes dos parametros
If lRet .And. !lAuto
	lRet := CtbOk()
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PrmCtbm300�Autor  � Felipe Aurelio de Melo� Data � 17/11/08 ���
�������������������������������������������������������������������������͹��
���Descricao � Valida o preenchimento de cada parametro da pergunta cPerg ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial - Movimentacoes                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PrmCtbm300(cNumPar)

Local lRet    := .T.
Local cTexto1 := {}
Local cTexto2 := {}

Do Case
//----------------------------------------------------------
	Case cNumPar == "01"
		If lRet .And. Empty(MV_PAR01)
			ShowHelpDlg(STR0029, {STR0059,STR0076},5,{STR0046,STR0037},5) //"NAOVAZIO"###"O par�metro 'm�todo de c�pia' n�o foi"###"preenchido."###"Favor preencher o par�metro 'm�todo de"###"c�pia' com uma das op��es dispon�veis."   
			lRet := .F.
		EndIf
		If lRet .And. MV_PAR01 = 1
			MV_PAR02 := 1
		EndIf
		If lRet .And. MV_PAR01 = 2
			MV_PAR02 := 2
			MV_PAR05 := 1
			MV_PAR06 := 2
			MV_PAR07 := 2
		EndIf

//----------------------------------------------------------
	Case cNumPar == "02"
		If lRet .And. Empty(MV_PAR02)
			ShowHelpDlg(STR0029, {STR0065,STR0076},5,{STR0047,STR0078},5)//"NAOVAZIO"###"O par�metro 'sele��o dos saldos' n�o foi"###"preenchido."###"Favor preencher o par�metro 'sele��o dos"###"saldos' com uma das op��es dispon�veis."   
			lRet := .F.
		EndIf
		If lRet .And. MV_PAR01 = 1 .And. MV_PAR02 = 2
			cTexto1:= {STR0032,STR0079,STR0033,STR0050} //"A informa��o preenchida no par�metro"###"'sele��o dos saldos' n�o � compat�vel com"###"a informa��o preenchida no par�metro"###"'m�todo de copia'."
			cTexto2:= {STR0075,STR0035,STR0071,STR0069} //"Por escolher no par�metro 'm�todo de "###"copia' a op��o 'copia simples', no "###"par�metro 'sele��o dos saldos' dever�"###" optar por 'par�metros'."
			ShowHelpDlg(STR0030,cTexto1,5,cTexto2,5)//"INCOMPATIVEL"   
			lRet := .F.
		EndIf
		If lRet .And. MV_PAR01 = 2 .And. MV_PAR02 = 1
			cTexto1:= {STR0032,STR0079,STR0033,STR0050} //"A informa��o preenchida no par�metro"###"'sele��o dos saldos' n�o � compat�vel com"###"a informa��o preenchida no par�metro"###"'m�todo de copia'."
			cTexto2:= {STR0075,STR0036,STR0071,STR0068} //"Por escolher no par�metro 'm�todo de "###"copia' a op��o 'm�ltiplos saldos', no "###"par�metro 'sele��o dos saldos' dever�"###"optar por 'movimentos multi saldos'."
			ShowHelpDlg(STR0030,cTexto1,5,cTexto2,5)//"INCOMPATIVEL"  
			lRet := .F.
		EndIf
		
//----------------------------------------------------------
	Case cNumPar == "03"
		If lRet .And. MV_PAR01 = 1 .And. Empty(MV_PAR03)
			ShowHelpDlg(STR0029, {STR0063,STR0076},5,{STR0077,STR0048,STR0070},5) //"NAOVAZIO"###"O par�metro 'saldo origem' n�o foi","preenchido."###"Quando o par�metro 'm�todo de c�pia' est�"###"marcado como 'c�pia simples' este"###"par�metro passa a ser obrigat�rio."
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "04"
		If lRet .And. MV_PAR01 = 1 .And. Empty(MV_PAR04)
			ShowHelpDlg(STR0029, {STR0064,STR0076},5,{STR0077,STR0048,STR0070},5) //"NAOVAZIO"###"O par�metro 'saldos destinos' n�o foi"###"preenchido."###"Quando o par�metro 'm�todo de c�pia' est�"###"marcado como 'c�pia simples' este"###"par�metro passa a ser obrigat�rio."   
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "07"
		If lRet .And. MV_PAR07 = 1 .And. MV_PAR16 = 1 
			ShowHelpDlg(STR0029, {STR0053,STR0110},5,{STR0045,STR0111,STR0073,STR0061,STR0041},5) //"NAOVAZIO"###"O par�metro "###"hist�rico padr�o n�o pode ser Mante"###"Favor preencher o par�metro em quest�o,"###" com o conteudo de especificar hist�rico"###"pois o mesmo � obrigatorio quando"###"o parametro 'movimentos copiados'"###"esta marcado como 'sint�tico'."   
			lRet := .F.
		EndIf
		If lRet .And. MV_PAR01 = 1 .And. MV_PAR07 = 1 .And. Empty(MV_PAR17)
			ShowHelpDlg(STR0029, {STR0053,STR0034,STR0052},5,{STR0045,STR0073,STR0061,STR0041},5) //"NAOVAZIO"###"O par�metro "###"'c�digo de hist�rico padr�o'"###" n�o foi preenchido."###"Favor preencher o par�metro em quest�o,"###"pois o mesmo � obrigatorio quando"###"o parametro 'movimentos copiados'"###"esta marcado como 'sint�tico'."   
			MV_PAR16 := 2
			lRet := .T.
		EndIf
//----------------------------------------------------------
	Case cNumPar == "06"
		If lRet .And. MV_PAR01 = 1 .And. MV_PAR06 = 3 .And.  MV_PAR16 == 2 .And. Empty(MV_PAR17)
			ShowHelpDlg(STR0029, {STR0053,STR0034,STR0052},5,{STR0045,STR0073,STR0061,STR0041},5) //"NAOVAZIO"###"O par�metro "###"'c�digo de hist�rico padr�o'"###" n�o foi preenchido."###"Favor preencher o par�metro em quest�o,"###"pois o mesmo � obrigatorio quando"###"o parametro 'movimentos copiados'"###"esta marcado como 'sint�tico'."   
			lRet := .F.
		EndIf
				
//----------------------------------------------------------
	Case cNumPar == "09"
		If lRet .And. Empty(MV_PAR09)
			ShowHelpDlg(STR0029, {STR0055,STR0076},5,{STR0045,STR0074},5) //"NAOVAZIO"###"O par�metro 'data inicial' n�o foi"###"preenchido."###"Favor preencher o par�metro em quest�o,"###"pois o mesmo � obrigatorio."   
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "10"
		If lRet .And. Empty(MV_PAR10)
			ShowHelpDlg(STR0029, {STR0054,STR0076},5,{STR0045,STR0074},5) //"NAOVAZIO"###"O par�metro 'data final' n�o foi","preenchido."###"Favor preencher o par�metro em quest�o,"###"pois o mesmo � obrigatorio."
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "12"
		If lRet .And. MV_PAR11 = 2 .And. Empty(MV_PAR12)
			ShowHelpDlg(STR0029, {STR0062,STR0076},5,{STR0045,STR0073,STR0060,STR0039},5)//"NAOVAZIO"###"O par�metro 'qual moeda' n�o foi","preenchido."###"Favor preencher o par�metro em quest�o,"###"pois o mesmo � obrigatorio quando"###"o parametro 'moeda' esta marcado como"###"'especificar'."   
			lRet := .F.
		EndIf
		If lRet .And. !Empty(MV_PAR12)
			CTO->(DbSetOrder(1))
			If CTO->(!DbSeek(xFilial("CTO")+MV_PAR12))
				ShowHelpDlg(STR0031, {STR0067},5,{STR0043},5) //"NAOEXISTE"###"O registro escolhido n�o existe."###"Favor escolher um registro existente."
				lRet := .F.
			EndIf
		EndIf

//----------------------------------------------------------
	Case cNumPar == "14"
		If lRet .And. MV_PAR13 = 2 .And. Empty(MV_PAR14)
			ShowHelpDlg(STR0029, {STR0057,STR0052},5,{STR0045,STR0073,STR0058,STR0040},5)//"NAOVAZIO"###"O par�metro 'lote cont�bil'"###"n�o foi preenchido."###"Favor preencher o par�metro em quest�o,"###"pois o mesmo � obrigatorio quando"###"o parametro 'lote e sub-lote cont�bil'"###"esta marcado como 'especificar'."   
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "15"
		If lRet .And. MV_PAR13 = 2 .And. Empty(MV_PAR15)
			ShowHelpDlg(STR0029, {STR0066,STR0052},5,{STR0045,STR0073,STR0058,STR0040},5)//"NAOVAZIO"###"O par�metro 'sub-lote cont�bil'"###" n�o foi preenchido."###"Favor preencher o par�metro em quest�o,"###"pois o mesmo � obrigatorio quando"###"o parametro 'lote e sub-lote cont�bil'"###"esta marcado como 'especificar'."   
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "17"
		If lRet .And. MV_PAR16 = 2 .And. Empty(MV_PAR17)
			ShowHelpDlg(STR0029, {STR0053,STR0034,STR0052},5,{STR0045,STR0073,STR0056,STR0040},5)//"NAOVAZIO"###"O par�metro "###"'c�digo de hist�rico padr�o'"###" n�o foi preenchido."###"Favor preencher o par�metro em quest�o,"###"pois o mesmo � obrigatorio quando"###"o parametro 'hist�rico padr�o'"###"esta marcado como 'especificar'."   
			lRet := .F.
		EndIf
		If lRet .And. !Empty(MV_PAR17)
			CT8->(DbSetOrder(1))
			If CT8->(!DbSeek(xFilial("CT8")+MV_PAR17))
				ShowHelpDlg(STR0031, {STR0067},5,{STR0043},5) //"NAOEXISTE"###"O registro escolhido n�o existe."###"Favor escolher um registro existente."
				lRet := .F.
			EndIf
		EndIf
		If lRet .And. MV_PAR01 = 1 .And. MV_PAR07 = 1 .And. Empty(MV_PAR17)
			ShowHelpDlg(STR0029, {STR0053,STR0034,STR0052},5,{STR0045,STR0073,STR0061,STR0041},5)//"NAOVAZIO"###"O par�metro "###"'c�digo de hist�rico padr�o'"###" n�o foi preenchido."###"Favor preencher o par�metro em quest�o,"###"pois o mesmo � obrigatorio quando"###"o parametro 'movimentos copiados'"###"esta marcado como 'sint�tico'."   
			MV_PAR16 := 2
			lRet := .F.
		EndIf


//----------------------------------------------------------
EndCase

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ApagaCtbm300 � Autor � Gustavo Henrique      �Data�28/12/06���
�������������������������������������������������������������������������͹��
���Descricao � Exclui os lancamnetos da tabela CT2                        ���
�������������������������������������������������������������������������͹��
���Parametros� EXPD1 - Data inicial para exclusao dos lancamentos         ���
���          � EXPD2 - Data final para exclusao dos lancamentos           ���
���          � EXPC3 - Tipo de saldo de destino para selecao dos lanctos. ���
���          � EXPC4 - Indica se processa todas as moedas ou especifica   ���
���          � EXPC5 - Moeda informada para selecao dos lancamentos       ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ApagaCtbm300( dDataIni, dDataFim, cTpSaldo, cMoeda, lTodas )
         
Local lRet		:= .T.         
                              
Local cArqTrb	:= ""
Local cIndex1	:= ""
Local cIndex2	:= ""

Local aKeyCTF	:= {}
Local aArea		:= GetArea()
Local aAreaCT2	:= CT2->(GetArea())
Local aAreaCTF	:= CTF->(GetArea())
Local aCampos  := {{ "NUMREC", "N", 17, 0 } , { "MOEDLC", "C", 2, 0 }}

If _oCtbm3001 <> Nil
	_oCtbm3001:Delete()
	_oCtbm3001 := Nil
Endif

_oCtbm3001 := FWTemporaryTable():New( "TRB" )  
_oCtbm3001:SetFields(aCampos) 
_oCtbm3001:AddIndex("1", {"MOEDLC"})

//------------------
//Cria��o da tabela temporaria
//------------------
_oCtbm3001:Create()  

Processa( { || lRet := SelLancCtbm300( dDataIni, dDataFim, cTpSaldo, cMoeda, lTodas ) },, STR0025 ) //"Selecionando lan�amentos para exclus�o..."
                       
If lRet
	Processa( { || PrcExclCtbm300( lTodas, cMoeda ) },, STR0015 )	//Excluindo lan�amentos no tipo de saldo de destino...
EndIf	

TRB->( dbCloseArea() )

//Deleta a tabela temporaria no banco de dados
If _oCtbm3001 <> Nil
	_oCtbm3001:Delete()
	_oCtbm3001 := Nil
Endif

RestArea( aArea )

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SelLancCtbm300�Autor � Gustavo Henrique   � Data � 28/12/06 ���
�������������������������������������������������������������������������͹��
���Descricao � Seleciona os numeros de RECNO dos lancamentos contabeis no ���
���          � tipo de saldo de origem, para gravacao posterior no tipo   ���
���          � de saldo de destino selecionado nos parametros.            ���
�������������������������������������������������������������������������͹��
���Parametros� EXPD1 - Data inicial do periodo para selecao dos lanctos.  ���
���          � EXPD2 - Data final do periodo para selecao dos lanctos.    ���
���          � EXPC3 - Tipo de saldo de origem para selecao dos lanctos.  ���
���          � EXPC4 - Moeda especifica caso informado "Especifico" no    ���
���          �         parametro "Qual Moeda"                             ���
���          � EXPC5 - Indica se devem ser selecionadas todas as moedas   ���
���          �         ou apenas uma moeda especifica.                    ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function SelLancCtbm300( dDataIni, dDataFim, cTpSald, cMoeda, lTodas )
          
Local aArea		:= GetArea()
                      
Local cFilCT2	:= xFilial("CT2")
Local cDataIni	:= DtoS(dDataIni)
Local cDataFim	:= DtoS(dDataFim)
Local cQuery	:= ""

Local nCont		:= 0

Local lGrava	:= .T.
Local lPosMoeda	:= TRB->( FieldPos("MOEDLC") ) > 0
Local lRet

CT2->( dbSetOrder( 1 ) )

cQuery := "SELECT COUNT(R_E_C_N_O_) TOTREC "
cQuery += "  FROM " + RetSqlName("CT2") + " " 
cQuery += " WHERE CT2_FILIAL = '" + cFilCT2 + "' "
cQuery += "   AND CT2_DATA BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "

If Len( Alltrim(cTpSald)) == 1
	cQuery += "   AND CT2_TPSALD = '" + Alltrim( cTpSald ) + "'"
Endif

cQuery += "   AND CT2_CTLSLD <> '0'"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBCT2",.T.,.F.)
nCont := TRBCT2->TOTREC
dbCloseArea()
dbSelectArea("CT2")
                          
ProcRegua( nCont )
                                                 
CT2->( MsSeek( cFilCT2 + cDataIni, .T. ) )

Do While CT2->( !EoF() .And. CT2_FILIAL == cFilCT2 .And. DtoS(CT2_DATA) <= cDataFim)
	IncProc()                                                                       

	If CT2_CTLSLD == '0'	
		CT2->( dbSkip() )
		Loop	
	Endif 

	If CT2->CT2_TPSALD $ cTpSald
		If !lTodas   
			If cMoeda == "01"
				lGrava := (CT2->CT2_MOEDLC == cMoeda)
			Else
				lGrava := CT2->( (CT2_MOEDLC == cMoeda .Or. CT2_MOEDLC == "01") )
			EndIf	
		EndIf
		If lGrava
			RecLock( "TRB", .T. )
			TRB->NUMREC := CT2->( Recno() )
			If lPosMoeda
				TRB->MOEDLC := CT2->CT2_MOEDLC
			EndIf	
			TRB->( MsUnlock() )
		EndIf	
	EndIf	

    If MV_PAR18 == 1
		RecLock( "CT2", .F. )
		CT2->CT2_CTLSLD := "0"
		CT2->( MsUnLock() )
    EndIf

	CT2->( dbSkip() )

EndDo
              
TRB->( dbGoTop() )

lRet := TRB->(!EoF())

RestArea( aArea )

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PrcExclCtbm300�Autor � Gustavo Henrique �Data �  15/01/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Processa exclusao dos lancamentos gravados na tabela CT2   ���
���          � a partir do tipo de saldo destino informado nos parametros ���
�������������������������������������������������������������������������͹��
���Parametros� EXPL1 - Indica se deve processar todas as moedas           ���
���          � EXPC2 - Caso moeda especifica, recebe a moeda informada nos���
���          �         parametros.                                        ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PrcExclCtbm300( lTodas, cMoeda )

Local lOutMoeda := .F.

ProcRegua( TRB->(LastRec()) )

// Processa primeiro a exclusao das outras moedas
If lTodas .Or. (!lTodas .And. cMoeda <> "01")
	lOutMoeda := .T.
EndIf

TRB->(dbGoTop())
Do While TRB->(!EoF())

	IncProc()                

	//Se moeda escolhida for diferente de "01" ou se foi selecionada todas as moedas, primeiro excluir as outras moedas e pula quando for moeda "01"
	If lOutMoeda .AND. TRB->MOEDLC == "01" 
		TRB->( dbSkip() )		
	Endif

	CT2->( dbGoTo( TRB->NUMREC ) )
	If __lConOutR
		ConoutR( '1. Posicionou: ' + StrZero( TRB->NUMREC,10 ) + "|" + CT2->(  Strzero(Recno(),10) + "|" + Dtos( CT2_DATA ) + "|" + CT2_LOTE + "|" + CT2_SBLOTE + "|" + CT2_DOC + "|" + CT2_LINHA + "|" + CT2_DC + "|" + CT2_MOEDLC + "|TPSALD " + CT2_TPSALD + "|" + CT2_SEQLAN ) )
	EndIf

	CT2->( GravaLanc(CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_DC,CT2_MOEDLC,CT2_HP,CT2_DEBITO,;
			CT2_CREDIT,CT2_CCD,CT2_CCC,CT2_ITEMD,CT2_ITEMC,CT2_CLVLDB,CT2_CLVLCR,CT2_VALOR,CT2_HIST,;
			CT2_TPSALD,CT2_SEQLAN,5,.F.,,CT2_EMPORI,CT2_FILORI,,,,,,,.F. ) )

	If __lConOutR
		ConoutR( '1. Depois de excluir: ' + StrZero( TRB->NUMREC,10 ) + "|" + CT2->(  Strzero(Recno(),10) + "|" + Dtos( CT2_DATA ) + "|" + CT2_LOTE + "|" + CT2_SBLOTE + "|" + CT2_DOC + "|" + CT2_LINHA + "|" + CT2_DC + "|" + CT2_MOEDLC + "|TPSALD " + CT2_TPSALD + "|" + CT2_SEQLAN ) )
	EndIf

	TRB->( dbSkip() )

	If __lConOutR
		ConoutR( '1. Depois do skip: ' + StrZero( TRB->NUMREC,10 ) + "|" + CT2->( Strzero(Recno(),10) + "|" + Dtos( CT2_DATA ) + "|" + CT2_LOTE + "|" + CT2_SBLOTE + "|" + CT2_DOC + "|" + CT2_LINHA + "|" + CT2_DC + "|" + CT2_MOEDLC + "|TPSALD " + CT2_TPSALD + "|" + CT2_SEQLAN ) )
	EndIf
EndDo
                         
// Processa exclusao da moeda 01 para excluir chave da tabela CTF
If lTodas .Or. ( !lTodas .And. cMoeda <> "01" )
	TRB->( dbGoTop() )
	Do While TRB->(!EoF())
	
		IncProc()                     

		//Somente continua se a moeda for "01"
		If TRB->MOEDLC <> "01" 
			TRB->( dbSkip() )		
		Endif

		CT2->( dbGoTo( TRB->NUMREC ) )  

		If __lConOutR
			ConoutR( '2. Posicionou: ' + CT2->(  StrZero( TRB->NUMREC,10 ) + "|" + Strzero(Recno(),10) + "|" + Dtos( CT2_DATA ) + "|" + CT2_LOTE + "|" + CT2_SBLOTE + "|" + CT2_DOC + "|" + CT2_LINHA + "|" + CT2_DC + "|" + CT2_MOEDLC + "|TPSALD " + CT2_TPSALD + "|" + CT2_SEQLAN ) )
		endIf
		
		CT2->( GravaLanc(CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_DC,CT2_MOEDLC,CT2_HP,CT2_DEBITO,;
				CT2_CREDIT,CT2_CCD,CT2_CCC,CT2_ITEMD,CT2_ITEMC,CT2_CLVLDB,CT2_CLVLCR,CT2_VALOR,CT2_HIST,;
				CT2_TPSALD,CT2_SEQLAN,5,.F.,,CT2_EMPORI,CT2_FILORI,,,,,,,.F. ) )    
				
		If __lConOutR
			ConoutR( '2. Depois de excluir: ' + CT2->(  StrZero( TRB->NUMREC,10 ) + "|" + Strzero(Recno(),10) + "|" + Dtos( CT2_DATA ) + "|" + CT2_LOTE + "|" + CT2_SBLOTE + "|" + CT2_DOC + "|" + CT2_LINHA + "|" + CT2_DC + "|" + CT2_MOEDLC + "|TPSALD " + CT2_TPSALD + "|" + CT2_SEQLAN ) )
		EndIf
		
		TRB->( dbSkip() )  
		
		If __lConOutR
			ConoutR( '2. Depois do skip: ' + CT2->(  StrZero( TRB->NUMREC,10 ) + "|" + Strzero(Recno(),10) + "|" + Dtos( CT2_DATA ) + "|" + CT2_LOTE + "|" + CT2_SBLOTE + "|" + CT2_DOC + "|" + CT2_LINHA + "|" + CT2_DC + "|" + CT2_MOEDLC + "|TPSALD " + CT2_TPSALD + "|" + CT2_SEQLAN ) )
		EndIf
	EndDo
EndIf

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CTM300Proc � Autor � Gustavo Henrique � Data �  15/01/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Gera lancamentos contabeis no tipo de saldo de destino a   ���
���          � partir dos movimentos ou saldos no tipo de saldo de origem ���
�������������������������������������������������������������������������͹��
���Parametros� EXPL1 - Indica se o processamento eh analitico (de CT2 para���
���          � CT2) ou sintetico (de CT7,CQ3,CQ5 ou CQ7) para CT2.        ���
���          � EXPL2 - Indica se deve processar saldo ou movimento.       ���
���          � EXPL3 - Indica se processa todas as moedas ou especifica.  ���
���          � EXPN4 - A partir de que nivel deve compor os lancamentos.  ���
���          � Utilizado apenas para processamento sintetico.             ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CTM300Proc( lAnalitico, lSaldo, lTodas, nNivel )
                                    
Local aArea		:= GetArea()
Local aAreaCT2	:= CT2->( GetArea() )
Local aAreaCQ1	:= CQ1->( GetArea() )
Local aCtaProc	:= {}
Local aCampos	:= {}                  
Local aStruct	:= {} 
Local aTamVlr	:= TamSX3("CQ1_DEBITO")

Local cArqTrb	:= ""
Local cArqInd1	:= ""
Local cArqInd2	:= ""
Local cMsgProc	:= ""   

Local lClVl		:=	CtbMovSaldo("CTH")
Local lItem		:=	CtbMovSaldo("CTD")
Local lCusto	:= CtbMovSaldo("CTT")
Local lRet		:= .T.

If lAnalitico

	//���������������������������������������������������������������������������������������Ŀ
	//� Executa selecao e gravacao dos movimentos analiticos (CT2 para CT2)					  �
	//�����������������������������������������������������������������������������������������
	AAdd( aStruct, { "NUMREC", "N", 17, 0 }  )

	If _oCtbm3002 <> Nil
		_oCtbm3002:Delete()
		_oCtbm3002 := Nil
	Endif
	
	_oCtbm3002 := FWTemporaryTable():New( "TRB" )  
	_oCtbm3002:SetFields(aStruct) 
	_oCtbm3002:AddIndex("1", {"NUMREC"})
				
	//------------------
	//Cria��o da tabela temporaria
	//------------------
	_oCtbm3002:Create()


	Processa( { || lRet := CTM300SelLanc( mv_par09, mv_par10, mv_par03, mv_par12, lTodas ) },, STR0020 )
	If lRet
		Processa( { || CTM300GrvLanc( lTodas, mv_par12 ) },, STR0021 )	// "Gravando lan�amentos no tipo de saldo destino..."
	EndIf	
	dbSelectArea( "CT2" )
	TRB->( dbCloseArea() )

	If _oCtbm3002 <> Nil
		_oCtbm3002:Delete()
		_oCtbm3002 := Nil
	Endif

Else	// Sinteticos

	//���������������������������������������������������������������������������������������Ŀ
	//� Executa selecao e gravacao dos saldos e/ou movimentos sinteticos (CQ1, CQ3, CQ5, CQ7) �
	//�����������������������������������������������������������������������������������������
	aCampos := {{"IDENT"    ,"C", 3, 0},;
               {"CONTA"    ,"C",Len(CriaVar("CT1_CONTA")),0},;
               {"CUSTO"    ,"C",Len(CriaVar("CTT_CUSTO")),0},;
               {"ITEM"     ,"C",Len(CriaVar("CTD_ITEM")),0},;
               {"CLVL"     ,"C",Len(CriavAr("CTH_CLVL")),0},;
               {"CREDIT"   ,"N",aTamVlr[1],aTamVlr[2]},;
               {"DEBITO"   ,"N",aTamVlr[1],aTamVlr[2]},;
               {"TPSALDO"  ,"C",1,0},;
               {"MOEDA"    ,"C",2,0}}

	If _oCtbm3002 <> Nil
		_oCtbm3002:Delete()
		_oCtbm3002 := Nil
	Endif
	
	_oCtbm3002 := FWTemporaryTable():New( "TRB" )  
	_oCtbm3002:SetFields(aCampos) 
	_oCtbm3002:AddIndex("1", {"TPSALDO","MOEDA","CONTA","CUSTO","ITEM","CLVL","IDENT"})
	_oCtbm3002:AddIndex("2", {"TPSALDO","MOEDA","IDENT","CONTA","CUSTO","ITEM","CLVL"})
				
	//------------------
	//Cria��o da tabela temporaria
	//------------------
	_oCtbm3002:Create()
    
	//��������������������������������������������������������������������������������Ŀ
	//� Gera lancamentos temporarios no tipo de saldo de origem e no nivel selecionado �
	//� na pergunta "Ate o nivel?". 1=Conta; 2=C.Custo; 3=Item; 4=Classe               �
	//����������������������������������������������������������������������������������
	If lClVl .And. nNivel == 4
		cMsgProc := STR0011 + RTrim(CtbSayApro("CTH")) + " ..."	// Selecionando saldos por Classe
		Processa( { ||	CTM300SelSint( lSaldo, "CQ7", mv_par09, mv_par10, mv_par12, mv_par03, lCusto, lItem, lClvl, lTodas, nNivel ) },, cMsgProc )
	EndIf
	
	If lItem .And. nNivel >= 3	
		cMsgProc := STR0011 + RTrim(CtbSayApro("CTD")) + " ..."	// Selecionando saldos por Item
		Processa( { || CTM300SelSint( lSaldo, "CQ5", mv_par09, mv_par10, mv_par12, mv_par03, lCusto, lItem, lClvl, lTodas, nNivel ) },, cMsgProc )
	EndIf
	
	If lCusto .And. nNivel >= 2	
		cMsgProc := STR0011 + RTrim(CtbSayApro("CTT")) + " ..." 	// Selecionando saldos por C.Custo ...
		Processa( { || CTM300SelSint( lSaldo, "CQ3", mv_par09, mv_par10, mv_par12, mv_par03, lCusto, lItem, lClvl, lTodas, nNivel ) },, cMsgProc )
	EndIf
	
	cMsgProc := STR0011 + STR0023 + " ..."	// Selecionando saldos por Conta ...
	Processa( { || CTM300SelSint( lSaldo, "CQ1", mv_par09, mv_par10, mv_par12, mv_par03, lCusto, lItem, lClvl, lTodas, nNivel ) },, cMsgProc )	
                     
	TRB->( dbGoTop() )
	lRet := TRB->( !EoF() )
	
	If lRet

		//��������������������������������������������������������������������������������Ŀ
		//� Calcula a data para gravacao dos lancamentos na tabela CT2                     �
		//����������������������������������������������������������������������������������
		If lSaldo
			dDataLanc := mv_par09 - 1	// Dia anterior a data inicial informada 
		Else
			dDataLanc := mv_par10		// Data final do periodo informado
		EndIf		

		//��������������������������������������������������������������������������������Ŀ
		//� Gera lancamentos contabeis no tipo de saldo de destino                         �
		//����������������������������������������������������������������������������������
		Processa( { || CTM300GrvSint( dDataLanc, mv_par14, mv_par15, mv_par12, mv_par04, mv_par17 ) },, STR0021 )	// Gravando lan�amentos no tipo de saldo destino...	
		
	EndIf	

	dbSelectArea("TRB")
	dbCloseArea()

	If _oCtbm3002 <> Nil
		_oCtbm3002:Delete()
		_oCtbm3002 := Nil
	Endif

	dbSelectArea("CT2")

EndIf

RestArea( aArea )
RestArea( aAreaCT2 )
RestArea( aAreaCQ1 )

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBM300SelLanc�Autor � Gustavo Henrique   � Data � 28/12/06 ���
�������������������������������������������������������������������������͹��
���Descricao � Seleciona os numeros de RECNO dos lancamentos contabeis no ���
���          � tipo de saldo de origem, para gravacao posterior no tipo   ���
���          � de saldo de destino selecionado nos parametros.            ���
�������������������������������������������������������������������������͹��
���Parametros� EXPD1 - Data inicial do periodo para selecao dos lanctos.  ���
���          � EXPD2 - Data final do periodo para selecao dos lanctos.    ���
���          � EXPC3 - Tipo de saldo de origem para selecao dos lanctos.  ���
���          � EXPC4 - Moeda especifica caso informado "Especifico" no    ���
���          �         parametro "Qual Moeda"                             ���
���          � EXPC5 - Indica se devem ser selecionadas todas as moedas   ���
���          �         ou apenas uma moeda especifica.                    ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CTM300SelLanc( dDataIni, dDataFim, cTpSald, cMoeda, lTodas )
          
Local aArea		:= GetArea()
                      
Local cFilCT2	:= xFilial("CT2")
Local cDataIni	:= DtoS(dDataIni)
Local cDataFim	:= DtoS(dDataFim)
Local cQuery	:= ""

Local nCont		:= 0

Local lGrava	:= .T.
Local lPosMoeda	:= TRB->( FieldPos("MOEDLC") ) > 0
Local lRetLanc

CT2->( dbSetOrder( 1 ) )

cQuery := "SELECT COUNT(R_E_C_N_O_) TOTREC "
cQuery += "FROM " + RetSqlName("CT2") + " " 
cQuery += "WHERE "
cQuery += "    CT2_FILIAL = '" + cFilCT2 + "' "
cQuery += "AND CT2_DATA BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBCT2",.T.,.F.)
nCont := TRBCT2->TOTREC
dbCloseArea()
dbSelectArea("CT2")
                          
ProcRegua( nCont )

CT2->( MsSeek( cFilCT2 + cDataIni, .T. ) )

Do While CT2->( !EoF() .And. CT2_FILIAL == cFilCT2 .And. DtoS(CT2_DATA) <= cDataFim )
	IncProc()
	If CT2->CT2_TPSALD $ cTpSald
		If !lTodas   
			If cMoeda == "01"
				lGrava := (CT2->CT2_MOEDLC == cMoeda)
			Else
				lGrava := CT2->( (CT2_MOEDLC == cMoeda .Or. CT2_MOEDLC == "01") )
			EndIf	
		EndIf
		If lGrava
			RecLock( "TRB", .T. )
			TRB->NUMREC := CT2->( Recno() )
			If lPosMoeda
				TRB->MOEDLC := CT2->CT2_MOEDLC
			EndIf	
			TRB->( MsUnlock() )
		EndIf	
	EndIf	
	CT2->( dbSkip() )
EndDo
              
TRB->( dbGoTop() )

lRetLanc := TRB->(!EoF())

RestArea( aArea )

Return lRetLanc

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBM300GrvLanc�Autor � Gustavo Henrique � Data � 28/12/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Grava lancamentos analiticos a partir dos registros que jah���
���          � foram gravados em arquivo temporario.                      ���
�������������������������������������������������������������������������͹��
���Parametros� EXPL1 - Indica se deve processar todas as moedas           ���
���          � EXPC2 - Caso moeda especifica, recebe a moeda informada nos���
���          �         parametros.                                        ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CTM300GrvLanc( lTodas, cMoeda )

Local nX		   := 0
Local nInc		:= 0
Local nCpos		:= CT2->(FCount())
Local CTF_LOCK	:= 0
Local nPosLinha:= 0
Local nPosLote	:= 0
Local nPosSLote:= 0
Local nPosDoc	:= 0
Local nPosTPSal:= 0
Local nPosCtSal:= 0
Local cLote		:= ""
Local cSubLote	:= ""
Local cDoc		:= ""
Local cDocOri	:= ""
Local cLoteOri	:= ""
Local cDataOri	:= ""
Local cTpSldOri:= ""
Local cMtSldOri:= ""
Local lSemValor:= (!lTodas .And. cMoeda <> "01")
Local cHistPadr:= IIf(MV_PAR16=1,"",MV_PAR17)
Local aDadosCT2:= {}
Local aTpSaldos:= {}
Local lMltSaldos:= .F.
Local lFirst := .T.
Local nLinha := 1
Local cLinha := StrZero(nLinha,3)
Local cLinIncl := cLinha
Local dDtLanc:= StoD("")
Local nMaxLinha:= IIf(SuperGetMV("MV_NUMLIN")<1,999,CtbLinMax(SuperGetMv("MV_NUMLIN")))
Local cUltLanc := ""
Local cTpSalDest := alltrim(strtran(MV_PAR04,';'))

aDadosCT2 := Array(nCpos)
		
nPosHP     := CT2->( FieldPos( "CT2_HP" ) )
nPosHist   := CT2->( FieldPos( "CT2_HIST" ) )
nPosLinha  := CT2->( FieldPos( "CT2_LINHA" ) )
nPosLote   := CT2->( FieldPos( "CT2_LOTE" ) )
nPosSLote  := CT2->( FieldPos( "CT2_SBLOTE" ) )
nPosDoc    := CT2->( FieldPos( "CT2_DOC" ) )
nPosTPSal  := CT2->( FieldPos( "CT2_TPSALD" ) )
nPosValor  := CT2->( FieldPos( "CT2_VALOR" ) )
nPosCtSal  := CT2->( FieldPos( "CT2_CTLSLD" ) )
nPosRecno  := CT2->( FieldPos( "R_E_C_N_O_" ) )

lMltSaldos := MV_PAR01==2

//DbSelectArea( "CT2" )
//DbGoTop()

DbSelectArea( "TRB" )
ProcRegua( TRB->(LastRec()))
		
TRB->( dbGoTop() )                          
	    
Do While TRB->(!EoF())

	IncProc()                  

	// Volta ao registro de origem 		        
    CT2->( dbGoTo( TRB->NUMREC ) )
    

    If MV_PAR18 == 1 .OR. MV_PAR05 == 2
		RecLock( "CT2", .F. )
		CT2->CT2_CTLSLD := "0"
		CT2->( MsUnLock() )
    EndIf

	//����������������������������������������������������������������������Ŀ
	//�se o parametro (Multiplos Tipos de Saldos) for igual a desconsidera   �
	//�entao deve seguir o fluxo normal.                                     �
	//�                                                                      �
	//�se controla deve copiar para todos os tipos de saldos escolhidos.     �
	//������������������������������������������������������������������������
	If MV_PAR01 == 1

		cTpSldOri := AllTrim(CT2->CT2_TPSALD) //Variavel criada para comparar com registro a ser criado
		cMtSldOri := AllTrim(StrTran(StrTran(CT2->CT2_MLTSLD,";",""),cTpSldOri,"")) //Variavel criada para tratar um possivel erro

		If (CT2->CT2_CTLSLD == "0" .Or. Empty(CT2->CT2_CTLSLD)) .And. Empty(cMtSldOri)

			// Atualiza o status de copia do lancamento de origem
			RecLock( "CT2", .F. )
			CT2->CT2_CTLSLD := "2"
			CT2->( MsUnLock() )

			If cDataOri+cDocOri+cLoteOri != CT2->(DtoS(CT2_DATA)+CT2_DOC+CT2_LOTE) .Or. nLinha > nMaxLinha
				// Atualiza numeracao de lote, sub-lote e documento
				If MV_PAR13 = 1
					cLote    := CT2->CT2_LOTE
					cSubLote := CT2->CT2_SBLOTE
				Else
					cLote		:= IIf(Empty(cLote)   ,mv_par14,cLote)
					cSubLote	:= IIf(Empty(cSubLote),mv_par15,cSubLote)
				EndIf
				cDataOri:= DtoS(CT2->CT2_DATA)
				cDocOri := CT2->CT2_DOC
				cLoteOri:= CT2->CT2_LOTE

				cDoc    := CT2->CT2_DOC
				dDtLanc := CT2->CT2_DATA
				lFirst  := .T.
			EndIf

			//tratamento para N�O gerar CT2 com saldo 0
			cTpSalDest := alltrim(strtran(cTpSalDest,'0')) 
			For nInc := 1 To Len(cTpSalDest)
				If SubStr(cTpSalDest,nInc,1) == AllTrim(cTpSldOri)
					Loop
				EndIf
				
				If lFirst .Or. nLinha > nMaxLinha
					CTM300ProxDoc(dDtLanc,cLote,cSubLote,@cDoc,@CTF_LOCK)
					If MV_PAR13 = 1
						cLote    := IIf(Empty(cLote)   ,Soma1(Space(TamSx3("CT2_LOTE")[1]))  ,cLote)    //CT2->CT2_LOTE
						cSubLote := IIf(Empty(cSubLote),Soma1(Space(TamSx3("CT2_SBLOTE")[1])),cSubLote) //CT2->CT2_SBLOTE
					Else
						cLote		:= IIf(Empty(cLote)   ,mv_par14,cLote)
						cSubLote	:= IIf(Empty(cSubLote),mv_par15,cSubLote)
					EndIf
					lFirst := .F.
					nLinha := 1
					cLinha := StrZero(nLinha,3)
				Else
					If cUltLanc != CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)
						nLinha ++
						cLinha := Soma1(cLinIncl)
					EndIf	
				EndIf

				// Copia os campos padrao da tabela de lancamentos contabeis (CT2)
				For nX := 1 To nCpos
					If nX <> nPosTpSal
						aDadosCT2[nX] := CT2->(FieldGet(nX))
					EndIf
				Next nX
				
				aDadosCT2[nPosLote]  := cLote
				aDadosCT2[nPosSLote] := cSubLote
				aDadosCT2[nPosDoc]   := cDoc
				aDadosCT2[nPosTPSal] := SubStr(cTpSalDest,nInc,1)
				aDadosCT2[nPosCtSal] := "2"							// Geracao Off-Line - Controle de Copia
				aDadosCT2[nPosLinha] := cLinha
				
				If !Empty(cHistPadr)
					aDadosCT2[nPosHP]  := cHistPadr
					aDadosCT2[nPosHist] := Posicione("CT8",1,xFilial("CT8")+cHistPadr,"CT8_DESC")
				EndIf
				
				If lSemValor .And. CT2->CT2_MOEDLC == "01"
					aDadosCT2[nPosValor] := 0
				EndIf

	            //deve ser armazenado antes de gravar o registro no CT2 pois se refere ao registro de origem da copia
				cUltLanc := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)
								
				// Cria novo registro na tabela CT2 e grava os dados do lancamento de origem
				RecLock( "CT2", .T. )
				For nX := 1 To nCpos
					CT2->( FieldPut( nX, aDadosCT2[nX] ) )
				Next nX
				CT2->( MsUnlock() )
				cLinIncl := CT2->CT2_LINHA
			Next nInc
		EndIf
		
	ElseIf lMltSaldos
		
		aTpSaldos := CTM300GetTpSaldos( CT2->CT2_MLTSLD, ";" )
		cTpSldOri := CT2->CT2_TPSALD //Variavel criada para comparar com registro a ser criado
		cMtSldOri := AllTrim(StrTran(StrTran(CT2->CT2_MLTSLD,";",""),cTpSldOri,"")) //Variavel criada para tratar um possivel erro

		If (CT2->CT2_CTLSLD == "0" .Or. Empty(CT2->CT2_CTLSLD)) .And. !Empty(cMtSldOri)

			// Atualiza o status de copia do lancamento de origem
			RecLock( "CT2", .F. )
			CT2->CT2_CTLSLD := "2"
			CT2->( MsUnLock() )

			If cDataOri+cDocOri+cLoteOri != CT2->(DtoS(CT2_DATA)+CT2_DOC+CT2_LOTE) .Or. nLinha > nMaxLinha
				// Atualiza numeracao de lote, sub-lote e documento
				If MV_PAR13 = 1
					cLote    := CT2->CT2_LOTE
					cSubLote := CT2->CT2_SBLOTE
				Else
					cLote		:= IIf(Empty(cLote)   ,mv_par14,cLote)
					cSubLote	:= IIf(Empty(cSubLote),mv_par15,cSubLote)
				EndIf
				cDataOri:= DtoS(CT2->CT2_DATA)
				cDocOri := CT2->CT2_DOC
				cLoteOri:= CT2->CT2_LOTE
				
				cDoc    := CT2->CT2_DOC
				dDtLanc := CT2->CT2_DATA
				lFirst  := .T.
			EndIf

			For nInc := 1 To Len( aTpSaldos )
				
				//N�o cria registro que j� existe
				If AllTrim(aTpSaldos[nInc]) == AllTrim(cTpSldOri) .Or. Empty(aTpSaldos[nInc])
					Loop
				EndIf

				If lFirst .Or. nLinha > nMaxLinha
					CTM300ProxDoc(dDtLanc,cLote,cSubLote,@cDoc,@CTF_LOCK)
					If MV_PAR13 = 1
						cLote    := IIf(Empty(cLote)   ,Soma1(Space(TamSx3("CT2_LOTE")[1]))  ,cLote)    //CT2->CT2_LOTE
						cSubLote := IIf(Empty(cSubLote),Soma1(Space(TamSx3("CT2_SBLOTE")[1])),cSubLote) //CT2->CT2_SBLOTE
					Else
						cLote		:= IIf(Empty(cLote)   ,mv_par14,cLote)
						cSubLote	:= IIf(Empty(cSubLote),mv_par15,cSubLote)
					EndIf
					lFirst := .F.
					nLinha := 1
					cLinha := StrZero(nLinha,3)
				Else
					If cUltLanc != CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)
						nLinha ++
						cLinha := Soma1(cLinIncl)
					EndIf
				EndIf

				// Copia os campos padrao da tabela de lancamentos contabeis (CT2)           
				For nX := 1 To nCpos         
					If nX <> nPosTpSal            
						aDadosCT2[nX] := CT2->(FieldGet(nX))
					EndIf
				Next nX
				
				aDadosCT2[nPosLote]  := cLote
				aDadosCT2[nPosSLote] := cSubLote
				aDadosCT2[nPosDoc]   := cDoc
				aDadosCT2[nPosTPSal] := aTpSaldos[nInc]				// Tipo de Saldo
				aDadosCT2[nPosCtSal] := "2"							// Geracao Off-Line - Controle de Copia
 				aDadosCT2[nPosLinha] := cLinha

				If !Empty(cHistPadr)
					aDadosCT2[nPosHP]  := cHistPadr
					aDadosCT2[nPosHist] := Posicione("CT8",1,xFilial("CT8")+cHistPadr,"CT8_DESC")
				EndIf

				If lSemValor .And. CT2->CT2_MOEDLC == "01"
					aDadosCT2[nPosValor] := 0
				EndIf

	            //deve ser armazenado antes de gravar o registro no CT2 pois se refere ao registro de origem da copia
				cUltLanc := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)

				// Cria novo registro na tabela CT2 e grava os dados do lancamento de origem
				RecLock( "CT2", .T. )
				For nX := 1 To nCpos
					CT2->( FieldPut( nX, aDadosCT2[nX] ) )
				Next nX
			    CT2->( MsUnlock() )
				cLinIncl := CT2->CT2_LINHA

		

			Next nInc
		EndIf
	EndIf
	

    TRB->( dbSkip() )
EndDo

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CTM300SelSint� Autor � Gustavo Henrique � Data � 20/12/06  ���
�������������������������������������������������������������������������͹��
���Descricao � Seleciona registros das tabelas de saldos e grava arquivo  ���
���          � de trabalho quando selecionado na pergunta "Tipo" a opcao  ���
���          � movimentos sinteticos.                                     ���
�������������������������������������������������������������������������͹��
���Parametros� EXPL1 - Indicar se deve processar saldo ateh a data inicial���
���          �         ou movimento sintetico do periodo.                 ���
���          � EXPC2 - Alias da tabela de saldos (CQ1,CQ3,CQ5,CQ7)        ���
���          � EXPD3 - Data inicial para selecao dos lancamentos de saldo ���
���          � EXPD4 - Data final para selecao dos lancamentos de saldo   ���
���          � EXPC5 - Moeda para selecao e gravacao dos lancamentos      ���
���          � EXPC6 - Tipo de saldo para selecao e gravacao dos lanctos. ���
���          � EXPL7 - Indica se movimenta centro de custo no CTB         ���
���          � EXPL8 - Indica se movimenta item contabil no CTB           ���
���          � EXPL9 - Indica se movimenta classe de valor no CTB         ���
���          � EXPL10- Indica se deve processar todas as moedas           ���
���          � EXPN11- Indica ateh que nivel de entidade do CTB deve      ���
���          �         processar os lancamentos.                          ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CTM300SelSint( lSaldo, cAlias, dDataIni, dDataFim, cMoeda, cTpSaldo, lCusto, lItem, lClVl, lTodas, nNivel )

Local aSldAtu	:= {}
Local aSldIni	:= {}
Local aSldFim	:= {}
Local aDataProc	:= {}

Local nRecno	:= 0
Local nDebTrb	:= 0 
Local nCrdTrb	:= 0
Local nTrbSlD	:= 0
Local nTrbSlC	:= 0
Local nMovCrd	:= 0
Local nMovDeb	:= 0
Local nSaldo	:= 0

Local cKeyAtu	:= ""             
Local cDataFim	:= DtoS(dDataFim)

Local cConta 	:= Space(Len(CriaVar("CT1_CONTA")))
Local cCusto 	:= Space(Len(CriaVar("CTT_CUSTO")))
Local cItem  	:= Space(Len(CriaVar("CTD_ITEM")))
Local cClVl		:= Space(Len(CriavAr("CTH_CLVL")))

Local lTemSaldo	:= .F.

Local dDataAtu	
Local dDataAnt	:= CtoD("  /  /  ")
      
Local bCond		:= { || .T. }
Local cVarAux		:= ""

                                                                                                           
If lTodas
	bCond 	:= { ||	(cAlias)->&(cAlias + "_TPSALD") $ cTpSaldo .And.; 	// Processa apenas tipo de saldo de origem
					dDataAtu >= dDataIni .And.	dDataAtu <= dDataFim }      // Dentro do periodo informado
Else
	bCond 	:= { ||	(cAlias)->&(cAlias + "_TPSALD") $ cTpSaldo .And.; 	// Processa apenas tipo de saldo de origem
					dDataAtu >= dDataIni .And.	dDataAtu <= dDataFim .And.;	// Dentro do periodo informado
					(cAlias)->&(cAlias + "_MOEDA") == cMoeda }  			// Na moeda especifica ou para todas as moedas
EndIf					


cFilAlias := xFilial(cAlias)

(cAlias)->(dbSetOrder(2))
(cAlias)->(MsSeek(cFilAlias,.T.)) //Procuro pela primeira conta a ser zerada

// Calcula numero de dias que serao processados para incremento do gauge
ProcRegua( (cAlias)->(LastRec()) )

Do While (cAlias)->( !Eof() .And. &(cAlias+"_FILIAL") == cFilAlias )

	dDataAtu := (cAlias)->&(cAlias+"_DATA")

	IncProc()
	
	If lTodas
		cMoeda := (cAlias)->&(cAlias + "_MOEDA")
	EndIf	 
	
	// Verifica se atende as condicoes de filtro especificadas nos parametros
	If !Eval( bCond )
		(cAlias)->( dbSkip() )
		Loop
	EndIf

	If cAlias == 'CQ7'
		cChave := CQ7->(CQ7_CONTA+CQ7_CCUSTO+CQ7_ITEM+CQ7_CLVL)
	ElseIf cAlias == 'CQ5'
		cChave := CQ5->(CQ5_CONTA+CQ5_CCUSTO+CQ5_ITEM)
	ElseIf cAlias == 'CQ3'       
		cChave := CQ3->(CQ3_CONTA+CQ3_CCUSTO)
	ElseIf cAlias == 'CQ1'
		cChave := CQ1->CQ1_CONTA
	EndIf

	//--------------------------------------
	// Pula registro caso a chave se repita
	//--------------------------------------
	If cChave+cMoeda+cTpSaldo == cVarAux
		(cAlias)->( DBSkip() )
		Loop
	Else
		cVarAux := cChave+cMoeda+cTpSaldo
	EndIf

	If cAlias == 'CQ7'
		cConta := CQ7->CQ7_CONTA
		cCusto := CQ7->CQ7_CCUSTO
		cItem  := CQ7->CQ7_ITEM
		cClVl  := CQ7->CQ7_CLVL
		If lSaldo
			aSldAtu := SaldoCTI(cConta,cCusto,cItem,cClVL,dDataIni-1,cMoeda,cTpSaldo,'CTBM300',.F.)
		Else
			aSldIni	:= SaldoCTI(cConta,cCusto,cItem,cClVL,dDataIni,cMoeda,cTpSaldo,'CTBM300',.F.)
			aSldFim	:= SaldoCTI(cConta,cCusto,cItem,cClVL,dDataFim,cMoeda,cTpSaldo,'CTBM300',.F.)	
		EndIf	
	ElseIf cAlias == 'CQ5'
		cConta := CQ5->CQ5_CONTA
		cCusto := CQ5->CQ5_CCUSTO
		cItem  := CQ5->CQ5_ITEM
		If lSaldo
			aSldAtu	:= SaldoCT4(cConta,cCusto,cItem,dDataIni-1,cMoeda,cTpSaldo,'CTBM300',.F.)
		Else
			aSldIni	:= SaldoCT4(cConta,cCusto,cItem,dDataIni,cMoeda,cTpSaldo,'CTBM300',.F.)
			aSldFim	:= SaldoCT4(cConta,cCusto,cItem,dDataFim,cMoeda,cTpSaldo,'CTBM300',.F.)	
		EndIf	
	ElseIf cAlias == 'CQ3'
		cConta := CQ3->CQ3_CONTA
		cCusto := CQ3->CQ3_CCUSTO
		If lSaldo
			aSldAtu	:= SaldoCT3(cConta,cCusto,dDataIni-1,cMoeda,cTpSaldo,'CTBM300',.F.)
		Else
			aSldIni	:= SaldoCT3(cConta,cCusto,dDataIni,cMoeda,cTpSaldo,'CTBM300',.F.)	
			aSldFim	:= SaldoCT3(cConta,cCusto,dDataFim,cMoeda,cTpSaldo,'CTBM300',.F.)	
		EndIf	
	ElseIf cAlias == 'CQ1'
		cConta := CQ1->CQ1_CONTA
		If lSaldo
			aSldAtu	:= SaldoCT7(cConta,dDataIni-1,cMoeda,cTpSaldo,'CTBM300',.F.)	
		Else
			aSldIni	:= SaldoCT7(cConta,dDataIni,cMoeda,cTpSaldo,'CTBM300',.F.)	
			aSldFim	:= SaldoCT7(cConta,dDataFim,cMoeda,cTpSaldo,'CTBM300',.F.)	
		EndIf	
	EndIf			
                   
  	If lSaldo
		nSaldo	:= aSldAtu[1]
		lTemSld	:= (nSaldo <> 0)
	Else
		nMovDeb	:= iif( dDataIni == dDataFim , aSldFim[4]  , aSldFim[4] - aSldIni[4] )
		nMovCrd	:= iif( dDataIni == dDataFim , aSldFim[5]  , aSldFim[5] - aSldIni[5] )
		lTemSld	:= (nMovDeb <> 0 .Or. nMovCrd <> 0)
	EndIf	

	If lTemSld	// Se houver saldo
	
		nTrbSlD := 0
		nTrbSlC := 0
	
		TRB->( dbSetOrder(2) )
                               
		If cAlias <> "CQ7"	// Saldos x Classe de Valor
			If cAlias == "CQ5"	// Saldos x Item contabil
				If lClVl .And. nNivel == 4
					cKeyAtu := cTpSaldo+cMoeda+"CQ7"+cConta+cCusto+cItem
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf	
			ElseIf cAlias == "CQ3" 	// Saldos x Centro de Custo
				If lItem .And. nNivel >= 3 
					cKeyAtu := cTpSaldo+cMoeda+"CQ3"+cConta+cCusto
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf
				If lClVl .And. nNivel == 4	                      
					cKeyAtu := cTpSaldo+cMoeda+"CQ7"+cConta+cCusto
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf	
			ElseIf cAlias == "CQ1"	// Saldos x Conta
				If lCusto .And. nNivel >= 2
					cKeyAtu := cTpSaldo+cMoeda+"CQ3"+cConta
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf
				If lItem .And. nNivel >= 3
					cKeyAtu := cTpSaldo+cMoeda+"CQ5"+cConta
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf
				If lClVl .And. nNivel == 4
					cKeyAtu := cTpSaldo+cMoeda+"CQ7"+cConta
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf
			EndIf
		EndIf	
                
		If lSaldo
			nDebTrb := aSldAtu[4] - nTrbSlD
			nCrdTrb := aSldAtu[5] - nTrbSlC
		Else
			nDebTrb := nMovDeb - nTrbSlD
			nCrdTrb := nMovCrd - nTrbSlC
		EndIf	

		If (nDebTrb <> 0 .Or. nCrdTrb <> 0) 
			TRB->(dbSetOrder(1))		
			If ! TRB->(MsSeek(cTpSaldo+cMoeda+cConta+cCusto+cItem+cClvl+cAlias,.F.))
				RecLock("TRB",.T.)
				TRB->TPSALDO	:= cTpSaldo
				TRB->MOEDA		:= cMoeda
				TRB->CONTA		:= cConta
				TRB->CUSTO		:= cCusto
				TRB->ITEM		:= cItem
				TRB->CLVL		:= cClVL
				TRB->IDENT		:= cAlias
				TRB->DEBITO		:= nDebTrb
				TRB->CREDIT		:= nCrdTrb
				TRB->(MsUnlock())
			EndIf
			TRB->(dbSetOrder(2))			
		EndIf	
	EndIf	

	(cAlias)->(dbSkip())

EndDo

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CTM300CalcTRB � Autor � Gustavo Henrique � Data � 26/12/06 ���
�������������������������������������������������������������������������͹��
���Descricao � Calcula o saldo total de debito e credito para nas entida_ ���
���          � des de centro de custo, item ou classe de valor.           ���
�������������������������������������������������������������������������͹��
���Parametros� EXPC1 - Indica a entidade que deve ser apurado os debitos  ���
���          �         e creditos (CQ3, CQ5 ou CQ1)                       ���
���          � EXPC2 - Chave de busca dos valores de saldo da entidade.   ���
���          � EXPN3 - Saldo total de debitos para a entidade.            ���
���          � EXPN4 - Saldo total de credito para a entidade.            ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CTM300CalcTrb( cAlias, cKeyAtu, nTrbSlD, nTrbSlC )
                                                  
Local bCond	

If cAlias == "CQ5"
	bCond := { || cKeyAtu == TPSALDO+MOEDA+IDENT+CONTA+CUSTO+ITEM }
ElseIf cAlias == "CQ3"	
	bCond := { || cKeyAtu == TPSALDO+MOEDA+IDENT+CONTA+CUSTO }        
ElseIf cAlias == "CQ1"
	bCond := { || cKeyAtu == TPSALDO+MOEDA+IDENT+CONTA }
EndIf

TRB->( MsSeek( cKeyAtu, .F. ) )
TRB->( dbEval(	{ || nTrbSlD += DEBITO, nTrbSlC += CREDIT },, bCond ) )

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CTM300GrvSint� Autor � Gustavo Henrique � Data �  21/12/06 ���
�������������������������������������������������������������������������͹��
���Descricao � Grava lancamentos contabeis a partir do arquivo de trabalho���
���          � gerado, com os movimentos sinteticos de acordo com os      ���
���          � parametros informados.                                     ���
�������������������������������������������������������������������������͹��
���Parametros� EXPD1 - Data em que serao gravados os lancamentos          ���
���          � EXPC2 - Numero do lote do lancamento                       ���
���          � EXPC3 - Numero do sub-lote do lancamento                   ���
���          � EXPC4 - Codigo da moeda do lancamento                      ���
���          � EXPC5 - Tipo de saldo do lancamento                        ���
���          � EXPC6 - Historico padrao do lancamento                     ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CTM300GrvSint( dDataLanc, cLote, cSubLote, cMoeda, cTpSaldo, cHP )

Local aArea		:= GetArea()
Local aCols		:= {}
Local lFirst	:= .T.
Local nLinha	:= 1
Local nConta	:= 1
Local cSeqLan	:= ""
Local cLinha	:= ""
Local cLinIncl  := Space(Len(CT2->CT2_LINHA))
Local cTipo		:= ""
Local cDebito	:= ""
Local cCustoDeb	:= ""
Local cItemDeb	:= ""
Local cClVlDeb	:= ""
Local cCredito	:= ""
Local cCustoCrd	:= ""
Local cItemCrd	:= ""
Local cClVlCrd	:= ""
Local cDoc		:= ""
Local nMaxLinha:= IIf(SuperGetMV("MV_NUMLIN")<1,999,CtbLinMax(SuperGetMv("MV_NUMLIN")))
Local CTF_LOCK	:= 0

ProcRegua( TRB->(LastRec()) )

CT2->( dbSetOrder( 1 ) )

CT8->( dbSetOrder( 1 ) )
CT8->( MsSeek( xFilial("CT8") + cHP ) )
cDescHP	:= CT8->CT8_DESC

TRB->( dbSetOrder(1) )
TRB->( dbGoTop() )

Do While TRB->( ! EoF() )
     
	IncProc()

	nSaldo := TRB->(CREDIT-DEBITO)
               
	If nSaldo <> 0

		If lFirst .Or. nLinha > nMaxLinha
			If Empty(mv_par14)
				cLote		:= IIf(Empty(cLote),Soma1(Space(TamSx3("CT2_LOTE")[1])),cLote) //CT2->CT2_LOTE
			Else
				cLote		:= IIf(Empty(cLote),mv_par14,cLote)
			EndIf

			If Empty(mv_par15)
				cSubLote := IIf(Empty(cSubLote),Soma1(Space(TamSx3("CT2_SBLOTE")[1])),cSubLote) //CT2->CT2_SBLOTE
			Else
				cSubLote	:= IIf(Empty(cSubLote),mv_par15,cSubLote)
			EndIf

			//Gera numero do documento
			CTM300ProxDoc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK)

			lFirst := .F.
			nLinha := 1
			cLinha := StrZero(nLinha,3)
			cSeqLan:= StrZero(nLinha,3)
		Else   
		/*
			nLinha ++
			cLinha := StrZero(nLinha,3)
			cSeqLan:= StrZero(nLinha,3)
		*/			
		EndIf
	
		If nSaldo > 0	
			cTipo		:= "2"		/// LANCAMENTO A CREDITO
			cDebito	:= ""
			cCustoDeb:= ""
			cItemDeb	:= ""
			cClVlDeb	:= ""
	
			cCredito	:= TRB->CONTA
			cCustoCrd	:= TRB->CUSTO
			cItemCrd	:= TRB->ITEM
			cClVlCrd	:= TRB->CLVL			
		Else
			cTipo 		:= "1"		/// LANCAMENTO A DEBITO
			cDebito		:= TRB->CONTA
			cCustoDeb	:= TRB->CUSTO
			cItemDeb	:= TRB->ITEM	
			cClVlDeb	:= TRB->CLVL
	
			cCredito	:= ""
			cCustoCrd	:= ""
			cItemCrd	:= ""
			cClVlCrd	:= ""
		EndIf 
	
		//Grava lancamento na moeda 01
		nSaldo := Abs(nSaldo)
	
		BEGIN TRANSACTION
	
		If TRB->MOEDA == "01"
	
			aCols := { { "01", " ", nSaldo, "2", .F., nSaldo } }
	
			For nConta := 1 To Len(cTpSaldo)
				If !(SubStr(cTpSaldo,nConta,1) $ "|;| |") .And. SubStr(cTpSaldo,nConta,1) != TRB->TPSALDO
					GravaLanc(dDataLanc,cLote,cSubLote,cDoc,cLinha,cTipo,'01',cHP,cDebito,cCredito,;
						  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,nSaldo,cDescHP,;
						  SubStr(cTpSaldo,nConta,1),cSeqLan,3,.F.,aCols,cEmpAnt,cFilAnt,,,,,,,.F.)
					nRecCT2 := CT2->( Recno() )
					cLinIncl := CT2->CT2_LINHA
					If CT2->( MsSeek(xFilial("CT2")+DTOS(dDataLanc)+cLote+cSubLote+cDoc+cLinha+SubStr(cTpSaldo,nConta,1)+cEmpAnt+cFilAnt+"01") )
						nLinha ++
						cLinha := Soma1(cLinIncl)
						cSeqLan:= cLinha
					EndIf
					CT2->( dbGoto(nRecCT2) )
				EndIf
			Next nConta
	
		Else	/// Grava Lancamento na moeda 02 com valor zerado na moeda 01

			//aCols := { { "01", " ", 0.00, "2", .F., 0 },{ TRB->MOEDA, "4", nSaldo, "2", .F., nSaldo } }
	
			If Val(TRB->MOEDA) >= 2
				nForaCols	:= Val(TRB->MOEDA)-1
			Else                
				nForaCols	:= 0
			EndIf
			
			aCols := { { "01", " ", 0.00, "2", .F., 0 } }
			For nConta := 1 To Len(cTpSaldo)
				If !(SubStr(cTpSaldo,nConta,1) $ "|;| |") .And. SubStr(cTpSaldo,nConta,1) != TRB->TPSALDO
					GravaLanc(dDatalanc,cLote,cSubLote,cDoc,cLinha,cTipo,'01',cHP,cDebito,cCredito,;
						  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
						  SubStr(cTpSaldo,nConta,1),cSeqLan,3,.F.,aCols,cEmpAnt,cFilAnt,0,,,,,,.F.)
					nRecCT2 := CT2->( Recno() )
					cLinIncl := CT2->CT2_LINHA
					If CT2->( MsSeek(xFilial("CT2")+DTOS(dDataLanc)+cLote+cSubLote+cDoc+cLinha+SubStr(cTpSaldo,nConta,1)+cEmpAnt+cFilAnt+"01") )
						nLinha ++
						cLinha := Soma1(cLinIncl)
						cSeqLan:= cLinha
					EndIf
					CT2->( dbGoto(nRecCT2) )
				EndIf
			Next nConta

			aCols := { { TRB->MOEDA, "4", nSaldo, "2", .F., nSaldo } }
			For nConta := 1 To Len(cTpSaldo)
				If !(SubStr(cTpSaldo,nConta,1) $ "|;| |") .And. SubStr(cTpSaldo,nConta,1) != TRB->TPSALDO
					GravaLanc(dDataLanc,cLote,cSubLote,cDoc,cLinha,cTipo,TRB->MOEDA,cHP,cDebito,cCredito,;
						  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
						  SubStr(cTpSaldo,nConta,1),cSeqLan,3,.F.,aCols,cEmpAnt,cFilAnt,nForaCols,,,,,,.F.)
					nRecCT2 := CT2->( Recno() )
					cLinIncl := CT2->CT2_LINHA
					If CT2->( MsSeek(xFilial("CT2")+DTOS(dDataLanc)+cLote+cSubLote+cDoc+cLinha+SubStr(cTpSaldo,nConta,1)+cEmpAnt+cFilAnt+cMoeda) )
						nLinha ++
						cLinha := Soma1(cLinIncl)
						cSeqLan:= cLinha
					EndIf
					CT2->( dbGoto(nRecCT2) )
				EndIf
			Next nConta
		EndIf
	
		END TRANSACTION
	
	EndIf


	TRB->( dbSkip() )

EndDo      

RestArea( aArea )

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBM300ProxDoc�Autor � Gustavo Henrique � Data �  15/01/07  ���
�������������������������������������������������������������������������͹��
���Descricao � Gera proxima numeracao de documento para gravar no novo    ���
���          � Lancamento. Caso estoure a numeracao de documento,         ���
���          � incrementa numero de lote.                                 ���
�������������������������������������������������������������������������͹��
���Parametros� EXPD1 - Data do lancamento a ser gravado                   ���
���          � EXPC2 - Numero do lote                                     ���
���          � EXPC3 - Numero do sub-lote                                 ���
���          � EXPC4 - Numero do documento                                ���
���          � EXPC5 - Numero do RECNO da tabela de numeracao de doctos.  ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTM300ProxDoc( dDataLanc, cLote, cSubLote, cDoc, CTF_LOCK )

// Verifica o Numero do Proximo documento contabil                         
Do While !ProxDoc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK)
	//������������������������������������������������������Ŀ
	//� Caso o N� do Doc estourou, incrementa o lote         �
	//��������������������������������������������������������
	cLote := Soma1(cLote)
Enddo

FreeUsedCode()  //libera codigos ainda travados

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTM300GetT�Autor  � Totvs              � Data �  13/10/08   ���
�������������������������������������������������������������������������͹��
���Descricao � retorna os tipos de saldos em um array.                    ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CTM300GetTpSaldos( cTpSaldos, cSepara )
	Local aReturn 	:= {}
	Local cAux		:= ""
	Local nInc		:= 0
	
	cTpSaldos := AllTrim( cTpSaldos )
	For nInc := 1 To Len( cTpSaldos )
		cAux += substr( cTpSaldos, nInc, 1 )
		If substr( cTpSaldos, nInc, 1 ) == cSepara .OR. nInc == Len( cTpSaldos )
			If aScan( aReturn, StrTran( cAux, cSepara, "" ) ) == 0
				aAdd( aReturn, StrTran( cAux, cSepara, "" ) )
			EndIf

			cAux := ""
		EndIf
	Next
	
Return aReturn
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBA105   �Autor  �Microsiga           � Data �  08/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function CtbLinMax(nMv_NumLin)
Local nRet := 0

If nMv_NumLin >= 35658  //limite estabelecido em razao do tamanho campo CT2_LINHA  = 3 e utilizar a funcao Soma1() para incremento
	nRet := 35658
Else
	nRet := nMv_NumLin
EndIf

Return(nRet)   
//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna os parametros no schedule.

@return aReturn			Array com os parametros

@author  TOTVS
@since   07/04/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

Local aParam  := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            "CTBM30",;		//Pergunte do relatorio, caso nao use passar ParamDef
            ,;				//Alias
            ,;				//Array de ordens
            STR0001}				//Titulo - Copia de saldos

Return aParam

/*/{Protheus.doc} ctb300val
	(Valida se o numero de linhas ultrapassara o conteudo do MV_NUMLIN e ser� preciso criar um novo doc, caso sim ser� retor� Verdadeiro)
	
	@author Wilton.Santos
	@since 18/01/2023
	@version 1.0
	/*/
Static Function ctb300val(cTpSldOri, cTpSalDest,dDataIni,dDataFim,lTdsMoedas,cMoeda)
Local aArea       := getArea()
Local lRet 		  := .F.
Local nMaxLinha   := SuperGetMV("MV_NUMLIN",.F.,999)
Local cQuery      := " "
Local TMPCT2	  := GetNextAlias()
Local nQtdTpSald  := len(alltrim(strtran(cTpSalDest,';')))

Default cTpSldOri := '1'
Default cMoeda 	  := '01'

cQuery+= " SELECT CT2_DATA, CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_TPSALD,CT2_MOEDLC "  +CRLF
cQuery+= ",(COUNT(CT2_LINHA)*"+str(nQtdTpSald)+") QTDLIN "+CRLF
cQuery+= ", MAX(CT2_LINHA) MAXLIN "+CRLF
cQuery+= " FROM "+REtSqlName('CT2')+" CT2 "+CRLF
cQuery+= " WHERE CT2_FILIAL='"+FWxFilial('CT2')+"' AND  D_E_L_E_T_=' '"+CRLF
cQuery+= " AND CT2_DATA >='"+dtos(dDataIni)+"'"+CRLF
cQuery+= " AND CT2_DATA <='"+dtos(dDataFim)+"'"+CRLF
cQuery+= " AND CT2_CTLSLD = '0'"+CRLF
cQuery+= " AND CT2_TPSALD = '"+cTpSldOri+"'"+CRLF
if !lTdsMoedas
	cQuery+= " AND CT2_MOEDLC = '"+cMoeda+"'"+CRLF
EndIF
cQuery+= " GROUP BY CT2_DATA, CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_TPSALD,CT2_MOEDLC "+CRLF
cQuery+= " ORDER BY QTDLIN DESC "+CRLF
cQuery:= changequery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),TMPCT2,.T.,.F.)

TcSetField(TMPCT2,'QTDLIN','N',GetSX3Cache("CT2_LINHA", "X3_TAMANHO"))
TcSetField(TMPCT2,'MAXLIN','N',GetSX3Cache("CT2_LINHA", "X3_TAMANHO"))

(TMPCT2)->(DbGoTop())
If (TMPCT2)->(!EOF())
	If (TMPCT2)->MAXLIN + (TMPCT2)->QTDLIN > nMaxLinha  
		lRet := .T.
	EndIf
EndIF
(TMPCT2)->(dbCloseArea())

restArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} EngSPS25Signature
Identifica a seqUencia de controle do fonte ADVPL com a     
stored procedure, qualquer alteracao que envolva diretamente
a stored procedure a variavel sera incrementada.            
Procedure CTB301                                           

@author Douglas Silva 
@version P12
@since   21.03.2023
@return  vers�o
@obs	 
*/
//-------------------------------------------------------------------   
         
// Processo 25 - COPIA DE SALDOS
Function EngSPS25Signature(cProcess as character)
Return "001"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTM300SOMA    �Autor � TOTVS            � Data �  23/01/09  ���
�������������������������������������������������������������������������͹��
���Descricao � Gera mssoma1 para banco respectivo                         ���
�������������������������������������������������������������������������͹��
���Parametros� EXPC1 - Nome da procedure                                  ���
���          � EXPC2 - MsstrZero criado previamente                       ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTM300SOMA(cProc, cStrZero)
Local aSaveArea := GetArea()
Local lRet      := .T.
Local cQuery    := ""

cQuery := cProcSOMA1(cProc, cStrZero)
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(STR0094+cProc)   //"Erro na query strzero pelo Parse "
	lRet := .F.
Else
	If !TCSPExist( cProc )
		iRet := TcSqlExec(cQuery)
		If iRet <> 0
			If !__lBlind
				MsgAlert(STR0095+cProc)  //"Erro na criacao da procedure StrZero "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)
Return(lRet)
