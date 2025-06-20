#INCLUDE "PROTHEUS.CH"
#INCLUDE "TAFXCLASS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TAFXCLASS � Autor �Gustavo G. Rueda       � Data �24.03.2011���
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
Function TAFXCLASS
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
Class TAFProgress

Data	bFuncProc	As 	Block
Data	cCaption	As	String

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

DATA	nTotal		As  Integer

Data	o2Progress	As	Object
Data	n2TProgress	As	Integer
Data	n2IncPr		As	Integer
Data	nCancel		As	Integer
Data	nPInc		As	Integer

Data lShowBtn As Boolean
Data lShowCan As Boolean

Method New(bFuncProc,cCaption,lShowBtn,lShowCan)			CONSTRUCTOR
Method Activate()
Method Set1Progress(nTotal,nPInc)
Method Set2Progress(nTotal,nPInc)
Method Inc1Progress()
Method Inc2Progress()
Method SetDetProgress(cDetLin1,nValLin1,cDetLin2,nValLin2,cDetLin3,nValLin3,cDetLin4,nValLin4)
Method Cancel()
Method Ret1Progress()
Method Ret2Progress()
Method Destroy()

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
���Sintaxe   �TAFProgress():New({||Funcao()},"Titulo")                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/  
Method New(bFuncProc,cCaption,lShowBtn,lShowCan) Class TAFProgress

Default lShowBtn := .T.
Default lShowCan := .T.
Self:bFuncProc	:=	bFuncProc
Self:cCaption	:=	cCaption
self:lShowBtn 	:= lShowBtn
self:lShowCan 	:= lShowCan
Self:oDlg 		:= 	Nil
Self:nWidth 	:= 	450
Self:nHeight 	:= 	210
Self:nAlign 	:= 	CONTROL_ALIGN_ALLCLIENT
Self:n1IncPr	:=	1
Self:n2IncPr	:=	1
Self:nCancel	:=	0
Self:n1TProgress:=	1
Self:n2TProgress:=	1
Self:c1ASayProc	:= STR0001  // "Iniciando Processamento..."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
Self:c1BSayProc	:=	""
Self:c2ASayProc	:=	STR0002 // "Obtendo informacoes, aguarde..."
Self:c2BSayProc	:=	""
Self:c1DetLin	:=	STR0002 // "Obtendo informacoes, aguarde..."
Self:c1ValLin	:=	""
Self:c2DetLin	:=	STR0002 // "Obtendo informacoes, aguarde..."
Self:c2ValLin	:=	""                                                                             
Self:c3DetLin	:=	STR0002 // "Obtendo informacoes, aguarde..."                                    
Self:c3ValLin	:=	""
Self:c4DetLin	:=	STR0002 // "Obtendo informacoes, aguarde..."
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
���Sintaxe   �TAFProgress():Activate()                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/  
Method Activate() Class TAFProgress
Local	oPanel1
Local	oPanel2
Local	bBlock		:=	Self:bFuncProc
Local	oBntFin
Local	oBntCan
Local	oCoords		:=	oMainWnd:ReadClientCoors()
Local 	lShowBtn  := Self:lShowBtn
Local 	lShowCan    := Self:lShowCan
DEFINE MSDIALOG Self:oDlg TITLE OemToAnsi(Self:cCaption)  PIXEL FROM 0,0 TO Self:nHeight*1.10,Self:nWidth Of oMainWnd

oPanel1	:=	TPanel():New (0,0,,Self:oDlg,,,,,,230,300,.F.,.F.)

TGroup ():New(5, 5, 95, 220, "", oPanel1,,, .T., .T. )

Self:o1ASayProc	:=	TSay():New(010,010,{|| Self:c1ASayProc },oPanel1,,,,,,.T.,,,200,15,,,,.T.,,.T.)
Self:o1Progress	:=	TMeter():New(30,10,,Self:n1TProgress,oPanel1,205,10,,.T.,/*oFtArialB*/,"",.T.,,,GetSysColor(13),GetSysColor(),.F.)
ProcessMessages() 
sleep(300) 
Self:o1Progress:Set(0)
ProcessMessages() 
sleep(300) 
Self:o1BSayProc	:=	TSay():New(045,010,{|| Self:c1BSayProc },oPanel1,,,,.T.,,.T.,,,200,15,,,,.T.,,.T.)

Self:o2ASayProc	:=	TSay():New(055,010,{|| Self:c2ASayProc },oPanel1,,,,,,.T.,,,200,15,,,,.T.,,.T.)
Self:o2Progress	:=	TMeter():New(65,10,,Self:n2TProgress,oPanel1,205,10,,.T.,/*oFtArialB*/,"",.T.,,,GetSysColor(13),GetSysColor(),.F.)
Self:o2Progress:Set(0)
Self:o2BSayProc	:=	TSay():New(080,010,{|| Self:c2BSayProc },oPanel1,,,,.T.,,.T.,,,200,15,,,,.T.,,.T.)

if lShowBtn
	oBntFin	:=	TButton():New(98,180, STR0003,Self:oDlg,{|| Self:oDlg:End(), Self:nCancel := 0},40,13,,,,.T.,,,,,,)		//"Finalizar"
	oBntFin:Hide()
endif

If lShowCan
oBntCan	:=	TButton():New(98,180, STR0004 ,Self:oDlg,{|| Iif(CancProc(),(Self:oDlg:End(),Self:nCancel := 1),)},40,13,,,,.T.,,,,,,)	//"Cancelar"

ProcessMessages() 
sleep(300) 
ACTIVATE MSDIALOG Self:oDlg CENTERED ON INIT (Eval(bBlock),Eval({||oBntCan:Hide(),iif( lShowBtn, oBntFin:Show(),Self:oDlg:End() ) }))
Else	
	ACTIVATE MSDIALOG Self:oDlg CENTERED ON INIT (Eval(bBlock) ,Eval({||iif( lShowBtn, oBntFin:Show(),Self:oDlg:End())}))
EndIf
ProcessMessages() 
sleep(300) 
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
���Sintaxe   �TAFProgress():Set1Progress(1000)                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method Set1Progress(nTotal,nPInc) Class TAFProgress
Default	nPInc	:= 0

Self:n1IncPr	:=	nPInc
Self:o1Progress:Set(0)
Self:o1Progress:SetTotal(nTotal)
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
���Sintaxe   �TAFProgress():Set2Progress(100)                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method Set2Progress(nTotal,nPInc) Class TAFProgress
Default	nPInc	:=	0

Self:n2IncPr	:=	nPInc
Self:o2Progress:Set(0)
Self:o2Progress:SetTotal(nTotal)	
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
���Sintaxe   �TAFProgress():Inc1Progress("Proc. NFs","1/10")              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method Inc1Progress(c1ASayProc,c1BSayProc) Class TAFProgress

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

If Self:n1IncPr<=Self:o1Progress:nTotal
	Self:o1Progress:Set(Self:n1IncPr++)
	ProcessMessages() 
	Sleep(300) 
	Self:oDlg:Refresh()
EndIf
ProcessMessages() 
Sleep(300) 

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
���Sintaxe   �TAFProgress():Inc2Progress("Proc. dia...","1/5")            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method Inc2Progress(c2ASayProc,c2BSayProc) Class TAFProgress

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


If Self:n2IncPr<=Self:o2Progress:nTotal
	Self:o2Progress:Set(Self:n2IncPr++ )
	ProcessMessages() 
	Sleep(300) 
	Self:oDlg:Refresh()
EndIf
ProcessMessages() 
Sleep(300) 

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
���Sintaxe   �TAFProgress():SetDetProgress("msg 1","1","msg 2","2",;      ���
���          �      "msg 3","3","msg 4","4")                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method SetDetProgress(c1DetLin,c1ValLin,c2DetLin,c2ValLin,c3DetLin,c3ValLin,c4DetLin,c4ValLin) Class TAFProgress

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
���Sintaxe   �TAFProgress():Cancel()                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1 -> .T. para processo cancelado e .F. para processa-   ���
���          �         mento normal                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method Cancel() Class TAFProgress
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
Return MsgYesNo(STR0005)	//"Deseja realmente cancelar o processamento da rotina ?"
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
���Sintaxe   �TAFProgress():Ret1Progress()                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpN1 -> Posicao do incremento da primeira regua            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method Ret1Progress() Class TAFProgress
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
���Sintaxe   �TAFProgress():Ret1Progress()                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpN1 -> Posicao do incremento da segunda  regua            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method Ret2Progress() Class TAFProgress
Return Self:n2IncPr
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Destroy()  � Autor �DAvid Costa		       � Data �19.12.2017���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Metodo que permite finalizar a tela sem o usu�rio clicar no ���
���          � Bot�o "Finalizar" 										   	    ���
�������������������������������������������������������������������������Ĵ��
���Observacao�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �TAFProgress():Destroy()                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum					                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method Destroy() Class TAFProgress

Self:oDlg:End()

Return()