#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISXCLASS.CH"
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FISXCLASS � Autor �Gustavo G. Rueda       � Data �24.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao utilizada para verificar a existencia das classes    ���
���          � fiscais no RPO para poder utiliza-la                       ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function FISXCLASS
Return .T.
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FISProgres� Autor �Gustavo G. Rueda       � Data �24.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Classe de barra de progressao cm detalhes de processamento  ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Esta classe foi construida com o objetivo de exibir mais    ���
���          � detalhes de algum processamento muito demorado, tendo a    ���
���          � possibilidade de informar uma previsao de termino, o que   ���
���          � atualmente nao eh possivel atraves das funcoes normais     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/  
Class FISProgress

Data	bFuncProc	As 	Block
Data	cCaption	As	String
Data	lExtTaf  	As	Boolean

Data	c1ASayProc	As	String
Data	o1ASayProc	As 	Object
Data	c1BSayProc	As	String
Data	o1BSayProc	As 	Object

Data	c2ASayProc	As	String
Data	o2ASayProc	As 	Object
Data	c2BSayProc	As	String
Data	o2BSayProc	As 	Object

Data	c1DetLin	As	String
Data	o1DetSay	As	Object

Data	c1ValLin	As	String
Data	o5DetSay	As	Object

Data	c2DetLin	As	String
Data	o2DetSay	As	Object

Data	c2ValLin	As	String
Data	o6DetSay	As	Object

Data	c3DetLin	As	String
Data	o3DetSay	As	Object

Data	c3ValLin	As	String
Data	o7DetSay	As	Object

Data	c4DetLin	As	String
Data	o4DetSay	As	Object

Data	c4ValLin	As	String
Data	o8DetSay	As	Object

Data	oDlg 		As 	Object
Data	nWidth 		As	Integer
Data	nHeight 	As	Integer
Data	nAlign 		As	Integer
Data	o1Progress	As	Object
Data	n1TProgress	As	Integer
Data	n1IncPr		As	Integer
Data	o2Progress	As	Object
Data	n2TProgress	As	Integer
Data	n2IncPr		As	Integer
Data	nCancel		As	Integer
Data	nPInc		As	Integer


Method New(bFuncProc,cCaption)			CONSTRUCTOR
Method Activate()
Method Set1Progress(nTotal,nPInc)
Method Set2Progress(nTotal,nPInc)
Method Inc1Progress()
Method Inc2Progress()
Method SetDetProgress(cDetLin1,nValLin1,cDetLin2,nValLin2,cDetLin3,nValLin3,cDetLin4,nValLin4)
Method Cancel()
Method Ret1Progress()
Method Ret2Progress()

EndClass
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �}New()    � Autor �Gustavo G. Rueda       � Data �24.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Metodo construtor da Classe, onde ocorre as inicializacoes  ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Nenhuma                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�bFuncProd -> Codeblock para execucao da rotina              ���
���          �cCaption  -> Titulo da barra da dialog                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FISProgress():New({||Funcao()},"Titulo")                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/  
Method New(bFuncProc,cCaption,lExtTaf) Class FISProgress     

Default lExtTaf := .F.

Self:bFuncProc	:=	bFuncProc
Self:cCaption	:=	cCaption  
Self:lExtTaf    := lExtTaf
Self:oDlg 		:= 	Nil
Self:nWidth 	:= 	450
Self:nHeight 	:= 	Iif( !lExtTaf, 380, 210 )
Self:nAlign 	:= 	CONTROL_ALIGN_ALLCLIENT
Self:n1IncPr	:=	1
Self:n2IncPr	:=	1
Self:nCancel	:=	0
Self:n1TProgress:=	1
Self:n2TProgress:=	1
Self:c1ASayProc	:=	STR0001	//"Obtendo informacoes, aguarde..."
Self:c1BSayProc	:=	""
Self:c2ASayProc	:=	STR0001	//"Obtendo informacoes, aguarde..."
Self:c2BSayProc	:=	""
Self:c1DetLin	:=	STR0001	//"Obtendo informacoes, aguarde..."
Self:c1ValLin	:=	""
Self:c2DetLin	:=	STR0001	//"Obtendo informacoes, aguarde..."
Self:c2ValLin	:=	""
Self:c3DetLin	:=	STR0001	//"Obtendo informacoes, aguarde..."
Self:c3ValLin	:=	""
Self:c4DetLin	:=	STR0001	//"Obtendo informacoes, aguarde..."
Self:c4ValLin	:=	""


Return
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Activate()� Autor �Gustavo G. Rueda       � Data �24.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Metodo que monta a dialog de exibicao das informacoes       ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Nenhuma                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FISProgress():Activate()                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/  
Method Activate() Class FISProgress
Local	oPanel1
Local	oPanel2
Local	bBlock		:=	Self:bFuncProc
Local   lExtTaf     :=  Self:lExtTaf
Local	oBntFin
Local	oBntCan
Local	oCoords		:=	oMainWnd:ReadClientCoors()	

DEFINE MSDIALOG Self:oDlg TITLE OemToAnsi(Self:cCaption)  PIXEL FROM 0,0 TO Self:nHeight,Self:nWidth Of oMainWnd

oPanel1	:=	TPanel():New (0,0,,Self:oDlg,,,,,,230,85,.F.,.F.)
TGroup ():New(5, 5, 80, 220, "", oPanel1,,, .T., .T. )

Self:o1ASayProc	:=	TSay():New(010,010,{|| Self:c1ASayProc },oPanel1,,,,,,.T.,,,200,15,,,,.T.,,.T.)
Self:o1Progress	:=	TMeter():New(20,10,,Self:n1TProgress,oPanel1,205,10,,.T.,/*oFtArialB*/,"",.T.,,,GetSysColor(13),GetSysColor(),.F.)
Self:o1Progress:Set(0)
Self:o1BSayProc	:=	TSay():New(035,010,{|| Self:c1BSayProc },oPanel1,,,,.T.,,.T.,,,200,15,,,,.T.,,.T.)


Self:o2ASayProc	:=	TSay():New(045,010,{|| Self:c2ASayProc },oPanel1,,,,,,.T.,,,200,15,,,,.T.,,.T.)
Self:o2Progress	:=	TMeter():New(55,10,,Self:n2TProgress,oPanel1,205,10,,.T.,/*oFtArialB*/,"",.T.,,,GetSysColor(13),GetSysColor(),.F.)
Self:o2Progress:Set(0)
Self:o2BSayProc	:=	TSay():New(070,010,{|| Self:c2BSayProc },oPanel1,,,,.T.,,.T.,,,200,15,,,,.T.,,.T.)
                    
If !lExtTaf
	oPanel2	:=	TPanel():New (82,0,,Self:oDlg,,,,,,230,110,.F.,.F.)
	TGroup ():New(0, 5, 85, 220, "", oPanel2,,, .T., .T. )
	
	Self:o1DetSay	:=	TSay():New(010,010,{|| Self:c1DetLin },oPanel2,,,,,,.T.,,,150,10,,,,.T.,,.T.)
	Self:o5DetSay	:=	TSay():New(010,161,{|| Self:c1ValLin },oPanel2,,,,.T.,,.T.,,,050,10,,,,.T.,,.T.)
	TGroup ():New(21, 10, 23, 210, "", oPanel2,,, .T., .T. )
	
	Self:o2DetSay	:=	TSay():New(028,010,{|| Self:c2DetLin },oPanel2,,,,,,.T.,,,150,10,,,,.T.,,.T.)
	Self:o6DetSay	:=	TSay():New(028,161,{|| Self:c2ValLin },oPanel2,,,,.T.,,.T.,,,050,10,,,,.T.,,.T.)
	TGroup ():New(39, 10, 41, 210, "", oPanel2,,, .T., .T. )
	
	Self:o3DetSay	:=	TSay():New(046,010,{|| Self:c3DetLin },oPanel2,,,,,,.T.,,,150,10,,,,.T.,,.T.)
	Self:o7DetSay	:=	TSay():New(046,161,{|| Self:c3ValLin },oPanel2,,,,.T.,,.T.,,,050,10,,,,.T.,,.T.)
	TGroup ():New(57, 10, 59, 210, "", oPanel2,,, .T., .T. )
	
	Self:o4DetSay	:=	TSay():New(064,010,{|| Self:c4DetLin },oPanel2,,,,,,.T.,,,150,10,,,,.T.,,.T.)
	Self:o8DetSay	:=	TSay():New(064,161,{|| Self:c4ValLin },oPanel2,,,,.T.,,.T.,,,050,10,,,,.T.,,.T.)
	TGroup ():New(75, 10, 77, 210, "", oPanel2,,, .T., .T. )
EndIf

If !lExtTaf
	oBntFin	:=	TButton():New(174,180, STR0002,Self:oDlg,{|| Self:oDlg:End(), Self:nCancel := 0},40,13,,,,.T.,,,,,,)		//'Finalizar'
	oBntFin:Hide()
	oBntCan	:=	TButton():New(174,180, STR0003 ,Self:oDlg,{|| Iif(CancProc(),(Self:oDlg:End(),Self:nCancel := 1),)},40,13,,,,.T.,,,,,,)	//'Cancelar'
Else
	oBntFin	:=	TButton():New(85,180, STR0002,Self:oDlg,{|| Self:oDlg:End(), Self:nCancel := 0},40,13,,,,.T.,,,,,,)		//"Finalizar"
	oBntFin:Hide()
	oBntCan	:=	TButton():New(85,180, STR0003 ,Self:oDlg,{|| Iif(CancProc(),(Self:oDlg:End(),Self:nCancel := 1),)},40,13,,,,.T.,,,,,,)	//"Cancelar"
EndIf

ACTIVATE MSDIALOG Self:oDlg CENTERED ON INIT (Eval(bBlock),Eval({||oBntCan:Hide(),oBntFin:Show()}))

Return
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Set1Prog()� Autor �Gustavo G. Rueda       � Data �24.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Metodo que define o total da progressao da barra principal  ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Nenhuma                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�nTotal -> Total da progressao                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FISProgress():Set1Progress(1000)                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method Set1Progress(nTotal,nPInc) Class FISProgress
Default	nPInc	:=	1

Self:n1IncPr	:=	nPInc
Self:o1Progress:Set(1)
Self:o1Progress:nTotal	:=	nTotal
Self:o1Progress:Refresh()
Return
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Set2Prog()� Autor �Gustavo G. Rueda       � Data �24.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Metodo que define o total da progressao da barra secundaria ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Nenhuma                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�nTotal -> Total da progressao                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FISProgress():Set2Progress(100)                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method Set2Progress(nTotal,nPInc) Class FISProgress
Default	nPInc	:=	1

Self:n2IncPr	:=	nPInc
Self:o2Progress:Set(1)
Self:o2Progress:nTotal	:=	nTotal
Self:o2Progress:Refresh()
Return
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Inc1Prog()� Autor �Gustavo G. Rueda       � Data �24.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Metodo que define o incremento da barra de progressao       ���
���          �  principal.                                                ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Nenhuma                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�c1ASayProc -> Define o titulo da barra de progressao        ���
���          �              principal                                     ���
���          �c1BSayProc -> Permite exibir um status de outra forma alem  ���
���          �              da barra de progressao principal              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FISProgress():Inc1Progress("Proc. NFs","1/10")              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method Inc1Progress(c1ASayProc,c1BSayProc) Class FISProgress
Default	c1ASayProc	:=	Self:c1ASayProc
Default	c1BSayProc	:=	Self:c1BSayProc

Self:c1ASayProc				:=	c1ASayProc
Self:o1ASayProc:cTitle 		:=	c1ASayProc
Self:o1ASayProc:cCaption	:=	c1ASayProc
Self:o1ASayProc:Refresh()

Self:c1BSayProc				:=	c1BSayProc
Self:o1BSayProc:cTitle 		:=	c1BSayProc
Self:o1BSayProc:cCaption	:=	c1BSayProc
Self:o1BSayProc:Refresh()

Self:o1Progress:Set(Self:n1IncPr++)

Return
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Inc2Prog()� Autor �Gustavo G. Rueda       � Data �24.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Metodo que define o incremento da barra de progressao       ���
���          �  secundaria                                                ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Nenhuma                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�c2ASayProc -> Define o titulo da barra de progressao        ���
���          �              secundaria                                    ���
���          �c2BSayProc -> Permite exibir um status de outra forma alem  ���
���          �              da barra de progressao secundaria             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FISProgress():Inc2Progress("Proc. dia...","1/5")            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method Inc2Progress(c2ASayProc,c2BSayProc) Class FISProgress
Default	c2ASayProc	:=	Self:c2ASayProc
Default	c2BSayProc	:=	Self:c2BSayProc

Self:c2ASayProc				:=	c2ASayProc
Self:o2ASayProc:cTitle 		:=	c2ASayProc
Self:o2ASayProc:cCaption	:=	c2ASayProc
Self:o2ASayProc:Refresh()

Self:c2BSayProc				:=	c2BSayProc
Self:o2BSayProc:cTitle 		:=	c2BSayProc
Self:o2BSayProc:cCaption	:=	c2BSayProc
Self:o2BSayProc:Refresh()

Self:o2Progress:Set(Self:n2IncPr++)

Return
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �SetDetPr()� Autor �Gustavo G. Rueda       � Data �24.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Metodo que permite atualizar os detalhes do processamento,  ���
���          � como previsao de termino, tempo medio, etc...              ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Os status sao LIMITADOS a quatro linhas de exibicao.        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�c1DetLin -> Primeira linha de mensagem a ser apresentada    ���
���          �c1ValLin -> Valor referente a este primeiro status          ���
���          �c2DetLin -> Segunda  linha de mensagem a ser apresentada    ���
���          �c2ValLin -> Valor referente a este segundo  status          ���
���          �c3DetLin -> Terceira linha de mensagem a ser apresentada    ���
���          �c3ValLin -> Valor referente a este terceiro status          ���
���          �c4DetLin -> Quarta linha de mensagem a ser apresentada      ���
���          �c4ValLin -> Valor referente a este quarto status            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FISProgress():SetDetProgress("msg 1","1","msg 2","2",;      ���
���          �      "msg 3","3","msg 4","4")                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method SetDetProgress(c1DetLin,c1ValLin,c2DetLin,c2ValLin,c3DetLin,c3ValLin,c4DetLin,c4ValLin) Class FISProgress

Self:c1DetLin	:=	c1DetLin
Self:c1ValLin	:=	c1ValLin
Self:c2DetLin	:=	c2DetLin
Self:c2ValLin	:=	c2ValLin
Self:c3DetLin	:=	c3DetLin
Self:c3ValLin	:=	c3ValLin
Self:c4DetLin	:=	c4DetLin
Self:c4ValLin	:=	c4ValLin

Self:o1DetSay:refresh()
Self:o2DetSay:refresh()
Self:o3DetSay:refresh()
Self:o4DetSay:refresh()
Self:o5DetSay:refresh()
Self:o6DetSay:refresh()
Self:o7DetSay:refresh()
Self:o8DetSay:refresh()

Return
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Cancel()  � Autor �Gustavo G. Rueda       � Data �24.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Metodo que permite verificar se o processo foi cancelado    ���
���          � para que seja possivel abortar a rotina                    ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FISProgress():Cancel()                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1 -> .T. para processo cancelado e .F. para processa-   ���
���          �         mento normal                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method Cancel() Class FISProgress
Return Self:nCancel==1
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CancProc  � Autor �Gustavo G. Rueda       � Data �24.03.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de confirmacao do cancelamento de processamento da   ���
���          � rotina                                                     ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CancProc()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1 -> .T. para processo cancelado e .F. para processa-   ���
���          �         mento normal                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function CancProc()
Return MsgYesNo(STR0004)	//"Deseja realmente cancelar o processamento da rotina ?"
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Ret1Progre� Autor �Gustavo G. Rueda       � Data �08.04.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Metodo que retorna o status da regua de processamento caso  ���
���          � necessite salvar, processar outra e retornar da onde parou ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FISProgress():Ret1Progress()                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpN1 -> Posicao do incremento da primeira regua            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method Ret1Progress() Class FISProgress
Return Self:n1IncPr
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Ret2Progre� Autor �Gustavo G. Rueda       � Data �08.04.2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Metodo que retorna o status da regua de processamento caso  ���
���          � necessite salvar, processar outra e retornar da onde parou ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FISProgress():Ret1Progress()                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpN1 -> Posicao do incremento da segunda  regua            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method Ret2Progress() Class FISProgress
Return Self:n2IncPr