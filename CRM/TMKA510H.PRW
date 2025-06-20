#INCLUDE "PROTHEUS.CH"     
#INCLUDE "TMKA510H.CH"

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �HelpDeskHist          �Autor� Vendas Clientes � Data �  10/02/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     |Interface de usuario para exibir o historico de chamados help desk.��� 
���          �                                                                   ���
��������������������������������������������������������������������������������͹��
���Uso       � MP10                                                              ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������     
*/
Class HelpDeskHist From HelpDeskFindCalls 
Data tipHistory

Method New() Constructor 
Method Find(oRelBrowse, aFields) 
EndClass 
             
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New          �Autor  � Vendas Clientes � Data �  10/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class HelpDeskHist 
Self:lFinding 	:= .F.
Self:lStop		:= .F.   
Self:cSelCall	:= ""
Self:isHistory 	:= .T.
Self:tipHistory := 1
Self:cStr1 		:= STR0001 // "Hist�rico de atendimento"
Self:cStr2 		:= ""
Self:cStr3 		:= STR0002 // "N�o foi selecionado um chamado para ser iniciado o atendimento."

//������������������������������������������������������������������������������Ŀ
//�Pergunte - TMK510HI                                                           �
//�MV_PAR01 - De                                                        		 �
//�MV_PAR02 - Ate                                                                �
//�MV_PAR03 - Do Chamado                                                         �
//�MV_PAR04 - Ate o chamado                                                      �
//�MV_PAR05 - Status do chamado                                                  �
//�MV_PAR06 - Do Cliente                                                         �
//�MV_PAR07 - Da Loja                                                            �	
//�MV_PAR08 - Ate o Cliente                                                      �
//�MV_PAR09 - Ate a Loja                                                         �	
//��������������������������������������������������������������������������������	
Self:cPergunte	:= "TMK510HI" 

Return Self  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Find         �Autor  � Vendas Clientes � Data �  10/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza procura por chamados que atendam ao criterio de     ���
���          �busca.                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Find(oRelBrowse, aFields) Class HelpDeskHist 
Local cQuery := ""  
Local aArea := GetArea()
Local cWhere		:= ""
Local cCodContact	:= ""						//Codigo do contato
Local cEntityName	:= ""  						//Nome da Entidade 
										
Default aFields := {}

Self:cKeyWords := AllTrim(Self:cKeyWords)

If Self:tipHistory == 1
	cCodContact	:= M->ADE_CODCON											
	cEntityName	:= M->ADE_ENTIDA	
EndIf

If Empty(cCodContact) .AND. Self:tipHistory == 1
	MsgAlert(STR0003,STR0004) //"Por favor, selecione um contato"###"Atencao"
	Return(.F.)
Else

	Self:lFinding 	:= .T.
	DbSelectArea("ADE")
	DbSetOrder(1)
	
	//������������������������������������������������������������������������������Ŀ
	//�Pergunte - TMK510H                                                            �
	//�MV_PAR01 - De                                                        		 �
	//�MV_PAR02 - Ate                                                                �
	//�MV_PAR03 - Do Chamado                                                         �
	//�MV_PAR04 - Ate o chamado                                                      �
	//�MV_PAR05 - Status do chamado                                                  �
	//�MV_PAR06 - Exibir hist�rico de ?                                              �
	//��������������������������������������������������������������������������������		
	
	//������������������������������������������������������������������������������Ŀ
	//�Pergunte - TMK510HI                                                           �
	//�MV_PAR01 - De                                                        		 �
	//�MV_PAR02 - Ate                                                                �
	//�MV_PAR03 - Do Chamado                                                         �
	//�MV_PAR04 - Ate o chamado                                                      �
	//�MV_PAR05 - Status do chamado                                                  �
	//�MV_PAR06 - Do Cliente                                                         �
	//�MV_PAR07 - Da Loja                                                            �	
	//�MV_PAR08 - Ate o Cliente                                                      �
	//�MV_PAR09 - Ate a Loja                                                         �
	//��������������������������������������������������������������������������������		

	If ValType(MV_PAR05) == "N"
		MV_PAR05 := cValToChar(MV_PAR05)
	EndIf
	If ValType(MV_PAR06) == "N"
		MV_PAR06 := cValToChar(MV_PAR06)
	EndIf
	
	#IFDEF TOP		
		cQuery := "	SELECT "		
		cQuery += "	ADE.ADE_FILIAL,	ADE.ADE_CODSB1,	ADE.ADE_ENTIDA,		ADE.ADE_CHAVE, "
		cQuery += "	ADE.ADE_CODIGO,	ADE.ADE_DATA,	ADE.ADE_SEVCOD,		ADE.ADE_CODINC, "
		cQuery += "	ADE.ADE_DATA,	ADE.ADE_STATUS,	ADE.ADE_DTEXPI,		ADE.ADE_OPERAD  "
		cQuery += "	FROM " + RetSQLName("ADE") + " ADE"
		
		If !Empty(Self:cKeyWords)
			cQuery += " INNER JOIN " + RetSQLName("SYP") + " SYP ON ADE.ADE_CODINC = SYP.YP_CHAVE AND SYP.D_E_L_E_T_ = ''"
		EndIf		
		
		cWhere += "	WHERE ADE.ADE_FILIAL = '" + xFilial("ADE") + "' AND" 

		cWhere += "	ADE.ADE_DATA BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' AND"		
		cWhere += " ADE.ADE_CODIGO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND"				
		
		If Val(MV_PAR05) < 4                                              
			cWhere += " ADE.ADE_STATUS = '" + AllTrim(MV_PAR05) + "' AND"					
		EndIf
		
		If !Empty(Self:cProduto)
			cWhere += "	ADE.ADE_CODSB1 = '" + Self:cProduto + "' AND"
		EndIf

		If !Empty(Self:cGroup)
			cWhere += "	ADE.ADE_GRUPO = '" + Self:cGroup + "' AND"
		EndIf	

		If Self:tipHistory == 1
			If Val(MV_PAR06) == 1 //Contato
				cWhere += " ADE.ADE_CODCON = '" + M->ADE_CODCON + "' AND"
			ElseIf Val(MV_PAR06) == 2	//Entidade                       
				cWhere += " ADE.ADE_ENTIDA = '" + M->ADE_ENTIDA + "' AND"		
				cWhere += " ADE.ADE_CHAVE  = '" + M->ADE_CHAVE + "' AND"			
			EndIf   
		Else
			cWhere += " ADE.ADE_CHAVE  BETWEEN '" + MV_PAR06+MV_PAR07 + "' AND '" + MV_PAR08+MV_PAR09 + "' AND"			
			cWhere += " ADE.ADE_ENTIDA = 'SA1' AND"		
		EndIf
		
		If !Empty(Self:cKeyWords)
			cWhere += " SYP.YP_FILIAL = '"+xFilial("SYP")+"' AND (UPPER(SYP.YP_TEXTO) LIKE '%" + Upper(Self:cKeyWords) + "%' OR UPPER(ADE.ADE_PLVCHV) LIKE '%" + Upper(Self:cKeyWords) + "%') AND"
		EndIf
	
		cWhere += "	ADE.D_E_L_E_T_ = ' '"  
		cQuery += cWhere		
		cQuery += "	ORDER BY " + SqlOrder(IndexKey())
		
		cQuery := ChangeQuery(cQuery)
	
		DbSelectArea("ADE")
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "ADE", .F., .T.)			
		
		TCSetField("ADE", "ADE_DTEXPI"	, "D")
		TCSetField("ADE", "ADE_DATA"	, "D")				
	#ELSE       
		DbSelectArea("ADE")
		DbSetOrder(3) //ADE_FILIAL+ ADE_GRUPO		
		DbSeek(xFilial("ADE")+Self:cPosto)	
		nTot := RecCount()
	#ENDIF
	                 
	IncProc(STR0005) // "Criando lista de chamados..."	        
	Self:FillData("ADE", @aFields, @oRelBrowse)
			                            	
	DbSelectArea("ADE")
	DbCloseArea()	
	
	Self:lFinding 	:= .F.
	Self:lStop		:= .F.                      
	
	RestArea(aArea)
EndIf
Return Nil          

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKA510H � Autor � IP - Vendas Clientes  � Data � 29/07/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe a tela de historico do atendimento Help Desk         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MP10                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKA510H(lViewOnly)
 
Local oObj := Nil
Local cPergunte := "TMK510H"  
Local cCodContact	:= M->ADE_CODCON											//Codigo do contato

SaveInter()
             
oObj := HelpDeskHist():New() 

Default lViewOnly := .T.

//������������������������������������������������������������������������������Ŀ
//�Pergunte - TMK510H                                                            �
//�MV_PAR01 - De                                                        		 �
//�MV_PAR02 - Ate                                                                �
//�MV_PAR03 - Do Chamado                                                         �
//�MV_PAR04 - Ate o chamado                                                      �
//�MV_PAR05 - Status do chamado                                                  �
//�MV_PAR06 - Exibir hist�rico de ?                                              �
//��������������������������������������������������������������������������������	
oObj:cPergunte := cPergunte

If Empty(cCodContact)
	MsgAlert(STR0006,STR0004) //"Por favor, selecione um contato"###"Atencao"
	Return(.F.)
Else
	oObj:lViewOnly := lViewOnly
	If oObj:showDialog()
		aAdd(ParamIXB[1], "ADE")
		aAdd(ParamIXB[1], 1)		
		aAdd(ParamIXB[1], xFilial("ADE")+oObj:cSelCall)	
	EndIf
EndIf

RestInter()

Return .F.   


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKA510HI� Autor � IP - Vendas Clientes  � Data � 29/07/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe a tela de historico do atendimento Help Desk         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MP10                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKA510HI(lViewOnly)
 
Local oObj := Nil

SaveInter()

oObj := HelpDeskHist():New()
                      
If Type("aCols")=="U"
	Private aCols := {}
EndIf

If Type("aHeader")=="U"
	Private aHeader := {}
EndIf

Default lViewOnly := .T.

oObj:lViewOnly := lViewOnly 
oObj:tipHistory	:= 2
oObj:showDialog()
                
RestInter()

Return .F.  