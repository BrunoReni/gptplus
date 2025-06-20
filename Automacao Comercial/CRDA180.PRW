#INCLUDE "crda180.ch"
#INCLUDE "PROTHEUS.CH"

Static oTimerCrd				//Objeto do timer 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRDA180   � Autor �Viviane M. Fernandes   � Data �05.07.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastro de clientes bloqueados por cr�dito, ordenado de    ���
���          �acordo com a  data e hora de bloqueio.                      ���
���          �Chamada da tela de desbloqueio de cr�dito, pela rotina do   ���
���          �menu "Analisa pr�x".					                  	  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �								                       		  ���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���15/06/05  �Kotaki/Machima �Retirada do filtro da mBrowse para mostrar  ���
���          �               �todos os registros do cadastro de credito.  ��� 
���          �               �Apresentar a legenda para os status bloquea-��� 
���          �               �do e nao-bloqueado                          ��� 
���03/03/06  �Andrea F.      �BOPS 94380 - Tratar o filtro na Mbrowse para���
���          �               �base de dados AS400.                        ��� 
���03/06/06  �Machima        �BOPS 100947 - Correcao para nao permitir que���
���			 �				 �2 ou mais analistas avaliem o mesmo cliente ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRDA180

Local lAS400	 	:= TcSrvType() == "AS/400"								// Identifica se o banco de dados eh AS400
Local aCores        := {{"MA7->MA7_BLOQUE == '4'" , "BR_VERMELHO"   },;  	// Bloqueado na Fila do Crediario - VERMELHO
						{"MA7->MA7_BLOQUE <> '4'" , "BR_VERDE"      }}    	// Nao-bloqueado na Fila do Crediario - VERDE

Private aRotina     :=	MenuDef()                   
Private cCadastro   := STR0002	  //"Classifica��o de cliente"
Private oObjBrow
Private cString     := "MA7"

DbSelectArea("MA7")
DbSetOrder(2)
//����������������������������������������������������������������������Ŀ
//�Quando  estiver utilizando o banco de dados AS400 a opcao de filtro da�
//�mbrowse nao estara disponivel. O filtro devera ser tratado na Mbrowse �
//������������������������������������������������������������������������
If lAS400
	Dbgotop()
	MBrowse( 06, 01, 15, 75, "MA7",,,,,,,"CRDA180Top","CRDA180Bot",,{|| CrdAtualiza() })
Else	
	DbSeek(xFilial("MA7"),.T.)
	MBrowse( 06, 01, 15, 75, "MA7",,,,,,aCores,,,,{|| CrdAtualiza() })
Endif
	
If ValType(oTimerCrd) == "O"
   oTimerCrd:DeActivate()	
EndIf  

Return(NIL)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Conrado Q. Gomes      � Data � 13.12.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CRDA180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
	Local aRotina := {	{STR0001	,"CRA180Aval"	,0	,4	,0	,.T.	}	,; 				//"Analisa Pr�x."
						{STR0003	,"CRA180Aval"	,0	,4	,0	,.T.	}	,; 				//"Escolha"
						{STR0014	,"CRA180Legenda",0	,2	,0	,.T.	}	} 				//"Legenda"
	Local aRotAdic := {}
	
	//������������������������������������������������������Ŀ
	//� Ponto de entrada - Adiciona rotinas ao aRotina       �
	//��������������������������������������������������������
	If ExistBlock("CRD180ROT")
		aRotAdic := ExecBlock("CRD180ROT", .F., .F.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic,{|x| AAdd(aRotina,x)})
		EndIf
	EndIf
Return(aRotina)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CrdAtualiz�Autor  �Microsiga           � Data �  06/15/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualizacao do browse para apresentar os registros de cadas-���
���          �tro do credito                                              ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACRD                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CrdAtualiza(oCrdMBrowse)

If oTimerCrd == NIL
	DEFINE TIMER oTimerCrd INTERVAL 3000 ACTION (CRDTimer(oCrdMBrowse)) OF GetWndDefault()	
	oTimerCrd:Activate()	
Endif	

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRDTimer  �Autor  �Microsiga           � Data �  06/15/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Execucao do timer para atualizacao do browse                ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACRD                                                    ���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���03/03/06  �Andrea F.      �BOPS 94380 - Tratar o filtro na Mbrowse para���
���          �               �banco de dados AS400.                       ��� 
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                 
Static Function CRDTimer( )

Local lAS400	 	:= TcSrvType() == "AS/400"	// Identifica se o banco de dados eh AS400

//������������������������������������������������������Ŀ
//�Comandos para executar o refresh no browse de maneira �
//�a mostrar ao avaliador o status de credito atualizado �
//��������������������������������������������������������
oCrdMBrowse := GetObjBrow()
#IFDEF TOP
	If lAS400
		oCrdMBrowse:SetFilter(IndexKey(),CRDA180Top(),CRDA180Bot())
    Else
		SetMbTopFilter("MA7","")      
	Endif	
#ELSE
	oCrdMBrowse:SetFilter(IndexKey(),,)
#ENDIF	
oCrdMBrowse:GoTop()
oCrdMBrowse:ResetLen()
oCrdMBrowse:Default()
oCrdMBrowse:Reset()
oCrdMBrowse:Refresh()
sysrefresh()

Return (NIL)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao   �CRA180Aval   �Autor�Viviane M. Fernandes� Data �  05/07/03   ���
�������������������������������������������������������������������������͹��
���Desc.    �Avaliacao do credito na fila do Crediario                    ���
�������������������������������������������������������������������������͹��
���Parametro�                                                             ���
�������������������������������������������������������������������������͹��
���Uso      � SIGACRD 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRA180Aval(cAlias, nRecno, nOpc )

Local aArea		:= GetArea()
Local cCliente  := ""
Local cLoja     := ""                                        
Local cMV_LibNiv:= SuperGetMv("MV_LIBNIV")
Local nTipo     := 3
Local nOrdem                      
Local nRecnoMAR := 0                       	// Recno do MAR gerado pelo CRDA180
Local lRet		:= .T.						// Retorno Default
Local lErro		:= .F.						// Flag de controle de erro

//��������������������������������������������������������������������������������Ŀ
//�Se o nivel do usuario logado for menor que a permissao de avalicao CONFIGURADA  �
//�pelo MV_LIBNIV para o analista de Credito nao permite avaliar a proxima venda   �
//����������������������������������������������������������������������������������
If cNivel < cMV_LibNiv
	MsgStop(STR0004, STR0005) //"Usu�rio sem permiss�o de liberar cr�dito para cliente"###"Usu�rio sem Permiss�o de libera��o"
	lRet  := .F.
Else	
	If nOpc == 1 // Deve procurar o proximo registro para liberacao
		dbSelectArea( "MA7" )
		dbSetOrder( 2 )
		If DbSeek( xFilial( "MA7" ) + "4" + cFilAnt )			
		   While !Eof() .AND. MA7->MA7_BLOQUE == "4" .AND. MA7->MA7_FILCRE == cFilAnt			
			  // Se for possivel dar um lock no registro liberar para a analise de credito
			  If CRDSEMABLO( "CRDA180"  ,Recno()  ,@nRecnoMAR )
				 lErro := .F.
				 Exit
			  Else
				 lErro := .T.
			  EndIf
			  MA7->(dbSkip())
		   End
		Else
			MsgStop(STR0006,STR0007) //"N�o h� registros para serem liberados."###"Aten��o !"
			lRet  := .F.
		Endif
		
		If lRet .AND. lErro
			MsgStop(STR0008) //"N�o h� registros para o desbloqueio, ou todos registros j� est�o sendo analisados"
			lRet  := .F.
		Endif		
	//����������������������������������������Ŀ
	//�Pesquisa registro de credito por cliente�
	//������������������������������������������
	Else   	
		If !Pergunte("CRD180")
			lRet  := .F.
		Endif	    
	    If lRet
	       dbSelectArea( "MA7" )
	       nOrdem := IndexOrd()
	       dbSetOrder(1)
	       If !DbSeek(xFilial("MA7")+MV_PAR01+MV_PAR02)
	   	      MsgStop(STR0009) //"Cliente n�o encontrado."
	   	      dbSetOrder(nOrdem)
	   	      lRet  := .F.
	       EndIf             
	       If lRet
	          dbSetOrder(nOrdem)	   
	          // Se for possivel dar um lock no registro liberar para a analise de credito
		      If !CRDSEMABLO( "CRDA180"  ,Recno()  ,@nRecnoMAR )
			     MsgStop(STR0010) //"Este cliente ja est� sendo analisado por outro atendente."
			     lRet  := .F.
		      EndIf
	   
		      If lRet .AND. MA7->MA7_BLOQUE <> "4"
			     MsgStop(STR0011) //"Este cliente n�o pode ser liberado."
			     lRet  := .F.
		      Endif                       
		   Endif   
	   Endif
	Endif   
    If lRet
	   If MA7->MA7_BLOQUE <> "4"
		  lRet  := .F.
		  MsgStop( STR0012, STR0013 ) //"Todos os cr�ditos est�o sendo analisados ou n�o existem registros para libera��o."###"Aten��o"		  
	   EndIf
	   If lRet		
	      cCliente:= MA7->MA7_CODCLI
	      cLoja   := MA7->MA7_LOJA
	
	      RegToMemory("MA7",.F.)
	
	      dbSelectArea("SA1")
	      dbSetOrder(1)	
	      If DbSeek(xFilial("SA1")+cCliente+cLoja)	
	         RegToMemory("SA1",.F.)	
	         
	         //Chamada da rotina de libera��o de cr�dito ( nTipo possui valor 3 )
	         CRM010_006(nTipo, cCliente, cLoja, nRecnoMAR)
	         
	         // Liberar o bloqueio do registro (semaforo)
	         dbSelectArea("MAR")
	         RecLock("MAR",.F.,.T.)
             dbDelete()
             MsUnlock()
             
             WriteSx2("MAR")
             
             lRet := .T.
          Endif   
       Endif
   Endif         
EndIf

//��������������������������������������������������������������������Ŀ
//�Restaura a area antes de chamar a funcao CrdTimer() porque ela tem  �
//�que atualizar o browse posicionado no ALIAS MA7.                    �
//����������������������������������������������������������������������
RestArea(aArea)

CrdTimer()

MsUnlockAll()

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRD180Legenda�Autor  �Fernando Machima � Data �  15/06/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Legenda do browse de liberacao de credito                   ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACRD                                                    ���
�������������������������������������������������������������������������ͺ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Machima   �15/06/05�811   �- Inicio do desenvolvimento  				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRA180Legenda()

Local cLegenda  := STR0015          //"Liberacao de Credito"
Local aCores 	:= {}				// Array Default com as definicoes de cores

aCores := {	{"BR_VERDE"		,STR0016  },;					//"Nao-Bloqueado"         
            {"BR_VERMELHO" 	,STR0017  }}				    //"Bloqueado"         
            
BrwLegenda(cLegenda,STR0014,aCores )  //"Legenda"	

Return(.T.)
                        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRDA180Top� Autor �Viviane M. Fernandes   � Data �05.09.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Fun��o que retorna o registro inicial que dever� ser visuali���
���			 �zado na mbrowse, sempre respeitando o �ndice que foi traba- ���
���			 �lhado anteriormente.O retorno da fun��o dever� retornar     ���
���			 �todos os campos que fazem parte da chave de �ndice.		  ���
���			 �Utilizado �ndice inverso, por isso trazemos o mais antigo   ���
���			 �pelo MAX                                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       �CRDA180						               			      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �MA7->MA7_FILIAL+MA7->MA7_BLOQUE+DTOS(MA7_DATABL)+MA7_HORABL ���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRDA180Top()

Local aArea		:= GetArea()		//Salva a area atual
Local cRetorno 	:= ""    

DbSelectArea("MA7")
DbSetOrder(2)// data mais recente
DbSeek(xFilial("MA7")+"4"+cFilAnt)

If MA7->(!EOF())
	cRetorno := MA7->MA7_FILIAL+MA7->MA7_BLOQUE+MA7->MA7_FILCRE+DTOS(MA7_DATABL)+MA7_HORABL
EndIf

RestArea(aArea)

Return(cRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRDA180Bot� Autor �Viviane M. Fernandes   � Data �05.09.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Fun��o que retorna o �ltimo registro  que dever� ser visuali���
���			 �zado na mbrowse, sempre respeitando o �ndice que foi traba- ���
���			 �lhado anteriormente.O retorno da fun��o dever� retornar     ���
���			 �todos os campos que fazem parte da chave de �ndice.		  ���
���			 �Utilizado �ndice inverso, por isso trazemos o mais recente  ���
���			 �pelo MIN             										  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �								                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �MA7->MA7_FILIAL+MA7->MA7_BLOQUE+DTOS(MA7_DATABL)+MA7_HORABL ���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRDA180Bot()

Local aArea		:= GetArea()	//Salva a area atual
Local cRetorno 	:=""

DBSelectarea("MA7")
DbSetOrder(3) //indice invertido
DbGoTop()
DbSeek(xFilial("MA7")+"4"+cFilAnt)

If MA7->(!EOF())
	cRetorno:= MA7_FILIAL+MA7_BLOQUE+MA7->MA7_FILCRE+DTOS(MA7_DATABL)+MA7_HORABL
EndIf

DbSelectArea("MA7")
DbSetOrder(2)

RestArea(aArea)

Return(cRetorno)
