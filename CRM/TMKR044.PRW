#INCLUDE "TMKR044.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMKR044   �Autor  �Armando M. Tessaroli� Data �  16/12/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Relatorio de impressao dos dados da consulta do perfil do   ���
���          �contato.                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMKR044(oExplorer, aEmpCont)
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local wnrel   	:= "TMKR044"  	 	// Nome do Arquivo utilizado no Spool
Local Titulo 	:= STR0001 			//"Emiss�o do Perfil do Contato"
Local cDesc1 	:= STR0002 			//"Este programa ira emitir os dados da consulta do perfil do contato,"
Local cDesc2 	:= STR0003 			//"considerando os dados que est�o apresentados em v�deo."
Local cDesc3 	:= STR0004 			//"A emiss�o ocorrer� baseada nos par�metros informados para o relat�rio."
Local nomeprog	:= "TMKR044.PRX"	// nome do programa
Local cString 	:= "SU5"			// Alias utilizado na Filtragem
Local lDic    	:= .F. 				// Habilita/Desabilita Dicionario
Local lComp   	:= .F. 				// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro 	:= .F. 				// Habilita/Desabilita o Filtro

Private Tamanho := "G" 				// P/M/G
Private Limite  := 220 				// 80/132/220
Private aReturn := { STR0005,;		//[1] Reservado para Formulario		 //"Zebrado"
					 1,;			//[2] Reservado para N� de Vias
					 STR0006,;		//[3] Destinatario				 //"Administracao"
					 2,;			//[4] Formato => 1-Comprimido 2-Normal	
					 2,;	    	//[5] Midia   => 1-Disco 2-Impressora
					 1,;			//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
					 "",;			//[7] Expressao do Filtro
					 1 } 			//[8] Ordem a ser selecionada
					 				//[9]..[10]..[n] Campos a Processar (se houver)
Private m_pag   := 1  				// Contador de Paginas
Private nLastKey:= 0  				// Controla o cancelamento da SetPrint e SetDefault
Private cPerg   := "TMK044"  		// Pergunta do Relatorio
Private aOrdem  := {}  				// Ordem do Relatorio

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("TMK044",.F.)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� Mv_Par01           // Imprime Contato                        �
//� Mv_Par02           // Imprime Empresa                        �
//� Mv_Par03           // Imprime Marketing                      �
//� Mv_Par04           // Imprime Field Service                  �
//����������������������������������������������������������������

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)

If (nLastKey == 27)
	DbSelectArea(cString)
	DbSetOrder(1)
	DbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)

If (nLastKey == 27)
	DbSelectArea(cString)
	DbSetOrder(1)
	DbClearFilter()
	Return
Endif

RptStatus({|lEnd| TKR044Imp(@lEnd,wnRel,cString,nomeprog,Titulo,oExplorer, aEmpCont)},Titulo)

Return(.T.)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TKR044Imp �Autor  �Armando M. Tessaroli� Data �  16/12/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao dos dados do relatorio.               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TKR044Imp(lEnd,wnrel,cString,nomeprog,Titulo,oExplorer,aEmpCont)

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao Do Cabecalho e Rodape    �
//����������������������������������������������������������������
Local cbCont	:= 0			// Numero de Registros Processados
Local cbText	:= SPACE(10)	// Mensagem do Rodape

SetRegua(4)		// Total de Elementos da regua

//��������������������������������������������������������������Ŀ
//� Imprime os dados do contato                                  �
//����������������������������������������������������������������
IncRegua()
If Mv_Par01 == 1
	TMKR044A(lEnd,wnrel,cString,nomeprog,Titulo,oExplorer,aEmpCont)
Endif

//��������������������������������������������������������������Ŀ
//� Imprime os dados da entidade                                 �
//����������������������������������������������������������������
IncRegua()
If Mv_Par02 == 1
	TMKR044B(lEnd,wnrel,cString,nomeprog,Titulo,oExplorer,aEmpCont)
Endif

//��������������������������������������������������������������Ŀ
//� Imprime os dados de marketing                                �
//����������������������������������������������������������������
IncRegua()
If Mv_Par03 == 1
	TMKR044C(lEnd,wnrel,cString,nomeprog,Titulo,oExplorer,aEmpCont)
Endif

//��������������������������������������������������������������Ŀ
//� Imprime os dados de chamado tecnico                          �
//����������������������������������������������������������������
IncRegua()
If Mv_Par04 == 1
	TMKR044D(lEnd,wnrel,cString,nomeprog,Titulo,oExplorer,aEmpCont)
Endif

Roda(cbCont,cbText,Tamanho)

Set Device To Screen
If ( aReturn[5] = 1 )
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return(.T.)
