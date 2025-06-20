#INCLUDE "TMKA530C.ch"
#INCLUDE "PROTHEUS.CH"

#DEFINE MAXGETDAD 4096

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � SLA      �Autor  �Vendas Clientes     � Data �  07/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Descreve o contrato de SLA								  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class SLA
Data id					// Identificador do contrato de SLA
Data name				// Nome do SLA
Data description		// Descricao completa do SLA
Data priorid			// Nivel de prioridade 
Data responsible		// Responsavel pelo SLA
Data codTemplate		// Modelo/template de Workflow a ser usado
Data iniValidity		// Inicio da vigencia do SLA
Data finValidity		// Fim da vigencia do SLA
Data status				// Status do SLA (1=Ativo, 2=Inativo)
Data utilDates			// Indica se considera Dias Uteis (1=Sim, 2=Nao)
Data timeShift			// Turno analisado
Data aHeadEnt			// Array com os campos de Entidades (SK7)
Data aColsEnt			// aCols de Entidades (usado durante cadastro e gravacao)
Data aHeadSev			// Array com os campos de Severidade (SK9)
Data aColsSev			// aCols de Severidade (usado durante cadastro e gravacao)
Data oPersist           // Classe de acesso ao banco de dados

Method new() Constructor
Method load(id)
Method save()
Method delete()   
Method createPersist()
//Method findSLA(entities)
Method showDialog(cAction, nReg, nOpc)
Method openBrowse()
Method BuildCols(nOpc,aHeadEnt,aColsEnt,aHeadSev,aColsSev)
Method free()

EndClass


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �New          �Autor  � Vendas Clientes � Data �  07/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe SLA                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class SLA
Self:id				:= ""
Self:name			:= ""
Self:description	:= ""
Self:priorid		:= 0
Self:responsible	:= ""
Self:codTemplate	:= ""
Self:iniValidity	:= ""
Self:finValidity	:= ""
Self:status			:= ""
Self:utilDates		:= ""
Self:aColsEnt		:= {}
Self:aHeadEnt		:= {}
Self:aColsSev		:= {}
Self:aHeadSev		:= {}
Self:oPersist 		:= Self:createPersist() 

Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �createPersist �Autor  �Vendas Clientes � Data �  10/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a classe de acesso ao banco de dados.               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method createPersist() Class SLA
Local obj			//Objeto de retorno da classe de Persistencia

obj := SlaTop():New()

Return obj                                


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �save      �Autor  �Vendas Clientes     � Data �  10/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que aciona a operacao de salvar registro de SLA     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method save() Class SLA
Local lRet := .F.			//Variavel de retorno do metodo

lRet := Self:oPersist:save(Self)

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �load      �Autor  �Vendas Clientes     � Data �  10/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que aciona a operacao de carregar registro de SLA   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method load(id) Class SLA
Local lRet := .F.			//Variavel de retorno do metodo

Self:id := id
lRet := Self:oPersist:load(Self)
If !lRet 
	Self:id := ""
EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �delete    �Autor  �Vendas Clientes     � Data �  10/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que aciona a operacao de excluir registro de SLA    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method delete() Class SLA
Local lRet := .F.			//Variavel de retorno do metodo

lRet := Self:oPersist:delete(Self)

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �findSLA		�Autor  �Vendas Clientes � Data �  16/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Localiza o SLA que possui o maior numero de entidades dentre���
���          �as entidades informadas                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*
Method findSLA(entities) Class SLA
Local nI	 		:= 0		//Usada em lacos For...Next
Local nPesoEntid	:= 0		//Peso total das entidades do SLA
Local cAlias 		:= "SK7"	//Alias do arquivo de Entidades
Local cCodSLA		:= ""		//Codigo de contrato de SLA encontrado
Local aSLAEntid		:= {}		//Array de SLA x Total de Entidades
Local cPrecedSLA	:= SuperGetMV("MV_SLAENTI",,"1")
Local nValPeso 		:= 0		//Indica o peso da entidade corrente

//��������������������������������������������������������������Ŀ
//� Efetua a busca em todas as entidades informadas 			 �
//����������������������������������������������������������������
For nI := 1 To Len(entities)

	#IFDEF TOP
		cAlias 	:=	GetNextAlias() 
		BeginSQL alias cAlias
			SELECT 	K7_CODSLA,	K7_NOMEENT, K7_CODENT,	K7_PESO
			FROM	%table:SK7% SK7, %table:SK6% SK6
			WHERE	SK7.K7_FILIAL = %xFilial:SK7% AND 	
					SK7.%NOTDEL% AND
					(SK7.K7_NOMEENT = %EXP:entities[nI]:entityName% AND
					SK7.K7_CODENT = %EXP:entities[nI]:entityValue%) OR
					(SK7.K7_NOMEENT = %EXP:entities[nI]:entityName% AND SK7.K7_CODENT = ' ') 

		EndSql
		
    #ELSE
		cArqInd	:= CriaTrab(,.F.)
		cQuery	:= "SK7->K7_FILIAL =='" + xFilial(cAlias)+"'"
		cQuery	+= ".AND. SK7->K7_NOMEENT == '" + entities[nI]:entityName + "'"
		cQuery	+= ".AND. SK7->K7_CODENT == '" + entities[nI]:entityValue + "'"
		
		DbSelectArea(cAlias)
		DbSetOrder(1)
		cKey := (cAlias)->(IndexKey())
		IndRegua(cAlias, cArqInd, cKey,, cQuery)
		DbGotop()

    #ENDIF

	While (cAlias)->(!Eof())
		//����������������������������������������������������������
		//� Verifica se o Contrato esta Ativo e dentro da vigencia �
		//����������������������������������������������������������
		DbSelectArea("SK6")
		DbSetOrder(1)
		If DbSeek(xFilial("SK6")+(cAlias)->K7_CODSLA)
			If	( SK6->K6_STATUS <> '1' ) .OR. ;	//Status Inativo
				( !Empty(SK6->K6_INIVIG) .AND. SK6->K6_INIVIG > dDataBase ) .OR. ;
				( !Empty(SK6->K6_FIMVIG) .AND. SK6->K6_FIMVIG < dDataBase )
				
				(cAlias)->(DbSkip())
				Loop
			EndIf
		EndIf
		
		//��������������������������������������������������������������������Ŀ
		//� Verifica se o SLA ja esta incluido no array                        �
		//� Caso positivo, incrementa o nr. entidades encontradas para este SLA�
		//� Caso contrario, adiciona um novo SLA no array                      �
		//����������������������������������������������������������������������
		nPos := aScan(aSLAEntid, { |x| x[1] == (cAlias)->K7_CODSLA } )
		If nPos > 0
			aSLAEntid[nPos][2] := aSLAEntid[nPos][2] + 1						//Total de Entidades
			aSLAEntid[nPos][3] := aSLAEntid[nPos][3] + (cAlias)->K7_PESO		//Somatoria do peso das entidades
		Else
			nTotEntidades := 1
			        
			//Verifica quando a Entidade for generica (codigo em branco) 
			//qual eh a precedencia a ser usada para desempate do peso (definida no param.)
			If Empty( Alltrim( (cAlias)->K7_CODENT ) )
				If cPrecedSLA == "0"
					nValPeso := (cAlias)->K7_PESO + 1
				Else
					nValPeso := (cAlias)->K7_PESO - 1
				EndIf
			Else
				nValPeso := (cAlias)->K7_PESO
			EndIf
			
			aAdd(aSLAEntid, {	(cAlias)->K7_CODSLA,;		//Cod. do SLA encontrado na Entidade
								nTotEntidades,;				//Nr. de entidades pertencentes a este SLA
								nValPeso			})		//Somatoria do peso das entidades do SLA
		EndIf

		(cAlias)->(dbSkip())
	End
	
	#IFDEF TOP
		DbSelectArea(cAlias)
		DbCloseArea()
	#ELSE
		DbSelectArea(cAlias)
		RetIndex(cAlias)
		FErase(cArqInd+OrdBagExt())	
	#ENDIF
	
Next nI


//�����������������������������������������������������Ŀ
//� Analisar qual eh o melhor SLA dentre os encontrados �
//� de acordo com o criterio de maior nr. de entidades  �
//�������������������������������������������������������
nTotEntidades := 0
If Len(aSLAEntid) > 0
	
	//Ordena o array pelo total de entidades para encontrar o SLA vencedor 
	ASort(aSLAEntid,,, {|x,y| x[2] > y[2]} )

	//Marca o primeiro SLA encontrado
	cCodSLA := aSLAEntid[1][1]

	For nI := 1 To Len(aSLAEntid)
		If nI == 1
			nTotEntidades := aSLAEntid[nI][2]
		Endif
		
		//Verifica se ocorreu empate de SLA pelo total de entidades
		If aSLAEntid[nI][2] == nTotEntidades
			//Verifica qual tem o maior peso total de entidades (criterio de desempate)
			If aSLAEntid[nI][3] > nPesoEntid
				nPesoEntid	:= aSLAEntid[nI][3]
				cCodSLA		:= aSLAEntid[nI][1]
			EndIf
		EndIf
	Next nI	
	
EndIf

ConOut("SLA encontrado: " + cCodSLA)

Return cCodSLA
*/


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �openBrowse   �Autor  � Vendas Clientes � Data �  09/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exibe o browse da rotina de cadastro de SLA.                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method openBrowse() Class SLA

Private aRotina		:= MenuDef()		//Array com as rotinas do menu funcional
Private cCadastro 	:= STR0009			//Titulo da Dialog //"SLA (Acordo de Nivel de Servico)"

//�������������������Ŀ
//� Fun��o de ajustes �
//���������������������

DbSelectArea("SK6")
DbSetOrder(1)

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
DbSetOrder(1)
DbSeek(xFilial("SK6"))
MBrowse(,,,,"SK6",,,,,,/*aCores*/,,,,)

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Funcao   �TK530Opc     �Autor  � Vendas Clientes � Data �  09/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exibe a tela para configurar um novo contrato de SLA        ���
���          �conforme a opcao selecionada.                               ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TK530Opc(cAlias, nReg, nOpc) 

If nOpc == 2
	
	oObj:showDialog(STR0001, nReg, nOpc) //"Visualizar"
	
ElseIf nOpc == 3

	oObj:showDialog(STR0002, nReg, nOpc)  //"Incluir"

ElseIf nOpc == 4	 

	oObj:showDialog(STR0003, nReg, nOpc) //"Alterar"

ElseIf nOpc == 5

	If oObj:showDialog(STR0004, nReg, nOpc) //"Excluir" //"Excluir"
		If MsgYesNo(STR0005 + AllTrim(oObj:id) + "'?", STR0006) //"Deseja realmente excluir o contrato de SLA'"###"Aten��o"
			oObj:delete()
		EndIf
	EndIf	

EndIf

Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Metodo    � showDialog � Autor � IP - Vendas Clientes� Data � 09/01/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Responsavel pela interface de cadastro de SLA              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void showDialog(ExpC1,ExpN1,ExpN2)                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMKA503A                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Method showDialog(cAction, nReg, nOpc) Class SLA
Local aArea     := GetArea()                            	//Guarda a area atual
Local aPosObj   := {}										//Array com posicao dos objetos
Local aObjects  := {}										//Array com as coordenadas da tela
Local aSize     := {}										//Array com as dimensoes retornadas pelo MsAdvSize()
Local aInfo     := {}										//Array de informacoes de tela
Local aHeadEnt  := {}										//Array aHeader de Entidades
Local aColsEnt  := {}										//Array aCols de Entidades
Local aHeadSev  := {}										//Array aHeader de Severidade
Local aColsSev  := {}										//Array aCols de Entidades
Local aTitles   := {STR0007,STR0008} 						//Array com os titulos das GetDados //"Entidades"###"Severidade"
Local aFldCBAtu := {}										//Array com os folders usados
Local nOpcA     := 0										//Guarda a opcao selecionada (1=gravar;0=cancelar)
Local nSaveSx8 	:= GetSX8Len()								//Numeracao automatica
Local lContinua := .T.										//Indica se continua a execucao da funcao
Local lRet		:= .T.										//Indica o retorno da funcao
Local oDlg													//Objeto Dialog
Local oGetEnt												//Objeto GetDados de Entidades
Local oGetSev   											//Objeto GetDados de Severidade
Local oFolder												//Objeto Folder

Private aTELA[0][0]
Private aGETS[0]

DEFAULT INCLUI := .F.

//������������������������������������������������������������������������Ŀ
//�Inicializa as variaveis da Enchoice                                     �
//��������������������������������������������������������������������������
DbSelectArea("SK6")
If INCLUI
	RegToMemory( "SK6", .T., .F. )
Else
	If SoftLock("SK6")
		RegToMemory( "SK6", .F., .F. )
		Self:load( M->K6_CODSLA )
	Else
		lContinua	:= .F.
		lRet		:= .F.
	EndIf
EndIf

//�����������������������������������������Ŀ
//� Construir aHeader e aCols das 2 Getdados�
//�������������������������������������������
If lContinua 
	Self:BuildCols(nOpc,aHeadEnt,aColsEnt,aHeadSev,aColsSev)
EndIf

If lContinua
	//������������������������������������������������������Ŀ
	//� Faz o calculo automatico de dimensoes de objetos     �
	//��������������������������������������������������������
	aSize := MsAdvSize()
	aAdd( aObjects, { 100, 100, .T., .T. } )
	aAdd( aObjects, { 200, 200, .T., .T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects, .T.)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
	
	EnChoice( "SK6", nReg, nOpc,,,,,aPosObj[1], , 3, , , , , ,.F. )
	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,{""},oDlg,,,, .T., .F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1],)
	oFolder:bSetOption := {|nDst| Tk530FlChg(nDst,oFolder:nOption,oFolder,aFldCBAtu)}

	//������������������������������Ŀ
	//� GetDados de Entidades (SK7)  �
	//��������������������������������
	oGetEnt := MsNewGetDados():New(0,0,aPosObj[2,3]-aPosObj[2,1],aPosObj[2,4]-aPosObj[2,2],;
				IIf(!INCLUI.And.!ALTERA,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
				"Tk530LOkEnt()","Tk530TOkEnt()",/*inicpos*/,/*alteraveis*/,;
				/*freeze*/,MAXGETDAD,/*fieldok*/,/*superdel*/,;
				/*delok*/,oFolder:aDialogs[1],aHeadEnt,aColsEnt)
				
	oGetEnt:oBrowse:bLostFocus	:= {|| lRetorno := oGetEnt:TudoOk(),oFolder:nOption := IIf(lRetorno,oFolder:nOption,1),aColsEnt:=IIf(lRetorno,oGetEnt:aCols,aColsEnt),lRetorno }
	aAdd(aFldCbAtu, oGetEnt:oBrowse:bLostFocus)

	//������������������������������Ŀ
	//� GetDados de Severidade (SK9) �
	//��������������������������������
	oGetSev := MsNewGetDados():New(0,0,aPosObj[2,3]-aPosObj[2,1],aPosObj[2,4]-aPosObj[2,2],;
				IIF(!INCLUI.And.!ALTERA,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
				"Ft530LOkSev()","Tk530TOkSev()",/*inicpos*/,/*alteraveis*/,;
				/*freeze*/,MAXGETDAD,/*fieldok*/,/*superdel*/,;
				/*delok*/,oFolder:aDialogs[2],aHeadSev,aColsSev)
				
	oGetSev:oBrowse:bLostFocus	:= {|| lRetorno := oGetSev:TudoOk(),oFolder:nOption := IIf(lRetorno,oFolder:nOption,2),aColsSev:=IIf(lRetorno,oGetSev:aCols,aColsSev),lRetorno }
	aAdd(aFldCbAtu, oGetSev:oBrowse:bLostFocus)
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA := 1,If(Tk530FlChg(0,oFolder:nOption,oFolder,aFldCBAtu) .And. oGetEnt:TudoOk() .And. oGetSev:TudoOk(),If(!Obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA := 0)},;
												{|| nOpcA := 0, oDlg:End()},,/*aButtons*/)


	If nOpcA == 0
		lRet := .F.	
		While (GetSx8Len() > nSaveSx8)
			RollBackSX8()
		End	
	Else
		//�����������������������������Ŀ
		//� Atualiza os dados do objeto �
		//�������������������������������
		Self:id				:= M->K6_CODSLA
		Self:name			:= M->K6_NOME
		Self:description	:= M->K6_DESCRI
		Self:priorid		:= M->K6_PRIORID
		Self:responsible	:= M->K6_CODRESP
		Self:codTemplate	:= M->K6_MODWF
		Self:iniValidity	:= M->K6_INIVIG
		Self:finValidity	:= M->K6_FIMVIG
		Self:status			:= M->K6_STATUS
		Self:utilDates		:= M->K6_DSUTEIS
		Self:aColsEnt		:= aClone(aColsEnt)
		Self:aHeadEnt		:= aClone(aHeadEnt)
		Self:aColsSev		:= aClone(aColsSev)
		Self:aHeadSev		:= aClone(aHeadSev)
		If Type("M->K6_TURNO") <> "U"
			Self:timeShift		:= M->K6_TURNO
		Else
			Self:timeShift		:= ""
		EndIf
		//������������������Ŀ
		//� Grava o registro �
		//��������������������
		If nOpc == 3 .OR. nOpc == 4
			Self:save()
			While (GetSx8Len() > nSaveSx8)
				ConfirmSX8()
			End
			EvalTrigger()
		EndIf	
	EndIf

EndIf

//������������������������������Ŀ
//� Restaura a entrada da rotina �
//��������������������������������
MsUnLockAll()
FreeUsedCode()
RestArea(aArea)

Return( lRet )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �BuildCols �Autor  � Vendas Clientes    � Data �  10/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo responsavel pela construcao do aHeader e aCols da   ���
���          � rotina                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BuildCols(nOpc,aHeadEnt,aColsEnt,aHeadSev,aColsSev) Class SLA
Local cSeek		:= ""					//Conteudo do seek para a FillGetDados
Local cWhile	:= ""					//Expressao de condicao para FillGetDados
Local cQuery	:= ""					//Expressao de query a ser executada
Local lQuery    := .F.					//Indica se usa query (TOP)

If aScan(aHeadEnt, {|x| x[8] == "M"} ) == 0
	lQuery := .T.
	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("SK7")+" SK7 "
	cQuery += "WHERE SK7.K7_FILIAL='" + xFilial("SK7") + "' AND "
	cQuery += "SK7.K7_CODSLA='" + M->K6_CODSLA + "' AND "
	cQuery += "SK7.D_E_L_E_T_= ' ' "
		
	cQuery := ChangeQuery(cQuery)
Else

	DbSelectArea("SK7")
	DbSetOrder(1)
	DbSeek(xFilial("SK7")+M->K6_CODSLA)

EndIf

 
cSeek  := xFilial("SK7")+M->K6_CODSLA
cWhile := "SK7->K7_FILIAL + SK7->K7_CODSLA"
DbSelectArea("SK7")
DbCloseArea()
FillGetDados(	nOpc			, "SK7"						,1				,cSeek,; 
				{||&(cWhile)}	, /*{|| bCond,bAct1,bAct2}*/,/*aNoFields*/	,/*aYesFields*/,; 
		   		/*lOnlyYes*/	,cQuery						,/*bMontAcols*/	,IIf(nOpc<>3,.F.,.T.),; 
				aHeadEnt		,aColsEnt 					,/*bafterCols*/ , /*bBeforeCols*/,;
				/*bAfterHeader*/, "SK7")

If lQuery
	DbSelectArea("SK7") 
	DbCloseArea()
	ChkFile("SK7")
EndIf


aHeader :={}
aCols   :={}

If aScan(aHeadSev, {|x| x[8] == "M"} ) == 0
	Dbselectarea("SK9")
	lQuery := .T.
	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("SK9")+" SK9 "
	cQuery += "WHERE SK9.K9_FILIAL='"+xFilial("SK9")+"' AND "
	cQuery += "SK9.K9_CODSLA='"+M->K6_CODSLA+"' AND "
	cQuery += "SK9.D_E_L_E_T_= ' ' "
		
	cQuery := ChangeQuery(cQuery)
	
Else
	DbSelectArea("SK9")
	DbSetOrder(1)
	DbSeek(xFilial("SK9")+M->K6_CODSLA)
EndIf
	
cSeek  := xFilial("SK9")+M->K6_CODSLA
cWhile := "SK9->K9_FILIAL + SK9->K9_CODSLA" 
DbSelectArea("SK9")
DbCloseArea()

FillGetDados(	nOpc					, "SK9"						,1			,cSeek,; 
				{||&(cWhile)}			, /*{||bCond,bAct1,bAct2}*/	,/*aNoFields*/,; 
		   		/*aYesFields*/			, /*lOnlyYes*/				,cQuery		, /*bMontAcols*/,;
		   		IIf(nOpc<>3,.F.,.T.)	, aHeadSev					,aColsSev 	, /*bAfterCols*/,;
		   		/*bBeforeCols*/			,/*bAfterHeader*/			,"SK9" )

If lQuery
	dbSelectArea("SK9")
	dbCloseArea()
	ChkFile("SK9")
EndIf
                                                           
Return .T.   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �free       	�Autor  �Vendas Clientes � Data �  30/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Libera a mem�ria dos objetos utilizados.    			 	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method free() Class SLA
TMKFree( Self:oPersist )
Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tk530LOkEnt� Autor � IP - Vendas Clientes � Data � 11/01/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da linha da GetDados de Entidades                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void Tk530LOkEnt()                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMKA530C                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Tk530LOkEnt()
Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tk530TOkEnt� Autor � IP - Vendas Clientes � Data � 11/01/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao Geral                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void Tk530TOkEnt()                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMKA530C                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Tk530TOkEnt()
Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft530LOkSev� Autor � IP - Vendas Clientes � Data � 11/01/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da linha da GetDados de Severidades              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void Ft530LOkSev()                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMKA530C                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ft530LOkSev()
Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tk530TOkSev� Autor � IP - Vendas Clientes � Data � 11/01/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao Geral                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void Tk530TOkSev()                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMKA530C                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Tk530TOkSev()
Return .T.


/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Tk530FlChg�Autor  � Vendas Clientes       � Data �10.03.2003 ���
��������������������������������������������������������������������������Ĵ��
���          �Rotina de controle da troca de folder                        ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1: Folder de destino                                     ���
���          �ExpN2: Folder atual                                          ���
���          �ExpO3: Objeto do Folder                                      ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo exibir/controlar os folders do ���
���          �cadastro 								                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � MP10								                           ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function Tk530FlChg(nFldDst,nFldAtu,oFolder,aCodeBlock)

Local lRetorno := .T.			//Indica retorno da funcao
DEFAULT nFldDst := IIf(oFolder<>Nil,oFolder:nOption,1)

//��������������������������������������������������������������Ŀ
//� Atualiza os objetos do folder de destino                     �
//����������������������������������������������������������������
If !Empty(aCodeBlock) .And. nFldAtu<=Len(aCodeBlock) .And. !Empty(aCodeBlock[nFldAtu])
	lRetorno := Eval(aCodeBlock[nFldAtu])
EndIf
Return(lRetorno)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKA530C � Autor � IP - Vendas Clientes  � Data � 09/01/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de SLA (Acordo de Nivel de Servico)               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MP10                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKA530C()
Static oObj := SLA():New()			//Objeto da classe SLA

oObj:openBrowse()
Return .T.   

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef	� Autor � Vendas Clientes       � Data �09/01/08  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o do aRotina                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina   retorna a array com lista de aRotina             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMKA530C                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef() 
Local aRotina			//Array de rotinas
               
aRotina		:= {{ STR0010	,"AxPesqui" 	,0	,1 },; 	// 	"Pesquisar"  //"Pesquisar"
				{ STR0001	,"TK530Opc" 	,0	,2 },; 	// 	"Visualizar" //"Visualizar"
				{ STR0002	,"TK530Opc" 	,0	,3 },; 	// 	"Incluir"  //"Incluir"
				{ STR0003	,"TK530Opc" 	,0	,4 },;	//	"Alterar" //"Alterar"
				{ STR0004  	,"TK530Opc" 	,0	,5 }} 	// 	"Excluir" //"Excluir"

Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_TMKA500      �Autor  �Michel W. Mosca � Data �  09/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                   
FUNCTION _TMKA530C()
RETURN NIL 


/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Rotina    � ProxIdent  � Autor � Vendas e CRM         � Data �  01/08/2013 ���
�����������������������������������������������������������������������������͹��
���Descricao � Retorna Proxima numera��o do ID do  relacionamento quando	  ���
���			 � novo registro, caso contrario, retorna o ID posicionado.		  ���
�����������������������������������������������������������������������������͹��
���Uso       �                                                                ���
�����������������������������������������������������������������������������͹��
���Parametros� ExpC1 = Alias dominio do relacionamento					      ���
���			 � ExpC2 = Alias contra dominio do relacionamento		     	  ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function ProxIdent(cDominio, cCDominio)  
Local cIdent := ''
Local aIdent := {}
Local aArea	 := GetArea()

DbSelectArea( 'SX9' )
DbSetOrder( 2 )   

cIdent:= StrZero(Val("1"),Len(X9_IDENT))

If DbSeek(cCDominio+cDominio)
	cIdent := X9_IDENT
Else              
	DbSetOrder( 1 )   
	If DbSeek(cDominio)
		While !Eof() .And. cDominio == X9_DOM
			AADD(aIdent,X9_IDENT)
			DbSkip()
		End              
		//���������������������������������������������������������������
		//�Ordena o array para pegar a ultima numera��o do identificador�
		//���������������������������������������������������������������
		If !Empty(aIdent)
			aSort(aIdent,,,{|x,y| x > y})
			cIdent:= Soma1(aIdent[1])
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return(cIdent)
