#INCLUDE "MCLIPTG.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MCLIPTG   � Autor � Cleber Stenio         � Data �23/05/2008���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Relatorio para demonstrar uma rela��o de clientes que deverᳱ�
���			 � ser entregue quando o valor anual das Vendas seja:         ���
���			 � Para os anos anteriores a 2004, superior a 50.000 euros    ���
���			 � Para o ano 2004 e seguintes, superior a 25.000 euros       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador �Data    � BOPS     � Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Jonathan Glz�06/07/15�PCREQ-4256�Se elimina la funcion AjustaSX1() la  ���
���            �        �          �hace modificacion a SX1 por motivo de ���
���            �        �          �adecuacion a fuentes a nuevas estruc- ���
���            �        �          �turas SX para Version 12.             ���
���Alf. Medrano�09/11/15�PCREQ-4263� se realiza merge 12.1.8              ���
���Jonathan Glz�04/01/17�SERINN001-�Se modifica uso de tablas temporales  ���
���            �        �       892�por motivo de limpieza de CTREE.      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MCLIPTG()

Local oReport
Local cPerg		:=	"MCLIPT"

Pergunte(cPerg,.F.)
oReport := ReportDef()
oReport:PrintDialog()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Gustavo G. Rueda      � Data �22/05/2008���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Funcao que monta todas as secoes do relatorio               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �oReport - Objeto TReport                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cPerg - Nome do grupo de perguntas                          ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local aOrdem 	:= {STR0005}
Local oReport      
Local oContr
Local oMov
Local cReport	:= "MCLIPTG"
Local cPerg		:= "MCLIPT"
Local cTitulo	:= OemToAnsi(STR0001)	//"MAPA RECAPITULATIVO DE CLIENTES (ANEXO - O)- al�nea e) do n� 1 do artigo 28.� do C�digo do IVA"
Local cDesc		:= OemToAnsi(STR0002)	//"O Mapa Recapitulativo de Clientes deve ser enviado quando o valor anual das Vendas for: para os anos anteriores a 2004, superior a 50.000 euros ou para o ano 2004 e seguintes, superior a 25.000 euros."
//�����������������������Ŀ
//�Componente de impressao�
//�������������������������
oReport := TReport():New(cReport,cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)
oReport:SetPortrait(.T.)
Pergunte(oReport:uParam,.F.)       

//Secao 1 - Contribuinte
oContr := TRSection():New(oReport,OemToAnsi(STR0003),{"SM0"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oContr:SetLineStyle()
TRCell():New(oContr,"M0_CGC"		,"SM0",OemToAnsi(STR0007),	"@R 99.999.999/9999-99"	,040,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oContr,"cPeriodo"		,"SM0",OemToAnsi(STR0008),/*Picture*/				,040,/*lPixel*/,/*{|| code-block de impressao }*/)

//Secao 2 - Relacao de clientes com sede em territ�rio nacional.
oMov := TRSection():New(oReport,OemToAnsi(STR0009),{"TMP"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Resumo Geral por NIF"
oMov:SetTotalInLine(.F.)
TRCell():New(oMov,"TMP_SEQ"		,"TMP"	,OemToAnsi(STR0004)			,"@!"						,5													,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oMov,"TMP_NIF"		,"TMP"	,OemToAnsi(STR0005) 		,"@!"						,TamSX3("A1_CGC")[01]								,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oMov,"TMP_VLR"		,"TMP"	,OemToAnsi(STR0006)	   		,"@E 999,999,999,999.99"	,15													,/*lPixel*/,/*{|| code-block de impressao }*/)
oMov:Cell("TMP_NIF"):SetHeaderAlign("RIGHT")

//Secao 3 - Totalizador
oTotal	:= TRSection():New(oReport,OemToAnsi(STR0010),{"SM0"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oTotal:SetLineStyle()
TRCell():New(oTotal,"nTotal","SM0",OemToAnsi(STR0010),"@E 999,999,999,999.99"	,015,/*lPixel*/,/*{|| code-block de impressao }*/)
oTotal:Cell("nTotal"):SetHeaderAlign("RIGHT")
Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Gustavo G. Rueda      � Data �22/05/2008���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Funcao que gera o relatorio pre-definido                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�oReport - Objeto TReport                                    ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport)
Local 	oContr		:= oReport:Section(1)
Local 	oMov		:= oReport:Section(2)
Local 	oTotal		:= oReport:Section(3)
Local	cPeriodo	:=	MV_PAR01
Local 	cCondicao	:= "SM0->M0_CODFIL == '" + cFilAnt + "' .And. SM0->M0_CODIGO == '" + cEmpAnt + "'"
Local	aTMP		:=	{}
Local	lGerou		:=	.F.
Local	nOpEst		:=	0
Local	nEstrang	:=	0
Local	nTotal		:=	0

Private oTmpTable
Private aOrder    := {}

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
oContr:SetFilter(cCondicao)
oTotal:SetFilter(cCondicao)
MakeAdvplExpr(oReport:uParam)    		

//Monta e alimenta o arquivo de trabalho
MontCLI(1,oReport,@aTMP,.T.,cPeriodo)

dbSelectArea("TMP")
oReport:SetMeter(TMP->(LastRec()))

oContr:Cell("cPeriodo"):SetBlock({|| cPeriodo }) 
oContr:Init()
oContr:Print()
oContr:Finish()

lGerou	:=	.F.
oReport:ThinLine()
oReport:SkipLine()
oReport:SkipLine()
oReport:PrintText(STR0009)
oReport:ThinLine()
oMov:Init()
TMP->(dbGoTop())
Do While !oReport:Cancel() .And. !TMP->(Eof())

	If oReport:Cancel()                    		
		Exit
	EndIf
       
    oMov:IncMeter()                       		
    
	// Anos anteriores a 2004, superior a 50.000 euros
	If 	(cPeriodo < "2004") .AND. (TMP->TMP_VLR > 50000)
		
		    nTotal	+=	TMP->TMP_VLR
	// Anos superiores a 2004, superior a 25.000 euros	    
	ElseIf (cPeriodo > "2004") .AND. (TMP->TMP_VLR > 25000)
	
       	    nTotal	+=	TMP->TMP_VLR
    EndIf
    
    If nTotal > 0
		oMov:PrintLine()
		lGerou	:=	.T.
    EndIf                                                   	
	TMP->(dbSkip())
Enddo
oMov:Finish()

If !lGerou
	oReport:PrintText(STR0011)//"*** Sem informa��o ***"
EndIf

oTotal:Cell("nTotal"):SetBlock({|| Int(nTotal) }) 
oTotal:Init()
oTotal:Print()
oTotal:Finish()

//Apaga o arquivo de trabalho gerado
MontCLI(2,,aTMP,,cPeriodo)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MontCLI   � Autor � Gustavo G. Rueda      � Data �22/05/2008���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Funcao que monta e alimenta o arquivo de trabalho com base  ���
���          � no SF3.                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�nOpc - 1=Cria e alimenta, 2=Apaga                           ���
���          �oReport - Objeto TReport                                    ���
���          �aTMP - Array que retorna o alias e o nome fisico do arquivo ���
���          � de trabalho.                                               ���
���          �lRelat - Flag que indica se a chamada da funcao e do relato-���
���          � rio ou nao.                                                ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MontCLI(nOpc,oReport,aTMP,lRelat,cAno)
Local	cAls	:=	GetNextAlias()
Local	nTam	:=	0
Local	aStr	:=	{}
Local	nSeq	:=	0
Local	cWhere	:=	""  
Local   dDatini := dTos(ctod("01/01/"+ cAno,"ddmmyy") )
Local   dDatFin := dTos(ctod("31/12/"+ cAno,"ddmmyy") ) 
Local	cChave	:=	""

If nOpc==1
	aAdd(aStr,{"TMP_SEQ",	"C",	005,	0})
	nTam	:=	TamSx3("A1_CGC")[1]
	aAdd(aStr,{"TMP_NIF",	"C",	nTam,	0})
	aAdd(aStr,{"TMP_ENT",	"N",	018,	2})	
	aAdd(aStr,{"TMP_SAI",	"N",	018,	2})	
	aAdd(aStr,{"TMP_VLR",	"N",	018,	2})	
	
	//Creacion de Objeto
	aOrder	:=	{"TMP_NIF"} //JGR
	oTmpTable := FWTemporaryTable():New("TMP") //JGR
	oTmpTable:SetFields( aStr ) //JGR
	oTmpTable:AddIndex("I01", aOrder) //JGR
	oTmpTable:Create() //JGR

	aTMP	:=	{"TMP"}
	cWhere		:=	"%SF3.F3_DTCANC=''%"
	
	BeginSql Alias cAls
	
		//COLUMN D2_EMISSAO AS DATE
	
		SELECT 	A1_CGC, A1_EST, F3_CLIEFOR, F3_LOJA, F3_NFISCAL, F3_SERIE, F3_VALCONT,F3_TIPOMOV, F3_ESPECIE, F3_VALIMP1 
	
		FROM %table:SF3% SF3, %table:SA1% SA1
	
		WHERE 	SF3.%NotDel%          		        AND
				SA1.%NotDel%          		        AND
				SF3.F3_FILIAL  	=  %xFilial:SF3% 	AND
				SF3.F3_ENTRADA 	>= %Exp:dDatini%   AND 
				SF3.F3_ENTRADA 	<= %Exp:dDatFin%   AND
				%Exp:cWhere%						AND
				SA1.A1_FILIAL  	=  %xFilial:SA1% 	AND
				SA1.A1_COD     	= 	SF3.F3_CLIEFOR 	AND
				SA1.A1_LOJA    	=   SF3.F3_LOJA		AND
				SF3.F3_EXENTAS	=	0               AND
				SF3.F3_VALIMP1  >   0 				AND
				SF3.F3_TIPOMOV  =  'V'
						
					
		ORDER BY 1
	
	EndSql
	
		
	TMP->(dbSetOrder(1))
	
	If lRelat
		oReport:SetMeter((cAls)->(LastRec()))
	EndIf
	
	While !(cAls)->(Eof())
	
	 //Posicionar o SF3 somente uma vez qdo houver duas escritura��es ou mais para a mesma nota
	  If cChave<>(cAls)->(F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)
	    	cChave	:=	(cAls)->(F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)
			
		 
		If lRelat
			oReport:IncMeter()
		EndIf
		
		If TMP->(dbSeek(aRetDig((cAls)->A1_CGC,.F.)))
			RecLock("TMP",.F.)
		Else
			nSeq++                                  	
			RecLock("TMP",.T.)
			TMP->TMP_SEQ	:=	StrZero(nSeq,5)
			TMP->TMP_NIF	:=	aRetDig((cAls)->A1_CGC,.F.)
		EndIf

		If !((cAls)->A1_EST$"98/99")	//INTRACOMUNITARIO/EXTRACOMUNITARIO  
				//Acumular Saidas
				If (cAls)->F3_TIPOMOV == "V"
				     //Se for Nota de Cr�dito subtrair
				    If Substr((cAls)->F3_ESPECIE,1,2)=="NC"
						TMP->TMP_SAI	-=	(cAls)->F3_VALCONT
					Else
						TMP->TMP_SAI	+=	(cAls)->F3_VALCONT				
					EndIf		
				//Acumular Entradas
				ElseIf (cAls)->F3_TIPOMOV == "C"
				
				 //Se for Nota de Cr�dito subtrair
				    If Substr((cAls)->F3_ESPECIE,1,2)==		"NC"
						TMP->TMP_ENT	-=	(cAls)->F3_VALCONT
					Else
						TMP->TMP_ENT	+=	(cAls)->F3_VALCONT				
					EndIf		
				
				EndIf
				 //Total Faturado para o Cliente igual a Saidas menos Entradas para o mesmo
				 TMP->TMP_VLR := TMP->TMP_SAI - TMP->TMP_ENT
		EndIf
		
		MsUnLock()
		FkCommit()	
	
		(cAls)->(dbSkip())		
	  Else
		(cAls)->(dbSkip())
	  EndIf
	End
	
	(cAls)->(dbCloseArea())
Else
		dbSelectArea(aTMP[1])
		dbCloseArea()

	If oTmpTable <> Nil   //JGR
		oTmpTable:Delete()  //JGR
		oTmpTable := Nil //JGR
	Endif //JGR

EndIf
Return
