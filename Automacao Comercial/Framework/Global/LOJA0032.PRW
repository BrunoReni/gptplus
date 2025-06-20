#INCLUDE "MSOBJECT.CH" 
#INCLUDE "AUTODEF.CH"

#DEFINE NOMEARQUIVO "ljecf" + IF(!FindFunction("STFGetStation"),  LjGetStation("LG_CODIGO"), STFGetStation("LG_CODIGO")) + ".log"		//Nome do arquivo de log do ecf
#DEFINE PATH "\log\Ecf" + cEmpAnt + cFilAnt							//Diretorio onde sera gravado os arquivos de log.

Function LOJA0032 ; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCLogEcf        �Autor  �Vendas Clientes     � Data �  04/08/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em gravar o log de Ecf.		                 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCLogEcf From LJALog
			
	Data lHabilitad									//Se a gravacao do log esta habilitada
	Method New()									//Metodo construtor
	Method Gravar(cTexto)							//Metodo que ira gravar o arquivo de log de integracao    

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  04/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCLogEcf.					          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto												      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCLogEcf
	
	Local cLog := 0								//Identifica se o log esta habilitado
	//Executa o metodo construtor da classe pai.
	::ALog()
	
	::cNomeArq 	:= NOMEARQUIVO 
	::cPath		:= StrTran(AllTrim(PATH), space(1), "")
		
	If GetRemoteType() == REMOTE_LINUX
		::cPath := StrTran(::cPath, "/", "\")	
	EndIf
	cLog := GetPvProfString("Log", "LogEcf", "0", GetClientDir() + "TOTVSAPI.INI")
	
	::lHabilitad := (cLog == "1")
		
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Gravar    �Autor  �Vendas Clientes     � Data �  04/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em gravar o arquivo de log de integracao.		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTexto) - Texto a ser gravado.					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico												      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Gravar(cTexto) Class LJCLogEcf
	
	Local lRetorno := .T.						//Variavel de retorno do metodo
			
	If ::lHabilitad		
		//Chama o metodo da classe pai para gravar o arquivo
		lRetorno := _Super:Gravar(cTexto)
	EndIf
			
Return lRetorno
