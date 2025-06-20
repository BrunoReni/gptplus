#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA790.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#define Confirma 1
#define Redigita 2
#define Abandona 3

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � Gpea790  � Autor � Abel Ribeiro          � Data �  19.08.08  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Manuten��o de Dados Declara��o de IRS                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � FNC  �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���Emerson     �01/07/2011�012509�Atender a Nova Interface Totvs 11.5       ���
���Campos	   �          � /2011�utilizando a funcao MsAdvSize( p/         ���
���            �          �	     �flexibilidade  da tela de acordo          ���
���            �          �      �com a resolucao).               	        ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function Gpea790(nOpcAuto)

LOCAL cFiltraSRA			//Variavel para filtro
LOCAL aIndexSRA	:= {}		//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

PRIVATE aRotina :=  MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
Private cANO    := 0

cCadastro := OeMtoAnsi(STR0001) //"Manuten��o da IRS"

//cCadastro	:= OeMtoAnsi(STR0001)  +STR0011 +cAno //"Manuten��o da I.R.S."#" - Ano Calendario "

If !Pergunte("GPA790",.T.)
	Return
EndIf

cAno 		:= Strzero(MV_PAR01,4)

If nOpcAuto <> Nil
	Do Case
		Case nOpcAuto == 3
			INCLUI := .T.
			ALTERA := .F.
		Case nOpcAuto == 4
			INCLUI := .F.
			ALTERA := .T.
		OtherWise	
			INCLUI := .F.
			ALTERA := .F.
	EndCase		

	dbSelectArea('SRA')
	nPos := Ascan(aRotina,{|x| x[4]== nOpcAuto})
	If ( nPos <> 0 )
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPos,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nPos)
	EndIf
Else
	//��������������������������������������������������������������Ŀ
	//� Verifica se o Arquivo Esta Vazio                             �
	//����������������������������������������������������������������
	If !ChkVazio("SRA")
		Return
	Endif
	
	//������������������������������������������������������������������������Ŀ
	//� Inicializa o filtro utilizando a funcao FilBrowse                      �
	//��������������������������������������������������������������������������
	cFiltraRh := CHKRH("GPEA790","SRA","1")
	bFiltraBrw 	:= {|| FilBrowse("SRA",@aIndexSRA,@cFiltraRH) }
	Eval(bFiltraBrw)
	
	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������

	dbSelectArea("SRA")
	mBrowse( 6, 1,22,75,"SRA",,,,,,fCriaCor() )

	//������������������������������������������������������������������������Ŀ
	//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
	//��������������������������������������������������������������������������
	EndFilBrw("SRA",aIndexSra)
	//--Retornar Set Epoch Padrao
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �gp790Atu  � Autor � Abel Ribeiro          � Data � 19.08.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de (Vis.,Inc.,Alt. e Del. de  dependentes         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � gp790Atu(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Function gp790Atu(cAlias,nReg,nOpcx)

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local nSavRec   	:= RecNo()
Local nCnt			:= 0
Local oDlg
Local oFont
Local oGroup

Local aNoFields  := {"RGO_FILIAL","RGO_NIF","RGO_ANO","RGO_ALI_WT","RGO_REC_WT"}
Local aYesFields := {"RGO_TIPREN","RGO_NOMREN","RGO_LOCREN","RGO_VLRANT","RGO_NRANOS","RGO_VLRREN","RGO_VLRRET","RGO_DESOBR","RGO_QUOTSI","RGO_VLISEN"}
Local bSeekWhile := {|| RGO->RGO_FILIAL + RGO->RGO_ANO + RGO->RGO_MAT + RGO->RGO_NIF }
Local Nrgoord	 := RetOrdem( "RGO", "RB_FILIAL+RGO->RGO_ANO + RGO->RGO_MAT + RGO->RGO_NIF + RGO->RGO_TIPREN" )
Local nPosRec	 := 0


Private aColsRec := {}   //--Array que contem o Recno() dos registros da aCols
Private nUsado   := 0
Private cAliasRgo := "RGO"
PRIVATE cMAT   	 := SRA->RA_MAT
PRIVATE cNome  	 := SRA->RA_NOME 
PRIVATE cNIF   	 := SRA->RA_CIC             


//If !Pergunte("GPA790",.T.)
//	Return
//EndIf

//cAno 		:= Strzero(MV_PAR01,4)
cCOD        := cFilial+cANO+cMAT+Substr(Alltrim(cNIF),1,9) 

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

While .T.

	
	//��������������������������������������������������������������Ŀ
	//� Verifica se existe algum dado no arquivo                     �
	//����������������������������������������������������������������
	dbSelectArea( cAliasRGO )
	dbSetOrder(1)
	dbSeek( cCod )
	nCnt := 0
   	While !EOF() .And. RGO_FILIAL + RGO_ANO + RGO_MAT + Substr(Alltrim(RGO_NIF),1,9) == CCod 
		nCnt++
		dbSkip()
    EndDo
  

    IF    (nCnt = 0 .and. nOPCx == 2) .or. (nCnt = 0 .and. nOPCx == 5)
           Aviso(OemToAnsi(STR0010), OemToAnsi(STR0015), {"Ok"})            	            //"Atencao"###"N�o H� valores lan�ados para este Funcion�rio"	        
           Exit             
    Elseif nCnt = 0 
           nOpcx := 3
    Elseif nCnt > 0 .and. nOpcx == 3
           cMensagem := STR0014 +chr(13) + CHR(10) + SRA->RA_MAT +" - "+ space(02)+SRA->RA_NOME   //"J� Existe Lan�amentos para este Funcion�rio,utilize a op��o Alterar"
	       Aviso(STR0007,cMensagem,{"OK"})
           Exit
    Endif
	
	//��������������������������������������������������������������Ŀ
    //� Gerar o array aCols com os dependentes E Monta o cabecalho   �
	//����������������������������������������������������������������

	FillGetDados(nOpcx					,; //1-nOpcx - n�mero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
				 cAliasRGO				,; //2-cAlias - area a ser utilizada;
				 nRGOOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				 cCod	                ,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
				 bSeekWhile				,; //5-bSeekWhile - bloco contendo a express�o a ser comparada com cSeekKey na condi��o  do While.
				 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-c�digo, condi��o a ser utilizado para executar o Loop no While;2� - array bi-dimensional contendo N.. condi��es, em que o 1� elemento � o bloco condicional, o 2� � bloco a ser executado se verdadeiro e o 3� � bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
				 aNoFields		   	    ,; //7-aNoFields - array contendo os campos que n�o estar�o no aHeader;
				 aYesFields				,; //8-aYesFields - array contendo somente os campos que estar�o no aHeader;
				 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usu�rio;
				 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
				 NIL					,; //11-bMontCols - bloco contendo fun��o especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
				 IIF(nOpcx==3,.t.,.f.)  ,; //12-Caso inclusao inclua um registro em branco no acols	
				 NIL			      	,; //13-aHeaderAux
				 NIL			      	,; //14-aColsAux
				 NIL			     	)  //15-bAfterCols
	
	nOpca := 0         
	
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
    DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
        
    @ aObjSize[1,1], aObjSize[1,2] GROUP oGroup TO aObjSize[1,3], aObjSize[1,4]*0.18 LABEL OemToAnsi(STR0007) OF oDlg PIXEL				// "Matricula:"
	oGroup:oFont:= oFont 
	@ aObjSize[1,1], aObjSize[1,4]*0.185 GROUP oGroup TO aObjSize[1,3],aObjSize[1,4]*0.8 LABEL OemToAnsi(STR0008) OF oDlg PIXEL	// "Nome:"
	oGroup:oFont:= oFont 
	@ aObjSize[1,1], aObjSize[1,4]*0.805 GROUP oGroup TO aObjSize[1,3],aObjSize[1,4] LABEL OemToAnsi(STR0009) OF oDlg PIXEL						// "NIF:"
	oGroup:oFont:= oFont 

	@ aObjSize[1,1]+10, aObjSize[1,2]*2.5	SAY cMat 	                SIZE 050,10 OF oDlg PIXEL FONT oFont
	@ aObjSize[1,1]+10, aObjSize[1,4]*0.2	SAY OemToAnsi(cNOME) 		SIZE 146,10 OF oDlg PIXEL FONT oFont
	@ aObjSize[1,1]+10, aObjSize[1,4]*0.82	SAY cNIF  	                SIZE 050,10 OF oDlg PIXEL FONT oFont

	                           
	oGet	:= MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4],nOpcx,"Xgp790LinOk","Xgp790TudOk"," ",If(nOpcx=2.Or.nOpcx=5,Nil,.T.),,1)
	
   	bSet15	:= {|| nOpca:=If(nOpcx=5,2,1),If(oGet:TudoOk(),oDlg:End(),nOpca:=0)}
   	bSet24	:= {||oDlg:End()}
   
   	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ) 
    
    aColsAnt := Aclone(aCols)

    //--Se nao for Exclusao
    If nOpcx # 5
        IF nOpcA == Redigita
            LOOP
        ELSEIF nOpcA == Confirma .And. nOpcx # 2
            Begin Transaction
                //--Gravacao
                gp790Grv(cAliasRGO,aColsAnt)
                //--Processa Gatilhos
                EvalTrigger()
            End Transaction
        Endif
    //--Se for Exclusao
    Elseif nOpca = 2 .And. nOpcx = 5
        Begin Transaction
            gp790Dele( cAlias , nReg , nOpc )

        End Transaction
    Endif

	Exit
EndDo
//��������������������������������������������������������������Ŀ
//� Restaura a integridade da janela                             �
//����������������������������������������������������������������
carq1 := "SRA"
dbSelectArea(cArq1)
Go nSavRec

If nOpcx == 3    //--Quando Inclusao
   MBrChgLoop(.F.)
EndIf
   
Return
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �gp790Dele � Autor � Abel Ribeiro          � Data � 18.08.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Deleta os Registro de  dependentes                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � gp790Dele                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function gp790Dele( cAlias , nReg , nOpc )

cAlias := "RGO"
dbSelectArea("RGO")
dbSetOrder(1)    // RGO_FILIAL+RGO_ANO+RGO_MAT+RGO_NIF              
IF dbSeek(SRA->RA_FILIAL+cANO+SRA->RA_MAT+SUBSTR(SRA->RA_CIC,1,9))
	nReg := Recno()
	cMensagem := STR0019      //"Deseja Excluir Informa��o de IRS deste funcion�rio: "
	If Aviso(STR0010,cMensagem,{STR0020,STR0021}) == 1 // ###"ATENCAO"###//"Deseja Excluir Informa��o de IRS deste funcion�rio: "###"Sim"###"Nao"
		AxDeleta( cAlias , nReg , nOpc )
	Endif
ELSE
    cMensagem := STR0015 + " " + SRA->RA_MAT + space(02)+SRA->RA_NOME// "N�o foram geradas informa��es para o funcion�rio: "
	Aviso(STR0007,cMensagem,{"OK"})
Endif
dbSelectArea("SRA")
                                                                                            
Return Nil



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���                   ROTINAS DE CRITICA DE CAMPOS                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �gp790Grava� Autor � Abel Ribeiro          � Data � 19.08.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava no arquivo de Dependentes                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � gp790Grava                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function gp790Grv(cAliasRGO,aColsAnt)
Local nX 		:= 0
Local aAreaRGO 	:= RGO->( GetArea() )
Local lAlt      := .F.
Local nLenCols	:= Len(aColsAnt)
Local nUsado    := Len(aHeader)
Local nTpRen    := aScan(aHeader,{|x| AllTrim(x[2])=="RGO_TIPREN" })
Local nLocRen   := aScan(aHeader,{|x| AllTrim(x[2])=="RGO_LOCREN" })
Local nVlAnt    := aScan(aHeader,{|x| AllTrim(x[2])=="RGO_VLRANT" })
Local nNranos   := aScan(aHeader,{|x| AllTrim(x[2])=="RGO_NRANOS" })
Local nVlREND	:= aScan(aHeader,{|x| AllTrim(x[2])=="RGO_VLRREN" })
Local nVlRET	:= aScan(aHeader,{|x| AllTrim(x[2])=="RGO_VLRRET" })
Local nVlDESC	:= aScan(aHeader,{|x| AllTrim(x[2])=="RGO_DESOBR" })
Local nVlQSIND  := aScan(aHeader,{|x| AllTrim(x[2])=="RGO_QUOTSI" })
Local nVlIsento := aScan(aHeader,{|x| AllTrim(x[2])=="RGO_VLISEN" })


For nX := 1 To nLenCols
	IF !( aColsAnt[nX,nUsado+1] )       //Se n�o Foi Deletado 
		dbSelectArea("RGO")
	    dbSetOrder(1)   
	    If dbSeek(xFilial("RGO")+cANO+cMAT+SUBSTR(ALLTRIM(cNIF),1,9)+aColsAnt[nX,1])
	       (cAliasRGO)->( RecLock(cAliasRGO,.F.,.T.) )
	       lAlt := .T.
	    Else     
	       (cAliasRGO)->( RecLock(cAliasRGO,.T.) )
	       (cAliasRGO)->RGO_FILIAL	:= XFILIAL("RGO")
		   (cAliasRgo)->RGO_MAT	    := cMat
		   (cAliasRGO)->RGO_NIF	    := cNIF
		   (cAliasRGO)->RGO_ANO     := cANO
    	   (cAliasRGO)->RGO_TIPREN 	:= aColsAnt[nX,nTPREN]
		Endif

		(cAliasRGO)->RGO_LOCREN 	:= aColsAnt[nX,nLocRen]
		(cAliasRGO)->RGO_VLRANT 	:= aColsAnt[nX,nVLant]
		(cAliasRGO)->RGO_NRANOS 	:= aColsAnt[nX,nNRANOS]
		(cAliasRGO)->RGO_VLRREN 	:= aColsAnt[nX,nVLREND]
		(cAliasRGO)->RGO_VLRRET 	:= aColsAnt[nX,nVLRET]
		(cAliasRGO)->RGO_DESOBR 	:= aColsAnt[nX,nVLDesc]
		(cAliasRGO)->RGO_QUOTSI 	:= aColsAnt[nX,nVLQSIND]
		(cAliasRGO)->RGO_VLISEN  	:= aColsAnt[nX,nVlIsento]

		//Se for altera��o Grava o Codigo do Usu�rio
		IF lAlt 
		   (cAliasRGO)->RGO_USER 	    := __cUSERID
		ENDIF
		   
		/*
		��������������������������������������������������������������Ŀ
		�Destrava o Registro										   �
		����������������������������������������������������������������*/
		( cAliasRGO )->( MsUnLock() )
	Else  //Se FOi Deletado , Trata o Registro
	    dbSelectArea("RGO")
	    dbSetOrder(1)   
	    If dbSeek(xFilial("RGO")+cANO+cMAT+Substr(Alltrim(cNIF),1,9)+aColsAnt[nX,1])
	       (cAliasRGO)->( RecLock(cAliasRGO,.F.,.T.) )
	       (cAliasRGO)->(dbDelete())
 	       (cAliasRGO)->( MsUnLock() )
 	    Endif   
	EndIF
Next nX

RestArea( aAreaRGO )
Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �gp790LinOk� Autor � J. Ricardo            � Data � 06.08.94 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Critica linha digitada                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Xgp790LinOk()
Local lRet 	:= .T.                                                                                                                            
Local nPosVLREN:= GdFieldPos("RGO_VLRREN")
Local nLocRen  := GdFieldPos("RGO_LOCREN")
Local nPosTip  := GdFieldPos("RGO_TIPREN")
Local cTIPREN  := GDFIELDGET("RGO_TIPREN",n)

nPosAcols := aScan(aCols,{|x| x[nPosTip]  == cTIPREN  } )

If aCols[n,Len(acols[n])]  = .F.
   IF  (nPosAcols > 0) .And. (nPosAcols <> n)
       Aviso(STR0012,STR0018 + AllTrim(Str(nPosAcols)),{STR0013})     // "Tipo de Rendimento J� Digitado - linha "
       lRet := .F.
   ELSEIF aCols[n, nPosVLREN] <= 0.00      
          Aviso(STR0012,STR0016,{STR0013})
          lRet := .F.
   ELSEIF aCols[n, nLocRen] == ""        
          Aviso(STR0012,STR0017,{STR0013})
          lRet := .F.
   ENDIF        
Endif
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �gp790TudOk� Autor � J. Ricardo            � Data � 15.02/95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Xgp790TudOk()
Local lRetorna  := .T.
Continua := .F.
Return lRetorna
/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gpem770Filter�Autor� Rogerio Vaz Melonio    �Data�22/08/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Botao de alteracao do filtro                 				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�������������������������������������������������������������������������/*/
Function Gpea790Filter(	aFilterExp 	,;		// opcoes do filtro  // MUDEI AQUI
								cTabMestra	,;		// alias do filtro
					 			cExpFiltro	,;		// string com o filtro - passado por referencia
								lShowDlg	 ;		// Se visualiza janela de filtros
					  		 )
Local aRetFiltro 	:= {}
Local aHeader 		:= {}

Local cTxtFil 		:= ""

DEFAULT lShowDlg	:= .T.

/*/
��������������������������������������������������������������Ŀ
�Elabora o cabecalho do arquivo Mestre                 	       �
����������������������������������������������������������������/*/
aHeader := GdMontaHeader(NIL,NIL,NIL,cTabMestra,NIL,.T.,.T.,.F.,.F.,.F.,.F.,.F.)

/*/
��������������������������������������������������������������Ŀ
�Retorna os filtros selecionados                       	       �
����������������������������������������������������������������/*/
aRetFiltro := GpFiltro( aFilterExp, .F. )

/*/
��������������������������������������������������������������Ŀ
�Se for na inicializacao da dialog, nao mostrar a janela       �
�Caso possua mais de 1 filtro selecionado-retornar filtro Vazio�
����������������������������������������������������������������/*/
If (;
		( Len(aRetFiltro) > 1 );
		.And.;
		( lShowDlg );
	)	
	aRetFiltro := GpFiltro( aFilterExp )
ElseIf (;
			( Len(aRetFiltro) > 1 );
			.And.;
			!( lShowDlg );
		)	
	aRetFiltro := NIL
EndIf

If !Empty(aRetFiltro)
	/*/
	��������������������������������������������������������������Ŀ
	�Retorna a expressao dos filtros                      	       �
	����������������������������������������������������������������/*/
	cExpFiltro := GpFltAlsGet( aRetFiltro , cTabMestra )

	If lShowDlg
		cTxtFil    := GpFltBldDesc( cExpFiltro, @aHeader, cTabMestra )
		/*/
		��������������������������������������������������������������Ŀ
		�Janela para alteracao dos valores do filtro          	       �
		����������������������������������������������������������������/*/
		AltValExp( cTabMestra , @cExpFiltro , @cTxtFil , NIL , aHeader )
	EndIf
EndIf

Return( NIL )


/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gpem770SetFil�Autor� Rogerio Vaz Melonio    �Data�22/08/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Setar as opcoes do Filtro									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�������������������������������������������������������������������������/*/
Function Gpea790SetFil( aFilterExp , cTabMestra )
Local aGrpUsr		:= {}	// Grupo dos Usuarios
Local cGrpUsr		:= ""	// string com o Grupo de usuario
Local nLoop			:= 0	
aAdd( aFilterExp , { "FILTRO_ALS" , cTabMestra 	, NIL , NIL    } )
/*/		
��������������������������������������������������������������������������Ŀ
� Localizar os grupos a que o usuario pertence                             �
���������������������������������������������������������������������������� */
aGrpUsr := UsrRetGrp( SubStr( cUsuario , 7 , 15 ) )
For nLoop := 1 To Len(aGrpUsr)
	cGrpUsr := aGrpUsr[nLoop]
	aAdd( aFilterExp , { "FILTRO_GRP" , cGrpUsr 	, NIL , NIL    } )
Next nLoop
Return( NIL )

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �01/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA790                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/        

Static Function MenuDef()

//��������������������������������������������������������������Ŀ
//� Define array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         1
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
 
Local  aRotina := { {	STR0002	 , 'PesqBrw' 	, 0 , 1 , ,.F.}	,;  //'Pesquisar' 
					{	STR0003  , "Gp790atu"	, 0 , 2  } ,;  	    //"Visualizar"
					{   STR0004  , "gp790ATu"   , 0 , 3  } ,;       //"Incluir" 
					{   STR0005  , "gp790ATu"   , 0 , 4  } ,;       //"Alterar" 
					{	STR0006  , "Gp790Dele"	, 0 , 5  } }   	    //"Excluir"
Return aRotina
