#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1130.CH"

Function LOJA1130()
	
	Local oManutInt := Nil
	
	//Estancia o objeto LJCManutRegIntegra
	oManutInt := LJCManutRegIntegra():New() 
	
	//Exibe a tela
	oManutInt:Show()

Return Nil

/* 
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������ͻ��
���Classe    �LJCManutRegIntegra �Autor  �Vendas Cliente      � Data �  18/03/08   ���
����������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em fazer manutencao nos registros nao processados ���
���			 �da integracao														   ���
����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		   ���
����������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
*/
Class LJCManutRegIntegra
	
	Data oDlg		 						//Objeto dialog
	Data aStrut 	                   		//Array com a estrutura do arquivo temporario
	Data oGetDB						   		//Objeto do tipo MSGetDb
	Data nOpc 		                   		//Opcao da rotina que sera executa do array aRotina
	Data cAliasTMP	                   		//Alias temporario
	Data aAltera					   		//Arrray com os campos que podem ser alterados na MSGetDb
	Data oEntMd8							//Objeto do tipo LJCEntEntrada
	Data cTipo								//Tipo de integracao
	Data oEntMdc							//Objeto do tipo LJCEntNaoConfIntegra	
	Data cTransacao							//Codigo da transacao
	
	Method New()							//Metodo construtor
	Method Show()   						//Metodo responsavel em exibir a tela dos registros nao processados	
        
	//Metodos internos
	Method MontaGrid()						//Carregar os dados na MSGetDB
	Method PrepGetDb()						//Prepara os dados utilizados pela MSGetDB
	Method CriaArqTmp()						//Cria o arquivo temporario
	Method CriaGetDb()						//Estancia o objeto MsGetDB
	Method ShowTelAlt(nPosicao)				//Mostra tela com os registros para alteracao
	Method ConsTbEnt()						//Consulta a tabela de entrada
	Method BuscaTrans(nPosicao)				//Busca o numero da transacao no arquivo temporario
	Method Confirma()						//Confirma as alteracoes da transacao
	Method ValidCampo()						//Valida se o campo pode ser alterado
	
EndClass

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �New          �Autor  �Vendas Clientes     � Data �  22/02/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCManutRegIntegra  		                 ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�																 ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto			    										 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method New() Class LJCManutRegIntegra

	::oDlg			:= Nil 
	::aStrut 		:= {}
	::oGetDB		:= Nil
	::nOpc 			:= 4
	::cAliasTMP		:= ""
    ::aAltera		:= {}
    ::oEntMd8		:= Nil
    ::cTipo			:= ""
    ::oEntMdc		:= Nil
    ::cTransacao	:= ""
    
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Show      �Autor  �Vendas Clientes     � Data �  19/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �responsavel em exibir a tela dos registros nao processados. ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Show() Class LJCManutRegIntegra
	
	Local cCampos 		:= "MDC_TRANS|MDC_DESC"								//Campos que serao criados na MsGetDB
	Local oCombo		:= Nil												//Objeto do tipo ComboBox
	Local cRetSelect	:= ""												//Retorno da combo
	Local aDadosTela 	:= {}												//Array com os dados que serao exibidos na combo
	
	Private aHeader 	:= {}												//Array usado pelo MsGetDb
	Private aRotina		:= {{ "aRotina Falso", "AxPesq"		, 0, 1 },;
						  	{ "aRotina Falso", "AxVisual"	, 0, 2 },;
							{ "aRotina Falso", "AxInclui"	, 0, 3 },;
							{ "aRotina Falso", "AxAltera"	, 0, 4 }}		//Array usado pelo MsGetDb		
	Private oObjManut	:= Self												//Objeto do tipo LJCManutRegIntegra

	//Carrega o array com as opcoes da combo
	aDadosTela := {"","INTEGRACAO ENTRADA", "INTEGRACAO ENTRADA DICIONARIO"}

	//Prepara os dados utilizados na MsGetDB
	::PrepGetDb("MDC", cCampos) 
	
	//Cria arquivo temporario
	::CriaArqTmp()
	
	//Monta a Tela
	DEFINE MSDIALOG ::oDlg FROM 80,1 TO 507,700 TITLE STR0001 PIXEL OF GetWndDefault() //"Manuten��o Integra��o"

	@ 005, 005 TO 35, 345 LABEL STR0002 PIXEL OF ::oDlg //"Tipo Integra��o" 
	@ 018, 010 ComboBox oCombo Var cRetSelect Items aDadosTela Size 120, 010 PIXEL OF ::oDlg
	
	oCombo:bChange := {||oObjManut:MontaGrid(oCombo:nAt)}		
	
	::oDlg:lEscClose := .F.
		
	//Cria a grid MSGetDB
	::CriaGetDb(40,5,190,345)
 	
	@195, 265 BUTTON STR0003 ACTION (::oDlg:End(), ::ShowTelAlt(::oGetDB:oBrowse:nAt)) SIZE 40, 15 OF ::oDlg PIXEL //"Alterar"
	@195, 306 BUTTON STR0004 ACTION (::oDlg:End()) SIZE 40, 15 OF ::oDlg PIXEL //"Cancelar"
		
	ACTIVATE MSDIALOG ::oDlg CENTERED                                                
		
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �PrepGetDb �Autor  �Vendas Clientes     � Data �  19/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em preparar os dados utilizados pela MSGetDB.   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTabela)  - Nome da tabela.					  ���
���			 �ExpC2 (2 - cCampos)  - Campos que serao utilizados na grade.���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method PrepGetDb(cTabela, cCampos) Class LJCManutRegIntegra
    
	aHeader 	:= {}
   	::aStrut 	:= {}
   	
	//Seleciona o arquivo	
	DbSelectArea("SX3")
	//Posiciona no registro
	DbSeek(cTabela)
	
	//Verifica todos os campos da tabela
	While !Eof() .AND. (X3_ARQUIVO == cTabela)
		
		//Monta somente com os campos solicitados 	
		If AllTrim(X3_CAMPO) $ cCampos
			//Alimenta o aHeader da MSGetDB
			AADD(aHeader,{TRIM(X3Titulo())	, 	X3_CAMPO, 	X3_PICTURE, 	X3_TAMANHO,;
							X3_DECIMAL		,	X3_VALID,	X3_USADO, 		X3_TIPO,; 
							X3_ARQUIVO })
			//Alimenta a estrutura do arquivo temporario
			AADD(::aStrut,{X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL})
		EndIf
		//Vai para o proximo registro
		DbSkip()	
	End
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �CriaArqTmp�Autor  �Vendas Clientes     � Data �  19/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em criar o arquivo temporario.   				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CriaArqTmp() Class LJCManutRegIntegra
	
	//Cria o arquivo temporario
	::cAliasTMP 	:= GetNextAlias()
	//Cria tabela temporaria
	LjCrTmpTbl(::cAliasTMP, ::aStrut )
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �MontaGrid �Autor  �Vendas Clientes     � Data �  19/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em carregar os dados na MSGetDB.   			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 (1 - nPosicao) - Posicao na grid					  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method MontaGrid(nPosicao) Class LJCManutRegIntegra
	
   	Local nCount 	:= 0 						//Variavel de controle contador
	Local oRetMdc	:= Nil						//Objeto de retorno da consulta
	
	//Determina o tipo de integracao
	If nPosicao == 2
		::cTipo := "IE"	
	ElseIf nPosicao == 3
		::cTipo := "ID"	
	EndIf
	
	If !Empty(::cTipo)
	   	
	   	//Cria o arquivo temporario
		::CriaArqTmp()
		
		//Estancia o objeto LJCEntNaoConfIntegra
		::oEntMdc := LJCEntNaoConfIntegra():New()
		
		//Consulta os dados na entidade
		::oEntMdc:DadosSet("MDC_TPTAB", ::cTipo)
		
		oRetMdc := ::oEntMdc:Consultar(2)	
		
		//Alimenta a tabela temporaria
		For nCount := 1 To oRetMdc:Count()
				
			RecLock(::cAliasTMP,.T.)
				
			Replace (::cAliasTMP)->MDC_TRANS	With oRetMdc:Elements(nCount):DadosGet("MDC_TRANS")
			Replace (::cAliasTMP)->MDC_DESC 	With oRetMdc:Elements(nCount):DadosGet("MDC_DESC")
	
			MsUnLock()
	   	Next
	   	
		//Cria a grid MSGetDB
		::CriaGetDb(40,5,190,345)
		
		//Seleciona e posiciona o arquivo no primeiro registro
		Dbselectarea(::cAliasTMP)                                                                   '
		(::cAliasTMP)->(dbGoTo(1))
		
		//Atualiza os dados na MSGetDB 
		::oGetDB:ForceRefresh()
	
	EndIf
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �CriaGetDb �Autor  �Vendas Clientes     � Data �  19/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em estanciar o objeto MSGetDB.   			      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CriaGetDb(nTop, nLeft, nBottom, nRight) Class LJCManutRegIntegra
	
	//Cria a grid MSGetDB
	::oGetDB := MSGetDb():New(nTop, nLeft, nBottom, nRight,::nOpc, "AllwaysTrue", "AllwaysTrue",,.T.,::aAltera,,.T.,"oGetDB:nMax",::cAliasTMP,"oObjManut:ValidCampo()",,,::oDlg,,,)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �BuscaTrans�Autor  �Vendas Clientes     � Data �  19/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em buscar o numero da transacao				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 (1 - nPosicao) - Posicao na grid					  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BuscaTrans(nPosicao) Class LJCManutRegIntegra
	
	//Seleciona a tabela
	DbSelectArea(::cAliasTMP)

	//Posiciona no registro
	(::cAliasTMP)->(dbGoTo(nPosicao))
	
	//Pega o numero da transacao do arquivo temporario
	::cTransacao := (::cAliasTMP)->MDC_TRANS
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ShowTelAlt�Autor  �Vendas Clientes     � Data �  19/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em mostra tela com os registros para alteracao  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 (1 - nPosicao) - Posicao na grid					  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ShowTelAlt(nPosicao) Class LJCManutRegIntegra
	
	Local cCampos 		:= "MD8_TRANS|MD8_NOME|MD8_VALOR|MD8_REG|MD8_SEQ"	//Campos que serao criados na MsGetDB
	
	//Array com os campos que podem ser alterrados
	::aAltera := {"MD8_VALOR"}
	
	//Busca o codigo da transacao selecionado
	::BuscaTrans(nPosicao)
	
	//Prepara os dados utilizados na MsGetDB
	::PrepGetDb("MD8", cCampos) 
	
	//Cria arquivo temporario
	::CriaArqTmp()
	
	//Carrega os dados da tabela MD8 no arquivo temporario
	::ConsTbEnt()
	
	//Monta a Tela
	DEFINE MSDIALOG ::oDlg FROM 80,1 TO 507,700 TITLE STR0005 PIXEL OF GetWndDefault() //"Dados da Integra��o"

	::oDlg:lEscClose := .F.
		
	//Cria a grid MSGetDB
	::CriaGetDb(5,5,190 ,345)
    
    DEFINE SBUTTON FROM 197, 290 TYPE 1 ENABLE OF ::oDlg ACTION (oObjManut:Confirma(), ::oDlg:End())
	DEFINE SBUTTON FROM 197, 319 TYPE 2 ENABLE OF ::oDlg ACTION (::oDlg:End())
		
	ACTIVATE MSDIALOG ::oDlg CENTERED                                                

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ConsTbEnt �Autor  �Vendas Clientes     � Data �  19/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em consultar a tabela de entrada                ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConsTbEnt() Class LJCManutRegIntegra
	
	Local nCount 	:= 0 						//Variavel de controle contador
	Local oRetMd8	:= Nil						//Objeto de retorno da consulta
	
	//Estancia o objeto LJCEntEntrada
	::oEntMd8 := LJCEntEntrada():New()
	
	//Consulta os dados na entidade
	::oEntMd8:DadosSet("MD8_TRANS", ::cTransacao)
	
	oRetMd8 := ::oEntMd8:Consultar(1)	
	
	//Alimenta a tabela temporaria
	For nCount := 1 To oRetMd8:Count()
		
		RecLock(::cAliasTMP,.T.)
			
		Replace (::cAliasTMP)->MD8_TRANS	With oRetMd8:Elements(nCount):DadosGet("MD8_TRANS")
		Replace (::cAliasTMP)->MD8_NOME 	With oRetMd8:Elements(nCount):DadosGet("MD8_NOME")
		Replace (::cAliasTMP)->MD8_VALOR	With oRetMd8:Elements(nCount):DadosGet("MD8_VALOR")
		Replace (::cAliasTMP)->MD8_REG  	With oRetMd8:Elements(nCount):DadosGet("MD8_REG")
		Replace (::cAliasTMP)->MD8_SEQ		With oRetMd8:Elements(nCount):DadosGet("MD8_SEQ")
		
		MsUnLock()
   	
   	Next

	//Seleciona e posiciona o arquivo no primeiro registro
	Dbselectarea(::cAliasTMP)                                                                   '
	(::cAliasTMP)->(dbGoTo(1))

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Confirma  �Autor  �Vendas Clientes     � Data �  19/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em efetuar a alteracao na tabela de entrada     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Confirma() Class LJCManutRegIntegra
    
	Local lOk := .F.								//Verifica se o comando foi executado

	//Seleciona a tabela
	DbSelectArea(::cAliasTMP)

	//Posiciona no primeiro registro
	(::cAliasTMP)->(dbGoTo(1))
    
    //Abre transacao
    Begin Transaction

		//Begin Sequence
	    
		    //Faz as alteracoes na tabela de entrada MD8
			While (::cAliasTMP)->(!Eof())
			    
			    //Limpa os dados da entidade
				::oEntMd8:Limpar()
			    
			    //Atribui o campo a ser alterado
			    ::oEntMd8:DadosSet("MD8_VALOR", (::cAliasTMP)->MD8_VALOR)
			    ::oEntMd8:DadosSet("MD8_STATUS", "1")
				::oEntMd8:DadosSet("MD8_SITPRO", "1")		
				
				//Seta os dados do indice 1
			    ::oEntMd8:DadosSet("MD8_TRANS", (::cAliasTMP)->MD8_TRANS)
		  	    ::oEntMd8:DadosSet("MD8_REG", (::cAliasTMP)->MD8_REG)
			    ::oEntMd8:DadosSet("MD8_SEQ", (::cAliasTMP)->MD8_SEQ)
		
				//Altera o registro
				lOk := ::oEntMd8:Alterar(1)
				
				//Verifica se o comando foi executado
				If !lOk
					Exit
				EndIf
				
				//Vai para o proximo registro		
				(::cAliasTMP)->(dbSkip())
			End
			//-----------------------------------------------------
			
			//Exclui o registro da tabela de nao conformidade MDC
			If lOk
				//Limpa os dados da entidade
				::oEntMdc:Limpar()
				
				//Seta os dados do indice
				::oEntMdc:DadosSet("MDC_TRANS", ::cTransacao)
			    ::oEntMdc:DadosSet("MDC_TPTAB", ::cTipo)
				
				//Exclui o registro
				lOk := ::oEntMdc:Excluir(1)
			EndIf
			//-----------------------------------------------------
		
		//Recover          
			//Desfaz a transacao
		  //	lOk := .F.
		//End Sequence 
	    
		If !lOk
			//Confirma a transacao	
			DisarmTransaction()
			Alert(STR0006)//"Os registros da integra��o n�o foram alterados"
		EndIf
	
	End Transaction 
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ValidCampo�Autor  �Vendas Clientes     � Data �  19/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em validar a alteracao do campo			      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico			    									  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ValidCampo() Class LJCManutRegIntegra
   	
   	Local lRetorno := .F.					//Retorno do metodo
   	
   	//Seleciona a tabela
	DbSelectArea(::cAliasTMP)

	//Posiciona no registro
	(::cAliasTMP)->(dbGoTo(::oGetDB:oBrowse:nAt))
	
	//Pega o numero da transacao do arquivo temporario
	cNome := (::cAliasTMP)->MD8_NOME
   	
   	//O campo com o nome tabela nao pode ser alterado. 
   	If AllTrim(cNome) == "TABELA"
		Alert(STR0007)//"Este campo n�o pode ser alterado"   	
   	Else
		lRetorno := .T.
	ENDIF

Return lRetorno