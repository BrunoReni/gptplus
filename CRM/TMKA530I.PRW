#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Classe    �SLARegisterCodebas�Autor: Vendas Clientes     �Data:08/01/08���
�������������������������������������������������������������������������͹��
���Desc.     �Classe que contempla as rotinas referentes a banco de dados ���
���          �CodeBase.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class SLARegisterCodebase From PersistSLARegister
Method new() Constructor
Method load(obj)

EndClass


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �new       �Autor  �Vendas Clientes     � Data �  19/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Construtor da classe SLARegisterCodebase                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class SLARegisterCodebase

Return Self


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �load      �Autor  �Vendas Clientes     � Data �  11/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �														      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method load(obj) Class SLARegisterCodebase
Local lRet 		:= .F.        	//Retorno da funcao
Local cAlias	:= "SK5" 		//Alias do arquivo
Local oEntity					//Objeto SLAEntity

DbSelectArea(cAlias)
DbSetOrder(1)
DbSeek(xFilial(cAlias)+obj:registerID)
While (cAlias)->(!Eof()) .AND.;
	xFilial(cAlias) == (cAlias)->K5_FILIAL .AND.;
	obj:registerID	== (cAlias)->K5_CODIGO	

	obj:registerID		:= (cAlias)->K5_CODIGO
	obj:item			:= (cAlias)->K5_ITEM
	obj:keyInfo			:= (cAlias)->K5_CHAVE
	//obj:details			:= (cAlias)->K5_OBS
	obj:createdDate		:= (cAlias)->K5_DATA
	obj:createdHour		:= (cAlias)->K5_HORA
	obj:dateToExpire	:= (cAlias)->K5_DTEXPIR
	obj:hourToExpire	:= (cAlias)->K5_HREXPIR
	obj:finishedDate	:= (cAlias)->K5_DTENCER
	obj:finishedHour	:= (cAlias)->K5_HRENCER	
	obj:previousCode	:= (cAlias)->K5_CODANT
	obj:updatedDate		:= (cAlias)->K5_DTATUA
	obj:updatedHour		:= (cAlias)->K5_HRATUA
	If TK510NewFields()
		obj:severityCode	:= Val((cAlias)->K5_SEVE)
	Else
		obj:severityCode	:= (cAlias)->K5_SEVERID
	EndIf
	obj:SlaFound		:= (cAlias)->K5_CODSLA
	obj:SlaResponsible	:= (cAlias)->K5_CODRESP
	obj:StatusRegister	:= (cAlias)->K5_STATUS
	obj:cbWhenDelayed	:= (cAlias)->K5_CODBLK
	obj:Paused			:= (cAlias)->K5_PAUSED
	obj:PausedTime		:= (cAlias)->K5_PAUSEDT
    lRet := .T.
    
    (cAlias)->(dbSkip())
End

If lRet
	DbSelectArea("SK7")
	DbSetOrder(2)	//K7_FILIAL+K7_CODSLA
	DbSeek(xFilial("SK7")+obj:SlaFound)
	While !Eof() .AND. SK7->K7_FILIAL == xFilial("SK7") .AND.;
						SK7->K7_CODSLA == obj:SlaFound
	    
		oEntity := SLAEntity():New()
		oEntity:entityName	:= SK7->K7_NOMEENT
		oEntity:entityValue	:= SK7->K7_CODENT
		aAdd(obj:entities, oEntity)	
		
		SK7->(DbSkip())
	End	
EndIf


Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_TMKA530I     �Autor  �Vendas Clientes � Data �  08/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION _TMKA530I()
RETURN NIL