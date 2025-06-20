#INCLUDE "WSGPE070.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"

/*
������������������������������������ͳ��
���Data Fonte Sustenta��o� ChangeSet ���
������������������������������������ĳ��  
���    21/07/2015        �  317066   ��� 
�������������������������������������ͱ�
*/ 
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o     �WSGPE070  � Autor �Marcelo Faria			� Data �28.03.2012  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Web Service responsavel pelos Dados Cadastrais	            ���
���������������������������������������������������������������������������Ĵ��
���Uso       � RH/Portais                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Responsavel  � Data   �Tarefa�  Motivo da Alteracao                     ��� 
��� Marcelo Faria�03/01/13�REQ204� Inclusao de metodo GetMessage para gerar ��� 
���              �        �04    � a mensagem ao participante               ��� 
���              �        �      � Apesar de ser liberado na release 11.80  ��� 
���              �        �      � essa funcionalidade foi liberada para    ��� 
���              �        �      � o cliente Liberty(11.50)                 ���
��� Renan Borges �08/12/15�TTSYXZ� Ajuste para visualizar dados cadastrais  ��� 
���              �        �      � corretamente ao incluir um campo Memo de ���
���              �        �      � usu�rio e inseri-lo para visualiza��o na ���
���              �        �      � rotina de dados cadastrais do portal.    ���  
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
//�����������������������������������������������������Ŀ
//�Definicao da Estrutura dos campos                    �
//�������������������������������������������������������
WSSTRUCT FieldsGroup
	WSDATA EmployeeImg 		 				AS Base64Binary OPTIONAL       //Imagem do funcionario
	WSDATA ListOfFieldsGroup     	As Array of FieldsStruct
ENDWSSTRUCT

WSSTRUCT FieldsStruct
	WSDATA Group		 		    			As String	       	  		   	//Pasta ou Grupo de campos
	WSDATA ListOfFieldsStruct     	As Array of DataField OPTIONAL	//Lista de campos para o funcionario
ENDWSSTRUCT

WSSTRUCT DataField
	WSDATA FieldSeq 							As Integer				      		//Sequencia do campo
	WSDATA FieldDesc 							As String	      						//Titulo do Campo
	WSDATA FieldAct 							As String 	        				//Acao para o campo
	WSDATA FieldType 							As String 	        				//tipo de dado do campo
	WSDATA FieldSize 							As Integer 	        				//Tamanho do campo
	WSDATA FieldDec 							As Integer 	        				//Tamanho do decimal numerico
	WSDATA FieldVal							As String 	        				//Valor do campo
	WSDATA FieldCtx							As String 	        				//Contexto do campo (Real/Virtual)
ENDWSSTRUCT                            

WSSTRUCT DataMessages
	WSDATA CompanyMessage					As String				      			//Mensagem da empresa
	WSDATA EmployeeMessage				As String				      			//Mensagem do funcionario
ENDWSSTRUCT                            

//�����������������������������������������������������Ŀ
//�Definicao do Web Service de Dados do Funcionario     �
//�������������������������������������������������������
WSSERVICE  RHEmployeeRegistration	DESCRIPTION STR0001				 	//Dados da Funcionario
	WSDATA EmployeeFil 		 				AS String			        			//Filial do funcionario
	WSDATA Registration		 				AS String			        			//Matricula do funcionario
	WSDATA EmployeeEmp  	 				AS String			        			//Empresa do funcionario

	WSDATA Messages							AS DataMessages	        			//Mensagens do funcionario
	WSDATA FieldValues		 				As FieldsGroup								//Dados dos Campos do SRA
	
	WSMETHOD GetRegEmployee				DESCRIPTION STR0002 						//Metodo que retorna os dados cadastrais do funcionario
	WSMETHOD GetMessage		 				DESCRIPTION STR0005 						//Metodo que retorna a mensagem do RH do funcionario
ENDWSSERVICE                                                                                                     

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Metodo    �GetRegEmployee � Autor �Marcelo Faria		    �Data �28.03.2012 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Metodo que retorna os campos do SRA, baseado na tabela RHW  	���
���������������������������������������������������������������������������Ĵ��
���Uso       � SIGATCF/Portal RH                                            ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
WSMETHOD GetRegEmployee WSRECEIVE EmployeeFil, Registration, EmployeeEmp WSSEND FieldValues WSSERVICE RHEmployeeRegistration
Local aCamposSX3 	:= {}
Local aMemSet		:= {}
Local lRet    		:= .T.                         
Local nReg    		:= 0                         
Local nx			:= 0
Local cDirImg    := ""
Local cBmpPict 	:= ""
Local cPathPict		:= GetSrvProfString("Startpath","")
Local cBitMap  	:= ""
Local cLeitura 	:= ""
Local cDescF3	:= ""
Local cExtensao		:= ".JPG"
Local nHandle  	:= 0
Local lCombo	:= .F.
Local lF3		:= .F.
Local aDescCombo:= {}

Local cGrupoAnt  := ""
Local cNameField := ""
Local cFilFun		:= ::EmployeeFil
Local cMatFun 		:= ::Registration
Local cQryAlias 	:= ""
Local cFuncAlias	:= ""
Local oFieldsGrp
Local oDataFields
Local oCampos
Local cCampo		:= ""
Local cIdiom        := FWRetIdiom() //Retorna Idioma Atual
Local cCposSRA		:= cposToQry("SRA")
Local cTabela 		:= "%"+RetSqlName("SRA")+"%"

DEFAULT EmployeeEmp := ""

If EmployeeEmp != "" .And. cEmpAnt != EmployeeEmp
	fOpenSx2(EmployeeEmp)
	cTabela := "%"+FWSX2Util():GetFile("SRA")+"%"
	fOpenSx2(cEmpAnt)
Endif

//Verifica dados do funcionario
cCposSRA := IIf(Empty(cCposSRA), "%*%", "%"+cCposSRA+"%") 
cFuncAlias := "QSRA"  
BeginSql alias cFuncAlias
	SELECT %exp:cCposSRA%
	FROM %exp:cTabela% SRA
	WHERE SRA.RA_FILIAL = %exp:cFilFun% AND
		 SRA.RA_MAT	  = %exp:cMatFun% AND
    	 SRA.%notDel%     
EndSql                                           
If (cFuncAlias)->(Eof())
	(cFuncAlias)->(dbCloseArea())
	SetSoapFault("GetRegEmployee", STR0003)
	Return .F.
EndIf

aMemSet:={}

DbSelectArea("SRA")
DbSetOrder(1)
DbSeek(cFilFun+cMatFun)

//Busca dados do SX3
DbSelectarea("SX3")
DbSetOrder(1)
DbSeek("SRA")
While X3_ARQUIVO == "SRA"
	AADD(aCamposSX3,{X3_CAMPO, PorEncode(X3Titulo()), X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_CONTEXT, X3CBox(),X3_F3})
	If X3_PROPRI = 'U' .AND. X3_TIPO == 'M'
		cCampo	:= X3_CAMPO
		aAdd(aMemSet,{"M->"+cCampo,SRA->&(cCampo)})
	EndIf
	dbSkip()
EndDo

//Busca dados 
cQryAlias := "QRHW"  
BeginSql alias cQryAlias
	SELECT 	*
	FROM 	%table:RHW% RHW 
	WHERE 	RHW.RHW_TABELA = "SRA" AND
			RHW.%notDel%
	Order by RHW_GRUPO, RHW_SEQ		
EndSql                                           

::FieldValues := WsClassNew('FieldsGroup')
::FieldValues:ListOfFieldsGroup := {}

//Setando variaveis de memoria criadas no E-Social
aAdd(aMemSet,{"M->RA_OBSDEFI",SRA->RA_OBSDEFI})
For nx:=1 To Len(aMemSet)
	If Type(aMemSet[nX][1]) == 'U'
		SetMemVar( aMemSet[nX][1] , aMemSet[nX][2],.T.)
	Endif
Next

//oFieldsGrp  := WsClassNew('FieldsGroup')
While (cQryAlias)->(!Eof())
	cNameField := (cQryAlias)->RHW_CAMPO
	nPosFil := aScan(aCamposSX3,{|X| X[1] = cNameField})
	If nPosFil > 0
		cDescF3		:= ""
	
		If (cQryAlias)->RHW_GRUPO != cGrupoAnt
			If cGrupoAnt != ""
				//Atualiza a estrutura com os dados do grupo
				nReg++ 
				aadd(::FieldValues:ListOfFieldsGroup,WsClassNew('FieldsStruct'))
				::FieldValues:ListOfFieldsGroup[nReg]  := oDataFields 
			EndIf	
	
			oDataFields := WsClassNew('FieldsStruct')
			oDataFields:ListOfFieldsStruct	:= {}
	
			cGrupoAnt				 		:= (cQryAlias)->RHW_GRUPO
			oDataFields:Group 				:= (cQryAlias)->RHW_GRUPO		
		EndIf	
	
		If !Empty((cQryAlias)->RHW_ACAO)
			oCampos:= WsClassNew('DataField')
			oCampos:FieldSeq	:= (cQryAlias)->RHW_SEQ
			oCampos:FieldAct	:= (cQryAlias)->RHW_ACAO
	
			If nPosFil > 0
				oCampos:FieldDesc	:= aCamposSX3[nPosFil,2] 
				oCampos:FieldType	:= aCamposSX3[nPosFil,3]
				oCampos:FieldSize	:= aCamposSX3[nPosFil,4]
				oCampos:FieldDec	:= aCamposSX3[nPosFil,5]
				oCampos:FieldCtx	:= aCamposSX3[nPosFil,6]
				lCombo				:= !Empty(aCamposSX3[nPosFil,7])
				lF3					:= !Empty(aCamposSX3[nPosFil,8]) .and. Len(AllTrim(aCamposSX3[nPosFil,8])) == 2
				aDescCombo			:= {}
				If lF3
					cDescF3 := POSICIONE("SX5",1,XFILIAL("SX5")+AllTrim(aCamposSX3[nPosFil,8])+(cFuncAlias)->&(cNameField),"X5_DESCRI")
					If Empty(cDescF3)
						cDescF3 := (cFuncAlias)->&(cNameField)
					EndIf
				EndIf
				If lCombo
					aDescCombo			:= If(";" $ aCamposSX3[nPosFil,7],Separa(aCamposSX3[nPosFil,7],";"),&(aCamposSX3[nPosFil,7]))
				EndIf
			EndIf	
	
			//Verifica tipo de dado do campo
			If lCombo
				If !Empty((cFuncAlias)->&(cNameField)) .and. (nPosFil := aScan(aDescCombo,{|X| AllTrim((cFuncAlias)->&(cNameField))+"=" $ X})) > 0
					oCampos:FieldVal	:= AllTrim(StrTran(aDescCombo[nPosFil],AllTrim((cFuncAlias)->&(cNameField))+"=",""))
				Else
					oCampos:FieldVal	:= (cFuncAlias)->&(cNameField)
				EndIf
			ElseIf lF3
				oCampos:FieldVal	:= AllTrim(cDescF3)
			ElseIf valtype((cFuncAlias)->&(cNameField)) = 'C'
				If Trim(cNameField) == "RA_CC"
					oCampos:FieldVal	:= (cFuncAlias)->&(cNameField) + " - " + Posicione("CTT",1,xFilial("CTT",(cFuncAlias)->RA_FILIAL)+(cFuncAlias)->RA_CC,"CTT_DESC01")
				Else
					oCampos:FieldVal	:= (cFuncAlias)->&(cNameField)
				EndIf
			ElseIf valtype((cFuncAlias)->&(cNameField)) = 'N'
				oCampos:FieldVal	:= Str((cFuncAlias)->&(cNameField))
			ElseIf valtype((cFuncAlias)->&(cNameField)) = 'D'
				oCampos:FieldVal	:= dToc((cFuncAlias)->&(cNameField))
			ElseIf valtype((cFuncAlias)->&(cNameField)) = 'L'
				If (cFuncAlias)->&(cNameField)
					oCampos:FieldVal	:= 'V'
				Else	
					oCampos:FieldVal	:= 'F'
				EndIf
			EndIf			
	
			aadd(oDataFields:ListOfFieldsStruct, oCampos)	
		EndIf
	EndIf
	(cQryAlias)->( dbSkip() )
EndDo

If valtype(oDataFields) == 'O'
	//Carrega ultimo grupo de campos
	If len(oDataFields:ListOfFieldsStruct) > 0
		//Atualiza a estrutura com os dados do grupo
		nReg++ 
		aadd(::FieldValues:ListOfFieldsGroup,WsClassNew('FieldsStruct'))
		::FieldValues:ListOfFieldsGroup[nReg]  := oDataFields 
	EndIf
	
	//Verifica imagem para o funcionario
	IF cIdiom == 'es' //SPANISH
		cDirImg := "imgspa"
	ElseIF cIdiom == 'en' //ENGLISH
		cDirImg := "imgeng"
	Else
		cDirImg := "images"
	EndIf
	
	If !Empty( cBmpPict := Upper( AllTrim( (cFuncAlias)->RA_BITMAP ) ) )
		If RepExtract(cBmpPict,cPathPict+cBmpPict)
			If !File(cPathPict+cBmpPict+cExtensao)
				cExtensao := ".BMP"
			EndIf
			nHandle := FOpen(cPathPict+cBmpPict+cExtensao)
			If nHandle <> 0
				nLidos := 1
				While nLidos > 0
					cLeitura := ""
					nLidos := Fread(nHandle,@cLeitura,4096)
					cBitMap += cLeitura
				EndDo
				::FieldValues:EmployeeImg := cBitMap
			Else
				::FieldValues:EmployeeImg := cDirImg+"/avatar.gif"
			EndIf
			FClose(nHandle)
			Ferase(cPathPict+cBmpPict+cExtensao)
		Else
			::FieldValues:EmployeeImg := cDirImg+"/avatar.gif"
		EndIf
	Else
		::FieldValues:EmployeeImg := cDirImg+"/avatar.gif"
	EndIF		
	
	(cQryAlias)->( DbCloseArea() )
	(cFuncAlias)->( DbCloseArea() )
Else
	lRet := .F.
	SetSoapFault("GetRegEmployee",STR0004)	//"Tabela RHW - Dados Cadastrais ainda n�o foi configurada.<br><br>Acesse a rotina SIGATCF -> Atualiza��es -> Configura��es -> Dados Cadastrais."
EndIf
	
Return lRet

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Metodo    �GetMessage		 � Autor �Marcelo Faria		    �Data �03.01.2012 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Metodo que retorna o mensagem do RH ao funcionario				  	���
���������������������������������������������������������������������������Ĵ��
���Uso       � Portal RH   					                                        ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
WSMETHOD GetMessage WSRECEIVE EmployeeFil, Registration WSSEND Messages WSSERVICE RHEmployeeRegistration
Local lRet    	  := .T.                         
Local lValid  	  := .F.                         
Local cMsg 			:= ""
Local cFileMsg	  := "TCFEMP.MSG"
Local aMsgEmp    := {}
Local nHandle

	//Busca menssagem ao funcionario
	::Messages:EmployeeMessage	:= ""

	DBSelectArea("SRA")
	DBSetOrder(1)
	If DBSeek(xFilial("SRA", Self:EmployeeFil) + Self:Registration)
			If empty(SRA->RA_TCFMSG)
					::Messages:EmployeeMessage	:= ""
			Else
					If Alltrim(StrTran(Alltrim(APDMSMM(SRA->RA_TCFMSG)) , chr(13)+chr(10), "")) != "" 
						::Messages:EmployeeMessage := Alltrim(APDMSMM(SRA->RA_TCFMSG))
					EndIf	
			EndIf		
	Endif

	//Captura menssagem corporativa
	nHandle := fOpen( cFileMsg )
	aMsgEmp := GetAllTxtFile( nHandle )
	fClose( nHandle )

	cMsg	:= ""
	::Messages:CompanyMessage	 := ""
	If len(aMsgEmp) > 0 
			cMsg := alltrim(StrTran(aMsgEmp[1] , chr(13)+chr(10), ""))
			If len(cMsg) > 0
					::Messages:CompanyMessage	 := Alltrim(aMsgEmp[1])
			EndIf
	EndIf
		
Return lRet

/*/{Protheus.doc} cposToQry()
Retorna string com todos os campos da tabela, exceto campos Memo, separados por virgula
@since	10/06/2022
@autor	martins.marcio
@version P12
/*/
Static Function cposToQry(cAlias)
	Local cRet	:= ""
	Local aRet	:= {}
	Local nI	:= 0
	Local aCampos := {}
	
	DEFAULT cAlias := "SRA"

	aCampos := FWSX3Util():GetAllFields( cAlias, .F.)
	If !Empty(aCampos)
		For nI := 1 To Len(aCampos)
			If FWSX3Util():GetFieldType( aCampos[nI]) <> "M" // Memo
				aAdd(aRet, AllTrim(aCampos[nI]))
			EndIf
		Next nI

		If !Empty(aRet)
			cRet := ArrTokStr(aRet,", ")
		EndIf
	EndIf

Return cRet

/*/{Protheus.doc} fOpenSx2
Fun��o para abrir a SX2 de outra empresa
@author Rafael Reis
@since 29/12/2017
/*/
Static Function fOpenSx2(cEmp)
	Local lOk	:=	.T.

	SX2->(DBCloseArea())
	OpenSxs(,,,,cEmp,"SX2","SX2",,.F.)
	lOk := Select("SX2") > 0

Return lOk
