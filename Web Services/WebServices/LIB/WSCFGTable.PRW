#INCLUDE "WSCFGTable.ch"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �WSCFGTable� Autor �Eduardo Riera          � Data �07.08.2003  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Web Service responsavel pela recuperacao de tabelas do siste-���
���          �ma                                                            ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Web Service                                                  ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
//������������������������������������������������������������������������Ŀ
//�Definicao do Web Service                                                �
//��������������������������������������������������������������������������
WSSERVICE CFGTable DESCRIPTION STR0001 NAMESPACE "http://webservices.microsiga.com.br/cfgtable.apw" //"Servico gen�rico de consulta aos dados das tabelas do sistema"
    WSDATA UserCode                 AS String
    WSDATA Alias                    AS String
    WSDATA Table                    AS TableView
    WSDATA QueryAddWhere            As String  OPTIONAL
    WSDATA Branch        			As String  OPTIONAL
    WSDATA ListFieldsView			As String  OPTIONAL
     
    WSMETHOD GetTable DESCRIPTION STR0002 //"M�todo de consulta as tabelas do sistema"
   
ENDWSSERVICE

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �GetTable  �Autor  � Eduardo Riera         � Data �18.09.2003 ���
��������������������������������������������������������������������������Ĵ��
���          �Rotina de recuperacao das tabelas do sistema                 ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Codigo do Usuario                                     ���
���          �ExpC2: Alias da tabela                                       ���
���          �ExpC3: Expressa a ser adicionada na query                    ���
���          �ExpC4: Lista de filias que deverao ser filtradas Ex:'01','02'���
���          �ExpC5: Lista de campos que deverao ser resgatados pelo WS    ���
���          �       diminuindo o fluxo de informacoes.Nao sera suportado  ���
���          �       cabecalhos complexos, como: "(B1_DESC) As Descricao", ���
���          �       somente aceitara estrutura simples separado por virgula��
��������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica que o M�todo foi avaliado com sucesso          ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Este M�todo devolve a estrutura de um tabela com seus dados  ���
���          �                                                             ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � CRM/Materiais/Portais                                       ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
WSMETHOD GetTable WSRECEIVE UserCode,Alias,QueryAddWhere,Branch,ListFieldsView WSSEND Table WSSERVICE CFGTable

Local aArea    := GetArea()
Local aAreaSX3 := SX3->(GetArea())
Local aStruct  := {}  
Local aStruAux := {}
Local lQuery   := .F.
Local lEmpytFil:= Empty(::Branch)
Local cCursor  := ""           
Local cArquivo := ""                        
Local cCpoFil  := PrefixoCpo(::Alias)+"_FILIAL"
Local lRetorno := .T.
Local nX       := 0
Local nY       := 0
Local nW       := 0
Local aFieldsSelect := {} 
#IFDEF TOP
	Local cQuery   := ""
#ENDIF

If PrtChkUser(::UserCode,"CFGTable","GetTable")
	dbSelectArea("SX3")	
	dbSetOrder(1)
	If MsSeek(::Alias)
		//������������������������������������������������������������������������Ŀ
		//�Montagem da estrutura                                                   �
		//��������������������������������������������������������������������������
		aStruct := (::Alias)->(dbStruct())

		//������������������������������������������������������������������������Ŀ
		//�Prepara a estrutura para listar somente os campos desejados, este campos�
		//�devem estar separados por virgula, pois serao usados no SELECT.         �		
		//��������������������������������������������������������������������������
		If !Empty(::ListFieldsView)
			
			aFieldsSelect := strtokarr(::ListFieldsView ,",")
			
			// Valida e adiciona no array aStruAux os campos da lista
			For nX:= 1 to len(aFieldsSelect)
				nY:= Ascan(aStruct,{|x|Alltrim(x[1]) == aFieldsSelect[nX]})
				If nY >0
					nW:= Ascan(aStruAux,{|x|Alltrim(x[1]) == aFieldsSelect[nX]})
					If nW == 0
						Aadd(aStruAux,{aStruct[nY,1],aStruct[nY,2],aStruct[nY,3],aStruct[nY,4]})
					EndIf
				Else
				
					// Busca no "CAMPO" informado se existe o mesmo natabela
					// Se existir e n�o tiver incluido ainda no array aStruAux, adiciono o mesmo.
					For nW := 1 To len(aStruct)
						If aStruct[nW,1] $ UPPER(aFieldsSelect[nX])
							nY:= Ascan(aStruAux,{|x|Alltrim(x[1]) == aStruct[nW,1]})
							If nY == 0
								Aadd(aStruAux,{aStruct[nW,1],aStruct[nW,2],aStruct[nW,3],aStruct[nW,4]})
							EndIf
						EndIf
					Next nW				
				EndIf
			Next nX

			aStruct := aClone(aStruAux)                                                                          
			
			If Empty(aStruct)
				lRetorno := .F.                                      
				SetSoapFault("GetTable",STR0004)//"Lista de Campos Invalida"
			EndIf
		EndIf
		
		If lRetorno
			::Table:TableStruct:= {}
			
			dbSelectArea(::Alias)
			For nX := 1 To Len(aStruct)
				aadd(::Table:TableStruct,WsClassNew("FieldStruct"))
				::Table:TableStruct[nX]:FldName := aStruct[nX][1]
				::Table:TableStruct[nX]:FldType := aStruct[nX][2]
				::Table:TableStruct[nX]:FldSize := aStruct[nX][3]
				::Table:TableStruct[nX]:FldDec  := aStruct[nX][4]
			Next nX
			//������������������������������������������������������������������������Ŀ
			//�Montagem da estrutura                                                   �
			//��������������������������������������������������������������������������
			cCurSor := ::Alias
			dbSelectArea(::Alias)
			dbSetOrder(1)
			#IFDEF TOP       
				If TcSrvType() <> "AS/400"
					lQuery  := .T.
					cCursor := "GETTABLES"
					
					cQuery	:= "SELECT "                      
	
					If Empty(::ListFieldsView)	//Lista todos os campos da tabela
						cQuery  += " * "
					Else						//Lista somente os campos informados pelo operador.
						cQuery	+= ::ListFieldsView+" "
					EndIf
	
					cQuery  += "FROM "+RetSqlName(::Alias)+" "
					cQuery  += "WHERE "                
	
					If lEmpytFil
						cQuery  += cCpoFil+"='"+xFilial(::Alias)+"' "
					Else                                           
						::Branch := StrTran(::Branch,'"',"'")
					    cQuery	+= cCpoFil+" in ("+::Branch+") "
					EndIf
	
					cQuery  := WsQueryAdd(cQuery,::QueryAddWhere)
					cQuery  += "AND D_E_L_E_T_=' ' "
					
					cQuery := ChangeQuery(cQuery)
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor)
					
					For nX := 1 To Len(aStruct)
						If aStruct[nX][2] <> "C"
							TcSetField(cCursor,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
						EndIf
					Next nX			
				EndIf
			#ENDIF  
			
			If !lQuery                                     
				cArquivo := CriaTrab( , .F. ) 
				If lEmpytFil				
					cQuery := cCpoFil+" == '" + xFilial(::Alias) + "' " 
				Else                                     
					::Branch := StrTran(::Branch,'"','')
					::Branch := StrTran(::Branch,"'",'')
					cQuery := cCpoFil+" $ ('" +::Branch+ "') "
				EndIf                                                                       
				
				//������������������������������������������������������������������������Ŀ
				//�Minimizando problemas com operadores utilizadas tanto em ambiente Top   �
				//�quanto em codebase, porem que normalmente nao deve acontecer.           �				
				//��������������������������������������������������������������������������
                If !Empty(::QueryAddWhere)  
                	::QueryAddWhere := StrTran(::QueryAddWhere,"AND"	,".AND.")
                	::QueryAddWhere := StrTran(::QueryAddWhere,"OR"	,".OR."	)
                	::QueryAddWhere := StrTran(::QueryAddWhere,">="	,">@"	)
                	::QueryAddWhere := StrTran(::QueryAddWhere,"<="	,"<@"	)
                	::QueryAddWhere := StrTran(::QueryAddWhere,"!="	,"!@"	)
                	::QueryAddWhere := StrTran(::QueryAddWhere,"="		,"=="	)
                	::QueryAddWhere := StrTran(::QueryAddWhere,"@"		,"="	)
                	cQuery += ".AND. "+ ::QueryAddWhere
                EndIf         
				IndRegua(cCurSor,cArquivo,(cCurSor)->(IndexKey()),,cQuery)
				(cCursor)->(DbGotop())
			EndIf			

			nX := 0
			While (cCurSor)->( !Eof() )
				aadd(::Table:TableData,WsClassNew("FieldView"))
				nX++
				::Table:TableData[nX]:FldTag := {}
				For nY := 1 To Len(aStruct)
					Do Case
						Case aStruct[nY][2] == "N"
							aadd(::Table:TableData[nX]:FldTag,Str((cCursor)->(FieldGet(FieldPos(aStruct[nY][1]))),aStruct[nY,3],aStruct[nY,4]))
						Case aStruct[nY][2] == "D"
							aadd(::Table:TableData[nX]:FldTag,Dtos((cCursor)->(FieldGet(FieldPos(aStruct[nY][1])))))
						OtherWise
							aadd(::Table:TableData[nX]:FldTag,(cCursor)->(FieldGet(FieldPos(aStruct[nY][1]))))
					EndCase		
				Next nY
				
				dbSelectArea(cCursor)
				dbSkip()
			EndDo
			If lQuery
				dbSelectArea(cCursor)
				dbCloseArea()
				dbSelectArea(::Alias)		
			Else
				RetIndex(::Alias)
				FErase(cArquivo+OrdBagExt())
			EndIf
		EndIf
	Else
		lRetorno := .F.
		SetSoapFault("GetTable",STR0003)	 //"Tabela nao encontrada"
	EndIf
Else
	lRetorno := .F.
EndIf       

If lRetorno .And. Empty(::Table:TableData)
	lRetorno := .F.
	SetSoapFault("GetTable",STR0005) //"Nao existem registros para esta consulta"
EndIf

RestArea(aAreaSX3)
RestArea(aArea)
Return(lRetorno)

Function wscfgtable()
Return
