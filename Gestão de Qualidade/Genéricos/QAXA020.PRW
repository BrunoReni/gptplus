#INCLUDE "PROTHEUS.CH"
#INCLUDE "QAXA020.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � QAXA020  � Autor � Eduardo de Souza      � Data � 15/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Envio de email para usuarios.                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Eduardo S.  �27/03/02� META � Alterado para utilizar o novo conceito de���
���            �        �      � arquivos de Usuarios do Quality.         ���
���Eduardo S.  �22/08/02� ---- � Acerto para apresentar somente usuarios  ���
���            �        �      � referente a filial selecionada.          ���
���Eduardo S.  �08/01/03� ---- � Alterado para permitir pesquisar usuarios���
���            �        �      � de outras filiais.                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QAXA020()

Local oDlg
Local oScroll
Local oDeQAAFil
Local oDeQAAMat
Local oDeQAANom
Local oAteQAAFil
Local oAteQAAMat
Local oAteQAANom
Local oDeQADCC
Local oDeQADDes
Local oAteQADCC
Local oAteQADDes
Local oAssunto
Local oCorpo
Local cDeQAANom := Space(TamSx3("QAA_NOME")[1])
Local cAteQAANom:= Space(TamSx3("QAA_NOME")[1])
Local cDeQADDes := Space(TamSx3("QAD_DESC")[1])
Local cAteQADDes:= Space(TamSx3("QAD_DESC")[1])
Local cAssunto  := Space(150)
Local cCorpo    := " "

Private Inclui:= .F.
Private cDeQAAFil := xFilial("QAA")
Private cAteQAAFil:= xFilial("QAA")
Private cDeQAAMat := Space(TamSx3("QAA_MAT")[1])
Private cAteQAAMat:= Space(TamSx3("QAA_MAT")[1])
Private cDeQADCC  := Space(TamSx3("QAD_CUSTO")[1])
Private cAteQADCC := Space(TamSx3("QAD_CUSTO")[1])
Private aUsrMat   := QA_USUARIO()
Private cFilMat   := xFilial("QAA")
Private nQaConpad := 5

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM 000,000 TO 405,625 OF oMainWnd PIXEL //"e-Mail"
oScroll:= TScrollBox():new(oDlg,035,003,175,308,.T.,.T.,.T.)

@ 004,002 SAY OemToAnsi(STR0002) SIZE 065,007 OF oScroll PIXEL // "De Usuario:"
@ 003,033 MSGET oDeQAAFil VAR cDeQAAFil F3 "SM0" SIZE 050,007 OF oScroll PIXEL;
				VALID QA_CHKFIL(cDeQAAFil,@cFilMat)
				
@ 003,084 MSGET oDeQAAMat VAR cDeQAAMat F3 "QDE" SIZE 050,007 OF oScroll PIXEL;
				VALID QAX20VQAA(cDeQAAFil,cDeQAAMat,@cDeQAANom,@oDeQAANom)
@ 003,135 MSGET oDeQAANom VAR cDeQAANom SIZE 130,007 OF oScroll PIXEL
oDeQAANom:lReadOnly:= .T.

@ 017,002 SAY OemToAnsi(STR0003) SIZE 065,007 OF oScroll PIXEL // "Ate Usuario:"
@ 016,033 MSGET oAteQAAFil VAR cAteQAAFil F3 "SM0" SIZE 050,007 OF oScroll PIXEL;
				VALID QA_CHKFIL(cAteQAAFil,@cFilMat)

@ 016,084 MSGET oAteQAAMat VAR cAteQAAMat F3 "QDE" SIZE 050,007 OF oScroll PIXEL;
				VALID QAX20VQAA(cAteQAAFil,cAteQAAMat,@cAteQAANom,@oAteQAANom)
@ 016,135 MSGET oAteQAANom VAR cAteQAANom SIZE 130,007 OF oScroll PIXEL
oAteQAANom:lReadOnly:= .T.

@ 030,002 SAY OemToAnsi(STR0004) SIZE 055,007 OF oScroll PIXEL // "De Depto:"
@ 029,033 MSGET oDeQADCC VAR cDeQADCC F3 "QAD" SIZE 050,007 OF oScroll PIXEL;
				VALID QAX20VQAD(cDeQADCC,@cDeQADDes,@oDeQADDes)
@ 029,085 MSGET oDeQADDes VAR cDeQADDes SIZE 150,007 OF oScroll PIXEL
oDeQADDes:lReadOnly:= .T.

@ 043,002 SAY OemToAnsi(STR0005) SIZE 055,007 OF oScroll PIXEL // "Ate Depto:"
@ 042,033 MSGET oAteQADCC VAR cAteQADCC F3 "QAD" SIZE 050,007 OF oScroll PIXEL;
				VALID QAX20VQAD(cAteQADCC,@cAteQADDes,@oAteQADDes)
@ 042,085 MSGET oAteQADDes VAR cAteQADDes SIZE 150,007 OF oScroll PIXEL
oAteQADDes:lReadOnly:= .T.

@ 057,002 SAY OemToAnsi(STR0006) SIZE 055,007 OF oScroll PIXEL // "Assunto:"
@ 056,033 MSGET oAssunto VAR cAssunto SIZE 272,007 OF oScroll PIXEL

@ 069,002 GET oCorpo VAR cCorpo MEMO NO VSCROLL SIZE 302, 95 OF oScroll PIXEL

DbSelectArea("QAA")

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| QAX20MAIL(Alltrim(cAssunto),AllTrim(cCorpo)),oDlg:End()},{|| oDlg:End()})

Return Nil

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun�ao	 � QAX20VQAA � Autor �Eduardo de Souza         � Data � 15/01/02 ���
����������������������������������������������������������������������������Ĵ��
���Descri�ao � Valida Usuario                                                ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QAX20VQAA()                                                   ���
����������������������������������������������������������������������������Ĵ��
���Uso		 �QAXA020()                                                      ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function QAX20VQAA(cQAAFil,cQAAMat,cQAANom,oQAANom)

Local lRet:= .t.

If !Empty(cQAAMat)
	cQAANom:= QA_NUSR(cQAAFil,cQAAMat)
	If Empty(cQAANom)
		Help(" ",1,"QD050FNE") // Funcionario nao Existe
		lRet:= .f.
	EndIf
Else
	cQAANom:= " "
EndIf

oQAANom:Refresh()

Return lRet

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun�ao	 � QAX20VQAD � Autor �Eduardo de Souza         � Data � 15/01/02 ���
����������������������������������������������������������������������������Ĵ��
���Descri�ao � Valida Centro de Custo                                        ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QAX20VQAD()                                                   ���
����������������������������������������������������������������������������Ĵ��
���Uso		 �QAXA020()                                                      ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function QAX20VQAD(cQADCC,cQADDes,oQADDes)

Local lRet := .t.

If !Empty(cQADCC)
	cQADDes:= QA_NDEPT(cQADCC)
	If Empty(cQADDes)
	   Help(" ",1,"QD050CCNE")	// C.Custo/Depto nao Existe
		lRet:= .f.
	EndIf
Else
	cQADDes:= " "
EndIf

oQADDes:Refresh()

Return lRet

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun�ao	 � QAX20MAIL � Autor �Eduardo de Souza         � Data � 15/01/02 ���
����������������������������������������������������������������������������Ĵ��
���Descri�ao � Dispara e-mail para usuarios                                  ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QAX20MAIL()                                                   ���
����������������������������������������������������������������������������Ĵ��
���Uso		 � QAXA020()                                                     ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function QAX20MAIL(cAssunto,cCorpo)

Local aUsrMail:= {}

//������������������������������Ŀ
//�Filtra Usuarios					�
//��������������������������������
MsgRun( OemToAnsi(STR0012), OemToAnsi(STR0011), {|| QAX20Filt()}) //"Carregando Usuarios..."  ### "Aguarde..."	

DbGoTop()
While !Eof()
	Qax20CarMail(@aUsrMail,QAA_APELID,QAA_EMAIL,cAssunto,cCorpo)
	DbSkip()
EndDo

#IFDEF TOP
	DbSelectArea("QAA_TRB")
	DbCloseArea()          
	DbSelectArea("QAA")
#ELSE               
	QAA->(DbClearFilter())
#ENDIF

IF Len(aUsrMail) > 0
	QaEnvMail(aUsrMail,,,,aUsrMat[5],"2")
Endif	

Return Nil

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun�ao	 � QAX20Filt � Autor �Eduardo de Souza         � Data � 15/01/02 ���
����������������������������������������������������������������������������Ĵ��
���Descri�ao � Filtra Usuarios Selecionados                                  ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QAX20Filt()                                                   ���
����������������������������������������������������������������������������Ĵ��
���Uso		 � QAXA020()                                                     ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function QAX20Filt()
#IFDEF TOP
	Local cQuery:= ""
#ELSE
	Local cFiltro:= ""
#ENDIF

DBSelectArea("QAA")
DBSetOrder(1)

#IFDEF TOP
	If TcSrvType() != "AS/400"

		cQuery := "SELECT * "
		cQuery += " FROM " + RetSqlName("QAA") + " WHERE " + Qa_FilSitF(.T.)
		cQuery += " AND (QAA_FILIAL >= '"+cDeQAAFil +"' AND QAA_MAT >= '"+cDeQAAMat +"')" 
		cQuery += " AND (QAA_FILIAL <= '"+cAteQAAFil+"' AND QAA_MAT <= '"+cAteQAAMat+"')"
		cQuery += " AND QAA_CC >= '"+cDeQADCC +"' AND QAA_CC <= '"+cAteQADCC +"'"
		cQuery += " AND QAA_RECMAI = '1' AND QAA_EMAIL <> ' '"
		cQuery += " AND D_E_L_E_T_ <> '*'"
		cQuery += " ORDER BY " + SqlOrder(QAA->(IndexKey()))			

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QAA_TRB', .F., .T.)
		DbSelectArea("QAA_TRB")
	EndIf
#ELSE
	cFiltro := Qa_FilSitF()
	cFiltro += ' .And. (QAA->QAA_FILIAL >= "'+cDeQAAFil +'" .And. QAA->QAA_MAT >= "'+cDeQAAMat +'")'
	cFiltro += ' .And. (QAA->QAA_FILIAL <= "'+cAteQAAFil+'" .And. QAA->QAA_MAT <= "'+cAteQAAMat+'")'
	cFiltro += ' .And. QAA->QAA_CC >= "'+cDeQADCC +'" .And. QAA->QAA_CC <= "'+cAteQADCC +'"'
	cFiltro += ' .And. QAA->QAA_RECMAI == "1" .And. !Empty(QAA->QAA_EMAIL)'
	Set Filter To &( cFiltro ) 
#ENDIF

Return

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun�ao	 �Qax20CarMail� Autor �Eduardo de Souza        � Data � 16/01/02 ���
����������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega email                                                 ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Qax20CarMail()                                                ���
����������������������������������������������������������������������������Ĵ��
���Uso		 � QAXA020()                                                     ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function Qax20CarMail(aUsrMail,cApelido,cMail,cAssunto,cCorpo)

Local aMsg    := {}
Local cMsg    := " "               
Local cSubject:= " "
Local cAttach := " "
Local cMatFil  := aUsrMat[2] // Filial do Usuario Logado
Local cMatCod  := aUsrMat[3] // Matricula do Usuario Logado
Local cMatDep  := aUsrMat[4] // Depto do Usuario Logado
Local nOrdQAA  := QAA->(IndexOrd())
Local nPosQAA  := QAA->(RecNo())
Local cTpMail  := "1"

cTpMail:= QAA->QAA_TPMAIL

cSubject := cAssunto
If cTpMail == "1"
	cMsg:= '<html><title>'+OemToAnsi(STR0007)+'</title><body>' // "Advanced Protheus" 
	cMsg+= '<table bordercolor=#0099cc height=29 cellspacing=1 width=645 bordercolorlight=#0099cc border=1>'
	cMsg+= ' <tr><td bordercolor=#0099cc bordercolorlight=#0099cc align=left width=606'
	cMsg+= '   bgcolor=#0099cc bordercolordark=#0099cc height=1>'
	cMsg+= '   <p align=center><font face="courier new" color=#ffffff size=4>'
	cMsg+= '   <b>'+OemToAnsi(STR0008)+'</b></font></p></td></tr>' // "ASSUNTO"
	cMsg+= ' <tr><td align=left width=606 height=32>'
	cMsg+= '   <p align=center>'+cAssunto+'</p></td></tr>'
	cMsg+='</table>'
	
	cMsg+= '<table bordercolor=#0099cc height=29 cellspacing=1 width=645 bordercolorlight=#0099cc border=1>'
	cMsg+= '  <tr><td colspan=6 bordercolor=#0099cc bordercolorlight=#0099cc align=left width=606'
	cMsg+= '   bgcolor=#0099cc bordercolordark=#0099cc height=1>'
	cMsg+= '   <p align=center><font face="courier new" color=#ffffff size=4>'
	cMsg+= '   <b>'+OemToAnsi(STR0009)+'</b></font></p></td></tr>' // "MENSAGEM"
	cMsg+= ' <tr><td align=left width=100% height=32>'+cCorpo+'</td></tr>'
	cMsg+= '</table>'
	If !Empty(cMatCod)	
		cMsg+= '<br>'+OemToAnsi(STR0010)+'<br>'+Alltrim(QA_NUSR(cMatFil,cMatCod)) //"Atenciosamente"
		cMsg+= '  <br>'+Alltrim(QA_NDEPT(cMatDep))
	Endif
Else
	cMsg:= cCorpo+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cMsg+= OemToAnsi(STR0010)+CHR(13)+CHR(10) //"Atenciosamente"
	If !Empty(cMatCod)
		cMsg+= Alltrim(QA_NUSR(cMatFil,cMatCod))+CHR(13)+CHR(10)
		cMsg+= Alltrim(QA_NDEPT(cMatDep))+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	Endif
EndIf

aMsg:=  {{cSubject,cMsg,cAttach}}

AADD(aUsrMail,{ AllTrim(cApelido),Trim(cMail),aMsg })

QAA->(DbSetOrder(nOrdQAA))
QAA->(DbGoto(nPosQAA))

Return Nil