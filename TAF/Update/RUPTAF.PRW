#Include "Protheus.ch"  


					/* ******************************************** ATENÇÃO ********************************************

					SEMPRE QUE HOUVER MANUTENÇÃO NO RUP_TAF, DEVE SER AVALIADO A NECESSIDADE DE ADAPTAR O PROGRAMA
					UPDTAF.PRW, POIS EXISTE DEPENDENCIA ENTRE OS FONTES. PONTOS QUE DEVEM SER AVALIADOS:
					 -> Ao criar nova função no RUP_TAF, esta deve ser informada no array aFuncSx do UPDTAF
					 -> As funções do RUP_TAF devem ser todas STATIC, pois o UPDTAF faz a chamada através de STATICCALL
					 -> Todo release que houver mudança no RUP_TAF, a função checkEnvUpddistr() no UPDTAF deve ser revisada
					 	pois ela possui as regras que informam ao usuário a necessidade de aplicação do UPDDISTR dos pacotes
					 	segregados do TAF ( pacotes gerados sem marca e expedidos independentemente do release incremental )

			 		************************************************ ATENÇÃO ********************************************  */

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_TAF

Esta rotina tem como objetivo realizar a criação do RUP do TAF, ou seja, manutenir as informações
de dicionário de dados que não são contempladas no UPDDISTR

@Param cVersion   = Versão
		cMode       = Modo de Execução
		cRelStart  = Release Corrente do Cliente
		cRelFinish = Release que está sendo aplicada
		cLocaliz   = Pais do Dicionário

@Author  Rodrigo Aguilar
@Since   09/04/2015
@Version 1.0

@Return ( Nil )
 
/*/
//--------------------------------------------------------------------------------------------------
Function RUP_TAF( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

	Local nVerAtu	as numeric
	Local nVerRUP	as numeric
	Local nX		as numeric
	Local aVersao	as array

	nVerAtu	:=	Val( cRelStart )
	nVerRUP	:=	Iif( cRelFinish == "000", Val( "014" ), Val( cRelFinish ) )
	nX		:=	0
	aVersao	:=	{25,27,33,2210}


	#IFDEF TOP //Tratamento na função RUP_TAF para correção de error.log no PDV do varejo para os clientes que utilizam a base ctree.
		//Apenas se aplica para as versões 11 e 12
		If cVersion == "12"
		
			//Execução por Grupo de Empresas
			If cMode == "1"
		
				//Somente irá executar o laço se a versão do release do RUP for maior do que a versão
				//corrente da base do cliente
				For nX := 1 to Len(aVersao)

					If aVersao[nX] >= nVerAtu .And. aVersao[nX] <= nVerRUP
		
						//Realiza a chamada da função refente as perguntas ( SX1 )
						FAtuTafSX1( aVersao[nX] )
			
						//Realiza a chamada da função refente aos índices ( SIX )
						FAtuTafSIX( aVersao[nX] )
			
						//Realiza a chamada da função refente aos campos ( SX2 )
						FAtuTafSX2( aVersao[nX] )
			
						//Realiza a chamada da função refente aos campos ( SX3 )
						FAtuTafSX3( aVersao[nX] )
			
						//Realiza a chamada da função refente aos gatilhos ( SX7 )
						FAtuTafSX7( aVersao[nX] )
			
						//Realiza a chamada da função refente as pastas e agrupamentos de campos ( SXA )
						FAtuTafSXA( aVersao[nX] )
			
						//Realiza a chamada da função refente aos relacionamentos ( SX9 )
						FAtuTafSX9( aVersao[nX] )

						//Realiza a chamada da função refente ao help de campo
						FAtuTafHlp( aVersao[nX] )
					EndIf

				Next nX
		
				If TCCanOpen( RetSqlName("CH8") )
					CH8Unique(GetNewPar( "MV_VAUTCON", 1000 ))
				EndIf
		
			EndIf
		
		EndIf
	#ENDIF

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuTafSX1

Realiza a atualização do dicionário de dados SX1( Perguntas )

@Param		nRelease - Versão do release

@Return	( Nil )

@Author Daniel Schimidt
@Since 11/06/2015
@Version 1.0
/*/
//---------------------------------------------------------------------

Function FAtuTafSX1( nRelease , aUpdTask )
Return()


//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuTafSX2

Realiza a atualização do dicionário de dados SX2( Tabelas )

@Param		nRelease - Versão do release

@Return	( Nil )

@Author Eduardo Bego Mantoan
@Since 29/03/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Function FAtuTafSX2( nRelease , aUpdTask )
Return()


//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuTafSX3

Realiza a atualização do dicionário de dados SX3( Campos )

@Param		nRelease - Versão do release

@Return	( Nil )

@Author Felipe C. Seolin
@Since 11/06/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Function FAtuTafSX3( nRelease , aUpdTask )

	Local cRelease	as character
	Local aAreaSX3	as array

	Default aUpdTask	:=	{}

	cRelease	:=	StrZero( nRelease, 3 )
	aAreaSX3	:=	SX3->( GetArea() )

	SX3->( DBSetOrder( 2 ) )

	If cRelease >= "025"

		If SX3->( MsSeek(  "CM6_CODCID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_CODCID' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_DCODCID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_DCODCID' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_DIASAF" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_DIASAF' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_IDPROF" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_IDPROF' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_DIDPRO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_DIDPRO' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_STATUS" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_STATUS' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_FMOTAF" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_FMOTAF' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_DFMOTA" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_DFMOTA' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_OBSFIM" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_OBSFIM' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_STAFIM" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_STAFIM' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_DFUNC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"S"
				SX3->X3_INIBRW	:=	'Posicione("C9V",1,xFilial("C9V",CM6->CM6_FILIAL)+CM6->CM6_FUNC,"C9V_NOME")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_DFUNC' , "X3_BROWSE" , "S"  } )
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_DFUNC' , "X3_INIBRW" , 'Posicione("C9V",1,xFilial("C9V",CM6->CM6_FILIAL)+CM6->CM6_FUNC,"C9V_NOME")' } )
		EndIf

		If SX3->( MsSeek( "T1V_NIS" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->X3_CONTEXT := "R"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T1V_NIS' , "X3_CONTEXT", 'R'  } )
		EndIf

		If SX3->( MsSeek( "T1U_NIS" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->X3_CONTEXT := "R"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T1U_NIS' , "X3_CONTEXT", 'R'  } )
		EndIf

		If SX3->( MsSeek( "CMF_NRPROC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_F3 := ""
				SX3->X3_TRIGGER := ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMF_NRPROC", "X3_F3", "REMOVIDO" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMF_NRPROC", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If SX3->( MsSeek( "CMF_NRLEIJ" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_CBOX := ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CMF_NRLEIJ' , "X3_CBOX", ''  } )
		EndIf

		If SX3->( MsSeek( "CUP_DNPRJE" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO := 'Iif(!INCLUI,Posicione("C1G",8,xFilial("C1G")+CUP->CUP_NPROJE+"1","C1G_TPPROC+' + "'"  + ' - ' + "'" + '+C1G_NUMPRO"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt, "SX3", 'CUP_DNPRJE', "X3_RELACAO", 'Iif(!INCLUI,Posicione("C1G",8,xFilial("C1G")+CUP->CUP_NPROJE+"1","C1G_TPPROC+' + "'"  + ' - ' + "'" + '+C1G_NUMPRO"),"")' } )
		EndIf

		If SX3->( MsSeek( "CUP_MOTCON" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO	:=	"Hipot. Legal"
				SX3->X3_DESCRIC	:=	"Hipotese Legal Contrat."
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CUP_MOTCON' , "X3_TITULO"  , "Hipot. Legal"  } )
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CUP_MOTCON' , "X3_DESCRIC" , "Hipotese Legal Contrat."  } )
		EndIf

		If SX3->( MsSeek( "CUP_TPINTT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO	:=	"Tp.Insc.Est."
				SX3->X3_DESCRIC	:=	"Tipo Insc. Estab. Vincul."
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CUP_TPINTT' , "X3_TITULO"  , "Tp.Insc.Est."  } )
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CUP_TPINTT' , "X3_DESCRIC" , "Tipo Insc. Estab. Vincul."  } )
		EndIf

		If SX3->( MsSeek( "CUP_NRINTT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO	:=	"Nr.Insc.Est."
				SX3->X3_DESCRIC	:=	"Núm. Inscr. Estab. Vincul"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CUP_NRINTT' , "X3_TITULO"  , "Nr.Insc.Est."  } )
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CUP_NRINTT' , "X3_DESCRIC" , "Núm. Inscr. Estab. Vincul"  } )
		EndIf

		If SX3->( MsSeek( "T0X_ID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'TafGeraID("TAF")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T0X_ID' , "X3_RELACAO" , 'TafGeraID("TAF")'  } )
		EndIf

		If SX3->( MsSeek( "CMK_DCODRU" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:= 'Iif(!INCLUI.and.!Empty(CMK->CMK_CODRUB),Posicione("C8R",1,xFilial("C8R")+CMK->CMK_CODRUB,"RTRIM(C8R_CODRUB)+' + "'"  + '–'   + "'" + '+C8R_DESRUB"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CMK_DCODRU' , "X3_RELACAO" , 'Iif(!INCLUI.and.!Empty(CMK->CMK_CODRUB),Posicione("C8R",1,xFilial("C8R")+CMK->CMK_CODRUB,"RTRIM(C8R_CODRUB)+' + "'"  + '–'   + "'" + '+C8R_DESRUB"),"")'  } )
		EndIf

		If SX3->( MsSeek(  "T71_CODIGO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL	:=	"A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T71_CODIGO' , "X3_VISUAL" , "A"  } )
		EndIf

		If SX3->( MsSeek(  "T71_DESCRI" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL	:=	"A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T71_DESCRI' , "X3_VISUAL" , "A"  } )
		EndIf

		If SX3->( MsSeek(  "T71_CONV" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL	:=	"A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T71_CONV' , "X3_VISUAL" , "A"  } )
		EndIf

		If SX3->( MsSeek(  "C4X_DESIPM" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO :=	'IF(!INCLUI.AND.!EMPTY(C4X->C4X_CODIPM),POSICIONE("LF0",1,xFilial("LF0")+C4X->C4X_CODIPM,"LF0_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C4X_DESIPM' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C4X->C4X_CODIPM),POSICIONE("LF0",1,xFilial("LF0")+C4X->C4X_CODIPM,"LF0_DESCRI"),"")'  } )
		EndIf

		FAtualID36("018", aUpdTask)

		If SX3->( MsSeek( "T20_QTDMOV" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO	:=	"Qtd.Mov. Ori"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T20_QTDMOV' , "X3_TITULO" , "Qtd.Mov. Ori"  } )
		EndIf
		If SX3->( MsSeek( "C4I_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(C4I->C4I_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C4I->C4I_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C4I_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C4I->C4I_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C4I->C4I_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "C58_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(C58->C58_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C58->C58_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C58_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C58->C58_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C58->C58_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "C5M_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(C5M->C5M_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C5M->C5M_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5M_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C5M->C5M_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C5M->C5M_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "C6M_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(C6M->C6M_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C6M->C6M_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C6M_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C6M->C6M_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C6M->C6M_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "C7J_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(C7J->C7J_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C7J->C7J_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7J_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C7J->C7J_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C7J->C7J_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "C7K_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(C7K->C7K_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C7K->C7K_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7K_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C7K->C7K_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C7K->C7K_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "CA9_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(CA9->CA9_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+CA9->CA9_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CA9_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(CA9->CA9_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+CA9->CA9_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "CAA_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(CAA->CAA_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+CAA->CAA_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CAA_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(CAA->CAA_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+CAA->CAA_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "CAD_DCTA" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(CAD->CAD_CTA),POSICIONE("C1O",3,xFilial("C1O")+CAD->CAD_CTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CAD_DCTA' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(CAD->CAD_CTA),POSICIONE("C1O",3,xFilial("C1O")+CAD->CAD_CTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "CAF_DCTA" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(CAF->CAF_CTA),POSICIONE("C1O",3,xFilial("C1O")+CAF->CAF_CTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CAF_DCTA' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(CAF->CAF_CTA),POSICIONE("C1O",3,xFilial("C1O")+CAF->CAF_CTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "CEQ_DCTA" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(CEQ->CEQ_CTA),POSICIONE("C1O",3,xFilial("C1O")+CEQ->CEQ_CTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CEQ_DCTA' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(CEQ->CEQ_CTA),POSICIONE("C1O",3,xFilial("C1O")+CEQ->CEQ_CTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "CHB_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(CHB->CHB_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+CHB->CHB_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CHB_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(CHB->CHB_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+CHB->CHB_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "C3B_DCODPA" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(C3B->C3B_CODPAR),POSICIONE("C1H",5,xFilial("C1H")+C3B->C3B_CODPAR,' + '"TRIM(C1H_CODPAR)+' + "' - '" + '+C1H_NOME"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3B_CODPAR' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C3B->C3B_CODPAR),POSICIONE("C1H",5,xFilial("C1H")+C3B->C3B_CODPAR,' + '"TRIM(C1H_CODPAR)+' + "' - '" + '+C1H_NOME"),"")' } )
		EndIf

		If SX3->( MsSeek( "T31_NOME" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(T31->T31_CODPAR),POSICIONE("C1H",5,xFilial("C1H")+T31->T31_CODPAR,' + '"TRIM(C1H_CODPAR)+' + "' - '" + '+C1H_NOME"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T31_CODPAR' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(T31->T31_CODPAR),POSICIONE("C1H",5,xFilial("C1H")+T31->T31_CODPAR,' + '"TRIM(C1H_CODPAR)+' + "' - '" + '+C1H_NOME"),"")' } )
		EndIf

		If SX3->( MsSeek( "C3B_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(C3B->C3B_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C3B->C3B_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3B_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C3B->C3B_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C3B->C3B_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		//Reinf R-2030
		If SX3->( MsSeek( "C9B_FILIAL" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_PICTURE := "@!"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_FILIAL", "X3_PICTURE" , "@!" } )
		EndIf

		If SX3->( MsSeek( "C9B_ID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_DESCRIC := "Identificador do Registro"
				SX3->X3_RELACAO := 'TAFGeraID( "TAF" )'
				SX3->X3_BROWSE := "N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_ID", "X3_DESCRIC" , "Identificador do Registro" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_ID", "X3_RELACAO" , 'TAFGeraID( "TAF" )' } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_ID", "X3_BROWSE" , "N" } )
		EndIf

		If SX3->( MsSeek( "C9B_VERSAO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Id Ver Reg"
				SX3->X3_DESCRIC := "Id da Versão do Registro"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_VERSAO", "X3_TITULO" , "Id Ver Reg" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_VERSAO", "X3_DESCRIC" , "Id da Versão do Registro" } )
		EndIf

		If SX3->( MsSeek( "C9B_INDAPU" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE := "N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_INDAPU", "X3_BROWSE" , "N" } )
		EndIf

		If SX3->( MsSeek( "C9B_PERAPU" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Per Apuração"
				SX3->X3_DESCRIC := "Período de Apuração"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_PERAPU", "X3_TITULO" , "Per Apuração" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_PERAPU", "X3_DESCRIC" , "Período de Apuração" } )
		EndIf

		If SX3->( MsSeek( "C9B_VERANT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Id Ver Ant"
				SX3->X3_DESCRIC := "Id Versão Anterior Reg"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_VERANT", "X3_TITULO" , "Id Ver Ant" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_VERANT", "X3_DESCRIC" , "Id Versão Anterior Reg" } )
		EndIf

		If SX3->( MsSeek( "C9B_STATUS" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Status"
				SX3->X3_DESCRIC := "Status do Registro"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_STATUS", "X3_TITULO" , "Status" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_STATUS", "X3_DESCRIC" , "Status do Registro" } )
		EndIf

		If SX3->( MsSeek( "C9B_PROTUL" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Recibo"
				SX3->X3_DESCRIC := "Recibo da Transmissão"
				SX3->X3_BROWSE := "N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_PROTUL", "X3_TITULO" , "Recibo" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_PROTUL", "X3_DESCRIC" , "Recibo da Transmissão" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_PROTUL", "X3_BROWSE" , "N" } )
		EndIf

		If SX3->( MsSeek( "C9B_PROTPN" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Recibo Ant"
				SX3->X3_DESCRIC := "Recibo Trans Anterior"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_PROTPN", "X3_TITULO" , "Recibo Ant" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_PROTPN", "X3_DESCRIC" , "Recibo Trans Anterior" } )
		EndIf

		If SX3->( MsSeek( "C9B_EVENTO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Id Evento"
				SX3->X3_DESCRIC := "Identificação do Evento"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_EVENTO", "X3_TITULO" , "Id Evento" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_EVENTO", "X3_DESCRIC" , "Identificação do Evento" } )
		EndIf

		If SX3->( MsSeek( "C9B_ATIVO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Reg Ativo"
				SX3->X3_DESCRIC := "Registro Ativo"
				SX3->X3_PICTURE := ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_ATIVO", "X3_TITULO" , "Reg Ativo" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_ATIVO", "X3_DESCRIC" , "Registro Ativo" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_ATIVO", "X3_PICTURE" , "" } )
		EndIf

		If SX3->(MsSeek("C9B_NRINSC"))
			If RecLock("SX3", .F.)
				SX3->X3_BROWSE := "S"
				SX3->(MsUnlock())
			EndIf
			aAdd(aUpdTask, {cEmpAnt, "SX3", "C9B_NRINSC", "X3_BROWSE" , "S"})
		EndIf

		If SX3->( MsSeek( "C9G_FILIAL" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_PICTURE := "@!"
				SX3->X3_BROWSE := "S"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_FILIAL", "X3_PICTURE" , "@!" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_FILIAL", "X3_BROWSE" , "S" } )
		EndIf

		If SX3->( MsSeek( "C9G_ID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_DESCRIC := "Identificador do Registro"
				SX3->X3_VISUAL := "V"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_ID", "X3_DESCRIC" , "Identificador do Registro" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_ID", "X3_VISUAL" , "V" } )
		EndIf

		If SX3->( MsSeek( "C9G_VERSAO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Id Ver Reg"
				SX3->X3_DESCRIC := "Id da Versão do Registro"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_VERSAO", "X3_TITULO" , "Id Ver Reg" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_VERSAO", "X3_DESCRIC" , "Id da Versão do Registro" } )
		EndIf

		If SX3->( MsSeek( "C9G_CNPJOR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "CNPJ Repasse"
				SX3->X3_DESCRIC := "CNPJ Emp Repasse Recursos"
				SX3->X3_VISUAL := "V"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_CNPJOR", "X3_TITULO" , "CNPJ Repasse" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_CNPJOR", "X3_DESCRIC" , "CNPJ Emp Repasse Recursos" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_CNPJOR", "X3_VISUAL" , "V" } )
		EndIf

		If SX3->( MsSeek( "C9G_VLREPA" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Vlr Brut Rec"
				SX3->X3_DESCRIC := "Valor Bruto Recebido"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_VLREPA", "X3_TITULO" , "Vlr Brut Rec" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_VLREPA", "X3_DESCRIC" , "Valor Bruto Recebido" } )
		EndIf

		If SX3->( MsSeek( "C9H_FILIAL" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_PICTURE := "@!"
				SX3->X3_BROWSE := "S"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9H_FILIAL", "X3_PICTURE" , "@!" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9H_FILIAL", "X3_BROWSE" , "S" } )
		EndIf

		If SX3->( MsSeek( "C9H_ID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_DESCRIC := "Identificador do Registro"
				SX3->X3_VISUAL := "V"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9H_ID", "X3_DESCRIC" , "Identificador do Registro" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9H_ID", "X3_VISUAL" , "V" } )
		EndIf

		If SX3->( MsSeek( "C9H_VERSAO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Id Ver Reg"
				SX3->X3_DESCRIC := "Id da Versão do Registro"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9H_VERSAO", "X3_TITULO" , "Id Ver Reg" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9H_VERSAO", "X3_DESCRIC" , "Id da Versão do Registro" } )
		EndIf

		//Reinf R-2040
		If SX3->( MsSeek( "C9I_FILIAL" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_PICTURE := "@!"
				SX3->X3_BROWSE := "S"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_FILIAL", "X3_PICTURE" , "@!" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_FILIAL", "X3_BROWSE" , "S" } )
		EndIf

		If SX3->( MsSeek( "C9I_ID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_DESCRIC := "Identificador do Registro"
				SX3->X3_VISUAL := "V"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_ID", "X3_DESCRIC" , "Identificador do Registro" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_ID", "X3_VISUAL" , "V" } )
		EndIf

		If SX3->( MsSeek( "C9I_VERSAO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Id Ver Reg"
				SX3->X3_DESCRIC := "Id da Versão do Registro"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_VERSAO", "X3_TITULO" , "Id Ver Reg" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_VERSAO", "X3_DESCRIC" , "Id da Versão do Registro" } )
		EndIf

		If SX3->( MsSeek( "C9I_CNPJAD" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "CNPJ Ass Des"
				SX3->X3_DESCRIC := "CNPJ Associação Desp"
				SX3->X3_VISUAL := "V"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_CNPJAD", "X3_TITULO" , "CNPJ Ass Des" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_CNPJAD", "X3_DESCRIC" , "CNPJ Associação Desp" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_CNPJAD", "X3_VISUAL" , "V" } )
		EndIf

		If SX3->( MsSeek( "C9I_VLREPA" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Vlr Brut Rep"
				SX3->X3_DESCRIC := "Valor Bruto Repassado"
				SX3->X3_VISUAL := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_VLREPA", "X3_TITULO" , "Vlr Brut Rep" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_VLREPA", "X3_DESCRIC" , "Valor Bruto Repassado" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_VLREPA", "X3_VISUAL" , "A" } )
		EndIf

		//Reinf R-2020
		If SX3->( MsSeek( "CMN_ID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_DESCRIC := "Identificador do Registro"
				SX3->X3_RELACAO := 'TAFGeraID( "TAF" )'
				SX3->X3_BROWSE := "N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_ID", "X3_DESCRIC" , "Identificador do Registro" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_ID", "X3_RELACAO" , 'TAFGeraID( "TAF" )' } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_ID", "X3_BROWSE" , "N" } )
		EndIf

		If SX3->( MsSeek( "CMN_VERSAO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Id Ver Reg"
				SX3->X3_DESCRIC := "Id da Versão do Registro"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_VERSAO", "X3_TITULO"  , "Id Ver Reg" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_VERSAO", "X3_DESCRIC" , "Id da Versão do Registro" } )
		EndIf

		If SX3->( MsSeek( "CMN_PERAPU" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Per Apuração"
				SX3->X3_DESCRIC := "Período da Apuração"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_PERAPU", "X3_TITULO"  , "Per Apuração" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_PERAPU", "X3_DESCRIC" , "Período da Apuração" } )
		EndIf

		If SX3->( MsSeek( "CMN_INDAPU" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE := "N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_INDAPU", "X3_BROWSE"  , "N" } )
		EndIf

		If SX3->( MsSeek( "CMN_PROTUL" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Recibo"
				SX3->X3_DESCRIC := "Recibo da Transmissão"
				SX3->X3_BROWSE := "N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_PROTUL", "X3_TITULO"  , "Recibo" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_PROTUL", "X3_DESCRIC" , "Recibo da Transmissão" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_PROTUL", "X3_BROWSE"  , "N" } )
		EndIf

		If SX3->( MsSeek( "CMN_PROTPN" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Recibo Ant"
				SX3->X3_DESCRIC := "Recibo Trans Anterior"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_PROTPN", "X3_TITULO"  , "Recibo Ant" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_PROTPN", "X3_DESCRIC" , "Recibo Trans Anterior" } )
		EndIf

		If SX3->( MsSeek( "CMN_ATIVO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Reg Ativo"
				SX3->X3_DESCRIC := "Registro Ativo"
				SX3->X3_PICTURE := ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_ATIVO", "X3_TITULO" , "Reg Ativo" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_ATIVO", "X3_DESCRIC" , "Registro Ativo" } )
		EndIf

		If SX3->( MsSeek( "CRO_NUMDOC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Núm NF"
				SX3->X3_DESCRIC := "Número da Nota Fiscal"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CRO_NUMDOC", "X3_TITULO"  , "Num NF" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CRO_NUMDOC", "X3_DESCRIC" , "Número da Nota Fiscal" } )
		EndIf

		If SX3->( MsSeek( "T94_EXCLUI" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Ativo ?"
				SX3->X3_DESCRIC := "TAG com Controle Ativo"
				SX3->X3_CBOX		:=	"1=Sim, Prevalece Tag Enviada no Xml;2=Não, Mantém a Informação Existente no TAF"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "T94_EXCLUI", "X3_TITULO"  , "Ativo ?" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "T94_EXCLUI", "X3_DESCRIC" , "TAG com Controle Ativo" } )
			aAdd( aUpdTask ,{ cEmpAnt ,"SX3", "T94_EXCLUI" ,"X3_CBOX" , "1=Sim, Prevalece Tag Enviada no Xml;2=Não, Mantém a Informação Existente no TAF" } )
		EndIf

		If SX3->( MsSeek(  "T93_PADRAO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO  := "Comp. Padrão"
				SX3->X3_DESCRIC := "Comportamento Padrao Tags"
				SX3->X3_CBOX	  := "1=Exclui Tags Não Enviadas no XML;2=Não Exclui Tags Não Enviadas no XML"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "T93_PADRAO", "X3_TITULO"  , "Comp. Padrão" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "T93_PADRAO", "X3_DESCRIC" , "Comportamento Padrao Tags" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", 'T93_PADRAO', "X3_CBOX" 	 , "1=Exclui Tags Não Enviadas no XML;2=Não Exclui Tags Não Enviadas no XML" } )
		EndIf

		If SX3->( MsSeek(  "T93_ATIVO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO := "2"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T93_ATIVO' , "X3_RELACAO" , '"2"'  } )
		EndIf

		If SX3->( MsSeek(  "C99_DESCRI" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C99_DESCRI' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "C20_DESOBR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IIF(!INCLUI .AND. !EMPTY(C20->C20_IDOBR),POSICIONE("T9C",1,XFILIAL("T9C")+C20->C20_IDOBR,"T9C_DSCOBR"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C20_DESOBR' , "X3_RELACAO" , 'IIF(!INCLUI .AND. !EMPTY(C20->C20_IDOBR),POSICIONE("T9C",1,XFILIAL("T9C")+C20->C20_IDOBR,"T9C_DSCOBR"),"")'  } )
		EndIf

		If SX3->( MsSeek( "CMR_ATIVO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VALID	:= 'Pertence("12")'
				SX3->X3_CBOX	:= "1=Sim;2=Nao"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", 'CMR_ATIVO', "X3_VALID", 'Pertence("12")' } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", 'CMR_ATIVO', "X3_CBOX" , "1=Sim;2=Nao"    } )
		EndIf

		If SX3->( MsSeek( "C1G_TPPROC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VALID	:= 'Pertence(" 1234") .AND. VldChvProc("C1G_TPPROC")'
				SX3->X3_CBOX	:= "1=Judicial;2=Administrativo;3=Número de Benefício (NB) do INSS;4=Processo FAP"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", 'C1G_TPPROC', "X3_VALID", 'Pertence(" 1234") .AND. VldChvProc("C1G_TPPROC")' } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", 'C1G_TPPROC', "X3_CBOX" , "1=Judicial;2=Administrativo;3=Número de Benefício (NB) do INSS;4=Processo FAP" } )
		EndIf

		If SX3->( MsSeek( "CM8_TPAVIS" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VALID	:= 'Pertence(" 12456")'
				SX3->X3_CBOX	:= "1=Redução 2 Hrs/Dia;2=Red. Dias Corridos;4=Não Dispensado;5=Empreg.Rural Red. um Dia por Semana;6=Acordo(Empregado e Empregador)"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", 'CM8_TPAVIS', "X3_VALID", 'Pertence(" 12456")' } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", 'CM8_TPAVIS', "X3_CBOX" , "1=Redução 2 Hrs/Dia;2=Red. Dias Corridos;4=Não Dispensado;5=Empreg.Rural Red. um Dia por Semana;6=Acordo(Empregado e Empregador)" } )
		EndIf

		If SX3->( MsSeek( "V0L_PERAPU" ) ) .And. SX3->X3_BROWSE	<>	"N"
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'V0L_PERAPU' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "C1H_PPES" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->X3_VALID		:= "Pertence('123').And.XFUNNWFunc('A053LogAlt')"
				SX3->X3_CBOX		:=	"1=Pessoa Física;2=Pessoa Jurídica;3=Outros"
				SX3->X3_CBOXSPA	:=	"1=Pessoa Física;2=Pessoa Jurídica;3=Outros"
				SX3->X3_CBOXENG	:=	"1=Pessoa Física;2=Pessoa Jurídica;3=Outros"
				SX3->( MsUnlock() )
			EndIf

			aAdd( aUpdTask, { cEmpAnt, "SX3", 'C1H_PPES', "X3_VALID", "Pertence('123').And.XFUNNWFunc('A053LogAlt')" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", 'C1H_PPES', "X3_CBOX" , "1=Pessoa Física;2=Pessoa Jurídica;3=Outros" } )
		Endif

		If SX3->( MsSeek( "T9F_ID" ) ) .And. SX3->X3_BROWSE	<>	"N"
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T9F_ID' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek( "CUF_IDGRP" ) ) .And. SX3->X3_BROWSE	<>	"N"
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CUF_IDGRP' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->(MsSeek("V0W_TPEVEN")) .And. SX3->X3_BROWSE	<>	"S"
			If RecLock("SX3", .F.)
				SX3->X3_BROWSE	:=	"S"
				SX3->(MsUnlock())
			EndIf
			aAdd(aUpdTask, {cEmpAnt, "SX3", 'V0W_TPEVEN', "X3_BROWSE", "S"})
		EndIf

		If SX3->(MsSeek("V0W_DTPROC")) .And. SX3->X3_BROWSE	<>	"S"
			If RecLock("SX3", .F.)
				SX3->X3_BROWSE	:=	"S"
				SX3->(MsUnlock())
			EndIf
			aAdd(aUpdTask, {cEmpAnt, "SX3", 'V0W_DTPROC', "X3_BROWSE", "S"})
		EndIf

		If SX3->(MsSeek("V0W_HRPROC")) .And. SX3->X3_BROWSE	<>	"S"
			If RecLock("SX3", .F.)
				SX3->X3_BROWSE	:=	"S"
				SX3->(MsUnlock())
			EndIf
			aAdd(aUpdTask, {cEmpAnt, "SX3", 'V0W_HRPROC', "X3_BROWSE", "S"})
		EndIf

		If SX3->(MsSeek("V0C_DTPROC")) .And. SX3->X3_BROWSE	<>	"S"
			If RecLock("SX3", .F.)
				SX3->X3_BROWSE	:=	"S"
				SX3->(MsUnlock())
			EndIf
			aAdd(aUpdTask, {cEmpAnt, "SX3", 'V0C_DTPROC', "X3_BROWSE", "S"})
		EndIf

		If SX3->(MsSeek("V0C_HRPROC")) .And. SX3->X3_BROWSE	<>	"S"
			If RecLock("SX3", .F.)
				SX3->X3_BROWSE	:=	"S"
				SX3->(MsUnlock())
			EndIf
			aAdd(aUpdTask, {cEmpAnt, "SX3", 'V0C_HRPROC', "X3_BROWSE", "S"})
		EndIf

		If SX3->( MsSeek( "T0C_DCODRE" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO := 'IF(!INCLUI.AND.!EMPTY(T0C->T0C_IDCODR),POSICIONE("C6R",3, XFILIAL("C6R")+T0C->T0C_IDCODR,' + '"C6R_CODIGO+' + "' - '" + '+C6R_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T0C_DCODRE' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(T0C->T0C_IDCODR),POSICIONE("C6R",3, XFILIAL("C6R")+T0C->T0C_IDCODR,"C6R_CODIGO +'-'+C6R_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "T0D_DCODRE" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO := 'IF(!INCLUI.AND.!EMPTY(T0D->T0D_CODREC),POSICIONE("C6R",1, XFILIAL("C6R")+T0D->T0D_CODREC,' + '"C6R_CODIGO+' + "' - '" + '+C6R_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T0D_DCODRE' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(T0D->T0D_CODREC),POSICIONE("C6R",3, XFILIAL("C6R")+T0D->T0D_CODREC,"C6R_CODIGO +'-'+C6R_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "T0C_IDCODR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_F3 := 'C6R'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T0C_IDCODR' , 'X3_F3' , 'C6R' } )
		EndIf

		If SX3->( MsSeek( "T0D_IDCODR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_F3 := 'C6R'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T0D_IDCODR' , 'X3_F3' , 'C6R' } )
		EndIf

		//eSocial - Inclusão/Alteração manual de múltiplos vínculos
		If SX3->( MsSeek( "C91_CPF" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->X3_BROWSE	:= "S"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C91_CPF' , "X3_VISUAL", 'A'  } )
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C91_CPF' , "X3_BROWSE", 'S'  } )
		EndIf

		If SX3->( MsSeek( "C9K_CODLOT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9K_CODLOT' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9K_TPINSC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->X3_CBOX	:= "1=CNPJ;2=CPF;3=CAEPF;4=CNO"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9K_TPINSC' , "X3_VISUAL", 'A'  } )
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9K_TPINSC' , "X3_CBOX", '1=CNPJ;2=CPF;3=CAEPF;4=CNO'  } )
		EndIf

		If SX3->( MsSeek( "C9K_NRINSC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9K_NRINSC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9L_DTRABA" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9L_DTRABA' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9M_RUBRIC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9M_RUBRIC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9M_IDTABR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9M_IDTABR' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9P_CODLOT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9P_CODLOT' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9P_TPINSC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9P_TPINSC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9P_NRINSC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9P_NRINSC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9R_RUBRIC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9R_RUBRIC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9R_IDTABR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9R_IDTABR' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C91_INDAPU" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VALID  := 'XC91Valid("C91_INDAPU")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C91_INDAPU' , "X3_VALID", 'XC91Valid("C91_INDAPU")'  } )
		EndIf

		If SX3->( MsSeek( "C91_PERAPU" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VALID  := 'XC91Valid("C91_PERAPU")
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C91_PERAPU' , "X3_VALID", 'XC91Valid("C91_PERAPU")'  } )
		EndIf

		If SX3->( MsSeek( "C91_TRABAL" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VALID  := 'XC91Valid("C91_TRABAL")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C91_TRABAL' , "X3_VALID", 'XC91Valid("C91_TRABAL")'  } )
		EndIf

		If SX3->( MsSeek( "C91_NOME" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C91_NOME' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C91_NASCTO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C91_NASCTO' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "T3P_CPF" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T3P_CPF' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "T3P_NOMER" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T3P_NOMER' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "LE2_RUBRIC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'LE2_RUBRIC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "LE2_IDTABR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'LE2_IDTABR' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "LE4_RUBRIC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'LE4_RUBRIC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "LE4_IDTABR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'LE4_IDTABR' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "T5Y_RUBRIC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T5Y_RUBRIC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "T5Y_IDTABR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T5Y_IDTABR' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "T6Q_RUBRIC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T6Q_RUBRIC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "T6Q_IDTABR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T6Q_IDTABR' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "T6R_RUBRIC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T6R_RUBRIC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "T6R_IDTABR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T6R_IDTABR' , "X3_VISUAL", 'A'  } )
		EndIf
		
		If SX3->( MsSeek( "C1E_DTINI" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VALID := 'XFUNVldDt(, "C1E_DTFIN")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C1E_DTINI' , "X3_VALID" , 'XFUNVldDt(, "C1E_DTFIN")'  } )
		EndIf

		If SX3->( MsSeek( "C1E_DTFIN" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VALID := 'XFUNVldDt("C1E_DTINI")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C1E_DTFIN' , "X3_VALID" , 'XFUNVldDt("C1E_DTINI")'  } )
		EndIf

		If SX3->( MsSeek( "C29_VLRLIQ" ) ) .and. SX3->X3_VISUAL == 'A'
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'V'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C29_VLRLIQ' , "X3_VISUAL", 'V'  } )
		EndIf

		//Protecao dessa atualizacao para o tsi, ja que o pacote ainda nao foi disponibilizado e com isso a execucao do UpdTaf fica pendente mesmo apos ser processada.
		if FindFunction("Ws034Dipa")
			If SX3->( MsSeek( "C30_DCDIPA" ) )				
				If RecLock( "SX3", .F. )
					SX3->X3_RELACAO := 'iif(FindFunction("Ws034Dipa"),Ws034Dipa(),"Sem Descrição Disponível")'
					SX3->X3_ORDEM   := "62"
					SX3->X3_TAMANHO := 254
					SX3->( MsUnlock( ) )
	
					aAdd( aUpdTask , { cEmpAnt, "SX3", 'C30_DCDIPA', "X3_ORDEM"  , "62"  } )
					aAdd( aUpdTask , { cEmpAnt, "SX3", 'C30_DCDIPA', "X3_TAMANHO", "254" } )
					aAdd( aUpdTask , { cEmpAnt, "SX3", 'C30_DCDIPA', "X3_RELACAO", 'iif(FindFunction("Ws034Dipa"),Ws034Dipa(),"Sem Descrição Disponível")' } )
				Endif
			EndIf
		endif

		If SX3->( MsSeek( "C0R_ID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:= 'GetSx8Num("C0R","C0R_ID",,6)' //C0R_FILIAL, C0R_ID, R_E_C_N_O_, D_E_L_E_T_
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C0R_ID' , "X3_RELACAO" , 'GetSx8Num("C0R","C0R_ID",,6)' } )
		EndIf

		If SX3->( MsSeek( "C5M_ID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:= 'GetSx8Num("C5M","C5M_ID",,3)' //C5M_FILIAL, C5M_ID, R_E_C_N_O_, D_E_L_E_T_
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5M_ID' , "X3_RELACAO" , 'GetSx8Num("C5M","C5M_ID",,3)' } )
		EndIf

		If SX3->( MsSeek( "V5S_FILIAL" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TRIGGER := ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "V5S_FILIAL", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If SX3->( MsSeek( "CA4_FILIAL" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TRIGGER := ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CA4_FILIAL", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If SX3->( MsSeek( "CMN_TPNUOB" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_F3 := ""
				SX3->X3_TRIGGER := ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_TPNUOB", "X3_F3", "REMOVIDO" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_TPNUOB", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If SX3->( MsSeek( "T95_TPNUOB" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_F3 := ""
				SX3->X3_TRIGGER := ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "T95_TPNUOB", "X3_F3", "REMOVIDO" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "T95_TPNUOB", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If cRelease <= "027"

			If SX3->( MsSeek( "C30_CODIPA" ) )

				OrderTbC30( )

				If Reclock( "SX3", .F. )

					SX3->X3_ORDEM   := "61"
					SX3->( MsUnlock( ) )

					aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C30_CODIPA' , "X3_ORDEM"   , "61" } )
					
				EndIF

			EndIf

			If SX3->( MsSeek( "T36_DESDIS" ) )
				If RecLock( "SX3", .F. )
					SX3->X3_RELACAO	:= 'IIF(!INCLUI .AND. !EMPTY(T36->T36_IDCODI),POSICIONE("T37",1,XFILIAL("T37")+T36->T36_IDCODI,"T37_DESCRI"),"")'
					SX3->( MsUnlock() )
				EndIf
				aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T36_DESDIS' , "X3_RELACAO" , 'IIF(!INCLUI .AND. !EMPTY(T36->T36_IDCODI),POSICIONE("T37",1,XFILIAL("T37")+T36->T36_IDCODI,"T37_DESCRI"),"")' } )
			EndIf

			If SX3->( MsSeek( "T36_DESLOC" ) )
				If RecLock( "SX3", .F. )
					SX3->X3_RELACAO	:= 'IIF(!INCLUI .AND. !EMPTY(T36->T36_IDCODL),POSICIONE("C07",3,XFILIAL("C07")+T36->T36_IDCODL,"C07_DESCRI"),"")'
					SX3->( MsUnlock() )
				EndIf
				aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T36_DESLOC' , "X3_RELACAO" , 'IIF(!INCLUI .AND. !EMPTY(T36->T36_IDCODL),POSICIONE("C07",3,XFILIAL("C07")+T36->T36_IDCODL,"C07_DESCRI"),"")' } )
			EndIf

		EndIf

	EndIf

	If cRelease >= "025"
		If SX3->( MsSeek( "T95_CODPAR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TRIGGER	:= ""
				SX3->( MsUnlock() )
			EndIf
		EndIf

		If SX3->( MsSeek( "T96_CHVNF" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TRIGGER	:= ""
				SX3->( MsUnlock() )
			EndIf
		EndIf

		If SX3->( MsSeek( "CMN_CODPAR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TRIGGER	:= ""
				SX3->( MsUnlock() )
			EndIf
		EndIf

		If SX3->( MsSeek( "CMN_TPNUOB" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TRIGGER	:= ""
				SX3->( MsUnlock() )
			EndIf
		EndIf

		If SX3->( MsSeek( "CRO_CHVNF" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TRIGGER	:= ""
				SX3->( MsUnlock() )
			EndIf
		EndIf

		If SX3->( MsSeek( "V5S_CODPAR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TRIGGER	:= ""
				SX3->( MsUnlock() )
			EndIf
		EndIf

		If SX3->( MsSeek( "V5V_CHVNF" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TRIGGER	:= ""
				SX3->( MsUnlock() )
			EndIf
		EndIf

	EndIf

	If cRelease >= "027" 
		If SX3->( MsSeek( "CM0_DCODSI" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:= 'IiF(!INCLUI .and. !EMPTY(CM0->CM0_CODSIT),Posicione("C8L",1,xFilial("C8L")+CM0->CM0_CODSIT, "C8L_CODIGO+' + "' - '" + '+C8L_DESCRI" ),"")'
				SX3->( MsUnlock() )
				aAdd( aUpdTask , { cEmpAnt, "SX3", "CM0_CODSIT", "X3_RELACAO", 'IiF(!INCLUI .and. !EMPTY(CM0->CM0_CODSIT),Posicione("C8L",1,xFilial("C8L")+CM0->CM0_CODSIT, "C8L_CODIGO+' + "' - '" + '+C8L_DESCRI" ),"")' } )
			EndIf
		EndIf

		If SX3->( MsSeek( "T3P_NOMEV" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:= 'IIf(!INCLUI, TafGetNome(T3P->T3P_FILIAL,T3P->T3P_BENEFI,T3P->T3P_NOMER,"T3P","T3P"), "")'
				SX3->X3_INIBRW	:= 'TafGetNome(T3P->T3P_FILIAL,T3P->T3P_BENEFI,T3P->T3P_NOMER,"T3P","T3P")'
				SX3->( MsUnlock() )
				aAdd( aUpdTask , { cEmpAnt, "SX3", "T3P_NOMEV", "X3_RELACAO", 'IIf(!INCLUI, TafGetNome(T3P->T3P_FILIAL,T3P->T3P_BENEFI,T3P->T3P_NOMER,"T3P","T3P"), "")' })				
				aAdd( aUpdTask , { cEmpAnt, "SX3", "T3P_NOMEV", "X3_INIBRW", 'TafGetNome(T3P->T3P_FILIAL,T3P->T3P_BENEFI,T3P->T3P_NOMER,"T3P","T3P")'} ) 
			EndIf
		EndIf

		If SX3->( MsSeek( "T3P_NOME" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:= 'IIF(!INCLUI .AND. !EMPTY(T3P->T3P_BENEFI),TAFNMTRAB(XFILIAL("C9V"),M->T3P_BENEFI,"S1210"),"")'
				SX3->( MsUnlock() )
				aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T3P_NOME' , "X3_RELACAO" , 'IIF(!INCLUI .AND. !EMPTY(T3P->T3P_BENEFI),TAFNMTRAB(XFILIAL("C9V"),M->T3P_BENEFI,"S1210"),"")' } )
			EndIf
		EndIf

		If SX3->(MsSeek("V72_DFUNC"))
			If RecLock("SX3", .F.)
				SX3->X3_RELACAO	:= 'IIF(!INCLUI .AND. !EMPTY(V72->V72_FUNC), TAFNMTRAB(XFILIAL("V72"),V72->V72_FUNC,"S2231"),"")'
				SX3->X3_INIBRW	:= 'TAFNMTRAB(XFILIAL("V72"),V72->V72_FUNC,"S2231")'
								
				SX3->(MsUnlock())

				AAdd(aUpdTask, {cEmpAnt, "SX3", "V72_DFUNC", "X3_RELACAO"	, 'IIF(!INCLUI .AND. !EMPTY(V72->V72_FUNC), TAFNMTRAB(XFILIAL("V72"),V72->V72_FUNC,"S2231"),"")'})
				AAdd(aUpdTask, {cEmpAnt, "SX3", "V72_DFUNC", "X3_INIBRW"	, 'TAFNMTRAB(XFILIAL("V72"),V72->V72_FUNC,"S2231")'})
			EndIf
		EndIf

		If SX3->(MsSeek("CUO_PAGDIV"))
			If RecLock("SX3", .F.)
				SX3->X3_TITULO 	:= "Pag. Per Apu"
				SX3->X3_TITSPA 	:= "Pago Per Cal"
				SX3->X3_TITENG	:= "Cal Per. Pay"
				SX3->X3_DESCRIC := "Info. Pagto. Per. Apur."
				SX3->X3_DESCSPA	:= "Info. Pago Per Calculo"
				SX3->X3_DESCENG	:= "Info. Calc. Period Pay"

				SX3->(MsUnlock())

				AAdd(aUpdTask, {cEmpAnt, "SX3", "CUO_PAGDIV", "X3_TITULO"	, "Pag. Per Apu"			})
				AAdd(aUpdTask, {cEmpAnt, "SX3", "CUO_PAGDIV", "X3_TITSPA"	, "Pago Per Cal"			})
				AAdd(aUpdTask, {cEmpAnt, "SX3", "CUO_PAGDIV", "X3_TITENG"	, "Cal Per. Pay"			})
				AAdd(aUpdTask, {cEmpAnt, "SX3", "CUO_PAGDIV", "X3_DESCRIC"	, "Info. Pagto. Per. Apur."	})
				AAdd(aUpdTask, {cEmpAnt, "SX3", "CUO_PAGDIV", "X3_DESCSPA"	, "Info. Pago Per Calculo"	})
				AAdd(aUpdTask, {cEmpAnt, "SX3", "CUO_PAGDIV", "X3_DESCENG"	, "Info. Calc. Period Pay"	})
			EndIf
		EndIf	

		If SX3->( MsSeek( "T2G_CPFTRA" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO	:=	"CPF Trab."
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T2G_CPFTRA' , "X3_TITULO" , "CPF Trab."  } )
		EndIf	

		If SX3->( MsSeek( "T2G_CPFBEN" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO	:=	"CPF Ben."
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T2G_CPFBEN' , "X3_TITULO" , "CPF Ben."  } )
		EndIf

	EndIf

	if nRelease >= 2210

		if SX3->(MsSeek('C20_CHVNF')) 
			//Protejo com a verificação do tamanho do campo, se foi alterado para comportar o retorno de 36 caracteres da função FWUUID(). Tamanho anterior: 15
			if SX3->X3_TAMANHO >= 36 
				if RecLock('SX3', .f.)
					SX3->X3_RELACAO	:= 'FWUUID("C20")'
					SX3->(MsUnlock())
				endif
				AAdd(aUpdTask, {cEmpAnt, 'SX3', 'C20_CHVNF', 'X3_RELACAO', 'FWUUID("C20")'})
			endif	
		endif

	endif


	RestArea(aAreaSX3)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FAtuTafSX7
Realiza a atualização do Dicionário de Dados SX7( Gatilhos )

@Param	  nRelease - Versão do Release

@Author  Rodrigo Aguilar
@Since   09/04/2015
@Version 1.0

@Return ( Nil )

/*/
//--------------------------------------------------------------------------------------------------
Function FAtuTafSX7( nRelease , aUpdTask )

	Local cRelease	as character
	Local aAreaSX7	as array
	Local lFind     as logical

	Default aUpdTask	:=	{}

	cRelease	:=	StrZero( nRelease, 3 )
	aAreaSX7	:=	SX7->( GetArea() )
	lFind		:= 	.F.

	//Seta Ordem de Pesquisa
	SX7->( dbSetOrder( 1 ) )

	If cRelease >= "025"
		If SX7->( MsSeek( "T95_CODPAR" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "T95_CODPAR"
				If RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "T95_CODPAR", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If SX7->( MsSeek( "T96_CHVNF" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "T96_CHVNF"
				If RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "T96_CHVNF", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If SX7->( MsSeek( "CMN_CODPAR" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "CMN_CODPAR"
				If RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "CMN_CODPAR", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If SX7->( MsSeek( "CMN_TPNUOB" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "CMN_TPNUOB"
				If RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "CMN_TPNUOB", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If SX7->( MsSeek( "CRO_CHVNF" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "CRO_CHVNF"
				If RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "CRO_CHVNF", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If SX7->( MsSeek( "V5S_CODPAR" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "V5S_CODPAR"
				If RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "V5S_CODPAR", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If SX7->( MsSeek( "V5V_CHVNF" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "V5V_CHVNF"
				If RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "V5V_CHVNF", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If SX7->( MsSeek( "V5S_FILIAL" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "V5S_FILIAL" .And. Upper(Alltrim(SX7->X7_TIPO)) == "X"
				If RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "V5S_FILIAL", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If SX7->( MsSeek( "CA4_FILIAL" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "CA4_FILIAL" .And. Upper(Alltrim(SX7->X7_TIPO)) == "X"
				If RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "CA4_FILIAL", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf
		If ( SX7->(MsSeek(PadR("CM9_FUNC",10) + "002"))) 
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "CM9_FUNC" .And. Upper(Alltrim(SX7->X7_TIPO)) == "P"
				If RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "CM9_FUNC", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf	
	EndIf

	//Restaura a Area Original
	RestArea( aAreaSX7 )

Return ( nil )

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FAtuTafSXA
Realiza a atualização do Dicionário de Dados SXA( Pastas e Agrupamentos de campos )

@Param	  nRelease - Versão do Release

@Author  Denis R. de Oliveira
@Since   23/11/2017
@Version 1.0

@Return ( Nil )

/*/
//--------------------------------------------------------------------------------------------------
Function FAtuTafSXA( nRelease , aUpdTask )

	Local cRelease	as character
	Local aAreaSXA	as array
	Local lRec		as logical
	Local aAlias	:= {}
	Local nX 		:= 1

	Default aUpdTask	:=	{}

	cRelease	:=	Iif(len(Alltrim(str(nRelease))) < 4, StrZero( nRelease, 3 ), Alltrim(str(nRelease)))
	aAreaSXA	:=	SXA->( GetArea() )
	lRec		:=	.T.

	If cRelease $ "027|033|2210"

		aAlias := {"T62"}

	EndIf

	If !Empty(aAlias)

		SXA->(dbSetOrder(1))

		For nX := 1 to Len(aAlias) 

			If SXA->(dbSeek(aAlias[nX]))

				While SXA->( !Eof() ) .and. SXA->XA_ALIAS == aAlias[nX]
					If RecLock( "SXA", .F. )
						SXA->( DBDelete() )
						SXA->( MsUnlock() )
					EndIf
					SXA->( DBSkip() )
				EndDo

				aAdd( aUpdTask , { cEmpAnt ,"SXA" , aAlias[nX] ,  , "DELETADAS PASTAS DA " + aAlias[nX]  } )

			EndIf

		Next

	EndIf

	RestArea( aAreaSXA )

Return Nil

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FAtuTafSX9
Realiza a atualização do Dicionário de Dados SX9( Relacionamentos )

@Param	  nRelease - Versão do Release

@Author  Daniel Schimidt
@Since   06/08/2015
@Version 1.0

@Return ( Nil )

/*/
//--------------------------------------------------------------------------------------------------
Function FAtuTafSX9( nRelease , aUpdTask )

	Local cRelease	as character

	Default aUpdTask	:=	{}

	cRelease	:=	StrZero( nRelease, 3 )

	If cRelease >= "025"

		DBSelectArea( "SX9" )
		SX9->( DBSetOrder( 1 ) ) //X9_DOM

		If SX9->( MsSeek( "CM6" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "CM6"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'CRE_AFASTA|CRF_AFASTA'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'CM6' , "" , 'DELETADO PARA CRE_AFASTA|CRF_AFASTA'  } )
		EndIf

		If SX9->( MsSeek( "C8B" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "C8B"
				If SX9->X9_CDOM == "CUP" .Or. SX9->X9_CDOM == "CMD"
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'C8B' , "" , 'DELETADO PARA CUP|CMD'  } )
		EndIf

		If SX9->( MsSeek( "C99" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "C99"
				If SX9->X9_CDOM == "CUP"
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'C99' , "" , 'DELETADO PARA CUP'  } )
		EndIf

		If SX9->( MsSeek( "C9V" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "C9V"
				If SX9->X9_CDOM == "CMJ"
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'C9V' , "" , 'DELETADO PARA CMJ'  } )
		EndIF

		If SX9->( MsSeek( "T2G" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T2G"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T2H_FILIAL|T2H_ID|T2H_VERSAO'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T2G' , "" , 'DELETADO PARA T2H_FILIAL|T2H_ID|T2H_VERSAO'  } )
		EndIf

		If SX9->( MsSeek( "T2H" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T2H"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T2I_FILIAL|T2I_ID|T2I_VERSAO|T2I_CODCAT'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T2H' , "" , 'DELETADO PARA T2I_FILIAL|T2I_ID|T2I_VERSAO|T2I_CODCAT'  } )
		EndIf

		If SX9->( MsSeek( "T2H" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T2H"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T2J_FILIAL|T2J_ID|T2J_VERSAO|T2J_CODCAT'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T2H' , "" , 'DELETADO PARA T2J_FILIAL|T2J_ID|T2J_VERSAO|T2J_CODCAT'  } )
		EndIf

		If SX9->( MsSeek( "T1O" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T1O"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T6B_FILIAL|T6B_ID|T6B_VERSAO|T6B_IDESTA|T6B_INDCOM|T6B_TPINSA|T6B_NRINSA '
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T1O' , "" , 'DELETADO PARA T6B_FILIAL|T6B_ID|T6B_VERSAO|T6B_IDESTA|T6B_INDCOM|T6B_TPINSA|T6B_NRINSA '  } )
		EndIf

		If SX9->( MsSeek( "T3P" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T3P"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T3Q_FILIAL|T3Q_ID|T3Q_VERSAO'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T3P' , "" , 'DELETADO PARA T3Q_FILIAL|T3Q_ID|T3Q_VERSAO'  } )
		EndIf

		If SX9->( MsSeek( "T3Q" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T3Q"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T3R_FILIAL|T3R_ID|T3R_VERSAO|T3R_DTPGTO|T3R_TPPGTO'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T3Q' , "" , 'DELETADO PARA T3R_FILIAL|T3R_ID|T3R_VERSAO|T3R_DTPGTO|T3R_TPPGTO'  } )
		EndIf

		If SX9->( MsSeek( "T3R" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T3R"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'LE2_FILIAL|LE2_ID|LE2_VERSAO|LE2_DTPGTO|LE2_TPPGTO|LE2_PERREF|LE2_IDEDMD|LE2_INDPGT'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T3R' , "" , 'DELETADO PARA LE2_FILIAL|LE2_ID|LE2_VERSAO|LE2_DTPGTO|LE2_TPPGTO|LE2_PERREF|LE2_IDEDMD|LE2_INDPGT'  } )
		EndIf

		If SX9->( MsSeek( "LE2" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "LE2"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'LE3_FILIAL|LE3_ID|LE3_VERSAO|LE3_DTPGTO|LE3_TPPGTO|LE3_PERREF|LE3_IDEDMD|LE3_INDPGT|LE3_IDRUBR'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'LE2' , "" , 'DELETADO PARA LE3_FILIAL|LE3_ID|LE3_VERSAO|LE3_DTPGTO|LE3_TPPGTO|LE3_PERREF|LE3_IDEDMD|LE3_INDPGT|LE3_IDRUBR'  } )
		EndIf

		If SX9->( MsSeek( "T3Q" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T3Q"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T6P_FILIAL|T6P_ID|T6P_VERSAO|T6P_DTPGTO|T6P_TPPGTO'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T3Q' , "" , 'DELETADO PARA T6P_FILIAL|T6P_ID|T6P_VERSAO|T6P_DTPGTO|T6P_TPPGTO'  } )
		EndIf

		If SX9->( MsSeek( "T6P" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T6P"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T6Q_FILIAL|T6Q_ID|T6Q_VERSAO|DTOS(T6Q_DTPGTO)|T6Q_TPPGTO|T6Q_PERREF|T6Q_IDEDMD|T6Q_INDPGT'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T6P' , "" , 'DELETADO PARA T6Q_FILIAL|T6Q_ID|T6Q_VERSAO|DTOS(T6Q_DTPGTO)|T6Q_TPPGTO|T6Q_PERREF|T6Q_IDEDMD|T6Q_INDPGT'  } )
		EndIf

		If SX9->( MsSeek( "T6P" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T6P"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T6R_FILIAL|T6R_ID|T6R_VERSAO|DTOS(T6R_DTPGTO)|T6R_TPPGTO|T6R_PERREF|T6R_IDEDMD|T6R_INDPGT'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T6P' , "" , 'DELETADO PARA T6R_FILIAL|T6R_ID|T6R_VERSAO|DTOS(T6R_DTPGTO)|T6R_TPPGTO|T6R_PERREF|T6R_IDEDMD|T6R_INDPGT'  } )
		EndIf

		If SX9->( MsSeek( "T3Q" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T3Q"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T5U_FILIAL|T5U_ID|T5U_VERSAO|T5U_DTPGTO|T5U_TPPGTO'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T3Q' , "" , 'DELETADO PARA T5U_FILIAL|T5U_ID|T5U_VERSAO|T5U_DTPGTO|T5U_TPPGTO'  } )
		EndIf

		If SX9->( MsSeek( "T5U" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T5U"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T5Y_FILIAL|T5Y_ID|T5Y_VERSAO|T5Y_DTPGTO|T5Y_TPPGTO|T5Y_IDCATE|T5Y_DTINIG'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T5U' , "" , 'DELETADO PARA T5Y_FILIAL|T5Y_ID|T5Y_VERSAO|T5Y_DTPGTO|T5Y_TPPGTO|T5Y_IDCATE|T5Y_DTINIG'  } )
		EndIf

		If SX9->( MsSeek( "T5Y" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T5Y"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T5Z_FILIAL|T5Z_ID|T5Z_VERSAO|T5Z_DTPGTO|T5Z_TPPGTO|T5Z_IDCATE|T5Z_DTINIG|T5Z_IDRUBR'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T5Y' , "" , 'DELETADO PARA T5Z_FILIAL|T5Z_ID|T5Z_VERSAO|T5Z_DTPGTO|T5Z_TPPGTO|T5Z_IDCATE|T5Z_DTINIG|T5Z_IDRUBR'  } )
		EndIf

		If SX9->( MsSeek( "T3Q" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T3Q"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T5V_FILIAL|T5V_ID|T5V_VERSAO|T5V_DTPGTO|T5V_TPPGTO'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T3Q' , "" , 'DELETADO PARA T5V_FILIAL|T5V_ID|T5V_VERSAO|T5V_DTPGTO|T5V_TPPGTO'  } )
		EndIf

		If SX9->( MsSeek( "T5V" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T5V"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T5X_FILIAL|T5X_ID|T5X_VERSAO|T5X_DTPGTO|T5X_TPPGTO|T5X_IDCATE|T5X_PERREF'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T5V' , "" , 'DELETADO PARA T5X_FILIAL|T5X_ID|T5X_VERSAO|T5X_DTPGTO|T5X_TPPGTO|T5X_IDCATE|T5X_PERREF'  } )
		EndIf

		If SX9->( MsSeek( "T14" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T14"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T6C_ID|T6C_VERSAO|T6C_INDAPU|T6C_PERAPU|T6C_TRABAL|T6C_DEMPAG|T6D_DEMPAG'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T14' , "" , 'DELETADO PARA T6C_ID|T6C_VERSAO|T6C_INDAPU|T6C_PERAPU|T6C_TRABAL|T6C_DEMPAG'  } )
		EndIf

		If SX9->( MsSeek( "T6C" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T6C"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T6D_ID|T6D_VERSAO|T6D_INDAPU|T6D_PERAPU|T6D_TRABAL|T6D_DEMPAG|T6D_ESTABE'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T6C' , "" , 'DELETADO PARA T6D_ID|T6D_VERSAO|T6D_INDAPU|T6D_PERAPU|T6D_TRABAL|T6D_DEMPAG|T6D_ESTABE'  } )
		EndIf

		If SX9->( MsSeek( "T6D" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T6D"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T6E_ID|T6E_VERSAO|T6E_INDAPU|T6E_PERAPU|T6E_TRABAL|T6E_DEMPAG|T6E_ESTABE|T6E_IDTRAB|T6E_CODCAT'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T6D' , "" , 'DELETADO PARA T6E_ID|T6E_VERSAO|T6E_INDAPU|T6E_PERAPU|T6E_TRABAL|T6E_DEMPAG|T6E_ESTABE|T6E_IDTRAB|T6E_CODCAT'  } )
		EndIf

		If SX9->( MsSeek( "T6F" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T6F"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T6G_ID|T6G_VERSAO|T6G_INDAPU|T6G_PERAPU|T6G_TRABAL|T6G_DEMPAG|T6G_ESTABE|T6G_IDTRAB|T6G_CODCAT|T6G_CNPJOP'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T6F' , "" , 'DELETADO PARA T6G_ID|T6G_VERSAO|T6G_INDAPU|T6G_PERAPU|T6G_TRABAL|T6G_DEMPAG|T6G_ESTABE|T6G_IDTRAB|T6G_CODCAT|T6G_CNPJOP'  } )
		EndIf

		If SX9->( MsSeek( "T14" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T14"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T61_ID|T61_VERSAO|T61_INDAPU|T61_PERAPU|T61_TRABAL|T61_DEMPAG'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T14' , "" , 'DELETADO PARA T61_ID|T61_VERSAO|T61_INDAPU|T61_PERAPU|T61_TRABAL|T61_DEMPAG'  } )
		EndIf

		If SX9->( MsSeek( "T61" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T61"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T6H_ID|T6H_VERSAO|T6H_INDAPU|T6H_PERAPU|T6H_TRABAL|T6H_DEMPAG|DTOS(T6H_DTLEI)|T6H_NUMLEI'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T61' , "" , 'DELETADO PARA T6H_ID|T6H_VERSAO|T6H_INDAPU|T6H_PERAPU|T6H_TRABAL|T6H_DEMPAG|DTOS(T6H_DTLEI)|T6H_NUMLEI'  } )
		EndIf

		If SX9->( MsSeek( "T6H" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T6H"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T6I_ID|T6I_VERSAO|T6I_INDAPU|T6I_PERAPU|T6I_TRABAL|T6I_DEMPAG|DTOS(T6I_DTLEI)|T6I_NUMLEI|T6I_PERREF '
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T6H' , "" , 'DELETADO PARA T6I_ID|T6I_VERSAO|T6I_INDAPU|T6I_PERAPU|T6I_TRABAL|T6I_DEMPAG|DTOS(T6I_DTLEI)|T6I_NUMLEI|T6I_PERREF '  } )
		EndIf

		If SX9->( MsSeek( "T6I" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T6I"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T6J_ID|T6J_VERSAO|T6J_INDAPU|T6J_PERAPU|T6J_TRABAL|T6J_DEMPAG|DTOS(T6J_DTLEI)|T6J_NUMLEI|T6J_PERREF|T6J_ESTABE'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T6I' , "" , 'DELETADO PARA T6J_ID|T6J_VERSAO|T6J_INDAPU|T6J_PERAPU|T6J_TRABAL|T6J_DEMPAG|DTOS(T6J_DTLEI)|T6J_NUMLEI|T6J_PERREF|T6J_ESTABE'  } )
		EndIf

		If SX9->( MsSeek( "T6J" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T6J"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T6K_ID|T6K_VERSAO|T6K_INDAPU|T6K_PERAPU|T6K_TRABAL|T6K_DEMPAG|DTOS(T6K_DTLEI)|T6K_NUMLEI|T6K_PERREF|T6K_ESTABE|T6K_IDTRAB|T6K_CODCAT'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T6J' , "" , 'DELETADO PARA T6K_ID|T6K_VERSAO|T6K_INDAPU|T6K_PERAPU|T6K_TRABAL|T6K_DEMPAG|DTOS(T6K_DTLEI)|T6K_NUMLEI|T6K_PERREF|T6K_ESTABE|T6K_IDTRAB|T6K_CODCAT'  } )
		EndIf

		If SX9->( MsSeek( "C99" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "C99"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T03_FILIAL|T03_ID|T03_VERSAO'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'C99' , "" , 'DELETADO PARA T03_FILIAL|T03_ID|T03_VERSAO'  } )
		EndIf

		If SX9->( MsSeek( "C90" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "C90"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'CRL_FILIAL|CRL_ID|CRL_VERSAO'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'C90' , "" , 'DELETADO PARA CRL_FILIAL|CRL_ID|CRL_VERSAO'  } )
		EndIf

		If SX9->( MsSeek( "T04" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T04"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T09_FILIAL|T09_ID|T09_VERSAO'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T04' , "" , 'DELETADO PARA T09_FILIAL|T09_ID|T09_VERSAO'  } )
		EndIf

		If SX9->( MsSeek( "T14" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "T14"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'C9N_ID|C9N_VERSAO|C9N_RECIBO'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T14' , "" , 'DELETADO PARA C9N_ID|C9N_VERSAO|C9N_RECIBO'  } )
		EndIf

		If SX9->( MsSeek( "C9N" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "C9N"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'C9O_ID|C9O_VERSAO|C9O_RECIBO|C9O_DTACOR|C9O_TPACOR'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'C9N' , "" , 'DELETADO PARA C9O_ID|C9O_VERSAO|C9O_RECIBO|C9O_DTACOR|C9O_TPACOR'  } )
		EndIf

		If SX9->( MsSeek( "C90" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "C90"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'C9P_ID|C9P_VERSAO|C9P_RECIBO|C9P_DTACOR|C9P_TPACOR|C9P_PERREF'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'C90' , "" , 'DELETADO PARA C9P_ID|C9P_VERSAO|C9P_RECIBO|C9P_DTACOR|C9P_TPACOR|C9P_PERREF'  } )
		EndIf

		If SX9->( MsSeek( "C9P" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "C9P"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'C9Q_ID|C9Q_VERSAO|C9Q_DTACOR|C9Q_TPACOR|C9Q_PERREF|C9Q_ESTABE|C9Q_LOTACA'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'C9P' , "" , 'DELETADO PARA C9Q_ID|C9Q_VERSAO|C9Q_DTACOR|C9Q_TPACOR|C9Q_PERREF|C9Q_ESTABE|C9Q_LOTACA'  } )
		EndIf

		If SX9->( MsSeek( "C9Q" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "C9Q"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'C9R_ID|C9R_VERSAO|C9R_DTACOR|C9R_TPACOR|C9R_PERREF|C9R_ESTABE|C9R_LOTACA|C9R_TRABAL|C9R_CODCAT'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'C9Q' , "" , 'DELETADO PARA C9R_ID|C9R_VERSAO|C9R_DTACOR|C9R_TPACOR|C9R_PERREF|C9R_ESTABE|C9R_LOTACA|C9R_TRABAL|C9R_CODCAT'  } )
		EndIf

		If SX9->( MsSeek( "C9K" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "C9K"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'C9L_ID|C9L_VERSAO|C9L_ESTABE|C9L_LOTACA'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'C9K' , "" , 'DELETADO PARA C9L_ID|C9L_VERSAO|C9L_ESTABE|C9L_LOTACA'  } )
		EndIf

		If SX9->( MsSeek( "C14" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "C14"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'C9L_ID|C9L_VERSAO|C9L_RECIBO'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'C14' , "" , 'DELETADO PARA C9L_ID|C9L_VERSAO|C9L_RECIBO'  } )
		EndIf

		If SX9->( MsSeek( "C9L" ) )
			While SX9->( !Eof() ) .and. SX9->X9_DOM == "C9L"
				If AllTrim( SX9->X9_EXPCDOM ) $ 'T6Z_ID|T6_VERSAO|T6Z_RECIBO|T6Z_ESTABE|T6Z_LOTACA|T6Z_TRABAL '
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'C9L' , "" , 'DELETADO PARA T6Z_ID|T6_VERSAO|T6Z_RECIBO|T6Z_ESTABE|T6Z_LOTACA|T6Z_TRABAL '  } )
		EndIf
		
		If SX9->( MsSeek( "C9HC9B" ) )
			If Reclock( "SX9", .F. )
				SX9->( DBDelete() )
				SX9->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt , "SX9", "C9H", "", "DELETADO PARA C9B_ID|C9B_VERSAO" } )
		EndIf

		If SX9->( MsSeek( "C9HC92" ) )
			If Reclock( "SX9", .F. )
				SX9->( DBDelete() )
				SX9->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt , "SX9", "C9H", "", "DELETADO PARA C92_ID" } )
		EndIf

		If SX9->( MsSeek( "C9IC9H" ) )
			If Reclock( "SX9", .F. )
				SX9->( DBDelete() )
				SX9->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt , "SX9", "C9I", "", "DELETADO PARA C9H_ID|C9H_VERSAO|C9H_ESTABE" } )
		EndIf
		
		SX9->( DBSetOrder( 2 ) ) //X9_CDOM+X9_DOM

		If SX9->( MsSeek( "T96LEM" ) )
			If Reclock( "SX9" , .F. )
				SX9->( DBDelete() )
				SX9->( MsUnlock() )
			EndIf		
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T96' , "" , 'DELETADO PARA LEM_NUMERO'  } )
		EndIf	

		If SX9->( MsSeek( "CROLEM" ) )
			If Reclock( "SX9" , .F. )
				SX9->( DBDelete() )
				SX9->( MsUnlock() )
			EndIf		
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'CRO' , "" , 'DELETADO PARA LEM_NUMERO'  } )
		EndIf

		If SX9->( MsSeek( "C20T9C" ) )
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C20T9C" )
				If Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C20_CODOBR"
					Reclock( "SX9", .F.)
					SX9->( DBDelete( ) )
					SX9->(MsUnlock( ) )
					aAdd( aUpdTask, { cEmpAnt , "SX9", "C20", "", "DELETADO PARA C20_CODOBR" } )	
					Exit
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf
		
		If SX9->( MsSeek( "C91" ) )
			While SX9->( !Eof() ) .and. SX9->X9_CDOM == "C91" 
				If AllTrim( SX9->X9_EXPCDOM ) $ 'C91_TRABAL' .and. AllTrim(SX9->X9_EXPDOM) != 'C9V_ID'
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				EndIf
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'C91' , "" , 'DELETADO PARA C91_TRABAL'  } )
		EndIf

		If SX9->( MsSeek( "CROC20" ) )
			While SX9->( !Eof() ) .and. SX9->X9_CDOM == "CRO"
				if SX9->X9_DOM == "C20" .And. "C20_CHVNF" $ SX9->X9_EXPDOM				
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				endif
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'CRO' , "" , 'DELETADO CRO PARA C20_CHVNF'  } )
		EndIf

		If SX9->( MsSeek( "T96C20" ) )
			While SX9->( !Eof() ) .and. SX9->X9_CDOM == "T96"
				if SX9->X9_DOM == "C20" .And. "C20_CHVNF" $ SX9->X9_EXPDOM				
					If Reclock( "SX9" , .F. )
						SX9->( DBDelete() )
						SX9->( MsUnlock() )
					EndIf
				endif
				SX9->( DBSkip() )
			EndDo
			aAdd( aUpdTask , { cEmpAnt ,"SX9" , 'T96' , "" , 'DELETADO T96 PARA C20_CHVNF'  } )
		EndIf
		
		If SX9->(MsSeek("C20C92"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "C20" 
				If "C20_CODOBR" $ SX9->X9_EXPCDOM				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C20' , "" , 'DELETADO C92 PARA C20_CODOBR'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf
		
		If SX9->(MsSeek("T35T34"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T35" 
				If "T35_CODAJU" $ SX9->X9_EXPCDOM				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T34' , "" , 'DELETADO T34 PARA T35_CODAJU'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf
		
		If SX9->(MsSeek("T36T37"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T36" 
				If "T36_CODDIS" $ SX9->X9_EXPCDOM				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T37' , "" , 'DELETADO T37 PARA T36_CODDIS'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		
		EndIf
		
		If SX9->(MsSeek("T6LC0G"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T6L" 
				If "T6L_ANPITE" $ SX9->X9_EXPCDOM				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C0G' , "" , 'DELETADO C0G PARA T6L_ANPITE'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
			
		EndIf
		
		If SX9->(MsSeek("T6LT5A"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T6L" 
				If "T6L_OPEANP" $ SX9->X9_EXPCDOM				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C0G' , "" , 'DELETADO C0G PARA T6L_OPEANP'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9GT9F"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9G" 
				If AllTrim("T9G_DTAPUR") == AllTrim(SX9->X9_EXPCDOM)			
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9G' , "" , 'DELETADO PARA T9F_DTAPUR'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9GT9F"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9G" 
				If Alltrim("T9G_ID") == AllTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9G' , "" , 'DELETADO PARA T9F_DTAPUR'})
					EndIf
				Endif
			SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9HT9F"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9H" 
				If Alltrim("T9H_DTAPUR") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9H' , "" , 'DELETADO PARA T9F_DTAPUR'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9HT9F"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9H" 
				If Alltrim("T9H_ID") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9H' , "" , 'DELETADO PARA T9F_ID'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9HT9F"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9H" 
				If Alltrim("T9H_ID+T9H_DTAPUR") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9H' , "" , 'DELETADO PARA T9F_ID+T9F_DTAPUR'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf


		If SX9->(MsSeek("T9HT9G"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9H" 
				If Alltrim("T9H_CATEVE") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9H' , "" , 'DELETADO PARA T9G_CATEVE'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9HT9G"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9H" 
				If Alltrim("T9H_NUMBOL") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9H' , "" , 'DELETADO PARA  T9G_NUMBOL'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9HT9G"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9H" 
				If Alltrim("T9H_NUMBOL+T9H_TPCOMP+T9H_CATEVE") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9H' , "" , 'DELETADO PARA T9G_NUMBOL+T9G_TPCOMP+T9G_CATEVE'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9HT9G"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9H" 
				If Alltrim("T9H_TPCOMP") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9H' , "" , 'DELETADO PARA  T9G_TPCOMP'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9IT9F"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9I" 
				If Alltrim("T9I_DTAPUR") == ALLTrim(SX9->X9_EXPCDOM)			
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9I' , "" , 'DELETADO PARA T9F_DTAPUR'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9IT9F"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9I" 
				If Alltrim("T9I_ID") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9I' , "" , 'DELETADO PARA T9F_ID'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9IT9F"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9I" 
				If Alltrim("T9I_ID+T9I_DTAPUR") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9I' , "" , 'DELETADO PARA T9F_ID+T9F_DTAPUR'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9IT9G"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9I" 
				If Alltrim("T9I_CATEVE") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9I' , "" , 'DELETADO PARA T9G_CATEVE'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9IT9G"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9I" 
				If Alltrim("T9I_NUMBOL") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9I' , "" , 'DELETADO PARA  T9G_NUMBOL'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9IT9G"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9I" 
				If Alltrim("T9I_NUMBOL+T9I_TPCOMP+T9I_CATEVE") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9I' , "" , 'DELETADO PARA  T9G_NUMBOL+T9G_TPCOMP+T9G_CATEVE'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9IT9G"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9I" 
				If Alltrim("T9I_TPCOMP") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9I' , "" , 'DELETADO PARA  T9G_TPCOMP'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9JC1G"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9J" 
				If Alltrim("T9J_IDPROC") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9J' , "" , 'DELETADO PARA  C1G_ID'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9JT9F"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9J" 
				If Alltrim("T9J_DTAPUR") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9J' , "" , 'DELETADO PARA  T9F_DTAPUR'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9JT9F"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9J" 
				If Alltrim("T9J_ID") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9J' , "" , 'DELETADO PARA  T9F_ID'})
					EndIf
				Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T9XC8S"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9X" 
				If Alltrim("T9X_IDSUSP") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9X' , "" , 'DELETADO PARA  C8S_ID'})
						EndIf
					Endif
				SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T5LC1G"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T5L" 
				If Alltrim("T5L_FILIAL+T5L_ID+T5L_VERSAO") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
					SX9->(DBDelete())
					SX9->(MsUnlock())
					aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T5L' , "" , 'DELETADO PARA C1G_FILIAL|C1G_ID|C1G_VERSAO'})
					EndIf
				Endif
			SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("T5LC8S"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T5L" 
				If Alltrim("T5L_INDDEC") == ALLTrim(SX9->X9_EXPCDOM)				
					If Reclock("SX9", .F.)
					SX9->(DBDelete())
					SX9->(MsUnlock())
					aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T5L' , "" , 'DELETADO PARA C8S_ID'})
					EndIf
				Endif
			SX9->(DBSkip())
			EndDo
		EndIf	

		If SX9->(MsSeek("T9XT9V"))
			While SX9->(!Eof()) .And. SX9->X9_CDOM == "T9X" 
				If Alltrim("T9X_ID+T9X_FILIAL") == ALLTrim(SX9->X9_EXPCDOM)			
					If Reclock("SX9", .F.)
					SX9->(DBDelete())
					SX9->(MsUnlock())
					aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9X' , "" , 'DELETADO PARA T9V_ID+T9V_FILIAL'})
					EndIf
				Endif
			SX9->(DBSkip())
			EndDo
		EndIf

		If SX9->(MsSeek("C20T9C")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C20T9C" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T9C_NRINSC"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C20' , "" , 'DELETADO PARA T9C_NRINSC'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf	
		
		If SX9->(MsSeek("C2UC2T")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C2UC2T" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C2T_ID+C2T_CODAJU"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C2U' , "" , 'DELETADO PARA EXPDOM C2T_ID+C2T_CODAJU'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf	

			If SX9->(MsSeek("C2VC2T")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C2VC2T" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C2T_ID+C2T_CODAJU"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C2V' , "" , 'DELETADO PARA EXPDOM C2T_ID+C2T_CODAJU'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf	

		If SX9->(MsSeek("C3LC3K")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C3LC3K" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C3K_ID+C3K_CODAJU"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C3L' , "" , 'DELETADO PARA EXPDOM C3K_ID+C3K_CODAJU'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf	

		If SX9->(MsSeek("C3MC3K")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C3MC3K" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C3K_ID+C3K_CODAJU"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C3M' , "" , 'DELETADO PARA EXPDOM C3K_ID+C3K_CODAJU'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		If SX9->(MsSeek("CA9C4A")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "CA9C4A" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C4A_ID+C4A_INDAJU+C4A_CAJAPC"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'CA9' , "" , 'DELETADO PARA EXPDOM C4A_ID+C4A_INDAJU+C4A_CAJAPC'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		If SX9->(MsSeek("CAECAD")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "CAECAD" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "CAD_ID+CAD_CTA"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'CAE' , "" , 'DELETADO PARA EXPDOM CAD_ID+CAD_CTA'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		If SX9->(MsSeek("CAGCAF")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "CAGCAF" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "CAF_ID+CAF_CTA"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'CAG' , "" , 'DELETADO PARA EXPDOM CAF_ID+CAF_CTA'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		If SX9->(MsSeek("LEHLEG")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "LEHLEG" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "LEG_FILIAL+LEG_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'LEH' , "" , 'DELETADO PARA EXPDOM LEG_FILIAL+LEG_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		If SX9->(MsSeek("LEQLEG")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "LEQLEG" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "LEG_FILIAL+LEG_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'LEQ' , "" , 'DELETADO PARA EXPDOM LEG_FILIAL+LEG_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		If SX9->(MsSeek("T5MLEM")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T5MLEM" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "LEM_IDPART+LEM_NUMERO"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T5M' , "" , 'DELETADO PARA EXPDOM LEM_IDPART+LEM_NUMERO'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		If SX9->(MsSeek("T69T68")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T69T68" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T68_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T69' , "" , 'DELETADO PARA EXPDOM T68_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		If SX9->(MsSeek("T9HT9G")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T9HT9G" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T9G_NUMBOL+T9G_TPCOMP+T9G_CATEVE"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9H' , "" , 'DELETADO PARA EXPDOM T9G_NUMBOL+T9G_TPCOMP+T9G_CATEVE'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		If SX9->(MsSeek("T9IT9G")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T9IT9G" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T9G_NUMBOL+T9G_TPCOMP+T9G_CATEVE"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9I' , "" , 'DELETADO PARA EXPDOM T9G_NUMBOL+T9G_TPCOMP+T9G_CATEVE'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		If SX9->(MsSeek("T36T37")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T36T37" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T37_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T36' , "" , 'DELETADO PARA EXPDOM T37_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C2DC2C")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C2DC2C" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C2C_CHVNF+C2C_CODOBS"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C2D' , "" , 'DELETADO PARA EXPDOM C2C_CHVNF+C2C_CODOBS'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C2DT0V")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C2DT0V" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T0V_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C2D' , "" , 'DELETADO PARA EXPDOM T0V_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C7DC6G")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C7DC6G" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C6G_FILIAL+C6G_ID+DTOS(C6G_DTMOV)"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C7D' , "" , 'DELETADO PARA EXPDOM C6G_FILIAL+C6G_ID+DTOS(C6G_DTMOV)'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C7CC6G")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C7CC6G" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C6G_FILIAL+C6G_ID+DTOS(C6G_DTMOV)"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C7C' , "" , 'DELETADO PARA EXPDOM C6G_FILIAL+C6G_ID+DTOS(C6G_DTMOV)'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("T6HT61")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T6HT61" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T61_ID+T61_VERSAO+T61_INDAPU+T61_PERAPU+T61_TRABAL+T61_DEMPAG+DTOS(T61_DTLEI)+T61_NUMLEI"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T6H' , "" , 'DELETADO PARA EXPDOM T61_ID+T61_VERSAO+T61_INDAPU+T61_PERAPU+T61_TRABAL+T61_DEMPAG+DTOS(T61_DTLEI)+T61_NUMLEI'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("T6IT6H")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T6IT6H" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T6H_ID+T6H_VERSAO+T6H_INDAPU+T6H_PERAPU+T6H_TRABAL+T6H_DEMPAG+DTOS(T6H_DTLEI)+T6H_NUMLEI+T6H_PERREF"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T6I' , "" , 'DELETADO PARA EXPDOM T6H_ID+T6H_VERSAO+T6H_INDAPU+T6H_PERAPU+T6H_TRABAL+T6H_DEMPAG+DTOS(T6H_DTLEI)+T6H_NUMLEI+T6H_PERREF'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("T6JT6I")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T6JT6I" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T6I_ID+T6I_VERSAO+T6I_INDAPU+T6I_PERAPU+T6I_TRABAL+T6I_DEMPAG+DTOS(T6I_DTLEI)+T6I_NUMLEI+T6I_PERREF+T6I_ESTABE"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T6J' , "" , 'DELETADO PARA EXPDOM T6I_ID+T6I_VERSAO+T6I_INDAPU+T6I_PERAPU+T6I_TRABAL+T6I_DEMPAG+DTOS(T6I_DTLEI)+T6I_NUMLEI+T6I_PERREF+T6I_ESTABE'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("T6KT6J")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T6KT6J" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T6J_ID+T6J_VERSAO+T6J_INDAPU+T6J_PERAPU+T6J_TRABAL+T6J_DEMPAG+DTOS(T6J_DTLEI)+T6J_NUMLEI+T6J_PERREF+T6J_ESTABE+T6J_IDTRAB+T6J_CODCAT"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T6K' , "" , 'DELETADO PARA EXPDOM T6J_ID+T6J_VERSAO+T6J_INDAPU+T6J_PERAPU+T6J_TRABAL+T6J_DEMPAG+DTOS(T6J_DTLEI)+T6J_NUMLEI+T6J_PERREF+T6J_ESTABE+T6J_IDTRAB+T6J_CODCAT'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("T6RT6P")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T6RT6P" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T6P_ID+T6P_VERSAO+DTOS(T6P_DTPGTO)+T6P_TPPGTO+T6P_PERREF+T6P_IDEDMD+T6P_INDPGT"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T6R' , "" , 'DELETADO PARA EXPDOM T6P_ID+T6P_VERSAO+DTOS(T6P_DTPGTO)+T6P_TPPGTO+T6P_PERREF+T6P_IDEDMD+T6P_INDPGT'})
					EndIf
				ElseIf Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T6P_FILIAL+T6P_ID+T6P_VERSAO+DTOS(T6P_DTPGTO)+T6P_TPPGTO+T6P_PERREF+T6P_IDEDMD+T6P_INDPGT"
																																																							
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T6R' , "" , 'DELETADO PARA EXPDOM T6P_FILIAL+T6P_ID+T6P_VERSAO+DTOS(T6P_DTPGTO)+T6P_TPPGTO+T6P_PERREF+T6P_IDEDMD+T6P_INDPGT'})
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf	

		If SX9->(MsSeek("T6QT6P")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T6QT6P" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T6P_ID+T6P_VERSAO+DTOS(T6P_DTPGTO)+T6P_TPPGTO+T6P_PERREF+T6P_IDEDMD+T6P_INDPGT"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T6Q' , "" , 'DELETADO PARA EXPDOM T6P_ID+T6P_VERSAO+DTOS(T6P_DTPGTO)+T6P_TPPGTO+T6P_PERREF+T6P_IDEDMD+T6P_INDPGT'})
					EndIf
				ElseIf Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T6P_FILIAL+T6P_ID+T6P_VERSAO+DTOS(T6P_DTPGTO)+T6P_TPPGTO+T6P_PERREF+T6P_IDEDMD+T6P_INDPGT"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T6Q' , "" , 'DELETADO PARA EXPDOM T6P_FILIAL+T6P_ID+T6P_VERSAO+DTOS(T6P_DTPGTO)+T6P_TPPGTO+T6P_PERREF+T6P_IDEDMD+T6P_INDPGT'})
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf	

		If SX9->(MsSeek("T2GC87")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T2GC87" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C87_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T2G' , "" , 'DELETADO PARA EXPDOM C87_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf	

		If SX9->(MsSeek("V5VT9V")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "V5VT9V" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T9V_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'V5V' , "" , 'DELETADO PARA EXPDOM T9V_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf	

		If SX9->(MsSeek("V5VT9X")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "V5VT9X" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T9X_ID+T9X_VERSAO+T9X_CODSUS"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'V5V' , "" , 'DELETADO PARA EXPDOM T9X_ID+T9X_VERSAO+T9X_CODSUS'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf	
		If SX9->(MsSeek("C74C14")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C74C14" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C14_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C74' , "" , 'DELETADO PARA EXPDOM C14_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf			
		If SX9->(MsSeek("T20T18")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T20T18" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T18_FILIAL+T18_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T20_FILIAL+T20_ID" 
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T20' , "" , 'DELETADO PARA EXPDOM T18_FILIAL+T18_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf			
		If SX9->(MsSeek("T20C1L")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T20C1L" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C1L_FILIAL+C1L_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T20_FILIAL+T20_CODITO" 
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T20' , "" , 'DELETADO PARA EXPDOM C1L_FILIAL+C1L_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf
		If SX9->(MsSeek("T20C1L")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T20C1L" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C1L_FILIAL+C1L_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T20_FILIAL+T20_CODITD" 
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T20' , "" , 'DELETADO PARA EXPDOM C1L_FILIAL+C1L_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf
		If SX9->(MsSeek("T22C1L")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T22C1L" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C1L_FILIAL+C1L_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T22_FILIAL+T22_CODINS" 
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T22' , "" , 'DELETADO PARA EXPDOM C1L_FILIAL+C1L_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf
		If SX9->(MsSeek("T22C1L")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T22C1L" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C1L_FILIAL+C1L_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T22_FILIAL+T22_INSSUB" 
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T22' , "" , 'DELETADO PARA EXPDOM C1L_FILIAL+C1L_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("T22T21")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T22T21" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T21_FILIAL+ T21_ID + T21_CODOP + T21_CODITE" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T22_FILIAL+ T22_ID + T22_CODOP + T22_CODITE" 
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T22' , "" , 'DELETADO PARA EXPDOM T21_FILIAL+ T21_ID + T21_CODOP + T21_CODITE'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("T24C1L")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T24C1L" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C1L_FILIAL+C1L_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T24_FILIAL+T24_INSSUB" 
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T24' , "" , 'DELETADO PARA EXPDOM C1L_FILIAL+C1L_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("T24C1L")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T24C1L" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C1L_FILIAL+C1L_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T24_FILIAL+T24_ITECON" 
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T24' , "" , 'DELETADO PARA EXPDOM C1L_FILIAL+C1L_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("T24T23")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T24T23" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T23_FILIAL+ T23_ID + T23_DTPROD+T23_CODITE" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T24_FILIAL+ T24_ID + T24_DTPROD + T24_CODITE" 
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T24' , "" , 'DELETADO PARA EXPDOM T23_FILIAL+ T23_ID + T23_DTPROD+T23_CODITE'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C7JC7I")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C7JC7I" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C7I_FILIAL + C7I_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C7J_FILIAL + C7J_ID" 
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C7J' , "" , 'DELETADO PARA EXPDOM C7I_FILIAL + C7I_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C74C73")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C74C73" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C73_FILIAL+C73_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C74_FILIAL+C74_ID" 
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C74' , "" , 'DELETADO PARA EXPDOM C73_FILIAL+C73_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C75C73")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C75C73" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C73_FILIAL+C73_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C75_FILIAL+C75_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C75' , "" , 'DELETADO PARA EXPDOM C73_FILIAL+C73_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf
		
		If SX9->(MsSeek("C76C73")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C76C73" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C73_FILIAL+C73_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C76_FILIAL+C76_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C76' , "" , 'DELETADO PARA EXPDOM C73_FILIAL+C73_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C7KC7I")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C7KC7I" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C7I_FILIAL + C7I_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C7K_FILIAL + C7K_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C7K' , "" , 'DELETADO PARA EXPDOM C7I_FILIAL + C7I_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C7LC7I")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C7LC7I" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C7I_FILIAL + C7I_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C7L_FILIAL + C7L_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C7L' , "" , 'DELETADO PARA EXPDOM C7I_FILIAL + C7I_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C7OC7N")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C7OC7N" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C7N_FILIAL + C7N_ID + C7N_CSTICM + C7N_CFOP + C7N_ALQICM" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C7O_FILIAL + C7O_ID + C7O_CSTICM + C7O_CFOP + C7O_ALQICM"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C7O' , "" , 'DELETADO PARA EXPDOM C7N_FILIAL + C7N_ID + C7N_CSTICM + C7N_CFOP + C7N_ALQICM'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C7QC7P")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C7QC7P" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C7P_FILIAL + C7P_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C7Q_FILIAL + C7Q_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C7Q' , "" , 'DELETADO PARA EXPDOM C7P_FILIAL + C7P_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C7RC7P")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C7SC7P" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C7P_FILIAL + C7P_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C7R_FILIAL + C7R_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C7S' , "" , 'DELETADO PARA EXPDOM C7P_FILIAL + C7P_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C7SC7P")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C7SC7P" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C7P_FILIAL + C7P_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C7S_FILIAL + C7S_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C7S' , "" , 'DELETADO PARA EXPDOM C7P_FILIAL + C7P_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("CROCMN")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "CROCMN" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "CMN_FILIAL+CMN_ID+CMN_VERSAO" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "CRO_FILIAL+CRO_ID+CRO_VERSAO"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'CRO' , "" , 'DELETADO PARA EXPDOM CMN_FILIAL+CMN_ID+CMN_VERSAO'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("LEGLEF")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "LEGLEF" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "LEF_FILIAL+LEF_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "LEG_FILIAL+LEG_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'LEG' , "" , 'DELETADO PARA EXPDOM LEF_FILIAL+LEF_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf
		
		If SX9->(MsSeek("T96T95")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T96T95" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T95_FILIAL+T95_ID+T95_VERSAO" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T96_FILIAL+T96_ID+T96_VERSAO"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T96' , "" , 'DELETADO PARA EXPDOM T95_FILIAL+T95_ID+T95_VERSAO'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("T9YCRO")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T9YCRO" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "CRO_FILIAL+CRO_ID+CRO_VERSAO+CRO_SERIE+CRO_NUMDOC+CRO_NUMFAT" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T9Y_FILIAL+T9Y_ID+T9Y_VERSAO+T9Y_SERIE+T9Y_NUMDOC+T9Y_NUMFAT"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T9Y' , "" , 'DELETADO PARA EXPDOM CRO_FILIAL+CRO_ID+CRO_VERSAO+CRO_SERIE+CRO_NUMDOC+CRO_NUMFAT'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C1MC2Q")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C1MC2Q" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C2Q_ID" .AND. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C1M_CPOALT"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C1M' , "" , 'DELETADO PARA EXPCDOM C1M_CPOALT'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("V1LT9X")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "V1LT9X" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T9X_ID+T9X_VERSAO+T9X_CODSUS" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "V1L_IDSUSP"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'V1L' , "" , 'DELETADO PARA EXPDOM T9X_ID+T9X_VERSAO+T9X_CODSUS'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C1LC3V")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C1LC3V" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C3V_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C1L_CODIND"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C1L' , "" , 'DELETADO PARA EXPDOM C3V_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C1LC1U")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C1LC1U" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C1U_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C1L_NATREC"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C1L' , "" , 'DELETADO PARA EXPDOM C1U_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C2TT0V")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C2TT0V" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T0V_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C2T_IDSUBI"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C2T' , "" , 'DELETADO PARA EXPDOM T0V_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C3KT0V")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C3KT0V" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T0V_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C3K_IDSUBI"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C3K' , "" , 'DELETADO PARA EXPDOM T0V_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("C6MC1N")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C6MC1N" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C1N_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C6M_NATOPE"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'C6M' , "" , 'DELETADO PARA EXPDOM C1N_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("V1IT9X")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "V1IT9X" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T9X_ID+T9X_VERSAO+T9X_CODSUS" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "V1I_CODSUS"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'V1I' , "" , 'DELETADO PARA EXPDOM T9X_ID+T9X_VERSAO+T9X_CODSUS'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("T95C1H")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T95C1H" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C1H_CODPAR" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T95_CODPAR"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T95' , "" , 'DELETADO PARA EXPDOM C1H_CODPAR'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("T95C1H")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T95C1H" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C1H_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T95_IDPART"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T95' , "" , 'DELETADO PARA EXPDOM C1H_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("T95T9C")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T95T9C" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T9C_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T95_IDOBRA"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T95' , "" , 'DELETADO PARA EXPDOM T9C_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("T95T9C")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T95T9C" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T9C_TPINSC+T9C_NRINSC" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T95_TPNUOB"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T95' , "" , 'DELETADO PARA EXPDOM T9C_TPINSC+T9C_NRINSC'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("CMNC1H")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "CMNC1H" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C1H_CODPAR" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "CMN_CODPAR"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'CMN' , "" , 'DELETADO PARA EXPDOM C1H_CODPAR'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("CMNC1H")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "CMNC1H" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C1H_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "CMN_IDPART"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'CMN' , "" , 'DELETADO PARA EXPDOM C1H_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("CMNT9C")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "CMNT9C" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T9C_ID" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "CMN_IDOBRA"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'CMN' , "" , 'DELETADO PARA EXPDOM T9C_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("CMNT9C")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "CMNT9C" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T9C_TPINSC+T9C_NRINSC" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "CMN_TPNUOB"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'CMN' , "" , 'DELETADO PARA EXPDOM T9C_TPINSC+T9C_NRINSC'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("CROCMQ")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "CROCMQ" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "CMQ_FILIAL+CMQ_ID+CMQ_VERSAO+CMQ_INSCES+CMQ_INSCCO" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "CRO_FILIAL+CRO_ID+CRO_VERSAO+CRO_INSCES+CRO_INSCCO"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'CRO' , "" , 'DELETADO PARA EXPDOM CMQ_FILIAL+CMQ_ID+CMQ_VERSAO+CMQ_INSCES+CMQ_INSCCO'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("CROCMQ")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "CROCMQ" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "CMQ_ID+CMQ_VERSAO+CMQ_INSCES+CMQ_INSCCO" .and. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "CRO_ID+CRO_VERSAO+CRO_INSCES+CRO_INSCCO"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'CRO' , "" , 'DELETADO PARA EXPDOM CMQ_ID+CMQ_VERSAO+CMQ_INSCES+CMQ_INSCCO'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("V5SC1H")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "V5SC1H" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C1H_CODPAR"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'V5S' , "" , 'DELETADO PARA EXPDOM C1H_CODPAR'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf	

		If SX9->(MsSeek("V5VC20")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "V5VC20" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C20_CHVNF"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'V5V' , "" , 'DELETADO PARA EXPDOM C20_CHVNF'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("V5VLEM")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "V5VLEM" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "LEM_NUMERO"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'V5V' , "" , 'DELETADO PARA EXPDOM LEM_NUMERO'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf

		If SX9->(MsSeek("V0LT9F")) 
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "V0LT9F" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T9F_ID"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'V0L' , "" , 'DELETADO PARA EXPDOM T9F_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) ) 
			EndDo
		EndIf
		
		//C1E CMN
		If SX9->(MsSeek("CMNC1E")) //X9_CDOM, X9_DOM
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "CMNC1E" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C1E_ID+C1E_ATIVO" .And. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "CMN_IDESTA+CMN_ATIVO"
					If Reclock("SX9", .F.) //correto SX9->X9_EXPCDOM CMN_IDESTA+'1' ( solicitado exclusão p/ frame (ID 109638) )
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'CMN' , "" , 'DELETADO PARA EXPCDOM CMN_IDESTA+CMN_ATIVO'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		//C1E T95
		If SX9->(MsSeek("T95C1E")) //X9_CDOM, X9_DOM
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T95C1E" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C1E_ID+C1E_ATIVO" .And. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T95_IDESTA+T95_ATIVO"
					If Reclock("SX9", .F.) //correto SX9->X9_EXPCDOM T95_IDESTA+'1' ( solicitado exclusão p/ frame (ID 109639) )
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T95' , "" , 'DELETADO PARA EXPCDOM T95_IDESTA+T95_ATIVO'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		//LEF LEI 
		If SX9->(MsSeek("LEILEF")) //X9_CDOM, X9_DOM
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "LEILEF" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "LEF_FILIAL+LEF_ID" .And. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "LEI_FILIAL+LEI_ID"
					If Reclock("SX9", .F.) //correto SX9->X9_EXPCDOM apenas com LEI_ID sem filial ( solicitado exclusão p/ frame (ID 49892) )
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'LEI' , "" , 'DELETADO PARA EXPCDOM LEI_FILIAL+LEI_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		//LEG LEH
		If SX9->(MsSeek("LEHLEG")) //X9_CDOM, X9_DOM
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "LEHLEG" ) 
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "LEG_FILIAL+LEG_ID" .And. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "LEH_FILIAL+LEH_ID"
					If Reclock("SX9", .F.) //correto SX9->X9_EXPCDOM apenas com LEH_ID sem filial ( solicitado exclusão p/ frame (ID 49889) )
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'LEH' , "" , 'DELETADO PARA EXPCDOM LEH_FILIAL+LEH_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		//LEG LEQ
		If SX9->(MsSeek("LEQLEG")) //X9_CDOM, X9_DOM
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "LEQLEG" ) 
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "LEG_FILIAL+LEG_ID" .And. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "LEQ_FILIAL+LEQ_ID"
					If Reclock("SX9", .F.) //correto SX9->X9_EXPCDOM apenas com LEQ_ID sem filial ( solicitado exclusão p/ frame (ID 49896) )
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'LEQ' , "" , 'DELETADO PARA EXPCDOM LEQ_FILIAL+LEQ_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		//T68 T69
		If SX9->(MsSeek("T69T68")) //X9_CDOM, X9_DOM
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "T69T68" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "T68_ID" .And. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "T69_ID"
					If Reclock("SX9", .F.) //correto apenas o outro SX9->X9_EXPCDOM ja existente  T69_ID + T69_IDJPAI ( solicitado exclusão p/ frame (ID 57133) )
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'T69' , "" , 'DELETADO PARA EXPCDOM T69_ID'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		//V5S V5T
		If SX9->(MsSeek("V5TV5S")) //X9_CDOM, X9_DOM
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "V5TV5S" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "V5S_FILIAL+V5S_ID+V5S_VERSAO" .And. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "V5T_FILIAL+V5T_ID+V5T_VERSAO"
					If Reclock("SX9", .F.) //correto SX9->X9_EXPCDOM apenas com V5T_ID+V5T_VERSAO sem filial ( solicitado exclusão p/ frame (id 117154) )
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'V5T' , "" , 'DELETADO PARA EXPCDOM V5T_FILIAL+V5T_ID+V5T_VERSAO'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		//V5T V5U
		If SX9->(MsSeek("V5UV5T")) //X9_CDOM, X9_DOM
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "V5UV5T" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "V5T_FILIAL+V5T_ID+V5T_VERSAO+V5T_IDAQUI" .And. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "V5U_FILIAL+V5U_ID+V5U_VERSAO+V5U_IDAQUI"
					If Reclock("SX9", .F.) //correto SX9->X9_EXPCDOM apenas com V5U_ID+V5U_VERSAO+V5U_IDAQUI sem filial ( solicitado exclusão p/ frame (id 117155) )
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'V5U' , "" , 'DELETADO PARA EXPCDOM V5U_FILIAL+V5U_ID+V5U_VERSAO+V5U_IDAQUI'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		//V5T V5V
		If SX9->(MsSeek("V5VV5T")) //X9_CDOM, X9_DOM
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "V5VV5T" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "V5T_FILIAL+V5T_ID+V5T_VERSAO+V5T_IDAQUI" .And. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "V5V_FILIAL+V5V_ID+V5V_VERSAO+V5V_IDAQUI"
					If Reclock("SX9", .F.) //correto SX9->X9_EXPCDOM apenas com V5V_ID+V5V_VERSAO+V5V_IDAQUI sem filial ( solicitado exclusão p/ frame (id 117156) )
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'V5V' , "" , 'DELETADO PARA EXPCDOM V5V_FILIAL+V5V_ID+V5V_VERSAO+V5V_IDAQUI'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

		If SX9->(MsSeek("C1KC1J")) //X9_CDOM, X9_DOM
			While SX9->( !Eof( ) .and. X9_CDOM + X9_DOM == "C1KC1J" )
				If Upper( AllTrim( SX9->X9_EXPDOM ) ) == "C1J_ID" .And. Upper( AllTrim( SX9->X9_EXPCDOM ) ) == "C1K_UNCONV"
					If Reclock("SX9", .F.)
						SX9->(DBDelete())
						SX9->(MsUnlock())
						aAdd(aUpdTask, {cEmpAnt ,"SX9" , 'V5V' , "" , 'DELETADO PARA EXPCDOM C1K_UNCONV'})
						Exit
					EndIf
				EndIf
				SX9->( DbSkip( ) )
			EndDo
		EndIf

	EndIf

Return()

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FAtuTafSIX
Realiza a atualização do Dicionário de Dados SIX( Índices )

@Param	  nRelease - Versão do Release

@Author  Anderson Costa
@Since   11/08/2015
@Version 1.0

@Return ( Nil )

/*/
//--------------------------------------------------------------------------------------------------
Function FAtuTafSIX( nRelease , aUpdTask )
Return Nil 

//---------------------------------------------------------------
/*/{Protheus.doc} FAtuTafHlp

Realiza a atualização do help de campo.

@Param		nRelease - Versão do Release

@Author	Felipe C. Seolin
@Since		17/05/2016
@Version	1.0
/*/
//---------------------------------------------------------------
Function FAtuTafHlp( nRelease , aUpdTask )

	Local cRelease	as character
	Local cKey		as character
	Local aHelpPor	as array
	Local aHelpEng	as array
	Local aHelpSpa	as array
	Local lUpdate	as logical

	Default aUpdTask	:=	{}

	cRelease	:=	StrZero( nRelease, 3 )
	cKey		:=	""
	aHelpPor	:=	{}
	aHelpEng	:=	{}
	aHelpSpa	:=	{}
	lUpdate	:=	.F.

	If Len(aUpdTask) == 0
		aAdd( aUpdTask , { cEmpAnt , "Não existe atualizações para o Ambiente" , "Não existe atualizações para o Ambiente" , "Não existe atualizações para o Ambiente" , "Não existe atualizações para o Ambiente"  } )
	EndIf

Return()

//---------------------------------------------------------------
/*/{Protheus.doc} FAtualID36

Funcão que contém a atualização do dicionário referente a mudança
dos ID dos cadastros para 36 posições.

@Param		nRelease - Versão do Release

@Author	Rafael Völtz
@Since		18/07/2017
@Version	1.0
/*/
//---------------------------------------------------------------
Static Function FAtualID36(cRelease, aUpdTask)

	Default aUpdTask	:=	{}

	/* Cad. Contas Contábeis */
	If SX3->( MsSeek("C1O_ID") )
		If RecLock("SX3", .F.)
			SX3->X3_RELACAO := 'TAFGeraId("TAF")'
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C1O_ID' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C1O_ID' , "X3_RELACAO" , "TAFGeraId('TAF')"  } )
	EndIf

	If SX3->( MsSeek("C1O_CTASUP") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C1O_CTASUP' , "X3_BROWSE" , "N"  } )
	EndIf

	If SX3->( MsSeek("C1O_CTAREF") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C1O_CTAREF' , "X3_BROWSE" , "N"  } )
	EndIf

	/* Documento Fiscal */
	If SX3->( MsSeek("C20_CODCTA") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C20_CODCTA' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C20_CODCTA' , "X3_F3" , ""  } )
	EndIf

	If SX3->( MsSeek("C30_CTACTB") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C30_CTACTB' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C30_CTACTB' , "X3_F3" , ""  } )
	EndIf

	If SX3->( MsSeek("C32_CODPAR") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C32_CODPAR' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C32_CODPAR' , "X3_F3" , ""  } )
	EndIf

	If SX3->( MsSeek("C37_CODPAR") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C37_CODPAR' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C37_CODPAR' , "X3_F3" , ""  } )
	EndIf

	If SX3->( MsSeek("C37_CODPRE") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C37_CODPRE' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C37_CODPRE' , "X3_F3" , ""  } )
	EndIf

	If SX3->( MsSeek("C38_CODPAR") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C38_CODPAR' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C38_CODPAR' , "X3_F3" , ""  } )
	EndIf

	If SX3->( MsSeek("C3A_CPARCO") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3A_CPARCO' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3A_CPARCO' , "X3_F3" , ""  } )
	EndIf

	If SX3->( MsSeek("C3A_CPARDE") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3A_CPARDE' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3A_CPARDE' , "X3_F3" , ""  } )
	EndIf

	If SX3->( MsSeek("C3A_CPAREN") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3A_CPAREN' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3A_CPAREN' , "X3_F3" , ""  } )
	EndIf

	If SX3->( MsSeek("C3A_CPARRE") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3A_CPARRE' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3A_CPARRE' , "X3_F3" , ""  } )
	EndIf

	If SX3->( MsSeek("C3F_CPARCO") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3F_CPARCO' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3F_CPARCO' , "X3_F3" , ""  } )
	EndIf

	If SX3->( MsSeek("C3F_CPARRE") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3F_CPARRE' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3F_CPARRE' , "X3_F3" , ""  } )
	EndIf

	If SX3->( MsSeek("C3G_CPARCO") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3G_CPARCO' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3G_CPARCO' , "X3_F3" , ""  } )
	EndIf

	If SX3->( MsSeek("T60_CODPAR") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T60_CODPAR' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T60_CODPAR' , "X3_F3" , ""  } )
	EndIf

	/* Bens/Comp. Atv Imobilizado */
	If SX3->( MsSeek("C2L_CODCTA") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C2L_CODCTA' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C2L_CODCTA' , "X3_F3" , ""  } )
	EndIf

	/*  Demais Docs Não Vinculados */
	If SX3->( MsSeek("C3B_CODCTA") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3B_CODCTA' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3B_CODCTA' , "X3_F3" , ""  } )
	EndIf

	/* Itens do Inventario */
	If SX3->( MsSeek("C5B_CODCTA") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5B_CODCTA' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5B_CODCTA' , "X3_F3" , ""  } )
	EndIf

	/* Itens Cupom Fiscal SAT CFe */
	If SX3->( MsSeek("C5S_CODCTA") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5S_CODCTA' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5S_CODCTA' , "X3_F3" , ""  } )
	EndIf

	/*  Itens Doc.Fiscal Emitido ECF */
	If SX3->( MsSeek("C6J_CCONT") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C6J_CCONT' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C6J_CCONT' , "X3_F3" , ""  } )
	EndIf

	/* Resumo por CFOP ICMS */
	If SX3->( MsSeek("C6Z_CODCTA") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C6Z_CODCTA' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C6Z_CODCTA' , "X3_F3" , ""  } )
	EndIf

	/* Resumo Diário do ECF PIS */
	If SX3->( MsSeek("C7C_CTA") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7C_CTA' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7C_CTA' , "X3_F3" , ""  } )
	EndIf

	/* Resumo Resumo diário do ECF COFINS */
	If SX3->( MsSeek("C7D_CTA") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7D_CTA' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7D_CTA' , "X3_F3" , ""  } )
	EndIf

	/* Reg Anali. – CF-e (CÓDIGO 59) */
	If SX3->( MsSeek("CAB_CODCTA") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CAB_CODCTA' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CAB_CODCTA' , "X3_F3" , ""  } )
	EndIf

	/* INICIO Resumo diário de Doc.      */
    If SX3->( MsSeek("C7Q_CTA") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7Q_CODCTA' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7Q_CODCTA' , "X3_F3" , ""  } )
	EndIf

	/* Documentos Emitidos SAT-CF-E */
    If SX3->( MsSeek("C7R_CTA") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7R_CODCTA' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7R_CODCTA' , "X3_F3" , ""  } )
	EndIf

	/* Bilhete Consolidados de Passag */
    If SX3->( MsSeek("C7U_CTA") )
		If RecLock("SX3", .F.)
			SX3->X3_BROWSE	:=	"N"
			SX3->X3_F3		:=	""
			SX3->( MsUnlock() )
		EndIf
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7U_CODCTA' , "X3_BROWSE" , "N"  } )
		aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7U_CODCTA' , "X3_F3" , ""  } )
	EndIf

	/*  Cad. Participantes */
    If SX3->( MsSeek("C1H_ID") )
       If RecLock("SX3", .F.)
          SX3->X3_RELACAO := 'TAFGeraId("TAF")'
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C1H_ID' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C1H_ID' , "X3_RELACAO" , "TAFGeraId('TAF')"  } )
     EndIf

     If SX3->( MsSeek("C0R_CDPART") )
        If RecLock("SX3", .F.)
           SX3->X3_BROWSE := "N"
           SX3->X3_F3     := ""
           SX3->( MsUnlock() )
        EndIf
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C0R_CDPART' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C0R_CDPART' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C20_CODPAR") )
        If RecLock("SX3", .F.)
           SX3->X3_BROWSE := "N"
           SX3->X3_F3     := ""
           SX3->( MsUnlock() )
        EndIf
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C20_CODPAR' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C20_CODPAR' , "X3_F3" , ""  } )
     EndIf
	/*  Cad. Participantes */

	/*Identif. Documentos fiscais */
	If SX3->( MsSeek("C2V_CODPAR") )
	    If RecLock("SX3", .F.)
	       SX3->X3_BROWSE := "N"
	       SX3->X3_F3     := ""
	       SX3->( MsUnlock() )
	    EndIf
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C2V_CODPAR' , "X3_BROWSE" , "N"  } )
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C2V_CODPAR' , "X3_F3" , ""  } )
	EndIf
	/* Identif. Documentos fiscais */

	/*Informações adicionais ICMS ST */
	If SX3->( MsSeek("C3M_CODPAR") )
	    If RecLock("SX3", .F.)
	       SX3->X3_BROWSE := "N"
	       SX3->X3_F3     := ""
	       SX3->( MsUnlock() )
	    EndIf
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3M_CODPAR' , "X3_BROWSE" , "N"  } )
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3M_CODPAR' , "X3_F3" , ""  } )
	EndIf
	/* Informações adicionais ICMS ST*/

	/*Exportacoes indiretas */
	If SX3->( MsSeek("C4H_CODPAR") )
	    If RecLock("SX3", .F.)
	       SX3->X3_BROWSE := "N"
	       SX3->X3_F3     := ""
	       SX3->( MsUnlock() )
	    EndIf
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C4H_CODPAR' , "X3_BROWSE" , "N"  } )
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C4H_CODPAR' , "X3_F3" , ""  } )
	EndIf
	/* Exportacoes indiretas*/

	/*Ind.Doc.Fiscais - CIAP */
	If SX3->( MsSeek("C4U_CODPAR") )
	    If RecLock("SX3", .F.)
	       SX3->X3_BROWSE := "N"
	       SX3->X3_F3     := ""
	       SX3->( MsUnlock() )
	    EndIf
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C4U_CODPAR' , "X3_BROWSE" , "N"  } )
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C4U_CODPAR' , "X3_F3" , ""  } )
	EndIf
	/* Ind.Doc.Fiscais - CIAP*/

	/*Totais Oper Cartao de Cred/Deb*/
	If SX3->( MsSeek("C59_CODPAR") )
	    If RecLock("SX3", .F.)
	       SX3->X3_BROWSE := "N"
	       SX3->X3_F3     := ""
	       SX3->( MsUnlock() )
	    EndIf
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C59_CODPAR' , "X3_BROWSE" , "N"  } )
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C59_CODPAR' , "X3_F3" , ""  } )
	EndIf

	If SX3->( MsSeek("C59_CPARTI") )
	    If RecLock("SX3", .F.)
	       SX3->X3_ORDEM:= "04"
	       SX3->( MsUnlock() )
	    EndIf
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C59_CPARTI' , "X3_ORDEM" , "04"  } )
	EndIf
	/* Totais Oper Cartao de Cred/Deb*/

	/*Itens do Inventario*/
	If SX3->( MsSeek("C5B_CODPAR") )
	    If RecLock("SX3", .F.)
	       SX3->X3_BROWSE := "N"
	       SX3->X3_F3     := ""
	       SX3->( MsUnlock() )
	    EndIf
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5B_CODPAR' , "X3_BROWSE" , "N"  } )
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5B_CODPAR' , "X3_F3" , ""  } )
	EndIf
	/* Itens do Inventario*/

	/*Info. Adic. Ajustes Apur. Docu*/
	If SX3->( MsSeek("LEQ_CODPAR") )
	    If RecLock("SX3", .F.)
	       SX3->X3_BROWSE := "N"
	       SX3->X3_F3     := ""
	       SX3->( MsUnlock() )
	    EndIf
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'LEQ_CODPAR' , "X3_BROWSE" , "N"  } )
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'LEQ_CODPAR' , "X3_F3" , ""  } )
	EndIf
	/* Info. Adic. Ajustes Apur. Docu*/

	/*Correção Ap. Estoque Escritura*/
	If SX3->( MsSeek("LEY_CODPAR") )
	    If RecLock("SX3", .F.)
	       SX3->X3_BROWSE := "N"
	       SX3->X3_F3     := ""
	       SX3->( MsUnlock() )
	    EndIf
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'LEY_CODPAR' , "X3_BROWSE" , "N"  } )
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'LEY_CODPAR' , "X3_F3" , ""  } )
	EndIf

	If SX3->( MsSeek("T19_CODPAR") )
	    If RecLock("SX3", .F.)
	       SX3->X3_BROWSE := "N"
	       SX3->X3_F3     := ""
	       SX3->( MsUnlock() )
	    EndIf
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T19_CODPAR' , "X3_BROWSE" , "N"  } )
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T19_CODPAR' , "X3_F3" , ""  } )
	EndIf
	/* Correção Ap. Estoque Escritura*/

	/* Cadastro de Observações*/
	If SX3->( MsSeek("C3Q_ID") )
       If RecLock("SX3", .F.)
          SX3->X3_RELACAO := 'TAFGeraId("TAF")'
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3Q_ID' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3Q_ID' , "X3_RELACAO" , "TAFGeraId('TAF')"  } )
     EndIf

     If SX3->( MsSeek("C21_CDINFO") )
	    If RecLock("SX3", .F.)
	       SX3->X3_BROWSE := "N"
	       SX3->X3_F3     := ""
	       SX3->X3_ORDEM  := "04"
	       SX3->( MsUnlock() )
	    EndIf
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C21_CDINFO' , "X3_BROWSE" , "N"  } )
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C21_CDINFO' , "X3_F3" , 	  ""  } )
	    aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C21_CDINFO' , "X3_ORDEM" ,  "04"  } )
	EndIf
     /* Cadastro de Observações*/

     /* Inventário */
	If SX3->( MsSeek("C5A_ID") )
       If RecLock("SX3", .F.)
          SX3->X3_RELACAO := 'TAFGeraId("TAF")'
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5A_ID' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5A_ID' , "X3_RELACAO" , "TAFGeraId('TAF')"  } )
     EndIf
     /* Inventário */

      /* Natureza de operação */
	If SX3->( MsSeek("C1N_ID") )
       If RecLock("SX3", .F.)
          SX3->X3_RELACAO := 'TAFGeraId("TAF")'
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C1N_ID' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C1N_ID' , "X3_RELACAO" , "TAFGeraId('TAF')"  } )
     EndIf

     If SX3->( MsSeek("CFQ_NATOPE") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CFQ_NATOPE' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CFQ_NATOPE' , "X3_F3" , ""  } )
     EndIf
     /* Natureza de operação  */

      /* Item */
	If SX3->( MsSeek("C1L_ID") )
       If RecLock("SX3", .F.)
          SX3->X3_RELACAO := 'TAFGeraId("TAF")'
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C1L_ID' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C1L_ID' , "X3_RELACAO" , "TAFGeraId('TAF')"  } )
     EndIf

     If SX3->( MsSeek("C3B_CODITE") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3B_CODITE' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3B_CODITE' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C4N_CODITE") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C4N_CODITE' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C4N_CODITE' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C4X_CODITE") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C4X_CODITE' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C4X_CODITE' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C6Y_CODIGO") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C6Y_CODIGO' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C6Y_CODIGO' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C6Y_ITEM") )
       If RecLock("SX3", .F.)
          SX3->X3_ORDEM      := "03"
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C6Y_ITEM' , "X3_ORDER" , "03"  } )
     EndIf

     If SX3->( MsSeek("C7H_ITEM") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7H_ITEM' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7H_ITEM' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C7H_CODITE") )
       If RecLock("SX3", .F.)
          SX3->X3_ORDEM      := "05"
          SX3->( MsUnlock() )
        EndIf
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7H_CODITE' , "X3_ORDEM" , "05"  } )
     EndIf

     If SX3->( MsSeek("LEZ_CODPRO") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'LEZ_CODPRO' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'LEZ_CODPRO' , "X3_F3" , ""  } )
     EndIf

     /* Cta Contábil */
     If SX3->( MsSeek("C4L_CODCTA") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C4L_CODCTA' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C4L_CODCTA' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C4I_CODCTA") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C4I_CODCTA' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C4I_CODCTA' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C58_CODCTA") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C58_CODCTA' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C58_CODCTA' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C5G_CODCTA") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5G_CODCTA' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5G_CODCTA' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C5K_CODCTA") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5K_CODCTA' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5K_CODCTA' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C5M_CODCTA") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5M_CODCTA' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5M_CODCTA' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C6M_CODCTA") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C6M_CODCTA' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C6M_CODCTA' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C71_CTA") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C71_CTA' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C71_CTA' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C74_CTA") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C74_CTA' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C74_CTA' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C75_CTA") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C75_CTA' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C75_CTA' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C7J_CODCTA") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7J_CODCTA' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7J_CODCTA' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C7K_CODCTA") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7K_CODCTA' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7K_CODCTA' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C7Z_CTA") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7Z_CTA' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7Z_CTA' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("CHF_CODCTA") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CHF_CODCTA' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CHF_CODCTA' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("C3B_CODPAR") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3B_CODPAR' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3B_CODPAR' , "X3_F3" , ""  } )
     EndIf

     If SX3->( MsSeek("LEM_IDPAR") )
       If RecLock("SX3", .F.)
          SX3->X3_BROWSE      := "N"
          SX3->X3_F3          :=  ""
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'LEM_IDPAR' , "X3_BROWSE" , "N"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'LEM_IDPAR' , "X3_F3" , ""  } )
     EndIf

	If SX3->( MsSeek("C91_CNPJEA"))
       If RecLock("SX3", .F.)
          SX3->X3_TITULO      := "Nr Inscrição"
          SX3->X3_DESCRIC     := "Número de Inscrição"
          SX3->( MsUnlock() )
        EndIf

        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C91_CNPJEA' , "X3_TITULO" , "Nr Inscrição"  } )
        aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C91_CNPJEA' , "X3_DESCRIC" , "Número de Inscrição"  } )
    EndIf

Return

//---------------------------------------------------------------
/*/{Protheus.doc} ChgOrder
Funcão que troca a ordem dos registros.

@Param	cAlias - Alias desejado
		aCampos[1] - Campo desejado para a troca
		aCampos[2] - Nova ordem

Observação - O campo que já conter a ordem passada ele trocara com a ordem do campo passado em aCampos[1]

@Author	Eduardo Sukeda
@Since	19/06/2019
@Version 1.0
/*/
//---------------------------------------------------------------
Static Function ChgOrder(cAlias)

	Local cCampo	:= ""
	Local cOrdem	:= ""
	Local aAreaSX3	:= SX3->( GetArea() )
	Local aCampos 	:= {}
	Local nX 		:= 0

	Default cAlias 	:= ""

	If cAlias $ "CM8|T92"
		aAdd(aCampos, {cAlias + "_DTRABA" , "02"})
		aAdd(aCampos, {cAlias + "_CPFV"  , "03"})
	ElseIf cAlias == "T2M"
		aAdd(aCampos, {cAlias + "_NOMEV" , "02"})
		aAdd(aCampos, {cAlias + "_CPFTRB", "03"})
	Else
		aAdd(aCampos, {cAlias + "_NOMEV" , "02"})
		aAdd(aCampos, {cAlias + "_CPFV"  , "03"})
	EndIf

	If !Empty(cAlias)
		For nX := 1 To Len(aCampos)
			SX3->( DbSetOrder( 1 ) )
			If SX3->( MsSeek(cAlias+ aCampos[nX][2]) )
				cCampo := SX3->X3_CAMPO
				SX3->( DbSetOrder( 2 ) )
				If SX3->( MsSeek(aCampos[nX][1]) )
					cOrdem := SX3->X3_ORDEM
				EndIf
			EndIf

			SX3->( DbSetOrder( 2 ) )
			If SX3->( MsSeek(cCampo))
				If RecLock( "SX3", .F. )
					SX3->X3_ORDEM := cOrdem
					SX3->( MsUnlock() )
				EndIf
			EndIf

			If SX3->( MsSeek(aCampos[nX][1]))
				If RecLock( "SX3", .F. )
					SX3->X3_ORDEM := aCampos[nX][2]
					SX3->( MsUnlock() )
				EndIf
			EndIf
		Next nX
	EndIf

	RestArea( aAreaSX3 )

Return Nil

//---------------------------------------------------------------
/*/{Protheus.doc} OrderTbC30
Funcão que troca a ordem dos campos da tabela C30

@Obs - 	Durante o teste sistêmico da 12.1.27 foi identificado que os campos C30_CODIPA e C30_DCDIPA estavam com o X3_ORDEM vazio no ATUSX.
		Ao rodar UPDDISTR, esses campos ficaram na posição 01 e 02 dentro do Dicionário SX3. Isso fez com que a ordem de apresentação na tela ( TAFA062 ) ficasse desordenada.

		Cod.Dipam | Descr.Dipam | Cód Item | Num.Item | Descr It

		Ex: 1- Campos C30_CODIPA ( Cod.Dipam ) e C30_DCDIPA ( Descr.Dipam ) apareciam antes do campo C30_NUMITE
			2- Campo C30_ITEM ( Cód. Item ) aparecia antes do campo C30_NUMITE ( Núm.Item ), porque dentro do fonte TAFA062 tem a instrução 'oStruC30:SetProperty( "C30_ITEM", MVC_VIEW_ORDEM, "04" )' 
			   que coloca o campo na posição '04', e o campo C30_NUMITE ficou com X3_ORDEM maior do que '04'

		Depois de rodar UPDDISTR, ao rodar UPDTAF o X3_ORDEM da tabela ficou com lacunas na ordenação ( não tinha mais posição '01' e '02' ) e alguns campos ficaram com a mesma ordenação

		Ex: X3_ORDEM	X3_CAMPO
			61			C30_CODIPA
			61			C30_IDTSER
			62			C30_DCDIPA
			62			C30_INDISE

		Com essa função garanto que o X3_ORDEM estará de acordo com o ATUSX.

@Author	Wesley Pinheiro
@Since	16/01/2020
@Version 1.0
/*/
//---------------------------------------------------------------
Static Function OrderTbC30( )

	Local nX       := 0
	Local aCampos  := { }
	Local aAreaSX3 := SX3-> ( GetArea( ) )

	aAdd( aCampos, { "C30_FILIAL", "01" } )
	aAdd( aCampos, { "C30_CHVNF" , "02" } )
	aAdd( aCampos, { "C30_NUMITE", "03" } )
	aAdd( aCampos, { "C30_CODITE", "04" } )
	aAdd( aCampos, { "C30_ITEM"  , "05" } )
	aAdd( aCampos, { "C30_DCODIT", "06" } )
	aAdd( aCampos, { "C30_DESCRI", "07" } )
	aAdd( aCampos, { "C30_UM"    , "08" } )
	aAdd( aCampos, { "C30_DUM"   , "09" } )
	aAdd( aCampos, { "C30_ORIGEM", "10" } )
	aAdd( aCampos, { "C30_DORIGE", "11" } )
	aAdd( aCampos, { "C30_QUANT" , "12" } )
	aAdd( aCampos, { "C30_VLRITE", "13" } )
	aAdd( aCampos, { "C30_VLDESC", "14" } )
	aAdd( aCampos, { "C30_TOTAL" , "15" } )
	aAdd( aCampos, { "C30_CFOP"  , "16" } )
	aAdd( aCampos, { "C30_DCFOP" , "17" } )
	aAdd( aCampos, { "C30_CODSER", "18" } )
	aAdd( aCampos, { "C30_DCODSE", "19" } )
	aAdd( aCampos, { "C30_INDMOV", "20" } )
	aAdd( aCampos, { "C30_ESTOQ" , "21" } )
	aAdd( aCampos, { "C30_NATOPE", "22" } )
	aAdd( aCampos, { "C30_CODNAT", "23" } )
	aAdd( aCampos, { "C30_DNATOP", "24" } )
	aAdd( aCampos, { "C30_QTDPAD", "25" } )
	aAdd( aCampos, { "C30_VLUNID", "26" } )
	aAdd( aCampos, { "C30_SELO"  , "27" } )
	aAdd( aCampos, { "C30_DSELO" , "28" } )
	aAdd( aCampos, { "C30_QTDSEL", "29" } )
	aAdd( aCampos, { "C30_VLOUTR", "30" } )
	aAdd( aCampos, { "C30_CLENQ" , "31" } )
	aAdd( aCampos, { "C30_DCLENQ", "32" } )
	aAdd( aCampos, { "C30_NATREC", "33" } )
	aAdd( aCampos, { "C30_NATBCC", "34" } )
	aAdd( aCampos, { "C30_DNATBC", "35" } )
	aAdd( aCampos, { "C30_ORICRE", "36" } )
	aAdd( aCampos, { "C30_CTACTB", "37" } )
	aAdd( aCampos, { "C30_CODCTA", "38" } )
	aAdd( aCampos, { "C30_DCTACT", "39" } )
	aAdd( aCampos, { "C30_CCUSTO", "40" } )
	aAdd( aCampos, { "C30_DCCUST", "41" } )
	aAdd( aCampos, { "C30_INDAPU", "42" } )
	aAdd( aCampos, { "C30_BSTORI", "43" } )
	aAdd( aCampos, { "C30_VSTREP", "44" } )
	aAdd( aCampos, { "C30_BCRETQ", "45" } )
	aAdd( aCampos, { "C30_VLRET" , "46" } )
	aAdd( aCampos, { "C30_VSTCOM", "47" } )
	aAdd( aCampos, { "C30_CSTCOM", "48" } )
	aAdd( aCampos, { "C30_DCSTCO", "49" } )
	aAdd( aCampos, { "C30_CSOSN" , "50" } )
	aAdd( aCampos, { "C30_DESNFE", "51" } )
	aAdd( aCampos, { "C30_VLOPER", "52" } )
	aAdd( aCampos, { "C30_RE"    , "53" } )
	aAdd( aCampos, { "C30_VLACRE", "54" } )
	aAdd( aCampos, { "C30_VLRDA" , "55" } )
	aAdd( aCampos, { "C30_SRVMUN", "56" } )
	aAdd( aCampos, { "C30_LICIMP", "57" } )
	aAdd( aCampos, { "C30_TPREPA", "58" } )
	aAdd( aCampos, { "C30_IDTSER", "59" } )
	aAdd( aCampos, { "C30_INDISE", "60" } )
	aAdd( aCampos, { "C30_CODIPA", "61" } )
	aAdd( aCampos, { "C30_DCDIPA", "62" } )
	aAdd( aCampos, { "C30_ICMSFT", "63" } )

	for nX := 1 To Len( aCampos )

		If SX3->( MsSeek( aCampos[nX][1] ) )

			If Reclock( "SX3", .F. )
				SX3->X3_ORDEM := aCampos[nX][2]
				SX3->( MsUnlock( ) )
			EndIf

		EndIf

	Next nX

	RestArea( aAreaSX3 )

Return
