#INCLUDE "AE_CANCELA.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AE_CANCELA�Autor  �Itamar	   		  � Data �  13/06/05      ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para cancelamento das viagens na opcao de solicitacao���
�������������������������������������������������������������������������͹��
���Uso       �CDV - Controle de Despesas de viagens						  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                                        
Template Function Cancela(sRotina) 
Local cMens, cMotivo, _aDestinatarios := {}, aArea:=GetArea()
//sRotina --> Se for "S" indica que foi solicitado o cancelamento atraves da rotina de Solicitacao de Viagens
//sRotina --> Se for "D" indica que foi solicitado o cancelamento atraves da rotina Depto de Viagens

ChkTemplate("CDV")
	If sRotina = "S"
 		//Cancelamento atraves da rotina de Solicitacao de Viagens
 		If LHP->LHP_FLAG == "K" //Legenda Pink
 			//FNC 00000028861/2009
	 		If ApMsgYesNo(OemToAnsi(STR0001 + CHR(13) + CHR(10) + STR0002)) //"Esta solicita��o j� est� cancelada."###"Deseja visualizar o motivo do cancelamento?"
				T_AE_VisMotCanc(LHP->LHP_CODIGO)
			Endif
 		ElseIf LHP->LHP_FLAG == "D" //Legenda Verde
 			cMens := STR0003 //"Esta mensagem ainda n�o foi enviada para aprova��o. "
 			cMens += STR0004 //"Nesse caso, a solicita��o pode ser exclu�da. Deseja chamar a rotina de exclus�o?"
 			If MsgYesNo(cMens) 
 				T_AE_SV001(3)
 			EndIf
		
		ElseIf LHP->LHP_FLAG == "I" //Legenda Amarela
			MsgInfo(STR0005) //"Esta solicita��o n�o poder� ser cancelada at� chegar o retorno da solicita��o de aprova��o."
		
		ElseIf LHP->LHP_FLAG == "A" //Legenda Azul - Aprovado
			cMotivo := T_CancelaSolicitacao()
    	
			AADD(_aDestinatarios, GetMv('MV_USVIAGE')) //e-mail do Responsavel do Depto. de Viagens
                    
			//Selecionar e-mail do solicitante, aprovador 1
 			DbSelectArea("LHT")
  			LHT->(DbSetOrder(1))
			//Solicitante
			LHT->(DbSeek(xFilial("LHT") + LHP->LHP_FUNC))
			AADD(_aDestinatarios, LHT->LHT_EMAIL)

			//Aprovador 1
			LHT->(DbSeek(xFilial("LHT") + LHP->LHP_SUPIMD))
			AADD(_aDestinatarios, LHT->LHT_EMAIL)
			
			cMens := "<font face='Arial'>" + STR0020 + "<b>" + UPPER(AllTrim(LHP->LHP_NFUNC)) + "</b><BR><BR>" //"A viagem descrita abaixo foi cancelada pelo colaborador "
			cMens += "<b>" + STR0021 + "</b> " + LHP->LHP_SOLPOR + "<BR>" //"Solicitada por:"
			cMens += "<b>" + STR0022 + "</b> " + DTOC(LHP->LHP_SAIDA) + "<BR>" //"Data Prevista de Sa�da:"
			cMens += "<b>" + STR0023 + "</b> " + DTOC(LHP->LHP_CHEGAD) + "<BR>" //"Data Prevista de Chegada:"
			cMens += "<b>" + STR0024 + "</b> " + LHP->LHP_LOCAL + "<BR>" //"Local da Viagem:"
			cMens += "<b>" + STR0025 + "</b> " + cMotivo + "<BR><BR>" //"Motivo do Cancelamento:"
			cMens += "<font face='Arial' color='#008080'><b>" + STR0037 + "</b></font>" //"Esse e-mail foi gerado automaticamente pelo sistema de controle de viagens. N�o deve ser respondido."
		
			T_EnviaEmail(_aDestinatarios, STR0013, cMens)  //"Cancelamento de Viagem"
			RestArea(aArea)

 		ElseIf LHP->LHP_FLAG == "P" //Legenda Preta - Reprovado
 			MsgInfo(STR0014) //"Esta solicita��o foi reprovada e n�o poder� ser cancelada."
 		
 		ElseIf LHP->LHP_FLAG == "M" .Or. LHP->LHP_FLAG == "E"
 		 	//Legenda M->Marrom - Encaminhada pelo Depto de Viagens para o aprovador 2
 		 	//Legenda E->Laranja - Liberada pelo Depto de Viagens para apontamento de despesas
 			cMens := STR0015 //"Esta solicita��o foi encaminhada para o Depto. de viagens e s� poder� ser "
 			cMens += STR0016 //"cancelada por eles. Deseja enviar uma mensagem de solicita��o de cancelamento "
 			cMens += STR0017 //"para o Depto. de Viagens? "
 			cMens += CRLF + STR0018 //"Obs. Esta mensagem n�o ir� cancelar a solicita��o, apenas "
 			cMens += STR0019 //"alertar� o Depto. de Viagens para sua solicita��o."
 			If MsgYesNo(cMens)
			 	cMotivo := T_MotivoCanc()
			 	If AllTrim(cMotivo) != ""
			 		// Chamar rotina de envio de email...  Criar baseado na rotina AEMailFin
					AADD(_aDestinatarios, GetMv('MV_USVIAGE')) //e-mail do Responsavel do Depto. de Viagens
                    
					//Selecionar e-mail do solicitante, aprovador 1 e 2
               DbSelectArea("LHT")
               LHT->(DbSetOrder(1))
					//Solicitante
               LHT->(DbSeek(xFilial("LHT") + LHP->LHP_FUNC))
					AADD(_aDestinatarios, LHT->LHT_EMAIL)

					LHT->(DbSeek(xFilial("LHT") + LHP->LHP_SUPIMD))
					AADD(_aDestinatarios, LHT->LHT_EMAIL)
					
					LHT->(DbSeek(xFilial("LHT") + LHP->LHP_DGRAR))
					AADD(_aDestinatarios, LHT->LHT_EMAIL)
					
					cMens :="<font face='Arial'>" + STR0027 + "<b>" + UPPER(AllTrim(LHP->LHP_NFUNC)) + "</b>" + ; //"O colaborador "
							STR0028 + "<b>" + STR0029 + "</b>. <BR><BR>" + ; //" solicita que a viagem abaixo descrita seja "###"Cancelada"
							"<b>" + STR0021 + "</b> " + LHP->LHP_SOLPOR + "<BR>" + ; //"Solicitada por:"
							"<b>" + STR0022 + "</b> " + DTOC(LHP->LHP_SAIDA) + "<BR>" + ; //"Data Prevista de Sa�da:"
							"<b>" + STR0023 + "</b> " + DTOC(LHP->LHP_CHEGAD) + "<BR>" + ; //"Data Prevista de Chegada:"
	  						"<b>" + STR0024 + "</b> " + LHP->LHP_LOCAL + "<BR>" + ; //"Local da Viagem:"
							"<b>" + STR0025 + "</b> " + cMotivo + "<BR><BR>" + ; //"Motivo do Cancelamento:"
							"<font face='Arial' color='#CC6600'><b>" + STR0030 + "</b></font>" //"Por favor entrem em contato com o colaborador para tomar as devidas provid�ncias."
				
					T_EnviaEmail(_aDestinatarios, STR0031, cMens)  //"Solicita��o de Cancelamento de Viagem"
					RestArea(aArea)
			 	EndIf
 			EndIf
		
 		ElseIf LHP->LHP_FLAG == "B" //Legenda Branco - Solicita��o avulsa
 			MsgInfo(STR0032) //"Esse processo n�o pode ser cancelado por ser uma presta��o de contas sem solicita��o."
 		
 		ElseIf LHP->LHP_FLAG == "C" .Or. LHP->LHP_FLAG == "Z"
 			//Legenda C-Vermelho - Liberada pela presta��o de contas - A viagem j� ocorreu
 			//Legenda Z-Cinza - Fechamento da solicita��o j� realizado - A viagem j� ocorreu
 			MsgInfo(STR0033) //"A viagem j� ocorreu, sendo assim n�o ser� poss�vel cancel�-la."
 		EndIf

 	ElseIf sRotina = "D"                                         
		//Cancelamento atraves do Depto. de Viagens
 	 		If LHP->LHP_FLAG1 == "K" //Legenda Pink
	 			//FNC 00000028861/2009
		 		If ApMsgYesNo(OemToAnsi(STR0001 + CHR(13) + CHR(10) + STR0002)) //"Esta solicita��o j� est� cancelada."###"Deseja visualizar o motivo do cancelamento?"
					T_AE_VisMotCanc(LHP->LHP_CODIGO)
				Endif
			ElseIf LHP->LHP_FLAG1 == "M" //Legenda Marrom
				If LHP->LHP_FLAG == "I" //Legenda Amarela
					MsgInfo(STR0005) //"Esta solicita��o n�o poder� ser cancelada at� chegar o retorno da solicita��o de aprova��o."
				ElseIf LHP->LHP_FLAG == "D" //Legenda Verde
					cMens := STR0003 //"Esta mensagem ainda n�o foi enviada para aprova��o. "
 					cMens += STR0004 //"Nesse caso, a solicita��o pode ser exclu�da. Deseja chamar a rotina de exclus�o?"
		 			If MsgYesNo(cMens) 
		 				T_AE_SV001(3)
		 			EndIf  
		 		ElseIf LHP->LHP_FLAG == "P" //Legenda Preta
					MsgInfo(STR0034) //"Esta solicita��o foi reprovada. N�o poder� ser cancelada."
		 		EndIf

		 	ElseIf LHP->LHP_FLAG1 == "D" //Legenda Verde
		 		cMotivo := T_CancelaSolicitacao()

				If AllTrim(cMotivo) != ""
					AADD(_aDestinatarios, GetMv('MV_USVIAGE')) //e-mail do Responsavel do Depto. de Viagens
	                    
					//Selecionar e-mail do solicitante, aprovador 1
		  			DbSelectArea("LHT")
		  			LHT->(DbSetOrder(1))
					//Solicitante
					LHT->(DbSeek(xFilial("LHT") + LHP->LHP_FUNC))
					AADD(_aDestinatarios, LHT->LHT_EMAIL)
		
					//Aprovador 1
					LHT->(DbSeek(xFilial("LHT") + LHP->LHP_SUPIMD))
					AADD(_aDestinatarios, LHT->LHT_EMAIL)
					
					cMens := "<font face='Arial'>" + STR0035 + "<b>" + STR0036 + "</b><BR><BR>" //"A viagem descrita abaixo foi cancelada pelo "###"Depto de Viagens."
					cMens += "<b>" + STR0021 + "</b> " + LHP->LHP_SOLPOR + "<BR>" //"Solicitada por:"
					cMens += "<b>" + STR0022 + "</b> " + DTOC(LHP->LHP_SAIDA) + "<BR>" //"Data Prevista de Sa�da:"
					cMens += "<b>" + STR0023 + "</b> " + DTOC(LHP->LHP_CHEGAD) + "<BR>" //"Data Prevista de Chegada:"
					cMens += "<b>" + STR0024 + "</b> " + LHP->LHP_LOCAL + "<BR>" //"Local da Viagem:"
					cMens += "<b>" + STR0025 + "</b> " + cMotivo + "<BR><BR>" //"Motivo do Cancelamento:"
					cMens += "<font face='Arial' color='#008080'><b>" + STR0037 + "</b></font>" //"Esse e-mail foi gerado automaticamente pelo sistema de controle de viagens. N�o deve ser respondido."
				
					T_EnviaEmail(_aDestinatarios, STR0013, cMens)  //"Cancelamento de Viagem"
				EndIf
				
				RestArea(aArea)

		 	ElseIf LHP->LHP_FLAG1 == "I" //Legenda Amarela
		 		MsgInfo(STR0005) //"Esta solicita��o n�o poder� ser cancelada at� chegar o retorno da solicita��o de aprova��o."
		 		
		 	ElseIf LHP->LHP_FLAG1 == "A" //Legenda Azul
				cMotivo := T_CancelaSolicitacao()
				If !Empty(cMotivo)
					AADD(_aDestinatarios, GetMv('MV_USVIAGE')) //e-mail do Responsavel do Depto. de Viagens
    	                
					//Selecionar e-mail do solicitante, aprovador 1
					DbSelectArea("LHT")
					LHT->(DbSetOrder(1))
					//Solicitante
					LHT->(DbSeek(xFilial("LHT") + LHP->LHP_FUNC))
					AADD(_aDestinatarios, LHT->LHT_EMAIL)
	        	
					//Aprovador 1
					LHT->(DbSeek(xFilial("LHT") + LHP->LHP_SUPIMD))
					AADD(_aDestinatarios, LHT->LHT_EMAIL)
					
					//Aprovador 2
					LHT->(DbSeek(xFilial("LHT") + LHP->LHP_DGRAR))
					AADD(_aDestinatarios, LHT->LHT_EMAIL)
										
					cMens := "<font face='Arial'>" + STR0038 + "</b><BR><BR>" //"A viagem descrita abaixo foi cancelada pelo <b>Depto de Viagens."
					cMens += "<b>" + STR0021 + "</b> " + LHP->LHP_SOLPOR + "<BR>" //"Solicitada por:"
					cMens += "<b>" + STR0022 + "</b> " + DTOC(LHP->LHP_SAIDA) + "<BR>" //"Data Prevista de Sa�da:"
					cMens += "<b>" + STR0023 + "</b> " + DTOC(LHP->LHP_CHEGAD) + "<BR>" //"Data Prevista de Chegada:"
					cMens += "<b>" + STR0024 + "</b> " + LHP->LHP_LOCAL + "<BR>" //"Local da Viagem:"
					cMens += "<b>" + STR0025 + "</b> " + cMotivo + "<BR><BR>" //"Motivo do Cancelamento:"
					cMens += "<font face='Arial' color='#008080'><b>" + STR0037 + "</b></font>" //"Esse e-mail foi gerado automaticamente pelo sistema de controle de viagens. N�o deve ser respondido."
			    	
					T_EnviaEmail(_aDestinatarios, STR0013, cMens)  //"Cancelamento de Viagem"
					RestArea(aArea)
				Endif

			ElseIf LHP->LHP_FLAG1 == "P" //Legenda Preta
				MsgInfo(STR0014) //"Esta solicita��o foi reprovada e n�o poder� ser cancelada."
			
			ElseIf LHP->LHP_FLAG1 == "E" //Legenda Laranja
				dDataServer := msDate() //essa eh a data do server... 
				If dDataServer >= LHP->LHP_SAIDA
					cMens := STR0039 //"N�o ser� poss�vel cancelar a viagem, pois a mesma j� est� em andamento. "
					cMens += STR0040 //"Caso a viagem n�o seja realizada, realize o acerto informando uma despesa do tipo 'Estorno' "
					cMens += STR0046 //"informando o mesmo valor gerado como adiantamento."
					
					MsgInfo(cMens)
				Else
					cMens := STR0041 //"Esta solicita��o j� foi enviada para a Ag�ncia de Viagens e para o setor Financeiro! "
					cMens += STR0042 //"Antes de cancel�-la � conveniente entrar em contato com a ag�ncia de viagens e com o setor "
					cMens += STR0043 //"financeiro para tomar as devidas provid�ncias. O sistema ir� apenas trocar o status para "
					cMens += STR0044 //"Cancelado e avisar os envolvidos atrav�s de e-mail. Sendo assim, o ajuste financeiro e o "
					cMens += STR0045 + CHR(13) + CHR(13) //"cancelamento de hot�is, traslados, etc. deve ser feito manualmente. "
					cMens += STR0006 //"Confirma o cancelamento?"
					                                                                                                    
					If MsgYesNo(cMens)
						// Solicitar motivo, cancelar e enviar email
						cMotivo := T_CancelaSolicitacao()

						AADD(_aDestinatarios, GetMv('MV_WFAGTUR')) //e-mail da Agencia de Viagens
						AADD(_aDestinatarios, GetMv('MV_USVIAGE')) //e-mail do Responsavel do Depto. de Viagens
                    	
						//Selecionar e-mail do solicitante, aprovador 1
						DbSelectArea("LHT")
						LHT->(DbSetOrder(1))
						//Solicitante
						LHT->(DbSeek(xFilial("LHT") + LHP->LHP_FUNC))
						AADD(_aDestinatarios, LHT->LHT_EMAIL)
			
						//Aprovador 1
						LHT->(DbSeek(xFilial("LHT") + LHP->LHP_SUPIMD))
						AADD(_aDestinatarios, LHT->LHT_EMAIL)
						
						//Aprovador 2
						LHT->(DbSeek(xFilial("LHT") + LHP->LHP_DGRAR))
						AADD(_aDestinatarios, LHT->LHT_EMAIL)
											
						cMens := "<font face='Arial'>" + STR0035 + "<b>" + STR0036 + "</b><BR><BR>" //"A viagem descrita abaixo foi cancelada pelo "###"Depto de Viagens."
						cMens += "<b>" + STR0021 + "</b> " + LHP->LHP_SOLPOR + "<BR>" //"Solicitada por:"
						cMens += "<b>" + STR0022 + "</b> " + DTOC(LHP->LHP_SAIDA) + "<BR>" //"Data Prevista de Sa�da:"
						cMens += "<b>" + STR0023 + "</b> " + DTOC(LHP->LHP_CHEGAD) + "<BR>" //"Data Prevista de Chegada:"
						cMens += "<b>" + STR0024 + "</b> " + LHP->LHP_LOCAL + "<BR>" //"Local da Viagem:"
						cMens += "<b>" + STR0025 + "</b> " + cMotivo + "<BR><BR>" //"Motivo do Cancelamento:"
						cMens += "<font face='Arial' color='#CC6600'><b>" + STR0007 + "<BR>" //"Esta a��o n�o cancela passagens a�reas, rodovi�rias, reservas em hot�is, etc. Apenas avisa a ag�ncia de viagens quanto a solicita��o de cancelamento. "
						cMens += STR0008 + "</b></font>" //"O status da solicita��o ser� 'Cancelado', por�m, os ajustes necess�rios com a Ag�ncia de Viagens e o setor Financeiro dever�o ser realizados junto aos mesmos."

						T_EnviaEmail(_aDestinatarios, STR0013, cMens)  //"Cancelamento de Viagem"
						RestArea(aArea)
                    EndIf
    			Endif

			ElseIf LHP->LHP_FLAG1 == "B" //Legenda Branco
//				MsgInfo(STR0009) //"A presta��o de contas sem solicita��o deve ser cancelada atrav�s da rotina de 'Presta��o de Contas'."
				cMotivo := T_CancelaSolicitacao()                                                          
			ElseIf LHP->LHP_FLAG1 == "C" .Or. LHP->LHP_FLAG1 == "Z" //Legenda Vermelho / Cinza
				MsgInfo(STR0033) //"A viagem j� ocorreu, sendo assim n�o ser� poss�vel cancel�-la."

		 	EndIf
 	 	EndIf
Return

/*****************************************************************************************************************/
Template Function AlteraStatusCanc(Processo, Flag1, Flag2)
Local aArea		:= GetArea()
Local aCancela	:= {}
Local cSE2Key	:= ''
Local lRet		:= .T.

RecLock('LHP', .F.)
LHP->LHP_Codigo:= Processo
LHP->LHP_FLAG  := Flag1
LHP->LHP_FLAG1 := Flag2
MsUnLock('LHP')

cSE2Key := LHP->LHP_DOCUME

If !Empty( cSE2Key )
	DbSelectArea('SE2')
	SE2->( DbSetOrder(1) )
	If SE2->( DbSeek(cSE2Key) )
		If SE2->E2_SALDO == SE2->E2_VALOR .And. Empty(SE2->E2_BAIXA) // Se o Titulo possui o E2_Saldo igual ao E2_Valor e o campo data de Baixa estiver vazio o titulo n�o possui baixas 
			lRet	:= T_AE_EXCSE2( .F., SE2->(RECNO()) )
		Else
			lRet 	:= T_AE_EXCSE2( .T., SE2->(RECNO()) )
		EndIf		
	EndIf 
EndIf

RestArea( aArea )
Return(lRet)

/*****************************************************************************************************************/
Template Function GravaLHQ(Processo)
Local aArea := GetArea()

//Gravar no LHQ (Tabela de Despesas - Para manter balanceamento dos c�digos)
DbSelectArea('LHQ')
DbSetOrder(1)
If LHQ->(DbSeek(xFilial('LHQ') + Processo))
 	RecLock('LHQ',.F.)
	LHQ->LHQ_Flag	:= 'K'
Else
	RecLock('LHQ',.T.)
	LHQ->LHQ_Filial := xFilial('LHQ')
	LHQ->LHQ_Codigo := Processo
	LHQ->LHQ_EmpCli := LHP->LHP_EmpCLi
	LHQ->LHQ_Func	:= LHP->LHP_Func
	LHQ->LHQ_SupImd := LHP->LHP_SupImd
	LHQ->LHQ_Saida	:= LHP->LHP_Saida
	LHQ->LHQ_HoraId := LHP->LHP_HoraId
	LHQ->LHQ_Chegad := LHP->LHP_Chegad
	LHQ->LHQ_HoraVt := LHP->LHP_HoraVt
	LHQ->LHQ_CC		:= LHP->LHP_CC
	LHQ->LHQ_FatCli := LHP->LHP_FatCLi
	LHQ->LHQ_FatFra := LHP->LHP_FatFra
	LHQ->LHQ_FatMic := LHP->LHP_FatMic
	LHQ->LHQ_Flag	:= 'K'
	LHQ->LHQ_DGRar	:= LHP->LHP_DGRar
	LHQ->LHQ_SolPor := LHP->LHP_SolPor
EndIf
	
MsUnLock('LHQ')

RestArea(aArea)

Return .T.

/*****************************************************************************************************************/
Template Function GravaMotivoCanc(Processo, Motivo)

RecLock('LJH',.T.)
LJH->LJH_FILIAL		:= xFilial('LJH')
LJH->LJH_CODSOL		:= Processo
LJH->LJH_MOTIVO		:= Motivo
MsUnLock('LJH')

Return .T.

/*****************************************************************************************************************/
Template Function DeletaLHQ(Processo)
Local aArea := GetArea()
	
DbSelectArea('LHQ')
DbSetOrder(1)
If MsSeek(xFilial('LHQ') + Processo)
	RecLock('LHQ', .F.)
		LHQ->(DbDelete())
	MsUnLock()
EndIf

RestArea(aArea)
Return .T.                       

/*****************************************************************************************************************/
Template Function DeletaLJH(Processo)
Local aArea := GetArea()
	
DbSelectArea('LJH')
DbSetOrder(1)
If MsSeek(xFilial('LJH') + Processo)
	RecLock('LJH', .F.)
	LJH->(DbDelete())
	MsUnLock()
EndIf

RestArea(aArea)

Return

/*****************************************************************************************************************/
Template Function CancelaSolicitacao()
Local aArea := GetArea(), cMotivo, _cProcesso := Space(06)

cMotivo := T_MotivoCanc()
If AllTrim(cMotivo) != ""
	//Gravar na tabela de Motivos de Cancelamento
	#IFDEF TOP
		BEGIN TRANSACTION 
	#ENDIF
		
	If AllTrim(LHP->LHP_CODIGO) = ""
		_cProcesso := GetSxEnum('LHP','LHP_CODIGO')
	Else
		_cProcesso := LHP->LHP_CODIGO
	Endif

	If Empty(_cProcesso)
		MsgInfo(STR0010, STR0011) //'N�o foi poss�vel obter um c�digo para a solicita��o. Tente novamente! Se o problema persistir, por favor, solicite atendimento Microsiga.'###'Dados Incompletos'
		Return(cMotivo)
	EndIf
	If !T_GravaLHQ(_cProcesso)
		MsgInfo(STR0012, STR0011) //'Ocorreu algum problema na altera��o do status da solicita��o. Por favor, solicite atendimento Microsiga.'###'Dados Incompletos'
		#IFDEF TOP
			DisarmTransaction()
		#ELSE
			T_DeletaLHQ(_cProcesso) //Delete o registro criado na tabela LHQ
		#ENDIF
		Return(cMotivo)
	EndIf
		
	If !T_AlteraStatusCanc(_cProcesso, 'K', 'K') //Altera o Status da Solicita��o para Cancelado na tabela LHP (FLAG = "K")
		MsgInfo(STR0012, STR0011) //'Ocorreu algum problema na altera��o do status da solicita��o. Por favor, solicite atendimento Microsiga.'###'Dados Incompletos'
		#IFDEF TOP
			DisarmTransaction()
		#ELSE
		     T_DeletaLHQ(_cProcesso) //Delete o registro criado na tabela LHQ
		     T_AlteraStatusCanc("", 'A', 'D') // Voltar status
		#ENDIF
		Return(cMotivo)
	EndIf    
	
	If !T_GravaMotivoCanc(_cProcesso, cMotivo) //Grava o motivo do cancelamento
		MsgInfo(STR0012, STR0011) //'Ocorreu algum problema na altera��o do status da solicita��o. Por favor, solicite atendimento Microsiga.'###'Dados Incompletos'
		#IFDEF TOP
			DisarmTransaction()
		#ELSE
		     T_DeletaLHQ(_cProcesso) //Delete o registro criado na tabela LHQ
		     T_AlteraStatusCanc("", 'A', 'D') // Voltar status
		     T_DeletaLJH(_cProcesso) //Deleta da Tabela LJH, caso fique sujeira
		#ENDIF
		Return
	EndIf
	
	ConfirmSX8()
	#IFDEF TOP
		END TRANSACTION 
	#ENDIF
EndIf
RestArea(aArea)

Return cMotivo
