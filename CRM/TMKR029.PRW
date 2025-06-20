#INCLUDE "TMKR029.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#DEFINE CRLF CHR(13)+CHR(10)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKR029  � Autor � Rafael M. Quadrotti   � Data � 30/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Respostas de Scripts                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Call Center - Relatorios 			                      ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Andrea F. �11/05/04�811   �Revisao do Fonte e inclusao de novos campos ���
���          �        �      �no cabecalho.                               ���
���Michel W. �29/08/06�99199 �Atualizacao relatorios release 4.           ���    
���Tatiana C.�06/10/06�109497�Chamada a variavel cAntPerg                 ���
���			 �        �		 �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
Function TMKR029()
Local oReport	//Objeto relatorio TReport (Release 4)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("TMK029",.F.)
//�������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                 			  �
//� mv_par01            // Do Atendimento                             �
//� mv_par02            // Ate o Atendimento                          �
//� mv_par03            // Entidade                                   �
//� mv_par04            // Da chave                                   �
//� mv_par05            // Ate a chave                                �
//� mv_par06            // Data Inicial                               �
//� mv_par07            // Data Final                                 �
//� mv_par08            // Operacao                                   �
//� mv_par09            // Produto                                    �
//� mv_par10 - Mv_par17 // Segmento 01 - 08                           �
//���������������������������������������������������������������������
	
//����������������������Ŀ
//�Interface de impressao�
//������������������������
oReport := ReportDef()
oReport:PrintDialog() 

Return(.T.)

/*
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Tk029ValAtend � Autor � Rafael M. Quadrotti� Data �21/06/2003���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o atendimento (data, cliente...)                     ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tk029ValAtend(cAtend,cCampanha,dAtend,cACI)                 ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � TMKR029                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Tk029ValAtend(cAtend, cCampanha, dAtend, cACI, cFilSUO)
Local lRet		:= .F.
Local nOper	:= 0
Local aArea	:= GetArea()
Local cAlias	:= ""

Default cFilSUO	:= xFilial("SUO")

IF (cACI)->ACI_ROTINA=="1"
	cAlias := "SUC"
ElseIf (cACI)->ACI_ROTINA=="2"
	cAlias := "SUA"
ElseIf (cACI)->ACI_ROTINA=="3"
	cAlias := "ACF"
ElseIf ( Empty((cACI)->ACI_ROTINA) .AND. Empty((cACI)->ACI_ATEND) ) .or. (cACI)->ACI_ROTINA=="4" // O Script foi executado pela agenda do Operador.
	cAlias := "ACI"
EndIf

If cAlias <> "ACI"
	DbSelectArea(cAlias)
	DbSetOrder(1)
	MsSeek(xFilial(cAlias) + cAtend,.T.)
EndIf

If ((cACI)->ACI_DATA >= Mv_Par06) .AND. ((cACI)->ACI_DATA <= Mv_Par07)
	If cAlias == "SUC"
		nOper:= Val(SUC->UC_OPERACA)
		If (Mv_Par08 == 3) .Or. (nOper == Mv_Par08)
			
			If Tk029ValCli(cACI)
				If Tk029ValProd(cAtend,cAlias)
					dAtend   := (cACI)->ACI_DATA
					cCampanha:= (cACI)->ACI_CODCAM + " - " + Posicione("SUO",1,cFilSUO + (cACI)->ACI_CODCAM,"UO_DESC")
					lRet:= .T.
				EndIf
			EndIf
		EndIf
	ELSEIF cAlias == "SUA"
		
		If Tk029ValCli(cACI)
			If Tk029ValProd(cAtend,cAlias)
				dAtend   := (cACI)->ACI_DATA
				cCampanha:= (cACI)->ACI_CODCAM + " - " + Posicione("SUO",1,cFilSUO + (cACI)->ACI_CODCAM,"UO_DESC")
				lRet:= .T.
			EndIf
		EndIf
	ELSEIF cAlias == "ACF"
		If Tk029ValCli(cACI)
			dAtend   := (cACI)->ACI_DATA
			cCampanha:= (cACI)->ACI_CODCAM + " - " + Posicione("SUO",1,cFilSUO + (cACI)->ACI_CODCAM,"UO_DESC")
			lRet:= .T.
		EndIf
		
	ELSEIF cAlias == "ACI"
		lRet:= .T.
		DbSelectarea("SUA")
		MsSeek("@#$%�&")	// posiciona em eof()
		DbSelectarea("SUC")
		MsSeek("@#$%�&")	// posiciona em eof()
		DbSelectArea((cACI)->ACI_ENTIDA)
		DbSetOrder(1)
		MsSeek((cACI)->ACI_CHAVE)
	EndIf
EndIf

RestArea(aArea)

Return(lRet)

/*
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Tk029ValCli� Autor � Rafael M. Quadrotti   � Data �26/12/2000���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o cliente ()                                         ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tk029ValCli(cACI)                                           ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � TMKR029                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Tk029ValCli(cACI)

Local lRet  := .T.
Local aArea := GetArea()

If (cACI)->ACI_CHAVE >= Mv_Par04 .and. (cACI)->ACI_CHAVE <= Mv_Par05
	IF Trim(Mv_Par03) = "SA1" .or. Trim(Mv_Par03) = "SUS"
		If !Empty(Mv_Par10+Mv_Par11+Mv_Par12+Mv_Par13+Mv_Par14+Mv_Par15+Mv_Par16+Mv_Par17)
			DbSelectArea(Trim(Mv_Par03))
			DbSetOrder(1)
			If MsSeek(xFilial(Trim(Mv_Par03)) + (cACI)->ACI_CHAVE)
				
				If AllTrim(Mv_Par03) == "SA1"
					
					If !Empty(Mv_Par10) .and. SA1->A1_SATIV1 <> Mv_Par10
						lRet:= .F.
					ElseIf !Empty(Mv_Par11) .and. SA1->A1_SATIV2 <> Mv_Par11
						lRet:= .F.
					ElseIf !Empty(Mv_Par12) .and. SA1->A1_SATIV3 <> Mv_Par12
						lRet:= .F.
					ElseIf !Empty(Mv_Par13) .and. SA1->A1_SATIV4 <> Mv_Par13
						lRet:= .F.
					ElseIf !Empty(Mv_Par14) .and. SA1->A1_SATIV5 <> Mv_Par14
						lRet:= .F.
					ElseIf !Empty(Mv_Par15) .and. SA1->A1_SATIV6 <> Mv_Par15
						lRet:= .F.
					ElseIf !Empty(Mv_Par16) .and. SA1->A1_SATIV7 <> Mv_Par16
						lRet:= .F.
					ElseIf !Empty(Mv_Par17) .and. SA1->A1_SATIV8 <> Mv_Par17
						lRet:= .F.
					EndIf
					
				Else
					
					If !Empty(Mv_Par10) .and. SUS->US_SATIV <> Mv_Par10
						lRet:= .F.
					ElseIf !Empty(Mv_Par11) .and. SUS->US_SATIV2 <> Mv_Par11
						lRet:= .F.
					ElseIf !Empty(Mv_Par12) .and. SUS->US_SATIV3 <> Mv_Par12
						lRet:= .F.
					ElseIf !Empty(Mv_Par13) .and. SUS->US_SATIV4 <> Mv_Par13
						lRet:= .F.
					ElseIf !Empty(Mv_Par14) .and. SUS->US_SATIV5 <> Mv_Par14
						lRet:= .F.
					ElseIf !Empty(Mv_Par15) .and. SUS->US_SATIV6 <> Mv_Par15
						lRet:= .F.
					ElseIf !Empty(Mv_Par16) .and. SUS->US_SATIV7 <> Mv_Par16
						lRet:= .F.
					ElseIf !Empty(Mv_Par17) .and. SUS->US_SATIV8 <> Mv_Par17
						lRet:= .F.
					EndIf
					
				EndIF
				
			Else
				lRet:= .F.
			EndIf
		EndIf
	EndIf
	
EndIf

RestArea(aArea)

Return(lRet)

/*
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Tk029ValProd  � Autor � Rafael M. Quadrotti� Data �26/12/2000���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o produto                                            ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tk029ValProd(void)                                          ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � TMKR029                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Tk029ValProd(cAtend,cAlias)  
Local lRet			:= .F.
Local aArea		:= GetArea()
Local cAli2		:= ""
Local cCampo		:= ""
Local cCampo2		:= ""
Local cCampo3		:= ""
Local cFilAli2	:= ""

If cAlias == "SUC"
	cAli2 := "SUD"
ElseIf cAlias == "SUA"
	cAli2 := "SUB"
EndIf

If !Empty(Mv_Par09)
	DbSelectArea(cAli2)
	DbSetOrder(1)
	cFilAli2	:= xFilial(cAli2)
	If MsSeek(cFilAli2 + cAtend)
		cCampo := SubStr(cAli2,2,2)+ "_FILIAL"
		cCampo2:= SubStr(cAli2,2,2)+ "_CODIGO"
		cCampo3:= SubStr(cAli2,2,2)+ "_PRODUTO"
		Do While !Eof() .AND. ((cAli2)->&cCampo) == cFilAli2 .AND. ((cAli2)->&cCampo2 == cAtend)
			If (cAli2)->&cCampo3 == Mv_Par09
				lRet:= .T.
				Exit
			EndIf
			DbSkip()
		EndDo
	EndIf
Else
	lRet:= .T.
EndIf

RestArea(aArea)

Return(lRet)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef � Autor �Michel W. Mosca     � Data �29/08/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina que define os itens que serao apresentados no relato-���
���          �rio de Emissao de repostas de Script no release 4.          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CALL CENTER                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/              
Static Function ReportDef()  
Local oReport					//Objeto relatorio TReport (Release 4)
Local oSection1				//Objeto secao 1 do relatorio (Cabecalho, dados da meta atendimento)
Local oSection2				//Rela��o de campanhas associadas a meta
Local cACI			:= "ACI"	//Alias da consulta Embedded SQL
Local aTamSX3		:= {}		//Array com os Campos x Tamanhos configurados no dicion�rio de dados
Local nTamCell	:= 0		//Tratativa do tamanho para a c�lula, obedecendo a configura��o do tamanho dos campos no dicion�rio de dados
Local cFilSUZ		:= xFilial("SUZ")

aAdd(aTamSX3, {"U5_FCOM1",  GetSx3Cache("U5_FCOM1",  "X3_TAMANHO")})
aAdd(aTamSX3, {"U5_CONTAT", GetSx3Cache("U5_CONTAT", "X3_TAMANHO")})
aAdd(aTamSX3, {"U5_DDD",    GetSx3Cache("U5_DDD",    "X3_TAMANHO")})
aAdd(aTamSX3, {"U5_EMAIL",  GetSx3Cache("U5_EMAIL",  "X3_TAMANHO")})

cACI	:= GetNextAlias()						// Pega o proximo Alias Disponivel	

//"Emiss�o de Respostas de Scripts " # //"Este programa ira emitir uma relacao dos Atendimentos "
//"Call Center relacionados aos Scripts trabalhados e suas" # //"respectivas respostas."
DEFINE REPORT oReport NAME "TMKR029" TITLE STR0001 PARAMETER "TMK029" ACTION {|oReport| Tkr029PrtRpt( oReport, cACI )} DESCRIPTION STR0002 + STR0003 + STR0004

//�����������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal �
//�������������������������������������������������������������������
DEFINE SECTION oSection1 OF oReport TITLE STR0033 TABLES "ACI"		//Dados do Contato
DEFINE SECTION oSection2 OF oSection1 TITLE STR0034 TABLES "SUP"	//Itens do Script Dinamico	

//�������������������������������������������������Ŀ
//�Imprime os dados do Contato .                    �
//���������������������������������������������������  
nTamCell	:= aTamSX3[aScan(aTamSX3, {|x| x[01] == "U5_CONTAT"})][02]
If	nTamCell < 50
	nTamCell := 50  
EndIf
DEFINE CELL NAME "" OF oSection1 Alias "ACI" BLOCK{||ALLTRIM(TkDadosContato((cACI)->ACI_CODCON,6,.T.))}                          TITLE STR0012 SIZE nTamCell //"Contato"
DEFINE CELL NAME "" OF oSection1 Alias "ACI" BLOCK{||ALLTRIM(Posicione("SX2",1,(cACI)->ACI_ENTIDA,"X2NOME()"))}              TITLE STR0013 SIZE 40 //"Entidade"

nTamCell	:= ( aTamSX3[aScan(aTamSX3, {|x| x[01] == "U5_DDD"})][02] + aTamSX3[aScan(aTamSX3, {|x| x[01] == "U5_FCOM1"})][02] + 3)
If	nTamCell < 20
	nTamCell := 20  
EndIf
DEFINE CELL NAME "" OF oSection1 Alias "ACI" BLOCK{||ALLTRIM(TkDadosContato((cACI)->ACI_CODCON,8,.T.)) + " - " +;
                                                     ALLTRIM(TkDadosContato((cACI)->ACI_CODCON,4,.T.))}                          TITLE STR0027 SIZE nTamCell //DDD # "Fone Com.1"

DEFINE CELL NAME "" OF oSection1 Alias "ACI" BLOCK{||ALLTRIM(TkEntidade((cACI)->ACI_ENTIDA,(cACI)->ACI_CHAVE,1,Nil,.T.))}            TITLE STR0014 SIZE 50 //"Nome"

nTamCell	:= aTamSX3[aScan(aTamSX3, {|x| x[01] == "U5_EMAIL"})][02]  
If	nTamCell < 50
	nTamCell := 50
EndIf
DEFINE CELL NAME "" OF oSection1 Alias "ACI" BLOCK{||ALLTRIM(TkDadosContato((cACI)->ACI_CODCON,10,.T.))}                         TITLE STR0028 SIZE nTamCell //"E-Mail"
DEFINE CELL NAME "" OF oSection1 Alias "ACI" BLOCK{||ALLTRIM(TkEntidade((cACI)->ACI_ENTIDA,(cACI)->ACI_CHAVE,9,Nil,.T.)) + " - " +;
                                                     ALLTRIM(TkEntidade((cACI)->ACI_ENTIDA,(cACI)->ACI_CHAVE,6,Nil,.T.))}            TITLE STR0029 SIZE 20 //DDD ## "Telefone"
		
//�������������������������������������������������Ŀ
//�Imprime os dados do Atendimento .                �
//���������������������������������������������������
DEFINE CELL NAME ""         OF oSection1 Alias "ACI" BLOCK{||AllTrim((cACI)->ACI_ATEND) +;
                                                             IF((cACI)->ACI_ROTINA == "1", STR0016,;
                                                                IF((cACI)->ACI_ROTINA == "2", STR0017,;
                                                                   IF((cACI)->ACI_ROTINA == "3", STR0026,;
                                                                      IF(Empty((cACI)->ACI_ROTINA) .AND. Empty((cACI)->ACI_ATEND),STR0018,""))))}      TITLE STR0019 SIZE 30
DEFINE CELL NAME ""         OF oSection1 Alias "ACI" BLOCK{||TkEntidade((cACI)->ACI_ENTIDA,(cACI)->ACI_CHAVE,3)+ "/"+;
                                                             TkEntidade((cACI)->ACI_ENTIDA,(cACI)->ACI_CHAVE,4)}                                       TITLE STR0030 SIZE 40 //"Munic�pio"
DEFINE CELL NAME "S1DATEND" OF oSection1 Alias "ACI"                                                                                                   TITLE STR0020 SIZE 10 //"Data"
DEFINE CELL NAME "ACI_DATA" OF oSection1 Alias "ACI" //"Data da execu��o"
DEFINE CELL NAME "S1CCAMP"  OF oSection1 Alias "ACI"                                                                                                   TITLE STR0022 SIZE 40 //"Campanha"
DEFINE CELL NAME ""         OF oSection1 Alias "ACI" BLOCK{||AllTrim((cACI)->ACI_CODSCR + " - " +;
                                                             Posicione("SUZ",1,cFilSUZ + (cACI)->ACI_CODSCR,"UZ_DESC"))}                               TITLE STR0023 SIZE 60 //"Script"
DEFINE CELL NAME ""         OF oSection1 Alias "ACI" BLOCK{||IIf(Posicione("SUZ",1,cFilSUZ + (cACI)->ACI_CODSCR,"UZ_FORMATO")=="1", STR0009, STR0010)} TITLE STR0008 SIZE 20 // Atendimento // Pesquisa

DEFINE CELL NAME "S2QUESTION" OF oSection2 TITLE STR0031 SIZE 100 
DEFINE CELL NAME "S2SCORE"    OF oSection2 TITLE STR0032 SIZE 20  

aSize(aTamSX3,0)
aTamSX3	:= NIL

Return(oReport)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tkr029PrtRpt � Autor �Michel W. Mosca     � Data �29/08/2006���
���          �             �       �                    �      �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina responsavel pela impressao do relatorio de Emissao de���
���          �Respostas de Scripts no release 4.                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tkr029PrtRept(ExpO1,ExpC2)                                 ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = objeto relatorio                                   ���
���          � ExpC2 = alias da query atual                               ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Tkr029PrtRpt(	oReport, 	cACI,	cAntPerg)
Local oSection1 := oReport:Section(1)		//Objeto secao 1 do relatorio (Cabecalho, dados da meta atendimento)	
Local oSection2 := oSection1:Section(1) 	//Rela��p de campanhas associadas a meta
Local dAtend   		:= CTOD("//")// Data do atendimento                                                                    
Local cAtend   		:= ""       // Codigo do atensdimento.
Local cCampanha		:= ""       // Codigo da campanha.       
Local nI			:= 0		// Contador
Local aLinhas		:= {}		// Recebe as linhas do memoLocal cPerg    		:= ""       // Codigo da pergunta
Local cResp    		:= ""       // Codigo da resposta
Local nScore   		:= 0        // Score das resposta
Local cWhere	:= ""						//String contendo condicoes da clausula Where para pesquisa em TOP
Local cTable	:= ""						//String para armazenar a tabela utilizada na verifica��o dos Segmentos de neg�cio
Local cQuery    := ""						//String para armazenar parametros de busca adicionais
Local nAux			:= 0

Local cFilACI		:= xFilial("ACI")
Local cFilSUK		:= xFilial("SUK")
Local cFilSUP		:= xFilial("SUP")
Local cFilSUO		:= xFilial("SUO")

//���������������������������������������������������������������������������������Ŀ
//�Transforma parametros do tipo Range em expressao SQL para ser utilizada na query �
//�Exemplo Word, nao intervalos pre definidos (mais utilizado pelo RH - Ferias)     �
//�����������������������������������������������������������������������������������
MakeSqlExpr("TMK029") 

//�������������������������������������������������������������������������������Ŀ
//�Chamo a funcao que monta a parte da query para validar os segmentos de negocios�
//���������������������������������������������������������������������������������
If Mv_Par03 == "SA1" .or. Mv_Par03 == "SUS"
	TKSegmento(	Mv_Par10,	Mv_Par11,	Mv_Par12,	Mv_Par13,;
				Mv_Par14,	Mv_Par15,	Mv_Par16,	Mv_Par17,;
				Mv_Par03,	"",			@cWhere)
Endif

//���������������������������������������������������������Ŀ
//�Implementa na query a validacao dos segmentos de negocios�
//�����������������������������������������������������������
If !Empty(cWhere)
	cTable := "%, " + RetSqlName(Mv_Par11) + " " + Mv_Par11 + " %"
Else
	cTable := "%%"
Endif

//���������������������������������������������������������Ŀ
//�Implementa na query a validacao dos segmentos de negocios�
//�����������������������������������������������������������
If !Empty(cWhere)
	cWhere =+ "% "
	cWhere += " AND "
Else
	cWhere := "% "
Endif
//��������������Ŀ
//�Selecao do ACI�
//����������������	
Iif(!Empty(mv_par03),cWhere += " ACI_ENTIDA = '" + ALLTRIM(Mv_Par03) + "' AND",)
cWhere += " ACI_DATA 	BETWEEN 	'" + DTOS(Mv_Par06) + "' AND '" + DTOS(Mv_Par07) + "' 	AND "
cWhere += " %"

BEGIN REPORT QUERY oSection1 
 	BeginSQL alias cACI
           SELECT	ACI_FILIAL,		ACI_ATEND,		ACI_CHAVE,		ACI_ENTIDA,
					ACI_CODIGO,		ACI_CODSCR,		ACI_CODCON,		ACI_ROTINA,
					ACI_DATA,		ACI_CODCAM	            	           			      			
           FROM     %table:ACI% ACI %exp:cTable% 
           WHERE  	ACI_FILIAL = %xfilial:ACI% 									AND
			 		ACI_ATEND 	BETWEEN		%exp:mv_par01% AND %exp:mv_par02% 	AND
			 		ACI_CHAVE 	BETWEEN 	%exp:Mv_Par04% AND %exp:Mv_Par05% 	AND			 			
					%exp:cWhere%
					ACI.%notDel% 	           							 			           
           ORDER BY %order:ACI%
    EndSql    
END REPORT QUERY oSection1

//�������������������������������������������Ŀ
//�Quebra a linha, caso existam muitas colunas�
//���������������������������������������������

oSection1:SetLineStyle()

//��������������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou query�
//����������������������������������������������������������������
oSection1:Init()

While	(!Eof()) 						.AND.;
		((cACI)->ACI_FILIAL == cFilACI)
	
	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf
	
	cAtend 	:= (cACI)->ACI_ATEND
	cEntChave 	:= (cACI)->ACI_ENTIDA+(cACI)->ACI_CHAVE

	If !Tk029ValAtend(cAtend, @cCampanha, @dAtend, cACI, cFilSUO)
		DbSelectArea(cACI)
		DbSkip()
		Loop
	EndIf
    
	oSection1:Cell("S1DATEND"):SetValue(DTOC(dAtend))
	oSection1:Cell("S1CCAMP"):SetValue(cCampanha)	
	oSection1:SetPageBreak()
	oSection1:PrintLine()		
	oSection2:Init()	
	DbSelectArea("SUK")
	DbSetOrder(1)
	If MsSeek(cFilSUK + (cACI)->ACI_CODIGO)
		While 	!Eof() 						.AND.;
			SUK->UK_FILIAL == cFilSUK  		.AND.;
			SUK->UK_CODIGO == (cACI)->ACI_CODIGO
			                     
			oSection2:Cell("S2QUESTION"):SetValue("")
			oSection2:Cell("S2SCORE"):SetValue("")
			//��������������������������������������������������������������������������Ŀ
			//�Caso seja resposta do Tipo Multipla Escolha(checkbox) a pergunta n�o sera �
			//�impressa mais de uma vez.                                                 �
			//����������������������������������������������������������������������������
			IF (Posicione("SUP",2,cFilSUP + (cACI)->ACI_CODSCR + SUK->UK_CODPERG,"UP_TIPOOBJ") == "2")
				If cAntPerg <> SUK->UK_CODPERG
					cPerg:= AllTrim(Posicione("SUP",2,cFilSUP + (cACI)->ACI_CODSCR + SUK->UK_CODPERG,"UP_DESC"))
					oSection2:Cell("S2QUESTION"):SetValue(cPerg)
					cAntPerg := SUK->UK_CODPERG
				EndIf
			Else
				cPerg:= AllTrim(Posicione("SUP",2,cFilSUP + (cACI)->ACI_CODSCR + SUK->UK_CODPERG,"UP_DESC"))
				oSection2:Cell("S2QUESTION"):SetValue(cPerg)
				cAntPerg := SUK->UK_CODPERG
			EndIf	 
			//IMPRIME A PERGUNTA
			oSection2:SetLeftMargin(2)
			oSection2:PrintLine()			
			cResp:= AllTrim(Posicione("SUP",2,cFilSUP + (cACI)->ACI_CODSCR + SUK->UK_CODRESP,"UP_DESC")) + iif(Empty(SUK->UK_COMPRES),""," - ") +;
					AllTrim(SUK->UK_COMPRES) 
			
			If(!Empty(SUK->UK_CODMEMO)) 
				aLinhas := TkMemo(SUK->UK_CODMEMO, 170)
				nAux	:= Len(aLinhas)
				For nI := 1 to nAux
					cResp+= aLinhas[nI]+CRLF+SPACE(10)
				Next nI           
				cResp+= CRLF
			EndIf	          
			oSection2:Cell("S2QUESTION"):SetValue("R: "+ cResp)
			
			//���������������������������������������������������
			//�Respostas dissertativas nao imprimem a pontuacao.�
			//���������������������������������������������������

			If Empty(SUK->UK_CODMEMO)
				oSection2:Cell("S2SCORE"):SetValue(Transform(SUK->UK_SCORE,PesqPict("SUK","UK_SCORE")))				
			EndIf
			nScore+= SUK->UK_SCORE				

			oSection2:SetLeftMargin(4)
			//IMPRIME A RESPOSTA
			oSection2:PrintLine()
				
			DbSelectArea("SUK")
			DbSkip()
		End
		
	EndIf	 
    oReport:SkipLine()                
    oSection2:SetLeftMargin(2) 
	oSection2:Cell("S2QUESTION"):SetValue(STR0011 + Transform(nScore,PesqPict("SUK","UK_SCORE")))//"Score Total   : "
	oSection2:Cell("S2SCORE"):SetValue("")	
	oSection2:PrintLine()
	nScore:= 0	
    oSection2:Finish()
    oReport:EndPage()
	DbSelectArea(cACI)  
	DbSkip()
End		
oSection1:Finish()

Return(.T.)