#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM025.CH"
#INCLUDE "SCOPECNT.CH"

#DEFINE TAMIMP 120

/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Funcao    	� GPEM025    � Autor � Claudinei Soares         	  � Data �15/10/2015     ���
���������������������������������������������������������������������������������������Ĵ��
���Descricao 	� CNIS                                                                    ���
���             � Rotina utilizada para importar o arquivo de retorno do CNIS.          ���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   	� GPEM025()                                                               ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      	� Generico (DOS e Windows)                                   			    ���
���������������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.               		    	���
���������������������������������������������������������������������������������������Ĵ��
���Programador  � Data     � FNC			�  Motivo da Alteracao                        ���
���������������������������������������������������������������������������������������Ĵ��
���Claudinei S. �15/10/2015�TTOW41          � Criacao do novo fonte para a P12.         ���
���Paulo O I    �13/04/2017�DRHPAG-239      �Melhoria -  remo��o de dependencias do ctree���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
Function GPEM025()

Local cArquivo
Local nOpca := 0

Local aSays:={ }, aButtons:= { } //<== arrays locais de preferencia
Local aRegs	   		:= {}

Local aOfusca		:= IIf(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Local aFldRel		:= {"RA_NOME", "RA_CIC", "RA_PIS"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

Private cPerg		:= "GPEM025"
Private lAbortPrint := .F.
Private cArqDados 	:= ""

If lBlqAcesso
	//"Dados Protegidos- Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Saiba mais em {link documenta��o centralizadora}"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Return
EndIf

cCadastro := OemToAnsi(STR0001) //"Leitura do Arquivo de Retorno do CNIS"

Pergunte(cPerg,.F.)

AADD(aSays,OemToAnsi(STR0002) )	//Esta rotina faz a leitura do arquivo de retorno do CNIS, e a gravacao do PIS no cadastro do
AADD(aSays,OemToAnsi(STR0021) )	//funcionario.

AADD(aButtons, { 5,.T.,{|| Pergunte("GPEM025",.T. ) } } )
aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(),FechaBatch(),nOpcA:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

IF nOpcA == 1
	Processa({|lEnd| GPM25Proce(),STR0001})  //"Leitura do Arquivo de Retorno do CNIS"
Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPM25Proce� Autor � Claudinei Soares    � Data � 06/03/2015 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Leitura Arquivo de Retorno do CNIS.                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function GPM25Proce()

// ----- Variaveis que receberao os campos do arquivo de retorno -----
Local cLinha		:= ""		//Linha que o registro esta localizado no arquivo.
Local cTipoReg	:= ""		//Tipo de Registro(00-Header Geral, 01-Header Parcial, 02-Registro Detalhe, 98-Trailer Parcial, 99-Trailer Geral).
Local cCodCampo	:= ""		//Codigo do campo (Identificara de que informacao se trata a linha).
Local cSeqCampo	:= ""		//Sequencial do campo.
Local cVlCampo	:= ""		//Conteudo do campo.
Local cPIS			:= ""		//Conteudo do campo que podera ter o PIS em caso de retorno positivo.
Local cMsgRet		:= ""		//Codigo do erro/mensagem de retorno.
Local lQualific	:= .F.		//Identifica se o Tipo do carga foi qualificacao.
Local cPISOK		:= ""		//Numero do PIS gerado em caso de retorno positivo.

Local lGravaPIS 	:= .F.
Local lCPF 		:= .F.
Local cNome 		:= ""

// ----------------------------------------------

Local cNomEmpFil	:= ""

Private aTitle	:= {}
Private aLog		:= {}
Private cArq1		:= ""
Private cCond		:= ""

Private oTmpTable := Nil
Private cAliasTmp

//��������������������������������������������������������������Ŀ
//� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
//����������������������������������������������������������������
cArquivo	:=	AllTrim(mv_par01)		//-- Nome do Aquivo Texto

If !File(cArquivo)
	Help(" ",1,"A210NOPEN")
	Return
Endif

//������������������������������Ŀ
//� Cria arquivo Temporario      �
//��������������������������������
Cria_TMPC()

//������������������������������Ŀ
//� Abre arquivo texto informado �
//��������������������������������
If fT_fUse(cArquivo ) == -1
	Help(" ",1,"A210NOPEN")
    Return( Nil )
EndIf
//Posiciona no inicio do arquivo
fT_fGotop()

//Verifica se existe alguma informacao no arquivo
If fT_fEof()
    Help(" ",1,"A210NOPEN")
    Return( Nil )
Endif

//��������������������������������������������������������������Ŀ
//� Posiciona SRA na Ordem 1                                     |
//����������������������������������������������������������������
SRA->(dbSetOrder(1))

//��������������������������������������������������������������Ŀ
//� Carrega Regua Processamento	                                 �
//����������������������������������������������������������������
nLinhas := FT_FLastRec()
fT_fGotop()

//��������������������������������������������������������������Ŀ
//� Carrega Regua Processamento	                                 �
//����������������������������������������������������������������
ProcRegua(nLinhas)

//��������������������������������������������������������������Ŀ
//� Inicia a leitura das linhas do arquivo de retorno            �
//����������������������������������������������������������������
While !fT_fEof()

	//��������������������������������������������������������������Ŀ
	//� Move Regua Processamento	                                 �
	//����������������������������������������������������������������
	IncProc(STR0001) //"Importacao de Valores Variaveis"

    //��������������������������������Ŀ
    //� L� cada linha do arquivo texto �
    //����������������������������������
    TXT := fT_fReadLn()

    //�����������������������������������������Ŀ
    //� Faz a leitura dos campos no arquivo e a �
    //� atribuicao nas variaveis para gravacao. �
    //�������������������������������������������

	cLinha		:= Alltrim(SubStr( TXT,1,11))  	//Linha que o registro esta localizado no arquivo
	cTipoReg	:= SubStr( TXT,41,2)				//Tipo de Registro(00-Header Geral, 01-Header Parcial, 02-Registro Detalhe, 98-Trailer Parcial, 99-Trailer Geral)
	cCodCampo	:= SubStr( TXT,46,4)				//Codigo do campo (Identifica de que informacao se trata a linha)
	cSeqCampo	:= SubStr( TXT,50,2)				//Sequencial do campo
	cVlCampo	:= Alltrim(SubStr( TXT,54,115))	//Conteudo do campo
	cPIS		:= SubStr( TXT,266,11)			//Numero do PIS em caso de retorno positivo
	cMsgRet		:= SubStr( TXT,277,4)			//Codigo do erro/mensagem de retorno.

	Do Case
		Case cCodCampo == "0313"
			cNomEmpFil := cVlCampo //Codigo que identifica o nome da Empesa/Filial
		Case cCodCampo == "0104"
			//Se existir o campo 0104 (Nome da empresa do header parcial) o tipo da estrutura sera Completa
			//Portanto o nome real da empresa nao estara no campo 0313 e sim no 0104.
			cNomEmpFil := cVlCampo
		Case cCodCampo == "0902"
			If SubStr( TXT,30,11) != "00000000000" //NIS para qualificacao
				lQualific := .T.
			Elseif cPIS != "00000000000"
				cPISOK := cPIS
				lGravaPIS := .T.
			Endif
		Case cCodCampo == "0195"
		    cNome := cVlCampo
		Case cCodCampo == "0370"
			cCPF := cVlCampo
			lCPF := .T.
	EndCase

	If cPIS == "00000000000" .And. cMsgRet != "0000"
			//inclui log de erros encontrados
			aAdd( aLog , {  "1ERRO"		, ;
				    		cLinha	    	, ;
							cCodCampo		, ;
				    		cSeqCampo		, ;
				    		cMsgRet		} )
	Endif

	If lGravaPIS .and. lCPF
		//Grava o PIS gerado na SRA
	 	fTRPPIS( cCPF, cPISOK, cNome )
		lGravaPIS := .F.
		lCPF := .F.
		cNome := ""
	Endif

	If cCodCampo == "0292"
		lGravaPIS := .F.
		lCPF := .F.
		cNome := ""
	Endif
	fT_fSkip()
End

//�������������������������������������Ŀ
//� Efetua Gravacao dos dados           �
//���������������������������������������
fGravaSRA()

fT_fUse()

//�������������������������������������Ŀ
//� Chama rotina de Log de Ocorrencias. �
//���������������������������������������
fLogCNIS(aLog)

If oTmpTable <> Nil
	oTmpTable:Delete()
	oTmpTable := Nil
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Cria_TMPC � Autor � Claudinei Soares      � Data �06/03/2015 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria Arquivo Temporario                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Gpem025                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function Cria_TMPC()

Local aStru[03]
Local aOrdem := {}

aStru[01] 	:= {"NUM_CPF"	,"C"		,11		,0}
aStru[02] 	:= {"NUM_PIS"	,"C"		,11		,0}
aStru[03] 	:= {"NOMEFUN"	,"C"		,70		,0}

oTmpTable := FWTemporaryTable():New()
oTmpTable:SetFields( aStru )

aOrdem	:=	{"NUM_CPF","NUM_PIS"}

oTmpTable:AddIndex("IND", aOrdem)
oTmpTable:Create()
cAliasTmp := oTmpTable:GetAlias()

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fTRPPIS	� Autor � Claudinei Soares      � Data �06/03/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua Gravacao dos dados                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � GPEM025  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function fTRPPIS( cCPF, cPISOK, cNome )
dbSelectArea(cAliasTmp)

RecLock(cAliasTmp,.T. )

(cAliasTmp)->NUM_CPF	:= cCPF
(cAliasTmp)->NUM_PIS	:= cPISOK
(cAliasTmp)->NOMEFUN	:= cNome

MsUnlock()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fGravaSRA	� Autor � Claudinei Soares      � Data �06/03/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua Gravacao dos dados                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Gpea210  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function  fGravaSRA()

Local cChave		:= ""
//���������������������������������������������������Ŀ
//� Seta o registro                                   �
//�����������������������������������������������������
DbSelectArea("SRA")
DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())
Begin Transaction
	While !(cAliasTmp)->( EOF() )
		("SRA")->( DbSetOrder( RetOrder( "SRA", "RA_CIC+RA_FILIAL+RA_MAT" )))
		cChave := (cAliasTmp)->(NUM_CPF)
		IF ("SRA")->(dbSeek(cChave))
			While cChave == SRA->RA_CIC
				If Empty(SRA->RA_PIS)
					RecLock( "SRA",.F. )
					//���������������������������������������������������Ŀ
				    //� Efetua Gravacao                                   �
				    //�����������������������������������������������������
				  	&( "SRA->RA_PIS" ) := (cAliasTmp)->NUM_PIS
					MsUnlock()
					//inclui log de funcionarios gravados
					aAdd( aLog , {  "4FUNGRAV"		, ;
						    		SRA->RA_FILIAL 	, ;
									SRA->RA_MAT		, ;
						    		(cAliasTmp)->NOMEFUN		, ;
						    		(cAliasTmp)->NUM_CPF		, ;
			                		(cAliasTmp)->NUM_PIS 		} )
			   	Else
					//inclui log de funcionarios nao gravados por ja estarem com pis preenchido
					aAdd( aLog , {  "2FUNCOMPIS"	, ;
						    		SRA->RA_FILIAL 	, ;
									SRA->RA_MAT		, ;
						    		(cAliasTmp)->NOMEFUN		, ;
						    		(cAliasTmp)->NUM_CPF		, ;
		        	        		(cAliasTmp)->NUM_PIS 		} )
				Endif
		    	SRA->( dbSkip() )
		    Enddo
		Else
			//inclui no log de funcionario nao gravados por CPF nao ter sido encontrado
			aAdd( aLog , {  "3FUNNAOCPF"	, ;
				    		(cAliasTmp)->NOMEFUN		, ;
				    		(cAliasTmp)->NUM_CPF		, ;
			           		(cAliasTmp)->NUM_PIS 		} )
		Endif
		(cAliasTmp)->( dbSkip() )
	Enddo
End Transaction
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetDireLer�Autor  � Claudinei Soares   � Data � 06/03/2015  ���
�������������������������������������������������������������������������͹��
���Desc.     � Usado no Pergunte para indicar o diretorio a ser gerado o  ���
���          � arquivo texto.                                             ���
�������������������������������������������������������������������������͹��
���Uso       � GPEM024                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GetDireLer()

Local mvRet:=Alltrim(ReadVar())
Local cFile

oWnd   := GetWndDefault()
cFile 	:= cGetFile(OemToAnsi(STR0022),OemToAnsi(STR0023), ,,.T.,GETF_LOCALHARD + GETF_LOCALFLOPPY)  // "Arquivo Texto" "Selecione o arquivo "

If Empty(cFile)
	Return(.F.)
Endif

cDrive := Alltrim(Upper(cFile))

&mvRet := cFile

If oWnd != Nil
	GetdRefresh()
EndIf

Return( .T. )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fLogCNIS  �Autor  � Claudinei Soares   � Data � 06/03/2015  ���
�������������������������������������������������������������������������͹��
���Desc.     � Emissao do Log de Ocorrencias                              ���
�������������������������������������������������������������������������͹��
���Parametros� aLog -> Log com as Ocorrencias Encontradas       		  ���
�������������������������������������������������������������������������͹��
���Uso       � GPEM025                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function fLogCNIS( aLog )
Local aNewLog		:= {}
Local nLenLog		:= Len(aLog)
Local nLoop		:= 1
Local nPosGrav	:= 0
Local cGrupo		:= ""

//-- Ordena por Ocorrencias
aSort( @aLog , NIL , NIL , { |x,y| ( x[1]+x[2]+x[3] < y[1]+y[2]+y[3] ) } )

//-- Corre todas as Ocorrencias e as trata conforme os tipos identificados
For nLoop:= 1 to nLenLog
	If aLog[nLoop,1] == "1ERRO" //Registros com mensagens
			If cGrupo <> "1ERRO"
	    		cGrupo	:= "1ERRO"
			    AADD(aNewLog, "")
			    AADD(aNewLog, "")
			    AADD(aNewLog, Space(2) + STR0007) // "Registros retornados com avisos, favor verificar o Anexo IV do leiaute do CNIS"
			    AADD(aNewLog, "")
			    AADD(aNewLog, Space(2) + STR0012 + Space(12) + STR0013 + Space(5) + STR0014 + Space(4) + STR0015 +Space(1) ) // "Linha + Campo + Sequencia + Num. Mensagem"
			Endif
	    AADD(aNewLog, Space(2) + aLog[nLoop, 2] + Space(7) + aLog[nLoop, 3]+ Space(6) + aLog[nLoop, 4]+ Space(10) + aLog[nLoop, 5] )
	ElseIf aLog[nLoop,1] == "2FUNCOMPIS" //Funcionarios que ja possuiam PIS cadastrados na SRA
			If cGrupo <> "2FUNCOMPIS"
	    		cGrupo	:= "2FUNCOMPIS"
			    AADD(aNewLog, "")
			    AADD(aNewLog, "")
			    AADD(aNewLog, Space(2) + STR0008 ) // "Funcionarios com PIS retornado no arquivo, mas que n�o foram importados por j� possuirem n�mero de PIS cadastrado"
			    AADD(aNewLog, "")
			    AADD(aNewLog, Space(2) + STR0016 + Space(8) + STR0017 + Space(3) + STR0018 + Space(71) + STR0019 + Space(13) + STR0020  ) //Filial + Matricula + Nome + CPF + PIS
		    Endif
		    AADD(aNewLog, Space(2) + aLog[nLoop, 2] + Space(6) + aLog[nLoop, 3]+ Space(6) +aLog[nLoop, 4]+ Space(5) +aLog[nLoop, 5]+ Space(5)+aLog[nLoop, 6] )
	ElseIf aLog[nLoop,1] == "3FUNNAOCPF" //Numero de CPF nao encontrado na tabela SRA
			If cGrupo <> "3FUNNAOCPF"
	    		cGrupo	:= "3FUNNAOCPF"
			    AADD(aNewLog, "")
			    AADD(aNewLog, "")
			    AADD(aNewLog, Space(2) + STR0009) // "Funcion�rios com PIS retornado no arquivo, mas que n�o foram importados, CPF informado no arquivo n�o encontrado na tabela SRA"
			    AADD(aNewLog, "")
			    AADD(aNewLog, Space(2) + STR0018 + Space(72) + STR0019 + Space(13) + STR0020  ) // "Nome + CPF + PIS
			Endif
	    AADD(aNewLog, Space(2) + aLog[nLoop, 2] + Space(6) + aLog[nLoop, 3]+ Space(6) +aLog[nLoop, 4] )
 	ElseIf aLog[nLoop,1] == "4FUNGRAV"  // Funcionarios com PIS gravados com sucesso
	    If cGrupo <> "4FUNGRAV"
	    	cGrupo	:= "4FUNGRAV"
		    AADD(aNewLog, "")
		    AADD(aNewLog, "")
		    AADD(aNewLog, Space(2) + STR0010 ) // Funcionarios com PIS retornado no arquivo e gravados com sucesso
		    AADD(aNewLog, "")
		    AADD(aNewLog, Space(2) + STR0016 + Space(8) + STR0017 + Space(3) + STR0018 + Space(71) + STR0019 + Space(13) + STR0020  ) // "Filial + Matr�cula + Nome + CPF + PIS"
	    Endif
		    AADD(aNewLog, Space(2) + aLog[nLoop, 2] + Space(6) + aLog[nLoop, 3]+ Space(6) +aLog[nLoop, 4]+ Space(5) +aLog[nLoop, 5]+ Space(5)+aLog[nLoop, 6] )
 	Endif
Next nLoop

nPosGrav := aScan(aLog, { |x| x[1] $ "4FUNGRAV"})
If nPosGrav == 0
	AADD(aNewLog, "")
    AADD(aNewLog, "")
    AADD(aNewLog, Space(2) + STR0011 ) // "Nenhum PIS foi importado para a tabela SRA"
Endif

aLog:= {}

If !Empty(aNewLog)
	AAdd(aLog, aClone(aNewLog) )
    fMakeLog( aLog , aTitle  ,       ,     ,"GPEM025"   ,OemToAnsi(STR0003), "M", "P",, .F.)   //"Log de Ocorrencias - CNIS"
EndIf

Return( NIL )