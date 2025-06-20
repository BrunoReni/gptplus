#Include "Protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TmsA160  � Autor �Rodrigo de A Sartorio  � Data �01.08.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Movimento de Motoristas                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TmsA160()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TmsA160()
	TMSA430("DTO")
Return NIL
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA160DTO� Autor � Alex Egydio           � Data �09.03.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta entrada de motoristas ou motoristas conforme      ���
���          � parametro MV_CONTVEI. Acionado na consulta SXB( DTO )      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TmsA160DTO()
Local aAreaDTQ := DTQ->( GetArea() )
Local bRetorno := { || Iif(GetMV('MV_CONTVEI',,.T.),TMSConsDTO(),Conpad1(,,,'DA4',,,.F.)) }

//-- Quando a Viagem for planejada, habilita a consulta pelo Cadastro de Veiculos.
If Alltrim( FunName() ) == "TMSA240" //-- Complemento de Viagem.
	DTQ->( dbSetOrder( 2 ) )
	If DTQ->( MsSeek( xFilial("DTQ") + M->DTR_FILORI + M->DTR_VIAGEM ) ) .And. DTQ->DTQ_TIPVIA == StrZero( 3, Len( DTQ->DTQ_TIPVIA ) ) //-- Viagem Planejada.
		bRetorno := { || Conpad1(,,,'DA4',,,.F.) }
	EndIf
	RestArea( aAreaDTQ )

ElseIf Left( FunName(), 7 ) $ "TMSA140|TMSA141|TMSA143|TMSA144"
	If M->DTQ_TIPVIA == StrZero( 3, Len( DTQ->DTQ_TIPVIA ) ) //-- Viagem Planejada.
		bRetorno := { || Conpad1(,,,'DA4',,,.F.) }
	EndIf
EndIf

Return( Eval( bRetorno ) )