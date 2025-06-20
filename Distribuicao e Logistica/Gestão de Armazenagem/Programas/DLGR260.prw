#INCLUDE "DLGR260.ch"
#Include 'FIVEWIN.CH'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �          � Autor �     Paullo Vieira     � Data � 12/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Indicadores de Produtividade - Equipamento / Hora           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function DLGR260()
//������������������������������������������������������������������������Ŀ
//�Define Variaveis                                                        �
//��������������������������������������������������������������������������
Local wnrel   := 'DLGR260'  // Nome do Arquivo utilizado no Spool
Local cDesc1  := STR0001 //'Relatorio de todos os Movimentos de Distribuicao cadastrados no armazem com as informacoes'
Local cDesc2  := STR0002 //'utilizadas no armazem'
Local cDesc3  := ''  // Descricao 3
Local Tamanho := 'M' // P/M/G

Private cString := 'SDB' // Alias utilizado na Filtragem
Private aReturn := { STR0003, 1,STR0004, 1, 2, 1, '',1 }  //'Zebrado'###'Administracao'
//[1] Reservado para Formulario
//[2] Reservado para N� de Vias
//[3] Destinatario
//[4] Formato => 1-Comprimido 2-Normal
//[5] Midia   => 1-Disco 2-Impressora
//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
//[7] Expressao do Filtro
//[8] Ordem a ser selecionada
//[9]..[10]..[n] Campos a Processar (se houver)
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault
Private Titulo  := STR0005 //'Indicadores de Produtividade - Equipamento / Hora'
Private nomeprog:= 'DLGR260'  // nome do programa
Private lEnd    := .F.// Controle de cancelamento do relatorio

//�����������������������������������������������������������������������Ŀ
//� Variaveis utilizadas como parametros p/filtrar as ordens de servico   �
//�����������������������������������������������������������������������Ĵ
//� mv_par01	// Armazem       De  ?                                    �
//� mv_par02	//               Ate ?                                    �
//� mv_par03	// Rec.Fisico    De  ?                                    �
//� mv_par04	//               Ate ?                                    �
//� mv_par05	// Analitico/Sintetic? 1-Analitico                        �
//�                                   2-Sintetico                         �
//�������������������������������������������������������������������������
Pergunte('DLR260', .F.)
//������������������������������������������������������������������������Ŀ
//�Envia para a SetPrinter                                                 �
//��������������������������������������������������������������������������
wnrel:=SetPrint(cString,wnrel,'DLR260',@titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)

If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	Set Filter to
	Return
Endif

RptStatus({|lEnd| ImpDet(@lEnd,wnRel,cString,nomeprog,Titulo,Tamanho)},Titulo)

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   � ImpDet   � Autor �                       � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Controle de Fluxo do Relatorio.                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ImpDet(lEnd,wnrel,cString,nomeprog,Titulo,Tamanho)
Local lImp		:= .F. // Indica se algo foi impresso
Local cQuebra	:= ''
Local nTotHora	:= 0
Local nTotQuant:= 0
Local nIndex	:= 0
Local cIndTmp	:= ''
Local cQuery	:= ''

Private cbCont	:= 00
Private Cbtext	:= Space( 10 )
Private Cabec1 := ''
Private li		:= 80
Private m_pag	:= 01

//�������������������������������������������������������������������Ŀ
//� Inicializa os codigos de caracter Comprimido/Normal da impressora �
//���������������������������������������������������������������������
Private nTipo	:= IIF(aReturn[4]==1,GetMV('MV_COMP'),GetMV('MV_NORM'))
Private nOrdem	:= aReturn[8]

If	mv_par05 == 1
	Cabec1	:= STR0006 //'Produto         Quantidade       Data Inicial   Hora Inicial   Data Final   Hora Final   Total de Horas'
Else
	Cabec1	:= STR0007 //'                Quantidade                                                               Total de Horas'
EndIf
//                  0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//                  01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Private Cabec2	:= ''
Private Cabec3	:= ''

dbSelectArea(cString)

cIndTmp := CriaTrab(NIL,.F.)
cQuery  := 'DB_FILIAL == "'+xFilial('SDB')+'".And.'
cQuery  += 'DB_LOCAL  >= "'+mv_par01+'".And.'
cQuery  += 'DB_LOCAL  <= "'+mv_par02+'".And.'
cQuery  += 'DB_RECFIS >= "'+mv_par03+'".And.'
cQuery  += 'DB_RECFIS <= "'+mv_par04+'"'

IndRegua('SDB',cIndTmp,'DB_FILIAL + DB_LOCAL + DB_RECFIS',,cQuery,OemToAnsi(STR0008)) //'Selecionando Registros ...'
nIndex := RetIndex('SDB')
dbSetIndex(cIndTmp+OrdBagExt())
dbSetOrder(nIndex+1)
SetRegua(LastRec())
DbGoTop()


While SDB->(!Eof())
	lImp := .T.
	If lEnd
		@ Prow()+1,001 PSAY STR0009 //'CANCELADO PELO OPERADOR'
		Exit
	EndIf
	IncRegua()
	
	
	If	SDB->DB_ATUEST != 'N' .Or. Empty(SDB->DB_LOCAL) .Or. Empty(SDB->DB_RECFIS) .Or.;
		Empty(SDB->DB_DATA) .Or. Empty(SDB->DB_HRINI) .Or. Empty(SDB->DB_DATAFIM) .Or. Empty(SDB->DB_HRFIM)
		SDB->(DbSkip())
		Loop
	EndIf
	
	
	If li > 55
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
		cQuebra := ''
	Endif
	
	
	If	cQuebra != SDB->DB_LOCAL + SDB->DB_RECFIS
		cQuebra := SDB->DB_LOCAL + SDB->DB_RECFIS
		@ Li,00 PSay STR0010+ SDB->DB_LOCAL  //'Centro de Distribuicao : '
		@ Li,57 PSay STR0011+ SDB->DB_RECFIS + ' - ' + AllTrim(Tabela('L1',SDB->DB_RECFIS,.F.)) //'Recurso Fisico : '
		li++
	EndIf
	
	If	mv_par05 == 1				//-- Analitico
		@ Li++
		@ Li,00 PSay SDB->DB_PRODUTO				Picture PesqPict('SDB','DB_PRODUTO')
		@ Li,16 PSay SDB->DB_QUANT				Picture PesqPictQt('DB_QUANT')
		@ Li,35 PSay SDB->DB_DATA
		@ Li,52 PSay SDB->DB_HRINI				Picture PesqPict('SDB','DB_HRINI')
		@ Li,64 PSay SDB->DB_DATAFIM
		@ Li,79 PSay SDB->DB_HRFIM				Picture PesqPict('SDB','DB_HRFIM')
		@ Li,93 PSay IntToHora(SubtHoras(SDB->DB_DATA,SDB->DB_HRINI,SDB->DB_DATAFIM,SDB->DB_HRFIM),3)
	EndIf
	
	nTotHora += SubtHoras(SDB->DB_DATA,SDB->DB_HRINI,SDB->DB_DATAFIM,SDB->DB_HRFIM)
	nTotQuant += DB_QUANT
	DbSelectArea(cString)
	dbSkip()
	
	If cQuebra != SDB->DB_LOCAL + SDB->DB_RECFIS
		If	mv_par05 == 1				//-- Analitico
			Li+=2
			@ Li,00 PSay STR0012 //'Total Geral: '
		EndIf
		@ Li,16 PSay nTotQuant Picture PesqPictQt('DB_QUANT')
		@ Li,93 PSay IntToHora(nTotHora,3)
		nTotHora := 0
		nTotQuant:= 0
		li+=2
	EndIf
EndDo

If ( lImp )
	Roda(cbCont,cbText,Tamanho)
EndIf

If ( aReturn[5] = 1 )
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

If	File(cIndTmp+OrdBagExt())
	dbSelectArea('SDB')
	Set Filter to
	Ferase(cIndTmp+OrdBagExt())
EndIf
RetIndex('SDB')
Return(.T.)
