#include "QIPA040.CH"
#include "TOTVS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPA040  � Autor � Cleber Souza          � Data � 05/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Grupo de Produtos               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001)  ,"AxPesqui"  , 0 , 1,,.F.},; //"Pesquisa" 
                     {OemToAnsi(STR0002)  ,"QP040GPr"  , 0 , 2},;     //"Visualiza"
                     {OemToAnsi(STR0003)  ,"QP040GPr"  , 0 , 3},;     //"Incluir" 
                     {OemToAnsi(STR0004)  ,"QP040GPr"  , 0 , 4},;     //"Alterar" 
                     {OemToAnsi(STR0005)  ,"QP040GPr"  , 0 , 5 , 3} } //"Excluir"


Return aRotina

Function QIPA040(xAutoCab,xAutoItens,nOpcAuto)
PRIVATE l040Auto   := xAutoCab <> NIL  .And. xAutoItens <> NIL
PRIVATE aAutoCab   := {}
PRIVATE aAutoItens := {}

PRIVATE __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
PRIVATE lProduto   := .F.
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0006)  //"Grupos de Produtos" 

DEFAULT nOpcAuto := 3

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//���������������������������������������������������������������� 
PRIVATE aRotina := MenuDef()

//�������������������������������������������Ŀ
//�Tratamento de Rotina Automatica            �
//���������������������������������������������
If  ( Type("l040Auto") <> "U" .And. l040Auto )
	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens
	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"QP3")
	xAutoCab   := aAutoCab
	xAutoItens := aAutoItens	
Else
	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	mBrowse( 6, 1,22,75,"QP3")
EndIf

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A040GPr  � Autor � Cleber Souza          � Data � 05/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastra Produtos dos Grupos                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A040GPr(ExpC1,ExpN1,ExpN2)                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada no menu                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/ 

Function QP040GPr(cAlias,nReg,nOpc)                 

Local aPosObj    := {}
Local aStruAlias := FWFormStruct(3, "QP3")[3]
Local lExecuta   := .T.
Local nOpcA      := 0
Local nX         := 0
Local nY         := 0
Local oSize      := Nil

Private __cPRODUTO     := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo 
Private __cREVISAO     := CriaVar("QP6_REVI") //Revisao do Produto ou Grupo
Private __cROTEIRO     := CriaVar("QP6_CODREC") //Roteiro de Operacoes do Produto ou Grupo 
Private __dREVISAO     := CriaVar("QP6_DTINI") //Vigencia do Produto ou Grupo
Private __lQIP010JR    := ExistBlock("QIP010JR")
Private __lQP010DEL    := ExistBlock("QP010DEL")
Private __lQP010GRV    := ExistBlock("QP010GRV")
Private __lQP010J11    := ExistBlock("QP010J11")
Private __lQP010OPE    := ExistBlock("QP010OPE")
Private __lQPA010R     := ExistBlock("QPA010R")
Private __lQPATUGRV    := ExistBlock("QPATUGRV")
Private __lQPATUSB1    := ExistBlock("QPATUSB1")
Private aCols          := {}
Private aColsAnt       := {}
Private aCpoQP3        := {{}, {}}
Private aespecificacao := {}
Private aGets          := {}
Private aHeader        := {}
Private aHeaderQP7     := QPA010HeadEsp(aClone(APBuildHeader("QP7"))) //Prepara o aHeader com os demais campos a serem utilizados na Especificacao
Private aHeaderQP9     := aClone(APBuildHeader("QP9"))
Private aHeaderQQ1     := aClone(APBuildHeader("QQ1"))
Private aHeaderQQ2     := AClone(APBuildHeader("QQ2"))
Private aHeaderQQH     := AClone(APBuildHeader("QQH")) //somente para montagem da estrutura 
Private aHeaderQQK     := aClone(APBuildHeader("QQK"))
Private aroteiros      := {}
Private aTela          := {}
Private cEspecie       := "QIPA010 "
Private lIntQMT        := If(GetMV( 'MV_QIPQMT' )=="S",.T.,.F.) //Define a Integracao com o QMT  
Private nPosAFI        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_AFI" })
Private nPosAFS        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_AFS" })
Private nPosAli        := 0
Private nPosAmo        := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_AMOST" })
Private nPosChav       := AsCan(aHeaderQQK,{|x|AllTrim(x[2])=="QQK_CHAVE" })
Private nPosCla        := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_CLASSE"})
Private nPosDCl        := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_DESCLA"})
Private nPosDesc       := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_DESC" })
Private nPosDescr      := Ascan(aHeaderQQ1,{|x|AllTrim(x[2])=="QQ1_DESCR"})
Private nPosDNC        := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_DESNCO"})
Private nPosDoc        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_METODO"})
Private nPosDPl        := Ascan(aHeaderQP7,{|x|AllTrim(x[2])=="QP7_DESPLA"})
Private nPosDPr        := 0
Private nPosEns        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_ENSAIO"})
Private nPosInstr      := Ascan(aHeaderQQ1,{|x|AllTrim(x[2])=="QQ1_INSTR"})
Private nPosLab        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_LABOR" })
Private nPosNC         := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_NAOCON"})
Private nPosNiv        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_NIVEL" })
Private nPosNivel      := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_NIVAMO"})
Private nPosNom        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_NOMINA"})
Private nPosNQA        := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_NQA" })
Private nPosOper       := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_OPERAC" })
Private nPosPlA        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_PLAMO" })
Private nPosPlano      := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_PLANO"})
Private nPosPro        := 0
Private nPosRastr      := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_PRODUT"})
Private nPosRec        := 0
Private nPosRvDoc      := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_RVDOC" })
Private nPosSeq        := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_SEQLAB"})
Private nPosTipIn      := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_TIPO" })
Private nPosTipo       := 0
Private nPosUM         := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_UNIMED"})
Private oEncQP3        := Nil
Private oGet           := Nil

Default cRotGrp := CriaVar("QP6_CODREC")
Default cStatus := CriaVar("QP6_SITREV")

//��������������������������������������������������������������Ŀ
//� Cria o vetor com os campos a serem utilizados na Enchoice    �
//����������������������������������������������������������������
For nX := 1 To Len(aStruAlias)
	If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") 
		Aadd(aCpoQP3[1],aStruAlias[nX,1])
		Aadd(aCpoQP3[2],GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT"))
	EndIf
Next nX

//��������������������������������������������������������������Ŀ
//� Cria as variaveis para edicao na Enchoice     		         �
//����������������������������������������������������������������
RegToMemory(cAlias,If(nOpc==3,.T.,.F.),.F.)  

If nOpc != 3
	FillGetDados(nOpc,"QPA" ,1     ,       ,            ,         ,         ,          ,        ,     ,{|| QP040Cols(nOpc)},       ,          ,        ,          ,           ,            ,)
Else
	FillGetDados(nOpc,"QPA" ,1     ,      ,             ,         ,         ,          ,        ,      ,        ,  .T.  ,          ,        ,          ,           ,            ,)
EndIf

//��������������������������������������������������������������Ŀ
//� Salva aCols original                                         �
//����������������������������������������������������������������
If Altera
	aColsAnt := aClone( aCols )
Endif

//����������������������������������������������������������������������Ŀ
//� Verifica a posicao dos campos no aHeader p/ posterior consistencia   �
//������������������������������������������������������������������������
nPosPro  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_PRODUT"})
nPosDPr  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_DESPRO"})
nPosTipo := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_TIPO"})
nPosAli  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_ALI_WT"})
nPosRec  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_REC_WT"})

If ( Type("l040Auto") == "U" .Or. ! l040Auto )
	oSize := FwDefSize():New(.T.)
	
	oSize:AddObject('HEADER',100,70,.T.,.F.)
	oSize:AddObject('GRID'  ,100,10,.T.,.T.)
	
	oSize:aMargins 	:= { 3, 3, 3, 3 }
	oSize:Process()
	
	aAdd(aPosObj,{oSize:GetDimension('HEADER', 'LININI'),oSize:GetDimension('HEADER', 'COLINI'),oSize:GetDimension('HEADER', 'LINEND'),oSize:GetDimension('HEADER', 'COLEND')})
	aAdd(aPosObj,{oSize:GetDimension('GRID'  , 'LININI'),oSize:GetDimension('GRID'  , 'COLINI'),oSize:GetDimension('GRID'  , 'LINEND'),oSize:GetDimension('GRID'  , 'COLEND')})

	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0006) FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL	 //"Grupos de Produtos"

		oEncQP3 := MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,.F.,,,,,,,.T.)
		oGet    := MsGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4], nOpc,"QP040lOk","QP040TOk",,.T.,NIL,NIL,NIL,999,,,,,oDlg)			

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,IIf(Obrigatorio(aGets,aTela) .AND. oGet:TudoOk(),oDlg:End(),nOpcA:=0)},{||oDlg:End()}) CENTERED  
Else  
	If EnchAuto(cAlias,aAutoCab,{|| Obrigatorio(aGets,aTela)},aRotina[nOpc][4]) .and. MsGetDAuto(aAutoItens,"QP040lOk",{|| QP040TOk()},aAutoCab,aRotina[nOpc][4])      
		nOpcA := 1
	EndIf
EndIF

IF nOpcA == 1	// Confirma
                
	//��������������������������������������������������������������Ŀ
	//� Rotina de Exclusao do Grupo x Produtos						 �
	//����������������������������������������������������������������
	If nOpc == 5
		//�����������������������������������������������������������������Ŀ
		//�Verifica se existe  especificao para o Grupo antes de  exclui-lo �
		//�������������������������������������������������������������������
		dbSelectArea("QQC")
		dbSetorder(1)
		DbSeek(xFilial("QQC")+QP3->QP3_GRUPO)
		IF !EOF() .AND. (QQC_FILIAL+QQC_GRUPO==xFilial("QQC")+QP3->QP3_GRUPO)
			lExecuta := .F.		
			MsgAlert(OemToAnsi(STR0008))
		EndIf
		If lExecuta
			Begin Transaction
			//������������������������������������������������������Ŀ
			//� Apaga tambem do QPA -> Amarracao Grupo X Produtos    �
			//��������������������������������������������������������
			dbSelectArea('QPA')
			dbSetOrder(1)
			dbSeek( xFilial("QPA")+QP3->QP3_GRUPO )
			While !EOF() .And. QPA_FILIAL+QPA_GRUPO==xFilial("QPA")+QP3->QP3_GRUPO
				RecLock("QPA",.F.,.t.)
				dbDelete()
				MsUnLock()
				dbSkip()
			EndDo

			//��������������������������������������������������������������Ŀ
			//� Apos passar por todas as verificacoes , deleta o registro    �
			//����������������������������������������������������������������
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.)
			dbDelete()
			MsUnLock()
	
			End Transaction
        EndIf
   	//��������������������������������������������������������������Ŀ
	//� Rotina de Altera��o / Inclus�o do Grupo x Produtos			 �
	//����������������������������������������������������������������
    ElseIf nOpc == 4 .or. nOpc == 3
    
	   	//��������������������������������������������������������������Ŀ
		//� Atualizacao do Cabecalho (QP3).								 �
		//����������������������������������������������������������������
		dbSelectArea("QP3")
		dbSetOrder(1)
		If !dbSeek(xFilial("QP3")+M->QP3_GRUPO)		    
			RecLock("QP3",.T.)
			QP3->QP3_FILIAL := xFilial("QP3")
		Else
			RecLock("QP3",.F.)
		EndIf
        Aeval(aCpoQP3[1],{|x,y|QP3->&(aCpoQP3[1,y]):=M->&(aCpoQP3[1,y])})
 		MsUnlock()

	   	//��������������������������������������������������������������Ŀ
		//� Grava o arquivo QPA											 �
		//����������������������������������������������������������������

		For nX := 1 to Len(aCols)
			If !Acols[nX,Len(aHeader)+1]	// Nao esta deletado
					dbSelectArea("QPA")
					dbSetOrder(1)
					If dbSeek(xFilial("QPA") + QP3->QP3_GRUPO + aCols[nX,nPosPro])			
						RecLock("QPA",.F.)	 
					Else
						RecLock("QPA",.T.) 
					Endif
					For nY := 1 to Len(aHeader)
						If aHeader[nY,10] # "V"
							cVar := Trim(aHeader[nY][2])
							Replace &cVar. With aCols[nX,nY]
						Endif
					Next nY
					RecLock("QPA",.F.)
					QPA->QPA_GRUPO  := QP3->QP3_GRUPO
					QPA->QPA_FILIAL := xFilial("QPA")
					MsUnLock()
				If nopc == 4
					//Obtem a ultima Revisao do Produto
					cProduto := QPA->QPA_PRODUT
					cUltRev  := QA_UltRevEsp(cProduto,,,.T.,"QIP")
					
					cRevGrp:=QA_UltRvG(QPA->QPA_GRUPO,,.F.)
					QQC->(DbSetOrder(1))
					If QQC->(DbSeek(xFilial("QQC")+QPA->QPA_GRUPO))
						cRotGrp:= QQC->QQC_CODREC
						cStatus:= QQC->QQC_SITREV
						
					Endif
					
					QP6->(dbSetorder(1))
					IF QP6->(dbSeek(xFilial("QP6")+cProduto+Inverte(cUltRev)))
						If EMPTY(QP6->QP6_GRUPO) .AND. EMPTY(QP6->QP6_REVIGR)
							//Atualiza os dados referentes a Especificacao dos Produtos
							_nrec:=QP6->(RECNO())
							QP6->(dbSetOrder(4)) //Grupo+Revisao
							IF QP6->(dbSeek(xFilial("QP6")+QPA->QPA_GRUPO+cRevGrp))
								If QP6->(!Eof())
									cProduto := QP6->QP6_PRODUT
									cRevisao := QP6->QP6_REVI
									cRoteiro := QP6->QP6_CODREC
								    
									QP6->(Dbgoto(_nrec))
									//Preenche os dados referentes a Especificacao do Grupo
									_aArea:=GetArea()
									QPA010FilEsp(cProduto,cRevisao,cRoteiro)
									
									QPAAtuEsp(QP6->QP6_PRODUT,QP6->QP6_REVI,.T.,nopc)
									
									RestArea(_aArea)								
	
									//Atualiza os dados referentes ao Grupo
									RecLock("QP6",.F.)
									QP6->QP6_GRUPO  := QPA->QPA_GRUPO
									QP6->QP6_REVIGR := cRevGrp
									QP6->QP6_CODREC := cRotGrp
									QP6->QP6_SITREV := cStatus
									MsUnLock() 
								Endif
							EndIf
						
						
						
						EndIf
					EndIf             
					
				Endif
			Else
			 	//���������������������������������������Ŀ
				//� Cancela o Produto no QPA              �
				//�����������������������������������������
				dbSelectArea("QPA")
				If dbSeek(xFilial("QPA") + QP3->QP3_GRUPO + aCols[nX,nPosPro])			
					RecLock("QPA",.F.)
					dbDelete()
					MsUnLock()
				EndIf
	 		EndIf
		Next nX
    EndIf
	
	//������������������������������������������������������Ŀ
	//� Ponto ode entrada QP040GRV executado apos a gravacao �
	//��������������������������������������������������������
	If ExistBlock("QP040GRV")
		ExecBlock("QP040GRV",.F.,.F.,{nOpc,aClone(aHeader),aClone(aCols)})
	EndIf
EndIF

Return
          
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A040Cols  �Autor  � Cleber Souza       � Data �  05/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Carega aCols com os Produtos.                              ���
�������������������������������������������������������������������������͹��
���Uso       � QIPA040                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function QP040Cols(nOpc)

Local nX       := 0
Local nPosAli  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_ALI_WT"})
Local nPosRec  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QPA_REC_WT"})

//��������������������������������������������������������������Ŀ
//� Carrega aCols com os produtos relacionados.	                 �
//����������������������������������������������������������������
If nOpc<> 3 
	dbSelectArea("QPA")
	DbSetOrder(1)
	dbSeek(xFilial("QPA")+QP3->QP3_GRUPO)
	While !EOF() .And. QPA_FILIAL+QPA_GRUPO == xFilial("QPA")+QP3->QP3_GRUPO 
		Aadd(aCols,Array(Len(aHeader)+1))
	    For nX := 1 to Len(aHeader) 
		    If aHeader[nX,10] <> "V"
				aCols[Len(aCols),nX] := &("QPA->"+aHeader[nX,2])
			ElseIF aHeader[nX,10] == "V"
				If !(aHeader[nX,2] $ "QPA_ALI_WT | QPA_REC_WT")
					If aHeader[nX,2] == "QPA_DESPRO"
						aCols[Len(aCols),nX] := QIPXDePr(QPA->QPA_PRODUT)
					Else
						aCols[Len(aCols),nX] := CriaVar(AllTrim(aHeader[nX,2]))
					EndIf
				ElseIf nPosAli > 0 .and. nPosRec > 0
					aCols[Len(aCols),nPosAli] := "QPA"
					If IsHeadRec(aHeader[nPosRec,2])
						aCols[Len(aCols),nPosRec] := QPA->(RecNo())
					EndIf
				Endif	
			Endif
		Next nX	
		aCols[Len(aCols),Len(aHeader)+1] := .F.
		QPA->(dbSkip())
	Enddo    
	
Else
    Aadd(aCols,Array(Len(aHeader)+1))
	Aeval(aHeader,{|x,y|aCols[Len(aCols),y]:=CriaVar(AllTrim(aHeader[y,2]))})
	aCols[Len(aCols),Len(aHeader)+1] := .F.    
EndIf
       
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QP040lOk  � Autor � Cleber Souza          � Data � 06/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a linha digitada esta' Ok                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QP040lOk(o)

Local lRetu    :=.T.
Local nAchou   :=0
Local cProcura := aCols[n][nPosPro]

If !(aCols[n,Len(aCols[n])])  

	//�������������������������������������������������������������Ŀ
	//� Verifica se campo Produto esta' preenchido                  �
	//���������������������������������������������������������������
	If !aCols[n][Len(aHeader)+1] .And. LastKey() != 5 .And. LastKey() != 27 .And. lRetu
		If Empty(aCols[n][nPosPro])
			Help(" ",1,"QA_CPOOBR")
			lRetu:=.F.	
		EndIf
	EndIf 
	
	If lRetu
		//�������������������������������������������������Ŀ
		//� Verifica se o Produto ja' existe                �
		//���������������������������������������������������
		nAchou := Ascan(aCols,{|x| x[nPosPro] == cProcura .And. !(x[Len(aCols[n])])})
		If nAchou > 0 .And. nAchou # n
			Help(" ",1,"A040EXIPRG")
			lRetu:=.F.
		EndIf
	EndIf

	//�������������������������������������������������Ŀ
	//� Verifica se o Produto esta' cadastrado          �
	//���������������������������������������������������
	If lRetu
		If ! Empty(aCols[n][nPosPro])
			If ! ExistCpo("QP6",aCols[n][nPosPro])
				lRetu := .f.
			EndIf
		EndIf
	EndIf
	//������������������������������������������������������������Ŀ
	//� Verifica se o Produto esta' relacionado a outro Grupo      �
	//��������������������������������������������������������������
	If lRetu
		If !Empty(aCols[n][nPosPro])
			nReg := QPA->(Recno())
			QPA->(dbSetOrder(2))
			If QPA->(dbSeek(xFilial("QPA") + aCols[n][nPosPro]))
				If QPA->QPA_GRUPO <> M->QP3_GRUPO
					HELP(" ",1,"A040GRPEXI",,QPA->QPA_GRUPO,3,1)
					lRetu := .f.
				EndIf
			EndIf
			QPA->(dbSetOrder(1))
			QPA->(dbGoto(nReg))
		EndIf
	EndIf
EndIf
Return lRetu

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QP040TOk  � Autor � Cleber Souza          � Data � 06/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se toda a getdados esta' Ok                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QP040TOk(o)
Local nI, lRetu := .t.  
Local nAchado,lOpera:=.F.
Local cSeek := ""

For nI := 1 to Len(aCols)
	If !aCols[nI][Len(aCols[nI])]	//Deletado
		If !QP040lOk(o)
			lRetu := .f.
			Exit
		EndIf
		If Altera
			If aScan( aColsAnt, {|x| x[1] == aCols[nI][1]} ) > 0
				Loop
			Endif
		Endif
		//������������������������������������������������������������Ŀ
		//� Recupera a revisao ativa do produto						   �
		//��������������������������������������������������������������
		If !Empty(aCols[ni][nPosPro])
			cSeek := aCols[ni][nPosPro] + QA_UltRevEsp(aCols[ni][nPosPro],,,.T.,"QIP")
		EndIf
		//������������������������������������������������������������Ŀ
		//� Verifica se o Produto ja contem roteiro/operacoes/ensaios  �
		//��������������������������������������������������������������
		If lRetu .And. !Empty(aCols[ni][nPosPro])
			nReg := QP7->(Recno())
			QP7->(dbSetOrder(1))
			If QP7->(dbSeek(xFilial("QP7") + cSeek))
				If !Empty(aCols[ni][nPosEns]) 
					MSGSTOP(OemToAnsi(STR0009)) //"O produto informado ja possui Roteiro de Operacoes/Ensaios cadastrados"
					lRetu := .f.
				EndIf
			EndIf
		EndIf
		//������������������������������������������������������������Ŀ
		//� Verifica se o Produto ja contem roteiro/operacoes/ensaios  �
		//��������������������������������������������������������������
		If lRetu .And. !Empty(aCols[ni][nPosPro])
			nReg := QP8->(Recno())
			QP8->(dbSetOrder(1))
			If QP8->(dbSeek(xFilial("QP8") + cSeek))
				If ! Empty (QP8->QP8_ENSAIO)
					MSGSTOP(OemToAnsi(STR0009)) //"O produto informado ja possui Roteiro de Operacoes/Ensaios cadastrados"
					lRetu := .f.
				EndIf
			EndIf
		EndIf
		//������������������������������������������������������������Ŀ
		//� Verifica se o Produto ja contem roteiro/operacoes/ensaios  �
		//��������������������������������������������������������������
		If lRetu .And. Altera
			If !Empty(aCols[ni][nPosPro])
				nReg := QQK->(Recno())
				QQK->(dbSetOrder(1))
				If QQK->(dbSeek(xFilial("QQK") + cSeek))
					If !Empty(QQK->QQK_PRODUT) .and. !Empty(QQK->QQK_REVIPR)
						MSGSTOP(OemToAnsi(STR0009)) //"O produto informado ja possui Roteiro de Operacoes/Ensaios cadastrados"
						lRetu := .f.
						lopera:=.f.
			   		EndIf
					If !Empty(QQK->QQK_PRODUT) .and. !Empty(QQK->QQK_REVIPR)
						lopera  := .t.
					EndIf
				EndIf
			EndIf
		Endif
	Else
		//������������������������������������������������������������Ŀ
		//� Verifica se existem ordens de producao para o produto	   �
		//��������������������������������������������������������������
		If !Empty(aCols[ni][nPosPro])
			lRetu := QIPCheckEsp(aCols[ni][nPosPro],QA_UltRevEsp(aCols[ni][nPosPro],,,.T.,"QIP"),.F.)
			IF !lRetu
				Aviso(STR0010,STR0011+ALLTRIM(aCols[ni][nPosPro])+STR0012,{STR0013}) // "Ordem Produ��o "Produto: XXXX " nao podera ser excluido, localizado em Ordem(s) de produ��o "                                                                                                                                                                                                                                                                                                                                                                                                                                                     ,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
			EndIf
		EndIf
	Endif
Next

nAchado := Ascan(aCols,{|x| x[Len(aCols[n])] == .F.})
If nAchado == 0
	lRetu := .F.
	Help(" ",1,"SQP040VLD",,OemToAnsi(STR0007),1,0)
Endif

Return(lRetu)  

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A040DEqu � Autor � Cleber Souza          � Data � 06/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gatilho para preencher a descricao da Equipe Follow-up     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A040DEqu(ExpC1,ExpL1)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo da Equipe                                   ���
���          � ExpL1 = Indica se e' gatilho                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico-Cham. no X3_RELACAO,X3_INIBRW e gat. (QP3_EQUIPE) ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function A040DEqu(cCodEq,lGatilho)
Local lnOpc := Iif(Type('Inclui') == 'U',.T.,Inclui)
lGatilho    := Iif(lGatilho == NIL,.t.,lGatilho)

IF !lnOpc .or. lGatilho	// Se Inic. Padrao ou gatilho a partir do cod. equipe
	QP4->(dbSeek(xFilial("QP4") + cCodEq))
	Return(QP4->QP4_DESCRI)
Else
	Return Space(Len(QP4->QP4_DESCRI))
Endif

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A040VlPr � Autor � Cleber Souza          � Data � 06/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Produto                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA040 - E' chamada no X3_VALID do cpo. QPA_PRODUT - SX3  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function A040VlPr()

Local lRetu := .T.
Local nI	:= 0
Local nReg	:= 0	
Local cVar	:= &(readvar()) // Conteudo da variavel do campo NC 

//����������������������������������������������������������������Ŀ
//� Verifica se mudou o Produto (Alterou o campo ja' digitado)     �
//������������������������������������������������������������������
If !Empty(aCols[n,nPosPro]) .and. !Empty(cVar) .and. aCols[n,nPosPro] <> cVar
	Help(" ",1,"A010ALTCHA")	// Campo nao pode ser alterado	
	lRetu := .f.
EndIf

If lRetu
	//�������������������������������������������������Ŀ
	//� Verifica se o Produto esta' cadastrado          �
	//���������������������������������������������������
	aCols[n,nPosPro] := M->QPA_PRODUT
	If ! ExistCpo("QP6",aCols[n,nPosPro])
		lRetu := .f.
	EndIf
EndIf

//������������������������������������������������������������Ŀ
//� Verifica se o Produto esta' relacionado a outro Grupo      �
//��������������������������������������������������������������
If lRetu
	nReg := QPA->(Recno())
	QPA->(dbSetOrder(2))
	If QPA->(dbSeek(xFilial("QPA") + aCols[n,nPosPro]))
		If QPA->QPA_GRUPO <> QP3->QP3_GRUPO
			HELP(" ",1,"a040GRPEXI",,QPA->QPA_GRUPO,3,1)
			lRetu := .f.
		EndIf
	EndIf
	QPA->(dbSetOrder(1))
	QPA->(dbGoto(nReg))
EndIf

//�������������������������������������������������Ŀ
//� Verifica se o Produto ja' existe                �
//���������������������������������������������������
If lRetu
	For nI := 1 to len(aCols)
		If cVar == acols[nI,nPosPro] .and. nI <> n
			Help(" ",1,"A040EXIPRD")
			acols[n,nPosPro]	:= CriaVar("QPA_PRODUT")
			M->QPA_PRODUT		:= acols[n,nPosPro]
		EndIf
	Next nI
EndIf

//�������������������������������������������������Ŀ
//� Preenche a Descricao e Tipo do Produto          �
//���������������������������������������������������
If lRetu
	aCols[n,nPosDPr] := QIPXDePr(aCols[n,nPosPro])
	aCols[n,nPosTipo]:= QIPXTipo(aCols[n,nPosPro])
EndIf

Return(lRetu)
