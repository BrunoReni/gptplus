#INCLUDE "TMKA061F.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMKA061C  �Autor  �Vendas Clientes     � Data �  07/24/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fonte com as funcoes de processo da Lista de Contato.       ���
���          �Tmka061                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � AP8 - Lista de Contato.                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Funcao    �TK061Del     �Autor �Vendas Clientes      � Data � 21/07/03  ���
��������������������������������������������������������������������������͹��
���Descricao � Rotina de Exclusao de Lista           					   ���
��������������������������������������������������������������������������͹��
���Uso       � Lista de Contatos                    	              	   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function Tk061Del()

Local lRet			:= .F.
Local cU4_Operad 	:= ""  

#IFDEF TOP
	Local cQuery 		:= ""
#ENDIF

BEGIN TRANSACTION

	If TmkOk(STR0001)	 //"Confirma a exclus�o da Lista de Contatos? "
		
		//������������������������������������Ŀ
		//�Apaga os itens da lista de contatos.�
		//��������������������������������������
		#IFDEF TOP
			cQuery += "DELETE FROM "
			cQuery += RetSqlName("SU6")+" "
			cQuery += "WHERE U6_FILIAL='"+xFilial("SU6")+"' AND "
			cQuery += "U6_LISTA='"+SU4->U4_LISTA+"' "
			
			TcSqlExec(cQuery)			
		
		#ELSE
			DbSelectArea("SU6")
			DbSetOrder(1)
		
			If DbSeek(xFilial("SU6") + SU4->U4_LISTA)
				While (!Eof()) .AND. (SU6->U6_FILIAL == xFilial("SU6")) .AND. (SU6->U6_LISTA == SU4->U4_LISTA)
					Reclock( "SU6" ,.F.,.T.)
					DbDelete()
					MsUnlock()
					DbSkip()
				End
			Endif
		#ENDIF
		
		//���������������������������������Ŀ
		//�Apaga o memo da mensagem do EMAIL�
		//�����������������������������������
		MSMM(SU4->U4_CODMENS,80,,,2)
		
		//�����������������������������������������������������������������������������������Ŀ
		//�Verifica se a lista ja foi finalizada para posterior retirada de tarefa do Operador�
		//�������������������������������������������������������������������������������������
		If  SU4->U4_STATUS == "1" // Ativa
			cU4_Operad := SU4->U4_OPERAD
		Endif
		
		//�����������������������������������������������������������������������������������Ŀ
		//�Apaga o codigo da lista de AB9 e AB7 quando for lista de O.S. do sigatec           �
		//�������������������������������������������������������������������������������������
		DbSelectArea("AB9")		
		DbSetOrder(8) // FILIAL+AB9_TMKLST
		If MsSeek(XFilial("AB9")+SU4->U4_LISTA)
			While !Eof() 
				If AB9_FILIAL == XFilial("AB9") .AND. AB9_TMKLST == SU4->U4_LISTA
					RecLock( "AB9", .F. )
					Replace AB9->AB9_TMKLST With Space(Len(SU4->U4_LISTA))
					AB9->(MsUnLock())
				EndIf					
				AB9->(DbSkip())
			End		
		EndIf
			
		DbSelectArea("AB7")
		DbSetOrder(8) // FILIAL+AB7_TMKLST
		If MsSeek(XFilial("AB7")+SU4->U4_LISTA)
			While !Eof() 				
				If AB7_FILIAL == XFilial("AB7") .AND. AB7_TMKLST == SU4->U4_LISTA
					RecLock( "AB7", .F. )
					Replace AB7->AB7_TMKLST With Space(Len(SU4->U4_LISTA))
					AB7->(MsUnLock())
				EndIf	
				AB7->(DbSkip())
			End						
		EndIf								

		//���������������������������������������Ŀ
		//�Apaga o cabecalho da lista de contatos.�
		//�����������������������������������������
		DbSelectArea("SU4")
		Reclock( "SU4" ,.F.,.T.)
		DbDelete()
		MsUnlock()
		
		If !EMPTY(cU4_Operad)
			Tk061GrvTarefa(cU4_Operad,2)
		Endif
		
		lRet:= .T.
	Endif
	
END TRANSACTION

Return(lRet)

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Tk061Grava � Autor � Vendas Clientes       � Data � 28/10/03 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Gravacao da lista de contatos SU4 e SU6  com integridade.    ���
��������������������������������������������������������������������������Ĵ��
���Uso       �Lista de Contatos                                            ���
��������������������������������������������������������������������������Ĵ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function Tk061Grava(nOpc			,aLista	,cAssunto	,cMensagem	,;
						cAttach	,aAttach	,cFiltro	,cSelOper	,;
						lGrvCab	,nSaveSX8	,lOS		,cOSIni		,;
						cOSFim		,lEntMonOS)

Local nCampo	:= 0				 				// Variavel para gravacao dos campos
Local lRec		:= .T.			   					// Retorno da funcao
Local nI 		:= 0 				  				// Contador
Local aArea		:= GetArea()		   				// Salva a area atual
Local lTK61ValC	:= ExistBlock("TK61VALC") 			// P.E  Antes da grava��o da lista.
Local lRet 		:= .T.   							// Variavel de retorno para o P.E.
Local lTK061Grv	:= ExistBlock("TK061GRV")			// Controle de ponto de entrada   
Local aSLARegister := {}							// Retorno da rotina de SLA

Default lOS		:= .F.
Default lEntMonOS	:= .F.

//������������������������������������������Ŀ
//�Realiza a gravacao da geracao de contatos.�
//��������������������������������������������
BEGIN TRANSACTION

	If !lGrvCab
		If nOpc == ALTERAR
				
				//��������������������������Ŀ
				//�Apaga o memo da mensagem .�
				//����������������������������
				MSMM(SU4->U4_CODMENS,80,,,2)  	//nao ha alteracao de dados de lista ja gerada.
		EndIf
		
		//�����������������������������������������������������������������Ŀ
		//�Efetua verificacao do tipo de operacao para a execucao do RecLock�
		//�������������������������������������������������������������������
		If 	nOpc <> INCLUIR .AND. nOpc <> INCLUIAUTO .AND. nOpc <> ASSISTENTE
			lRec := .F.
		Else
			lRec := .T.
		Endif

		//���������������������������������������Ŀ
		//�Grava o cabecalho da Lista de Contatos.�
		//�����������������������������������������
		RecLock("SU4",lRec)
		For nCampo:= 1 To FCount()
			
			//����������������������������������������������������������Ŀ
			//�Caso nao seja uma ALTERACAO grava normalmente o cabecalho.�
			//������������������������������������������������������������
			If nOpc != ALTERAR 
			
				Do Case
					Case (FieldName(nCampo) == "U4_FILIAL" )
						FieldPut(nCampo, xFilial("SU4"))
					
					Case (FieldName(nCampo) == "U4_ASSUNTO" )
						FieldPut(nCampo, cAssunto)
						
					Case (FieldName(nCampo) == "U4_ATTACH" )
						FieldPut(nCampo, cAttach)
						
					Case (FieldName(nCampo) == "U4_FILTRO" )
						FieldPut(nCampo, cFiltro)
						
					Case (FieldName(nCampo) == "U4_STATUS" )
						FieldPut(nCampo, "1")
						
					Case (FieldName(nCampo) == "U4_OPERAD" )
						FieldPut(nCampo, cSelOper)  
					OtherWise               	
						FieldPut(nCampo, M->&(FieldName(nCampo)))
				EndCase
			            
				If nModulo == 73 //SIGACRM
			       SU4->U4_ORIGEM := M->U4_ORIGEM
			       SU4->U4_CUSTO  := M->U4_CUSTO
				EndIf
			
			//���������������������������������������������������������������������Ŀ
			//�Caso seja Alteracao grava somente os campos que podem ser alterados. �
			//�Neste caso a funcao de Montagem da Lista foi pulada, pois nao poderao�
			//�ser gravados campos que influenciem em seus dados ja selecionados.   �
			//�����������������������������������������������������������������������
			Else
				Do case
					Case (FieldName(nCampo) == "U4_ASSUNTO" )
						FieldPut(nCampo, cAssunto)
						
					Case (FieldName(nCampo) == "U4_ATTACH" )
						FieldPut(nCampo, cAttach)
	
					Case (FieldName(nCampo) == "U4_OPERAD" )
						FieldPut(nCampo, cSelOper)
	
					Case (FieldName(nCampo) == "U4_MALADIR" )
						FieldPut(nCampo, M->&(FieldName(nCampo)))
	
					Case (FieldName(nCampo) == "U4_ETIQUET" )
						FieldPut(nCampo, M->&(FieldName(nCampo)))
				
					Case (FieldName(nCampo) == "U4_CODCAMP" )
						FieldPut(nCampo, M->&(FieldName(nCampo)))
	
					Case (FieldName(nCampo) == "U4_DESCCAM" )
						FieldPut(nCampo, M->&(FieldName(nCampo)))
						
					Case (FieldName(nCampo) == "U4_SCRIPT" )
						FieldPut(nCampo, M->&(FieldName(nCampo)))
	
					Case (FieldName(nCampo) == "U4_EVENTO" )
						FieldPut(nCampo, M->&(FieldName(nCampo)))
						
					Case (FieldName(nCampo) == "U4_DESC" )
						FieldPut(nCampo, M->&(FieldName(nCampo)))
	
					Case (FieldName(nCampo) == "U4_CONFIG" )
						FieldPut(nCampo, M->&(FieldName(nCampo)))
	
					Case (FieldName(nCampo) == "U4_TELE" )	
						FieldPut(nCampo, M->&(FieldName(nCampo)))
				EndCase     
		
			Endif	
		Next nCampo         
		 If nModulo == 73 //SIGACRM
		     SU4->U4_DTUPD := DDataBase 
		     SU4->U4_ORIGEM := M->U4_ORIGEM
		     SU4->U4_CUSTO  := M->U4_CUSTO
		 EndIf
	     
	    //���������������������������Ŀ           
		//�Grava a mensagem do e-mail.�
		//�����������������������������             
		
		If !Empty(cMensagem)
			MSMM(,80,,cMensagem,1,,,"SU4","U4_CODMENS") //Mensagem do Email
		Endif
	    
	    
		cMensagem:= Space(400)
		cAssunto := CriaVar("U4_ASSUNTO",.F.)
		aAttach  := {}
		cAttach  := ""
        cFiltro	 := ""
        
		lGrvCab := .T.
		FKCOMMIT()
	Endif
	
	If lOS
		DbSelectArea( "AB7" )
		DbSetOrder(6)
		If AB7->(DBSeek( xFilial( "AB7" ) + aLista[1][8], .T. )) //Codigo do Contato
			While	xFilial( "AB7" ) + aLista[1][8] == AB7->AB7_FILIAL + AB7->AB7_CODCON	.And.	;
					AB7->(!EOF())
				
				If !lEntMonOS // Pesquisa de Satisfa��o				
					DbSelectArea( "AB9" )
					DbSetOrder( 1 )
					If AB9->(DbSeek( xFilial("AB9") + AB7->AB7_NUMOS + AB7->AB7_ITEM ))					
						While	xFilial("AB9") + AB7->AB7_NUMOS + AB7->AB7_ITEM == AB9->AB9_FILIAL + AB9_NUMOS	.And.	;
								AB9->(!EOF())
							If AB9->AB9_TIPO == '1' .And. Empty(AB9->AB9_TMKLST)
								If !Empty(cOSIni) .Or. !Empty(cOSFim)
									If !(AB9->AB9_NUMOS >= cOSIni .And. AB9->AB9_NUMOS <= cOSFim)
										RecLock( "AB9", .F. )
										Replace AB9->AB9_TMKLST With U4_LISTA
										AB9->(MsUnLock())
									EndIf
								EndIf 
							EndIf
							AB9->(DbSkip())
						End
					EndIf
				Else //Entrega e Montagem
					DbSelectArea( "AB6" )
					DbSetOrder( 1 )
					If AB6->(DbSeek( xFilial("AB6") + AB7->AB7_NUMOS ))					
						If !Empty(AB6->AB6_NUMLOJ) 
							If !Empty(cOSIni) .Or. !Empty(cOSFim)
								If !(AB7->AB7_NUMOS >= cOSIni .And. AB7->AB7_NUMOS <= cOSFim) 
										RecLock( "AB7", .F. )
										Replace AB7->AB7_TMKLST With U4_LISTA
										AB7->(MsUnLock())	
								EndIf														
							EndIf 
						EndIf
					End				
				EndIf				        
				AB7->(DbSkip())					
			End	
		EndIf                                                                       
	EndIf

	//�������������������������������������Ŀ
	//�Grava as chamadas a serem executadas.�
	//���������������������������������������
	If nOpc <> ALTERAR  // Na alteracao nao sao gravados os itens.
	
		If lTK61ValC
			lRet := U_TK61ValC(aLista)
		
			// Se o retorno for .F. nao prossegue com a grava��o
		   
			If (ValType(lRet) <> "L")
				lRet := .T.
	   		Endif
		Endif
	    				    
		  	If M->U4_BLQCONT == "2" 
				If lRet := TK700VldAut(M->U4_BLQCONT,M->U4_FORMA,M->U4_TIPOTEL,M->U4_TELE,aLista[1,8])
					
					If lRet
						DbSelectArea("SU6")
						
						RecLock("SU6",.T.)
						Replace U6_FILIAL  With aLista[1][1]  //Filial
						Replace U6_LISTA   With aLista[1][2]  //Codigo da Lista
						Replace U6_CODIGO  With aLista[1][3]  //Codigo de Interacao
						Replace U6_FILENT  With aLista[1][4]  //Filial da Entidade
						Replace U6_ENTIDA  With aLista[1][5]  //Entidade
						Replace U6_CODENT  With aLista[1][6]  //Codigo da Entidade
						Replace U6_ORIGEM  With aLista[1][7]  //Origem da Interacao
						Replace U6_CONTATO With aLista[1][8]  //Contato
						Replace U6_DATA    With aLista[1][9]  //Data
						Replace U6_HRINI   With aLista[1][10] //Hora Inicio
						Replace U6_HRFIM   With aLista[1][11] //Hora Fim
						Replace U6_STATUS  With aLista[1][12] //Status da Interacao
						
						If Len(aLista[1]) > 12 .AND. !Empty(aLista[1][13])
							Replace U6_NUMOS  With aLista[1][13] //Numero O.S. Field
						EndIf
					
						Replace U6_DTBASE	With dDataBase
											
						MsUnlock()
						FkCommit()
					Endif
					
                EndIf
		        
			Else
		        
		        	If lRet
						DbSelectArea("SU6")
						
						RecLock("SU6",.T.)
						Replace U6_FILIAL  With aLista[1][1]  //Filial
						Replace U6_LISTA   With aLista[1][2]  //Codigo da Lista
						Replace U6_CODIGO  With aLista[1][3]  //Codigo de Interacao
						Replace U6_FILENT  With aLista[1][4]  //Filial da Entidade
						Replace U6_ENTIDA  With aLista[1][5]  //Entidade
						Replace U6_CODENT  With aLista[1][6]  //Codigo da Entidade
						If nModulo <> 73 //SIGACRM
							Replace U6_ORIGEM  With aLista[1][7]  //Origem da Interacao
						EndIf
						Replace U6_CONTATO With aLista[1][8]  //Contato
						Replace U6_DATA    With aLista[1][9]  //Data
						Replace U6_HRINI   With aLista[1][10] //Hora Inicio
						Replace U6_HRFIM   With aLista[1][11] //Hora Fim
						Replace U6_STATUS  With aLista[1][12] //Status da Interacao
						
						If Len(aLista[1]) > 12 .AND. !Empty(aLista[1][13]) .And.nModulo <> 73 //SIGACRM
							Replace U6_NUMOS  With aLista[1][13] //Numero O.S. Field
						EndIf
						
						Replace U6_DTBASE	With dDataBase
						
						MsUnlock()
						FkCommit()
					Endif
		
				EndIf 	
				
	//������������������������������������������������������������������������������Ŀ
	//�Em caso de alteracao serao apagados os itens que estiverem deletados do aCols.�
	//��������������������������������������������������������������������������������
	Else
		DbSelectArea("SU6")
		DbSetOrder(1) // FILIAL + LISTA + CODIGO
		
		For nI:= 1 To Len(aCols)
			If aCols[nI][Len(aHeader)+1]
				If DbSeek(xFilial("SU6") + M->U4_LISTA+ aCols[nI][Ascan(aHeader,{|aVal| Alltrim(aVal[2])== "U6_CODIGO"  })])
					If !Empty(SU6->U6_REGSLA)   
						Tk061FimSLA(SU6->U6_REGSLA)
					EndIf                          
					Reclock("SU6",.F.,.T.)
					DbDelete()
					MsUnlock()
				Endif
			Endif
		Next nI
	Endif    

END TRANSACTION

If nOpc <> ALTERAR .AND. lRet
	If !Empty(M->U4_SERVSLA)
		aSLARegister := Tk061SLA(M->U4_SERVSLA)
		If Len(aSLARegister)>0
			Reclock("SU6",.F.,.T.)
			Replace U6_REGSLA	With aSLARegister[1]
			MsUnlock()
		EndIf
	EndIf
EndIf

If lTK061Grv
	ExecBlock("TK061GRV",.F.,.F.,{} )
EndIf

RestArea(aArea)

Return lRet
                                                 
/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Funcao    �Tk061GrvTarefa�Autor  �Vendas Clientes     � Data �  07/15/03   ���
�����������������������������������������������������������������������������͹��
���Desc.     � Grava a tarefa no SU7 para o operador.                         ���
�����������������������������������������������������������������������������͹��
���Retorno   �Logico                                                          ���
�����������������������������������������������������������������������������͹��
���Parametros�ExpC1: Codigo do operador                                       ���
���          �ExpN1: Opcao selecionada 1- Soma 2- Subtrai                     ���
�����������������������������������������������������������������������������͹��
���Uso       � Lista de Contatos                                              ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Function Tk061GrvTarefa(cSelOper,nOpX)
Local lRet   := .F.
Local aSArea := GetArea()
Local nVal   := 0

DbSelectArea("SU7")
DbSetOrder(1)
IF DbSeek(xFilial("SU7")+ cSelOper)
    nVal := SU7->U7_TAREFA
    
    If nOpX == 1
 	   nVal++
	ElseIf nOpX == 2
	   If nVal > 0
	      nVal--
	   Endif   
	Endif
	
	If RecLock("SU7",.F.)
		Replace SU7->U7_TAREFA With nVal
		MsUnlock()
		DbCommit()
		lRet := .T.
	Endif	
Endif
RestArea(aSArea)
Return (lRet)

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Funcao    �Tk061GrvTrans �Autor  �Vendas Clientes     � Data �  07/15/03   ���
�����������������������������������������������������������������������������͹��
���Desc.     � Grava a transferencia de Listas                                ���
�����������������������������������������������������������������������������͹��
���Retorno   �Logico                                                          ���
�����������������������������������������������������������������������������͹��
���Parametros�ExpA1: Array com as listas.                                     ���
���          �ExpD1: Data para transferencia                                  ���
���          �ExpC1: Codigo do Operador                                       ���
�����������������������������������������������������������������������������͹��
���Uso       � Lista de Contatos                                              ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Function TK061GrvTrans(aListas,dData,cOperad)
Local lRet 	:= .F.	// Retorno da funcao
Local nI	:= 0 	// Controle do for
DbSelectArea("SU4")
DbSetOrder(1)

BEGIN TRANSACTION 
	For nI := 1 To Len(aListas)
		If aListas[nI][1]
			If SU4->(DbSeek(xFilial("SU4")+aListas[nI][2]))
				SU4->(Reclock( "SU4" ,.F.))
				REPLACE SU4->U4_DATA   WITH dData
				REPLACE SU4->U4_OPERAD WITH cOperad
				SU4->(MsUnlock())
				lRet := .T.
				If SU4->U4_TIPO == "1"	//"Marketing"
					//Atualiza o atendimento com o novo operador
					dbSelectArea("SUC")
					SUC->(dbSetOrder(1))
					If SUC->(dbSeek(xFilial("SUC")+SU4->U4_CODLIG ))
						SUC->(RecLock("SUC",.F.))
							SUC->UC_OPERADO := cOperad
						SUC->(MsUnlock())				
					EndIf
				ElseIf SU4->U4_TIPO == "3"	//"Vendas"
					//Atualiza o atendimento com o novo operador
					dbSelectArea("SUA")
					SUA->(dbSetOrder(1))
					If SUA->(dbSeek(xFilial("SUA")+SU4->U4_CODLIG ))
						SUA->(RecLock("SUA",.F.))
							SUA->UA_OPERADO := cOperad
						SUA->(MsUnlock())				
					EndIf				
				EndIf	
			Endif
		Endif	
	Next nI
END TRANSACTION

Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �TK061COPIA�Autor  �Vendas Clientes     � Data �  28/10/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao que executa a copia de listas de contato.            ���
���          �Gravacao com Integridade.                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Lista de Contatos                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Tk061Copia(oSay,oMeter,cAlias,nReg,nOpc,cNome,dData,cOperad,lAutomato)

Local cLista     := ""					// Codigo da Lista
Local cNovaLista := ""					// Codigo da nova Lista
Local nCampo     := 0					// Campo para FieldPut
Local nRecord    := 0					// Contole
Local aCampos    := Array(1,FCount())	// Array com campos para copia
Local lRet		 := .F.
Local nTotCpy	 := 0
Local cChave     := ""
Local aAutoAO4   := {}

Default lAutomato := .F.

DbSelectArea(cAlias)
DbSetOrder(1)

If !lAutomato
	oSay:Show()
	oMeter:Show()
	oMeter:Refresh()   
EndIf

DbGoto(nReg)

If Eof()
	HELP("",1,"ARQVAZIO")
	lRet := .F.
Else
	
	cLista := SU4->U4_LISTA
	
	If !lAutomato
		nTotCpy:= Tk061TotCpy(cLista)
		oMeter:SetTotal(nTotCpy)
		nTotCpy := 0
	EndIf
	
	BEGIN TRANSACTION
	
		//������������Ŀ
		//�Copia o SU4.�
		//��������������
		For nCampo := 1 To FCount()
			aCampos[1,nCampo]:= FieldGet(nCampo)
		Next nCampo
		
		RecLock("SU4",.T.)
		For nCampo:=1 To FCount()
			
			Do Case
				
				Case (Field(nCampo) == "U4_LISTA")
					cNovaLista:= GetSxeNum("SU4","U4_LISTA")
					FieldPut(nCampo,cNovaLista)
					ConfirmSx8()
					
				Case (Field(nCampo) == "U4_DESC")
					FieldPut(nCampo,cNome)
					
				Case (Field(nCampo) == "U4_DATA")
					FieldPut(nCampo,dData)
					                      
				Case (Field(nCampo) == "U4_OPERAD")
					FieldPut(nCampo,cOperad)	

				Case (Field(nCampo) == "U4_STATUS")
					FieldPut(nCampo,"1")	// 1=Ativa;2=Encerrada;3=Em Andamento

				OtherWise
					FieldPut(nCampo,aCampos[1,nCampo])
					
			EndCase
			
		Next nCampo
		
		MsUnLock()
		DbCommit()
		
		//������������Ŀ
		//�Copia o SU6 �
		//��������������
		DbSelectArea("SU6")
		DbSetOrder(1)
		If DbSeek(xFilial("SU6") + cLista)
			aCampos := {}
			
			While !Eof() .AND. (xFilial("SU6") == SU6->U6_FILIAL) .AND. (cLista == SU6->U6_LISTA)
				Aadd(aCampos,Array(FCount()))
				
				For nCampo := 1 To FCount()
					aCampos[Len(aCampos),nCampo]:= FieldGet(nCampo)
				Next nCampo	
				
				DbSkip()
			End
			
			For nRecord:=1 To Len(aCampos)
				RecLock("SU6",.T.)
				For nCampo:= 1 To FCount()
					If (Field(nCampo) == "U6_LISTA")
						FieldPut(nCampo,cNovaLista)
					ElseIf (Field(nCampo) == "U6_STATUS")
						FieldPut(nCampo,"1")	// 1=Nao Enviado;2=Em Uso;3=Enviado
					ElseIf (Field(nCampo) == "U6_DATA")
						FieldPut(nCampo,dData)
					ElseIf (Field(nCampo) == "U6_DTBASE")
						FieldPut(nCampo,dDataBase)
					Else
						FieldPut(nCampo,aCampos[nRecord,nCampo])
					Endif
				Next nCampo
				
				MsUnLock()
				DbCommit()
				
				If !lAutomato
					//Atualiza barra de progressao
					oMeter:Set(nTotCpy+1)
					oMeter:Refresh()
				EndIf
				
			Next nRecord
			//���������������������������������������������������Ŀ
			//�Adiciona ou Remove o privilegios deste registro.  �
			//����������������������������������������������������
			If nModulo == 73 //SIGACRM
				cChave   := PadR(xFilial("SU4")+cNovaLista+dTos(dData),TAMSX3("AO4_CHVREG")[1])		
				aAutoAO4 := CRMA200PAut(nOpc,"SU4",cChave,/*cCodUsr*/,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)    
				lRet 	  := CRMA200Auto(aAutoAO4[1],aAutoAO4[2],3)
			EndIf 
			
		Endif
		
	END TRANSACTION
	
	lRet := .T.
Endif

Return (lRet)
                                         

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Funcao    �Tk061SLA      �Autor  �Vendas CRM          � Data �  09/07/08   ���
�����������������������������������������������������������������������������͹��
���Desc.     � Inicia um novo SLA                                             ���
�����������������������������������������������������������������������������͹��
���Retorno   �Array                                                           ���
�����������������������������������������������������������������������������͹��
���Parametros�ExpC1: Codigo do Servico de SLA                                 ���
���          �                                                                ���
�����������������������������������������������������������������������������͹��
���Uso       � Lista de Contatos                                              ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Function Tk061SLA(codService)
Local oSLAService	:= SLAService():New()	//Objeto SLAService
Local cCodRespons	:= RetCodUsr()			//Primeiro usuario responsavel pelo SLA 
Local aSLARegister	:= {}					//Array de retorno com dados do SLA

	If oSLAService:load( codService )
		If oSLAService:find()
			//���������������������������������������������Ŀ
			//� Cria um novo registro para o SLA encontrado �
			//�����������������������������������������������
			If oSLAService:start(cCodRespons)
				//Salva o registro de SLA (SK5)
				oSLAService:save()
				ConOut("1 - Criou novo reg. SLA: " + oSLAService:getRegisterID())
			Else
				ConOut("1 - Nao foi possivel iniciar o registro de SLA")
			EndIf
		EndIf
	Else
		ConOut("1 - Nao foi possivel carregar o Servico de SLA: " + codService )		
	EndIf

	If !Empty(oSLAService:getRegisterID())
		aAdd(aSLARegister, oSLAService:getRegisterID())
		aAdd(aSLARegister, oSLAService:getDateToExpire())
		aAdd(aSLARegister, oSLAService:getSeverity())
	EndIf	

Return aSLARegister

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Funcao    �Tk061SLA      �Autor  �Vendas CRM          � Data �  09/07/08   ���
�����������������������������������������������������������������������������͹��
���Desc.     � Finaliza o SLA                                                 ���
�����������������������������������������������������������������������������͹��
���Retorno   �Logico                                                          ���
�����������������������������������������������������������������������������͹��
���Parametros�ExpC1: Codigo do Registro de SLA                                ���
���          �                                                                ���
�����������������������������������������������������������������������������͹��
���Uso       � Lista de Contatos                                              ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Function Tk061FimSLA(codRegSLA)
Local lRet := .F.
Local oSLAService	:= SLAService():New()	//Objeto SLAService

If oSLAService:finish( codRegSLA )
	oSLAService:save()
	ConOut("1 - Finalizou o SLA : " +  codRegSLA)	
EndIf

Return lRet    



