#INCLUDE "ATFA270.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ATFA270  � Autor � Wagner Mobile Costa   � Data � 25.03.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de grupo de bens                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ATFA270()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaAtf                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Atfa270(aRotAuto,nOpcAuto)

Private aRotina := MenuDef()
Private cAlias 		:= "SNG"
PRIVATE aAutoCab   	:= {}
Private lATF270AUT	:= .F.
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := STR0006 //"Cadastro de grupos de bens"

Default aRotAuto := {}
Default nOpcAuto := 1

If Len(aRotAuto) > 0
	lATF270AUT 	:= .T.
	aAutoCab   	:= aClone(aRotAuto)
Else
	lATF270AUT := .F.	
EndIf

If lATF270AUT	
	MBrowseAuto(nOpcAuto,aAutoCab,cAlias)
Else
	mBrowse( 6,1,22,75,cAlias,,,,,,)
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �30/11/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     	  ���
���          �		2 - Simplesmente Mostra os Campos                     ���
���          �		3 - Inclui registros no Bancos de Dados               ���
���          �		4 - Altera o registro corrente                        ���
���          �		5 - Remove o registro corrente do Banco de Dados      ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()                                    
Local aRotina := { 	{ STR0001	,"AxPesqui" ,	0,1 , ,.F.},; 	//"Pesquisar"
					{ STR0002	,"AxVisual",	0,2},; 			//"Visualizar"
					{ STR0003	,"Af270Inc",	0,3},; 			//"Incluir"
					{ STR0004	,"Af270Alter",	0,4},; 			//"Alterar"
      				{ STR0005	,"Af270Del",	0,5},;			//"Excluir"
      				{ STR0007	,"Af270Imp",	0,3} ,; 		//"Importar"
          			{ STR0008	,"Af270Exp",	0,4}	}		//"Exportar"
Return(aRotina)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Af270Del  �Autor  �Marcos Berto        � Data �  05.11.08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Exclusao de Gupo de Bens                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Af270Del(cAlias, nReg, nOpc)
Local nOpca
Local oDlg
Local cCadastro := OemToAnsi(STR0006) //"Excluir"
Local aCamposSNG := {},bCampo,i
Local nValExclui := 0

Private aSize		:= {}
Private aObjects 	:= {} 
Private aPosObj  	:= {} 

Af270Help()

dbSelectArea("SX3")
dbSeek("SNG")

While !Eof() .And. (X3_ARQUIVO == cAlias)
	If X3Uso(X3_USADO) .And. cNivel >= X3_NIVEL
		AAdd(aCamposSNG,X3_CAMPO)
	Endif
	dbSkip()
Enddo

dbSelectArea(cAlias)
bCampo:= { |nCPO| Field(nCPO) }

For i:= 1 to FCount()
	M->&(Eval(bCampo,i)) := FieldGet(i)
Next i 

dbSelectArea("SN1")
dbSetOrder(1)
dbSeek(xFilial("SN1"))
While SN1->(N1_FILIAL == xFilial("SN1") .And. ! Eof())
	If SN1->N1_GRUPO == M->NG_GRUPO
		Help(" ",1,"AF270DEL")
		Return()
	Endif
	dbSkip()		                                                	
Enddo

//monta a entrada de dados do arquivo
Private aTELA[0][0], aGETS[0]

//envia processamento dos Gets
nOpca := 0
dbSelectArea(cAlias)
If !SoftLock(cAlias)
	Return
Endif 

//�����������������������������������������������������������������������Ŀ
//� Calculo do tamanho dos objetos                                        �
//�������������������������������������������������������������������������
aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
nOpca := Enchoice(cAlias, nReg, nOpc,,,,,aPosObj[1])
nOpca := 1
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

If nOpca == 2
	Begin Transaction
		dbSelectArea(cAlias)
		RecLock(cAlias,.F.,.T.)
		dbDelete()
	End Transaction
Else
	MsUnlock()
End
dbSelectArea(cAlias)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AF270TudOk�Autor  �Alvaro Camillo Neto � Data �  08/02/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida��o de cadastro                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AF270TudOk() 
Local lRet := ExistChav('SNG',M->NG_GRUPO)
Local cMoedaFisc:= AllTrim(GetMV("MV_ATFMOEDA"))
Local cNomeField:= "" 

If lRet .And. cPAISLOC = "PTG" .AND. !Empty(cMoedaFisc)	
	dbSelectArea("SNG")
	If len(cMoedaFisc) > 1
		cNomeField  := "NG_TXDEP"+cMoedaFisc
	Else
		cNomeField  := "NG_TXDEPR"+cMoedaFisc
	Endif
	nCPO := FieldPos( cNomeField )
	If nCPO > 0 .AND. val(cMoedaFisc) > 1
		nVlrMoeda := M->&(Field(nCPO) )
		If nVlrMoeda == 0
			Help(" ",1,"AF270M01")
			lRet := .F.
		Else
			lRet := .T.
		Endif
	Else
		Help(" ",1,"AF270M02")
	Endif
Endif


Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Af270Inc  �Autor  �Alexandre Silva     �Fecha �  05/30/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Inclusao de registros                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Af270Inc(cAlias,nReg,nOpc)

If lATF270AUT
	nOpca := AxInclui(cAlias,nReg,nOpc,/*aAcho*/,/*cFunc*/,/*aCpos*/,"AF270TudOk()",/*lF3*/,  ,   ,/*aParam*/,aAutoCab  ,/*lVirtual*/,/*lMaximized*/)
Else
	nOpca := AxInclui(cAlias,nReg,nOpc,/*aAcho*/,/*cFunc*/,/*aCpos*/,"AF270TudOk()",/*lF3*/,  ,   ,/*aParam*/,/*aAutoCab*/,/*lVirtual*/,/*lMaximized*/)
EndIf

Return                    


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Af270Alter  �Autor  �Alvaro Camillo Neto      �  01/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Altera�ao de registros                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Af270Alter(cAlias,nReg,nOpc)

If lATF270AUT		// SE FOR ROTINA AUTOMATICA
	nOpca := AxAltera(cAlias,nReg,nOpc,/*aAcho*/,,,,"AF270TudOk()",/*lF3*/,  ,   ,/*aParam*/,aAutoCab,/*lVirtual*/,/*lMaximized*/)
Else
	nOpca := AxAltera(cAlias,nReg,nOpc,/*aAcho*/,,,,"AF270TudOk()",/*lF3*/,  ,   ,/*aParam*/,/*aAutoCab*/,/*lVirtual*/,/*lMaximized*/)
EndIf   

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Af270Imp   �Autor  �ALvaro Camillo Neto � Data �  01/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Importa arquivo .CSV para a base                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ATFA270                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Af270Imp()
Local aRet	:= {}
Local aArea	:= SNG->(GetArea())
Local aCfg  := {}
Local cCampos := ""

Aviso(STR0007,STR0009,{STR0010}) //"Importar"###"Funcao nao disponivel" //"Fechar"
Return .F.

SaveInter()

SX3->(dbSetOrder(1))
If SX3->(dbSeek(cAlias))
	
	While  cAlias == SX3->X3_ARQUIVO .And. SX3->(!EOF())
		cCampos += SX3->X3_CAMPO + ","
		SX3->(dbSkip())
	EndDo
	cCampos   := Left(cCampos,Len(cCampos)-1)

	aCfg := { { cAlias, cCampos, {||MsExecAuto({|x,y| ATFA270(x,y)}, xAutoCab, 3)} } }
	
	If ParamBox({	{6,STR0011,padr("",150),"",,"", 90 ,.T.,STR0012,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},;	 //"Arquivo"###"Arquivo .CSV |*.CSV"
		STR0013,@aRet)  //"Importar para grupo de bens"
	
		oProcess:= MsNewProcess():New( {|lEnd| CTBImpCSV( lEnd, oProcess, aRet[1], aCfg )} )
		oProcess:Activate()
		lATF270AUT := .F.
	
	EndIf
EndIf
	
RestInter()
RestArea(aArea)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Af270Exp   �Autor  �ALvaro Camillo Neto � Data �  01/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exporta	 arquivo .CSV para a base                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ATFA270                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Af270Exp()

Local aRet		:=	{}   

Aviso(STR0008,STR0009,{STR0010}) //"Exportar"###"Funcao nao disponivel" //"Fechar"
Return .F.

SaveInter()

If ParamBox({	{6,STR0011,padr("",150),"",,"",90 ,.T.,STR0012,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},; //"Arquivo"###"Arquivo .CSV |*.CSV"
		STR0014,@aRet)  //"Exportar para grupo de bens"

	oProcess:= MsNewProcess():New( {|lEnd| CTBExpCSV( lEnd, oProcess, aRet[1], { {cAlias,1} } )} )
	oProcess:Activate()
	lATF270AUT := .F.
EndIf

RestInter()

Return .T.


