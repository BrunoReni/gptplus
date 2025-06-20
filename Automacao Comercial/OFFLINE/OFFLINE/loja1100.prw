#INCLUDE "MSOBJECT.CH"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿟ipo de replicao do processo�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸
#DEFINE INTEGRACAO "I"
#DEFINE ESPECIFICA "E"
#DEFINE RPLLOCAL	"L"

Function LOJA1100 ; Return  // "dummy" function - Internal Use 

/* 
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�         
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튏lasse    쿗JCProcessoOffLine튍utor  쿣endas Clientes     � Data �  22/02/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿎lasse responsavel em executar a integracao do processo offline. 	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                         		  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Class LJCProcessoOffLine
	
	Data oDadosProc										//Objeto do tipo LJCDadosProcesso
	Data cTpRplProc										//Tipo de replicacao do processo
	Data oRplIntegracao									//Objeto do tipo LJIIntegracao
	Data lAutomati										//Verifica se o processo vai ser integrado automaticamente
		
	Method New(cProcesso, lAutomati)                   	//Metodo construtor
	Method Inserir(cTabela, cChave, nIndice, cTipo)  	//Metodo que ira adicionar um objeto na Colecao
	Method Processar()	    							//Metodo que ira processar o processo OffLine
	
	//Metodos internos
	Method ProcHabili()									//Metodo que ira verificar se o processo esta habilitado
	Method TabsHabili()									//Metodo que ira verificar se as tabelas do processo estao habilitadas
	Method Integrar()									//Metodo que ira integrar o processo via integracao ou conexao especifica
	
EndClass

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튝etodo    쿙ew       튍utor  쿣endas Clientes     � Data �  22/02/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿎onstrutor da classe LJCProcessoOffLine.                    볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐xpN1 (1 - cProcesso) - Codigo do processo.                 볍�
굇�			 쿐xpL1 (2 - lAutomati) - Integracao automatica do processo.  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto									   				  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method New(cProcesso, lAutomati) Class LJCProcessoOffLine
	
	Default lAutomati := .F.
	
    ::cTpRplProc 		:= IIF(lAutomati, INTEGRACAO, "")
    ::oRplIntegracao 	:= Nil
    ::lAutomati			:= lAutomati
    
    //Estancia o objeto LJCDadosProcesso
    ::oDadosProc := LJCDadosProcesso():New(cProcesso)

Return Self

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튝etodo    쿔nserir   튍utor  쿣endas Clientes     � Data �  22/02/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝esponsavel em armazenar os dados do processo.              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐xpC1 (1 - cTabela) - Nome da tabela. 					  볍�
굇�			 쿐xpC2 (2 - cChave)  - Dados da chave.						  볍�
굇�			 쿐xpN1 (3 - nIndice) - Codigo do indice.			          볍�
굇�			 쿐xpC3 (4 - CTipo)   - Tipo de integracao do dado.	          볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method Inserir(cTabela, cChave, nIndice, cTipo) Class LJCProcessoOffLine

	Local oDadoProc := Nil					//Objeto do tipo LJCDadoProcesso
	
	cTabela := AllTrim(Upper(cTabela))
	
	//Estancia o objeto LJCDadoProcesso
	oDadoProc := LJCDadoProcesso():New(cTabela, cChave, nIndice, cTipo, ::lAutomati)
	
	//Adiciona o dado do processo na colecao
	::oDadosProc:Add(cTabela, oDadoProc, .T.)
	
Return Nil

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튝etodo    쿛rocessar 튍utor  쿣endas Clientes     � Data �  22/02/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝esponsavel em processar o processo OffLine.                볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�											                  볍�															  
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico									   				  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method Processar() Class LJCProcessoOffLine

	Local lRetorno 	:= .F.					//Retorno do metodo
    Local lAmbOffLn := .F.					//Parametro mv_ljoffln
    
	//Verifica se o ambiente esta operando em offline
	lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)
	lRetorno	:= lAmbOffLn
	
    //Verifica se o processo sera integrado automaticamente
	If !::lAutomati
		//Verifica se o processo existe e se esta habilitado
		If lRetorno
			lRetorno := ::ProcHabili()
		EndIf
		
		//Verifica se alguma tabela do processo esta habilitada
		If lRetorno 
			lRetorno := ::TabsHabili()
		EndIf
	EndIf
    
    //Integra o processo
    If lRetorno
	    lRetorno := ::Integrar()
    EndIf

Return lRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튝etodo    쿛rocHabili튍utor  쿣endas Clientes     � Data �  03/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝esponsavel em verificar se o processo esta habilitado      볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�											                  볍�															  
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico									   				  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method ProcHabili() Class LJCProcessoOffLine

	Local lRetorno 	:= .F.				//Retorno do metodo
    Local oProcesso := Nil              //Objeto do tipo LJCEntProcessos
	Local oRetorno	:= Nil              //Objeto do tipo LJCRegistrosEntidades com o retorno da consulta
	Local aArea		:= GetArea()
	    
    //Estancia o objeto LJCEntProcessos
	oProcesso := LJCEntProcessos():New()
	
	//Seta os dados do indice 1
	oProcesso:DadosSet("MD1_CODIGO", ::oDadosProc:cProcesso)
	
	//Consulta pelo indice 1
	oRetorno := oProcesso:Consultar(1)

	//Verifica se encontrou
	If oRetorno:Count() > 0 
		//Verifica se o processo esta habilitado
		lRetorno :=	oRetorno:Elements(1):DadosGet("MD1_ENABLE")
		//Guarda o tipo de replicacao do processo
		::cTpRplProc := oRetorno:Elements(1):DadosGet("MD1_TIPO")		 		
	EndIf
	
	RestArea(aArea)
	
Return lRetorno

/*       
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튝etodo    쿟absHabili튍utor  쿣endas Clientes     � Data �  03/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝esponsavel em verificar verificar se as tabelas do processo볍�
굇�			 쿮stao habilitadas										      볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�											                  볍�															  
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico									   				  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method TabsHabili() Class LJCProcessoOffLine

	Local lRetorno 	:= .F.				//Retorno do metodo
    Local oTabsProc := Nil              //Objeto do tipo LJCEntTabelasProcesso
	Local oRetorno	:= Nil              //Objeto do tipo LJCRegistrosEntidades com o retorno da consulta
    Local cTabela	:= ""				//Tabela do processo
    Local nCount	:= 0				//Variavel de controle contador para os registros da tabela MD2
    Local nTabProc	:= 0				//Variavel de controle contador das tabelas do processo    
        
    //Estancia o objeto LJCEnTTabelasProcesso
	oTabsProc := LJCEnTTabelasProcesso():New()
	
	//Seta os dados do indice 1
	oTabsProc:DadosSet("MD2_PROCES", ::oDadosProc:cProcesso)
	
	//Consulta pelo indice 1
	oRetorno := oTabsProc:Consultar(1)
    
	//Verifica se a tabela esta habilitada para o processo
	For nCount := 1 To oRetorno:Count()

		//Tabela do processo
		cTabela := oRetorno:Elements(nCount):DadosGet("MD2_TABELA")
        
        //Verifica se a tabela pertence ao processo
		For nTabProc := 1 To ::oDadosProc:Count()
			If ::oDadosProc:Elements(nTabProc):cTabela == cTabela
				::oDadosProc:Elements(nTabProc):lIntegra := oRetorno:Elements(nCount):DadosGet("MD2_ENABLE")
				lRetorno := .T.
			EndIf
		Next
	Next
	
Return lRetorno

/*       
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튝etodo    쿔ntegrar  튍utor  쿣endas Clientes     � Data �  03/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝esponsavel em integrar o processo via integracao ou conexao볍�
굇�			 쿮specifica												  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�											                  볍�															  
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico									   				  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method Integrar() Class LJCProcessoOffLine

	Local lRetorno 	:= .F.				//Retorno do metodo	
	
    Do Case
        //Integracao
		Case ::cTpRplProc  == INTEGRACAO
			::oRplIntegracao := LJCRplIntegracao():New()
			
		//Conexao especifica
		Case ::cTpRplProc  == ESPECIFICA
			::oRplIntegracao := LJCRplEspecifica():New()
	EndCase
	
	If ::oRplIntegracao != Nil
		lRetorno := ::oRplIntegracao:Integrar(::oDadosProc)
	Else
		//Somente Local
		lRetorno := .T.
	EndIf   

Return lRetorno