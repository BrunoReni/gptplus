#INCLUDE "TMKR030.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKR030  � Autor � Armando M. Tessaroli  � Data � 19/03/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de operadores por posto de vendas                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Call Center                                                ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Conrado Q.�04/08/06� 8.11 � Bops. 99200 Conversao para relatorio perso-���
���          �        �      � nalizado (Release 4)                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKR030()

Local oReport				// Objeto utilizado para a criacao do relatorio
Local aArea := GetArea()   // Armazena a area atual

If !TRepInUse()  

	//��������������������������������Ŀ
	//�Executa versao anterior do fonte�
	//����������������������������������
	TMKR030R3()
Else
    /* Como nao localizei nenhuma pergunta para o relatorio TMK030 vou comentar as linhas abaixo */
    /*
	//���������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                          �
	//� Mv_Par01           // Do Evento                               �
	//� Mv_Par02           // Ate Evento                              �
	//�����������������������������������������������������������������
	Pergunte("TMK030",.F.)
	*/

	//����������������������Ŀ
	//�Interface de impressao�
	//������������������������
	oReport := Tkr030RptDef()
	oReport:PrintDialog()
EndIf

RestArea( aArea )
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKR030R3� Autor � Armando M. Tessaroli  � Data � 19/03/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de operadores por posto de vendas                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Call Center                                                ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Tmkr030R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local wnrel   	:= "TMKR030"  	 	// Nome do Arquivo utilizado no Spool
Local Titulo 	:= STR0001			// "Listagem de Operadores por Grupo de Atendimento"
Local cDesc1	:= STR0002			// "Este Programa ir� emitir uma listagem de todos os Operadores"
Local cDesc2	:= STR0003			// "agupados por Grupo de Atendimento"
Local cDesc3	:= ""
Local nomeprog	:= "TMKR030.PRX"	 // nome do programa
Local cString 	:= "SU0"			 // Alias utilizado na Filtragem
Local lDic    	:= .F. 				 // Habilita/Desabilita Dicionario
Local lComp   	:= .F. 				 // Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro 	:= .T. 				 // Habilita/Desabilita o Filtro
Local aPDFields	:= {}

Private Tamanho := "G" 				 // P/M/G
Private Limite  := 220 				 // 80/132/220
Private aReturn := { STR0004,;		 // [1] Reservado para Formulario	//"Zebrado"
					 1,;			 // [2] Reservado para N� de Vias
					 STR0005,;		 // [3] Destinatario				//"Administracao"
					 2,;			 // [4] Formato => 1-Comprimido 2-Normal	
					 2,;	    	 // [5] Midia   => 1-Disco 2-Impressora
					 1,;			 // [6] Porta ou Arquivo 1-LPT1... 4-COM1...
					 "",;			 // [7] Expressao do Filtro
					 1 } 			 // [8] Ordem a ser selecionada
					 				 // [9]..[10]..[n] Campos a Processar (se houver)
Private m_pag   := 1  				 // Contador de Paginas
Private nLastKey:= 0  				 // Controla o cancelamento da SetPrint e SetDefault
Private cPerg   := NIL  	 		 // Pergunta do Relatorio
Private aOrdem  := {}  				 // Ordem do Relatorio


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

// Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
aPDFields := {"U7_NREDUZ","U7_NOME","U7_END"}
FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)

RptStatus({|lEnd| TR030Imp(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)

//Finaliza o gerenciamento dos campos com prote��o de dados.
FATPDUnLoad()  

Return(.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � TR030Imp �Autor  �Armando M. Tessaroli� Data �  19/03/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Executa a impress�o dos dados                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 - Call Center                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TR030Imp(lEnd,wnrel,cString,nomeprog,Titulo)

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao Do Cabecalho e Rodape    �
//����������������������������������������������������������������
Local nLi		:= 0			// Linha a ser impressa
Local nMax		:= 58			// Maximo de linhas suportada pelo relatorio
Local cbCont	:= 0			// Numero de Registros Processados
Local cbText	:= SPACE(10)	// Mensagem do Rodape
Local cCabec1	:= "" 			// Label dos itens
Local cCabec2	:= "" 			// Label dos itens

//�������������������������������������������������������Ŀ
//�Declaracao de variaveis especificas para este relatorio�
//���������������������������������������������������������
Local cSU0			:= "SU0"						// Gerencia o alias para top e dbf
Local cSU7			:= "SU7"						// Gerencia o alias para top e dbf
Local cPosto		:= ""							// Quebra por posto de atendimento
Local aU0_Bound		:= TkSx3Box("U0_BOUND")			// Busca as opcoes do campo do dd SX3
Local aU0_TipoCTI	:= TkSx3Box("U0_TIPOCTI")		// Busca as opcoes do campo do dd SX3
Local aU0_UsaMail	:= TkSx3Box("U0_USAMAIL")		// Busca as opcoes do campo do dd SX3
Local aU0_UsaAgen	:= TkSx3Box("U0_USAAGEN")		// Busca as opcoes do campo do dd SX3
Local aU0_Descont	:= TkSx3Box("U0_DESCONT")		// Busca as opcoes do campo do dd SX3
Local aU0_Acresci	:= TkSx3Box("U0_ACRESCI")		// Busca as opcoes do campo do dd SX3
Local aU0_AvalCre	:= TkSx3Box("U0_AVALCRE")		// Busca as opcoes do campo do dd SX3
Local aU0_AvalEst	:= TkSx3Box("U0_AVALEST")		// Busca as opcoes do campo do dd SX3
Local aU7_TipoAte	:= TkSx3Box("U7_TIPOATE")		// Busca as opcoes do campo do dd SX3
Local aU7_Vend		:= TkSx3Box("U7_VEND")			// Busca as opcoes do campo do dd SX3


Local aSetField		:= {}		// Parametros para SetField do alias principal
Local cCampos		:= ""		// Campos do alias principal para select
Local cQuery		:= ""		// Armazena a expressao da query para top
Local nI			:= 0		// Contador

DbSelectArea ("SU0")
DbSetOrder(1)
SetRegua(RecCount())

TkSelect(cString, @cCampos, @aSetField)

cSU7 := "SU0"
cQuery :=	" SELECT	" + cCampos + ", " +;
			"			U7_BAIRRO, U7_CEP, U7_COD, U7_CODVEN, U7_END, U7_EST, U7_TAREFA, " +;
			"			U7_FILIAL, U7_HABIL, U7_MUN, U7_NOME, U7_NREDUZ, U7_POSTO, U7_REGIAO, " +;
			"			U7_TIPOATE, U7_VEND " +;
			" FROM " + RetSqlName("SU0") + " SU0, " + RetSqlName("SU7") + " SU7 " +;
			" WHERE	SU0.U0_FILIAL = '" + xFilial("SU0") + "' AND" +;
			"		SU0.D_E_L_E_T_ = ' ' AND" +;
			"		SU7.U7_FILIAL = '" + xFilial("SU7") + "' AND" +;
			"		SU7.U7_POSTO = SU0.U0_CODIGO AND" +;
			"		SU7.D_E_L_E_T_ = ' '" +;
			" ORDER BY U7_FILIAL, U7_POSTO, U7_COD"
	
cQuery	:= ChangeQuery(cQuery)
// MemoWrite("TMKR030.SQL", cQuery)
DbSelectArea("SU0")
DbCloseArea()
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SU0', .F., .T.)

For nI := 1 To Len(aSetField)
	TCSetField(cString, aSetField[nI][1], aSetField[nI][2], aSetField[nI][3], aSetField[nI][4])
Next nI

While	(!Eof()) .AND.;
		SU0->U0_FILIAL == xFilial("SU0")
	
	IncRegua()
	
	If lEnd
		@Prow()+1,000 PSay STR0007 //"CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	//��������������������������������������������������������������Ŀ
	//� Considera filtro do usuario                                  �
	//����������������������������������������������������������������
	If (!Empty(aReturn[7])) .AND. (!&(aReturn[7]))
		DbSkip()
		Loop
	Endif
	
	If cPosto <> (cSU0)->U0_CODIGO
		cPosto := (cSU0)->U0_CODIGO
		
		//�����������������������������������������������������������Ŀ
		//�Funcao que incrementa a linha e verifica a quebra de pagina�
		//�������������������������������������������������������������
		TkIncLine(@nLi,3,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay __PrtFatLine()
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000			PSay PadR(STR0008,15) //"Posto"
		@ nLi,PCol()+1		PSay PadR((cSU0)->U0_CODIGO,38) 
		@ nLi,Limite/4		PSay PadR(STR0009,15) //"Descricao"
		@ nLi,PCol()+1		PSay PadR((cSU0)->U0_NOME,38)
		@ nLi,Limite/4*2	PSay PadR(STR0010,15) //"T.M.Atendimento"
		@ nLi,PCol()+1		PSay PadR((cSU0)->U0_TEMPCRO,38)
		@ nLi,Limite/4*3	PSay PadR(STR0011,15) //"Ligacoes"
		@ nLi,PCol()+1		PSay PadR(IIF(Val((cSU0)->U0_Bound)>0,aU0_Bound[Val((cSU0)->U0_Bound)],""),38)
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000			PSay PadR(STR0012,15) //"Hardware"
		@ nLi,PCol()+1		PSay PadR(IIF(Val((cSU0)->U0_TIPOCTI)>0,aU0_TipoCTI[Val((cSU0)->U0_TIPOCTI)],""),38)
		@ nLi,Limite/4		PSay PadR(STR0013,15) //"Linha Externa"
		@ nLi,PCol()+1		PSay PadR((cSU0)->U0_EXTERNA,38)
		@ nLi,Limite/4*2	PSay PadR(STR0014,15) //"Operadora do UF"
		@ nLi,PCol()+1		PSay PadR((cSU0)->U0_OPEREST,38)
		@ nLi,Limite/4*3	PSay PadR(STR0015,15) //"Operad. Fora UF"
		@ nLi,PCol()+1		PSay PadR((cSU0)->U0_OPEFEST,38)
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000			PSay PadR(STR0016,15) //"Envia e-mail"
		@ nLi,PCol()+1		PSay PadR(IIF(Val((cSU0)->U0_USAMAIL)>0,aU0_UsaMail[Val((cSU0)->U0_USAMAIL)],""),38)
		@ nLi,Limite/4		PSay PadR(STR0017,15) //"Envia Tarefa"
		@ nLi,PCol()+1		PSay PadR(IIF(Val((cSU0)->U0_USAAGEN)>0,aU0_UsaAgen[Val((cSU0)->U0_USAAGEN)],""),38)
		@ nLi,Limite/4*2	PSay PadR(STR0018,15) //"Config. TMK"
		@ nLi,PCol()+1		PSay PadR((cSU0)->U0_CONFTMK,38)
		@ nLi,Limite/4*3	PSay PadR(STR0019,15) //"Estacao"
		@ nLi,PCol()+1		PSay PadR((cSU0)->U0_ESTACAO,38)
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000			PSay PadR(STR0020,15) //"Desconto"
		@ nLi,PCol()+1		PSay PadR(IIF(Val((cSU0)->U0_DESCONT)>0,aU0_Descont[Val((cSU0)->U0_DESCONT)],""),38)
		@ nLi,Limite/4		PSay PadR(STR0021,15) //"Acrescimo"
		@ nLi,PCol()+1		PSay PadR(IIF(Val((cSU0)->U0_ACRESCI)>0,aU0_Acresci[Val((cSU0)->U0_ACRESCI)],""),38)
		@ nLi,Limite/4*2	PSay PadR(STR0022,15) //"Avalia Credito"
		@ nLi,PCol()+1		PSay PadR(IIF(Val((cSU0)->U0_AVALCRE)>0,aU0_Avalcre[Val((cSU0)->U0_AVALCRE)],""),38)
		@ nLi,Limite/4*3	PSay PadR(STR0023,15) //"Avalia Estoque"
		@ nLi,PCol()+1		PSay PadR(IIF(Val((cSU0)->U0_AVALEST)>0,aU0_Avalest[Val((cSU0)->U0_AVALEST)],""),38)
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay __PrtThinLine()
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay STR0024 //"Codigo   Nome                             Nome Reduzido          Endereco                         Bairro            Cidade            UF   CEP          Atendimento       Vendedor          Reg  Habilidade             Pend"
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay __PrtThinLine()
		
	Endif
	
	DbSelectArea("SX5")
	DbSetOrder(1)
	MsSeek(xFilial("SX5") + "A4" + (cSU7)->U7_HABIL)
	
	TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000		PSay PadR((cSU7)->U7_COD,6) 
	@ nLi,PCol()+3	PSay PadR(FATPDObfuscate((cSU7)->U7_NOME,"U7_NOME"),30)		
	@ nLi,PCol()+3	PSay PadR(FATPDObfuscate((cSU7)->U7_NREDUZ,"U7_NREDUZ"),20)
	@ nLi,PCol()+3	PSay PadR(FATPDObfuscate((cSU7)->U7_END,"U7_END"),30)
	@ nLi,PCol()+3	PSay PadR((cSU7)->U7_BAIRRO,15)
	@ nLi,PCol()+3	PSay PadR((cSU7)->U7_MUN,15)
	@ nLi,PCol()+3	PSay PadR((cSU7)->U7_EST,2)
	@ nLi,PCol()+3	PSay PadR((cSU7)->U7_CEP,10)
	@ nLi,PCol()+3	PSay PadR(aU7_TipoAte[IIF(Val((cSU7)->U7_TIPOATE)<>0,Val((cSU7)->U7_TIPOATE),4)],15)
	@ nLi,PCol()+3	PSay PadR(aU7_Vend[IIF(Val((cSU7)->U7_VEND)<>0,Val((cSU7)->U7_VEND),2)] + " / " + (cSU7)->U7_CODVEN,15)
	@ nLi,PCol()+3	PSay PadR((cSU7)->U7_REGIAO,2)
	@ nLi,PCol()+3	PSay PadR(X5DESCRI(),20)
	@ nLi,PCol()+3	PSay PadR((cSU7)->U7_TAREFA,4)
			
	DbSelectArea("SU0")
	DbSkip()
End

If nLi == 0
	TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi+1,000 PSay STR0025 //"Nao ha informacoes para imprimir este relatorio de acordo com os parametros informados"
Endif

Roda(cbCont,cbText,Tamanho)


DbSelectArea("SU0")
DbCloseArea()
ChkFile("SU0")

Set Device To Screen
If ( aReturn[5] = 1 )
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return(.T.)

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �Tkr030RptDef �Autor  �Conrado Q. Gomes    � Data �  04/08/06   ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela-  ���
���          �latorio                                                        ���
����������������������������������������������������������������������������͹��
���Uso       � TMKR030 R4                                                    ���
����������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                            ���
����������������������������������������������������������������������������͹��
���          �        �      �                                               ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function Tkr030RptDef()
Local oReport			// Objeto do relatorio
Local oSection1			// Objeto da secao 1
Local oSection2			// Objeto da secao 2
Local cSU7 := "SU7"		// Alias da consulta Embedded SQL


cSU7:=GetNextAlias()

//�������������������������������������������������������������������Ŀ
//�Gera a tela com os dados para a confirma��o da geracao do relatorio�
//���������������������������������������������������������������������

// "Listagem de Operadores por Grupo de Atendimento"
// "Este Programa ir� emitir uma listagem de todos os Operadores" # "agupados por Grupo de Atendimento"
DEFINE REPORT oReport NAME "TMKR030" TITLE STR0001 /*PARAMETER "TMK030"*/ ACTION {|oReport| Tkr030PrtRpt(oReport, cSU7)} DESCRIPTION STR0002 + STR0003

//����������������������������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal utlizado eh o SU0�
//������������������������������������������������������������������������������������
DEFINE SECTION oSection1 OF oReport TITLE STR0027 TABLES "SU0"	// "Campanhas"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//�����������������������������������������������              
DEFINE CELL NAME "U0_CODIGO"	OF oSection1 ALIAS "SU0"
DEFINE CELL NAME "U0_NOME"		OF oSection1 ALIAS "SU0"
DEFINE CELL NAME "U0_TEMPCRO"	OF oSection1 ALIAS "SU0"
DEFINE CELL NAME "U0_BOUND"		OF oSection1 ALIAS "SU0"	
DEFINE CELL NAME "U0_TIPOCTI"	OF oSection1 ALIAS "SU0" 
DEFINE CELL NAME "U0_EXTERNA"	OF oSection1 ALIAS "SU0"
DEFINE CELL NAME "U0_OPEREST"	OF oSection1 ALIAS "SU0"
DEFINE CELL NAME "U0_OPEFEST"	OF oSection1 ALIAS "SU0"
DEFINE CELL NAME "U0_USAMAIL"	OF oSection1 ALIAS "SU0" 
DEFINE CELL NAME "U0_USAAGEN"	OF oSection1 ALIAS "SU0"
DEFINE CELL NAME "U0_CONFTMK"	OF oSection1 ALIAS "SU0"
DEFINE CELL NAME "U0_ESTACAO"	OF oSection1 ALIAS "SU0"
DEFINE CELL NAME "U0_DESCONT"	OF oSection1 ALIAS "SU0" 
DEFINE CELL NAME "U0_ACRESCI"	OF oSection1 ALIAS "SU0" 
DEFINE CELL NAME "U0_AVALCRE"	OF oSection1 ALIAS "SU0" 
DEFINE CELL NAME "U0_AVALEST"	OF oSection1 ALIAS "SU0"

//���������������������������������Ŀ
//�N�o quebra a p�gina a cada se��o.�
//�����������������������������������
oSection1:SetPageBreak(.F.) 

//�������������������������������������Ŀ
//�Exibi��o em modo vertical da colunas.�
//���������������������������������������
oSection1:SetLineStyle()

//�������������������������������������������������������������������������������������Ŀ
//�Define a secao2 (que sera filha da secao1)  e o arquivo principal utilizado na secao �
//���������������������������������������������������������������������������������������
DEFINE SECTION oSection2 OF oSection1 TITLE STR0028 TABLES "SU7"	// "Operadores"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao2�
//�����������������������������������������������            
DEFINE CELL NAME "U7_COD"  		OF oSection2 ALIAS "SU7"
DEFINE CELL NAME "U7_NOME"		OF oSection2 ALIAS "SU7"
DEFINE CELL NAME "U7_NREDUZ"	OF oSection2 ALIAS "SU7"
DEFINE CELL NAME "U7_END"		OF oSection2 ALIAS "SU7"
DEFINE CELL NAME "U7_BAIRRO"	OF oSection2 ALIAS "SU7"
DEFINE CELL NAME "U7_MUN"		OF oSection2 ALIAS "SU7"
DEFINE CELL NAME "U7_EST"		OF oSection2 ALIAS "SU7"
DEFINE CELL NAME "U7_CEP"		OF oSection2 ALIAS "SU7"
DEFINE CELL NAME "U7_TIPOATE"	OF oSection2 ALIAS "SU7"
DEFINE CELL NAME "U7_VEND"		OF oSection2 ALIAS "SU7"
DEFINE CELL NAME "U7_CODVEN"	OF oSection2 ALIAS "SU7"
DEFINE CELL NAME "U7_REGIAO"	OF oSection2 ALIAS "SU7"
DEFINE CELL NAME ""				OF oSection2 TITLE STR0026	BLOCK {||(cSU7)->U7_HABIL + " - " + ;
  						Posicione("SX5",1,xFilial("SX5") + "A4" + (cSU7)->U7_HABIL,"X5DESCRI()")}
DEFINE CELL NAME "U7_TAREFA"	OF oSection2 ALIAS "SU7"
                   
//����������������������������������������������������������
//�Quebra a linha se o cabe�alho/conte�do atingir a largura�
//�m�xima.                                                 �
//����������������������������������������������������������
oSection2:SetLineBreak()

Return oReport

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �TKR030PrtRpt�Autor  �Conrado Q. Gomes    � Data �  04/08/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio personalizavel             ���
���������������������������������������������������������������������������͹��
���Uso       � TMKR030 R4                                                   ���
���������������������������������������������������������������������������͹��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������͹��
���Parametros� oReport: Objeto TReport do relatorio                         ���
���          � cAlias1: Alias criado para a utilizacao com o relatorio      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/              
Static Function TKR030PrtRpt( oReport, cAlias1 )
Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
Local oSection2 := oSection1:Section(1)				// Define que a secao 2 serah filha da secao 1
Local cFiltro	:= ""								// Variavel utilizada para o filtro
Local cIndex										// Nome do indice temporario U7_FILIAL+U7_POSTO+U7_COD
Local nIndex										// Numero do indice temporario


DbSelectArea("SU0")
DbSetOrder(1)

//������������������������������������������������������������
//�Transforma parametros do tipo Range em expressao SQL      �
//�para ser utilizada na query  Exemplo Word, nao intervalos �
//�pre definidos (mais utilizado pelo RH - Ferias)           �
//������������������������������������������������������������
MakeSqlExpr("TMK030")

//��������������������Ŀ
//�Inicializa a se��o 1�
//����������������������
BEGIN REPORT QUERY oSection1

//����������������Ŀ
//�Query da se��o 1�
//������������������
BeginSql alias cAlias1
	SELECT	U0_FILIAL,	U0_CODIGO,	U0_NOME,	U0_TEMPCRO, 
			U0_BOUND,	U0_TIPOCTI,	U0_EXTERNA, U0_OPEREST, 
			U0_OPEFEST,	U0_USAMAIL,	U0_USAAGEN, U0_CONFTMK,	
			U0_ESTACAO,	U0_DESCONT, U0_ACRESCI,	U0_AVALCRE,	
			U0_AVALEST,	U7_BAIRRO,	U7_CEP, 	U7_COD, 	
			U7_CODVEN,	U7_END, 	U7_EST, 	U7_TAREFA,	
			U7_FILIAL,	U7_HABIL, 	U7_MUN, 	U7_NOME,	  
			U7_NREDUZ, 	U7_POSTO, 	U7_REGIAO,	U7_TIPOATE, 
			U7_VEND
			
	FROM	%table:SU0% SU0,%table:SU7% SU7          
	
	WHERE	U0_FILIAL	=	%xfilial:SU0%	AND
			U7_FILIAL	=	%xfilial:SU7%	AND
			U7_POSTO	=	U0_CODIGO		AND
			SU0.%notDel%					AND
			SU7.%notDel%

	ORDER BY %Order:SU0%
EndSql


//�������������������Ŀ
//�Finaliza a se��o 1.�
//���������������������
END REPORT QUERY oSection1 
           
oSection2:SetParentQuery()
oSection2:SetParentFilter({|cParam| (cAlias1)->U7_POSTO == cParam},{|| (cAlias1)->U0_CODIGO})

//��������������������������������������������Ŀ
//�Quebra a linha, caso existam muitas colunas.�
//����������������������������������������������
oSection1:SetLineBreak()

//���������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou �
//�query.                                                   �
//�����������������������������������������������������������
oSection1:Print()


Return

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usu�rio utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que ser�o verificados.
    @param aFields, Array, Array com todos os Campos que ser�o verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com prote��o de dados.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun��o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive