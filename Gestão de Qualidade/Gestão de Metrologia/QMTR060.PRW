#INCLUDE "QMTR060.CH"
#INCLUDE "Protheus.CH"
#INCLUDE "Report.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QMTR060   �Autor  �Leandro Sabino      � Data �  19/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rela�ao de Padroes a Calibrar                              ���
���          � (Versao Relatorio Personalizavel)                          ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                            
Function QMTR060()
Local oReport

If TRepInUse()
	//�����������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros							�
	//� mv_par01				// Periodo Inicial						�
	//� mv_par02				// Periodo Final                        �
	//�������������������������������������������������������������������
	Pergunte("QMR060",.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
    QMTR060R3()	// Executa vers�o anterior do fonte
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 18/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTR060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local ctitulo   := OemToAnsi(STR0002) // "Padroes a Calibrar"
Local cDesc1	:= OemToAnsi(STR0001) // "Este programa ir� emitir o relat�rio de padr�es a calibrar."
Local oSection1 

DEFINE REPORT oReport NAME "QMTR060" TITLE cTitulo PARAMETER "QMR060" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1)
oReport:SetLandscape(.T.)

DEFINE SECTION oSection1 OF oReport TABLES "QM3" Title OemToAnsi(STR0007) //Padroes

DEFINE CELL NAME "QM3_PADRAO"  OF oSection1 ALIAS "QM3" 
DEFINE CELL NAME "QM3_REVPAD"  OF oSection1 ALIAS "QM3" 
DEFINE CELL NAME "QM3_DESCRI"  OF oSection1 ALIAS "QM3" 
DEFINE CELL NAME "QM3_DATAF"   OF oSection1 ALIAS "QM3" 
DEFINE CELL NAME "QM3_FREQAF"  OF oSection1 ALIAS "QM3" 
DEFINE CELL NAME "QM3_VALDAF"  OF oSection1 ALIAS "QM3" 

Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 19/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Rela�ao de Padroes a Calibrar 							  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)  	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTR060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                  
Static Function PrintReport(oReport) 
Local oSection1 := oReport:Section(1)
Local cStrAnt	:= ""
Local cindex    := ""  
Local cAliasQM3
Local lTop := .T.
		               
dbSelectArea("QM3")
dbSetOrder(1)

MakeSqlExpr(oReport:uParam)

cAliasQM3 := GetNextAlias()

oSection1:BeginQuery()
    
BeginSQL Alias cAliasQM3

SELECT QM3.QM3_FILIAL,QM3.QM3_PADRAO,QM3.QM3_REVPAD,QM3.QM3_DESCRI,QM3.QM3_DATAF,QM3.QM3_FREQAF,QM3.QM3_VALDAF  
       FROM %table:QM3% QM3
	   WHERE QM3.QM3_FILIAL = %xFilial:QM3% AND 
                 QM3.QM3_VALDAF BetWeen %Exp:mv_par01% AND  %Exp:mv_par02% AND 
	         QM3.%notDel% 
	   ORDER BY QM3_FILIAL,QM3_PADRAO,QM3_INVRPD
EndSql	

oSection1:EndQuery()

While !oReport:Cancel() .And. &(cAliasQM3)->(!Eof())

	If !QMTR060Val(&(cAliasQM3+"->QM3_PADRAO"),&(cAliasQM3+"->QM3_REVPAD")) // Nao existe  uma revisaio maior que a atual?
		&(cAliasQM3)->(dbSkip())		
		Loop
    EndIf
    
	If QM3->QM3_PADRAO == cStrAnt
		&(cAliasQM3)->(dbSkip())             
		Loop
	Else
	   oSection1:Init()
	EndIf

	cStrAnt := QM3->QM3_PADRAO  
	
	oSection1:PrintLine()
	QM3->(dbSkip())
Enddo
oSection1:Finish()

dbSelectArea("QM3")
dbSetOrder(01)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QMTr060R3� Autor � Alessandro B. Freire  � Data � 23.03.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rela�ao de Padroes a Calibrar							  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Qmtr060(void)											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Qmtr060R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis 											 �
//����������������������������������������������������������������
Local cDesc1		:= OemToAnsi(STR0001) // "Este programa ir� emitir o relat�rio de padr�es a calibrar."
Local cDesc2		:= ""
Local cDesc3		:= ""
Local cString		:="QM3"
Local wnrel   

PRIVATE titulo    := OemToAnsi(STR0002) // "Padroes a Calibrar"
PRIVATE cabec1 	:= OemToAnsi(STR0003) // "Padrao           Rev. Descricao                           Afericao Freq Validade"

PRIVATE cabec2 	:= ""
PRIVATE aReturn	:= {OemToAnsi(STR0004),1,OemToAnsi(STR0005),1,2,1,"",1} // "Zebrado"###"Administra��o" 
PRIVATE nomeprog	:="QMTR060"
PRIVATE nLastKey	:= 0
PRIVATE cPerg		:="QMR060"
PRIVATE cTamanho := "M"

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas 							 �
//����������������������������������������������������������������
pergunte("QMR060",.F.)

//�����������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros							�
//� mv_par01				// Periodo Inicial						�
//� mv_par02				// Periodo Final                        �
//�������������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT 						 �
//����������������������������������������������������������������
wnrel:="QMTR060"
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,cTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| MTr060Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �QMA070PAva� Autor � Cicero Cruz           � Data � 13/05/05  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se existe uma  recvis�o maior que a do padrao consi -���
���          � derado.                                                     ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � QMA070PAva(ExpC1,ExpC2)                                     ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Padrao                                              ���
���          � ExpC2 = Revisao                                             ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � QMTR060                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function QMTR060Val(cPad,cRev)
Local lRet:=.T.
Local aArea	:= GetArea()

dbSelectArea("QM3")
dbSetOrder(1)
If DBSeek(xFilial("QM3")+cPad)
	If QM3->QM3_REVPAD > cRev
		lRet:=.F.
	Endif
EndIf   

RestArea( aArea )
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � MTr060IMP� Autor � Alessandro B.Freire   � Data � 23.03.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime PADROES A CALIBRAR                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � MTr060IMP(lEnd,wnRel,cString) 							  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd	  - Acao do Codeblock								  ���
���			 � wnRel   - T�tulo do relat�rio 							  ���
���			 � cString - Mensagem										  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MTr060Imp(lEnd,wnRel,cString)

Local CbCont
Local CbTxt
Local cStrAnt	:= ""
Local cQuery	:= ""	
Local cChave 
Local cFilterUser

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape	 �
//����������������������������������������������������������������
cbtxt 	:= SPACE(10)
cbcont	:= 0
li 		:= 80
m_pag 	:= 1

dbSelectArea("QM3")
dbSetOrder(1)

cChave := "QM3_FILIAL+QM3_PADRAO+QM3_INVRPD"
cQuery := "SELECT QM3_FILIAL,QM3_PADRAO,QM3_REVPAD,QM3_INVRPD,QM3_DESCRI,QM3_DATAF,QM3_FREQAF,QM3_VALDAF " 
cQuery += "FROM "+RetSqlName("QM3")+" "
cQuery += "WHERE "
cQuery += "QM3_FILIAL = '"			+xFilial("QM3")+	"' AND "
cQuery += "QM3_VALDAF BetWeen '"	+ Dtos(mv_par01)+	"' AND '" + DtoS(mv_par02) +	"' AND "
cQuery += "D_E_L_E_T_= ' ' "
cQuery += " ORDER BY " + SqlOrder(cChave)
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)
TcSetField("TRB","QM3_VALDAF","D",8,0)
TcSetField("TRB","QM3_DATAF","D",8,0)		
dbSelectArea( "TRB" )

SetRegua(RecCount())

Dbselectarea("QM3")
Dbsetorder(1)
dbgotop()

cFilterUser:= Iif(Type("cFilterUser") == "U", If(Type("aReturn[7]")=="U"," ", aReturn[7]), cFilterUser)

dbSelectArea( "TRB" )
dbGoTop()
While !TRB->(Eof())

	// Valida Padrao antes de imprimi-lo
	If !QMTR060Val(TRB->QM3_PADRAO,TRB->QM3_REVPAD) // Nao existe  uma revisaio maior que a atual?
		TRB->(dbSkip())		
		Loop
    EndIf
	If !Empty(cFilterUser) 
		If !QM3->(dbSeek(xFilial("QM3")+TRB->QM3_PADRAO+TRB->QM3_INVRPD)) // esta com filtro aplicado
			TRB->(dbSkip())
			Loop
		Endif	
    EndIf
	If TRB->QM3_PADRAO == cStrAnt
		TRB->(dbSkip())             
		Loop
	EndIf
	cStrAnt := TRB->QM3_PADRAO

	IF li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,ctamanho,IIF(aReturn[4]==1,15,18))
	End

/*
		  1 		2		  3		    4 		  5			6		  7 		8		  9			100
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
Padrao              Rev.   Descricao                              Afericao      Freq      Validade
xxxxxxxxxxxxxxxx    xx     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    xx/xx/xxxx    xxxx      xx/xx/xxxx
*/                  

	@li,000 PSAY TRB->QM3_PADRAO
	@li,020 PSAY TRB->QM3_REVPAD
	@li,027 PSAY TRB->QM3_DESCRI
	@li,066 PSAY DTOC(TRB->QM3_DATAF)
	@li,080 PSAY TRB->QM3_FREQAF
	@li,090 PSAY DTOC(TRB->QM3_VALDAF)
	
	li++
	TRB->(dbSkip())
Enddo
	

Roda( cbCont, cbTxt, cTamanho )

Set Device To Screen

dbSelectArea("TRB")
dbCloseArea()
dbSelectArea("QM3")
dbSetOrder(01)


If aReturn[5] = 1
	Set Printer TO
	dbCommitall()
	ourspool(wnrel)
Endif

MS_FLUSH()



