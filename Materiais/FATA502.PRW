#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA502.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � FATA502  � Autor � Vendas CRM            � Data �           ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Baixa dos Orcamentos de Venda  Ref(MATA416)     ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void FATA502(void)                                          ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function FATA502( xStatus )

Local lGerar   		:= .F.
Local lContinua		:=.F.
Local cAlias   		:= Alias()
Local nOps     		:= 0
Local nOpc     		:= 0
Local nX       		:= 0
Local nCntFor  		:= 0
Local nMaxFor  		:= 0
Local aCores 		:= {	{ 'SCJ->CJ_STATUS=="A"'	, 'ENABLE' 		},;
							{ 'SCJ->CJ_STATUS=="B"'	, 'DISABLE'		},;
							{ 'SCJ->CJ_STATUS=="C"'	, 'BR_PRETO'	},;
							{ 'SCJ->CJ_STATUS=="D"'	, 'BR_AMARELO'	},;
							{ 'SCJ->CJ_STATUS=="U"'	, 'BR_AZUL'		},;
							{ 'SCJ->CJ_STATUS=="T"'	, 'BR_CINZA'		},;
							{ 'SCJ->CJ_STATUS=="F"'	, 'BR_MARROM'	}}
					
Local xAutoCab		:= Nil	
Local xAutoItens	:= Nil
Local cFiltroSCJ	:= ""					
					
PRIVATE aHeadC6		:= {}
PRIVATE aHeadD4		:= {}
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas na geracao de SCS aglutinadas por data  �
//� de necessidade.                                              �
//����������������������������������������������������������������
PRIVATE aDataOPC1 	:= {}
PRIVATE aDataOPC7 	:= {}
PRIVATE aOPC1     	:= {}
PRIVATE aOPC7     	:= {}
PRIVATE lEnd      	:= .F.
PRIVATE INCLUI    	:= .T.
PRIVATE lMTA650I  	:= (ExistBlock( "MTA650I" ) )
PRIVATE lMT650C1 	:= (ExistBlock( "MT650C1" ) )
PRIVATE lM650EmpT	:= (ExistTemplate( "EMP650"  ) ) 
PRIVATE lM650Emp  	:= (ExistBlock( "EMP650"  ) )
PRIVATE cPedido   	:= ""
PRIVATE cItemPV   	:= ""
PRIVATE cCadastro 	:= STR0001 //"Baixa de Propostas"
PRIVATE l416Auto  	:= ( xAutoCab <> NIL  .and. xAutoItens <> NIL )
PRIVATE aAutoCab  	:= {}
PRIVATE aAutoItens	:= {}
PRIVATE aValidGet 	:= {}
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para integracao com programa MATA650    �
//����������������������������������������������������������������
PRIVATE aSav650	 	:= Array(20)
PRIVATE lConsTerc
PRIVATE lConsNPT
PRIVATE aRotina 	:= MenuDef()
PRIVATE cStatus		:= xStatus

DEFAULT cStatus		:= "A"		

If ExistBlock("MATA416A")
	ExecBlock("MATA416A",.F.,.F.)
EndIf	
//������������������������������������������������������Ŀ
//� mv_par01 Mostra Ordem de Producao   ? Sim/Nao        �
//� mv_par02 Mostra Empenho do PV.      ? Sim/Nao        �
//� mv_par03 Gera PV s/ Sugest�o        ? Sim/Nao        �
//��������������������������������������������������������
//������������������������������������������������������Ŀ
//� Ativa tecla F-10 para parametros                     �
//��������������������������������������������������������
Pergunte("MTA416",.F.)
If !(l416Auto)
	SetKey( VK_F12 , {|| Pergunte("MTA416",.T.) } )
EndIf

DbSelectArea("SCJ")

If IsInCallStack("FATA320")
	If ADL->ADL_ENTIDA == "SUS"
		cFiltroSCJ := "CJ_PROSPE = '" + ADL->ADL_CODENT + "' .AND. CJ_LOJPRO = '" + ADL->ADL_LOJENT + "'"
	ElseIf ADL->ADL_ENTIDA == "SA1"
		cFiltroSCJ := "CJ_CLIENTE = '" + ADL->ADL_CODENT + "' .AND. CJ_LOJA = '" + ADL->ADL_LOJENT + "'"
	EndIf      
	If !Empty(cFiltroSCJ)
		dbSetFilter({|| &cFiltroSCJ}, cFiltroSCJ)
	EndIf
EndIf

If Empty(SCJ->(DbFilter()))
	cFiltroSCJ := "SCJ->CJ_STATUS == '" + cStatus + "'"
Else
	cFiltroSCJ := SCJ->(DbFilter()) + " .AND. SCJ->CJ_STATUS == '" + cStatus + "' "
EndIf

If Len(cFiltroSCJ) >= 2000
	cFiltroSCJ := "SCJ->CJ_STATUS == '" + cStatus + "'"
EndIf

If !Empty(cFiltroSCJ)
	dbSetFilter({|| &cFiltroSCJ}, cFiltroSCJ)
EndIf

//������������������������������������������������������Ŀ
//� Monta aHeader do SC6                                 �
//��������������������������������������������������������
aHeadC6 := {}
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SC6",.T.)
While ( !Eof() .And. (SX3->X3_ARQUIVO == "SC6") )
	If (  ((X3Uso(SX3->X3_USADO) .And. ;
			!( Trim(SX3->X3_CAMPO) == "C6_NUM" ) .And.;
			Trim(SX3->X3_CAMPO) != "C6_QTDEMP"  .And.;
			Trim(SX3->X3_CAMPO) != "C6_QTDENT") .And.;
			cNivel >= SX3->X3_NIVEL) .Or.;
			Trim(SX3->X3_CAMPO)=="C6_NUMORC" .Or. ;
			Trim(SX3->X3_CAMPO)=="C6_NUMOP"  .Or. ;
			Trim(SX3->X3_CAMPO)=="C6_ITEMOP" .Or. ;
			Trim(SX3->X3_CAMPO)=="C6_OP" .Or. ;
			Trim(SX3->X3_CAMPO)=="C6_OPC" )	
		Aadd(aHeadC6,{TRIM(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			If(Trim(SX3->X3_CAMPO)=="C6_NUMORC",".F.",SX3->X3_VALID),;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo
//������������������������������������������������������Ŀ
//� Monta aHeader do SD4                                 �
//��������������������������������������������������������
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SD4")
While ( !Eof() .And. SX3->X3_ARQUIVO == "SD4" )
	If ( X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		Aadd(aHeadD4,{ Trim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT })
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo
dbSelectArea("ABI")
dbSelectArea("SCJ")
dbSetOrder(1)
If (l416Auto)
	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens
	MBrowseAuto(4,Aclone(aAutoCab),"SCJ")
Else
	//��������������������������������������������������������������Ŀ
	//� Ponto de Entrada para alterar cores do Browse do Cadastro    �
	//����������������������������������������������������������������
	If ExistBlock("MA416COR")
		aCores := ExecBlock("MA416COR",.F.,.F.,aCores)
	EndIf
	MsSeek(xFilial("SCJ"))
	mBrowse( 6, 1,22,75,"SCJ",,,,,,aCores)
EndIf
INCLUI := .F. // For�ado para compatibilizacao
//��������������������������������������������������������������Ŀ
//� Verifica se existe SC's ou OP's para serem geradas           �
//����������������������������������������������������������������
SetKey( VK_F12 , Nil )
Pergunte("MTA650",.F.)
//Salvar variaveis existentes
For nx := 1 to 20
	aSav650[nx] := &("mv_par"+StrZero(nx,2))
Next nx
lConsNPT  := (aSav650[14] == 1)
lConsTerc := !(aSav650[15] == 1)
//��������������������������������������������������������������Ŀ
//� Gera SC's aglutinadas por OP.                                �
//����������������������������������������������������������������
If ( aSav650[06] == 2 )
	nMaxFor  := Len(aOPC1)
	For nCntFor := 1 to nMaxFor
		A650GravC1(	aOPC1[nCntFor,1],aOPC1[nCntFor,2],aOPC1[nCntFor,3],;
			aOPC1[nCntFor,4],aOPC1[nCntFor,5],aOPC1[nCntFor,6],;
			aOPC1[nCntFor,7],aOPC1[nCntFor,8],aOPC1[nCntFor,9],;
			aOPC1[nCntFor,10])
	Next nCntFor
	nMaxFor  := Len(aOPC7)
	For nCntFor := 1 to nMaxFor
		A650GravC7(	aOPC7[nCntFor,1],aOPC7[nCntFor,2],aOPC7[nCntFor,3],;
			aOPC7[nCntFor,4],aOPC7[nCntFor,5],aOPC7[nCntFor,6],;
			aOPC7[nCntFor,7])
	Next nCntFor
ElseIf ( aSav650[06] == 3 )
	//��������������������������������������������������������������Ŀ
	//� Gera SC's aglutinadas por data de Necessidade.               �
	//����������������������������������������������������������������
	nMaxFor := Len(aDataOPC1)
	For nCntFor := 1 to nMaxFor
		A650GravC1(	aDataOPC1[nCntFor,1],aDataOPC1[nCntFor,2],;
			aDataOPC1[nCntFor,3],aDataOPC1[nCntFor,4],;
			aDataOPC1[nCntFor,5],aDataOPC1[nCntFor,6],;
			aDataOPC1[nCntFor,7],aDataOPC1[nCntFor,8],;
			aDataOPC1[nCntFor,9],aDataOPC1[nCntFor,10])
	Next nCntFor
	nMaxFor := Len(aDataOPC7)
	For nCntFor := 1 to nMaxFor
		A650GravC7(	aDataOPC7[nCntFor,1],aDataOPC7[nCntFor,2],;
			aDataOPC7[nCntFor,3],aDataOPC7[nCntFor,4],;
			aDataOPC7[nCntFor,5],aDataOPC7[nCntFor,6],;
			aDataOPC7[nCntFor,7])
	Next nCntFor
EndIf
//��������������������������������������������������������������Ŀ
//� Verifica se existe OP's Intermediarias para geracao          �
//����������������������������������������������������������������
If lContinua:= .T.
	//��������������������������������������������������������������Ŀ
	//� Verifica o Numero de Registros a Processar                   �
	//����������������������������������������������������������������
	If lContinua
		a650RegOPI(@lGerar, @nOps, Funname())		
	Else
		dbSelectArea("BAT")
		dbSetOrder(2)
		While !Eof()
			If ( Empty(BAT->OK) .And. BAT->OR == "S" )
				lGerar := .T.
				nOps++
			EndIf
			dbSkip()
		End
	EndIf
	If ( lGerar )
		MTA650OK(@nOpc)
		If ( nOpc == 1 )
			Processa({|lEnd| MA650Process(@lEnd,nOps,.T.)},STR0005,STR0006,.F.)   //"Gera��o de OPs Intermediarias e SCs"###"Gerando OPs Intermediarias e SCs..."
		EndIf
	EndIf
	dbSelectArea("BAT")
	dbCloseArea()
Endif

dbSelectArea("SCJ")
dbClearFilter()

dbSelectArea(cAlias)
Return(.T.)


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Vendas CRM            � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()
               
Private aRotina := {	{ STR0002,"AxPesqui"	, 0 , 1 , 0 , .F.},;	//"Pesquisar"
						{ STR0003,"A502Desbl"	, 0 , 2 , 0 , NIL},;	//"Desbloquear" 
						{ STR0004,"A502Legend"	, 0 , 2 }}   			//"Legenda"

Return(aRotina)

/*
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �A502Legend�Autor  � Vendas CRM            � Data �08/09/2006 ���
��������������������������������������������������������������������������Ĵ��
���          �Demonstra a legenda das cores da mbrowse                     ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina monta uma dialog com a descricao das cores da    ���
���          �Mbrowse.                                                     ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function A502Legend()

Local aCores := {	{ 'ENABLE'    , STR0007 },; //'Orcamento em Aberto'
					{ 'DISABLE'   , STR0008 },; //'Orcamento Baixado'
					{ 'BR_PRETO'  , STR0009 },; //'Orcamento Cancelado' 	
					{ 'BR_AMARELO', STR0010 },; //'Orcamento nao Orcado'
					{ 'BR_AZUL'   , STR0011 },; // 'Orcamento aprovado'
					{ 'BR_CINZA'  , STR0012 },; // 'Orcamento aprovado'
					{ 'BR_MARROM' , STR0013 }}	//"Orcamento bloqueado"
					
//���������������������������������������������������Ŀ
//� Ponto de Entrada para alterar cores da legenda    �
//�����������������������������������������������������
If ExistBlock("MA415LEG")
	aCores := ExecBlock("MA415LEG",.F.,.F.,aCores)
Endif
					
BrwLegenda(cCadastro,STR0014,aCores )   //"Pedido Liberado"
	
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A502Libera�Autor  �Vendas CRM          � Data �  22/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Liberacao do orcamento com bloqueio de regra de negocio     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �MATA416/MATA415                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A502Libera(cAlias,nReg,nOpcx,oDlg)

Local aArea		:= GetArea()							// Armazena o posicionamento atual
Local aAreaSA3	:= SA3->(GetArea())						// Armazena o posicionamento da SA3
Local aAreaACA	:= ACA->(GetArea())						// Armazena o posicionamento da ACA
Local lContinua	:= .T.									// Controla a execucao da rotina
Local cCodUsr	:= __cUserId             				// Codigo do usuario logado
Local lFT502Lib := (ExistBlock( "FT502Lib"  ) )			// Ponto de entrada na liberacao da proposta
Local aRecOrc	:= {}									// Registros do Orcamento a serem desbloqueados
Local cProposta	:= ""									// Numero da proposta
Local cFilSCJ	:= xFilial("SCJ")						// Filial dos orcamentos
Local nX		:= 0									// Contador de loop
Local lFT502Fat	:= (ExistBlock( "FT502Fat"  ) )			// Ponto de entrada utilizado para tratar a liberacao do orcamento pelo faturamento
Local cFiltro	:= ""

//��������������������������Ŀ
//�Valida se eh pela workarea�
//����������������������������
If IsInCallStack("FATA320")
	SA3->(DbSetOrder(7))//A3_FILIAL+A3_CODUSR
	ACA->(DbSetOrder(1))//ACA_FILIAL+ACA_GRPREP
	
	//��������������������������������������������������������Ŀ
	//�Localiza o grupo do representante e valida sua permissao�
	//����������������������������������������������������������
	If 	SA3->(DbSeek(xFilial("SA3")+cCodUsr)) .AND.;
		ACA->(DbSeek(xFilial("ACA")+SA3->A3_GRPREP))	
		If ACA->ACA_LIBORC <> "1"
			lContinua := .F.
			MsgInfo(STR0015) //"Usu�rio sem permiss�o para liberar a proposta"
		EndIf		
	Else 
		lContinua	:= .F.
		MsgInfo(STR0017) //"Seu usu�rio n�o est� associado a nenhum vendedor."
	EndIf
Endif
//��������������������Ŀ
//�Libera os orcamentos�
//����������������������
If lContinua
	
	DbSelectArea("SCJ")
	DbGoTo(nReg)

	//�������������������������������������������������������������Ŀ
	//�Se o orcamento foi originado a partir de uma proposta, libera�
	//�todos os orcamentos                                          �
	//���������������������������������������������������������������
	If !Empty(SCJ->CJ_PROPOST)
		
		cProposta	:= SCJ->CJ_PROPOST
		
		SCJ->(DbSetOrder(4)) //CJ_FILIAL+CJ_PROPOST
		SCJ->(DbSeek(cFilSCJ+cProposta))
		
		While !SCJ->(Eof()) 			.AND.;
			SCJ->CJ_FILIAL == cFilSCJ 	.AND.;
			SCJ->CJ_PROPOST == cProposta			
			
			AAdd(aRecOrc,SCJ->(Recno()))								
			SCJ->(DbSkip())
			
		End
		
	Else                              
		AAdd(aRecOrc,SCJ->(Recno()))
	EndIf

	
	For nX := 1 to Len(aRecOrc) 
		SCJ->(DbGoTo(aRecOrc[nX]))   

		//�������������������������������������������������������������������������������Ŀ
		//�Este ponto de entrada foi criado para permitir a liberacao do orcamento somente�
		//�quando o faturamento conferir a proposta e dar o Ok para ser Faturado          �
		//���������������������������������������������������������������������������������				
		If lFT502Fat	
			ExecBlock("FT502Fat",.F.,.F.)	          
   		Endif
   		
   		DbSelectArea("SCJ")
   		
		If SCJ->CJ_STATUS == "F"
			RecLock("SCJ",.F.) 
			MaAvalOrc("SCJ",11)
			//�����������������������������������������������Ŀ
			//�Realiza a Baixa do Orcamento no Faturamento    �
			//�Apenas para orcamento em Aberto(cfe. A415Baixa)�
			//�������������������������������������������������				
			If ( SCJ->CJ_STATUS == "A" )			
				cFiltro := SCJ->(dbFilter())
				//Limpa o filtro da tabela para fazer a baixa do or�amento
				If !Empty(cFiltro)
					dbSelectArea("SCJ")
					dbClearFilter()
				EndIf
				A502GrvBx()
				//Volta o filtro
				If !Empty(cFiltro)	  
					dbSelectArea("SCJ")
					Set Filter To &cFiltro
				EndIf				
			EndIf
			MsUnLock()		
		EndIf
			
	Next nX
      
	//��������������������������������������Ŀ
	//�Ponto de entrada ao final da liberacao�
	//����������������������������������������
	If lFT502Lib
		ExecBlock("FT502Lib",.F.,.F.)
	Endif
	
	//��������������������������Ŀ
	//�Encerra a tela da proposta�
	//����������������������������
	If oDlg <> Nil	 
		oDlg:End()
	EndIf
	
EndIf

RestArea(aAreaACA)
RestArea(aAreaSA3)
RestArea(aArea)

Return Nil

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �A502GrvBx � Autor � Vendas CRM            � Rev. �30.11.2001 ���
��������������������������������������������������������������������������Ĵ��
���          �Rotina de interface da baixa manual dos orcamentos de venda  ���
���          �Ref. MATA416                                                 ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo controlar a interface da baixa ���
���          �manual do orcamento de venda                                 ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function A502GrvBx()

Local aArea     := GetArea()
Local bSetKey   := SetKey(VK_F12,Nil)
Local lLibPv	 := .F. 
Local lMostraPV	:= SuperGetMV("MV_TKEXPV",,.F.)


If SuperGetMV("MV_ORCSLIB",,.F.)
	Pergunte("MTA410",.F.)
	lLibPV := MV_PAR01==1
EndIf

Pergunte("MTA416",.F.)

MaBxOrc(SCJ->CJ_NUM,MV_PAR01==1,MV_PAR02==1,MV_PAR03==1,lMostraPV,,,lLibPV)

SetKey(VK_F12,bSetKey)
RestArea(aArea)

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A502Desbl �Autor  �Vendas CRM          � Data �  04/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Aciona a tela para visualizacao do Orcamento/Proposta a ser ���
���          �aprovado ou reprovado                                       ���
�������������������������������������������������������������������������͹��
���Uso       �MATA416/MATA415                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A502Desbl(cAlias,nReg,nOpcx)

Local aArea		:= GetArea()
Local cFatProp	:= SuperGetMV("MV_FATPROP",,"O") //Indica se a oportunidade manipula orcamento ou propostas.

//��������������������������������������������Ŀ
//� Chama a funcao p/ visualizacao da Proposta �
//����������������������������������������������
If cFatProp == "P"
	DbSelectArea("ADY")
	DbSetOrder(1) //ADY_FILIAL+ADY_PROPOS
	If DbSeek(xFilial("ADY")+SCJ->CJ_PROPOST)
		FWExecView(Upper(STR0019),"VIEWDEF.FATA600",MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)
	EndIf 
Else
	A502Libera(cAlias,nReg,nOpcx)
EndIf

RestArea(aArea) 

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A416Desapr�Autor  �Vendas CRM          � Data �  22/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Reprovacao do orcamento com bloqueio de regra de negocio    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �MATA416/MATA415                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A502Desapr(cAlias,nReg,nOpcx,oDlg)
Local aArea    		:= GetArea()             					// Armazena o posicionamento atual
Local aAreaSA3    	:= SA3->(GetArea())                        // Armazena o posicionamento da SA3
Local aAreaACA   	:= ACA->(GetArea())                        // Armazena o posicionamento da ACA
Local aAreaAD1  	:= AD1->(GetArea())                        // Armazena o posicionamento da AD1
Local lContinua		:= .T.                                      // Controla a execucao da rotina
Local cCodUsr  		:= __cUserId                                // Codigo do usuario logado
Local lMT416Des 	:= (ExistBlock( "MT416Des"  ) )            // Ponto de entrada na desaprovacao da proposta
Local aRecOrc  		:= {}                                      // Registros do Orcamento a serem desbloqueados
Local cProposta 	:= ""                                      // Numero da proposta
Local cFilSCJ  		:= xFilial("SCJ")                          // Filial dos orcamentos
Local nX   			:= 0                               		  // Contador de loop

SA3->(DbSetOrder(7))//A3_FILIAL+A3_CODUSR
ACA->(DbSetOrder(1))//ACA_FILIAL+ACA_GRPREP

//��������������������������Ŀ
//�Valida se eh pela workarea�
//����������������������������
If IsInCallStack("FATA320")
	//��������������������������������������������������������Ŀ
	//�Localiza o grupo do representante e valida sua permissao�
	//����������������������������������������������������������
	If SA3->(DbSeek(xFilial("SA3")+cCodUsr)) .AND.;
			ACA->(DbSeek(xFilial("ACA")+SA3->A3_GRPREP))

  			If ACA->ACA_LIBORC <> "1"
               	lContinua := .F.
     			MsgInfo(STR0015)		//"Usu�rio sem permiss�o para liberar o or�amento"
        	EndIf
	Else 
			lContinua          := .F.
	  		MsgInfo(STR0017)				//"Seu usu�rio n�o est� associado a nenhum vendedor."
	EndIf
Endif

//�����������������������Ŀ
//�Desaprova os orcamentos�
//�������������������������
If lContinua
	DbSelectArea("SCJ")
	DbGoTo(nReg)

	//�������������������������������������������������������������Ŀ
	//�Se o orcamento foi originado a partir de uma proposta, libera�
	//�todos os orcamentos                                          �
	//���������������������������������������������������������������
	If !Empty(SCJ->CJ_PROPOST)
		cProposta         := SCJ->CJ_PROPOST
		
		SCJ->(DbSetOrder(4)) //CJ_FILIAL+CJ_PROPOST
		SCJ->(DbSeek(cFilSCJ+cProposta))

		While !SCJ->(Eof())  .AND.;
    				SCJ->CJ_FILIAL == cFilSCJ      .AND.;
         			SCJ->CJ_PROPOST == cProposta                               

			AAdd(aRecOrc,SCJ->(Recno()))
			SCJ->(DbSkip())
		End

	Else
		AAdd(aRecOrc,SCJ->(Recno()))
	EndIf
	
	For nX := 1 to Len(aRecOrc) 
		SCJ->(DbGoTo(aRecOrc[nX]))
		
		If SCJ->CJ_STATUS == "T"
			RecLock("SCJ",.F.) 
			SCJ->CJ_STATUS := "A"
			SCJ->(MsUnLock())
			
			If ChkFile("ADY")
				DbSelectArea("ADY")
				DbSetOrder(1) //ADY_FILIAL+ADY_PROPOS
				If DbSeek(xFilial("ADY") + cProposta)
					RecLock("ADY",.F.)
					ADY->ADY_STATUS	:= "A"
					MsUnLock()
				EndIf
			EndIf
				
			DbSelectArea("AD1")
			DbSetOrder(1)
			If DbSeek(xFilial("AD1") + SCJ->CJ_NROPOR) .OR. !Empty(SCJ->CJ_NROPOR)
				RecLock("AD1",.F.) 
					AD1->AD1_STATUS := "1"
				AD1->(MsUnLock())
			Endif
		EndIf
	Next nX
	
	//��������������������������������������Ŀ
	//�Ponto de entrada ao final da liberacao�
	//����������������������������������������
	If lMT416Des
		ExecBlock("MT416Des",.F.,.F.)
	Endif

	//�������������������������������������Ŀ
	//� Processo p/ Reprovacao de Orcamento �
	//���������������������������������������
	ExecCRMPro("000009")

	//��������������������������Ŀ
	//�Encerra a tela da proposta�
	//����������������������������	
	If oDlg <> Nil	 
		oDlg:End()
	EndIf
	
EndIf

RestArea(aAreaAD1)
RestArea(aAreaACA)
RestArea(aAreaSA3)
RestArea(aArea)
Return Nil

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � FATA502A � Autor � Vendas CRM            � Data �           ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Encapsulamento da funcao FATA502, para chamada via menu-XNU.���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void FATA502a(void)                                         ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function FATA502A()
FATA502( "F" )
Return Nil
