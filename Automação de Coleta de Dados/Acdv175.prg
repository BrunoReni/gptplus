#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'APVT100.CH'
#INCLUDE 'ACDV175.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ACDV175  � Autor � ACD                   � Data � 03/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Embarque dos volumes                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                         

Function ACDV175()
Local aTela
Local nOpc 
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
If ACDGet170() 
	Return ACDV175X(0)
EndIf
aTela := VtSave()
VTCLear()
If lVT100B // GetMv("MV_RF4X20")
	@ 0,0 VTSAY STR0006 + ' Selecione:'//"Embarque"
	nOpc:=VTaChoice(2,0,3,VTMaxCol(),{STR0008,STR0050,STR0051}) // "Ordem de separa��o","Pedido de vendas","Nota Fiscal"
ElseIf Vtmodelo()=="RF"
	@ 0,0 VTSAY STR0006 //"Embarque" 
	@ 1,0 VTSay 'Selecione:' 
	nOpc:=VTaChoice(3,0,6,VTMaxCol(),{STR0008,STR0050,STR0051}) // "Ordem de separa��o","Pedido de vendas","Nota Fiscal"
ElseIf VtModelo()=="MT44"
	@ 0,0 VTSAY STR0006 //"Embarque" 
	@ 1,0 VTSay 'Selecione:'
	nOpc:=VTaChoice(0,20,1,39,{STR0008,STR0050,STR0051}) // "Ordem de separa��o","Pedido de vendas","Nota Fiscal"
ElseIf VtModelo()=="MT16"
	@ 0,0 VTSAY "Embarque Selecione"
	nOpc:=VTaChoice(1,0,1,19,{STR0008,STR0050,STR0051}) // "Ordem de separa��o","Pedido de vendas","Nota Fiscal"
EndIf	

VtRestore(,,,,aTela)
If nOpc == 1 // por ordem de separacao
	ACDV175A()
ElseIf nOpc == 2 // por pedido de venda
	ACDV175B()
ElseIf nOpc == 3 // por Nota Fiscal 
	ACDV175C()
EndIf   
Return 1

Function ACDV175A()
ACDV175X(1)
Return
Function ACDV175B()
ACDV175X(2)
Return
Function ACDV175C()
ACDV175X(3)
Return


Static Function ACDV175X(nOpc)
Local ckey09  := VTDescKey(09)    
Local ckey24  := VTDescKey(24)
Local bkey09  := VTSetKey(09)
Local bkey24  := VTSetKey(24)

Local cEtiqueta
Local cProduto
Local cF3 := nil
Local nQtde
Local lSai:= .f.
Private cCodOpe    :=CBRetOpe()
Private cTranspConf 
Private cDesTra
Private lVldOrdSep:= GetMV("MV_CBVLDOS") == "1" // --> Valida Ordem de Separacao
Private lVldTransp:= SuperGetMV("MV_CBVLDTR",.F.,"1") == "1" // --> Valida Transportadora
Private lEmbarque := .t.

If Type('cOrdSep')=='U'
	Private cOrdSep := Space(TamSX3("CB8_ORDSEP")[1])
EndIf    
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

//Verifica se foi chamado pelo programa ACDV170 e se ja foi embarcado 
//(ver se eh necessario fazer esta consistencia)
If ACDGet170() .AND. !("06" $ CB7->CB7_TIPEXP)
	Return 10
ElseIf ACDGet170()
	//����������������������������������������������������������������������Ŀ
	//�Desativa a  tecla  avanca                                             �
	//������������������������������������������������������������������������	
	A170ATVKeys(.f.,.t.)		
EndIf

VTClear()
If VtModelo()=="RF" .or. lVT100B // GetMv("MV_RF4X20")
	@ 0,0 VtSay  STR0006 //"Embarque" 
EndIf
If ! CBSolCB7(nOpc,{|| VldCodSep()})
   Return 10
EndIf   

If CB7->CB7_STATUS == "9"
   VTAlert(STR0001,STR0002,.t.,4000) //"Processo de embarque finalizado" "Aviso" 
   If VTYesNo(STR0003,STR0004,.T.)   //"Deseja estornar os produtos embarcados ?" "Atencao"
	   VTSetKey(09,{|| Informa()},STR0005)//"Informacoes"	 
	   Estorna()
	   VTSetKey(09,bkey09,cKey09)        
	   Return FimEmbarq()
	Endif			   			
EndIf   

IniProcesso()

VTSetKey(09,{|| Informa()},STR0005) //"Informacoes"
VTSetKey(24,{|| Estorna()},STR0007) //"Estorno"

//Informa a Transportadora
If !Transport()
	Return FimEmbarq(10)
EndIf      

//Atualiza variavel com dados da transportadora
cDesTra := ""

DbSelectArea("SA4")
SA4->(DbSetOrder(1)) // A4_FILIAL + A4_COD
SA4->(DbSeek(xFilial("SA4") + CB7->CB7_TRANSP))
If !Empty(SA4->A4_COD)
	cTranspConf := SA4->A4_COD
	cDesTra     := SA4->A4_NOME	
ENDIF


//Leitura dos produtos para embarque
If !Embarque()
	Return FimEmbarq(10)
EndIf

Vtsetkey(09,bkey09,cKey09)
Vtsetkey(24,bkey24,cKey24)
Return  FimEmbarq()                   


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � VldCodSep� Autor � ACD                   � Data � 08/03/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao da Ordem de Separacao                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldCodSep()

If Empty(cOrdSep)
   VtKeyBoard(chr(23))
   Return .f.
EndIf

CB7->(DbSetOrder(1))
CB7->(DbSeek(xFilial("CB7")+cOrdSep))

// --> Atencao nao alterar a sequencia das validacoes.

If CB7->(Eof())
	VtAlert(STR0008+STR0009,STR0002,.t.,4000,3) //### "Ordem de separacao  nao encontrada." "Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
  
// analisar a pergunta '00-Separcao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque'
If !("06") $ CB7->CB7_TIPEXP
	VtAlert(STR0008+STR0010+STR0006,STR0002,.t.,4000,3) //### "Ordem de separacao nao configurada para Embarque","Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If CB7->CB7_STATUS == "0" .OR. CB7->CB7_STATUS == "1"
	VtAlert(STR0008+STR0011,STR0002,.t.,4000,3) //### "Ordem de separacao possui itens nao separados","Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .f.
Endif

If "02" $ CB7->CB7_TIPEXP .and. (CB7->CB7_STATUS == "2" .OR. CB7->CB7_STATUS == "3")
	VtAlert(STR0008+STR0052,STR0002,.t.,4000,3) //### "Ordem de separacao possui itens nao embalados","Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If "03" $ CB7->CB7_TIPEXP .and. Empty(CB7->(CB7_NOTA+CB7_SERIE))
	VtAlert(STR0012+STR0013+STR0008,STR0002,.t.,4000,3) //"nota n�o gerada para esta ordem de separa��o",,"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If !ACDGet170()
	If "04" $ CB7->CB7_TIPEXP .AND.  (CB7->CB7_STATUS  < "6")
		VtAlert(STR0014+STR0013+STR0008,STR0002,.t.,4000,3) //"Nota nao impressa para esta Ordem de separacao","Aviso",
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If "05" $ CB7->CB7_TIPEXP .AND.  (CB7->CB7_STATUS  < "7")
		VtAlert(STR0015+STR0016+STR0013+STR0008,STR0002,.t.,4000,3) //"Etiquetas oficiais de volume nao foram impressas para esta Ordem de separacao","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf		
EndIf

If CB7->CB7_STATUS # "0" .AND. CB7->CB7_STATPA == "1" .AND. CB7->CB7_CODOPE # cCodOpe  // SE ESTIVER EM SEPARACAO E PAUSADO SE DEVE VERIFICAR SE O OPERADOR E' O MESMO
   VtBeep(3)
   If !VTYesNo(STR0008+STR0017+CB7->CB7_CODOPE+STR0018,STR0002,.T.) //###### "Ordem Separacao iniciada pelo operador "+CB7->CB7_CODOPE+". Deseja continuar ?","Aviso"
      VtKeyboard(Chr(20))  // zera o get
      Return .F.
   EndIf
EndIf

//-- Ponto de entrada permite valida��o especifica para a ordem de separa��o.   
If ExistBlock("ACD175SOL")
	lRet:=ExecBlock("ACD175SOL",.f.,.f.)
	If ValType(lRet) == "L"
	   	Return lRet
   	EndIf
EndIf   	

RecLock("CB7",.f.)
If !Empty(CB7->CB7_STATPA)  // se estiver pausado tira o STATUS  de pausa
	CB7->CB7_STATPA := " "
EndIf
CB7->CB7_CODOPE := cCodOpe
CB7->(MsUnlock())
Return .t.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � IniProcesso� Autor � ACD                 � Data � 08/03/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Embarque                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function IniProcesso()
CBFlagSC5("3",cOrdSep)  //Embarcado
RecLock("CB7")
CB7->CB7_STATUS := "8"    //Em processo de embarque
CB7->CB7_STATPA := " "    //tira pausa
CB7->(MsUnlock())
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �Transport� Autor � ACD    	            � Data � 03/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Respons�vel por apresentar tela de digita��o de dados  da�   ��
���transportadora.�                                                                        ��
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Transport()          
Local cF3 
Local nLinha
Local uRetTrans
Local lV175CODT :=ExistBlock("V175CODT")
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
VTClear()
If lVldTransp
	If lVT100B // GetMv("MV_RF4X20")
		If ! Empty(CB7->CB7_TRANSP)
			@ 0,0 VTSay STR0019 //"Va para doca "
			@ 1,0 VTSay STR0020 //"referente a  "
			@ 2,0 VTSay STR0021 //"transportadora:"
			@ 3,0 VTSay CB7->CB7_TRANSP
			VTPause
			VTClear
			@ 1,0 VTSay STR0022 //"Confirme a "
			@ 2,0 VTSay STR0023 //"transportadora"
			nLinha:= 7
		Else
			@ 0,0 VTSay STR0024 //"Leia o codigo da"
			@ 1,0 VTSay STR0021 //"transportadora:"
			@ 2,0 VTSay STR0025 //"para embarcar"
			nLinha := 3
		EndIf
	ElseIf VtModelo()=="RF"
		If ! Empty(CB7->CB7_TRANSP)
			@ 0,0 VTSay STR0019 //"Va para doca " 
			@ 1,0 VTSay STR0020 //"referente a  " 
			@ 2,0 VTSay STR0021 //"transportadora:" 
			@ 3,0 VTSay CB7->CB7_TRANSP
			@ 5,0 VTSay STR0022 //"Confirme a " 
			@ 6,0 VTSay STR0023 //"transportadora" 
			nLinha:= 7
		Else
			@ 0,0 VTSay STR0024 //"Leia o codigo da" 
			@ 1,0 VTSay STR0021 //"transportadora:" 
			@ 2,0 VTSay STR0025 //"para embarcar" 
			nLinha := 3
		EndIf  
	ElseIf VtModelo()=="MT44"
		If ! Empty(CB7->CB7_TRANSP)
			@ 0,0 VTSay STR0022+STR0023+ CB7->CB7_TRANSP //"Confirme a transportadora "
		Else
			@ 0,0 VTSay STR0026+STR0023 //"Informe a Transportadora" 
		EndIf
		nLinha := 1	
	ElseIf VtModelo()=="MT16"
		If ! Empty(CB7->CB7_TRANSP)
		VtClear()	
		@ 0,0 VTSay STR0022 //"Confirme a "
		@ 1,0 VTSay STR0023 //"Transportadora"	   
		VtInkey(0)
		VtClear()
			@ 0,0 VTSay "Transp.: "+CB7->CB7_TRANSP
		Else
		VtClear()	
		@ 0,0 VTSay  STR0026 //"Informe a "
		@ 1,0 VTSay  STR0023 //"Transportadora"	   
		VtInkey(0)
		VtClear()
			@ 0,0 VTSay STR0023 //"Transportadora" 
		EndIf
		nLinha:= 1
	EndIf   

	while .t.
		VtClearBuffer()
		If UsaCB0('06')
			cTranspConf := Space(10)
		Else
			cTranspConf := Space(6)
			cF3 := 'SA4'
		EndIf
		If lV175CODT
			uRetTrans := ExecBlock("V175CODT",.F.,.F.)
			If(ValType(uRetTrans)=="C") 
				cTranspConf := uRetTrans
			EndIf
		EndIf
		@ nLinha,0 VTGet cTranspConf  pict "@!" Valid VldConfTransp(cTranspConf) F3 cF3
		VTRead
		If VtLastKey() == 27
			Return .f.
		EndIf
		Exit
	End
EndIf	
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �VldConfTransp� Autor � ACD                � Data � 03/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Validacao da Transportadora                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldConfTransp(cTranspConf)
Local lACD175VE := ExistBlock("ACD175VE")
Local aRet      := {}
Local lRet      := .T.

If UsaCB0("06")  // se usar CB0 para dispositivo
	aRet := CBRetEti(cTranspConf,"06")
	If lACD175VE
		aRet:=ExecBlock('ACD175VE',,,{aRet,"06"})
	EndIf	
	If Empty(aRet)
		VtAlert(STR0027,STR0002,.t.,4000,3) //### "Etiqueta invalida","Aviso"
		VtClearGet("cTranspConf")
		lRet := .F.
	EndIf
Else
	aRet := {PadR(cTranspConf,6)}
EndIf

If !Empty(CB7->CB7_TRANSP) .and. CB7->CB7_TRANSP <> aRet[1]
	VtBeep(3)
	VtAlert(STR0053,STR0002,.T.,4000) //"Transportadora invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	lRet:= .F.
EndIf

If lRet
	SA4->(DbSetOrder(1))
	If !SA4->(DbSeek(xFilial()+aRet[1]))
		VtAlert(STR0023+STR0009,STR0002,.T.,4000,3)  //### "Transportadora nao encontrada","Aviso"
		VtClearGet("cTranspConf")
		lRet := .F.
	EndIf
EndIf

If lRet
	RecLock("CB7")
	CB7->CB7_TRANSP := aRet[1]
	CB7->(MsUnlock())
EndIf	

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � FimEmbarq  � Autor � ACD                 � Data � 09/03/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Finalisa o processo de Impressao de NFS                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/              
Static Function FimEmbarq(nSai)
Local _cStatus := CB7->CB7_STATUS
Local _cPausa  := " "
Local lACD175FI := ExistBlock("ACD175FI") 
Default nSai := 1 

CB9->(DbSetOrder(5))
If !CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"1")) .AND. ;
	!CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"2")) 
   _cStatus := "9"	//Embarque finalizado
   _cPausa  := " "   //Sem pausa
   VTAlert(STR0001,STR0002,.t.,4000) 
ElseIf CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"3")) .AND.;
		(CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"1")) .OR. ;
		 CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"2")))
   _cStatus := "8"  //Embarcando
   _cPausa  := "1"  //Pausada
Else              
	 // Retorna para processo anterior 
	_cStatus :=  CBAntProc(CB7->CB7_TIPEXP,"06*")
	_cPausa  := "1"  //Pausada
EndIf

RecLock("CB7",.F.)
CB7->CB7_STATUS := _cStatus
CB7->CB7_STATPA := _cPausa
CB7->(MsUnLock())

//��������������������������������������������������������������������Ŀ
//� Ponto de entrada para Customizacoes apos gravar dados Embarque     �
//����������������������������������������������������������������������
If lACD175FI
       ExecBlock("ACD175FI",.F.,.F.,{CB7->CB7_ORDSEP})
EndIf       

//Verifica se esta sendo chamado pelo ACDV170 e se existe um avanco 
//ou retrocesso forcado pelo operador
If ACDGet170() .AND. A170AvOrRet() 
 	nSai := A170ChkRet()         
EndIf
Return nSai


Static Function Embarque()
Local cEtiqProd
Local cProduto
Local cPictQtdExp := PesqPict("CB8","CB8_QTDORI")
Local nQtde
Local lForcaQtd   := GetMV("MV_CBFCQTD",,"2") =="1"     
Private cVolume   := Space(10)
Private lEmbarque := .t.
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

While .T.
	VTClear           
	If lVT100B // GetMv("MV_RF4X20")
		@ 0,0 VTSay "Transp." +CB7->CB7_TRANSP+" "+SubStr(cDesTra,1,20)		
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
			cVolume := Space(10)
			@ 02,00 VtSay STR0028 //"Leia o volume"
			@ 03,00 VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume)
		Else
			nQtde := 1
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If ! Usacb0("01")
				@ 1,0 VTSay 'Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 2,0 VTSay STR0031 // STR0031->Embarcar Produto
			@ 3,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,Nil)
		EndIf
	ElseIf VtModelo()=="RF"
		@ 0,0 VTSay STR0023 //Transportadora
		@ 1,0 VTSay CB7->CB7_TRANSP
		@ 2,0 VtSay SubStr(cDesTra,1,20)
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
			cVolume := Space(10)
			@ 06,00 VtSay STR0028 //"Leia o volume" 
			@ 07,00 VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume)
		Else
			nQtde := 1
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If ! Usacb0("01")
				@ 4,0 VTSay 'Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 5,0 VTSay  STR0029 //'Leia o produto' 
			@ 6,0 VtSay  STR0030 //'a embarcar' 
			@ 7,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,Nil)
		EndIf
	ElseIf VtModelo()=="MT44" 
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
		@ 0,0 VTSay "Transp." +CB7->CB7_TRANSP+" "+SubStr(cDesTra,1,20)
			cVolume := Space(10)
			@ 01,00 VtSay STR0028 VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume) //STR0028 -> Leia o volume
		Else         
		@ 0,0 VTSay "Transp." +CB7->CB7_TRANSP
			nQtde := 1   
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If ! Usacb0("01")
				@ 0,17 VTSay 'Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 1,0 VTSay STR0031 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,Nil) // STR0031->Embarcar Produto
		EndIf           
	ElseIf VtModelo()=="MT16"	
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
		@ 0,0 VTSay "Transp." +CB7->CB7_TRANSP
			cVolume := Space(10)
			@ 01,00 VtSay STR0032 VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume) // STR0032 ->Volume
		Else         
			nQtde := 1   
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If Usacb0("01")
			@ 0,0 VTSay "Transp." +CB7->CB7_TRANSP
			Else
				@ 0,0 VTSay 'Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 1,0 VTSay STR0033 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,Nil) //STR0033->Produto
		EndIf           
	EndIf
	VtRead
	If VtLastKey() == 27
		Return .f.
	EndIf
	CB9->(DbSetOrder(5))
	If ! CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"1")) .and. ! CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"2"))
		Exit
	EndIF
EndDo
RecLock("CB7")
CB7->CB7_STATUS := "9"    //embarcado/finalizado
CBLogExp(cOrdSep)
CB7->(MsUnlock())
//VTAlert('Processo de embarque finalizado','Aviso',.t.,4000) //'Processo de expedicao finalizado'###
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � VldEbqVol� Autor � ACD                   � Data � 08/03/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao do Volume no embarque e no estorno do embarque   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldEbqVol(cVolume,lEstorna)
Local lACD175VE  := ExistBlock("ACD175VE")
Local lACD175VO  := ExistBlock("ACD175VO")
Local aRet       := {}
Local cVolOri
Default lEstorna := .F.

If Empty(cVolume)
	Return .f.
EndIf

If lACD175VO
	cVolOri := cVolume
	cVolume := ExecBlock("ACD175VO",.F.,.F.,{cVolume})
	If (ValType(cVolume)<>"C") .OR. (ValType(cVolume)=="C" .AND. Empty(cVolume))
		cVolume := cVolOri
	EndIf
EndIf

If UsaCB0("05")
   aRet:= CBRetEti(cVolume,"05")
	If lACD175VE
		aRet:=ExecBlock('ACD175VE',,,{aRet,"05"})
	Endif   
   If Empty(aRet)
	   VtAlert(STR0034,STR0002,.t.,4000,3) //###"Etiqueta de volume invalida","Aviso"
	   VtKeyboard(Chr(20))  // zera o get
	   Return .f.
   EndIf
   cCodVol:= aRet[1]   
Else
   cCodVol:= cVolume
EndIf

CB6->(DbSetOrder(1))
If ! CB6->(DbSeek(xFilial("CB6")+cCodVol))
	VtAlert(STR0035+cCodVol,STR0002,.t.,4000,3) //###"Codigo de volume nao cadastrado "+cCodVol,"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
If lEstorna
	If CB6->CB6_STATUS # "5"
		VtAlert(STR0036,STR0002,.t.,4000) //### "Volume nao embarcado","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
EndIf
CB9->(DbSetOrder(4))
If !CB9->(DbSeek(xFilial("CB9")+cCodVol))
	VtAlert(STR0037,STR0002,.t.,4000) //### "Volume nao encontrado","Aviso"
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
If CB9->CB9_ORDSEP # CB7->CB7_ORDSEP
	VtAlert(STR0032+STR0038+STR0008+CB9->CB9_ORDSEP,STR0002,.t.,4000,3) //### "Volume pertence a outra ordem de separacao "+CB9->CB9_ORDSEP,"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
If lEstorna
	IF ! VtYesNo(STR0039,STR0002,.t.) //### "Confirma o estorno?","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
Else
	IF CB9->CB9_STATUS =="3"
		VtAlert(STR0040,STR0002,.t.,4000,3) //### "Volume ja lido","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
EndIf

CB9->(DbSetOrder(2))
CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+cCodVol))
While CB9->(! EOF() .and. CB9_FILIAL+CB9_ORDSEP+CB9_VOLUME == ;
	xFilial("CB9")+cOrdSep+cCodVol)
	RecLock("CB9")
	If lEstorna
		CB9->CB9_QTEEBQ := 0.00
		CB9->CB9_STATUS := "2"  // EMBALAGEM FINALIZADA
	Else
		CB9->CB9_QTEEBQ := CB9->CB9_QTESEP
		CB9->CB9_STATUS := "3"  // EMBARCADO
	EndIf
	CB9->(MsUnLock())
	CB9->(DBSkip())
End
RecLock("CB6")
If lEstorna
	If CBAntProc(CB7->CB7_TIPEXP,"06*") == "7"
		CB6->CB6_STATUS := "3"   // VOLUME ENCERRADO
	Else
		CB6->CB6_STATUS := "1"   // VOLUME EM ABERTO
	EndIf		
	CB6->CB6_CODEB1 := ""
	CB6->CB6_CODEB2 := ""
Else
	CB6->CB6_STATUS := "5"   // EMBARQUE
	CB6->CB6_CODEB1 := cCodOpe
	CB6->CB6_CODEB2 := cCodOpe
EndIf
CB6->(MsUnlock())
VtKeyboard(Chr(20))  // zera o get
Return ! lEstorna

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �  VldQtde � Autor � ACD                   � Data � 09/03/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao da quantidade informada                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAACD															        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldQtde(nQtde,lSerie)
Local   lRet := .T.
Default lSerie:=.F.

If nQtde <= 0
   Return .F.
Endif
If lSerie .and. nQtde > 1
   VTAlert(STR0041,STR0002,.T.,2000,3) //###  "Quantidade invalida !""Aviso"
   VTAlert(STR0042,STR0002,.T.,4000) //### "Quando se utiliza numero de serie a quantidade deve ser == 1","Aviso"
   Return .F.
Endif

If Existblock("ACD175QTD") 
	lRet:=ExecBlock("ACD175QTD",.F.,.F.,{nQtde})
	If ValType(lRet) == "L"
	   	Return lRet
   	EndIf
EndIf 
 	
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �VldProdEbq� Autor � ACD                   � Data � 09/03/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Validacao do Produto no embarque e no estorno do embarque   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAACD                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldProdEbq(cEProduto,nQtde,lEstorna)
Local cTipo
Local aEtiqueta,aRet
Local aCB9Atu  := {}
Local aItensPallet := CBItPallet(cEProduto)
Local cLote    := Space(TamSX3("B8_LOTECTL")[1])
Local cSLote   := Space(TamSX3("B8_NUMLOTE")[1])
Local cNumSer  := Space(TamSX3("BF_NUMSERI")[1])
Local cProduto := ""
Local cFilCB9  := xFilial("CB9")
Local nTamVol  := TamSX3("CB9_VOLUME")[1]
Local nQE      :=0
Local nQEConf  :=0
Local nQtdBaixa:=0
Local nX       :=1
Local nSaldoEmb:=0
Local nSaldoEtq:=0
Local lACD175VE:= ExistBlock("ACD175VE")
Local lIsPallet:= .F.
Local lFirst   := .T.
Local lChkqemb := SuperGetMV("MV_CHKQEMB",.F.,"1") == "1"

Default lEstorna := .F.

If !CBLoad128(@cEProduto)
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

If Len(aItensPallet) > 0 .And. UsaCB0("01")
	lIsPallet := .T.
EndIf

cTipo := CBRetTipo(cEProduto)
If cTipo == "01"
	aEtiqueta:= CBRetEti(cEProduto,"01") 
	If lACD175VE
		aEtiqueta:=ExecBlock('ACD175VE',,,{aEtiqueta,"01"})
	EndIf		
	If Empty(aEtiqueta)
		VtAlert(STR0027,STR0002,.t.,4000,3) //### "Etiqueta invalida","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If !Empty(aEtiqueta[21])
		VtAlert(STR0054,STR0002,.t.,4000,3) //### "Etiqueta invalida, produto pertence a um pallet" "AVISO"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	CB9->(DbSetorder(1))
	If ! CB9->(DbSeek(cFilCB9+cOrdSep+CB0->CB0_CODETI))
		VtAlert(STR0043,STR0002,.t.,4000,3) //### "Produto nao separado" "AVISO"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	
	nSaldoEtq := aEtiqueta[2]
	While !CB9->(EOF()) .And. CB9->(CB9_FILIAL+CB9_ORDSEP+CB9_CODETI) == cFilCB9+cOrdSep+CB0->CB0_CODETI

		cProduto	:= aEtiqueta[1]		
		nQE     	:= IIF(nSaldoEtq > CB9->CB9_QTESEP,CB9->CB9_QTESEP,nSaldoEtq)
		nSaldoEtq 	-= nQE
		
		cLote   	:= aEtiqueta[16]
		cSLote  	:= aEtiqueta[17]
		nQEConf 	:= nQE
		If ! CBProdUnit(aEtiqueta[1]) .and. lChkqemb
			nQEConf := CBQtdEmb(aEtiqueta[1])
		EndIf
		If Empty(nQEConf) .or. nQE # nQEConf
			VtAlert(STR0041,STR0002,.t.,4000,3) //### "Quantidade invalida""Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
		If lEstorna
			If CB9->CB9_STATUS == "1"  // STATUS=1 (EM ABERTO)
				VtAlert(STR0031,STR0002,.t.,4000,3) //### "Produto nao embarcado","Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .f.
			EndIf
			If ! VtYesNo(STR0039,STR0002,.t.) //### "Confirma o estorno?","Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .F.
			EndIf
		Else
			If CB9->CB9_STATUS # "1"  // STATUS=1 (EM ABERTO)
				VtAlert(STR0031,STR0002,.t.,4000,3) //### "Produto ja embarcado","Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .f.
			EndIf
		EndIf
		aAdd(aCB9Atu,{CB9->(Recno()),nQE})
		
		CB9->(dbSkip())
	End
	For nX := 1 To Len(aCB9Atu)
		CB9->(dbGoTo(aCB9Atu[nX,1]))
		RecLock("CB9",.F.)
		If lEstorna
			CB9->CB9_QTEEBQ := 0
			CB9->CB9_STATUS := "1"  // em aberto
		Else
			CB9->CB9_QTEEBQ += aCB9Atu[nX,2]
			CB9->CB9_STATUS := "3"  // embarcado
		EndIf
		CB9->(MsUnlock())
	Next nX

ElseIf cTipo $ "EAN8OU13-EAN14-EAN128"
	aRet     := CBRetEtiEan(cEProduto)
	If lACD175VE
		aRet:=ExecBlock('ACD175VE',,,{aRet,"01"})
	Endif	
	If Empty(aRet)
		VtAlert(STR0027,STR0002,.t.,4000,3) //### "Etiqueta invalida","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cProduto := aRet[1]
	If ! CBProdUnit(cProduto)
		VtAlert(STR0027,STR0002,.t.,4000,3)  //### "Etiqueta invalida","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	
	If cTipo $ "EAN8OU13"
		nQE  := aRet[2] * nQtde
	Else
		nQE  := CBQtdEmb(cProduto)*nQtde
	EndIf	
	
	If Empty(nQE)
		VtAlert(STR0041,STR0002,.t.,4000,3) //### "Quantidade invalida" "Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cLote := aRet[3]
	If ! CBRastro(aRet[1],@cLote,@cSLote)
		VTKeyBoard(chr(20))
		Return .f.
	EndIf   
	cNumSer:= aRet[5]
	If Empty(cNumSer) .and. CBSeekNumSer(cOrdSep,cProduto)
      If ! VldQtde(nQtde,.T.)
         VtKeyboard(Chr(20))  // zera o get
		   Return .F.
      Endif
      If ! CBNumSer(@cNumSer)
         VTKeyBoard(chr(20))
         Return .f.
      EndIf
   EndIf
	CB9->(DbSetorder(8))
	If ! CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+ Space(nTamVol)))
		VtAlert(STR0044,STR0002,.t.,4000,3)  //### "Produto invalido","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	nSaldoEmb:=0
	While CB9->(! EOF() .AND. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_VOLUME ==;
		xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+space(nTamVol))
		If lEstorna
			nSaldoEmb += CB9->CB9_QTEEBQ
		Else
			nSaldoEmb += CB9->CB9_QTESEP-CB9->CB9_QTEEBQ
		EndIf
		CB9->(DbSkip())
	Enddo
	If nQE > nSaldoEmb
		VtBeep(3)
		If lEstorna
			VtAlert(STR0045,STR0002,.t.,4000)  //### "Quantidade informada maior que a quantidade embarcada","Aviso"
		Else
			VtAlert(STR0046,STR0002,.t.,4000) //### "Quantidade informada maior que disponivel para o embarque","Aviso"
		EndIf
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If lEstorna
		If ! VtYesNo(STR0039,STR0002,.t.) //### "Confirma o estorno?","Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	EndIf
	nSaldoEmb := nQE
	nQtdBaixa :=0
	CB9->(DbSetorder(8))
	CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+space(nTamVol)))
	While CB9->(! EOF() .AND. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_VOLUME ==;
		xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+space(nTamVol)) .and. ! Empty(nSaldoEmb)
		If lEstorna
			If Empty(CB9->CB9_QTEEBQ)
				CB9->(DBSkip())
				Loop
			EndIf
		Else
			If CB9->CB9_STATUS == '3'
				CB9->(DBSkip())
				Loop
			EndIf
		EndIf
		nQtdBaixa := nSaldoEmb
		If lEstorna
			If nSaldoEmb >= CB9->CB9_QTEEBQ
				nQtdBaixa := CB9->CB9_QTEEBQ
			EndIf
		Else
			If nSaldoEmb >= (CB9->CB9_QTESEP-CB9->CB9_QTEEBQ)
				nQtdBaixa := (CB9->CB9_QTESEP-CB9->CB9_QTEEBQ)
			EndIf
		EndIf
		RecLock("CB9")
		If lEstorna
			CB9->CB9_QTEEBQ -=nQtdBaixa
			CB9->CB9_STATUS := "1"  // em aberto
		Else
			CB9->CB9_QTEEBQ +=nQtdBaixa
			If CB9->CB9_QTEEBQ == CB9->CB9_QTESEP
				CB9->CB9_STATUS := "3"  // embarcado
			EndIf
		EndIf
		CB9->(MsUnlock())
		nSaldoEmb -=nQtdBaixa
		CB9->(DbSkip())
	Enddo
ElseIf lIsPallet
	Begin Transaction
	For nX:= 1 to Len(aItensPallet)
		cEProduto := aItensPallet[nX]
		aEtiqueta := CBRetEti(cEProduto,"01") 
		If lACD175VE
			aEtiqueta:=ExecBlock('ACD175VE',,,{aEtiqueta,"01"})
		EndIf		
		If Empty(aEtiqueta)
			VtAlert(STR0027,STR0002,.t.,4000,3) //### "Etiqueta invalida","Aviso"
			VtKeyboard(Chr(20))  // zera o get
			DisarmTransaction()
			Break
		EndIf
		CB9->(DbSetorder(1))
		If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+Left(cEProduto,10)))
			VtAlert(STR0043,STR0002,.t.,4000,3) //### "Produto nao separado" "AVISO"
			VtKeyboard(Chr(20))  // zera o get
			DisarmTransaction()
			Break
		EndIf
		cProduto:= aEtiqueta[1]
		nQE     := aEtiqueta[2]
		cLote   := aEtiqueta[16]
		cSLote  := aEtiqueta[17]
		nQEConf := nQE
		If ! CBProdUnit(aEtiqueta[1]) .and. lChkqemb
			nQEConf := CBQtdEmb(aEtiqueta[1])
		EndIf
		If Empty(nQEConf) .or. nQE # nQEConf
			VtAlert(STR0041,STR0002,.t.,4000,3) //### "Quantidade invalida""Aviso"
			VtKeyboard(Chr(20))  // zera o get
			DisarmTransaction()
			Break
		EndIf
		If lEstorna
			If CB9->CB9_STATUS == "1"  // STATUS=1 (EM ABERTO)
				VtAlert(STR0031,STR0002,.t.,4000,3) //### "Produto nao embarcado","Aviso"
				VtKeyboard(Chr(20))  // zera o get
				DisarmTransaction()
				Break
			EndIf
			If lFirst
				If ! VtYesNo(STR0039,STR0002,.t.) //### "Confirma o estorno?","Aviso"
					VtKeyboard(Chr(20))  // zera o get				
					DisarmTransaction()
					Break
				EndIf
				lFirst := .F.
			EndIf
		Else
			If CB9->CB9_STATUS # "1"  // STATUS=1 (EM ABERTO)
				VtAlert(STR0031,STR0002,.t.,4000,3) //### "Produto ja embarcado","Aviso"
				VtKeyboard(Chr(20))  // zera o get				
				DisarmTransaction()
				Break
			EndIf
		EndIf
		If lEstorna
			RecLock("CB9")
			CB9->CB9_QTEEBQ := 0.00
			CB9->CB9_STATUS := "1"  // em aberto
			CB9->(MsUnlock())
		Else
			RecLock("CB9")
			CB9->CB9_QTEEBQ += nQE
			CB9->CB9_STATUS := "3"  // embarcado
			CB9->(MsUnlock())
		EndIf
	Next
	End Transaction
	If !(nX > Len(aItensPallet))
		Return .F.
	Endif
Else
	VtAlert(STR0027,STR0002,.t.,4000,3) //### "Etiqueta invalida","Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

nQtde:=1
VTGetRefresh('nQtde')
VtKeyboard(Chr(20))  // zera o get
Return ! lEstorna


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � Informa  � Autor � ACD                   � Data � 17/03/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Mostra as etiquetas lidas o tipo e a quantidade das mesmas ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Informa()
Local cPallet                
Local nRecCB9 := CB9->(RecNo())
Local cTipo                       
Local nPos
Local aCab      := {}
Local aSize     := {}
Local aSave     := VTSAVE()              
Local aAreaCB9  := CB9->(GetArea())
Local aEtiqueta := {}
Local aDados    := {}
Local lACD175VE := ExistBlock("ACD175VE")

VTClear()
If UsaCB0("01")
   aCab  := {STR0048,STR0047,STR0008} //###### "Etiqueta","Tipo","Ordem Separacao"
   aSize := {10,10,15}
   CB9->(DbSetOrder(1))
   CB9->(DbSeek(xFilial("CB9")+cOrdSep))
   While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
      cTipo  := CBRetTipo(CB9->CB9_CODETI)
   	cPallet:= RetPallet(CB9->CB9_CODETI)   	
   	If cTipo == "05"   		// --> Etiqueta de Volume         
      	aadd(aDados,{CB9->CB9_CODETI,STR0032,CB9->CB9_ORDSEP})  // STR0032 -> Volume
   	Elseif cTipo == "01" .and. Empty(cPallet)  // --> Etiqueta de Produto  com CB0	  
	   	aadd(aDados,{CB9->CB9_CODETI,STR0033,CB9->CB9_ORDSEP})		 // STR0033 -> Produto
   	Elseif ! Empty(cPallet)  // --> Etiqueta de Pallet			 
         aEtiqueta:= CBRetEti(CB9->CB9_CODETI)
			If lACD175VE
				aEtiqueta:=ExecBlock('ACD175VE',,,{aEtiqueta,"01"})
			EndIf	
         If Alltrim(CB0->CB0_PALLET) # Alltrim(cPallet)    
         	CB9->(DbSkip())
            Loop
         Endif
  			If ascan(aDados,{|x|x[1] == cPallet})== 0 // Adiciona o Pallet somente uma vez
     	      aadd(aDados,{cPallet,"Pallet",CB9->CB9_ORDSEP}) //
 			Endif                        
   	EndIf   	
      CB9->(DbSkip())
   EndDo
   aDados := aSort(aDados,,,{|x,y| x[2] < y[2]})   
Else
   aCab  := {STR0033,STR0032,"Qtd.Sep","Qtd.Embq"}  //"Produto","Volume","Qtd.Sep","Qtd.Embq"
   aSize := {15,10,9,9}              
   CB9->(DbSetOrder(12))
   CB9->(DbSeek(xFilial("CB9")+cOrdSep))
   While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
   	nPos := AsCan(aDados,{|x| x[1]+x[2]+x[5]==CB9->(CB9_PROD+CB9_VOLUME+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)})
   	If Empty(nPos)
			CB9->(aadd(aDados,{CB9_PROD,CB9_VOLUME,CB9_QTESEP,CB9_QTEEBQ,CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER}) )
		Else
			aDados[nPos,3] += CB9->CB9_QTESEP
			aDados[nPos,4] += CB9->CB9_QTEEBQ
		EndIf
   	CB9->(DbSkip())
   EndDo
Endif   
VTaBrowse(0,0,VTMaxRow(),VTMaxCol(),aCab,aDados,aSize)
VtRestore(,,,,aSave)
RestArea(aAreaCB9)
CB9->(DbGoto(nRecCB9))
Return                 



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � Estorna  � Autor � Anderson Rodrigues    � Data � 15/07/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Realiza estorno dos volumes embarcados                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Estorna()
Local ckey24  := VTDescKey(24)
Local bkey24  := VTSetKey(24)
Local aTela   := VTSave()
Local cEtiqueta  
Local cVolume
Local cProduto
Local nQtde
Local lForcaQtd   := GetMV("MV_CBFCQTD",,"2") =="1"     
Local cPictQtdExp := PesqPict("CB8","CB8_QTDORI")
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
VTSetKey(24,Nil)        

While .t.
	VTClear()           
		If lVT100B // GetMv("MV_RF4X20")
			@ 0,0 VtSay Padc(STR0049,VTMaxCol())  // STR0049->"Estorno do embarque"
			If '01' $ CB7->CB7_TIPEXP .or.; 
			'02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
				cVolume := Space(10)
				@ 02,00 VtSay  STR0028 // "Leia o volume"
				@ 03,00 VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume,.t.)
			Else
				nQtde := 1
				cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
				If ! Usacb0("01")
					@ 1,0 VTSay 'Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
				EndIf
				@ 2,0 VtSay  STR0031 //STR0031->Embarcar Produto
				@ 3,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,.t.)
			EndIf
		ElseIf VtModelo()=="RF"
		@ 0,0 VtSay Padc(STR0049,VTMaxCol())  // STR0049->"Estorno do embarque"
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
			cVolume := Space(10)
			@ 06,00 VtSay  STR0028 // "Leia o volume"
			@ 07,00 VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume,.t.)
		Else
			nQtde := 1
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If ! Usacb0("01")
				@ 4,0 VTSay 'Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 5,0 VTSay  STR0029 // 'Leia o produto' 
			@ 6,0 VtSay  STR0030 // 'a embarcar' 
			@ 7,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,.t.)						
		EndIf
	ElseIf VtModelo()=="MT44" 
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
			cVolume := Space(10)                                                            
			@ 0,0 VtSay Padc(STR0049,VTMaxCol()) // STR0049->"Estorno do embarque"
			@ 1,00 VtSay STR0028 VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume,.t.) // "Leia o volume"
		Else         
			nQtde := 1   
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If Usacb0("01")       
			   @ 0,0 VtSay Padc(STR0049,VTMaxCol())// STR0049->"Estorno do embarque"
			Else
				@ 0,0 VTSay 'Estorno: Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 1,0 VTSay STR0033 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,.T.) // "STR0033 ->Produto"
		EndIf           
	ElseIf VtModelo()=="MT16"	
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
			cVolume := Space(10)                                 
			@ 0,0 VtSay Padc(STR0049,VTMaxCol())	// STR0049->"Estorno do embarque"		
			@ 1,0 VtSay STR0032 VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume,.t.) //STR0032 ->"Volume"
		Else         
			nQtde := 1   
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If  Usacb0("01")
				@ 0,0 VtSay Padc(STR0049,VTMaxCol())	// STR0049->"Estorno do embarque"			
			Else
				@ 0,0 VTSay 'Est.Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 1,0 VTSay STR0033 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,.T.) //STR0033 -> Produto
		EndIf           
	EndIf
	VtRead
	If VtLastKey() == 27	
		Exit
	EndIf
	//Se nao existir mais nenhum produto embarcado para esta ordem
	//de separacao aborta estorno
	CB9->(DbSetOrder(5))
	If ! CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"3"))
		Exit
	EndIF
EndDo

VTRestore(,,,,aTela)
VTSetKey(24,bkey24,cKey24)        
Return 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �RetPalletCB9� Autor � ACD                 � Data � 03/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Verifica se existe o Pallet para a etiqueta informada       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function RetPallet(cEtiqueta)
Local cPallet:= " "
Local aArea  := CB0->(GetArea())

If ! UsaCB0("01") .or. Empty(cEtiqueta)
   Return(cPallet)
EndIf

CB0->(DbSetOrder(1))
If CB0->(DbSeek(xFilial("CB0")+cEtiqueta)) 
   cPallet:= CB0->CB0_PALLET
EndIf
RestArea(aArea)
Return(cPallet)

