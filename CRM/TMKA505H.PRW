#INCLUDE "PROTHEUS.CH"

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Programa  �TSTableStructureTop  �Autor �Michel Mosca     � Data �  01/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     |Classe que contempla as rotina de acesso a banco de dados Top      ��� 
���          �                                                                   ���
��������������������������������������������������������������������������������͹��
���Uso       � MP10                                                              ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������     
*/
Class TSTableStructureTop From PersistTSTableStructure

Method new() Constructor 
Method load(obj, keyInfo) 
Method loadMaster(obj, keyInfo) 
Method loadDetail(obj, keyInfo) 
Method TCSetField(cAlias, aSelFields)

EndClass
            
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Michel W. Mosca  � Data �  01/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class TSTableStructureTop     
Return Self     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOAD      �Autor  �Michel W. Mosca     � Data �  01/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method load(obj, keyInfo) Class TSTableStructureTop  
Local lRet := .F.  

lRet := Self:loadMaster(obj, keyInfo)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOADMASTER�Autor  �Michel W. Mosca     � Data �  22/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega os dados da tabela master.                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method loadMaster(obj, keyInfo) Class TSTableStructureTop  
Local lRet := .T.         		//Retorno da funcao
Local cAlias :=	GetNextAlias() 	//Alias para acesso ao banco de dados
Local cFields := ""				//Campos da tabela a serem selecionados
Local nCount  	:= 0 				//Contador utilizado em loop for
Local cWhere  := ""				//Condicoes da query
Local oField					//Objeto do tipo campo
Local aSelFields := {}			//Campos inseridos na sele��o da query
                   
For nCount := 1 To Len(obj:master:fields)
	If obj:master:fields[nCount]:context <> "V"
		cFields += "MASTER." + obj:master:fields[nCount]:name + ","
		aAdd(aSelFields,obj:master:fields[nCount]) 
	EndIf
Next nCount        
cFields := SubStr(cFields,1,Len(cFields)-1)

//Adiciona o delete
cWhere := " MASTER.D_E_L_E_T_ = ' ' AND"           

//Adiciona as condicoes da query
For nCount := 1 To Len(keyInfo)
	oField := keyInfo[nCount]                                                  
	cWhere += " MASTER." + oField + " = '" + Eval(&("{||" + obj:master:alias + "->" + oField + "}")) + "' AND" 
	//cWhere += " MASTER." + oField:name + " = '" + oField:value:value + "' AND"
Next nCount                                        
cWhere := SubStr(cWhere,1,Len(cWhere)-3)

//Monta a query
cQuery := 	"SELECT " + cFields +;
			" FROM " + RetSqlName(obj:master:alias) + " MASTER " +;
			"WHERE " + cWhere

//Adiciona os campos da chave primaria
If Len(obj:master:pkFields) > 0
	cQuery += " ORDER BY "
EndIf
For nCount := 1 To Len(obj:master:pkFields)
	cQuery += obj:master:pkFields[nCount]:name + ","
Next nCount  
cQuery := SubStr(cQuery, 1, Len(cQuery)-1)

cQuery	:= ChangeQuery(cQuery)
MemoWrite("TMKA505H_M.SQL", cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
Self:TCSetField(cAlias, aSelFields)

If (cAlias)->(!EOF())
	Self:fillMaster(obj, cAlias)
	Self:loadDetail(obj, keyInfo, cAlias)
Else
	lRet := .F.
EndIF

DbSelectArea(cAlias)
DbCloseArea()            

Return lRet



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOADDETAIL�Autor  �Michel W. Mosca     � Data �  22/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega os dados da tabela detalhes.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method loadDetail(obj, keyInfo, cMasterAlias) Class TSTableStructureTop  
Local lRet := .T.         		//Retorno da funcao
Local cAlias :=	GetNextAlias() 	//Alias para acesso ao banco de dados
Local cFields := ""				//Campos da tabela a serem selecionados
Local nCount  := 0 				//Contador utilizado em loop for
Local nCountRel := 0 			//Contador utilizado em loop
Local cWhere  := ""				//Condicoes da query
Local oBranch					//Armazena a filial da tabela
Local oField					//Objeto do tipo campo         
Local aSelFields := {}			//Campos inseridos na sele��o da query
                   
For nCount := 1 To Len(obj:detail:fields)
	cFields += "DETAIL." + obj:detail:fields[nCount]:name + ","
	aAdd(aSelFields,obj:detail:fields[nCount])
Next nCount    
cFields +=  "DETAIL.R_E_C_N_O_,"              
cFields := SubStr(cFields,1,Len(cFields)-1)

//Adiciona o delete
cWhere := " DETAIL.D_E_L_E_T_ = ' ' AND"           

//Adiciona a relacao com a tabela master
For nCount := 1 To Len(obj:aRelations)
	cWhere += " DETAIL." + obj:aRelations[nCount]:detail:name + " = '" + Eval(&("{||" + cMasterAlias + "->" + obj:aRelations[nCount]:master:name + "}")) + "' AND" 	
Next nCount
cWhere := SubStr(cWhere,1,Len(cWhere)-3)

//Monta a query
cQuery := 	"SELECT " + cFields +;
			" FROM " + RetSqlName(obj:detail:alias) + " DETAIL " +;
			"WHERE " + cWhere
                       
//Adiciona os campos da chave primaria
If Len(obj:detail:pkFields) > 0
	cQuery += " ORDER BY "
EndIf
For nCount := 1 To Len(obj:detail:pkFields)
	cQuery += obj:detail:pkFields[nCount]:name + ","
Next nCount  
cQuery := SubStr(cQuery, 1, Len(cQuery)-1)

cQuery	:= ChangeQuery(cQuery)
MemoWrite("TMKA505H_D.SQL", cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.) 
Self:TCSetField(cAlias, aSelFields)

If (cAlias)->(!EOF())
	Self:fillDetail(obj, cAlias)
Else
	lRet := .F.
EndIF

DbSelectArea(cAlias)
DbCloseArea() 
Return lRet                  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TCSetField�Autor  �Michel W. Mosca     � Data �  24/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define os tipos de campos para o TOP Connect.               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TCSetField(cAlias, aSelFields) Class TSTableStructureTop    
Local nCount := 0		//Contador utilizado em loop

For nCount := 1 To Len(aSelFields)     
	If aSelFields[nCount]:value:dataType == 4
		TCSetField(cAlias, aSelFields[nCount]:name,	'D')
	EndIf                                    
	If aSelFields[nCount]:value:dataType == 2
		TCSetField(cAlias, aSelFields[nCount]:name,	'N',aSelFields[nCount]:value:size, aSelFields[nCount]:value:decimal)
	EndIf                                    	
	If aSelFields[nCount]:value:dataType == 3
		TCSetField(cAlias, aSelFields[nCount]:name,	'L')
	EndIf                                    		
Next nCount	
Return Nil

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
FUNCTION _TMKA505H()
RETURN NIL
