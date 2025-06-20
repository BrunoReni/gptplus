#INCLUDE 'PROTHEUS.CH'  
#INCLUDE 'FWADAPTEREAI.CH' 


Static cVerSend := ''

/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������Ŀ��
���Funcao    � GPEI250    �Autor  �Alberto M.         v.I         � Data �31/12/2014���
�����������������������������������������������������������������������������������Ĵ��
���Descricao � Mensagem Unica EmployeeHistorySalaryPosition                         ���
�����������������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                                      ���
�����������������������������������������������������������������������������������Ĵ��
���Uso       � GPEA010 - Funcionario.                                               ���
���          � GPER200 - Reajuste Salarial.                                         ���
���          � GPEM690 - Dissidio Retroativo.                                       ���
���          � GPEA250 - Hist�rio de Sal�rio.                                       ���
�����������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                       ���
�����������������������������������������������������������������������������������͹��
*/

Function GPEI250(cXml, nType, cTypeMsg, cVersaoMsg )


Local nTypeTrans := nType
Local cXMLRet    := ''
Local cOrigem    := ''
Local lRet       := .T.
Local cEvent     := 'upsert'
Local cAliasXXF := ''

If nTypeTrans == TRANS_RECEIVE

	Do Case
			Case cTypeMsg == EAI_MESSAGE_WHOIS
				lRet := .T.
				cXMLRet := cVerSend
			Case cTypeMsg == EAI_MESSAGE_RECEIPT
			Case cTypeMsg == EAI_MESSAGE_BUSINESS
			Case cTypeMsg == EAI_MESSAGE_RESPONSE
	EndCase
			
ElseIf nTypeTrans == TRANS_SEND

	Do Case
		//Funcionarios.
		Case IsInCallStack('GPEA010')
			cOrigem   := 'GPEA010'
			cEvent    := 'upsert'
		//Reajuste Salarial.
		Case IsInCallStack('GPER200')
			cOrigem   := 'GPER200'
			cEvent    := 'upsert'
		//Dissidio Retroativo.
		Case IsInCallStack('GPEM690')
			cOrigem   := 'GPEM690'
			cEvent    := 'upsert'
		//Altera��o Salarial.
		Case IsInCallStack('GPEA250')
			cOrigem   := 'GPEA250'
			If l250exc 
				cEvent    := 'delete'
			Else
				cEvent    := 'upsert'
			EndIf
	EndCase


	//Conte�do do evento.
	cXMLRet += '<BusinessEvent>'
	cXMLRet +=    '<Entity>EmployeeHistorySalaryPosition</Entity>'
	cXMLRet +=    '<Event>' + cEvent+ '</Event>'
	cXMLRet += 	'<Identification>' 
	cXMLRet += 		'<key name="InternalID"></key>' 
	cXMLRet += 	'</Identification>'
	cXMLRet += '</BusinessEvent>'

	//Conte�do do neg�cio.
	cXMLRet += '<BusinessContent>'
	cXMLRet += 	'<CompanyId>' + cEmpAnt + '</CompanyId>' 
	cXMLRet += 	'<BranchId>' + BranchId(cOrigem) + '</BranchId>'
	cXMLRet += 	'<CompanyInternalId>' + cEmpAnt + "|" + BranchId(cOrigem) + '</CompanyInternalId>'
	cXMLRet +=    '<ListOfEmployeeHistorySalaryPosition>'
	cXMLRet +=    	'<EmployeeHistorySalaryPosition>
	cXMLRet += 			'<EmployeeCode>' + EmployCod(cOrigem) + '</EmployeeCode>'
	cXMLRet += 			'<EmployeeInternalID>' + EmploIntID(cOrigem) + '</EmployeeInternalID>'
	cXMLRet += 			'<ChangedDate>' + ChngDate(cOrigem) +'</ChangedDate>'
	cXMLRet += 			'<Salary>' + Salary(cOrigem) +'</Salary>'
	cXMLRet += 			'<PaymentFrequency>'+ PaymentFreq(cOrigem) + '</PaymentFrequency>'
	cXMLRet += 			'<EmployeePositionCode>'+ EmploPosCod(cOrigem) + '</EmployeePositionCode>'
	cXMLRet +=           '<EmployeePositionInternalId>' +PositionId(cOrigem)+ '</EmployeePositionInternalId>'
	cXMLRet +=           '<EmployeePositionLevel>' + '</EmployeePositionLevel>'
	cXMLRet += 		'</EmployeeHistorySalaryPosition>
	cXMLRet += 	'</ListOfEmployeeHistorySalaryPosition>'
	cXMLRet += '</BusinessContent>' 

EndIf	


Return({lRet,cXMLRet})
	
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � EmployCod   � Autor � Alberto M.           � Data � 31/12/14���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <EmployeeCode> da mensagem             ���
���          � EmployeeHistorySalaryPosition.                              ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI250                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
//Preenchimento da TAG <EmployeeCode>.
Static Function EmployCod (cOrigem)

Local cTag := ''

Do Case
	//Funcionarios.
	Case cOrigem == 'GPEA010'
		cTag := AllTrim(SRA->RA_MAT)
	//Reajuste Salarial.
	Case cOrigem == 'GPER200'
		cTag := AllTrim(SR3->R3_MAT)
	//Dissidio Retroativo.
	Case cOrigem == 'GPEM690'
		cTag := AllTrim(SRA->RA_MAT)
	//Altera��o Salarial.
	Case cOrigem == 'GPEA250'
		cTag := SR3->R3_MAT//aIntegdef[GdFieldPos( "R3_MAT"		, aHeaderR3All )]
EndCase
Return(cTag)


/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � EmploIntID  � Autor � Alberto M.           � Data � 31/12/14���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <EmployeeInternalId> da mensagem       ���
���          � EmployeeHistorySalaryPosition.                              ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI250                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
//Preenchimento da TAG <EmployeeInternalId>.
Static Function EmploIntID (cOrigem)

Local cTag := ''

Do Case
	//Funcionarios.
	Case cOrigem == 'GPEA010'
		cTag := cEmpAnt + '|' + SRA->RA_FILIAL + '|' + SRA->RA_MAT
	//Reajuste Salarial.
	Case cOrigem == 'GPER200'
		cTag := cEmpAnt + '|' + SRA->RA_FILIAL + '|' + SR3->R3_MAT
	//Dissidio Retroativo.
	Case cOrigem == 'GPEM690'
		cTag := cEmpAnt + '|' + SRA->RA_FILIAL + '|' + SRA->RA_MAT
	//Altera��o Salarial.
	Case cOrigem == 'GPEA250'
		cTag := SR3->R3_FILIAL + '|' + SR3->R3_MAT //aIntegdef[GdFieldPos( "R3_FILIAL"		, aHeaderR3All )] + "|" + aIntegdef[GdFieldPos( "R3_MAT"		, aHeaderR3All )]
EndCase


Return(cTag)

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � ChngDate    � Autor � Alberto M.           � Data � 31/12/14���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <ChangedDate> da mensagem              ���
���          � EmployeeHistorySalaryPosition.                              ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI250                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
//Preenchimento da TAG <ChangedDate>.
Static Function ChngDate (cOrigem)

Local cTag := ''
Local cAux := ''

Do Case
	//Funcionarios.
	Case cOrigem == 'GPEA010'
		cAux := AllTrim(DtoS(dDataAlt))  
		cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2) 
	//Reajuste Salarial.
	Case cOrigem == 'GPER200'
		cAux := AllTrim(DtoS(SR7->R7_DATA)) 
		cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2) 
	//Dissidio Retroativo.
	Case cOrigem == 'GPEM690'
		cTag := Substr(RHH->RHH_DATA,1,4) + '-' + Substr(RHH->RHH_DATA,5,2) + '-' + '01' 
	//Altera��o Salarial.
	Case cOrigem == 'GPEA250'
		cTag := Transform( dtos(oGridSr3:getvalue("R3_DATA")), "@R 9999-99-99")//Transform( dtos(aIntegdef[GdFieldPos( "R3_DATA"		, aHeaderR3All )]), "@R 9999-99-99")
EndCase


Return(cTag)


/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � Salary      � Autor � Alberto M.           � Data � 31/12/14���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <Salary> da mensagem                   ���
���          � EmployeeHistorySalaryPosition.                              ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI250                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
//Preenchimento da TAG <Salary>.
Static Function Salary(cOrigem)

Local cTag := ''

Do Case
	//Funcionarios.
	Case cOrigem == 'GPEA010'
		cTag := AllTrim(Str(SRA->RA_SALARIO))
	//Reajuste Salarial.
	Case cOrigem == 'GPER200'
		cTag := AllTrim(Str(SR3->R3_VALOR))
	//Dissidio Retroativo.
	Case cOrigem == 'GPEM690'
		cTag := AllTrim(Str(RHH->RHH_CALC))
	//Altera��o Salarial.
	Case cOrigem == 'GPEA250'
		cTag := AllTrim(Str(oGridSr3:getValue("R3_VALOR")))
EndCase



Return(cTag)				
	
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � PaymentFreq � Autor � Alberto M.           � Data � 31/12/14���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <PaymentFrequency> da mensagem         ���
���          � EmployeeHistorySalaryPosition.                              ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI250                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
//Preenchimento da TAG <PaymentFrequency>.
Static Function PaymentFreq(cOrigem)

Local cTag := ''

Do Case
	//Funcionarios.
	Case cOrigem == 'GPEA010'
		Do Case
			Case SRA->RA_TIPOPGT == 'M'
				cTag := '1'
			Case SRA->RA_TIPOPGT == 'S'
				cTag := '6'
		EndCase
		
	//Reajuste Salarial.
	Case cOrigem == 'GPER200'
				Do Case
			Case SR7->R7_TIPOPGT == 'M'
				cTag := '1'
			Case SR7->R7_TIPOPGT == 'S'
				cTag := '6'
		EndCase
	//Dissidio Retroativo.
	Case cOrigem == 'GPEM690'
		
		Do Case
			Case SRA->RA_TIPOPGT == 'M'
				cTag := '1'
			Case SRA->RA_TIPOPGT == 'S'
				cTag := '6'
		EndCase
		
	//Altera��o Salarial.
	Case cOrigem == 'GPEA250'
		Do Case
			Case SRA->RA_TIPOPGT == 'M'
				cTag := '1'
			Case SRA->RA_TIPOPGT == 'S'
				cTag := '6'
		EndCase
EndCase


Return(cTag)	

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � EmploPosCod � Autor � Alberto M.           � Data � 31/12/14���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <EmployeePositionCode> da mensagem     ���
���          � EmployeeHistorySalaryPosition.                              ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI250                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
//Preenchimento da TAG <EmployeePositionCode>.
Static Function EmploPosCod(cOrigem)

Local cTag := ''

Do Case
	//Funcionarios.
	Case cOrigem == 'GPEA010'
		cTag := AllTrim(SRA->RA_CARGO)
	//Reajuste Salarial.
	Case cOrigem == 'GPER200'
		cTag := AllTrim(SR7->R7_CARGO)
	//Dissidio Retroativo.
	Case cOrigem == 'GPEM690'
		cTag := AllTrim(SRA->RA_CARGO)
	//Altera��o Salarial.
	Case cOrigem == 'GPEA250'
		cTag := AllTrim(SRA->RA_CARGO)
EndCase


Return(cTag)		

Static Function PositionId(cOrigem)

Local cTag := ''

Do Case
	//Funcionarios.
	Case cOrigem == 'GPEA010'
		cTag := GPEI370Snd( { cEmpAnt, xFilial("SQ3"), AllTrim(SRA->RA_CARGO) } )
	//Reajuste Salarial.
	Case cOrigem == 'GPER200'
		cTag := GPEI370Snd( { cEmpAnt, xFilial("SQ3"), AllTrim(SR7->R7_CARGO) } )
	//Dissidio Retroativo.
	Case cOrigem == 'GPEM690'
		cTag := GPEI370Snd( { cEmpAnt, xFilial("SQ3"), AllTrim(SRA->RA_CARGO) } )
	//Altera��o Salarial.
	Case cOrigem == 'GPEA250'
		cTag := GPEI370Snd( { cEmpAnt, xFilial("SQ3"), AllTrim(SRA->RA_CARGO) } )
EndCase
Return(cTag)	

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � BranchId � Autor � Alberto M.              � Data � 31/12/14���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <BranchId> da mensagem                 ���
���          � EmployeeHistorySalaryPosition.                              ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI250                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
//Preenchimento da TAG <BranchId>.
Static Function BranchId(cOrigem)

Local cTag := ''

Do Case
	//Funcionarios.
	Case cOrigem == 'GPEA010'
		cTag := SRA->RA_FILIAL
	//Reajuste Salarial.
	Case cOrigem == 'GPER200'
		cTag := SR3->R3_FILIAL
	//Dissidio Retroativo.
	Case cOrigem == 'GPEM690'
		cTag := SRA->RA_FILIAL
	//Altera��o Salarial.
	Case cOrigem == 'GPEA250'
		cTag := SRA->RA_FILIAL
EndCase


Return(cTag)		