#INCLUDE "WSTMSE65.CH"
#INCLUDE "PROTHEUS.CH"
#Include "XMLXFUN.CH"
#INCLUDE "APWEBSRV.CH"

Static lTMSE65Prc  := ExistBlock('TMSE65Prc')

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  �WSTMSE65  � Autor �Vitor Raspa              � Data �10.Jul.06 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � WebService para Recepcionar os eventos de Retorno da         ���
���          � Operadora de Frotas                                          ���
���������������������������������������������������������������������������Ĵ��
���Uso       � SigaTMS - Gestao de Transporte                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function TMSEvents()
Return

WsService TMSEvents Description STR0001; //-- "WebService para recepcionar e tratar os eventos de retorno da Operadora de Frotas"
		NAMESPACE "http://webservices.totvs.com.br/tmsevents.apw"
	WsData ReturnType      As String
	WsData XMLIn           As String
	WsData ReceiveStatus   As Boolean
	
	WsMethod ReceiveEvent Description STR0002 //-- "Recebe e trata os eventos de retorno da Operadora de Frotas"

EndWsService        


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Metodo    �TMSEvents � Autor �Vitor Raspa              � Data �10.Jul.06 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Metodo para tratar os eventos de Retorno da Operadora        ���
���������������������������������������������������������������������������Ĵ��
���Retorno do� ReceiveStatus:                                               ���
���Metodo    �.F. - Falha na Interpretacao do XML de Entrada                ���
���          �.T. - XML de Entrada interpretado com sucesso                 ���
���������������������������������������������������������������������������Ĵ��
���Uso       � SigaTMS - Gestao de Transporte                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
WsMethod ReceiveEvent WsReceive ReturnType, XMLIn WsSend ReceiveStatus WsService TMSEvents
Local aAreaDTY   := DTY->(GetArea())
Local aAreaDTQ   := DTQ->(GetArea())
Local cError     := ''
Local cWarning   := ''
Local aMsgErro   := {}
Local oObjXML    := Nil
Local aPassagens := {}
Local cFilOri    := ''
Local cViagem    := ''
Local cNumCTC    := ''
Local aMovValor 
Local cValor     := ''
Local lRet       := .T.
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )   
Local cCodVei    := ''     
Local cOper      := '0'
Local lDTYX2MODO := FwModeAccess("DTY") == "E"
Local cVsRepom   := SuperGetMV( 'MV_VSREPOM',, '1' )  //-- Versao 2- Contempla nova Legislacao (Encerramento viagem no Posto)
Local aQuitacao  := {}
Local cFilOld    := ""
Local nAux       := 0
Local aDadosDoc  := {}

//��������������������������������������������������������������Ŀ
//� Valores para ::ReturnType   (VERSAO ANTIGA - MV_VSREPOM <> 2)�
//��������������������������������������������������������������Ĵ
//� 01 � Passagem em Postos                                      �
//� 02 � Movimentacao de Valores                                 �
//� 03 � Aviso de Pagamento de Postos                            �
//� 04 � Aviso de Pagamento de Carreteiros                       �
//����������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Valores para ::ReturnType   (VERSAO NOVA - MV_VSREPOM = 2)   �
//��������������������������������������������������������������Ĵ
//� 01 � Movimentacao de Valores                                 �
//� 02 � Passagem em Postos                                      �
//� 03 � Quitacao de Frete                                       �
//� 04 � Aviso de Pagamento de Carreteiros                       �
//� 05 � Aviso de Pagamento de Postos                            �
//� 06 � Roteiro/Percursos                                       �
//� 07 � Postos                                                  �
//����������������������������������������������������������������


//���������������������������������������������������������������Ŀ
//� Tratamento dos Erros:                                         �
//���������������������������������������������������������������Ĵ
//� 000 � XML DE ENTRADA VAZIO OU INVALIDO                        �
//� 001 � ERRO NA INTERPRETACAO DO XML                            �
//� 002 � TIPO DE RETORNO INVALIDO                                �
//� 003 � FORMATO DO XML DE ENTRADA INVALIDO                      �
//� 004 � VIAGEM NAO ENCONTRADA                                   �
//� 005 � POSTO VINCULADO A MENSAGEM DE AVISO PAGTO. NAO EXISTE   �
//� 006 � CONTRATO DE CARRETEIRO PARA A VIAGEM NAO EXISTE         �
//� 007 � CONTRATO NAO INTEGRADO COM A OPERADORA                  �
//�����������������������������������������������������������������

//-- Seta a configuracao de nome de variaveis para 255 caracteres
SetVarNameLen( 255 )

If Empty(::XMLIn)
	AAdd(aMsgErro, {'000', STR0008} ) //-- "XML de entrada vazio ou nao enviado!"
	::ReceiveStatus := .F.
Else
	//�������������������������������������������������Ŀ
	//� VERSAO ANTIGA - MV_VSREPOM <> 2                 | 
	//���������������������������������������������������
	If cVsRepom <> '2'

	//�������������������������������������������������Ŀ
	//� O CONTEUDO DA VARIAVEL ::ReturnType EH INVALIDO �
	//���������������������������������������������������
	If !(::ReturnType $ '01|02|03|04')
		AAdd(aMsgErro, {'002', STR0004}) //-- "O tipo de retorno nao e valido!"
		::ReceiveStatus := .F.
		
		//-- Grava o XML em disco
		If lTMSXML
			TMSLogXML( ::XMLIn, 'ReceiveError-002.XML' )
		EndIf
		
	Else
		::ReceiveStatus	:= .T.
		If ::ReturnType == '01'
			//���������������������Ŀ
			//� Passagens em Postos �
			//�����������������������
			
			//-- Grava o XML em disco
			If lTMSXML
				TMSLogXML( ::XMLIn, 'ReceivePassagensPostos.XML' )
			EndIf
			
			If !('<PASSAGEM>' $ Upper(::XMLIn))
				AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
				::ReceiveStatus := .F.
			Else
				//-- Gera o Objeto XML conforme XML de envio:
				::XMLIn := NoAcento( OemToAnsi(::XMLIn) ) //-- Remove os Acentos
				oObjXML := XMLParser( ::XMLIn, '_', @cError, @cWarning )
				If !Empty(cError) .Or. !Empty(cWarning)
					If !Empty(cError)
						AAdd(aMsgErro, {'001', STR0003 + " - " + cError}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
					ElseIf !Empty(cWarning)
						AAdd(aMsgErro, {'001', STR0003 + " - " + cWarning}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
					EndIf
					::ReceiveStatus := .F.
				Else	
					If XMLChildCount( oObjXML:_Passagem:_Integracao ) <> 21
						AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
						::ReceiveStatus := .F.
					Else				
						ConOut('')
						ConOut(Repl('-',80))
						ConOut('Iniciando Processo - Passagem em Postos')

						::ReceiveStatus := .T.

						cFilOri := Left( oObjXML:_Passagem:_Integracao:_Codigo_Processo_Cliente:Text, 2 )
						cViagem := SubStr( oObjXML:_Passagem:_Integracao:_Codigo_Processo_Cliente:Text, 3, 6 )
		
						DTQ->(DbSetOrder(2))
						If !DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem))
							AAdd(aMsgErro, {'004', STR0006 + ' - ' + cFilori + '/' + cViagem}) //-- "Viagem nao encontrada!"
							::ReceiveStatus := .F.
						Else
							AAdd( aPassagens, {	oObjXML:_Passagem:_Integracao:_Codigo_Processo_Cliente:Text,;		//-- Processo de Transporte
												oObjXML:_Passagem:_Integracao:_Data:Text,;							//-- Data Prevista da Passagem
												oObjXML:_Passagem:_Integracao:_Hora:Text,;							//-- Hora Prevista da Passagem
												{	oObjXML:_Passagem:_Integracao:_CNPJ_Posto:Text,;				//-- CNPJ do Posto
													oObjXML:_Passagem:_Integracao:_Razao_Posto:Text,;				//-- Razao Social
													oObjXML:_Passagem:_Integracao:_Endereco:Text,;					//-- Endereco
													oObjXML:_Passagem:_Integracao:_Cidade:Text,;					//-- Cidade
													oObjXML:_Passagem:_Integracao:_Estado:Text,;					//-- Estado
													'' },;															//-- Telefone
												'',;																//-- Valor do Diesel
												oObjXML:_Passagem:_Integracao:_Data:Text,;							//-- Data Real da Passagem
												oObjXML:_Passagem:_Integracao:_Hora:Text,;							//-- Hora Real da Passagem
												oObjXML:_Passagem:_Integracao:_Valor_Consumo:Text,;					//-- Valor do Consumo
												oObjXML:_Passagem:_Integracao:_Valor_Saque:Text,;					//-- Valor do Saque
												oObjXML:_Passagem:_Integracao:_Data_Pagamento_Consumo:Text,;		//-- Data Prevista de pagamento do Consumo
												oObjXML:_Passagem:_Integracao:_Data_Pagamento_Saque:Text,;			//-- Data Prevista de pagamento do Saque
												oObjXML:_Passagem:_Integracao:_Codigo_Documento_Passagem:Text,;		//-- Documento vinculado a passagem
												oObjXML:_Passagem:_Integracao:_Indice_Lancamento:Text,;				//-- Ordem da Passagem 
												cOper } )															//-- Operacao (0-Baixa da Passagem, 1-Estorno da Baixa, 2-Nova Passagem em Aberto

							//�������������������Ŀ
							//�ATUALIZA A PASSAGEM�
							//���������������������
							ConOut('Efetivando a Passagem')
							TMSPassag( '01', cFilOri, cViagem, aPassagens )
							ConOut('Processo Ok!')
							ConOut(Repl('-',80))
							ConOut('')
                        EndIf
		            EndIf
		        EndIf
		    EndIf
		            
		ElseIf ::ReturnType == '02'
			//�������������������������Ŀ
			//� Movimentacao de Valores �
			//���������������������������

			//-- Grava o XML em disco
			If lTMSXML
				TMSLogXML( ::XMLIn, 'ReceiveMovimentacaoValores.XML' )
			EndIf

			If !('<MOVIMENTACAO_VALORES>' $ Upper(::XMLIn))
				AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
				::ReceiveStatus := .F.
			Else
				//-- Gera o Objeto XML conforme XML de envio:
				::XMLIn := NoAcento( OemToAnsi(::XMLIn) ) //-- Remove os Acentos
				oObjXML := XMLParser( ::XMLIn, '_', @cError, @cWarning )
				If !Empty(cError) .Or. !Empty(cWarning)
					If !Empty(cError)
						AAdd(aMsgErro, {'001', STR0003 + " - " + cError}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
					ElseIf !Empty(cWarning)
						AAdd(aMsgErro, {'001', STR0003 + " - " + cWarning}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
					EndIf
					::ReceiveStatus := .F.
				Else	
					If XMLChildCount( oObjXML:_Movimentacao_Valores:_Integracao ) <> 14
						AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
						::ReceiveStatus := .F.
					Else				
						ConOut('')
						ConOut(Repl('-',80))
						ConOut('Iniciando Processo - Movimentacao de Valores')

						::ReceiveStatus := .T.

						cFilOri := Left( oObjXML:_Movimentacao_Valores:_Integracao:_Codigo_Processo_Cliente:Text, 2 )
						cViagem := SubStr( oObjXML:_Movimentacao_Valores:_Integracao:_Codigo_Processo_Cliente:Text, 3, 6 )
		
						DTQ->(DbSetOrder(2))
						If !DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem))
							AAdd(aMsgErro, {'004', STR0006 + ' - ' + cFilori + '/' + cViagem}) //-- "Viagem nao encontrada!"
							::ReceiveStatus := .F.
						Else
							DTY->(DbSetOrder(2)) //-- DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC
							If !DTY->(MsSeek(Iif(lDTYX2MODO,cFilOri,xFilial('DTY')) + cFilOri + cViagem))
								AAdd(aMsgErro, {'006', STR0007  } ) //-- "Contrato de carreteiro para a viagem nao existe"
								::ReceiveStatus := .F.
							Else
								cNumCTC := DTY->DTY_NUMCTC			
								cCodVei := DTY->DTY_CODVEI
								If Val(oObjXML:_Movimentacao_Valores:_Integracao:_Valor:Text) < 0
									cValor := Str(Val(oObjXML:_Movimentacao_Valores:_Integracao:_Valor:Text) * ( - 1))
								Else
									cValor := oObjXML:_Movimentacao_Valores:_Integracao:_Valor:Text
								EndIf

									AAdd(aMovValor, {	oObjXML:_Movimentacao_Valores:_Integracao:_Movimentacoes:_Movimentacao})
													/*	_Codigo_Contrato_Repom:Text,;
														oObjXML:_Movimentacao_Valores:_Integracao:_Codigo_Processo_Cliente:Text,;
														oObjXML:_Movimentacao_Valores:_Integracao:_Codigo_Movimento:Text,;
														cValor,;
														oObjXML:_Movimentacao_Valores:_Integracao:_Operacao:Text} )  */

								//����������������������Ŀ
								//�TRATA AS MOVIMENTACOES�
								//������������������������
								ConOut('Efetivando o Movimento')
								TMSMovVal( '01', cFilOri, cViagem, aMovValor, 3, cCodVei )
								ConOut('Processo Ok!')
								ConOut(Repl('-',80))
								ConOut('')
			                EndIf
		                EndIf
		            EndIf
			    EndIf
			EndIf

		ElseIf ::ReturnType == '03'
			//������������������������������Ŀ
			//� Aviso de Pagamento de Postos �
			//��������������������������������
			//-- Grava o XML em disco
			If lTMSXML
				TMSLogXML( ::XMLIn, 'ReceiveAvisoPagamentoPostos.XML' )
			EndIf


			If !('<AVISO_PAGAMENTO_POSTOS>' $ Upper(::XMLIn))
				AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
				::ReceiveStatus := .F.
			Else
				//-- Gera o Objeto XML conforme XML de envio:
				::XMLIn := NoAcento( OemToAnsi(::XMLIn) ) //-- Remove os Acentos
				oObjXML := XMLParser( ::XMLIn, '_', @cError, @cWarning )
				If !Empty(cError) .Or. !Empty(cWarning)
					If !Empty(cError)
						AAdd(aMsgErro, {'001', STR0003 + " - " + cError}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
					ElseIf !Empty(cWarning)
						AAdd(aMsgErro, {'001', STR0003 + " - " + cWarning}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
					EndIf
					::ReceiveStatus := .F.
				Else	
					If XMLChildCount( oObjXML:_Aviso_Pagamento_Postos:_Integracao ) <> 7
						AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
						::ReceiveStatus := .F.
					Else				
						ConOut('')
						ConOut(Repl('-',80))
						ConOut('Iniciando Processo - Aviso de Pagamento de Postos')

						::ReceiveStatus := .T.
						
						//-- Obtem o Fornecedor referente ao aviso de pagamento:
						SA2->(DbSetOrder(3))
						If !SA2->(MsSeek(xFilial('SA2') + AllTrim(oObjXML:_Aviso_Pagamento_Postos:_Integracao:_CNPJ_Posto:Text)))
							AAdd(aMsgErro, {'005',STR0009}) //-- "Posto relacionado a mensagem de Aviso de Pagamento de Postos nao encontrado na base de dados!"
							::ReceiveStatus := .F.
						Else
							ConOut('Efetivando o Aviso de Pagamento de Postos')
							RecLock('DEQ',.T.)
							DEQ->DEQ_FILIAL := xFilial('DEQ')
							DEQ->DEQ_CODFOR := SA2->A2_COD
							DEQ->DEQ_LOJFOR := SA2->A2_LOJA
							DEQ->DEQ_DATPAG := CtoD( oObjXML:_Aviso_Pagamento_Postos:_Integracao:_Data_Pagamento:Text )
							DEQ->DEQ_VALPAG := Val(oObjXML:_Aviso_Pagamento_Postos:_Integracao:_Valor:Text)
							DEQ->DEQ_TIPPAG := oObjXML:_Aviso_Pagamento_Postos:_Integracao:_Tipo_Pagamento:Text
							MsUnLock()
						
							//������������������������Ŀ
							//�GERA LOG DA MOVIMENTACAO�
							//��������������������������
							TMSGerLog( 	'01',;	//-- Codigo da Operadora
										'AV',;	//-- Tipo do Log
										'R',;	//-- Log de 'E'nvio ou 'R'ecebimento
										xFilial('DEQ') + SA2->A2_COD + SA2->A2_LOJA + DtoS( CtoD( oObjXML:_Aviso_Pagamento_Postos:_Integracao:_Data_Pagamento:Text ) ),;	//-- Chave do Registro (Identificador do Registro)
										'DEQ',; //-- Origem do Registro
										'0' )	//-- 0-Inclusao, 1-Exclusao  

							ConOut('Processo Ok!')
							ConOut(Repl('-',80))
							ConOut('')
						EndIf
					EndIf
				EndIf
			EndIf

		ElseIf ::ReturnType == '04'
			//����������������������������������Ŀ
			//� Aviso de Pagamento de Carreteiro �
			//������������������������������������

			//-- Grava o XML em disco
			If lTMSXML
				TMSLogXML( ::XMLIn, 'ReceiveAvisoPagamentoCarreteiro.XML' )
			EndIf
			
			If !('<AVISO_PAGAMENTO_CARRETEIROS>' $ Upper(::XMLIn))
				AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
				::ReceiveStatus := .F.
			Else
				//-- Gera o Objeto XML conforme XML de envio:
				::XMLIn := NoAcento( OemToAnsi(::XMLIn) ) //-- Remove os Acentos
				oObjXML := XMLParser( ::XMLIn, '_', @cError, @cWarning )
				If !Empty(cError) .Or. !Empty(cWarning)
					If !Empty(cError)
						AAdd(aMsgErro, {'001', STR0003 + " - " + cError}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
					ElseIf !Empty(cWarning)
						AAdd(aMsgErro, {'001', STR0003 + " - " + cWarning}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
					EndIf
					::ReceiveStatus := .F.
				Else	
					If XMLChildCount( oObjXML:_Aviso_Pagamento_Carreteiros:_Integracao ) <> 12
						AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
						::ReceiveStatus := .F.
					Else				
						ConOut('')
						ConOut(Repl('-',80))
						ConOut('Iniciando Processo - Aviso de Pagamento de Carreteiros')

						::ReceiveStatus := .T.
						
						cFilOri := Left( oObjXML:_Aviso_Pagamento_Carreteiros:_Integracao:_Codigo_Processo_Sistema_Cliente:Text,2 )
						cViagem := SubStr( oObjXML:_Aviso_Pagamento_Carreteiros:_Integracao:_Codigo_Processo_Sistema_Cliente:Text, 3, 6 )

						DTQ->(DbSetOrder(2))
						If !DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem))
							AAdd(aMsgErro, {'004', STR0006 + ' - ' + cFilori + '/' + cViagem}) //-- "Viagem nao encontrada!"
							::ReceiveStatus := .F.
						Else
							DTY->(DbSetOrder(2)) //-- DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC
							If !DTY->(MsSeek(Iif(lDTYX2MODO,cFilOri,xFilial('DTY')) + cFilOri + cViagem))
								AAdd(aMsgErro, {'006', STR0007  } ) //-- "Contrato de carreteiro para a viagem nao existe"
								::ReceiveStatus := .F.
							Else
								RecLock('DER',.T.)
								DER->DER_FILIAL := xFilial('DER')
								DER->DER_FILORI := cFilOri
								DER->DER_VIAGEM := cViagem
								DER->DER_DATAUT := CtoD( oObjXML:_Aviso_Pagamento_Carreteiros:_Integracao:_Data_Autorizacao:Text )
								DER->DER_DATENV := CtoD( oObjXML:_Aviso_Pagamento_Carreteiros:_Integracao:_Data_Envio_Banco:Text )
								DER->DER_DATPAG := CtoD( oObjXML:_Aviso_Pagamento_Carreteiros:_Integracao:_Data_Pagamento:Text )
								DER->DER_DATCNF := CtoD( oObjXML:_Aviso_Pagamento_Carreteiros:_Integracao:_Data_Confirmacao_Pagamento:Text )
								DER->DER_VALPAG := Val( oObjXML:_Aviso_Pagamento_Carreteiros:_Integracao:_Valor:Text )
								MsUnLock()
								
								//������������������������Ŀ
								//�GERA LOG DA MOVIMENTACAO�
								//��������������������������
								TMSGerLog( 	'01',;	//-- Codigo da Operadora
											'AC',;	//-- Tipo do Log
											'R',;	//-- Log de 'E'nvio ou 'R'ecebimento
											xFilial('DER') + cFilOri + cViagem,;	//-- Chave do Registro (Identificador do Registro)
											'DER',;	//-- Origem do Registro
											'0' )	//-- 0-Inclusao, 1-Exclusao
							EndIf
						EndIf
					EndIf	
                EndIf
            EndIf    
		Else
			AAdd(aMsgErro, {'002', STR0004}) //-- "O tipo de retorno nao e valido!"
			::ReceiveStatus := .F.
			//-- Grava o XML em disco
			If lTMSXML
				TMSLogXML( ::XMLIn, 'ReceiveError-002.XML' )
			EndIf
		EndIf
	EndIf
		Else
		//�������������������������������������������������Ŀ
		//� O CONTEUDO DA VARIAVEL ::ReturnType EH INVALIDO �
		//���������������������������������������������������
		If !(::ReturnType $ '01|02|03|04|05')
			AAdd(aMsgErro, {'002', STR0004}) //-- "O tipo de retorno nao e valido!"
			::ReceiveStatus := .F.
			
			//-- Grava o XML em disco
			If lTMSXML
				TMSLogXML( ::XMLIn, 'ReceiveError-002.XML' )
			EndIf
			
		Else
			::ReceiveStatus	:= .T.
			    
			If ::ReturnType == '01'
				//�������������������������Ŀ
				//� Movimentacao de Valores �
				//���������������������������
	
				//-- Grava o XML em disco
				If lTMSXML
					TMSLogXML( ::XMLIn, 'ReceiveMovimentacaoValores.XML' )
				EndIf
	
				If !('<MOVIMENTACAO_VALORES>' $ Upper(::XMLIn))
					AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
					::ReceiveStatus := .F.
				Else
					//-- Gera o Objeto XML conforme XML de envio:
					::XMLIn := NoAcento( OemToAnsi(::XMLIn) ) //-- Remove os Acentos
					oObjXML := XMLParser( ::XMLIn, '_', @cError, @cWarning )
					If !Empty(cError) .Or. !Empty(cWarning)
						If !Empty(cError)
							AAdd(aMsgErro, {'001', STR0003 + " - " + cError}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
						ElseIf !Empty(cWarning)
							AAdd(aMsgErro, {'001', STR0003 + " - " + cWarning}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
						EndIf
						::ReceiveStatus := .F.
					Else	
						If XMLChildCount( oObjXML:_Movimentacao_Valores:_Integracao ) <= 14
							AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
							::ReceiveStatus := .F.
						Else				
							ConOut('')
							ConOut(Repl('-',80))
							ConOut('Iniciando Processo - Movimentacao de Valores')
	
							::ReceiveStatus := .T.
	
							cFilOri := Left( oObjXML:_Movimentacao_Valores:_Integracao:_Codigo_Processo_Cliente:Text, 2 )
							cViagem := SubStr( oObjXML:_Movimentacao_Valores:_Integracao:_Codigo_Processo_Cliente:Text, 3, 6 )
			
							DTQ->(DbSetOrder(2))
							If !DTQ->(DbSeek(xFilial('DTQ') + cFilOri + cViagem))
								AAdd(aMsgErro, {'004', STR0006 + ' - ' + cFilori + '/' + cViagem}) //-- "Viagem nao encontrada!"
								::ReceiveStatus := .F.
							Else
								DTY->(DbSetOrder(2)) //-- DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC
								If !DTY->(MsSeek(Iif(lDTYX2MODO,cFilOri,xFilial('DTY')) + cFilOri + cViagem))
									AAdd(aMsgErro, {'006', STR0007  } ) //-- "Contrato de carreteiro para a viagem nao existe"
									::ReceiveStatus := .F.
								Else
									cNumCTC := DTY->DTY_NUMCTC			
									cCodVei := DTY->DTY_CODVEI
									If Val(oObjXML:_Movimentacao_Valores:_Integracao:_Valor:Text) < 0
										cValor := Str(Val(oObjXML:_Movimentacao_Valores:_Integracao:_Valor:Text) * ( - 1))
									Else
										cValor := oObjXML:_Movimentacao_Valores:_Integracao:_Valor:Text
									EndIf
	                                 
									AAdd(aMovValor, {	oObjXML:_Movimentacao_Valores:_Integracao:_Codigo_Contrato_Repom:Text,;
														oObjXML:_Movimentacao_Valores:_Integracao:_Codigo_Processo_Cliente:Text,;
														oObjXML:_Movimentacao_Valores:_Integracao:_Codigo_Movimento:Text,;
														cValor,;
														oObjXML:_Movimentacao_Valores:_Integracao:_Operacao:Text} ) 
	
									//����������������������Ŀ
									//�TRATA AS MOVIMENTACOES�
									//������������������������
									ConOut('Efetivando o Movimento')
									//	TMSMovVal( '01', cFilOri, cViagem, aMovValor, 3, cCodVei )
									ConOut('Processo Ok!')
									ConOut(Repl('-',80))
									ConOut('')
				                EndIf
			                EndIf
			            EndIf
				    EndIf
				EndIf
				
			ElseIf ::ReturnType == '02'
				//���������������������Ŀ
				//� Passagens em Postos �
				//�����������������������
				
				//-- Grava o XML em disco
				If lTMSXML
					TMSLogXML( ::XMLIn, 'ReceivePassagensPostos.XML' )
				EndIf
				
				If !('<PASSAGEM>' $ Upper(::XMLIn))
					AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
					::ReceiveStatus := .F.
				Else
					//-- Gera o Objeto XML conforme XML de envio:
					::XMLIn := NoAcento( OemToAnsi(::XMLIn) ) //-- Remove os Acentos
					oObjXML := XMLParser( ::XMLIn, '_', @cError, @cWarning )
					If !Empty(cError) .Or. !Empty(cWarning)
						If !Empty(cError)
							AAdd(aMsgErro, {'001', STR0003 + " - " + cError}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
						ElseIf !Empty(cWarning)
							AAdd(aMsgErro, {'001', STR0003 + " - " + cWarning}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
						EndIf
						::ReceiveStatus := .F.
					Else	
						If XMLChildCount( oObjXML:_Passagem:_Integracao ) <> 21
							AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
							::ReceiveStatus := .F.
						Else				
							ConOut('')
							ConOut(Repl('-',80))
							ConOut('Iniciando Processo - Passagem em Postos')
	
							::ReceiveStatus := .T.
	
							cFilOri := Left( oObjXML:_Passagem:_Integracao:_Codigo_Processo_Cliente:Text, 2 )
							cViagem := SubStr( oObjXML:_Passagem:_Integracao:_Codigo_Processo_Cliente:Text, 3, 6 )
			
							DTQ->(DbSetOrder(2))
							If !DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem))
								AAdd(aMsgErro, {'004', STR0006 + ' - ' + cFilori + '/' + cViagem}) //-- "Viagem nao encontrada!"
								::ReceiveStatus := .F.
							Else
								AAdd( aPassagens, {	oObjXML:_Passagem:_Integracao:_Codigo_Processo_Cliente:Text,;		//-- Processo de Transporte
													oObjXML:_Passagem:_Integracao:_Data:Text,;							//-- Data Prevista da Passagem
													oObjXML:_Passagem:_Integracao:_Hora:Text,;							//-- Hora Prevista da Passagem
													{	oObjXML:_Passagem:_Integracao:_CNPJ_Posto:Text,;				//-- CNPJ do Posto
														oObjXML:_Passagem:_Integracao:_Razao_Posto:Text,;				//-- Razao Social
														oObjXML:_Passagem:_Integracao:_Endereco:Text,;					//-- Endereco
														oObjXML:_Passagem:_Integracao:_Cidade:Text,;					//-- Cidade
														oObjXML:_Passagem:_Integracao:_Estado:Text,;					//-- Estado
														'' },;															//-- Telefone
													'',;																//-- Valor do Diesel
													oObjXML:_Passagem:_Integracao:_Data:Text,;							//-- Data Real da Passagem
													oObjXML:_Passagem:_Integracao:_Hora:Text,;							//-- Hora Real da Passagem
													oObjXML:_Passagem:_Integracao:_Valor_Consumo:Text,;					//-- Valor do Consumo
													oObjXML:_Passagem:_Integracao:_Valor_Saque:Text,;					//-- Valor do Saque
													oObjXML:_Passagem:_Integracao:_Data_Pagamento_Consumo:Text,;		//-- Data Prevista de pagamento do Consumo
													oObjXML:_Passagem:_Integracao:_Data_Pagamento_Saque:Text,;			//-- Data Prevista de pagamento do Saque
													oObjXML:_Passagem:_Integracao:_Codigo_Documento_Passagem:Text,;		//-- Documento vinculado a passagem
													oObjXML:_Passagem:_Integracao:_Indice_Lancamento:Text,;				//-- Ordem da Passagem 
													cOper } )															//-- Operacao (0-Baixa da Passagem, 1-Estorno da Baixa, 2-Nova Passagem em Aberto
	
								//�������������������Ŀ
								//�ATUALIZA A PASSAGEM�
								//���������������������
								ConOut('Efetivando a Passagem')
								TMSPassag( '01', cFilOri, cViagem, aPassagens )
								ConOut('Processo Ok!')
								ConOut(Repl('-',80))
								ConOut('')
	                        EndIf
			            EndIf
			        EndIf
			    EndIf
			            
		   	ElseIf ::ReturnType == '03' 
				//������������������������������Ŀ
				//� Quitacao de Frete            �
				//��������������������������������
				//-- Grava o XML em disco
				If lTMSXML
					TMSLogXML( ::XMLIn, 'ReceiveQuitacaoFrete.XML' )
				EndIf
				If !('<QUITACAO>' $ Upper(::XMLIn))
					AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
					::ReceiveStatus := .F.
				Else
					//-- Gera o Objeto XML conforme XML de envio:
					::XMLIn := NoAcento( OemToAnsi(::XMLIn) ) //-- Remove os Acentos
					oObjXML := XMLParser( ::XMLIn, '_', @cError, @cWarning )
					If !Empty(cError) .Or. !Empty(cWarning)
						If !Empty(cError)
							AAdd(aMsgErro, {'001', STR0003 + " - " + cError}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
						ElseIf !Empty(cWarning)
							AAdd(aMsgErro, {'001', STR0003 + " - " + cWarning}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
						EndIf
						::ReceiveStatus := .F.
					Else	
					    //- Formato antigo com tamanho de 16 e o novo formato com tamanho 17
						If XMLChildCount( oObjXML:_Quitacao:_Integracao ) < 16 .Or. XMLChildCount( oObjXML:_Quitacao:_Integracao ) > 17
							AAdd(aMsgErro, {'003',STR0010}) //-- "Formato do XML de entrada invalido. Atualizar o Mapa Quita��o na Repom
							::ReceiveStatus := .F.
						   	cFilOri := Left( oObjXML:_Quitacao:_Integracao:_Codigo_Processo_Cliente:Text, 2 )
						   	cViagem := SubStr( oObjXML:_Quitacao:_Integracao:_Codigo_Processo_Cliente:Text, 3, 6 )
							
							ConOut(str(threadid()) + 'Formato do XML de entrada invalido')
							conout(VARINFO("Viagem: ",cFilOri + '-' + cViagem,,.f.))
						Else				
							ConOut('')
							ConOut(Repl('-',80))
							ConOut('Iniciando Processo - Quitacao de Frete')
	
							::ReceiveStatus := .T.
	
						   	cFilOri := Left( oObjXML:_Quitacao:_Integracao:_Codigo_Processo_Cliente:Text, 2 )
						   	cViagem := SubStr( oObjXML:_Quitacao:_Integracao:_Codigo_Processo_Cliente:Text, 3, 6 )
			

							DTQ->(DbSetOrder(2))
							If !DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem))
								AAdd(aMsgErro, {'004', STR0006 + ' - ' + cFilori + '/' + cViagem}) //-- "Viagem nao encontrada!"
								::ReceiveStatus := .T.
							Else
								aDadosDoc:={}	
		   						If Valtype(oObjXML:_Quitacao:_Integracao:_Entregas:_Entrega) == 'A'
									For nAux := 1 To Len(oObjXML:_Quitacao:_Integracao:_Entregas:_Entrega)
											AAdd( aDadosDoc, {	oObjXML:_Quitacao:_Integracao:_Entregas:_Entrega[nAux]:_FILIAL_EMISSAO:Text,;
																oObjXML:_Quitacao:_Integracao:_Entregas:_Entrega[nAux]:_DOCUMENTO:Text,;
																oObjXML:_Quitacao:_Integracao:_Entregas:_Entrega[nAux]:_SERIE_DOCUMENTO:Text,;
																Left(oObjXML:_Quitacao:_Integracao:_Entregas:_Entrega[nAux]:_DATA_ENTREGA:Text,10),;
																SubStr(oObjXML:_Quitacao:_Integracao:_Entregas:_Entrega[nAux]:_DATA_ENTREGA:Text,12,5) })
									Next				   
								ElseIf Valtype(oObjXML:_Quitacao:_Integracao:_Entregas:_Entrega) == 'O'
											AAdd( aDadosDoc, {	oObjXML:_Quitacao:_Integracao:_Entregas:_Entrega:_FILIAL_EMISSAO:Text,;
																oObjXML:_Quitacao:_Integracao:_Entregas:_Entrega:_DOCUMENTO:Text,;
																oObjXML:_Quitacao:_Integracao:_Entregas:_Entrega:_SERIE_DOCUMENTO:Text,;
																Left(oObjXML:_Quitacao:_Integracao:_Entregas:_Entrega:_DATA_ENTREGA:Text,10),;
																SubStr(oObjXML:_Quitacao:_Integracao:_Entregas:_Entrega:_DATA_ENTREGA:Text,12,5) })
								EndIf          
								AAdd( aQuitacao, {	oObjXML:_Quitacao:_Integracao:_Codigo_Processo_Cliente:Text,;		 //-- Processo de Transporte
													oObjXML:_Quitacao:_Integracao:_Data_Quitacao:Text,;					 //-- Data Quitacao
													oObjXML:_Quitacao:_Integracao:_Hora_Quitacao:Text,;					 //-- Hora Quitacao
													oObjXML:_Quitacao:_Integracao:_Valor_Saques:Text,;					 //-- Valor Saques
													oObjXML:_Quitacao:_Integracao:_Valor_Total_Consumo:Text,;			 //-- Valor Total de Consumo
													oObjXML:_Quitacao:_Integracao:_Saldo_Pagar:Text,;					 //-- Saldo a Pagar
													oObjXML:_Quitacao:_Integracao:_Peso_Entrega:Text,;					 //-- Peso Entrega 
													oObjXML:_Quitacao:_Integracao:_Data_prevista_pagamento_saldo:Text,;	 //-- Dta Prevista Pagamento
													oObjXML:_Quitacao:_Integracao:_Filial_Codigo_Processo_Cliente:Text,;	//-- Filial Codigo Cliente																																
													oObjXML:_Quitacao:_Integracao:_Tipo_operacao:Text,;						//-- Tipo Operacao
													oObjXML:_Quitacao:_Integracao:_Codigo_Contrato:Text,; 					//-- Nr contrato 	     													
													aDadosDoc }) 															//-- Documentos da Viagem com Dt/Hr Entrega
							
								//�������������������Ŀ
								//�ATUALIZA A QUITACAO�
								//���������������������
								ConOut('Efetivando a Quitacao')
								cFilOld:= cFilAnt
								cFilAnt:= cFilOri
								TMSQuitac( '01', cFilOri, cViagem, aQuitacao )
								cFilAnt:= cFilOld
								ConOut('Processo Ok!')
								ConOut(Repl('-',80))
								ConOut('')
	                        EndIf
			            EndIf
			        EndIf
				EndIf
				
			ElseIf ::ReturnType == '04'
				//����������������������������������Ŀ
				//� Aviso de Pagamento de Carreteiro �
				//������������������������������������
	
				//-- Grava o XML em disco
				If lTMSXML
					TMSLogXML( ::XMLIn, 'ReceiveAvisoPagamentoCarreteiro.XML' )
				EndIf
				
				If !('<AVISO_PAGAMENTO_CARRETEIROS>' $ Upper(::XMLIn))
					AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
					::ReceiveStatus := .F.
				Else
					//-- Gera o Objeto XML conforme XML de envio:
					::XMLIn := NoAcento( OemToAnsi(::XMLIn) ) //-- Remove os Acentos
					oObjXML := XMLParser( ::XMLIn, '_', @cError, @cWarning )
					If !Empty(cError) .Or. !Empty(cWarning)
						If !Empty(cError)
							AAdd(aMsgErro, {'001', STR0003 + " - " + cError}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
						ElseIf !Empty(cWarning)
							AAdd(aMsgErro, {'001', STR0003 + " - " + cWarning}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
						EndIf
						::ReceiveStatus := .F.
					Else	
						If XMLChildCount( oObjXML:_Aviso_Pagamento_Carreteiros:_Integracao ) <> 12
							AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
							::ReceiveStatus := .F.
						Else				
							ConOut('')
							ConOut(Repl('-',80))
							ConOut('Iniciando Processo - Aviso de Pagamento de Carreteiros')
	
							::ReceiveStatus := .T.
							
							cFilOri := Left( oObjXML:_Aviso_Pagamento_Carreteiros:_Integracao:_Codigo_Processo_Sistema_Cliente:Text,2 )
							cViagem := SubStr( oObjXML:_Aviso_Pagamento_Carreteiros:_Integracao:_Codigo_Processo_Sistema_Cliente:Text, 3, 6 )
	
							DTQ->(DbSetOrder(2))
							If !DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem))
								AAdd(aMsgErro, {'004', STR0006 + ' - ' + cFilori + '/' + cViagem}) //-- "Viagem nao encontrada!"
								::ReceiveStatus := .F.
							Else
								DTY->(DbSetOrder(2)) //-- DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC
								If !DTY->(MsSeek(Iif(lDTYX2MODO,cFilOri,xFilial('DTY')) + cFilOri + cViagem))
									AAdd(aMsgErro, {'006', STR0007  } ) //-- "Contrato de carreteiro para a viagem nao existe"
									::ReceiveStatus := .F.
								Else
									RecLock('DER',.T.)
									DER->DER_FILIAL := xFilial('DER')
									DER->DER_FILORI := cFilOri
									DER->DER_VIAGEM := cViagem
									DER->DER_DATAUT := CtoD( oObjXML:_Aviso_Pagamento_Carreteiros:_Integracao:_Data_Autorizacao:Text )
									DER->DER_DATENV := CtoD( oObjXML:_Aviso_Pagamento_Carreteiros:_Integracao:_Data_Envio_Banco:Text )
									DER->DER_DATPAG := CtoD( oObjXML:_Aviso_Pagamento_Carreteiros:_Integracao:_Data_Pagamento:Text )
									DER->DER_DATCNF := CtoD( oObjXML:_Aviso_Pagamento_Carreteiros:_Integracao:_Data_Confirmacao_Pagamento:Text )
									DER->DER_VALPAG := Val( oObjXML:_Aviso_Pagamento_Carreteiros:_Integracao:_Valor:Text )
									MsUnLock()   
									
									//baixa  titulo e sdg abertos
									TMSXBXCC(cFilOri,cViagem)
									
									//������������������������Ŀ
									//�GERA LOG DA MOVIMENTACAO�
									//��������������������������
									TMSGerLog( 	'01',;	//-- Codigo da Operadora
												'AC',;	//-- Tipo do Log
												'R',;	//-- Log de 'E'nvio ou 'R'ecebimento
												xFilial('DER') + cFilOri + cViagem,;	//-- Chave do Registro (Identificador do Registro)
												'DER',;	//-- Origem do Registro
												'0' )	//-- 0-Inclusao, 1-Exclusao
								EndIf
							EndIf
						EndIf	
	                EndIf
	            EndIf    
	
			ElseIf ::ReturnType == '05'
				//������������������������������Ŀ
				//� Aviso de Pagamento de Postos �
				//��������������������������������
				//-- Grava o XML em disco
				If lTMSXML
					TMSLogXML( ::XMLIn, 'ReceiveAvisoPagamentoPostos.XML' )
				EndIf
	
	
				If !('<AVISO_PAGAMENTO_POSTOS>' $ Upper(::XMLIn))
					AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
					::ReceiveStatus := .F.
				Else
					//-- Gera o Objeto XML conforme XML de envio:
					::XMLIn := NoAcento( OemToAnsi(::XMLIn) ) //-- Remove os Acentos
					oObjXML := XMLParser( ::XMLIn, '_', @cError, @cWarning )
					If !Empty(cError) .Or. !Empty(cWarning)
						If !Empty(cError)
							AAdd(aMsgErro, {'001', STR0003 + " - " + cError}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
						ElseIf !Empty(cWarning)
							AAdd(aMsgErro, {'001', STR0003 + " - " + cWarning}) //-- "Ocorreu um erro na interpretacao do XML de entrada!"
						EndIf
						::ReceiveStatus := .F.
					Else	
						If XMLChildCount( oObjXML:_Aviso_Pagamento_Postos:_Integracao ) <> 7
							AAdd(aMsgErro, {'003',STR0005}) //-- "Formato do XML de entrada invalido!"
							::ReceiveStatus := .F.
						Else				
							ConOut('')
							ConOut(Repl('-',80))
							ConOut('Iniciando Processo - Aviso de Pagamento de Postos')
	
							::ReceiveStatus := .T.
							
							//-- Obtem o Fornecedor referente ao aviso de pagamento:
							SA2->(DbSetOrder(3))
							If !SA2->(MsSeek(xFilial('SA2') + AllTrim(oObjXML:_Aviso_Pagamento_Postos:_Integracao:_CNPJ_Posto:Text)))
								AAdd(aMsgErro, {'005',STR0009}) //-- "Posto relacionado a mensagem de Aviso de Pagamento de Postos nao encontrado na base de dados!"
								::ReceiveStatus := .F.
							Else
								ConOut('Efetivando o Aviso de Pagamento de Postos')
								RecLock('DEQ',.T.)
								DEQ->DEQ_FILIAL := xFilial('DEQ')
								DEQ->DEQ_CODFOR := SA2->A2_COD
								DEQ->DEQ_LOJFOR := SA2->A2_LOJA
								DEQ->DEQ_DATPAG := CtoD( oObjXML:_Aviso_Pagamento_Postos:_Integracao:_Data_Pagamento:Text )
								DEQ->DEQ_VALPAG := Val(oObjXML:_Aviso_Pagamento_Postos:_Integracao:_Valor:Text)
								DEQ->DEQ_TIPPAG := oObjXML:_Aviso_Pagamento_Postos:_Integracao:_Tipo_Pagamento:Text
								MsUnLock()
							
								//������������������������Ŀ
								//�GERA LOG DA MOVIMENTACAO�
								//��������������������������
								TMSGerLog( 	'01',;	//-- Codigo da Operadora
											'AV',;	//-- Tipo do Log
											'R',;	//-- Log de 'E'nvio ou 'R'ecebimento
										  		xFilial('DEQ') + SA2->A2_COD + SA2->A2_LOJA + DtoS( CtoD( oObjXML:_Aviso_Pagamento_Postos:_Integracao:_Data_Pagamento:Text ) ),;	//-- Chave do Registro (Identificador do Registro)
											'DEQ',; //-- Origem do Registro
											'0' )	//-- 0-Inclusao, 1-Exclusao  
	
								ConOut('Processo Ok!')
								ConOut(Repl('-',80))
								ConOut('')
							EndIf
						EndIf
					EndIf
				EndIf

			Else
				AAdd(aMsgErro, {'002', STR0004}) //-- "O tipo de retorno nao e valido!"
				::ReceiveStatus := .F.
				//-- Grava o XML em disco
				If lTMSXML
					TMSLogXML( ::XMLIn, 'ReceiveError-002.XML' )
				EndIf
			EndIf
		EndIf	
	EndIf	
EndIf

If !(::ReceiveStatus)
	SetSoapFault(aMsgErro[1,1],aMsgErro[1,2])
	lRet := .F.
EndIf

//�����������������������������������������������Ŀ
//�PONTO DE ENTRADA APOS O PROCESSAMENTO DO METODO�
//�������������������������������������������������
If lTMSE65Prc
	ExecBlock( 'TMSE65Prc', .F., .F., { ::ReturnType, ::XMLIn, aMsgErro } )
EndIf

//-- Seta a configuracao de nome de variaveis para 10 caracteres novamente...
SetVarNameLen( 10 )

RestArea(aAreaDTY)
RestArea(aAreaDTQ)
Return(lRet)
                     
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Metodo    �TMSEvents � Autor �Katia                    � Data �05.06.09  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo de XML recebidos pela Operadora de Frotas (REPOM)     ���
���          � para gera��o dos Movimentos Custo Transporte no Protheus.    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
<movimentacao_valores>
	<integracao>
	  <assinatura_digital>664da6sda64d4as</assinatura_digital> 
	  <mensagem_tipo>1</mensagem_tipo> 
	  <cliente_codigo>0153</cliente_codigo> 
	  <codigo_contrato_repom>000044598</codigo_contrato_repom>      //Contrato gerado na REPOM
	  <codigo_processo_cliente>30123003</codigo_processo_cliente>   //Filial Viagem + Nro Viagem
	  <filial_processo_cliente>30</filial_processo_cliente>         //Filial Viagem
	  <codigo_documento>123456</codigo_documento>                   //Nro Documento 
	  <codigo_movimento>6</codigo_movimento>                        //DEM_CODMOV
	  <descricao>DESCONTO</descricao> 
	  <valor>-10.00</valor> 
	  <data>06/05/2009</data> 
	  <hora>09:20</hora> 
	  <usuario>SISTEMA</usuario> 
	  <operacao>0</operacao> 
	</integracao>
</movimentacao_valores>     
*/
