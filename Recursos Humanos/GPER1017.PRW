#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"


#xcommand DEFAULT <uVar1> := <uVal1> ;
      [, <uVarN> := <uValN> ] => 		;
									    <uVar1> := If( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
   	  [ <uVarN> := If( <uVarN> == nil, <uValN>, <uVarN> ); ]

//-- Define's de aCONFIG
#DEFINE NETQPARAM 		  29

#DEFINE NETQIMPLINHA     1
#DEFINE NETQIMPCOLUNA    2
#DEFINE NETQALTURA  	  3
#DEFINE NETQLARGURA	  4
#DEFINE NETQDISTH		  5
#DEFINE NETQDISTV		  6
#DEFINE NETQQTDH		  7
#DEFINE NETQQTDV		  8
#DEFINE NPAGMARGESQ 	  9
#DEFINE NPAGMARGSUP 	  10
#DEFINE NLOGALTURA 	  11
#DEFINE NLOGLARGURA 	  12
#DEFINE NLOGPOS 		  13
#DEFINE NIMGALTURA 	  14
#DEFINE NIMGLARGURA 	  15     
#DEFINE NORDEM        	  16		   
#DEFINE CFILDE           17
#DEFINE CFILATE          18
#DEFINE CVISDE           19
#DEFINE CVISATE          20
#DEFINE CEMPDE           21
#DEFINE CEMPATE          22
#DEFINE DDTVISI          23
#DEFINE DDTVISF          24
#DEFINE CCRACHADE        25        
#DEFINE CCRACHAATE       26
#DEFINE NHORDE           27
#DEFINE NHORATE          28
#DEFINE CTPVIS           29

//Define's de aVarBloq
#DEFINE NMAXCOL          01
#DEFINE NMAXLIN          02
#DEFINE NLIN          	  03
#DEFINE NCOL             04
#DEFINE NPOSCOL          05
#DEFINE NPOSLIN          06

/*
  =========================================================================
  Opcoes de Fontes Disponiveis para Uso na Impressao do Texto das Etiquetas
  =========================================================================
  
oCouNew07  	-->	"Courier New"    //-- Modo Normal 
oCouNew07N 	-->	"Courier New" 	 //-- Modo Negrito(5o parametro New() )  
oCouNew08  	-->	"Courier New"
oCouNew08N 	-->	"Courier New"
oCouNew10 	-->	"Courier New"
oCouNew10N	-->	"Courier New"
oCouNew12 	-->	"Courier New"
oCouNew12N	-->	"Courier New"
oCouNew15 	--> "Courier New"
oCouNew15N	-->	"Courier New"
oCouNew21 	--> "Courier New"
oCouNew21N	-->	"Courier New"
oArial08 	--> "Arial"      
oArial08N 	-->	"Arial"      
oArial12  	--> "Arial"      
oArial12N 	--> "Arial"      
oArial16 	-->	"Arial"      
oArial16N 	-->	"Arial"      

*/

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ETQVIST  � Autor � MAURICIO MR           � Data � 22.01.04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao Grafica Individual de Etiquetas de Visitantes    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ETQVIST() 		                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function GPER1017(nParam)

//-- Configuracao de Cracha
If nParam == 1
   fETQCfg('ETQCFG')      
//-- Impressao Individual de Etiquetas para Cracha   
ElseIf nParam == 2
       fETQIndiv('ETQCFG', 'ETQIND')              
//-- Impressao Coletiva de Etiquetas para Cracha          
ElseIf nParam == 3 
       fETQColetiva('ETQCFG','ETQCOL')
Endif    

Return NIL
   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fETQIndiv � Autor � Mauricio MR           � Data � 20/12/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Etiqueta Individual para Cracha 					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � ETQVIST                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function  fETQIndiv(cPergCfg,cPergImp)
Local aFotos	:= {}         
Local aVisitas	:= Array( 06 )  
Local bProcessa := {|| NIL }   
Local lPreview	:= .T.
Local nColPg	:= 800  
Local nEtiqueta	:= 1
Local nLinPg	:= 3100
Local nQtdeCol 	:= 1
Local nX	    := 0
Local aConfig   := {}

Begin Sequence

	aConfig			:= Array(NETQPARAM)
	
	//-- Obtem Dados da Etiqueta 
	aVisitas[  1   ] 	:= XFILIAL('SPY')				//01 - Filial
	aVisitas[  2   ] 	:= M->PY_CRACHA					//02 - Cracha da Visita
	aVisitas[  3   ] 	:= M->PY_NOMEMP					//03 - Nome da Empresa
	    
	SPW->(DBSEEK(xFilial("SPW")+M->PY_VISITA))
	SPW->( aVisitas[  4	  ]	:= PW_VISITA  )				//04 - Codigo do Visitante
	SPW->( aVisitas[  5	  ]	:= ALLTRIM(PW_NOMFULL) )	//05 - Nome do Visitante
	SPW->( aVisitas[  6	  ]	:= PW_BITMAP	)			//06 - Nome da Foto 	
	
	
	//��������������������������������������������������������������Ŀ
	//� Verifica as perguntas selecionadas                           �
	//����������������������������������������������������������������
	
	//-- Obtem Configuracao do Cracha
	Pergunte(cPergCfg, .F.)
	
	aConfig[NETQALTURA  	]:=  mv_par01 //Altura?
	aConfig[NETQLARGURA		]:=  mv_par02 //Comprimento?
	aConfig[NETQDISTH		]:=  mv_par03 //Distancia Horiz.? 
	aConfig[NETQDISTV		]:=  mv_par04 //Distancia Vertical ?
	aConfig[NETQQTDH		]:=  mv_par05 //Qtde por Linha ? 
	aConfig[NETQQTDV		]:=  mv_par06 //Qtde por Coluna ?  
	aConfig[NPAGMARGESQ 	]:=  mv_par07 //Margem Esquerda?
	aConfig[NPAGMARGSUP 	]:=  mv_par08 //Margem Superior?   
	aConfig[NLOGALTURA 		]:=  mv_par09 //Logo Altura?   
	aConfig[NLOGLARGURA 	]:=  mv_par10 //Logo Comp?   
	aConfig[NLOGPOS 		]:=  mv_par11 //Logo Posicao?   
	aConfig[NIMGALTURA 		]:=  If(ValType(mv_par12)=='C' .AND. Empty(mv_par12) ,250,mv_par12) //Imagem Altura?   
	aConfig[NIMGLARGURA 	]:=  If(ValType(mv_par13)=='C' .AND. Empty(mv_par13) ,250,mv_par13) //Imagem Comp?  

	//-- Obtem Posicao da Etiqueta do Cracha	
	If ! Pergunte(cPergImp, .T.)
	   Break
	Endif   
	aConfig[NETQIMPLINHA  	]:=  MIN(mv_par01,aConfig[NPAGMARGSUP 	]) //Imprimir na Linha?
	aConfig[NETQIMPCOLUNA 	]:=  min(mv_par02,aConfig[NPAGMARGESQ 	]) //Imprimir na Coluna?
    
 
	
	bProcessa := {|| fImpCracha(aVisitas, GetSrvProfString("Startpath",""),Nil,aConfig)}
	//Inicializa a Impressao com Opcao de Pre-visualizacao
	fIniPrtGraf( , nLinPg, nColPg, bProcessa,lPreview,.F.)
	//-- Calcula a Localizacao da Proxima Etiqueta                                                               
	fEtqAdd( cPergCFG, cPergImp, '05', '06', '01', '02')
	
	//-- Apaga BMP Foto do Diretorio
	For nX:=1 to Len(aFotos)
		IF File(aFotos[nX])
			fErase( aFotos[nX])
		Endif	
	next nX

End
	
Return Nil                           

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fImpCracha� Autor � Mauricio MR           � Data � 20/12/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Cracha											  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � ETQINDIV                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
				
Static Function fImpCracha(aVisitas, cPath, cFileLogo, aConfig, aFotos, lSalta)
Local cFileFoto		:= ''
Local nLin			:= aConfig[NPAGMARGSUP 	] 
//Local nLinPg		:= (aConfig[NETQQTDV] * (aConfig[NETQALTURA] + aConfig[NETQDISTV] ) ) + aConfig[NPAGMARGSUP] 
Local nLinTexto		:= 150
Local nPosLinI		:= 0
Local nPosColI		:= 0
Local nPosCImg		:= 0
Local nPosCLogo		:= 0
Local nPosCTexto	:= 0


DEFAULT aFotos		:= {}
DEFAULT cPath	 	:= GetSrvProfString("Startpath","")
DEFAULT lSalta		:= .F.

nPosLinI:= aConfig[NPAGMARGSUP 	] + ( aConfig[NETQALTURA  	]  * (aConfig[NETQIMPLINHA 	] - 1)) + ( aConfig[NETQDISTH]* ( aConfig[NETQIMPLINHA	 ] - 1 ) )
nPosColI:= aConfig[NPAGMARGESQ 	] + ( aConfig[NETQLARGURA  	]  * (aConfig[NETQIMPCOLUNA	] - 1)) + ( aConfig[NETQDISTV]* ( aConfig[NETQIMPCOLUNA  ] - 1 ) )

nPosCLogo	:= nPosColI + IF(aConfig[NLOGPOS]==1,aConfig[NIMGLARGURA]+50,0) 
nPosCTexto	:= nPosCLogo
nPosCImg	:= nPosColI + IF(aConfig[NLOGPOS]==1, 0,(aConfig[NETQLARGURA]-aConfig[NIMGLARGURA])+50) 

If lSalta
   oPrint:EndPage()   
   nPosLinI	:=aConfig[NPAGMARGSUP 	]
Endif

//-- Logo Empresa
//-- Obtem Logo 
If cFileLogo == NIl
   fLogoEmp(@cFileLogo)
Endif

If !Empty(cFilelogo)
	oPrint:SayBitmap(nPosLinI, nPosCLogo, cFileLogo, aConfig[NLOGLARGURA], aConfig[NLOGALTURA]) 		//-- Tem que estar abaixo do RootPath
Endif	

cFileFoto:=fGetFoto(cPath, aVisitas[6], @aFotos )  		//-- Localizacao, Nome da Foto, Armazena a Foto
     
//--  Foto Visitante
If !EMPTY(cFileFoto)
	oPrint:SayBitmap(nPosLinI,nPosCImg,cFileFoto, aConfig[NIMGLARGURA], aConfig[NIMGALTURA]) 
Endif                     


//-- Informacoes Visitante
oPrint:say(nPosLinI+nLinTexto		, nPosCTexto	,aVisitas[04]					,oCouNew12N) //Codigo Visitante
oPrint:say(nPosLinI+nLinTexto + 50 	, nPosCTexto	,Substr(aVisitas[05],1,18)		,oCouNew15N) //Nome Visitante
oPrint:say(nPosLinI+nLinTexto + 100	, nPosCTexto	,Substr(aVisitas[03],1,40)		,oCouNew12)	//Empresa

nLin+= MAX(aConfig[NIMGALTURA], (aConfig[NLOGALTURA]+nLinTexto+150))
   

Return (Nil)        
                                
/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    �fETQCfg        � Autor � Mauricio MR           � Data � 20/12/03 ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � Configura parametros para Impressao de Etiqueta para Cracha     ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                                 ���
������������������������������������������������������������������������������Ĵ��
��� Uso      � ETQVIST                                                         ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Static Function  fETQCfg(cPergCfg)
Local lRet := .T.

lRet:=Pergunte(cPergCfg, .T.)

Return(lRet)
   

	

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    �fETQColetiva   � Autor � Mauricio MR           � Data � 20/12/03 ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Etiquetas para Um Grupo de Visitantes		   	       ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                                 ���
������������������������������������������������������������������������������Ĵ��
��� Uso      � ETQVIST                                                         ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Static Function  fETQColetiva(cPergCfg,cPergImp)

Local aFotos	:= {}         
Local aVisitas	:= Array( 06 )  
Local bProcessa := {|| NIL }   
Local lPreview	:= .T.
Local nColPg	:= 800  
Local nEtiqueta	:= 1
Local nLinPg	:= 3100
Local nQtdeCol 	:= 1
Local nX	    := 0
Local aConfig   := {}
Local aVarBloq	:= {}
Local lEnd		:= .F.

Begin Sequence

	aConfig			:= Array(NETQPARAM)


	//��������������������������������������������������������������Ŀ
	//� Verifica as perguntas selecionadas                           �
	//����������������������������������������������������������������
	
	//-- Obtem Configuracao do Cracha
	Pergunte(cPergCfg, .F.)
	
	aConfig[NETQALTURA  	]:=  mv_par01 //Altura?
	aConfig[NETQLARGURA		]:=  mv_par02 //Comprimento?
	aConfig[NETQDISTH		]:=  mv_par03 //Distancia Horiz.? 
	aConfig[NETQDISTV		]:=  mv_par04 //Distancia Vertical ?
	aConfig[NETQQTDH		]:=  mv_par05 //Qtde por Linha ? 
	aConfig[NETQQTDV		]:=  mv_par06 //Qtde por Coluna ?  
	aConfig[NPAGMARGESQ 	]:=  mv_par07 //Margem Esquerda?
	aConfig[NPAGMARGSUP 	]:=  mv_par08 //Margem Superior?   
	aConfig[NLOGALTURA 		]:=  mv_par09 //Logo Altura?   
	aConfig[NLOGLARGURA 	]:=  mv_par10 //Logo Comp?   
	aConfig[NLOGPOS 		]:=  mv_par11 //Logo Posicao?   
	aConfig[NIMGALTURA 		]:=  If(ValType(mv_par12)=='C' .AND. Empty(mv_par12) ,250,mv_par12) //Imagem Altura?   
	aConfig[NIMGLARGURA 	]:=  If(ValType(mv_par13)=='C' .AND. Empty(mv_par13) ,250,mv_par13) //Imagem Comp?  


	//-- Obtem Posicao da Etiqueta do Cracha	
	If ! Pergunte(cPergImp, .T.)
	   Break
	Endif   
	aConfig[NETQIMPLINHA  	]:=	MIN(mv_par01,aConfig[NPAGMARGSUP 	]) //Imprimir na Linha?
	aConfig[NETQIMPCOLUNA 	]:=	min(mv_par02,aConfig[NPAGMARGESQ 	]) //Imprimir na Coluna?
	aConfig[NORDEM			]:=	mv_par03
	aConfig[CFILDE          ]:=	mv_par04
	aConfig[CFILATE         ]:=	mv_par05
	aConfig[CVISDE          ]:=	mv_par06
	aConfig[CVISATE         ]:=	mv_par07
	aConfig[CEMPDE          ]:=	mv_par08
	aConfig[CEMPATE         ]:=	mv_par09
	aConfig[DDTVISI         ]:=	mv_par10
	aConfig[DDTVISF         ]:=	mv_par11
	aConfig[CCRACHADE       ]:=	mv_par12
	aConfig[CCRACHAATE      ]:=	mv_par13
	aConfig[NHORDE          ]:=	mv_par14
	aConfig[NHORATE         ]:=	mv_par15
	aConfig[CTPVIS          ]:=If(mv_par16=1,'1',If(mv_par16=2,'2','3'))
 
	If DTOS(aConfig[DDTVISI]) > DTOS(aConfig[DDTVISF         ])
		Help(' ',1,'PNR050DATA')
		Break
	Endif
	
	//��������������������������������������������������������������Ŀ
	//� Redefine a Ordem de Impressao conforme Indice                �
	//���������������������������������������������������������������� 
	If 	aConfig[NORDEM			]== 1
	   	aConfig[NORDEM			]:=2
	ElseIf 	aConfig[NORDEM		] == 2
	   	aConfig[NORDEM			]:=3
	ElseIf 	aConfig[NORDEM		] == 3
	   	aConfig[NORDEM			]:=6
	Endif    
    
	//��������������������������������������������������������������Ŀ
	//� Trata SX1										             �
	//���������������������������������������������������������������� 
    //-- Bloqueia e Recupera Dados das Etiquetas
	If Empty((aVarBloq:= fEtqBloq( cPergCFG, cPergImp, '05', '06', '01', '02') ))
	   Break
	Endif
	

	bProcessa := {|| RptStatus( { |lEnd| fImpColet(@lEnd, GetSrvProfString("Startpath",""),aConfig, @aFotos)} , '' )}

	//Inicializa a Impressao com Opcao de Pre-visualizacao
	fIniPrtGraf( , nLinPg, nColPg, bProcessa,lPreview,.F.)
	//-- Salva as Novas Coordenadas da Etiqueta a Ser Impressa
    fEtqSave(aConfig[NETQIMPCOLUNA], aConfig[NETQIMPLINHA  	], aVarBloq[NPOSCOL], aVarBloq[NPOSLIN]) 
    //-- Libera Registros
	PonFreeLocks() 
	
	//-- Apaga BMP Foto do Diretorio
	For nX:=1 to Len(aFotos)
		IF File(aFotos[nX])
			fErase( aFotos[nX])
		Endif	
	next nX

End
	
Return Nil                           

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fImpColet� Autor � Mauricio MR 		    � Data � 22.01.04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Obtem Dados e Imprime Etiquetas para Crachas de Visitantes ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � fImpColet(cLogoEmp, aConfig)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd        - A��o do Codelock                             ���
���          � WnRel       - T�tulo do relat�rio                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fImpColet(lEnd, cLogoEmp, aConfig, aFotos)
Local aAreaSPY	 	:= SPY->( GetArea() )
Local aTempSPY	 	:= SPY->( dbStruct() )                      
Local aVisitas 		:=	{}  

Local cAcessaSPY 	:= &("{ || " + ChkRH("ETQVIST",'SPY',"2") + "}")  
Local cAliasQuery	:= 'SPY'
Local cDbSeek		:= '' 
Local cFilAlias	 	:= xFilial('SPY')
Local cFilSPW	 	:= xFilial('SPW')	
Local cInicio	 	:= ''
Local cFim		 	:= ''
Local cLastFil		:= "__cLastFil__"     
Local lSalta		:= .F.
Local nContField	:= Len(aTempSPY)   
Local nMaxLin		:= aConfig[NETQQTDV]
Local nMaxCol       := aConfig[NETQQTDH]
Local nLin			:= 0
Local nCol          := 0
Local nX			:= 0                  



#IFDEF TOP
	Local cQuery	 := ""
	Local cSP_Query	 := ""
	Local aStruSPY	 := {}
	Local aCposSPY	 := {} 
	Local nLenStruSPY:= 0.00
#ENDIF

dbSelectArea('SPY')

SPY->( dbSetOrder( 	aConfig[NORDEM] ) )
SPY->( dbGoTop() )

//-- Codigo do Visitante + Data
//-- Filial + Cracha + Data Visita
If 	aConfig[NORDEM] == 2
	cDbSeek	 := aConfig[CFILDE] + aConfig[CCRACHADE] + DTOS(aConfig[DDTVISI])
	cInicio  := 'SPY->PY_FILIAL + SPY->PY_CRACHA + DTOS(SPY->PY_DTVISIT)'
	cFim     := aConfig[CFILATE] + aConfig[CCRACHAATE] + DTOS(aConfig[DDTVISF])
//-- Filial + Data Visita + Cracha
ElseIf 	aConfig[NORDEM] == 3
	cDbSeek	 := aConfig[CFILDE] + DTOS(aConfig[DDTVISI]) + aConfig[CCRACHADE] 
	cInicio  := 'SPY->PY_FILIAL + DTOS(SPY->PY_DTVISIT) + SPY->PY_CRACHA'
	cFim     := aConfig[CFILATE] + DTOS(aConfig[DDTVISF]) + aConfig[CCRACHAATE]
//-- Filial + Empresa + Data Visita
ElseIf 	aConfig[NORDEM] == 6
	cDbSeek	 := aConfig[CFILDE] + aConfig[CEMPDE] + DTOS(aConfig[DDTVISI])
	cInicio  := 'SPY->PY_FILIAL + SPY->PY_NOMEMP + DTOS(SPY->PY_DTVISIT)'
	cFim     := aConfig[CFILATE] + aConfig[CEMPATE] + DTOS(aConfig[DDTVISF])
Endif


#IFDEF TOP
	
	/*
	�������������������������������������������������������������Ŀ
	� Seta apenas os Campos do SPY que serao Utilizados           �
	���������������������������������������������������������������*/
	nContField	:= Len(aTempSPY)   

	For nX := 1 To nContField
		aAdd( aStruSPY , aClone( aTempSPY[ nX ] ) )
	Next nX 
	
	aCposSPY	:=  NIL
	nLenStruSPY	:= Len( aStruSPY )
	cQuery := "SELECT "
	For nX := 1 To nLenStruSPY
		cQuery += aStruSPY[ nX , 1 ] + ", "
	Next nX
	cQuery := SubStr( cQuery , 1 , Len( cQuery ) - 2 )
	cQuery += "FROM "+RetSqlName('SPY')+" SPY "
	cQuery += "WHERE "
	cQuery += "SPY.PY_FILIAL>='" +aConfig[CFILDE     		] +"' AND "
	cQuery += "SPY.PY_FILIAL<='" +aConfig[CFILATE    		] +"' AND "
	cQuery += "SPY.PY_VISITA>='" +aConfig[CVISDE     		] +"' AND "
	cQuery += "SPY.PY_VISITA<='" +aConfig[CVISATE    		] +"' AND "  
    cQuery += "SPY.PY_DTVISIT>='"+Dtos(aConfig[DDTVISI    	])+"' AND "
    cQuery += "SPY.PY_DTVISIT<='"+Dtos(aConfig[DDTVISF   	])+"' AND "
	cQuery += "SPY.PY_CRACHA>='" +aConfig[CCRACHADE       	] +"' AND "
	cQuery += "SPY.PY_CRACHA<='" +aConfig[CCRACHAATE      	] +"' AND " 
  	cQuery += "SPY.PY_NOMEMP>='" +aConfig[CEMPDE          	] +"' AND "
	cQuery += "SPY.PY_NOMEMP<='" +aConfig[CEMPATE           ]+"'"
	cQuery += " AND SPY.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "+SqlOrder( SPY->( IndexKey() ) )
	cQuery := ChangeQuery(cQuery)
	( dbSelectArea('SPY') , dbCloseArea() ) //Fecha o SPW para uso da Query
	IF ( lQueryOpened := MsOpenDbf(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQuery,.T.,.T.) )
		For nX := 1 To nLenStruSPY
			IF ( aStruSPY[nX,2] <> "C" )
			   	TcSetField(cAliasQuery,aStruSPY[nX,1],aStruSPY[nX,2],aStruSPY[nX,3],aStruSPY[nX,4])
			EndIF
		Next nX       
		
	Else        

		/*
		�������������������������������������������������������������Ŀ
		� Restaura Arquivo Padrao e Ordem                             �
		���������������������������������������������������������������*/
		ChkFile( 'SPY' )
		SPY->( dbSetOrder( 	aConfig[NORDEM] ) )
	
		/*
		�������������������������������������������������������������Ŀ
		� Procura e posiciona no primeiro Visitante.                  �
		���������������������������������������������������������������*/
		SPY->( MsSeek( cDbSeek , .T. ) )
	EndIF

#ELSE
	/*
	�������������������������������������������������������������Ŀ
	� Procura e posiciona no primeiro funcion�rio.                �
	���������������������������������������������������������������*/
	SPY->( MsSeek( cDbSeek , .T. ) )
#ENDIF	



SetRegua(SPY->(RecCount())) //-- Inicializa R�gua de Contagem

//��������������������������������������������������������������Ŀ
//� Looping no Arquivo de Funcion�rios (SPW)                     �
//����������������������������������������������������������������

While SPY->( !Eof() .and. PY_FILIAL <= 	aConfig[CFILATE] .AND.  &cInicio <= cFim)
	
	//���������������������������������������������������Ŀ
	//� Aborta o Calculo, caso seja pressionado Alt + B   �
	//�����������������������������������������������������
	If lEnd
		IMPR(cCancela,'C')
		Return Nil
	EndIF
	
	/*
	��������������������������������������������������������������Ŀ
	�Incrementa a R�gua de Impress�o							   �
	����������������������������������������������������������������*/
	SPY->(IncRegua())

	 //-- Verifica a quebra de Filial e atualiza o Gauge de Filial
	IF !( cLastFil == SPY->PY_FILIAL ) 
		/*
		��������������������������������������������������������������Ŀ
		� Atualiza o Filial Anterior								   �
		����������������������������������������������������������������*/
		cLastFil := SPY->PY_FILIAL  
		 
		/*	
		��������������������������������������������������������������Ŀ
		� Carrega as Filiais dos Arquivoss                             �
		����������������������������������������������������������������*/
		cFilSPW 	:= xFilial("SPW", cLastFil)   
		/*
		��������������������������������������������������������������Ŀ
		�Obtem Informacoes Empresa	      					     	   �
		����������������������������������������������������������������*/ 
	Endif
    
	//��������������������������������������������������������������Ŀ
	//� Consiste controle de acessos e filiais validas				 |
	//����������������������������������������������������������������
    If !(SPY->PY_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSPY)
	   SPY->(DbSkip())
       Loop
    EndIf

	/*
	��������������������������������������������������������������Ŀ
	� Consiste filtro do intervalo De / Ate.                       �
	����������������������������������������������������������������*/
	#IFNDEF TOP
    
		If  (SPY->PY_Filial	 	< aConfig[CFILDE          ]		) 			.Or. ( SPY->PY_Filial 			> aConfig[CFILATE         ]		) .Or. ;
		    (SPY->PY_NOMEMP  	< aConfig[CEMPDE          ]		) 			.Or. ( SPY->PY_NOMEMP 			> aConfig[CEMPATE         ]		) .Or. ;
			(SPY->PY_Visita 	< aConfig[CVISDE          ]		) 			.Or. ( SPY->PY_Visita 			> aConfig[CVISATE         ]		) .Or. ;
			(SPY->PY_Cracha 	< aConfig[CCRACHADE       ]		) 			.Or. ( SPY->PY_Cracha			> aConfig[CCRACHAATE      ]	) .Or. ;
			(SPY->(DTOS(PY_DtVisit)) 	< DTOS(aConfig[DDTVISI         ]) )	.Or. ( SPY->(DTOS(PY_DtVisit))	> DTOS(aConfig[DDTVISF    ])) 
		    SPY->(DbSkip())
			Loop
		Endif 
		

   	#ENDIF
       	
   	//-- Verifica Tipo de Visita
	If aConfig[CTPVIS] <> '3'
		If	SPY->PY_TIPOVIS <> aConfig[CTPVIS]  	
		    SPY->(DbSkip())
			Loop
		Endif	    
	Endif 
		
	//-- Verifica Horarios (ATENCAO: Nao Fazer Data + Horas)
	If	SPY->( PY_ENTRADA < aConfig[NHORDE] .OR. 	PY_ENTRADA    > aConfig[NHORATE] ) 
	    SPY->(DbSkip())
		Loop
	Endif
    
     //-- Zera Acumuladores 
	aVisitas	:=Array( 06 )  
	
   	//-- Obtem Dados da Etiqueta 

	SPY->( aVisitas[  1   ] 	:= PY_FILIAL	)	//01 - Filial
	SPY->( aVisitas[  2   ] 	:= PY_CRACHA	)	//02 - Cracha da Visita
	SPY->( aVisitas[  3   ] 	:= SUBSTR(ALLTRIM(PY_NOMEMP),1,30))	//03 - Nome da Empresa
    
    SPW->(DBSEEK(cFilSPW+SPY->PY_VISITA)) 
   	SPW->( aVisitas[  4	  ]	:= PW_VISITA  )				//04 - Codigo do Visitante
   	SPW->( aVisitas[  5	  ]	:= ALLTRIM(PW_NOMFULL) )	//05 - Nome do Funcionario
	SPW->( aVisitas[  6	  ]	:= PW_BITMAP	)			//06 - Nome da Foto 	

    //-- Imprime a Etiqueta
	fImpCracha(aVisitas, cLogoEmp , Nil, aConfig, @aFotos, lSalta) 
	nLin	:= aConfig[NETQIMPLINHA]
    nCol    := aConfig[NETQIMPCOLUNA]
    //-- Calcula Nova Posicao da Etiqueta
	fEtqPosicao( nMaxCol, nMaxLin, @nCol, @nLin)

	//-- Atualiza a Posicao da Proxima Etiqueta a Ser Impressa
	aConfig[NETQIMPLINHA]	:= nLin
	aConfig[NETQIMPCOLUNA]	:= nCol       	
	
	lSalta:=( nLin == 1 .AND. nCol == 1 )
	
	//-- Obtem Proximo Visitante
    SPY->(DbSkip())

End While
                            

#IFDEF TOP
	( dbSelectArea( 'SPY' ) , dbCloseArea() , ChkFile( 'SPY' ) ) //Restaura o SPY Padrao
#ENDIF

RestArea( aAreaSPY ) 



Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fLogoEmp  �Autor  �RH - Natie          � Data �  02/18/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fLogoEmp( cLogo,cTipo)
Local  cStartPath	:= GetSrvProfString("Startpath","")
Default cTipo 	:= "1"

//-- Logotipo da Empresa
If cTipo =="1"
	cLogo := cStartPath + "LGRL"+SM0->M0_CODIGO+FWGETCODFILIAL+".BMP" 	// Empresa+Filial
	If !File( cLogo )
		cLogo := cStartPath + "LGRL"+SM0->M0_CODIGO+".BMP" 				// Empresa
	endif
Else		
	cLogo := cStartPath + "LogoSiga.bmp"
Endif

Return

/*
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �fEtqADD       � Autor � RH - Mauricio MR      � Data � 26/01/04 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao Para Alterar Conteudo do SX1 de Etiquetas               ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�                                                                ���
���        01� ExpO1 = Grupo de Perguntas Configuracao da Etiqueta            ���
���        02� ExpO2 = Grupo de Perguntas Impressao da Etiqueta               ���
���        03� ExpO3 = Ordem da Perg de Qtde Max de Linhas por Pagina         ���
���        04� ExpO4 = Ordem da Perg de Qtde Max de Colunas por Pagina        ���
���        05� ExpO5 = Ordem da Perg da Linha da Etq a Ser Impressa           ���
���        06� ExpO6 = Ordem da Perg da Coluna da Etq a Ser Impressa          ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                       ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function fEtqAdd( cPergCFG, cPergImp, cOrdLinMax, cOrdColMax, cOrdLinEtq, cOrdColEtq)

Local aArea			:= GetArea()
Local aAreaSX1		:= SX1->( GetArea() )
Local aVarBloq		:= {}
Local lRet			:= .T.
Local nMaxLin		:= 0
Local nMaxCol       := 0
Local nLin			:= 0
Local nCol          := 0
Local nPosLin   	:= 0
Local nPosCol   	:= 0

Begin Sequence

    //-- Bloqueia e Recupera Dados das Etiquetas
	If Empty((aVarBloq:= fEtqBloq( cPergCFG, cPergImp, cOrdLinMax, cOrdColMax, cOrdLinEtq, cOrdColEtq)))
	   Break
	Endif

	//-- Converte aArray para variaveis
	nMaxCol	:=aVarBloq[1]
	nMaxLin	:=aVarBloq[2]
	nCol	:=aVarBloq[3]
	nLin	:=aVarBloq[4]
	nPosCol :=aVarBloq[5]
	nPosLin :=aVarBloq[6]

	//-- Calcula a Posicao da Proxima Coluna
	fEtqPosicao( nMaxCol, nMaxLin, @nCol, @nLin)
    //-- Salva as Novas Coordenadas da Etiqueta a Ser Impressa
    fEtqSave( nCol, nLin, nPosCol, nPoslin)

End Sequence

PonFreeLocks()

RestArea( aAreaSX1 )
RestArea( aArea )

Return (lRet)

/*
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �fEtqBloq      � Autor � RH - Mauricio MR      � Data � 26/01/04 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao Para Bloquear Conteudo do SX1 de Etiquetas              ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�                                                                ���
���        01� ExpO1 = Grupo de Perguntas Configuracao da Etiqueta            ���
���        02� ExpO2 = Grupo de Perguntas Impressao da Etiqueta               ���
���        03� ExpO3 = Ordem da Perg de Qtde Max de Linhas por Pagina         ���
���        04� ExpO4 = Ordem da Perg de Qtde Max de Colunas por Pagina        ���
���        05� ExpO5 = Ordem da Perg da Linha da Etq a Ser Impressa           ���
���        06� ExpO6 = Ordem da Perg da Coluna da Etq a Ser Impressa          ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                       ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function fEtqBloq( cPergCFG, cPergImp, cOrdLinMax, cOrdColMax, cOrdLinEtq, cOrdColEtq)

Local aArea			:= GetArea()
Local aAreaSX1		:= SX1->( GetArea() )
Local lRet			:= .T.
Local nMaxLin		:= 0
Local nMaxCol       := 0
Local nLin			:= 0
Local nCol          := 0
Local nPosLin   	:= 0
Local nPosCol   	:= 0
Local nLenX1Grp		:= Len(SX1->X1_GRUPO)

cPergCFG := PADR( cPergCFG, nLenX1Grp )
cPergIMP := PADR( cPergIMP, nLenX1Grp )

Begin Sequence
    //-- Procura Pela Qtde Max Etq por Linha (Qtas Colunas de Etiquetas?)
	IF SX1->( dbSeek( cPergCFG + cOrdLinMax, .F. ) )
   	   PonLockRegs( 'SX1' , {SX1->(Recno())} , {SX1->(X1_GRUPO + X1_ORDEM)})
	   nMaxCol		:= VAL(SX1->X1_CNT01)

	   //-- Procura Pela Qtde Max Etq por Coluna (Qtas Linhas de Etiquetas?)
	   IF SX1->( dbSeek( cPergCFG + cOrdColMax, .F. ) )
      	   PonLockRegs( 'SX1' , {SX1->(Recno())} , {SX1->(X1_GRUPO + X1_ORDEM)})
   	       nMaxLin		:= VAL(SX1->X1_CNT01)

  	       //-- Procura Pela Linha da Etq a ser Impressa
	   	   IF SX1->( dbSeek( cPergIMP + cOrdLinEtq, .F. ) )
   	   		  PonLockRegs( 'SX1' , {SX1->(Recno())} , {SX1->(X1_GRUPO + X1_ORDEM)})
	   		  nLin		:= VAL(SX1->X1_CNT01)
   		  	  nPosLin	:= SX1->(Recno())
	   		  //-- Procura Pela Coluna da Etq a ser Impressa
	   		  IF SX1->( dbSeek( cPergIMP + cOrdColEtq, .F. ) )
   		   	     PonLockRegs( 'SX1' , {SX1->(Recno())} , {SX1->(X1_GRUPO + X1_ORDEM)})
	   			 nCol		:= VAL(SX1->X1_CNT01)
  			 	 nPosCol	:= SX1->(Recno())
	   		  Else
	   		     lRet:=.F.
	   		  	 Break
	   		  Endif
		   Else
   		      lRet:=.F.
	   		  Break
	   	   Endif
	   Else
		  lRet:=.F.
	   	  Break
	   Endif
	Else
       lRet:=.F.
	   Break
	Endif
End

RestArea( aAreaSX1 )
RestArea( aArea )

Return (If(lRet, {nMaxCol,nMaxLin,nCol,nLin,nPosCol,nPosLin},{}))

/*
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �fEtqPosicao   � Autor � RH - Mauricio MR      � Data � 26/01/04 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao Para Calcular Posicao da Proxima Etiqueta               ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�                                                                ���
���        01� ExpO1 = No.Max Colunas de Etiquetas				              ���
���        02� ExpO2 = No.Max Linhas                                          ���
���        03� ExpO3 = Coluna a Incrementar							          ���
���        04� ExpO4 = Linha a Incrementar								      ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                       ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function fEtqPosicao( nMaxCol, nMaxLin, nCol, nLin )
 	//-- Folha com Mais que 1 coluna, Incrementa a Coluna
    If nMaxCol > 1
      //-- Verifica se a Coluna Incrementada Ultrapassa a Qtde Max de Colunas da Folha de Etiquetas
      If nCol + 1 > nMaxCol
         //-- Inicializa a Coluna
         nCol:=1
         //-- Verifica se a Linha Incrementada Ultrapassa a Qtde Max de Linhas da Folha de Etiquetas
         If nLin + 1 > nMaxLin
           //-- Inicializa a Linha
	       nLin:=1
	     Else
	         nLin++
	   	 Endif
      Else
         nCol++
      Endif
    Else
       //-- Verifica se a Linha Incrementada Ultrapassa a Qtde Max de Linhas da Folha de Etiquetas
       If nLin + 1 > nMaxLin
          //-- Inicializa a Linha
	      nLin:=1
	   Else
	      nLin ++
	   Endif
    Endif
Return Nil


/*
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �fEtqSave      � Autor � RH - Mauricio MR      � Data � 26/01/04 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao Para Salvar Posicao da Proxima Etiqueta a Ser Impressa  ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�                                                                ���
���        01� ExpO1 = No.Max Colunas de Etiquetas				              ���
���        02� ExpO2 = No.Max Linhas                                          ���
���        03� ExpO3 = Coluna Incrementada							          ���
���        04� ExpO4 = Linha a Incrementar								      ���
���        05� ExpO5 = Posicao do Reg da Coluna no SX1                        ���
���        06� ExpO6 = Posicao do Reg da Linha  no SX1                        ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                       ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function fEtqSave( nCol, nLin, nPosCol, nPoslin)
  SX1->(DbGoto(nPosCol))
  SX1->X1_CNT01:=ALLTRIM(STR(nCol))
  SX1->(DbGoto(nPosLin))
  SX1->X1_CNT01:=ALLTRIM(STR(nLin))

Return Nil
