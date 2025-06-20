#include "Protheus.ch"        
#include "MATR071.CH"

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Programa  � MATR071  � Autor � Carlos E. Chigres         � Data � 11/07/12 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de Entidades Bancarias                                 ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                          ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                          ���
�����������������������������������������������������������������������������Ĵ��
���   DATA   � DATA   � Programador�   Manutencao efetuada                    ���
�����������������������������������������������������������������������������Ĵ��
���  Marco A.�16/04/18� DMINA-2310 �Se remueven sentencias CriaTrab y se apli-���
���          �        �            �ca FWTemporaryTable(), para el manejo de  ���
���          �        �            �las tablas temporales.                    ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Function MATR071()

	Local oReport	:= Nil
	
	Private oTmpTable := Nil
	
	If FindFunction("TRepInUse") .And. TRepInUse()
		//������������������������Ŀ
		//�Interface de impressao  �
		//��������������������������
		oReport	:= ReportDef()
		oReport:PrintDialog()
	EndIf
	
	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil
	Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Paulo Augusto          � Data �28/06/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport,oSection1
Local cReport := "MATR071"
Local cTitulo := STR0010     // "Listagem de Entidades Bancarias"
Local cDescri := STR0011     // "Este relat�rio apresenta uma rela��o das Entidades Bancarias cadastradas." 

//--- Tamanho de Celulas
Local nTamBanco   := TamSx3("FJN_COD")[1] + 1
Local nTamAgenci  := TamSx3("FJN_AGENCI")[1] + 1
Local nTamDigit   := 3
Local nTamNome    := TamSx3("FJN_NOMAGE")[1]
Local nTamPostal  := Iif(cPaisLoc == "ARG",TamSx3("FJN_POSTAL")[1],'')
Local nTamEnder   := TamSx3("FJN_END")[1]
Local nTamMunicip := TamSx3("FJN_MUN")[1]
Local nTamProvinc := 4

Pergunte( "MATR71" , .F. )
                   
oReport := TReport():New( cReport, cTitulo, "MATR71" , { |oReport| ReportPrint( oReport, "TRB" ) }, cDescri )

//���������������������������������Ŀ
//� Define a 1a. secao do relatorio �
//�����������������������������������
oSection1 := TRSection():New( oReport,STR0002, {"TRB","FJN","FJO"},,/*Campos do SX3*/,/*Campos do SIX*/)    
oSection1:SetTotalInLine(.T.)                                                                                                                                                                                                                                                       
oReport:SetTotalInLine(.F.)                                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                                                                   
TRCell():New( oSection1, "FJN_COD"   	,"FJN"  , /*X3Titulo()*/  , /*Picture*/ , nTamBanco , /*lPixel*/ ,  {|| TRB->BANCO } ) 
TRCell():New( oSection1, "FJN_AGENCI" 	,"FJN"  , /*X3Titulo()*/  , /*Picture*/ , nTamAgenci , /*lPixel*/ , {|| TRB->AGENCI } ) 
TRCell():New( oSection1, "FJN_DVAGE"	,"FJN"	, /*X3Titulo()*/  , /*Picture*/ , nTamDigit  , /*lPixel*/ , {|| TRB->DIGITO } )	  
TRCell():New( oSection1, "FJN_NOMAGE" 	,"FJN"	, /*X3Titulo()*/  , /*Picture*/ , nTamNome   , /*lPixel*/ , {|| TRB->NOMEAG } )	
If cPaisLoc == "ARG"
	TRCell():New( oSection1, "FJN_POSTAL"  	,"FJN"	, /*X3Titulo()*/  , /*Picture*/ , nTamPostal , /*lPixel*/ , {|| TRB->POSTAL } )	              
EndIf
TRCell():New( oSection1, "FJN_END"	    ,"FJN" 	, /*X3Titulo()*/  , /*Picture*/ , nTamEnder  , /*lPixel*/ , {|| TRB->ENDER  } )                                            
TRCell():New( oSection1, "FJN_MUN"  	,"FJN" 	, /*X3Titulo()*/  , /*Picture*/ , nTamMunicip , /*lPixel*/ , {|| TRB->MUNICI } ) 
TRCell():New( oSection1, "FJN_PROV" 	,"FJN" 	, /*X3Titulo()*/  , /*Picture*/ , nTamProvinc , /*lPixel*/ , {|| TRB->PROVIN } ) 
TRCell():New( oSection1, "Qtd"  		,"   " 	,                 ,"@E 99.999"  , 5           , /*lPixel*/ , {|| 1 } )    

oSection1:SetNoFilter( {'FJN'} ) 

Return oReport

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint�Autor  �Paulo Augusto       � Data �  27/06/06   ���
��������������������������������������������������������������������������͹��
���Desc.     �Query de impressao do relatorio                              ���
��������������������������������������������������������������������������͹��
���Uso       � SIGAFIN                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport )

	Local oSection1	:= oReport:Section(1)
	Local oBreak1	:= Nil
	Local nOrder	:= oReport:Section(1):GetOrder()
	Local cDesFor	:= " "
	
	//��������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
	//����������������������������������������������������������������
	Local aCampos	:= {}
	Local aOrdem	:= {}
	
	Private cBancoDe  := mv_par01
	Private cBancoAte := mv_par02
	
	AADD( aCampos,{"AGENCI"  ,"C",TamSX3('FJN_AGENCI')[1],0 } )
	AADD( aCampos,{"DIGITO"  ,"C",TamSX3('FJN_DVAGE')[1] ,0 } )
	AADD( aCampos,{"NOMEAG"  ,"C",TamSX3('FJN_NOMAGE')[1],0 } )
	If cPaisLoc == "ARG"
		AADD( aCampos,{"POSTAL"  ,"C",TamSX3('FJN_POSTAL')[1],0 } )
	EndIf
	AADD( aCampos,{"ENDER"   ,"C",TamSX3('FJN_END')[1]   ,0 } )
	AADD( aCampos,{"MUNICI"  ,"C",TamSX3('FJN_MUN')[1]   ,0 } )
	AADD( aCampos,{"PROVIN"  ,"C",TamSX3('FJN_PROV')[1]  ,0 } )
	AADD( aCampos,{"BANCO"   ,"C",TamSX3('FJO_COD')[1]   ,0 } )
	AADD( aCampos,{"NOMBANK" ,"C",TamSX3('FJO_NOME')[1]  ,0 } )

	aOrdem := {"BANCO", "AGENCI"}
	
	//Creacion de Objeto
	oTmpTable := FWTemporaryTable():New("TRB")
	oTmpTable:SetFields( aCampos )
	oTmpTable:AddIndex("I1", aOrdem)

	//Creacion de la tabla
	oTmpTable:Create()

	Processa( {|lEnd| GrvFJN() },,OemToAnsi(STR0013) ) // "Preparando Temporario..."
	
	//��������������������������������������������������������������Ŀ
	//� Inicia rotina de impressao                                   �
	//����������������������������������������������������������������
	dbSelectArea("TRB")
	dbGoTop()
	
	cDesFor := TRB->BANCO + " - " + TRB->NOMBANK
	
	oSection1:Cell("Qtd"):Hide()
	
	oSection1:SetOrder(1)
	oSection1:SetLineCondition( {|| .T. } )
	
	oBreak1 := TRBreak():New( oSection1, oSection1:Cell("BANCO"),,.F.)  
	
	oBreak1:SetTitle({|| STR0014 + cDesFor }) // "Resumo pelo Banco : "
	
	oBreak1:OnPrintTotal({|| cDesFor := TRB->BANCO + " - " + TRB->NOMBANK } )
	
	TRFunction():New(oSection1:Cell("Qtd"  )  , , "COUNT" , oBreak1, , , , .F. ,  )
	
	oSection1:NoUserFilter()
	
	oSection1:Print()

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GrvSldClie� Autor � Lucas                � Data � 05/02/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grabar uno archivo transit�rio (TRB) con los salods de los ���
���          � Clientes. Baseado en las leyes y denificiones de Localiza- ���
���          � ciones de los paises del ConeSul y Andinos.                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GrvSldClie(ExpC1,ExpC2,ExpN1,ExpL1,ExpC3)                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 := C�digo Inicial del Cliente                        ���
���          � ExpC2 := C�digo Final del Cliente                          ���
���          � ExpN1 := Selecci�n del Tipo de T�tulos                     ���
���          � ExpL1 := Identifica lo Cierre por Vendedor o Cliente		  ���
���          � ExpL2 := Imprimir con Historico o No (Saldo > 0)    		  ���
���          � ExpC3 := Nombre do Relat�rio. Ejemplo: "FINR152"           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Localizacoes ConeSul y Andinos                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function GrvFJN()

dbSelectArea("FJN")
dbSetOrder( 1 )

ProcRegua( FJN->( RecCount() ) )

If Empty( cBancoDe )
   dbGoTop()
Else
   dbSeek( xFilial("FJN")+cBancoDe , .T. )
EndIf

While !Eof() .And. ( FJN_FILIAL == xFilial("FJN") )

    dbSelectArea("TRB")

    RecLock("TRB",.T.)

    TRB->AGENCI  :=  FJN->FJN_AGENCI
    TRB->DIGITO  :=  FJN->FJN_DVAGE
    TRB->NOMEAG  :=  FJN->FJN_NOMAGE
    If cPaisLoc == "ARG"
    	TRB->POSTAL  :=  FJN->FJN_POSTAL
    EndIf
    TRB->ENDER   :=  FJN->FJN_END
    TRB->MUNICI  :=  FJN->FJN_MUN
    TRB->PROVIN  :=  FJN->FJN_PROV
    TRB->BANCO   :=  FJN->FJN_COD
    TRB->NOMBANK :=  Posicione( "FJO", 1, xFilial("FJO") + FJN->FJN_COD, "FJO_NOME" )
    
    MsUnLock()

    dbSelectArea("FJN")
    dbSkip()
    
    If FJN_COD > cBancoAte
       Exit
    EndIf
    
Enddo

Return