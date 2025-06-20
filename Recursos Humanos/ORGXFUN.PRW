/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Programa  �ORGXFUN    �Autor  �Equipe Advanced RH        � Data �  06/26/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Biblioteca de Funcoes para uso no SIGAORG                          ���
��������������������������������������������������������������������������������͹��
���Uso       �Generico                                                           ���
��������������������������������������������������������������������������������͹��
���                ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL              ���
��������������������������������������������������������������������������������͹��
���Progr.      �Data      � BOPS/FNC  �Motivo da Alteracao                       ���
��������������������������������������������������������������������������������͹��
���Cecilia C.  �31/03/2014�151223     �Ajuste na funcao OrgRelationFile para     ���
���            �          �           �verificar compatibilidade entre modos     ���
���            �          �           �apenas das tabelas RCL/RBU/RBT/RBX        ���
���Cecilia C.  �07/08/2014�TQEQKP     �Limpeza do fonte.                         ���
���Raquel Hager�06/06/2016�TVDLLJ     �Removido chamada da fun��o OpenSXS da     ���
���            �          �           �fun��o OrgxOpenFile.		                  ���
���Marcelo F.  �21/05/2017�DRHPONTP   �Ajuste de origem da transfer�ncia,        ���
���            �          �-604       �quando utilizado controle de postos       ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������/*/     
#INCLUDE "PROTHEUS.CH"
#INCLUDE "ORGXFUN.CH"

Static nTamDpt
Static cFuncCall := FunName()
Static cOrgCfg   := SuperGetMv("MV_ORGCFG",NIL,0)

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � OrgRelationFile � Autor � Rogerio R. Cruz  � Data � 26/06/07 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o Relacionamentos dos Arquivos do Modulo Org          ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ORGLOAD() - SIGAORG - Arquitetura Organizacional.            ���
���������������������������������������������������������������������������Ĵ��
���Parametros� lShowHelp: Exibe ou nao a mensagem de Help				    ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetModo													    ���
���������������������������������������������������������������������������Ĵ��
���Observa��o�                                                      	    ���
���������������������������������������������������������������������������Ĵ��
���Uso       �Generica                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function OrgRelationFile(lFinal)
	Local nCount
	Local cMessage
	Local lRetModo	:= .T.
	Local aFiles	:= {	{"RCL", "RBU"},;//Cadastro de Postos+Movimentacao de Postos
							{"RCL", "RBT"},;//Cadastro de Postos+Mov de Estrutura de Departam
							{"RCL", "RBX"},;//Cadastro de Postos+Operacoes em Mov Departamento
							{"RCL", "RCX"},;//Cadastro de Postos+Ocupantes do posto
							{"RDK", "RD4"},;//Visoes+Itens de Visoes
							{"RD4", "RCD"} }//Itens de Visoes+Historico de Itens de Visoes
	
	Static lOrgChkRel
	Static cLastEmpChk
	
	Default lFinal	:= .F.

	CursorWait()
	
	Begin Sequence
		DEFAULT lOrgChkRel 	:= .T.
		DEFAULT cLastEmpChk	:= cEmpAnt
		
		IF ( cLastEmpChk <> cEmpAnt )
			lOrgChkRel := .T.
		EndIF
		
		IF !( lOrgChkRel )
			Break
		EndIF
		
		IF !( lRetModo := Rd0ChkModo( .F. ) )
			cMessage:= OemToAnsi(STR0003) + " RD0 " + OemToAnsi(STR0004)
			Break
		EndIF
		
		IF !( lRetModo := RdZChkModo( .F. ) )
			cMessage:= OemToAnsi(STR0003) + " RDZ " + OemToAnsi(STR0004)
			Break
		EndIF
		
		For nCount:= 1 To Len(aFiles)
			IF !( lRetModo := xRetModo(aFiles[nCount, 1] , aFiles[nCount, 2] , .F. ) )
				cMessage:= OemToAnsi(STR0005) + " " + aFiles[nCount, 1] + " " + OemToAnsi(STR0006) + " " + aFiles[nCount, 2] + " " + OemToAnsi(STR0007)
				Break
			EndIF
		Next
	End Sequence
	
	If !lRetModo .AND. lFinal
		Final(cMessage)
	EndIf	

	
	CursorArrow()
	
	//Se estiver Tudo Ok nao verifica Novamente
	lOrgChkRel := !lRetModo
Return lRetModo

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � OrgxOpenFile    � Autor � Marcos Alves     � Data � 17/10/07 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Abertura das tabelas de outra empresas e dicion�rios, para   ���
���          � funcionamento das query de embedded                          ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � OrgxOpenFile(aFiles,cEmp)									���
���������������������������������������������������������������������������Ĵ��
���Parametros� aFiles - Tebelas a serem abertas na empresa					���
���          � cEmp   - Codigo da empresa a ser abertos as tabelas          ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nada     										            ���
���������������������������������������������������������������������������Ĵ��
���Observa��o�                                                      	    ���
���������������������������������������������������������������������������Ĵ��
���Uso       �SIGAORG                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function OrgxOpenFile(aFiles,cEmp)
	Local nLoops	:=Len(aFiles)
	Local nX
	Local cModo		:=""
	Local lOpen		:=.T.
	Local aSxs		:=RetSxs()
	Local cAlias	:=""
	
	//�������������������������������������������������������������������Ŀ
	//� Fechar as tabelas antes de abrir, pois vai abrir no mesmo alias	  �
	//���������������������������������������������������������������������
	For nX:=1 to Len(aSxs)
		cAlias 	:= If("SX"$aSxs[nX,1],aSxs[nX,1],"SIX")
		IF Select(cAlias) > 0
			dbSelectArea(cAlias)
			dbCloseArea()
		Endif	
	Next nX
	//�������������������������������������������������������������������Ŀ
	//� Posicionar na empresa a ser aberto os dicionario				  �
	//���������������������������������������������������������������������
	SM0->(dbSeek(cEmpAnt))
	For nX:=1 to Len(aSxs)
		cAlias 	:= If("SX"$aSxs[nX,1],aSxs[nX,1],"SIX")
		OpenSxs(,,,,,,cAlias)
	Next nX
	
	For nX:=1 to nLoops
		lOpen:=EmpOpenFile(	aFiles[nX,1],;			//cExp1 - Alias com o Qual o Arquivo Sera Aberto
		   					aFiles[nX,1],;		//cExp2 - Alias do Arquivo Para Pesquisa e Comparacao           
							1		,;	  		//nExp3 - Ordem do Arquivo a Ser Aberto                         
							.T.		,;			//lExp4 - .T. Abre e .F. Fecha                                  
							cEmp	,;			//cExp5 - Empresa                                               
							@cModo)				//cExp6 - Modo de Acesso (Passar por Referencia)                
		
	
		aFiles[nX,2]:=If(lOpen,cModo,"X")
	Next nX
Return
               


//-----------------------------------------------------------------------------
//<summary>
//		Libera os postos ocupados pelo funcionario.
//</summary>
//<param name="cFilFun">Filial do Funcionario</param>
//<param name="cMatFun">Matricula do Funcionario</param>
//<param name="dDataBaixa">Data de demissao do Funcionario</param>
//<remarks></remarks>
//<history>
// 	<change date="08/07/2008" user="rogerio.ribeiro">Criacao da funcao.</change>
//</history>
//-----------------------------------------------------------------------------
Function OrgXRescisao(cFilFun, cMatFun, dDataBaixa)
   	Local oPostos	:= ArrayList():New()
	Local aArea 
	Local aAreaSRA
	Local aAreaRCX
	Local aAreaRCL
	Local aAreaRBU
   	Local cPosto
   	Local nCount
	Local nGetSX8Len
	
	If GetMv("MV_ORGCFG", NIL, "0") != "1"
		Return {}
	Endif
 	   	
	SX2->(dbSetOrder(1))	
	If !SX2->(dbSeek("RCX"))
		Return {}
	Endif
	
	aArea 	:= GetArea() 
	aAreaSRA	:= SRA->( GetArea() )
	aAreaRCX	:= RCX->( GetArea() )
	aAreaRCL	:= RCL->( GetArea() )
	aAreaRBU	:= RBU->( GetArea() )
   	   		
   	dbSelectArea("RCX") 	
	dbSetOrder(4)	//RCX_FILIAL+RCX_FILFUN+RCX_MATFUN+RCX_POSTO

   //Necess�rio realizar a busca na tabela de ocupa��es utilizando a mesma filial do funcion�rio
   //pois no caso de transfer�ncias de filial+ posto, essa funcionalidade dever� realizar as
   //baixas na filial de origem e n�o na filial de destino *xFilial("RCX")*
   //visto que no processo de transfer�ncia quando se opta pela troca de filial, o posto deve
   //acompanhar a mesma filial do funcion�rio, na atualiza��o do campo RA_POSTO.
	If !RCX->(dbSeek(xFilial("RCX",cFilFun) + cFilFun + cMatFun))
		Return {}
 	EndIf	
 	
	RBU->(dbSetOrder(1)) //RBU_FILIAL+RBU_POSTO+RBU_CODMOV
	
	nGetSX8Len:= GetSX8Len()
	
	While !RCX->(Eof())                .AND.;
           RCX->RCX_FILFUN == cFilFun .AND.;
           RCX->RCX_MATFUN == cMatFun 
		
		cPosto := RCX->RCX_POSTO 
		oPostos:Add( RCX->(RECNO()) )

		//��������������������������������������������������������������Ŀ
		//� Atualizar o posto											 �
		//����������������������������������������������������������������
		RCL->(dbSetOrder(2))
		
	 	If RCL->(DBSeek(xFilial("RCL",cFilFun) + cPosto))
	 		If RCX->RCX_SUBST == "2"
				RCL->(RecLock("RCL",.F.))
				RCL->RCL_OPOSTO	:= 	If(RCL->RCL_OPOSTO>=1,RCL->RCL_OPOSTO-1,0)
				RCL->RCL_STATUS	:=	If(RCL->RCL_OPOSTO==0,"1",RCL->RCL_STATUS)	// 1=Livre;2=Ocupado;3=Congelado;4=Cancelado
				RCL->(MsUnLock())
			EndIf
		EndIf
		
		If RBU->(DBSeek(xFilial("RBU",cFilFun) + cPosto))
			While !RBU->(EOF())               .AND.;
					RBU->RBU_FILIAL == xFilial("RBU",cFilFun) .AND.;
					RBU->RBU_POSTO  == cPosto		

				If RBU->RBU_FILFUN == cFilFun .AND.;
				   RBU->RBU_MATFUN == cMatFun .AND.;
				   RBU->RBU_DTFIM == CTOD("  /  /  ")
				   
					RBU->(RecLock("RBU", .F.))
					RBU->RBU_DTFIM 	:=	dDataBaixa
					RBU->(MsUnLock())
				EndIf

				RBU->(dbSkip())
			EndDo
			        
		EndIf
		
		RCX->(dbSkip())
	EndDo

	//���������������������������������������������������������������Ŀ
	//� Processo de exclusao dos registros do ocupante para nao perder�
	//� o ponteiro												      �
	//�����������������������������������������������������������������
    For nCount:= 1 to oPostos:GetCount()
    	RCX->( DBGoto( oPostos:GetItem(nCount) ) )
    	
    	oPostos:SetItem(nCount, RCX->RCX_POSTO)
    	
		RCX->( RecLock("RCX",.F., .T.))
		RCX->( DBDelete())	
		RCX->( MsUnLock())
	Next nCount
	      
	SRA->(DBSetOrder(1))
	
	If SRA->(DBSeek(cFilFun + cMatFun))
		SRA->(RecLock("SRA",.F.))
		SRA->RA_POSTO:= ""
		SRA->(MsUnLock())
	EndIf
	
	While ( GetSX8Len() > nGetSX8Len )
		ConfirmSX8()
	End While	

	RestArea(aAreaRBU)
	RestArea(aAreaRCL)
	RestArea(aAreaRCX)
	RestArea(aAreaSRA)
	RestArea(aArea)
Return oPostos:ToArray()


//-----------------------------------------------------------------------------
//<summary>
//		
//</summary>
//<param name="cFilFun">Filial do Funcionario</param>
//<param name="cMatFun">Matricula do Funcionario</param>
//<remarks></remarks>
//<history>
// 	<change date="08/07/2008" user="rogerio.ribeiro">Criacao da funcao.</change>
//</history>
//-----------------------------------------------------------------------------
Function OrgXDelRescisao(cFilFun, cMatFun)
   	Local cQuery	:= GetNextAlias()   	
	Local aArea
	Local aAreaSRA
	Local aAreaRCX
	Local aAreaRCL
	Local aAreaRBU
   	Local lPrincipal
	Local nGetSX8Len
   	
   	
   	If GetMv("MV_ORGCFG", NIL, "0") != "1"
		Return
	Endif
 	   	
	SX2->(dbSetOrder(1))	
	If !SX2->(dbSeek("RCX"))
		Return
	Endif
   	
	aArea	:= GetArea() 
	aAreaSRA:= SRA->( GetArea() )
	aAreaRCX:= RCX->( GetArea() )
	aAreaRCL:= RCL->( GetArea() )
	aAreaRBU:= RBU->( GetArea() )

	nGetSX8Len:= GetSX8Len()
   	
	BEGINSQL ALIAS cQuery
		COLUMN RBU_DTINI AS DATE
		
		SELECT 
			RBU_POSTO,
			RBU_DTINI,
			R_E_C_N_O_
		FROM 
			%table:RBU% RBU
		WHERE
			RBU_FILFUN = %exp:cFilFun% AND 
			RBU_MATFUN = %exp:cMatFun% AND 
			RBU_OPERAC = '3' AND 
			(RBU_SUBST = '2' OR RBU_SUBST = ' ') AND 
			%NotDel%  
		ORDER BY 
			RBU_DTFIM DESC
	ENDSQL
	
	If !(cQuery)->(Eof())
		RCL->(dbSetOrder(2))
		
	 	If RCL->(DBSeek(xFilial("RCL") + (cQuery)->RBU_POSTO ) )	            
		 	lPrincipal:= RCL->RCL_OPOSTO < RCL->RCL_NPOSTO
		 	
			RCL->(RecLock("RCL", .F.))
			RCL->RCL_OPOSTO	:= 	If(lPrincipal, RCL->RCL_OPOSTO + 1, RCL->RCL_NPOSTO)				
			RCL->RCL_STATUS	:=	If(RCL->RCL_OPOSTO ==  RCL->RCL_NPOSTO, "2", RCL->RCL_STATUS)	// 1=Livre;2=Ocupado;3=Congelado;4=Cancelado								
			RCL->(MsUnLock())
	 	
			RCX->( RecLock("RCX", .T.))
	       	RCX->RCX_FILIAL	:= xFilial("RCX")
	       	RCX->RCX_POSTO	:= (cQuery)->RBU_POSTO
			RCX->RCX_TIPOCU	:= "1"
			RCX->RCX_DTINI	:= (cQuery)->RBU_DTINI
			RCX->RCX_DTFIM	:= CTOD("//")
			RCX->RCX_FILFUN	:= cFilFun
			RCX->RCX_MATFUN	:= cMatFun
			RCX->RCX_SUBST 	:= If(lPrincipal, "2", "1")
			RCX->( MsUnLock())	

		 	RBU->( DBGoto( (cQuery)->R_E_C_N_O_ ))
			RBU->( RecLock("RBU", .F. ))
			RBU->RBU_DTFIM:= CTOD("//")
			RBU->( MsUnLock())				             
			     
			SRA->(DBSetOrder(1))
		
			If SRA->(DBSeek(cFilFun + cMatFun))
				SRA->(RecLock("SRA",.F.))
				SRA->RA_POSTO:= (cQuery)->RBU_POSTO
				SRA->(MsUnLock())
			EndIF
		EndIf
	EndIf

	(cQuery)->(DBCloseArea())
	
	While ( GetSX8Len() > nGetSX8Len )
		ConfirmSX8()
	End While	

	RestArea(aAreaRBU)
	RestArea(aAreaRCL)
	RestArea(aAreaRCX)
	RestArea(aAreaSRA)
	RestArea(aArea)
Return

//-----------------------------------------------------------------------------
//<summary>
//		
//</summary>
//<param name="cFilFun">Filial do Funcionario</param>
//<param name="cMatFun">Matricula do Funcionario</param>
//<param name="cPosto">Codigo do posto</param>
//<param name="dDataOcupacao">Data de inicio da ocupacao do posto</param>
//<param name="cFilPessoa">Filial do Participante</param>
//<param name="cCodPessoa">Codigo do Participante</param>
//<remarks></remarks>
//<history>
// 	<change date="08/07/2008" user="rogerio.ribeiro">Criacao da funcao.</change>
//</history>
//-----------------------------------------------------------------------------
Function OrgXOcupacao(cFilFun, cMatFun, cPosto, dDataOcupacao, cFilPessoa, cCodPessoa)
	Local aArea
	Local aAreaSRA
	Local aAreaRCX
	Local aAreaRCL
	Local aAreaRBU
	Local lExistePessoa
	Local nGetSX8Len
	Local lCadFun := IsInCallStack("GPEA010") .And. !INCLUI
	
 	If GetMv("MV_ORGCFG", NIL, "0") != "1"
		Return
	Endif
 	   	
	SX2->(dbSetOrder(1))	
	If !SX2->(dbSeek("RCX"))
		Return
	Endif
	
	dbSelectArea("RCL")
	RCL->(dbSetOrder(2))
        
 	If !RCL->(dbSeek(xFilial("RCL")+ cPosto))
 		Return .T.
 	EndIf
 	
	aArea	:= GetArea() 
	aAreaSRA:= SRA->( GetArea() )
	aAreaRCX:= RCX->( GetArea() )
	aAreaRCL:= RCL->( GetArea() )
	aAreaRBU:= RBU->( GetArea() )	
	
	nGetSX8Len:= GetSX8Len()
	
	If cFilPessoa == NIL .OR. cCodPessoa == NIL
		lExistePessoa:= ExistePessoa("SRA", cFilFun + cMatFun)
	Else
		lExistePessoa:= !Empty(cCodPessoa)
	EndIf
 	
	/*
	��������������������������������������������������������������Ŀ
	� Registro de movimentacao do posto							   �
	����������������������������������������������������������������*/
	RBU->(RecLock("RBU", .T.))
	RBU->RBU_FILIAL 	:=	xFilial("RBU")
	RBU->RBU_POSTO 		:=	RCL->RCL_POSTO
	RBU->RBU_PROCES		:=	RCL->RCL_PROCES
	RBU->RBU_DEPTO		:=	RCL->RCL_DEPTO                             
	RBU->RBU_CODMOV		:=	fBuscaMov()
	RBU->RBU_DTAMOV  	:=	dDataBase
	RBU->RBU_OPERAC 	:=  "3"				//1=Cria��o;2=Atualiza��o;3=Ocupa��o;4=Congelamento;5=Cancelamento		
	RBU->RBU_CARGO		:=	RCL->RCL_CARGO 
	RBU->RBU_FUNCAO		:=	RCL->RCL_FUNCAO
	RBU->RBU_CC			:=	RCL->RCL_CC	
	RBU->RBU_SALAR		:=	RCL->RCL_SALAR 
	RBU->RBU_ENCARG		:=	RCL->RCL_ENCARG
	RBU->RBU_BENEF		:=	RCL->RCL_BENEF 
	RBU->RBU_TPCONT		:=	RCL->RCL_TPCONT
	RBU->RBU_DTINI 		:=	dDataOcupacao

	If lExistePessoa
		RBU->RBU_FILOCU		:=	cFilPessoa
		RBU->RBU_CODOCU		:=	cCodPessoa
	EndIf

	RBU->RBU_RESPON		:=	cUsername
	RBU->RBU_FILFUN		:=	cFilFun
	RBU->RBU_MATFUN		:=	cMatFun
	If cPaisLoc == "BRA"
		RBU->RBU_FGTS		:=	RCL->RCL_FGTS  
	ElseIf cPaisLoc == "MEX"	
		RBU->RBU_LOCPAG		:=	RCL->RCL_LOCPAG			
	EndIF		
	RBU->(MsUnLock())
	
	/*/
	��������������������������������������������������������������Ŀ
	� Gravar a ocupacao do posto								   �
	����������������������������������������������������������������/*/
    RCX->(dbSetorder(4))		//RCX_FILIAL+RCX_FILFUN+RCX_MATFUN+RCX_POSTO
	RCX->(dbSeek(xFilial("RCX") + cFilFun + cMatFun + cPosto))

	RCX->(RecLock("RCX", !Found()) )
	RCX->RCX_FILIAL	:= xFilial("RCX")
	If !lCadFun
		RCX->RCX_SUBST 	:= IIf(RCL->RCL_OPOSTO < RCL->RCL_NPOSTO, "2", "1")	//1=Sim;2-Nao
	EndIf
	RCX->RCX_POSTO 	:= cPosto
	RCX->RCX_CODMOV	:= RBU->RBU_CODMOV

	If lExistePessoa
		RCX->RCX_FILOCU	:= cFilPessoa 
		RCX->RCX_CODOCU	:= cCodPessoa
	EndIf

	RCX->RCX_FILFUN	:= cFilFun
	RCX->RCX_MATFUN	:= cMatFun
	RCX->RCX_TIPOCU	:= "1"					//1=Funcionario;2=Pessoa
	RCX->RCX_DTINI	:= dDataOcupacao
	RCX->(MsUnlock())
	
	/*
	��������������������������������������������������������������Ŀ
	� Atualizar o posto											   �
	����������������������������������������������������������������*/
	If !lCadFun .And. RCX->RCX_SUBST == "2"
		RCL->(RecLock("RCL", .F.))
		RCL->RCL_STATUS := If(RCL->RCL_STATUS=="1", "2", RCL->RCL_STATUS)	// 1=Livre;2=Ocupado;3=Congelado;4=Cancelado
		RCL->RCL_OPOSTO += 1
		RCL->(MsUnLock())
		     
		dbSelectArea("SRA")
		dbSetOrder(1)
		
		If DBSeek(cFilFun + cMatFun)		
			SRA->(RecLock("SRA", .F.))
			SRA->RA_POSTO:= RCL->RCL_POSTO
			SRA->(MsUnLock())
		EndIf
	EndIf
	
	While ( GetSX8Len() > nGetSX8Len )
		ConfirmSX8()
	End While	
	
	RestArea(aAreaRBU)
	RestArea(aAreaRCL)
	RestArea(aAreaRCX)
	RestArea(aAreaSRA)
	RestArea(aArea)
Return

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �OrgXAprova�Autor�Igor Franzoi	            �Data�01/03/2009�
�����������������������������������������������������������������������Ĵ
�Descri��o �Gravacao da operacao de movimentacao de departamento		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico													�
�������������������������������������������������������������������������/*/
Function OrgXAprova( cFilRBT, cCodMov, cCodOpe, nQtDig, cCodJust, lIntRSP, lPortal, cDepto )

Local nPosto	:= 0
Local nQtd		:= 0
Local nTotPos	:= 0
Local lRet		:= .F.
Local lInclui	:= .T.
Local nGetSX8Len
Local cCodPos	:= ""
Local cFieldName
Local nField
Local nCount

Default lIntRSP := .F.
Default lPortal := .F.

If ( !Empty(cCodMov) )
		
	Begin Transaction	
		nGetSX8Len:= GetSX8Len()
				
		//��������������������������������������������������������������Ŀ
		//� Atualiza o status - Legenda								     �
		//� 1 - baixados												 �
		//� 2 - Pendente parcial										 �
		//� 3 - Pendente total										     �
		//����������������������������������������������������������������		
		dbSelectArea("RCL")
		dbSetOrder( RetOrder("RCL","RCL_FILIAL+RCL_POSTO") )

		If nTamDpt == Nil .Or. Empty( nTamDpt )
			nTamDpt := TamSX3( "RCL_DEPTO" )[ 1 ]
		EndIf 
		
		If cDepto == Nil .Or. Empty( cDepto )
			cDepto := Space( nTamDpt )
		EndIf

		dbSelectArea("RBT")	
		dbSetOrder(RetOrder("RBT","RBT_FILIAL+RBT_DEPTO+RBT_CODMOV"))
		RBT->(dbSeek(cFilRBT + cDepto + cCodMov))
		RecLock("RBT", .F.)
		//Se nao for do portal, faz o calculo da quantidade restante
		If !lPortal
			nQtd := Orgm10Saldo(.F.)
			RBT->RBT_STATUS:= If((nQtd + nQtDig) == RBT->RBT_QTDMOV, '1', '2')
		EndIf
		cCodPos	:= RBT->RBT_CODPOS
		If ( RBT->RBT_TIPOR == "2" )						
			lInclui:= !(RCL->(DBSEEK(RBT->RBT_FILIAL+RBT->RBT_CODPOS)))
			If !lInclui
				RBT->RBT_TPOSTO := "2"	
			EndIf
		EndIf
		MsUnlock()
		//Se nao for do portal, grava o registro da movimentacao. Se for solicitacao do portal,
		//ja foi feito gravacao do registro de movimentacao
		If !lPortal
			/*
			��������������������������������������������������������������Ŀ
			� Registro de movimenta��o do departamento					   �
			����������������������������������������������������������������*/
			dbSelectArea("RBX")
			RecLock("RBX",.T.)
			RBX->RBX_FILIAL	:=	xFilial("RBX")
			RBX->RBX_DEPTO 	:=	RBT->RBT_DEPTO
			RBX->RBX_CODMOV :=	cCodMov //RBT->RBT_CODMOV
			RBX->RBX_DTAMOV :=	RBT->RBT_DTAMOV
			RBX->RBX_CODOPE :=	cCodOpe //M->RBX_CODOPE	//Grava Status da Operacao: Aprovar/Cancelar/Congelar
			RBX->RBX_TPOSTO :=	RBT->RBT_TPOSTO //M->RBX_TPOSTO	//1=Individual;2=Generico
			RBX->RBX_QTDOPE	:=	nQtDig
			RBX->RBX_RESOPE	:=	cUsername
			RBX->RBX_JUSTIF := cCodJust
			MsUnLock()
		EndIf

		If RBX->RBX_CODOPE == "1"  //  Caso for Aprovado
			/*
			��������������������������������������������������������������Ŀ
			� Registro de criacao/alteracao do posto					   �
			����������������������������������������������������������������*/
			dbSelectArea("RCL")
			If ( !lInclui )
				dbSetOrder( RetOrder("RCL","RCL_FILIAL+RCL_POSTO") )
				RCL->(dbSeek(xFilial("RCL", cFilRBT) + cCodPos))
			EndIf
			For nPosto:= 1 to nQtDig
				RecLock("RCL",lInclui)
				If lInclui
					RCL->RCL_FILIAL 	:=	RBT->RBT_FILIAL
					RCL->RCL_POSTO 		:=	RCLPostoInit()
					RCL->RCL_PROCES 	:=	RBT->RBT_PROCES
					RCL->RCL_DEPTO 		:= 	RBT->RBT_DEPTO
					RCL->RCL_CARGO 		:=	RBT->RBT_CARGO
					RCL->RCL_FUNCAO 	:=	RBT->RBT_FUNCAO
					RCL->RCL_CC			:=	RBT->RBT_CC
					RCL->RCL_SALAR   	:=	RBT->RBT_REMUNE
					RCL->RCL_ENCARG  	:= 	RBT->RBT_ENCARG
					RCL->RCL_BENEF   	:= 	RBT->RBT_BENEF
					RCL->RCL_TPCONT 	:= 	RBT->RBT_TPCONT
					RCL->RCL_STATUS 	:= 	"1"	   				//Posto Vago para ocupacao
					RCL->RCL_DTATU  	:=	dDataBase			//?? RBT->RBT_DTAMOV
		
					If cPaisLoc == "BRA"
						RCL->RCL_FGTS   := 	RBT->RBT_FGTS
					ElseIf cPaisLoc == "MEX"
						RCL->RCL_LOCPAG	:= 	RBT->RBT_LOCPAG
					EndIf
				EndIf
				/*
				��������������������������������������������������������������Ŀ
				� Se o posto for generico cria um unico registro de posto com a�
				� quantidade aprovada.										   �
				����������������������������������������������������������������*/
				RCL->RCL_NPOSTO 	:= 	If(RBT->RBT_TPOSTO=="2", RCL->RCL_NPOSTO+nQtDig, 1)	//1=Individual;2=Generico
				RCL->RCL_TPOSTO 	:= 	RBT->RBT_TPOSTO		//1=Individual;2=Generico
				nTotPos				:= RCL->RCL_NPOSTO
				MsUnLock()

				/*
				��������������������������������������������������������������Ŀ
				� Integracao com Recrutamente e Selecao 					   �
				����������������������������������������������������������������*/
				If lIntRSP
		
					If lInclui
						// Rotina automatica de Inclusao de Vaga
						ORGXRSPINT(3,"RCL",nQtDig)
					Endif
					
				Endif

				/*
				��������������������������������������������������������������Ŀ
				� Registro de movimentacao do posto							   �
				����������������������������������������������������������������*/
				RecLock("RBU",.T.)
				  
				RBU->RBU_FILIAL 	:=	xFilial("RBU", RCL->RCL_FILIAL)
				RBU->RBU_POSTO 		:=	RCL->RCL_POSTO
				RBU->RBU_CODMOV		:=	fBuscaMov()
				RBU->RBU_DTAMOV  	:=	RCL->RCL_DTATU
				RBU->RBU_OPERAC 	:=  If ( lInclui, "1", "2" )					//1=Cria��o;2=Atualiza��o;3=Ocupa��o;4=Congelamento;5=Cancelamento		
				RBU->RBU_RESPON		:=	cUserName
				RBU->RBU_ORIGEM		:=	cCodMov 		//Relacionar com o movimentacao do Departamento RBT
				RBU->RBU_NPOSTO		:=	nTotPos
				
				For nCount:= 1 To RCL->(FCount())
					cFieldName:= RCL->(FieldName(nCount))
				
					If cFieldName $ "RCL_FILIAL/RCL_POSTO/RCL_TPOSTO/RCL_NPOSTO/RCL_OPOSTO/RCL_STATUS/RCL_DTINI/RCL_DTFIM/RCL_DTATU"
						Loop
					EndIF
					
					nField:= RBU->(FieldPos(StrTran(cFieldName, "RCL", "RBU")))
				
					If nField == 0
						Loop
					EndIF
								
					RBU->(FieldPut(nField, RCL->( FieldGet(nCount) ) ) )
				Next
				
				MsUnLock()			

				/*
				��������������������������������������������������������������Ŀ
				� Integracao com Recrutamente e Selecao 					   �
				����������������������������������������������������������������*/
				If lIntRSP

					If !lInclui
						// Verifica a necessidade de envio de WF para Aprovacao com base na tabela RBU-Historico
						ORGXFUNRSP(nQtDig)
					Endif

				Endif

				/*
				��������������������������������������������������������������Ŀ
				� Se o posto for generico cria um unico registro de posto com a�
				� quantidade aprovada.										   �
				����������������������������������������������������������������*/
				If RBT->RBT_TPOSTO == "2"	//1=Individual;2=Generico
					Exit
				EndIf
			Next nPosto
		EndIf
		lRet:=.T.
			
		While ( GetSX8Len() > nGetSX8Len )
			ConfirmSX8()
		End While	
	End Transaction

EndIf

Return ( lRet )
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �RD4ORGFiltro� Autor �Tatiane Vieira Matias� Data � 26.06.08 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Filtrar os departamentos de acordo com a visao Organizacio- ���
���          �nal e operacional                                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Consulta Padrao RD4ORG                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function RD4ORGFiltro()
	Local aArea    	:= GetArea()
	Local aAreaRDK 	:= RDK->( GetArea() )
	Local cFiltro  	:= ""     
	Local cEmpRD4  	:= ""
	Local cFilRD4  	:= ""
	Local cVisao	:= ""
	Local cAliasRD4	:= GetNextAlias()
	Local cItemRD4	:= ""
	
	cFiltro := " (RD4_FILIAL == '" + xFilial("RD4")  + "' .AND. "
	
	dbSelectArea("RDK")	
	dbSetOrder(4)		//RDK_FILIAL+RDK_HIERAR+RDK_TIPO+RDK_CODIGO
	
	If RDK->( dbSeek(xFilial("RDK")+"11") )
		If Type("oGetSRA2") != "U"		//Se existir o objeto oGetSRA2, � porque esta sendo chamado da transferencia nova
			cEmpRD4 := oGetSRA2:aCols[oGetSRA2:nAt, GdFieldPos("M_EMPRESA", oGetSRA2:aHeader)] 
			cFilRD4 := xFilial("SQB", oGetSRA2:aCols[oGetSRA2:nAt, GdFieldPos("RA_FILIAL", oGetSRA2:aHeader) ] )			
		ElseIf cFuncCall $ "GPEA010|GPEA011|RSPM001|TRMA100|GPEA265" .And. cOrgCfg == "1"
			cEmpRD4 := cEmpAnt
			cFilRD4 := xFilial("SQB")
		ElseIf cFuncCall $ "GPER103"
			If RDK->( dbSeek(xFilial("RDK",cFilAnt)+"11"+MV_PAR16) )
				cEmpRD4 := cEmpAnt
				cFilRD4 := xFilial("SQB",cFilAnt)		
				cFiltro += "  RD4_CODIGO == '" + RDK->RDK_CODIGO + "' .AND. "	
			EndIf
		Else
			cEmpRD4 := cEmpAnt
			cFilRD4 := xFilial("RCL")		
			cFiltro += "  RD4_CODIGO == '" + RDK->RDK_CODIGO + "' .AND. "	
		EndIf
	EndIf
	
	BeginSql alias cAliasRD4
		SELECT DISTINCT RD4.RD4_CODIDE, RD4.RD4_CODIGO FROM %table:RD4% RD4
		WHERE RD4.RD4_FILIDE = %exp:cFilRD4% 
		AND  RD4.RD4_EMPIDE = %exp:cEmpRD4% 
		AND RD4.RD4_CODIGO IN (
			SELECT RDK.RDK_CODIGO 
			FROM %table:RDK% RDK 
			WHERE RDK.RDK_HIERAR = '1'
			AND RDK_TIPO = '1'
			AND RDK.%NotDel% )
		AND RD4.%NotDel%
	EndSql
	
	While (cAliasRD4)->( !Eof() )
		If((Len(cItemRD4) + Len(AllTrim((cAliasRD4)->RD4_CODIDE))) < 1872) //tamanho limite para n�o apresentar error log de filtro
			cItemRD4 += AllTrim((cAliasRD4)->RD4_CODIDE) + '|'	
			If !AllTrim((cAliasRD4)->RD4_CODIGO) $ cVisao
				cVisao += AllTrim((cAliasRD4)->RD4_CODIGO) + '|'
			EndIf
		EndIf		
		(cAliasRD4)->( DbSkip() )
	EndDo		    		
	
	(cAliasRD4)->(dbCloseArea())
	
	cItemRD4 := "'" + cItemRD4 + "'"
	
	cFiltro += " RD4_EMPIDE == '" + cEmpRD4  + "' .AND. "
	cFiltro += " RD4_FILIDE == '" + cFilRD4  + "' .AND. "
	cFiltro += " RD4_CODIGO $ '"  + cVisao  + "' .AND. "
	cFiltro += " RD4_CODIDE $ " + cItemRD4 + ") "
	
	cFiltro := "@#" + cFiltro + "@#"
	
	RestArea( aAreaRDK )
	RestArea( aArea )
	
Return cFiltro

Function RCLORGFiltro()
	Local aArea    := GetArea()
	Local cFiltro  := ""     
	Local cFilRCL  := ""
	If cFuncCall $ "GPEA180|RU07T03"   
		If Type("oGetSRA2") != "U" .and. Type("oGetTran") == "U" //Se existir o objeto oGetSRA2, eh porque esta sendo chamado da transferencia nova
			cFilRCL := xFilial("RCL", oGetSRA2:aCols[oGetSRA2:nAt, GdFieldPos("RA_FILIAL", oGetSRA2:aHeader) ] )
		Elseif Type("oGetTran") != "U" 	//Se existir o objeto oGetTran, eh porque esta sendo chamado da transferencia para um unico destino
			cFilRCL := xFilial("RCL",oGetTran:aCols[oGetTran:nAt, GdFieldPos("RA_FILIAL", oGetTran:aHeader) ] )
		Else
			cFilRCL := xFilial("RCL")		
		EndIf
		cFiltro := " RCL_FILIAL == '" + cFilRCL  + "'  "
	EndIf
	
	If cFuncCall $ "GPEA010|GPEA011|RSPM001|TRMA100|GPEA265" .And. cOrgCfg == "1"
		cFilRCL := xFilial("RCL")
		
		If  Type("cDepart") != "U"
			cFiltro := " RCL_FILIAL == '" + cFilRCL + "' .And. RCL_DEPTO == '" + cDepart + "'"
		Else
			cFiltro := " RCL_FILIAL == '" + cFilRCL + "'"
		EndIf
	EndIf
	
	cFiltro := "@#" + cFiltro + "@#"
	
	RestArea( aArea )	
Return cFiltro

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ORGXRSPINT  � Autor �IP - RH Inovacao     � Data � 13.02.12 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Executar rotina automatica para inclusao/alteracao de Vagas ���
���          �Tabela SQS                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1 - opcao do menu 3-Inclusao 4-Alteracao                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Rotinas SIGAORG                                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function ORGXRSPINT(nOpc,cAliasInt,nQtDig)
Local aRotAuto		:= {}
Local aArea			:= GetArea()
Local cAliasQry		:= GetNextAlias()
Local cWhere		:= ""
Local nRegSQS		:= SQS->(Recno())
Local nQS_NRVAGA 	:= 0
Default nOpc 		:= 3
Default cAliasInt	:= "RCL"
Default nQtDig		:= 0

If !(cAliasInt == "RCL")
	dbSelectArea("RCL")
	dbSetOrder( RetOrder("RCL","RCL_FILIAL+RCL_POSTO") )
	dbSeek( (cAliasInt)->RCL_FILIAL+(cAliasInt)->RCL_POSTO )
Endif

If SubStr((cAliasInt)->RCL_TPOSTO, 1, 1) == '1'	// Tipo individual
	nQS_NRVAGA := (cAliasInt)->RCL_NPOSTO
Else
	nQS_NRVAGA := (cAliasInt)->RCL_NPOSTO-(cAliasInt)->RCL_OPOSTO
Endif

If nOpc == 3
	cWhere	:= "% SQS.D_E_L_E_T_ = ' ' AND SQS.QS_FILPOST = '" + (cAliasInt)->RCL_FILIAL+ "' AND SQS.QS_POSTO = '" + (cAliasInt)->RCL_POSTO +  "'%"
	BeginSql alias cAliasQry
	   	SELECT SQS.R_E_C_N_O_, SQS.QS_NRVAGA, SQS.QS_VAGAFEC
		FROM %table:SQS% SQS 
		WHERE %exp:cWhere%
		ORDER BY R_E_C_N_O_ DESC
	EndSql

	// Verifica se encontrou algum registro e se est� pendente para alteracao com o numero total de vagas, senao cria um novo
	// registro no SQS apenas com o numero de vagas solicitadas
	If (cAliasQry)->( !Eof() )
		While (cAliasQry)->( !Eof() )
			If ( (cAliasQry)->QS_NRVAGA - (cAliasQry)->QS_VAGAFEC ) > 0
				SQS->( dbGoTo((cAliasQry)->(R_E_C_N_O_)) )
				nRegSQS 	:= (cAliasQry)->(R_E_C_N_O_)
				nQS_NRVAGA	:= (cAliasQry)->QS_NRVAGA + nQtDig
				nOpc 		:= 4
			Else
				nQS_NRVAGA	:= nQtDig
			Endif
			Exit
			(cAliasQry)->( dbSkip() )
		Enddo
	Endif
	
	dbCloseArea()
	dbSelectArea(cAliasInt)
Elseif  nOpc == 6	// Inclusao de Vagas apenas com qtde aprovada
	nQS_NRVAGA := nQtDig
Endif

If nOpc == 3 .Or. nOpc == 6
	Aadd( aRotAuto, { "QS_FILIAL", xFilial("SQS",(cAliasInt)->RCL_FILIAL), Nil })
	Aadd( aRotAuto, { "QS_DESCRIC", STR0010 + " " + fDesc('SQB',(cAliasInt)->RCL_DEPTO ,'SQB->QB_DESCRIC',,,1), Nil }) // "Vaga aberta para o departamento"
	Aadd( aRotAuto, { "QS_FILPOST", (cAliasInt)->RCL_FILIAL, Nil })
	Aadd( aRotAuto, { "QS_POSTO", (cAliasInt)->RCL_POSTO, Nil })
	Aadd( aRotAuto, { "QS_CC", (cAliasInt)->RCL_CC, Nil })
	Aadd( aRotAuto, { "QS_FUNCAO", (cAliasInt)->RCL_FUNCAO, Nil })
	Aadd( aRotAuto, { "QS_NRVAGA", nQS_NRVAGA, Nil })
	Aadd( aRotAuto, { "QS_SOLICIT", UsrRetName(RetCodUsr()), Nil })
	Aadd( aRotAuto, { "QS_DTABERT", DATE(), Nil })
	Aadd( aRotAuto, { "QS_TIPO", "1", Nil })

	RSP100Inc("SQS",0,nOpc,aRotAuto)
ElseIf nOpc == 4
	If ( SQS->QS_FUNCAO <> (cAliasInt)->RCL_FUNCAO .Or. SQS->QS_CC <> (cAliasInt)->RCL_CC ) 
		Aadd( aRotAuto, { "QS_FUNCAO", (cAliasInt)->RCL_FUNCAO, Nil })
		Aadd( aRotAuto, { "QS_CC", (cAliasInt)->RCL_CC, Nil })
	Else
		Aadd( aRotAuto, { "QS_NRVAGA", nQS_NRVAGA, Nil })
	Endif
	RSP100Alt("SQS",nRegSQS,nOpc,aRotAuto)
Endif

RestArea(aArea)

Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ORGA30RSP     �Autor  �IP-RH Inovacao  � Data �  09/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se existe Postos (ORG) associados a Vagas (RSP)   ���
���          � e envia WF de aprovacao caso houver aumento de quadro      ���
�������������������������������������������������������������������������͹��
���Uso       � ORGA030                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ORGXFUNRSP(nQtDig)
Local cAliasQry		:= GetNextAlias()
Local cWhere		:= ""
Default nQtDig		:= 1

cWhere	:= "% SQS.D_E_L_E_T_ = ' ' AND SQS.QS_FILPOST = '" + RBU->RBU_FILIAL+ "' AND SQS.QS_POSTO = '" + RBU->RBU_POSTO +  "'%"
BeginSql alias cAliasQry
   	SELECT SQS.R_E_C_N_O_ AS RECNO,SQS.QS_NRVAGA,SQS.QS_VAGAFEC
	FROM %table:SQS% SQS 
	WHERE %exp:cWhere%
	ORDER BY QS_VAGA DESC 
EndSql

If (cAliasQry)->( !Eof() )

	SQS->( dbGoTo( (cAliasQry)->RECNO ) )
	WFAltVagas(0,nQtDig)

	// Rotina automatica de Inclusao de Vaga
	ORGXRSPINT(3,"RCL",nQtDig)

Else
	// Inclui a vaga no RSP sem WF
	ORGXRSPINT(6,"RCL",nQtDig)
Endif

dbSelectArea(cAliasQry)
dbCloseArea()

dbSelectArea("RBU")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �ORGCombo  � Autor � IP - RH Inovacao  	� Data � 07.03.12 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Retorna um array com as opcoes do combo do campo           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � ORGCombo(cCampo)											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - campo a ser selecionado para retorno do combo	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso	 	 � SIGAORG  												  ���
��������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������� */
Function ORGCombo(cCampo)
Local aArea    := GetArea()
Local cBox     := ""
Local aBox     := {}
Local nPosicao1:= 0
Local nPosicao2:= 0
Local cElem1 	:= cElem2:= ""
Local cIdiom	:= FWRetIdiom()        //Retorna Idioma Atual

dbSelectArea("SX3")
dbSetOrder(2)
If ( MsSeek(cCampo) )
	If cIdiom == "pt-br" 
		cBox  := SX3->X3_CBOX
	ElseIf cIdiom == 'es'
		cBox  := SX3->X3_CBOXSPA
	ElseIf cIdiom == 'en' 
		cBox  := SX3->X3_CBOXENG
	EndIf
	While ( !Empty(cBox) )
		nPosicao1   := At(";",cBox)
		If ( nPosicao1 == 0 )
			nPosicao1 := Len(cBox)+1
		EndIf
		nPosicao2   := At("=",cBox)
		cElem1 := SubStr(cBox,1,nPosicao2-1)
		cElem2 := SubStr(cBox,nPosicao2+1,nPosicao1-nPosicao2-1)
		aadd(aBox,{cElem1+' - '+cElem2,cElem1})
		cBox := SubStr(cBox,nPosicao1+1)
	EndDo
EndIf
dbSelectArea("SX3")
dbSetOrder(1)

RestArea(aArea)
Return(aBox)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �fBuscaMov� Autor � Fernando Luis Guilherme� Data � 10.08.20 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Retorna o pr�ximo n�mero de c�digo de movimento            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fBuscaMov()												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                       	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso	 	 � SIGAORG  												  ���
��������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������� */

Static Function fBuscaMov ()
Local aAreaRBU := RBU->(GetArea())
Local cCodMov 
Local cAliasTab:= GetNextAlias()
Local bX := .T.
Local nRbuMovTam := GetSx3Cache( "RBU_CODMOV" , "X3_TAMANHO" )

BeginSql Alias cAliasTab
		SELECT MAX(RBU_CODMOV) CODMOV  FROM  %table:RBU%  RBU
		WHERE  RBU.RBU_FILIAL = %Exp:( xFilial("RBU") )%
		AND    %NotDel%
EndSql

cCodMov := StrZero(Val((cAliasTab)->CODMOV)+1,nRbuMovTam)

//Verifico se realmente o codigo � o correto a ser utilizado de acordo com a chave prim�ria

While bX
	If RBU -> (dbSeek(xFilial("RBU")+RCL->RCL_POSTO+cCodMov))
		cCodMov := StrZero(Val((cAliasTab)->CODMOV)+1,nRbuMovTam)
	Else
		bX:= .F.
	EndIf
End While

(cAliasTab)->(dbCloseArea())
RestArea(aAreaRBU)

Return cCodMov
