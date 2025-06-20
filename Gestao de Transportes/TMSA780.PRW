#INCLUDE "TMSA780.ch"
#INCLUDE "Protheus.ch"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA780  � Autor � Robson Alves          � Data �23.06.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Transferencia de Enderecos.                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA780()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMS                                                        ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tmsa780()

Local aCampos     := {}
Local lInverte    := .F.
Local lExibeBrw   := .F.

Private cMarca    := GetMark()
Private aRotina   := {}
Private cCadastro := STR0001 //"Transferencia de Enderecos"
Private cCusMed   := GetMv("MV_CUSMED")
Private aRegSD3   := {}
Private oTempTable
Private TRB  	  

If Pergunte( "TMA780", .T. )
	Processa( { |lEnd| Tmsa780Trb( @lExibeBrw ) }, STR0002 ) //"Gerando arquivo de trabalho."

	If lExibeBrw
		//��������������������������������������������������������������Ŀ
		//� Define Array contendo as Rotinas a executar do programa      �
		//� ----------- Elementos contidos por dimensao ------------     �
		//� 1. Nome a aparecer no cabecalho                              �
		//� 2. Nome da Rotina associada                                  �
		//� 3. Usado pela rotina                                         �
		//� 4. Tipo de Transa��o a ser efetuada                          �
		//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
		//�    2 - Simplesmente Mostra os Campos                         �
		//�    3 - Inclui registros no Bancos de Dados                   �
		//�    4 - Altera o registro corrente                            �
		//�    5 - Remove o registro corrente do Banco de Dados          �
		//����������������������������������������������������������������
		aRotina := { 	{ STR0003 , "TMSA780Psq"	,0 ,1},;	//"Pesquisar"
						  	{ STR0004 , "TMSA780Mnt"	,0 ,2},;	//"Visualizar"
						  	{ STR0005 , "TMSA780Mnt"	,0 ,3} }	//"Transferir"
	
		/* Define os campos para mostrar no Browse. */
		Aadd(aCampos, {"TRB_OK"    , "  ", ""							        , "" })
		Aadd(aCampos, {"TRB_FILDOC", ""  , Rtrim(RetTitle("DT6_FILDOC")), PesqPict("DT6", "DT6_FILDOC")} )
		Aadd(aCampos, {"TRB_DOC"   , ""  , Rtrim(RetTitle("DT6_DOC"))   , PesqPict("DT6", "DT6_DOC"   )} )
		Aadd(aCampos, {"TRB_SERIE" , ""  , Rtrim(RetTitle("DT6_SERIE")) , PesqPict("DT6", "DT6_SERIE" )} )
		Aadd(aCampos, {"TRB_QTDVOL", ""  , Rtrim(RetTitle("DT6_QTDVOL")), PesqPict("DT6", "DT6_QTDVOL")} )
		Aadd(aCampos, {"TRB_PESO"  , ""  , Rtrim(RetTitle("DT6_PESO"))  , PesqPict("DT6", "DT6_PESO"  )} )
		Aadd(aCampos, {"TRB_PESOM3", ""  , Rtrim(RetTitle("DT6_PESOM3")), PesqPict("DT6", "DT6_PESOM3")} )
		Aadd(aCampos, {"TRB_VALMER", ""  , Rtrim(RetTitle("DT6_VALMER")), PesqPict("DT6", "DT6_VALMER")} )
		Aadd(aCampos, {"TRB_CDRORI", ""  , Rtrim(RetTitle("DT6_CDRORI")), PesqPict("DT6", "DT6_CDRORI")} )
		Aadd(aCampos, {"TRB_REGORI", ""  , Rtrim(RetTitle("DUY_DESCRI")), PesqPict("DUY", "DUY_DESCRI")} )
		Aadd(aCampos, {"TRB_CDRDES", ""  , Rtrim(RetTitle("DT6_CDRDES")), PesqPict("DT6", "DT6_CDRDES")} )
		Aadd(aCampos, {"TRB_REGDES", ""  , Rtrim(RetTitle("DUY_DESCRI")), PesqPict("DUY", "DUY_DESCRI")} )
		Aadd(aCampos, {"TRB_CDRCAL", ""  , Rtrim(RetTitle("DT6_CDRCAL")), PesqPict("DT6", "DT6_CDRCAL")} )
		Aadd(aCampos, {"TRB_REGCAL", ""  , Rtrim(RetTitle("DUY_DESCRI")), PesqPict("DUY", "DUY_DESCRI")} )
	
		MarkBrow(TRB,"TRB_OK",,aCampos,lInverte,cMarca,"Tmsa780All()")
	Else		
		HELP(" ",1,"REGNOIS") //"Nao existe registro relacionado a este codigo"
	EndIf		
	
	//-- Apaga os arquivos temporarios	
	oTempTable:Delete()	
EndIf

Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tmsa780Trb� Autor � Robson Alves          � Data �23.06.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria arquivo de trabalho.                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMS                                                        ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tmsa780Trb( lExibeBrw )

Local cSeek     := ""
Local aStruct   := {}
Local lGrvTrb   := .F.

/* Cria estrutura do arquivo de trabalho. */
AAdd(aStruct, {"TRB_OK"    , "C", 02							 , 0 })
AAdd(aStruct, {"TRB_FILDOC", "C", FWGETTAMFILIAL, 0 })
AAdd(aStruct, {"TRB_DOC"   , "C", TamSX3("DT6_DOC")[1]   , 0 })
AAdd(aStruct, {"TRB_SERIE" , "C", TamSX3("DT6_SERIE")[1] , 0 })
AAdd(aStruct, {"TRB_QTDVOL", "N", TamSX3("DT6_QTDVOL")[1], TamSX3("DT6_QTDVOL")[2] })
AAdd(aStruct, {"TRB_PESO"  , "N", TamSX3("DT6_PESO")[1]  , TamSX3("DT6_PESO")[2] })
AAdd(aStruct, {"TRB_PESOM3", "N", TamSX3("DT6_PESOM3")[1], TamSX3("DT6_PESOM3")[2] })
AAdd(aStruct, {"TRB_VALMER", "N", TamSX3("DT6_VALMER")[1], TamSX3("DT6_VALMER")[2] })
AAdd(aStruct, {"TRB_CDRORI", "C", TamSX3("DT6_CDRORI")[1], 0 })
AAdd(aStruct, {"TRB_REGORI", "C", TamSX3("DUY_DESCRI")[1], 0 })
AAdd(aStruct, {"TRB_CDRDES", "C", TamSX3("DT6_CDRDES")[1], 0 })
AAdd(aStruct, {"TRB_REGDES", "C", TamSX3("DUY_DESCRI")[1], 0 })
AAdd(aStruct, {"TRB_CDRCAL", "C", TamSX3("DT6_CDRCAL")[1], 0 })
AAdd(aStruct, {"TRB_REGCAL", "C", TamSX3("DUY_DESCRI")[1], 0 })

TRB  	  := GetNextAlias()
oTempTable:= FWTemporaryTable():New(TRB)
oTempTable:SetFields( aStruct )
oTempTable:AddIndex("01", {"TRB_FILDOC","TRB_DOC","TRB_SERIE"} )
oTempTable:Create()


If !Empty( mv_par01 ) .And. !Empty( mv_par02 )
	/* Obtem os enderecos de todos os documentos do ( Local / Armazem ) informado. */
	
	DTC->( dbSetOrder( 2 ) ) // Notas Fiscais do Cliente.
	DT6->( dbSetOrder( 1 ) ) // Documentos de Transporte.
	DUH->( dbSetOrder( 2 ) ) // Enderecamento de Notas Fiscais.
	DUH->( MsSeek( cSeek := xFilial("DUH") + cFilAnt + StrZero( 1, Len( DUH->DUH_STATUS ) ) + mv_par01 + mv_par02 ) )
	DUH->( ProcRegua( RecCount() ) )
	
	While DUH->( !Eof() .And. DUH_FILIAL + DUH_FILORI + DUH_STATUS + DUH_LOCAL + DUH_LOCALI == cSeek )
		DTC->( MsSeek( xFilial("DTC") + DUH->DUH_NUMNFC + DUH->DUH_SERNFC + DUH->DUH_CLIREM + DUH->DUH_LOJREM ) )
		
		IncProc()
		
		If !Empty( mv_par03) .And. AllTrim( DTC->DTC_FILDOC ) != AllTrim( mv_par03 ) .Or.;
			!Empty( mv_par04) .And. AllTrim( DTC->DTC_DOC )    != AllTrim( mv_par04 ) .Or.;
			!Empty( mv_par05) .And. AllTrim( DTC->DTC_SERIE )  != AllTrim( mv_par05 )
			
			DUH->( dbSkip() )
			Loop
		EndIf
		
		If DT6->( MsSeek( xFilial("DT6") + DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE ) )
			If !dbSeek( DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE )
				RecLock(TRB, .T.)
				(TRB)->TRB_OK     := cMarca
				(TRB)->TRB_FILDOC := DT6->DT6_FILDOC
				(TRB)->TRB_DOC    := DT6->DT6_DOC
				(TRB)->TRB_SERIE  := DT6->DT6_SERIE
				(TRB)->TRB_QTDVOL := DT6->DT6_QTDVOL
				(TRB)->TRB_PESO   := DT6->DT6_PESO
				(TRB)->TRB_PESOM3 := DT6->DT6_PESOM3
				(TRB)->TRB_VALMER := DT6->DT6_VALMER
				(TRB)->TRB_CDRORI := DT6->DT6_CDRORI
				(TRB)->TRB_REGORI := Posicione( "DUY", 1, xFilial("DUY") + DT6->DT6_CDRORI, "DUY_DESCRI" )
				(TRB)->TRB_CDRDES := DT6->DT6_CDRDES
				(TRB)->TRB_REGDES := Posicione( "DUY", 1, xFilial("DUY") + DT6->DT6_CDRDES, "DUY_DESCRI" )
				(TRB)->TRB_CDRCAL := DT6->DT6_CDRCAL
				(TRB)->TRB_REGCAL := Posicione( "DUY", 1, xFilial("DUY") + DT6->DT6_CDRCAL, "DUY_DESCRI" )
				MsUnLock()
			EndIf				
		EndIf
		
		DUH->( dbSkip() )
	EndDo
ElseIf !Empty( mv_par03 ) .And. !Empty( mv_par04 ) .And. !Empty( mv_par05 )
	/* Obtem os enderecos do documentos informado. */
	
	DTC->( dbSetOrder( 3 ) ) // Notas Fiscais do Cliente.
	DTC->( MsSeek( xFilial("DTC") + mv_par03 + mv_par04 + mv_par05) )
	
	DT6->( dbSetOrder( 1 ) ) // Documentos de Transporte.
	DT6->( MsSeek( xFilial("DT6") + DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE ) )

	DUH->( dbSetOrder( 1 ) ) // Enderecamento de Notas Fiscais.
	DUH->( MsSeek( cSeek := xFilial("DUH") + cFilAnt + DTC->DTC_NUMNFC + DTC->DTC_SERNFC + DTC->DTC_CLIREM + DTC->DTC_LOJREM ) )
	DUH->( ProcRegua( RecCount() ) )

	While DUH->( !Eof() .And. DUH_FILIAL + DUH_FILORI + DUH_NUMNFC + DUH_SERNFC + DUH_CLIREM + DUH_LOJREM == cSeek )
		IncProc()

		If DUH->DUH_STATUS == StrZero( 1, Len( DUH->DUH_STATUS ) ) // Em aberto
			lGrvTrb := .T.
			Exit
		EndIf
		DUH->( dbSkip() )
	EndDo
	If lGrvTrb
		If !dbSeek( DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE )
			RecLock(TRB, .T.)
			(TRB)->TRB_OK     := cMarca
			(TRB)->TRB_FILDOC := DT6->DT6_FILDOC
			(TRB)->TRB_DOC    := DT6->DT6_DOC
			(TRB)->TRB_SERIE  := DT6->DT6_SERIE
			(TRB)->TRB_QTDVOL := DT6->DT6_QTDVOL
			(TRB)->TRB_PESO   := DT6->DT6_PESO
			(TRB)->TRB_PESOM3 := DT6->DT6_PESOM3
			(TRB)->TRB_VALMER := DT6->DT6_VALMER
			(TRB)->TRB_CDRORI := DT6->DT6_CDRORI
			(TRB)->TRB_REGORI := Posicione( "DUY", 1, xFilial("DUY") + DT6->DT6_CDRORI, "DUY_DESCRI" )
			(TRB)->TRB_CDRDES := DT6->DT6_CDRDES
			(TRB)->TRB_REGDES := Posicione( "DUY", 1, xFilial("DUY") + DT6->DT6_CDRDES, "DUY_DESCRI" )
			(TRB)->TRB_CDRCAL := DT6->DT6_CDRCAL
			(TRB)->TRB_REGCAL := Posicione( "DUY", 1, xFilial("DUY") + DT6->DT6_CDRCAL, "DUY_DESCRI" )
			MsUnLock()
		EndIf				
	EndIf
EndIf

dbSelectArea(TRB)
dbGotop()
lExibeBrw := !Eof()
	
Return( lExibeBrw )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA780Psq � Autor � Robson Alves       � Data � 24.06.2003 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua a pesquisa no arquivo de trabalho.                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tmsa780Psq()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMS                                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function Tmsa780Psq()

Local cCampo  := Space( 40 )                     
Local cTitulo := ""
Local lSeek	  := .F.
Local nOrdem  := 1
Local aCbx    := {}
Local oCbx, oDlg, oPsqGet, cOrd

/* Define as opcoes de pesquisa para o arquivo de trabalho. */
cTitulo :=	AllTrim( Posicione( "SX3", 2, "DT6_FILDOC", "X3Titulo()" ) ) + "+" +;
				AllTrim( Posicione( "SX3", 2, "DT6_DOC"   , "X3Titulo()" ) ) + "+" +;
				AllTrim( Posicione( "SX3", 2, "DT6_SERIE" , "X3Titulo()" ) )
Aadd(aCbx, cTitulo)

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0007 //"Pesquisa"
	@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg ON CHANGE nOrdem := oCbx:nAt
	@ 22,05 MSGET oPsqGet VAR cCampo PICTURE "@!" SIZE 206,10 PIXEL

	DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
	DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()
ACTIVATE MSDIALOG oDlg CENTERED

If lSeek
	(TRB)->( dbSetOrder(1) )
	(TRB)->( dbSeek( AllTrim( cCampo ) ) )
EndIf	

Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA780Mnt� Autor � Robson Alves          � Data �24.06.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao de enderecos.                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA500Mnt(ExpC1, ExpN1, ExpN2)                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA780Mnt( cAlias, nReg, nOpcx )

Local aTam       := {}
Local nOpcA      := 0
Local aObjects   := {}
Local aPosObj    := {}
Local aSize      := MsAdvSize()
Local aInfo      := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aButtons   := {}
Local nTamMax    := 0
Local oDlg, oGetD

Private aHeader  := {}
Private aCols    := {}

If nOpcx == 2
	DT6->( dbSetOrder( 1 ) ) // Documentos de Transporte.
	If DT6->( MsSeek( xFilial("DT6") + (TRB)->TRB_FILDOC + (TRB)->TRB_DOC + (TRB)->TRB_SERIE ) )
		Tmsa500Mnt( "DT6", DT6->( Recno() ), nOpcx )
	EndIf
Else
	Aadd(aButtons, {"EMPILHADEIRA", { ||Tmsa780Dig() }, STR0008 , STR0010 } ) //"Endereco para todos documentos"
	
	aTam := TamSX3("DTC_NUMNFC")	
	Aadd(aHeader,{RetTitle("DTC_NUMNFC"),"DTC_NUMNFC"	,PesqPict("DTC","DTC_NUMNFC",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTC"," "})
	aTam := TamSX3("DTC_SERNFC")	
	Aadd(aHeader,{RetTitle("DTC_SERNFC"),"DTC_SERNFC"	,PesqPict("DTC","DTC_SERNFC" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTC"," "})
	aTam := TamSX3("DT6_FILDOC")	
	Aadd(aHeader,{RetTitle("DT6_FILDOC"),"DT6_FILDOC"	,PesqPict("DT6","DT6_FILDOC" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DT6"," "})
	aTam := TamSX3("DT6_DOC")	
	Aadd(aHeader,{RetTitle("DT6_DOC"),"DT6_DOC"	,PesqPict("DT6","DT6_DOC" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DT6","V"})
	aTam := TamSX3("DT6_SERIE")	
	Aadd(aHeader,{RetTitle("DT6_SERIE"),"DT6_SERIE"	,PesqPict("DT6","DT6_SERIE" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DT6"," "})
	Aadd(aHeader,{RetTitle("DTC_EMINFC"),"DTC_EMINFC"	,PesqPict("DTC","DTC_EMINFC"),8       ,0       ,"",USADO, "D" ,"DTC"," "})
	aTam := TamSX3("DTC_QTDVOL")	
	Aadd(aHeader,{RetTitle("DTC_QTDVOL"),"DTC_QTDVOL"	,PesqPict("DTC","DTC_QTDVOL",aTam[1]),aTam[1],aTam[2],"",USADO, "N" ,"DTC"," "})
	aTam := TamSX3("DTC_VALOR")	
	Aadd(aHeader,{RetTitle("DTC_VALOR"),"DTC_VALOR"  	,PesqPict("DTC","DTC_VALOR" ,aTam[1]),aTam[1],aTam[2],"",USADO, "N" ,"DTC"," "})
	aTam := TamSX3("DTC_CLIREM")	
	Aadd(aHeader,{RetTitle("DTC_CLIREM"),"DTC_CLIREM"	,PesqPict("DTC","DTC_CLIREM",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTC"," "})
	aTam := TamSX3("DTC_LOJREM")	
	Aadd(aHeader,{RetTitle("DTC_LOJREM"),"DTC_LOJREM"	,PesqPict("DTC","DTC_LOJREM",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTC"," "})
	aTam := TamSX3("DTC_NOMREM")	
	Aadd(aHeader,{RetTitle("DTC_NOMREM"),"DTC_NOMREM"	,PesqPict("DTC","DTC_NOMREM",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTC"," "})
	aTam := TamSX3("DUH_LOCAL")	
	Aadd(aHeader,{RetTitle("DUH_LOCAL"),"DUH_LOCAL"  	,PesqPict("DUH","DUH_LOCAL" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DUH"," "})
	aTam := TamSX3("DUH_LOCALI")	
	Aadd(aHeader,{RetTitle("DUH_LOCALI"),"DUH_LOCALI"	,PesqPict("DUH","DUH_LOCALI",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DUH"," "})

	(TRB)->( dbGotop() )
	While (TRB)->( !Eof() )
		If IsMark( "TRB_OK", cMarca )
			DUH->( dbSetOrder( 1 ) ) // Enderecamento de Notas Fiscais.
			DTC->( dbSetOrder( 3 ) ) // Notas Fiscais do Cliente.
			DTC->( MsSeek( xFilial("DTC") + (TRB)->( TRB_FILDOC + TRB_DOC +TRB_SERIE ) ) )
			DTC->( DbEval( {|| Aadd( aCols, {	DTC->DTC_NUMNFC, ;
															DTC->DTC_SERNFC,; 
															DT6->DT6_FILDOC,;
															DT6->DT6_DOC,;
															DT6->DT6_SERIE,;
															DTC->DTC_EMINFC,;
															DTC->DTC_QTDVOL,;
															DTC->DTC_VALOR,;
															DTC->DTC_CLIREM,;
															DTC->DTC_LOJREM,;
															Posicione( "SA1", 1, xFilial("SA1") + DTC->DTC_CLIREM + DTC->DTC_LOJREM, "A1_NOME" ), ;
															DUH->DUH_LOCAL ,	;
															DUH->DUH_LOCALI, ;
															.F.   } ) },;
								{ || 	DUH->( MsSeek( xFilial("DUH") + cFilAnt + DTC->DTC_NUMNFC + DTC->DTC_SERNFC + DTC->DTC_CLIREM + DTC->DTC_LOJREM ) ) .And.;
								      DT6->( MsSeek( xFilial("DT6") + DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE ) )                                    },;
								{ || 	!Eof() .And. DTC->DTC_FILIAL + DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE == xFilial("DTC") + (TRB)->( TRB_FILDOC + TRB_DOC +TRB_SERIE ) } )	)
			nTamMax += 1								
		EndIf			
		(TRB)->( dbSkip() )
	EndDo							

	Aadd( aObjects, { 100, 100, .T., .T., .F. } )
	aPosObj := MsObjSize( aInfo, aObjects )
	DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]
		oGetD := MSGetDados():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],nOpcX,"AllwaysTrue","AllwaysTrue",,.T.,,,,nTamMax)
		oGetD:oBrowse:aAlter := {"DUH_LOCAL", "DUH_LOCALI"}
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| IIF(oGetD:TudoOk(),(nOpcA:=1,oDlg:End()),)},{||oDlg:End()},,aButtons))		

	If nOpcA == 1
		Processa( { |lEnd| Tmsa780Trf() }, STR0009 ) //"Efetuando a transferencia."
	EndIf
	MBRCHGLoop() // Nao chama novamente a tela de inlusao.
EndIf

Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tmsa780Trf� Autor � Robson Alves          � Data �24.06.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua a transferencia de enderecos.                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tmsa780Trf()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nil                                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function Tmsa780Trf()

Local nA        := 0
Local lFoundDUH := .F.
Local lFoundDTC := .F.
Local cSeek     := ""
Local cTesEnt	 := GetMV("MV_TESDR",,"") // Tes de Entrada
                
SF4->( DbSetOrder( 1 ) )
SF4->(MsSeek(xFilial('SF4') + cTesEnt, .F.)) 

SD1->( dbSetOrder( 1 ) ) // Itens das NF's de Entrada.
DUH->( dbSetOrder( 1 ) ) // Enderecamento de Notas Fiscais
DTC->( dbSetOrder( 2 ) ) // Notas Fiscais do Cliente
                
ProcRegua( Len( aCols ) )
For nA := 1 To Len( aCols )
	IncProc()
	
	If !GdDeleted( nA )
		lFoundDUH := DUH->( MsSeek( cSeek := xFilial("DUH") + cFilAnt + GdFieldGet("DTC_NUMNFC", nA) + GdFieldGet("DTC_SERNFC", nA) + GdFieldGet("DTC_CLIREM", nA) + GdFieldGet("DTC_LOJREM", nA) ) )
		lFoundDTC := DTC->( MsSeek( xFilial("DTC") + DUH->DUH_NUMNFC + DUH->DUH_SERNFC + DUH->DUH_CLIREM + DUH->DUH_LOJREM ) )

		/* Somente efetua a transferencia se os registros foram encontrados e se o armazem ou endereco foi alterado. */
		If lFoundDUH .And. lFoundDTC .And. DUH->( DUH_LOCAL + DUH_LOCALI ) != GdFieldGet("DUH_LOCAL", nA) + GdFieldGet("DUH_LOCALI", nA)
         //-- Se o Tes de Entrada Atualiza Estoque 
			If SF4->F4_ESTOQUE == "S" .And. 	SD1->( MsSeek( xFilial("SD1") + GdFieldGet("DTC_NUMNFC", nA) + GdFieldGet("DTC_SERNFC", nA) +;
				GdFieldGet("DTC_CLIREM", nA) + GdFieldGet("DTC_LOJREM", nA) ) )
				A260Processa( DTC->DTC_CODPRO, DUH->DUH_LOCAL, DUH->DUH_QTDVOL, SD3->( ProxNum() ), dDataBase,;
				0, SD1->D1_NUMLOTE, SD1->D1_LOTECTL, SD1->D1_DTVALID, "", DUH->DUH_LOCALI, DTC->DTC_CODPRO,;
				GdFieldGet("DUH_LOCAL", nA), GdFieldGet("DUH_LOCALI", nA), .F., 0, 0, "TMSA780" )
			EndIf	
			RecLock("DUH", .F.)
			DUH->DUH_LOCAL  := GdFieldGet("DUH_LOCAL" , nA)
			DUH->DUH_LOCALI := GdFieldGet("DUH_LOCALI", nA)
			MsUnLock()
		EndIf								  
	EndIf
Next nA

Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tmsa780Dig� Autor � Robson Alves          � Data �24.06.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Digitacao do endereco para todos os documentos.            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tmsa780Dig()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nil                                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function Tmsa780Dig()

Local cLocal  := Criavar( "DUH_LOCAL" , .F.)
Local cLocali := Criavar( "DUH_LOCALI", .F.)
Local cFilDco := Criavar( "DT6_FILDOC", .F.)
Local cDoc    := Criavar( "DT6_DOC"   , .F.)
Local cSerie  := Criavar( "DT6_SERIE" , .F.)
Local nOpca   := 0
Local oDlgDig

DEFINE MSDIALOG oDlgDig FROM  125,3 TO 340,548 TITLE cCadastro PIXEL
	oPanel := TPanel():New(15,05,"",oDlgDig,,,,,CLR_WHITE,263, 60,.T.) 
	
	/* Armazem. */
	@ 010, 010 SAY RetTitle( "DUH_LOCAL" ) SIZE 030,007 OF oPanel PIXEL
	@ 010, 050 MSGET cLocal PICTURE PesqPict( "DUH", "DUH_LOCAL" ) VALID NaoVazio(cLocal) SIZE 10, 07  OF oPanel PIXEL 
	
	/* Endereco. */
	@ 010, 150 SAY RetTitle( "DUH_LOCALI" ) SIZE 030,007 OF oPanel PIXEL
	@ 010, 190 MSGET cLocali PICTURE PesqPict( "DUH", "DUH_LOCALI" ) VALID ( NaoVazio( cLocal ) .And. ExistCpo("SBE", cLocal + cLocali ) ) F3 "SBE" SIZE 60, 07 OF oPanel PIXEL 
	
	/* Filial Documento. */
	@ 022, 010 SAY RetTitle( "DT6_FILDOC" ) SIZE 030,007 OF oPanel PIXEL
	@ 022, 050 MSGET cFilDco PICTURE PesqPict( "DT6", "DT6_FILDOC" ) SIZE 10, 07 F3 "DL6" OF oPanel PIXEL 
	
		/* Documento. */
	@ 034, 010 SAY RetTitle( "DT6_DOC" ) SIZE 050,007 OF oPanel PIXEL
	@ 034, 050 MSGET cDoc PICTURE PesqPict( "DT6", "DT6_DOC" ) SIZE 40, 07 OF oPanel PIXEL 
	
	/* Serie Documento. */
	@ 034, 150 SAY RetTitle( "DT6_SERIE" ) SIZE 050,007 OF oPanel PIXEL
	@ 034, 190 MSGET cSerie PICTURE PesqPict( "DT6", "DT6_SERIE" ) VALID ExistCpo("DT6", cFilDco + cDoc + cSerie ) SIZE 25, 07 OF oPanel PIXEL 

	DEFINE SBUTTON FROM 85,201 TYPE 1 ACTION (oDlgDig:End(),nOpca:=1) ENABLE OF oDlgDig
	DEFINE SBUTTON FROM 85,238 TYPE 2 ACTION oDlgDig:End() ENABLE OF oDlgDig
ACTIVATE MSDIALOG oDlgDig CENTERED

If nOpca == 1
	If Empty( cFilDco ) .And. Empty( cDoc ) .And. Empty( cSerie )
		/* Troca o armazem e endereco de todos os documentos. */
		Aeval( aCols, { |x| 	( x[GdFieldPos("DUH_LOCAL")] := cLocal, x[GdFieldPos("DUH_LOCALI")] := cLocali ) } )
	Else
		/* Troca o armazem e endereco do documento informado. */
		Aeval( aCols, { |x| 	Iif( x[GdFieldPos("DT6_FILDOC")] == cFilDco .And.;
		                          x[GdFieldPos("DT6_DOC")]    == cDoc    .And.;
		                          x[GdFieldPos("DT6_SERIE")]  == cSerie, ( x[GdFieldPos("DUH_LOCAL")] := cLocal, x[GdFieldPos("DUH_LOCALI")] := cLocali ), "" ) } )
	EndIf
EndIf

Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tmsa780All� Autor � Robson Alves          � Data �24.06.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Marca / Desmarca todos os registros.                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tmsa780All()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nil                                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function Tmsa780All()

Local aArea  := { Alias(),Recno() }
Local lMarca :=  NIL

(TRB)->( dbGotop() )
While (TRB)->( !Eof() )
	lMarca := (TRB)->TRB_OK == cMarca

	RecLock("TRB", .F.)
	(TRB)->TRB_OK := If( lMarca, "", cMarca )
	MsUnLock()

	(TRB)->( dbSkip() )
EndDo

dbSelectArea( aArea[1] )
dbGoto( aArea[2] )

Return Nil