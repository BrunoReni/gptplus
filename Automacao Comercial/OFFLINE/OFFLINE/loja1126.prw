#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA1126()
Return NIL
/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Classe    �LJCGrafo  �Autor  �Vendas Clientes     � Data �  17/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Guarda o Caminho da Replicacao dos Registros para o        ���
���          � Processo informado.                                        ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class LJCGrafo
	Data aGrafo								//Guarda o Caminho para Replicacao
	Data nVertices							//Tamanho do Grafo
	Data lEspecif							//Conexao Especifica

	Method New(cProcesso, nOrigem)			//Instancia o Objeto
	Method SetAresta(nAmbOri, nAmbDes)		//Adiciona a ligacao entre dois Ambientes
	Method TemAresta(nAmbOri, nAmbDes)		//Verifica se existe ligacao direta entre dois Ambientes
	Method setVertices(nVertices)			//Guarda o Tamanho do Grafo
	Method getVertices()					//Retorna o Tamanho do Grafo
	Method TemCaminho(nAmbOri, nAmbDes)		//Verifica se existe caminho entre dois Ambientes
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   � New      �Autor  �Vendas Clientes     � Data �  17/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Instancia o Objeto                                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(cProcesso, nOrigem) Class LJCGrafo
	Local oEAmbxProc	:= LJCEntAmbProcessos():New()		//Entidade Ambiente x Processo
	Local oDAmbxProc	:= NIL								//Dados da Entidade Ambiente x Processo
	Local oEProcesso	:= LJCEntProcessos():New()			//Entidade Processos
	Local oDProcesso	:= NIL								//Dados Processo

	Local nMax			:= 0								//Guarda o Ambiente com o Maior Codigo
	Local nI			:= 0								//Contador
	Local nJ			:= 0    							//Contador
	Local nAmbOri		:= 0								//Ambiente Origem
	Local nAmbDes		:= 0								//Ambiente Destino

	Local lEspecif		:= .F.

	//Inicializa o Grafo
	::aGrafo	:= {}

	oEProcesso:DadosSet("MD1_CODIGO", cProcesso)
	
	oDProcesso := oEProcesso:Consultar(1)	//MD1_FILIAL, MD1_CODIGO
	
	//Verifica se e Conexao Especifica
	For nI := 1 to oDProcesso:Count()
		If oDProcesso:Elements(nI):DadosGet("MD1_TIPO") == "E"
			lEspecif := .T.
		EndIf
	Next nI

	//Atribui a Condicao da Consulta
	oEAmbxProc:DadosSet("MD5_PROCES", cProcesso)

	//Realiza a Consulta
	oDAmbxProc := oEAmbxProc:Consultar(2)	//MD5_FILIAL, MD5_PROCES
    
	//Guarda o Ambiente com o Maior Codigo
	For nI := 1 to oDAmbxProc:Count()
		nAmbOri	:= Val(oDAmbxProc:Elements(nI):DadosGet("MD5_AMBORI"))
		nAmbDes := Val(oDAmbxProc:Elements(nI):DadosGet("MD5_AMBDES"))

		If nAmbOri > nMax
			nMax := nAmbOri
		EndIf
		
		If nAmbDes > nMax
			nMax := nAmbDes
		EndIf
	Next nI

	//Guarda o Tamanho do Grafo
	::SetVertices(nMax)

	//Cria uma Matriz quadrada com o Numero de Ambientes
	For nI := 1 to ::GetVertices()
		Aadd(::aGrafo, Array(nMax))
		For nJ := 1 to nMax
			::aGrafo[nI][nJ] := 0		//Nao tem Caminho
		Next nJ
	Next nI

	//Insere as ligacoes entre os Ambientes
	For nI := 1 to oDAmbxProc:Count()
		nAmbOri	:= Val(oDAmbxProc:Elements(nI):DadosGet("MD5_AMBORI"))
		nAmbDes := Val(oDAmbxProc:Elements(nI):DadosGet("MD5_AMBDES"))
		
		//Se for Conexao Especifica e o Ambiente de Destino
		//for Igual a Origem nao marca a ligacao para que o
		//sistema faca a replicacao para todos os ambientes,
		//menos o ambiente de Origem.
		lMarca := !(lEspecif .AND. nAmbDes == nOrigem)
		
		If lMarca
			::SetAresta(nAmbOri, nAmbDes)
		EndIf
	Next nI
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   � SetAresta  �Autor  �Vendas Clientes   � Data �  17/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Habilita a Ligacao direta entre dois Ambientes.            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SetAresta(nAmbOri, nAmbDes) Class LJCGrafo
	::aGrafo[nAmbOri][nAmbDes] := 1	//Habilita a ligacao entre dois Ambientes
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   � TemAresta  �Autor  �Vendas Clientes   � Data �  17/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se existe ligacao direta entre dois Ambientes.    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TemAresta(nAmbOri, nAmbDes) Class LJCGrafo
	Local lRetorno := .F.
	If ::aGrafo[nAmbOri][nAmbDes] == 1
		lRetorno := .T.
	EndIf
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   � SetVertices �Autor  �Vendas Clientes  � Data �  17/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Guarda o numero de Vertices.                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SetVertices(nVertices) Class LJCGrafo			//Guarda o Tamanho do Grafo
	::nVertices := nVertices
Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   � GetVertices �Autor  �Vendas Clientes  � Data �  17/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Recupera o numero de Vertices.                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetVertices() Class LJCGrafo					//Retorna o Tamanho do Grafo
Return ::nVertices

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo � TemCaminho �Autor  �Vendas Clientes     � Data �  17/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.   � Verifica se existe Caminho entre dois Ambientes.             ���
���        �                                                              ���
�������������������������������������������������������������������������͹��
���Uso     � SIGALOJA                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TemCaminho(nAmbOri, nAmbDes) Class LJCGrafo
	Local aFila		:= {}						//Fila com os Ambientes a Percorrer
	Local aVisita	:= {}						//Ambientes Percorridos
	Local nVertices := ::GetVertices()			//Numero de Ambientes
	Local nW		:= 0						//Ambiente Atual
	Local nI		:= 0						//Contador
	Local lRetorno	:= .F.						//Define se existe um Caminho entre os Ambientes Informados
	
	aVisita := Array(nVertices)

	//Inicializa aVisita 
	For nI := 1 to Len(aVisita)
		aVisita[nI] := .F.
	Next nI
	
	//Adiciona o Ambiente de Origem ao aFila
	Aadd(aFila, {nAmbOri})

	While !Empty(aFila)
		//Remove o primeiro vertice e coloca na variavel nW	
		nW := aFila[1][1]
		aDel(aFila, 1)
		aSize(aFila, Len(aFila) - 1)
		
		//Marca o vertice nW, como visitado.
		aVisita[nW] := .T.
		
		For nI := 1 to nVertices
			If ::TemAresta(nW, nI)
				If !aVisita[nI]
					If nI == nAmbDes
						lRetorno := .T.
					EndIf
					Aadd(aFila, {nI})
				EndIf
			EndIf
		Next nI		
	End
Return lRetorno
