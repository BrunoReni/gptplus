#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA320M.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEA320M � Autor � Leandro Drumond       � Data � 12/09/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro e Manutencao de Definicao de Tabelas              ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Gpea320M()

Local aArea			:= GetArea()
Local aAreaRCC		:= RCC->( GetArea() )
Local lCargaRCC		:= cPaisLoc $ "BRA|RUS"

Private lImpTabela	:= .F.

Begin Sequence 

	// Gerar as formulas padroes atraves do programa GpexINI.PRX //
	If ( lImpTabela := MsgNoYes(	OemToAnsi(	STR0002 + ;	//"O Sistema ir� atualizar seu ambiente com as informa��es atualizadas no reposit�rio."
					 							CRLF	+ ;
												STR0003 + ;	//"Fa�a um Backup (RCC) antes de iniciar o Processo de Atualiza��o."
												CRLF	+ ;
												CRLF	+ ;
												STR0004   ;	//"Confirma a Atualizacao das informa��es das tabelas ?"
					   					 	 ),;
				 				OemToAnsi( STR0001 ) ;	//"Aten��o"
							);
		)

		MsAguarde( { || Gpea320MDel() } )
		lCargaRCC := .T.

	EndIf
	
	//-- Chamada ao programa de Cadastro de Roteiros
	Gpea320(lCargaRCC)
	
End Sequence

/*/
������������������������������������������������������������������������Ŀ
� Restaura os Dados de Entrada 											 �
��������������������������������������������������������������������������/*/
RestArea( aAreaRCC )
RestArea( aArea )

Return( NIL )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gpea320MDel  �Autor�Leandro Drumond       � Data �12/09/2012�
�����������������������������������������������������������������������Ĵ
�Descri��o �Deletar as informacoes das tabelas                          �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �Gpea320MDel()											    �
�����������������������������������������������������������������������Ĵ
�Parametros�NIL															�
�����������������������������������������������������������������������Ĵ
�Uso       �GPEA320M()	                                                �
�������������������������������������������������������������������������*/
Static Function Gpea320MDel()

RCC->( DbGoTop() )
While RCC->( !Eof() )
	If Substr( RCC->( RCC_CODIGO ),1,1) != "U"
		If RCC->( RecLock( "RCC" , .F. , .F. ) )
			RCC->( dbDelete() )
			RCC->( MsUnLock() )
		EndIf
	EndIf
	RCC->( DbSkip() )
EndDo

Return( NIL )
