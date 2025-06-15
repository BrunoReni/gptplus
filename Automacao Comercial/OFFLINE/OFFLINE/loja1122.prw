#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA1122()
Return NIL
/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Classe    �LJCGetTrans �Autor  �Vendas Clientes   � Data �  14/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Controla o numero da Transacao da Tabela de Entrada da     ���
���          � Integracao.                                                ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class LJCGetTrans
	Data cTabela				//Alias da Tabela de Entrada ou Saida
	Data cTrans					//Numero da proxima Transacao

	Method New(cTabela)			//Inicializa o Objeto
	Method SetTrans()			//Recupera a proxima Transacao a Partir da Tabela
	Method LockTrans()			//Reserva a proxima Transacao
	Method GetTrans()			//Retorna a Transacao
	Method FreeTrans()			//Libera a reserva da Transacao
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   � New      �Autor  �Vendas Clientes     � Data �  14/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Inicializa o Objeto                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(cTabela) Class LJCGetTrans
	::cTabela := cTabela
	
	//Verifica o Proximo Numero na Tabela
	::SetTrans()
	//Reserva o Numero
	::LockTrans()
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �SetTrans  �Autor  �Vendas Clientes     � Data �  14/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Recupera a proxima Transacao a Partir da Tabela MD8.       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SetTrans() Class LJCGetTrans
	Local cQuery	:= ""			   		//conte�do da query
	 
    
	//Seleciona a Area para cria-la caso nao exista
	DbSelectArea(::cTabela)

	//Recupera o Numero da Maior Transacao
    #IFDEF TOP	

		cQuery	:= "SELECT MAX(" + ::cTabela + "_TRANS) TRANS "
		cQuery	+= "FROM " + RetSqlName(::cTabela)
		cQuery	:= ChangeQuery(cQuery)
		dbUseArea(.T., "TopConn", TCGenQry(NIL, NIL, cQuery), "TRBTRS", .F., .F.)
	        
		//Verifica se existem registros na Tabela
		If Select("TRBTRS") > 0
			::cTrans := Soma1(TRBTRS->TRANS)
			TRBTRS->(DbCloseArea())
		Else
			::cTrans := StrZero(1, TamSX3(::cTabela + "_TRANS")[1])
		EndIf

	#ELSE                      

		cCampo  := ::cTabela + "_TRANS"
		nTamSX3 := TamSX3(cCampo)[1]
		cChave  := Replicate("9",nTamSX3)	
		
		//posiciona no ultimo registro	          	
		DbSetOrder(1)
		DbSeek(IncLast(xFilial(::cTabela)) + cChave ,.T.) 
		DbSkip(-1)
		                                        
		::cTrans := Soma1( &( (::cTabela)->(cCampo) ) )
                   		
		(::cTabela)->(DbCloseArea())
	#ENDIF			

	SetMaxCodes(100)
	While !MayIUseCode(::cTrans)  //verifica se esta na memoria, sendo usado
		::cTrans := Soma1(::cTrans)
	EndDo

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �LockTrans �Autor  �Vendas Clientes     � Data �  14/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Reserva a proxima Transacao.                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LockTrans() Class LJCGetTrans
    
    local cTab   //Nome da Tabela
	
    #IFDEF TOP               
    	cTab := RetSqlName(::cTabela)
    #ELSE
		cTab := RETFULLNAME(::cTabela)
    #ENDIF

	While !MayIUseCode(cTab + ::cTrans)
		//Incrementa a Transacao
		::cTrans := Soma1(::cTrans)
	End
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �GetTrans  �Autor  �Vendas Clientes     � Data �  14/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna a Transacao.                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetTrans() Class LJCGetTrans
Return ::cTrans

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �FreeTrans �Autor  �Vendas Clientes     � Data �  14/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Libera a reserva da Transacao.                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FreeTrans() Class LJCGetTrans
	FreeUsedCode()
	::cTrans := ""
Return Nil
	
