#INCLUDE "TMKA280B.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk280TLC02�Autor  �Armando M. Tessaroli� Data �  16/05/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Painel que demonstra o ultimo atendimento realizado para o  ���
���          �cliente.                                                    ���
�������������������������������������������������������������������������͹��
���Parametros�oExplorer - Objeto que contem os paineis com os dados do    ���
���          �            pre-atendimento.                                ���
���          �nPanel    - Nupero do painel corrente.                      ���
���          �aPanels   - Todos objetos de todos paineis.                 ���
���          �aMemory   - Vaiaveis de memoria utilizada pelas MSMGET.     ���
�������������������������������������������������������������������������͹��
���Uso       � TMKA280                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Tk280TLC02(oExplorer, nPanel, aPanels, aMemory)

// Definicao de variaveis de manipulacao
Local nRow		:= Int((oExplorer:aPanel[nPanel]:nHeight * .97) / 2)
Local nCol		:= Int((oExplorer:aPanel[nPanel]:nWidth * .985) / 2)
Local aCoord	:= {}
Local cMemo		:= MSMM(SA1->A1_CODHIST)

// Definicao de variaveis para objetos
Local oFonte
Local oSay1
Local oSay2
Local oMemo

DEFINE FONT oFonte NAME "Arial" SIZE 0,14 BOLD

//������������������
//�Parte 01 da tela�
//������������������
@ (nRow*.010), (nCol*.010) TO (nRow*.59), nCol OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.010), (nCol*.020) SAY oSay1 PROMPT STR0001 FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// " Atendimento Referente ao Item da Agenda"
oSay1:lTransparent := .F.
oSay1:nHeight := 14
oSay1:nWidth  := (Len(STR0001) * 6.2) //" Atendimento Referente ao Item da Agenda"

Aadd(aCoord, { (nRow*.04), (nCol*.02), (nRow*.57), (nCol*.99) } )
Aadd( aPanels, { MsMGet():New("ACF", ACF->(RecNo()), 2,,,,,aCoord[1],,,,,,oExplorer:GetPanel(nPanel),,.F.,, ), "BOBJ01", .F.})

//������������������
//�Parte 02 da tela�
//������������������
@ (nRow*.610), (nCol*.010) TO nRow, nCol OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.610), (nCol*.020) SAY oSay2 PROMPT STR0002 FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// " Hist�rico do Atendimento"
oSay2:lTransparent := .F.
oSay2:nHeight := 14
oSay2:nWidth  := (Len(STR0002) * 6.2) //" Hist�rico do Atendimento"

@ (nRow*.64), (nCol*.02) GET oMemo VAR cMemo OF oExplorer:GetPanel(nPanel) MEMO SIZE (nCol*.97), (nRow*.34) READONLY PIXEL
Aadd( aPanels, { oMemo, "BOBJ02" } )
 
Return(.T.)

