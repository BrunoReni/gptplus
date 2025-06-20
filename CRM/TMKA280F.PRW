#INCLUDE "TMKA280F.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk280TLC06�Autor  �Armando M. Tessaroli� Data �  16/05/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao que atualiza os dados dos paineis para um novo atendi���
���          �mento de cobranca.                                          ���
�������������������������������������������������������������������������͹��
���Parametros�oExplorer - Objeto que contem os paineis com os dados do    ���
���          �            pre-atendimento.                                ���
���          �nPanel    - Nupero do painel corrente.                      ���
���          �aPanels   - Todos objetos de todos paineis.                 ���
���          �aMemory   - Variareis de memoria das MSMGET.                ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Tk280TLC06(oExplorer, nPanel, aPanels, aMemory)

// Definicao de variaveis de manipulacao
Local nRow		:= Int((oExplorer:aPanel[nPanel]:nHeight * .97) / 2)
Local nCol		:= Int((oExplorer:aPanel[nPanel]:nWidth * .985) / 2)
Local aHeadNew	:= {}
Local aColsNew	:= {}
Local aCoord	:= {}
Local nPFolder	:= 0
Local aRodape	:= Array(12,2)

// Definicao de variaveis para objetos
Local oFonte
Local oSay1
Local oSay2
Local oFolder

DEFINE FONT oFonte NAME "Arial" SIZE 0,14 BOLD

//������������������
//�Parte 01 da tela�
//������������������
@ (nRow*.010), (nCol*.010) TO (nRow*.53), nCol OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.015), (nCol*.020) SAY oSay1 PROMPT STR0001 FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// " Dados do Cliente e Contato"
oSay1:lTransparent := .F.
oSay1:nHeight := 14
oSay1:nWidth  := (Len(STR0001) * 6.2) //" Dados do Cliente e Contato"

// Cria os folders para Clientes e Contatos

@ (nRow*.050),(nCol*.020) FOLDER oFolder ITEMS STR0002,STR0003 OF oExplorer:GetPanel(nPanel) SIZE (nCol*.965),(nRow*.46) PIXEL		//"Cliente"###"Contato"
Aadd( aPanels, { oFolder, "FOBJ01" } )
nPFolder := Ascan(aPanels, {|x| x[2]=="FOBJ01"} )

// Define as coordenadas para as enchoices abaixo
Aadd(aCoord, { 0, 0, (nRow*.41), (nCol*.96) } )

// Monta a enchoice do Cliente
// Parametro 16 = .F. a enchoice trabalha com as variaveis de memoria ex: M->A1_COD
Aadd( aPanels, { MsMGet():New("SA1", SA1->(RecNo()), 2,,,,,aCoord[1],,,,,,aPanels[nPFolder][1]:aDialogs[1],,.T.,, ), "FOBJ02"} )

// Monta a enchoice do Contato
// Parametro 16 = .F. a enchoice trabalha com as variaveis de memoria ex: M->A1_COD
Aadd( aPanels, { MsMGet():New("SU5", SU5->(RecNo()), 2,,,,,aCoord[1],,,,,,aPanels[nPFolder][1]:aDialogs[2],,.T.,, ), "FOBJ03"} )


//������������������
//�Parte 02 da tela�
//������������������
@ (nRow*.550), (nCol*.010) TO nRow, nCol OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.555), (nCol*.020) SAY oSay2 PROMPT STR0002 FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// " T�tulos em Aberto"
oSay2:lTransparent := .F.
oSay2:nHeight := 14
oSay2:nWidth  := (Len(STR0004) * 6.2) //" T�tulos em Aberto"

// Cria um folder com duas pastas para caber na tela.

@ (nRow*.600),(nCol*.020) FOLDER oFolder ITEMS STR0005,STR0006 OF oExplorer:GetPanel(nPanel) SIZE (nCol*.96),(nRow*.37) PIXEL		//"T�tulos"###"Totais"
nRow := (oFolder:nHeight*.9)/2
nCol := oFolder:nWidth/2

// Atualiza os itens do atendimento - .T. monta a getdados em branco.
Tk280SK1(@aHeadNew,@aColsNew,@aRodape,,,.T.)

// Cria o objeto que contara os atendimentos agendados.
Aadd( aPanels, { MsNewGetDados():New((nRow*.025),(nCol*.01),(nRow*.94), (nCol*.99),0,,,,,,4096,,,,oFolder:aDialogs[1],aHeadNew,aColsNew), "FOBJ04" } )


@ (nRow*.08),(nCol*.02) SAY STR0007 OF oFolder:aDialogs[2] PIXEL //"Abatimentos"
@ (nRow*.08),(nCol*.14) MSGET aRodape[1][1] VAR aRodape[1][2] Picture "@E 999,999,999.99" OF oFolder:aDialogs[2] PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)

@ (nRow*.30),(nCol*.02) SAY STR0008 OF oFolder:aDialogs[2] PIXEL //"Corr. Monet."
@ (nRow*.30),(nCol*.14) MSGET aRodape[2][1] VAR aRodape[2][2] Picture "@E 999,999,999.99" OF oFolder:aDialogs[2] PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)

@ (nRow*.52),(nCol*.02) SAY STR0009 OF oFolder:aDialogs[2] PIXEL //"Juros"
@ (nRow*.52),(nCol*.14) MSGET aRodape[3][1] VAR aRodape[3][2] Picture "@E 999,999,999.99" OF oFolder:aDialogs[2] PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)

@ (nRow*.74),(nCol*.02) SAY STR0010 OF oFolder:aDialogs[2] PIXEL //"Descontos"
@ (nRow*.74),(nCol*.14) MSGET aRodape[6][1] VAR aRodape[6][2] Picture "@E 999,999,999.99" OF oFolder:aDialogs[2] PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)


@ (nRow*.08),(nCol*.36) SAY STR0011 OF oFolder:aDialogs[2] PIXEL //"Acr�scimos"
@ (nRow*.08),(nCol*.48) MSGET aRodape[4][1] VAR aRodape[4][2] Picture "@E 999,999,999.99" OF oFolder:aDialogs[2] PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)

@ (nRow*.30),(nCol*.36) SAY STR0012 OF oFolder:aDialogs[2] PIXEL //"Decr�scimos"
@ (nRow*.30),(nCol*.48) MSGET aRodape[5][1] VAR aRodape[5][2] Picture "@E 999,999,999.99" OF oFolder:aDialogs[2] PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)

@ (nRow*.52),(nCol*.36) SAY STR0013 OF oFolder:aDialogs[2] PIXEL //"Sld Mda Tit."
@ (nRow*.52),(nCol*.48) MSGET aRodape[8][1] VAR aRodape[8][2] Picture "@E 999,999,999.99" OF oFolder:aDialogs[2] PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)

@ (nRow*.74),(nCol*.36) SAY STR0014 OF oFolder:aDialogs[2] PIXEL //"Sld Mda Corr."
@ (nRow*.74),(nCol*.48) MSGET aRodape[9][1] VAR aRodape[9][2] Picture "@E 999,999,999.99" OF oFolder:aDialogs[2] PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)


@ (nRow*.08),(nCol*.70) SAY STR0015 OF oFolder:aDialogs[2] PIXEL //"Valor Original"
@ (nRow*.08),(nCol*.82) MSGET aRodape[7][1] VAR aRodape[7][2] Picture "@E 999,999,999.99" OF oFolder:aDialogs[2] PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)

@ (nRow*.30),(nCol*.70) SAY STR0016 OF oFolder:aDialogs[2] PIXEL //"Pagto Parcial"
@ (nRow*.30),(nCol*.82) MSGET aRodape[10][1] VAR aRodape[10][2] Picture "@E 999,999,999.99" OF oFolder:aDialogs[2] PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12)

@ (nRow*.52),(nCol*.70) SAY STR0017 OF oFolder:aDialogs[2] PIXEL COLOR CLR_RED //"D�v Mda T�t"
@ (nRow*.52),(nCol*.82) MSGET aRodape[11][1] VAR aRodape[11][2] Picture "@E 999,999,999.99" OF oFolder:aDialogs[2] PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12) COLOR CLR_RED

@ (nRow*.74),(nCol*.70) SAY STR0018 OF oFolder:aDialogs[2] PIXEL COLOR CLR_RED //"D�v Mda Corr"
@ (nRow*.74),(nCol*.82) MSGET aRodape[12][1] VAR aRodape[12][2] Picture "@E 999,999,999.99" OF oFolder:aDialogs[2] PIXEL When .F. SIZE (nCol*.17) ,(nRow*.12) COLOR CLR_RED

Aadd( aPanels, { aRodape, "FOBJ05" } )


Return(.T.)
