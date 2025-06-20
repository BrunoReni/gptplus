#INCLUDE "PROTHEUS.CH"

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Programa  �TSTableStructureCodebase�Autor �Michel Mosca  � Data �  31/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     |Classe que contempla as rotina de acesso a banco de dados Codebase.��� 
���          �                                                                   ���
��������������������������������������������������������������������������������͹��
���Uso       � MP10                                                              ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������     
*/
Class TSTableStructureCodebase From PersistTSTableStructure

Method new() Constructor 
Method load(obj, keyInfo) 
Method loadMaster(obj, keyInfo) 
Method loadDetail(obj, keyInfo) 


EndClass
            
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Michel W. Mosca  � Data �  31/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class TSTableStructureCodebase     
Return Self     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOAD      �Autor  �Michel W. Mosca     � Data �  31/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method load(obj, keyInfo) Class TSTableStructureCodebase  
Local lRet := .F.  

lRet := Self:loadMaster(obj, keyInfo)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOADMASTER�Autor  �Michel W. Mosca     � Data �  31/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega os dados da tabela master.                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method loadMaster(obj, keyInfo) Class TSTableStructureCodebase  
Local lRet 			:= .T. 		//Retorno da funcao
Local cAlias 	 				//Alias para acesso ao banco de dados
Local nCount  		:= 0		//Contador utilizado em loop for
Local nCountFields 	:= 0		//Contador utilizado no loop varrendo campos da selecao
Local cWhere  		:= ""		//Condicoes da query               
Local cValue 		:= ""      	//Valor do parametro recebido
Local cSeek 		:= ""
Local oField					//Objeto do tipo campo

//Adiciona o alias da tabela                              
cAlias := obj:master:alias 

//Adiciona as condicoes da query
For nCount := 1 To Len(keyInfo)
	oField := keyInfo[nCount]	
	cWhere += cAlias + "->" + oField + " == '" + Eval(&("{||" + obj:master:alias + "->" + oField + "}")) + "' .AND."
	//cWhere += cAlias + "->" + oField:name + " == '" + oField:value:value + "' .AND."
Next nCount                                        
cWhere := SubStr(cWhere,1,Len(cWhere)-5)

//Adiciona os campos da chave primaria
For nCount := 1 To Len(obj:master:pkFields)
	cValue := Space(obj:master:pkFields[nCount]:value:size)	
	For nCountFields := 1 To Len(keyInfo)
		oField := keyInfo[nCountFields]
		//If AllTrim(oField:name) == AllTrim(obj:master:pkFields[nCount]:name)
		If AllTrim(oField) == AllTrim(obj:master:pkFields[nCount]:name)
			//cValue := oField:value:value		
			cValue := Eval(&("{||" + obj:master:alias + "->" + oField + "}"))		
			Exit
		EndIf		
	Next nCountFields 
	cSeek += cValue	
Next nCount  


DbSelectArea(cAlias)
DbSetOrder(obj:master:iIdx) 
If DbSeek(RTrim(cSeek))
	If Eval(&("{||" + cWhere + "}"))
		Self:fillMaster(obj, cAlias)
		Self:loadDetail(obj, keyInfo, cAlias)
	Else
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIF

Return lRet



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOADDETAIL�Autor  �Michel W. Mosca     � Data �  31/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega os dados da tabela detalhes.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method loadDetail(obj, keyInfo, cMasterAlias) Class TSTableStructureCodebase  
Local lRet := .T.         		//Retorno da funcao
Local cAlias :=	GetNextAlias() 	//Alias para acesso ao banco de dados
Local cFields := ""				//Campos da tabela a serem selecionados
Local nCount  := 0 				//Contador utilizado em loop for
Local nCountRel := 0 			//Contador utilizado em loop
Local cWhere  := ""				//Condicoes da query
Local oBranch					//Armazena a filial da tabela
Local oField					//Objeto do tipo campo                 
Local aSelFields := {}			//Campos inseridos na sele��o da query
Local nCountFields 	:= 0		//Contador utilizado no loop varrendo campos da selecao
Local cValue 		:= ""      	//Valor do parametro recebido
Local cSeek 		:= ""

//Adiciona o alias da tabela                              
cAlias := obj:detail:alias 

//Adiciona a relacao com a tabela master
For nCount := 1 To Len(obj:aRelations)
	cWhere += cAlias + "->" + obj:aRelations[nCount]:detail:name + " == '" + Eval(&("{||" + cMasterAlias + "->" + obj:aRelations[nCount]:master:name + "}")) + "' .AND." 	
Next nCount
cWhere := SubStr(cWhere,1,Len(cWhere)-5)
                       
//Adiciona os campos da chave primaria
For nCount := 1 To Len(obj:detail:pkFields)
	cValue := Space(obj:detail:pkFields[nCount]:value:size)	
	//Verifica se n�o foi passado nenhum parametro pelo usuario
	For nCountFields := 1 To Len(keyInfo)
		oField := keyInfo[nCountFields]
		//If AllTrim(oField:name) == AllTrim(obj:detail:pkFields[nCount]:name)
		If AllTrim(oField) == AllTrim(obj:detail:pkFields[nCount]:name)
			//cValue := oField:value:value		
			cValue := Eval(&("{||" + cMasterAlias + "->" + oField + "}"))
			Exit
		EndIf		                                           		
	Next nCountFields                                          
	//Verifica se o campo pertence ao relacionamento de tabelas
	For nCountFields := 1 To Len(obj:aRelations)
		If AllTrim(obj:detail:pkFields[nCount]:name) == AllTrim(obj:aRelations[nCountFields]:detail:name)		
			cValue := Eval(&("{||" + cMasterAlias + "->" + obj:aRelations[nCountFields]:master:name + "}"))			
		EndIf
	Next nCountFields	
	cSeek += cValue	
Next nCount  

DbSelectArea(cAlias)
DbSetOrder(obj:master:iIdx) 
If DbSeek(RTrim(cSeek))
	Self:fillDetail(obj, cAlias, "{||" + cWhere + "}")
Else
	lRet := .F.
EndIF

Return lRet                  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_TMKA500      �Autor  �Michel W. Mosca � Data �  09/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                   
FUNCTION _TMKA505G()
RETURN NIL
