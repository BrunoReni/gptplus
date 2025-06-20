
// 17/08/2009 -- Filial com mais de 2 caracteres   

#Include "Ctba175.Ch"
#Include "Protheus.Ch"

// TRADU��O RELEASE P10 1.2 - 21/07/08

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Ctba175  � Autor � Alexandre Silva       � Data � 15/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calculo do "Ajuste por inflacao" usado na Argentina        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void Ctba175(void)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function Ctba175()
// ������������������Ŀ
// � Define vari�veis �
// ��������������������
Local nOpca := 0
Local aSays := {}, aButtons := {}
PRIVATE lArg  := If (cPaisLoc = 'ARG',.T.,.F.)
PRIVATE cCadastro := OemToAnsi(STR0001)  //"C�lculo da Varia��o Monet�ria"
#IFDEF TOP
	TCInternal(5,"*OFF")   // Desliga Refresh no Lock do Top
#ENDIF
PRIVATE cNumLote := ""
Private cSubLote := ""

//����������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                           �
//� mv_par01 // Data de ajuste                                     �
//� mv_par02 // Conta de ajuste                                    �
//� mv_par03 // Cod Hist Padrao?                                   �
//� mv_par04 // Lote para lancamento                               �
//� mv_par05 // Moeda ara lancamento                               �
//� mv_par06 // Sub-Lote                                           �
//������������������������������������������������������������������
Pergunte("CTB175",.f.)

AADD(aSays,OemToAnsi( STR0005 ) )
AADD(aSays,OemToAnsi( STR0006 ) )
AADD(aSays,OemToAnsi( STR0007 ) )
AADD(aSays,OemToAnsi( STR0008 ) )
AADD(aSays,OemToAnsi( STR0009 ) )
AADD(aSays,OemToAnsi( STR0010 ) )

AADD(aButtons, { 5,.T.,{|| Pergunte("CTB175",.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(), FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

FormBatch(cCadastro, aSays, aButtons )

If nOpca == 1
	DbSelectArea('SIE')
	DbCloseArea()
	ChkFile("SIE",.T.)
	If !MA280FLock("SIE") 
		ChkFile("SIE",.F.)
		Return .T.
	EndIf
	OpenIndx("SIE")
	Processa({|lEnd| Ca175Proc()})
	DbSelectArea('SIE')
	DbCloseArea()
EndIf
DbSelectArea('SIE')
DbSetOrder(1)
Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ca071Proc � Autor �Alexandre Silva        � Data � 04/06/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualizacao de Sinteticas                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ca070Proc()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function Ca175Proc()

Local dDataIni	:= CTOD('') 	
Local dIniPer	:=	CTOD('')
Local lRet		:=	.T.
Local cMes		:=	"" 
Local aRecSI2	:=	{}
Local aContas	:=	{}
Local aTmpConta	:= 	{}
Local cDataAj	:= 	""
Local dDataAju := CTOD('')
Local cTpSaldo := "" 
Private cSequencia	:=	"0000000001"

If lArg
	dDataAju := GetNewPar('MV_DTINIAJ',dDataIni)
	cTpSaldo := GetNewPar('MV_TIPSAL',"") 
EndIf

If CT1->(FieldPos('CT1_AJ_INF')) == 0
	MsgStop(	OemtoAnsi(STR0017)+Chr(13)+Chr(10)+;
				OemtoAnsi(STR0018)+Chr(13)+Chr(10)+;
				OemtoAnsi(STR0019)+Chr(13)+Chr(10)+;
				OemtoAnsi(STR0020)+Chr(13)+Chr(10)+;
				OemtoAnsi(STR0021)+Chr(13)+Chr(10)+;
				OemtoAnsi(STR0022)+Chr(13)+Chr(10)+;
				OemtoAnsi(STR0023)+Chr(13)+Chr(10)+;
				OemtoAnsi(STR0024)+Chr(13)+Chr(10)+Chr(13)+Chr(10)+;
				OemtoAnsi(STR0025))
	Return Nil
Endif

Private nLinha 	:= 100
Private nDoc 	:= 0
Private aFatores:=	{}
cNumLote		:=	mv_par04
cSubLote		:=	mv_par06

/*������������������������������������������������������������Ŀ
  �Verificar datas de ajuste, e se algum dos periodos do ajuste�
  �ja foi ajustado                                             �
  ��������������������������������������������������������������*/
DbSelectArea('SIE')
DbSetOrder(2)
MsSeek(xFilial()+'9999999999',.T.)
DbSkip(-1)

/*��������������������������������������Ŀ
  �Verificar se ja foi feito algum ajuste�
  �para pegar a proxima sequencia.       �
  ����������������������������������������*/
  
If !BOF() .And. xFilial() == IE_FILIAL .And. !Empty(IE_SEQ)
	cSequencia	:=	Soma1(IE_SEQ)
	dDataIni	:=	Ctod('01/'+StrZero(Month(IE_DTAJUS),2)+'/'+Str(Year(IE_DTAJUS),4))
Endif

/*���������������������������������������������Ŀ
  �Pegar o periodo correspondente a data inicial�
  �����������������������������������������������*/
If lArg
	dIniPer := dDataAju
Else  
	dIniPer := CTBPeriodos(mv_par05,mv_par01,,.T.,.F.)[1][1]
EndIf
/*����������������������������������������������������������������������Ŀ
  �Verificar se a data do ultimo ajuste (data de inicio do ajuste atual) �
  �pertence ao exercicio atual.                                          �
  ������������������������������������������������������������������������*/
If dDataIni < dIniPer
	lRet		:=	MsgYesNo(STR0026+CHR(13)+CHR(10)+STR0027	) //"Nao foi achado nenhum periodo ajustado para este exercicio, o sistema ajustara a partir do primeiro periodo do exercicio"###"Confirma?"
	dDataIni	:=	dIniPer
Endif
/*����������������������������������������������������������������������Ŀ
  �Verificar se a data do ultimo ajuste pertence ao mesmo periodo ou a um�
  �periodo superior a data de referencia para o atual ajuste.            �
  ������������������������������������������������������������������������*/
If lRet .And. AnoMes(dDataIni) >= AnoMes(mv_par01)
	MsgStop(STR0028+AnoMes(dDataIni)+STR0029; //"O ultimo periodo ajustado ("###") e igual ou posterior a data de ajuste atual."
			+CHR(13)+CHR(10)+ STR0030) //"Apague a ultima sequencia e tente novamente"
	lRet	:=	.F.
Endif

If !lRet	
	Return .F.
ElseIf dDataIni <> dIniPer
	cDataAj := Dtoc(Ctod("01/"+StrZero(Month(mv_par01))+"/"+StrZero(Year(mv_par01)))-1)
	Aviso(STR0031,STR0032+DTOC(dDataIni)+STR0033+cDataAj,{STR0002}) //"Periodo de ajuste"###"Serao ajustados os lancamentos comprendidos entre as datas "###" e "###"Ok"
Endif

/*���������������������������������������������Ŀ
  �Carrega indices de asjute                    �
  �����������������������������������������������*/
If !Ca175PegaSIE(dDataIni,@aFatores)
	MsgStop(OemToAnsi(STR0037),OemToAnsi(STR0038))
	Return .F.
Endif		

dbSelectArea("CT1")
dbSetOrder(1)
dbSeek(xFilial("CT1"))

If !Empty(mv_par03)
	dbSelectArea ( "CT8" )
	dbSetOrder(1)
	If ( !dbSeek(xFilial("CT8") + mv_par03) )
		Help (" ", 1,"CA160N/HIS")
		Return(.F.)
	EndIf
EndIf

/*��������������������������������������������������������������������Ŀ
  � Localiza conta inicial                                             �
  ����������������������������������������������������������������������*/
  
dbSelectArea("CT1")
DbSetOrder(1)
dbSeek(xFilial("CT1"))
ProcRegua(RecCount())

If lArg 
dbSelectArea("SX5")
	If !(dbSeek(xFilial("SX5")+"SL"+cTpSaldo))	
		lRet := .F.
		MsgAlert (STR0039)	 
	EndIf
EndIf
If lRet  
While CT1->CT1_FILIAL == xFilial("CT1")  .And. ! Eof()
	aLanca	:=	{}
	IncProc(STR0034+CT1->CT1_CONTA) //"Procesando conta "
	// ��������������������������������������������������������������������Ŀ
	// � Desconsidera as contas sem varia��o monet�ria ou contas sint�ticas �
	// ����������������������������������������������������������������������
	If Alltrim(CT1->CT1_AJ_INF) == '1' .And. CT1->CT1_CLASSE <> "1" .AND. &("CT1->CT1_CVD"+MV_PAR05) == "A" .AND. &("CT1->CT1_CVC"+MV_PAR05) == "A"
		//�����������������������������������
		//�Carregar valores de saldo inicial�
		//�����������������������������������
  		AAdd(aLanca,{AnoMes(dDataIni),SaldoCt7(CT1->CT1_CONTA,(dDataIni-1),MV_PAR05,"1")[1]})
		//�����������������Ŀ
		//�Verificar DEBITOS�
		//�������������������
		DbSelectArea('CT2')
		DbSetOrder(2)
		MsSeek(xFilial()+CT1->CT1_CONTA+Dtos(dDataIni),.T.)		
		While  xFilial() == CT2_FILIAL .And. CT2_DEBITO == CT1->CT1_CONTA .And. CT2_DATA < mv_par01 .And. !Eof() 
			If CT2_TPSALD == "1" .or. cTpSaldo == CT2_TPSALD .and. lArg 
				If MV_PAR05 == CT2_MOEDLC
					// �����������������������������������Ŀ
					// � Acumula os lancamentos a ajustar  �
					// �������������������������������������
					If (nPosPer	:=	Ascan(aLanca,{|x| x[1] == AnoMes(CT2_DATA)})) > 0
						aLanca[nPosPer][1] :=	AnoMes(CT2_DATA)
						aLanca[nPosPer][2] -=	CT2_VALOR
					Else
						AAdd(aLanca,{AnoMes(CT2_DATA),	CT2_VALOR*-1})
					Endif				
					AAdd(aRecSI2,RECNO())								
				Endif			
			Else
				If MV_PAR05 == CT2_MOEDLC
					// �����������������������������������Ŀ
					// � Acumula os lancamentos a ajustar  �
					// �������������������������������������
					If (nPosPer	:=	Ascan(aLanca,{|x| x[1] == AnoMes(CT2_DATA)})) > 0
						aLanca[nPosPer][1] :=	AnoMes(CT2_DATA)
						aLanca[nPosPer][2] -=	CT2_VALOR
					Else
						AAdd(aLanca,{AnoMes(CT2_DATA),	CT2_VALOR*-1})
					Endif				
					AAdd(aRecSI2,RECNO())								
				Endif					
			Endif	
		DbSkip()
		Enddo		
		//������������������Ŀ
		//�Verificar CREDITOS�
		//��������������������
		DbSelectArea('CT2')
		DbSetOrder(3)
		MsSeek(xFilial()+CT1->CT1_CONTA+Dtos(dDataIni),.T.)
		While  xFilial() == CT2_FILIAL .And. CT2_CREDIT == CT1->CT1_CONTA .And. CT2_DATA < mv_par01 .And. !Eof()
			If CT2_TPSALD == "1" .or. cTpSaldo == CT2_TPSALD .and. lArg     
				If MV_PAR05 == CT2_MOEDLC
					// �����������������������������������Ŀ
					// � Acumula os lancamentos a ajustar  �
					// �������������������������������������
					If (nPosPer	:=	Ascan(aLanca,{|x| x[1] == AnoMes(CT2_DATA)})) > 0
						aLanca[nPosPer][1] :=	AnoMes(CT2_DATA)
						aLanca[nPosPer][2] +=	CT2_VALOR
					Else
						AAdd(aLanca,{AnoMes(CT2_DATA),	CT2_VALOR})
					Endif				
					AAdd(aRecSI2,RECNO())								
				Endif			
			Else
				If MV_PAR05 == CT2_MOEDLC
					// �����������������������������������Ŀ
					// � Acumula os lancamentos a ajustar  �
					// �������������������������������������
					If (nPosPer	:=	Ascan(aLanca,{|x| x[1] == AnoMes(CT2_DATA)})) > 0
						aLanca[nPosPer][1] :=	AnoMes(CT2_DATA)
						aLanca[nPosPer][2] +=	CT2_VALOR
					Else
						AAdd(aLanca,{AnoMes(CT2_DATA),	CT2_VALOR})
					Endif				
					AAdd(aRecSI2,RECNO())								
				Endif							
			Endif
		DbSkip()	
		Enddo	
		//�������������������������������������������Ŀ
		//�Calcular valor de lancamentos de ajuste    �
		//���������������������������������������������
		aTmpConta	:= Ct175CalAj(aLanca)
		If ! Empty(aTmpConta[2]) 
			Aadd(aContas,aTmpConta)
		EndIf			
	Endif
	dbSelectArea("CT1")
	dbSkip()
EndDo

EndIf

Begin Transaction
	If (lRet	:=	Ca175GrCT2(aContas,aRecSI2))
		DbSelectArea('SIE')
		DbSetOrder(1)
		MsSeek(xFilial()+AnoMes(dDataIni))
		While !EOF() .And. IE_FILIAL == xFilial() .And. IE_EXERCIC+IE_MES < AnoMes(mv_par01)
			RecLock('SIE',.F.)
			Replace IE_SEQ		With cSequencia
			Replace IE_DTAJUS	With MV_PAR01
			Replace IE_MOEDA	With MV_PAR05 //Moeda usada no ajuste.
			MsUnLock()
			DbSkip()
		Enddo			
	Endif
End Transaction        
If lRet
	MsgAlert(STR0035) //"O ajuste por inflacao finalizou com sucesso"
Endif

/* ����������������������������������Ŀ
   � Restaura a integridade da janela �
   ������������������������������������*/
CT1->(dbSetOrder(1))
CT2->(dbSetOrder(1))
Return


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ct175CalAj� Autor �Alexandre Silva        � Data � 04.06.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula os valores de lancamento de ajuste                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ct175CalAj(aLanca)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function Ct175CalAj(aLanca)

Local nAjuste	:=	0
Local nFator	:=	nFatorAtu := nFatorAnt	:=	0
Local cTipoLanc	:= ""
Local nX		:= 0

nFatorAtu	:=	Ascan(aFatores,{|x| x[1] == AnoMes(mv_par01)})

For nX := 1 To Len(aLanca)	
	nFatorAnt	:=	Ascan(aFatores,{|x| x[1] == aLanca[nX][1] }) 	
	nFator		:=	aFatores[nFatorAtu][2] / aFatores[nFatorAnt][2]
	nValor		:=	(aLanca[nX][2] * nFator) - aLanca[nX][2] 
	nAjuste		+= nValor	
Next		

If 	(nAjuste	> 0 .And. CT1->CT1_NORMAL == "2"	)	.Or.;
	(nAjuste	< 0 .And. CT1->CT1_NORMAL == "1"	)	
	cTipoLanc	:=	"1"
ElseIf	(nAjuste	< 0 .And. CT1->CT1_NORMAL == "2"	).Or. ;
       	(nAjuste	> 0 .And. CT1->CT1_NORMAL == "1"	)	
	cTipoLanc	:=	"2"
Endif

Return {CT1->CT1_CONTA,cTipoLanc,Abs(nAjuste)}

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ca175GrCT2� Autor �Alexandre Silva        � Data � 22.05.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera lancamentos de ajuste                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ca175GrCT2()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function Ca175GrCT2(aContas,aRecnos)
Local cOldArea 		:= Alias()
Local nDecs			:=	TamSX3('CT2_VALOR')[2]
Local nLote
Local nContraPart	:=	0
Local nX			:=	1
Local nBase			:=	1
Local nMaxLanc		:=	99
Local nContador		:=	Min(Len(aContas),nMaxLanc-1) 
Local lCt175GrCT2	:=	ExistBlock('CT175GRV')
Local aAreaSI2		:=	CT2->(GetArea())
Local aCab			:= {}
Local aItem			:= {}
Local aTotItem 		:= {}
Local cTpSaldo     := ""
Private lMsErroAuto := .F.

If lArg
	cTpSaldo := GetNewPar('MV_TIPSAL',"")
EndIf
If Empty(mv_par03)
	cHp	:=	Nil
	cHist	:=	OemToAnsi(STR0014+AnoMes(mv_par01)) //"Ajuste por inflacion "
Else
	cHp		:= mv_par03
	cHist	:= CT8->CT8_DESC
EndIf

aCab := {;
			{"dDataLanc",mv_par01,NIL},;
			{"cLote"	,Padr(cNumlote,TamSx3("CT2_LOTE")[1]),NIL},;
			{"cSubLote"	,Padr(cSublote,TamSx3("CT2_SBLOTE")[1]),NIL};
		}

While nX <= Len(aContas)
	nContraPart	:=	0
	For nX	:= nBase To nContador
		/*������������������������������������Ŀ
		  �Fazer o lancamento de contrapartida �
		  ��������������������������������������*/
		If lArg   
			Aadd(aTotItem, {;
				 				{"CT2_LINHA"	,StrZero(nX+1-nBase,3)					, NIL},;
				 				{"CT2_DC"		,aContas[nX][2]							, NIL},;
								{"CT2_DEBITO"	,IIf(aContas[nX][2]=='1',aContas[nX][1],Nil), NIL},;
								{"CT2_CREDIT"	,IIf(aContas[nX][2]=='2',aContas[nX][1],Nil), NIL},;
								{"CT2_VALOR"	,Round(aContas[nX][3],nDecs)			, NIL},;
								{"CT2_ORIGEM"	,cSequencia								, NIL},;
								{"CT2_HP"		,cHp									, NIL},;
								{"CT2_TPSALD"	,cTpSaldo                            , NIL},;
								{"CT2_HIST"		,cHist									, NIL}}	)
			nContraPart	+=	(Round(aContas[nX][3],nDecs) * Iif(aContas[nX][2]=='1',-1,1))
		Else
			Aadd(aTotItem, {;
				 				{"CT2_LINHA"	,StrZero(nX+1-nBase,3)					, NIL},;
				 				{"CT2_DC"		,aContas[nX][2]							, NIL},;
								{"CT2_DEBITO"	,IIf(aContas[nX][2]=='1',aContas[nX][1],Nil), NIL},;
								{"CT2_CREDIT"	,IIf(aContas[nX][2]=='2',aContas[nX][1],Nil), NIL},;
								{"CT2_VALOR"	,Round(aContas[nX][3],nDecs)			, NIL},;
								{"CT2_ORIGEM"	,cSequencia								, NIL},;
								{"CT2_HP"		,cHp									, NIL},;							
								{"CT2_HIST"		,cHist									, NIL}}	)
			nContraPart	+=	(Round(aContas[nX][3],nDecs) * Iif(aContas[nX][2]=='1',-1,1))
		EndIf
	Next                                                 
	/*��������������������Ŀ
	  �Asiento a debito    �
	  ����������������������*/
	If nContrapart # 0
		If lArg 
			Aadd(aTotItem, {;
			 					{"CT2_LINHA"	,StrZero(nX+1-nBase,3)				, NIL},;
				 				{"CT2_DC"		,IIf(nContrapart > 0,'1','2')		, NIL},;
								{"CT2_DEBITO"	,IIf(nContrapart > 0,mv_par02,Nil)	, NIL},;
								{"CT2_CREDIT"	,IIf(nContrapart < 0,mv_par02,Nil)	, NIL},;
								{"CT2_VALOR"	,Abs(nContrapart)					, NIL},;
								{"CT2_ORIGEM"	,cSequencia							, NIL},;
								{"CT2_HP"		,cHp								, NIL},;
								{"CT2_TPSALD"	,cTpSaldo                        , NIL},;
								{"CT2_HIST"		,cHist								, NIL}};
							)
		Else
			Aadd(aTotItem, {;
			 					{"CT2_LINHA"	,StrZero(nX+1-nBase,3)				, NIL},;
				 				{"CT2_DC"		,IIf(nContrapart > 0,'1','2')		, NIL},;
								{"CT2_DEBITO"	,IIf(nContrapart > 0,mv_par02,Nil)	, NIL},;
								{"CT2_CREDIT"	,IIf(nContrapart < 0,mv_par02,Nil)	, NIL},;
								{"CT2_VALOR"	,Abs(nContrapart)					, NIL},;
								{"CT2_ORIGEM"	,cSequencia							, NIL},;
								{"CT2_HP"		,cHp								, NIL},;							
								{"CT2_HIST"		,cHist								, NIL}};
							)
		EndIf						
	EndIf
	If lCt175GrCT2
		aRetorno	:=	ExecBlock('CT175GRV',.F.,.F.,{aClone(aCab),aClone(aTotItem)})
		aCab		:=	aClone(aRetorno[1])
		aTotItem	:=	aClone(aRetorno[2])
		aRetorno	:=	{}	
	Endif		
	IncProc(STR0036) //"Gerando lancamento "
	MSExecAuto({|x,y,Z| Ctba102(x,y,Z)},aCab,aTotItem,3) 
	aTotItem	:=	{}
	Pergunte("CTB175",.f.)	
	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
		Return .F.
	Endif		
	nBase		:=	nX
	nContador	:=	Min(Len(aContas),(nBase-1)+(nMaxLanc-1))		
Enddo	

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Ca175PegaSIE �Autor � Alexandre Silva      �Data� 23/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pega os indices da tabela SIE                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function Ca175PegaSIE(dDataIni,aFatores)
Local cAnoMes	:=	AnoMes(dDataIni)                     
Local nPosFat	:=	1

DbSelectArea('SIE')         
DbSetOrder(1)                                                               
DbSeek(xFilial()+AnoMes(dDataIni))
While !EOF() .And. xFilial()==IE_FILIAL .And. IE_EXERCIC+IE_MES <= AnoMes(mv_par01)
	AAdd(aFatores,{IE_EXERCIC+IE_MES,IE_INDICE})
	DbSkip()
Enddo	
While  nPosFat <> 0.And. cAnoMes <= AnoMes(mv_par01)
	nPosFat	:=	Ascan(aFatores,{|x| x[1]==cAnoMes}) 
	cAnoMes := Substr(cAnoMes,1,4)+STRZERO(Val(Substr(cAnoMes,5))+1,2)
	If Substr(cAnoMes,5) == '13'
		cAnoMes	:=	STRZERO(Val(Substr(cAnoMes,1,4))+1,4)+'01'
	Endif
Enddo	

Return (nPosFat <> 0 .And. cAnoMes > AnoMes(mv_par01))
