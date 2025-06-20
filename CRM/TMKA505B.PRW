#INCLUDE "PROTHEUS.CH"

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Programa  �TeleServicingTop     �Autor �Michel Mosca     � Data �  01/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     |Classe que contempla as rotina de acesso a banco de dados Top      ��� 
���          �                                                                   ���
��������������������������������������������������������������������������������͹��
���Uso       � MP10                                                              ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������     
*/
Class TeleServicingTop From PersistTeleServicing

Method new() Constructor 
Method load(obj)
Method loadHistory(Obj, nType)
Method loadHistDetail(oObj, cCodMaster)

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
Method new() Class TeleServicingTop     
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
Method load(obj) Class TeleServicingTop  
Local lRet := .T.         
Local cAlias :=	GetNextAlias() 

If cPaisLoc <> "BRA"    
	
	Do Case
	 
		Case cPaisLoc $ "ARG|BOL|CHI|COL|COS|DOM|MEX|PAN|PAR|PER|POR|SAL|URU|VEN"
			
			BeginSQL alias cAlias
				SELECT 	KA_FILIAL,	KA_CODIGO, 		KA_NOMESPA, KA_ALIMAST, 
						KA_ALIDET,	KA_ABRTELA, 	KA_CONTSEL,	KA_ANTGRAV, 
						KA_APOGRAV, KA_ENCTELA, 	KA_PEBTNOK, KA_PEHIST,
						KA_CPCONT,	KA_CPNMENT,		KA_CPCHAVE,	KA_CPIDXCH,
						KA_PEGDIT,	KA_CPGDINI,		KA_CMPKEY,	KA_OPCODI,
						KA_REGCOD
					
				FROM	%table:SKA% SKA 
						WHERE	SKA.KA_FILIAL = %xFilial:SKA% AND 	
						SKA.%NOTDEL% AND
						SKA.KA_CODIGO = %EXP:obj:id%
			EndSql
			   
		Case cPaisLoc $ "EUA" 
		
			BeginSQL alias cAlias
				SELECT 	KA_FILIAL,	KA_CODIGO, 		KA_NOMEENG, KA_ALIMAST, 
						KA_ALIDET,	KA_ABRTELA, 	KA_CONTSEL,	KA_ANTGRAV, 
						KA_APOGRAV, KA_ENCTELA, 	KA_PEBTNOK, KA_PEHIST,
						KA_CPCONT,	KA_CPNMENT,		KA_CPCHAVE,	KA_CPIDXCH,
						KA_PEGDIT,	KA_CPGDINI,		KA_CMPKEY,	KA_OPCODI,
						KA_REGCOD
					
				FROM	%table:SKA% SKA 
						WHERE	SKA.KA_FILIAL = %xFilial:SKA% AND 	
						SKA.%NOTDEL% AND
						SKA.KA_CODIGO = %EXP:obj:id%
			EndSql
			   	
		Case cPaisLoc $ "ANG|EQU|HAI|PTG"
			
			BeginSQL alias cAlias
				SELECT 	KA_FILIAL,	KA_CODIGO, 		KA_NOMEPTG, KA_ALIMAST, 
						KA_ALIDET,	KA_ABRTELA, 	KA_CONTSEL,	KA_ANTGRAV, 
						KA_APOGRAV, KA_ENCTELA, 	KA_PEBTNOK, KA_PEHIST,
						KA_CPCONT,	KA_CPNMENT,		KA_CPCHAVE,	KA_CPIDXCH,
						KA_PEGDIT,	KA_CPGDINI,		KA_CMPKEY,	KA_OPCODI,
						KA_REGCOD
					
				FROM	%table:SKA% SKA 
						WHERE	SKA.KA_FILIAL = %xFilial:SKA% AND 	
						SKA.%NOTDEL% AND
						SKA.KA_CODIGO = %EXP:obj:id%
			EndSql
			   
   		EndCase 
	
Else
	
	BeginSQL alias cAlias
		SELECT 	KA_FILIAL,	KA_CODIGO, 		KA_NOME, 	KA_ALIMAST, 
				KA_ALIDET,	KA_ABRTELA, 	KA_CONTSEL,	KA_ANTGRAV, 
				KA_APOGRAV, KA_ENCTELA, 	KA_PEBTNOK, KA_PEHIST,
				KA_CPCONT,	KA_CPNMENT,		KA_CPCHAVE,	KA_CPIDXCH,
				KA_PEGDIT,	KA_CPGDINI,		KA_CMPKEY,	KA_OPCODI,
				KA_REGCOD
					
		FROM	%table:SKA% SKA 
		WHERE	SKA.KA_FILIAL = %xFilial:SKA% AND 	
				SKA.%NOTDEL% AND
				SKA.KA_CODIGO = %EXP:obj:id%
	EndSql                                  
	                                  
EndIf

If (cAlias)->(!EOF())
	Self:fillClass(obj, cAlias)
	DbSelectArea(cAlias)
	DbCloseArea()     
	BeginSQL alias cAlias
		SELECT 	KB_FILIAL,	KB_CODTELE,	KB_CPOMAST,	KB_CPODET, KB_CODIGO 					
		FROM	%table:SKB% SKB 
		WHERE	SKB.KB_FILIAL = %xFilial:SKB% AND 	
				SKB.%NOTDEL% AND
				SKB.KB_CODTELE = %EXP:obj:id%
	EndSql                                  	
	Self:fillRelations(obj, cAlias)	
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
���Programa  �loadHistor�Autor  �Vendas Clientes     � Data �  07/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que carrega os dados do Historico do Modelo de      ���
���          � Atendimento (Top).                                         ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method loadHistory(Obj, nType) Class TeleServicingTop
Local cContactField := Obj:contactField:name			//Nome do campo de Contato 
Local cEntityField := Obj:entityName:name				//Nome do campo da Entidade
Local cEntityKey := Obj:entityKey:name					//Nome do campo Valor da Entidade
Local cCodContact	:= M->&(cContactField)				//Codigo do contato        
Local cCodEntity	:= M->&(cEntityField)				//Codigo da Entidade
Local cCodEntKey	:= M->&(cEntityKey)					//Valor da Entidade
Local cAliasMaster	:= Obj:master:alias					//Alias da tabela Master
Local cCpoFilial	:= Obj:master:BranchField:name		//Nome do campo Filial na tab. Master
Local cFields		:= ""								//Campos da query
Local aMaster 		:= {}								//Array de retorno dos dados resultantes da query
Local aSelFields	:= {}								//Array com os campos usados na query
Local cAlias 		:= GetNextAlias() 					//Alias temporario usado na query
Local nFields		:= 0
Local nCount		:= 0

For nCount := 1 To Len(Obj:master:fields)
	cFields += "MASTER." + Obj:master:fields[nCount]:name + ","
	aAdd(aSelFields, Obj:master:fields[nCount]) 
Next nCount
cFields := SubStr(cFields,1,Len(cFields)-1)

//Adiciona as condicoes da query
cWhere := " MASTER.D_E_L_E_T_ = ' ' AND"
cWhere += " MASTER." + cCpoFilial + " = '" + xFilial(cAliasMaster) + "' AND" 
If nType == 1
	cWhere += " MASTER." + cContactField + " = '" + cCodContact + "' AND" 
Else
	cWhere += " MASTER." + cEntityField + " = '" + cCodEntity + "' AND" 
	cWhere += " MASTER." + cEntityKey + " = '" + cCodEntKey + "' AND" 	
EndIf
cWhere := SubStr(cWhere,1,Len(cWhere)-3)

//Monta a query
cQuery := 	"SELECT " + cFields +;
			" FROM " + RetSqlName(cAliasMaster) + " MASTER " +;
			"WHERE " + cWhere

//Adiciona os campos da chave primaria
If Len(Obj:master:pkFields) > 0
	cQuery += " ORDER BY "
EndIf
For nCount := 1 To Len(Obj:master:pkFields)
	cQuery += Obj:master:pkFields[nCount]:name + ","
Next nCount  
cQuery := SubStr(cQuery, 1, Len(cQuery)-1)

cQuery	:= ChangeQuery(cQuery)
MemoWrite("TMKA505B_M.SQL", cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

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

//��������������������������������������������������Ŀ
//� Prepara o array aMaster com o resultado da query �
//����������������������������������������������������
nLin	:= 0
While (cAlias)->(!Eof())

	aAdd(aMaster, Array( Len(aSelFields) ) )
	nLin := Len(aMaster)
	
	For nFields := 1 To Len(aSelFields)
		aMaster[nLin][nFields] := (cAlias)->&(aSelFields[nFields]:name)
    Next nFields
    
	(cAlias)->(DbSkip())
End
     
DbSelectArea(cAlias)
DbCloseArea() 
Return aMaster


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �loadHistDe�Autor  �Vendas Clientes     � Data �  12/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que carrega os dados da tabela detalhe do Historico ���
���          � de Atendimento (Top)                                       ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method loadHistDetail(oObj, cCodMaster) Class TeleServicingTop
Local cAliasDetail	:= oObj:service:tableStructureInfo:detail:alias				//Alias da tabela Detail
Local cCpoFilial	:= oObj:service:tableStructureInfo:detail:BranchField:name	//Nome do campo Filial
Local cAlias		:= GetNextAlias() 											//Alias da query
Local cFields		:= ""														//Armazena os campos da query
Local aSelFields	:= {}														//Array com os campos usados na query
Local nCount		:= 0
Local nFields			:= 0

For nCount := 1 To Len(oObj:service:tableStructureInfo:detail:fields)
	cFields += "DETAIL." + oObj:service:tableStructureInfo:detail:fields[nCount]:name + ","
	aAdd(aSelFields,oObj:service:tableStructureInfo:detail:fields[nCount]) 
Next nCount
cFields := SubStr(cFields,1,Len(cFields)-1)

//Pega o nome do campo p/ usar na comparacao com o codigo do chamado da tab. master
cCodField := oObj:service:tableStructureInfo:detail:fields[2]:name

//Adiciona as condicoes da query
cWhere := " DETAIL.D_E_L_E_T_ = ' ' AND"
cWhere += " DETAIL." + cCpoFilial + " = '" + xFilial(cAliasDetail) + "' AND" 
cWhere += " DETAIL." + cCodField + " = '" + cCodMaster + "' AND"
cWhere := SubStr(cWhere,1,Len(cWhere)-3)

//Monta a query
cQuery := 	"SELECT " + cFields +;
			" FROM " + RetSqlName(cAliasDetail) + " DETAIL " +;
			"WHERE " + cWhere

//Adiciona os campos da chave primaria
If Len(oObj:service:tableStructureInfo:detail:pkFields) > 0
	cQuery += " ORDER BY "
EndIf
For nCount := 1 To Len(oObj:service:tableStructureInfo:detail:pkFields)
	cQuery += oObj:service:tableStructureInfo:detail:pkFields[nCount]:name + ","
Next nCount 
cQuery := SubStr(cQuery,1,Len(cQuery)-1)
cQuery	:= ChangeQuery(cQuery)

MemoWrite("TMKA505B_D.SQL", cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

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

//��������������������������������������������������Ŀ
//� Prepara o array aDetail com o resultado da query �
//����������������������������������������������������
aDetail := {}
nLin := 0
While (cAlias)->(!Eof())

	aAdd(aDetail, Array( Len(aSelFields) ) )
	nLin := Len(aDetail)
	
	For nFields := 1 To Len(aSelFields)
		aDetail[nLin][nFields] := (cAlias)->&(aSelFields[nFields]:name)
    Next nFields
    
	(cAlias)->(DbSkip())
End 

DbSelectArea(cAlias)
DbCloseArea() 
Return aDetail


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
FUNCTION _TMKA505B()
RETURN NIL
