#INCLUDE "GEMA030.ch"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GEMA030   �Autor  �Telso Carneiro      � Data �  01/02/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de Grupo de Participantes                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAGEM                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function GEMA030()

Local aArea := GetArea()

Private cCadastro:= OemToAnsi(STR0001)  //'Cadastro de Grupo de Participantes'
Private aRotina := MenuDef()
                
// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")
// alteracoes de dicionario
AjustaSX()

DbSelectArea("LE7")
LE7->(dbSetOrder(1)) // LE7_FILIAL+LE7_GRUPO+LE7_COD+LE7_LOJA
DbGoTop()
mBrowse(006,001,022,075,"LE7")

RestArea(aArea)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GM030Telas� Autor � Telso Carneiro        � Data � 01/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela Cadastro de Grupo de Participantes					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GM030TELAS(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Alias do arquivo                                   ���
���          � ExpN1 - Numero do registro                                 ���
���          � ExpN2 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGEM                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function GM030Telas(cAlias,nReg,nOpc)

Local oDlg
Local nI    := 0
Local nOpcao:= 0          
Local aSize	:= MsAdvSize()
Local oGetCar  
Local aArea := GetArea()

Private bCampo:= {|nCPO| Field( nCPO ) }
Private aTELA[0][0]
Private aGETS[0]

DbSelectArea("LE7")
LE7->(dbSetOrder(1)) // LE7_FILIAL+LE7_GRUPO+LE7_COD+LE7_LOJA

RegToMemory( "LE7", nOpc == 3 )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL   //'Cadastro de Grupo de Participantes'

oGetCar:=MsMGet():New("LE7",nReg,nOpc,,,,,{015,000,200,350},,,,,,oDlg)
oGetCar:oBox:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela),(nOpcao:= 1,oDlg:End()),)},{|| nOpcao:= 2, oDlg:End()}) CENTERED

If nOpc <> 2 .AND. nOpcao == 1
	If nOpc == 3 .Or. nOpc == 4
		GMA030Gra(nOpc)
	ElseIf nOpc == 5
		GMA030Dele()
	EndIf
EndIf

If __lSX8
	If nOpcao == 1
		ConfirmSX8()
	Else
		RollBackSX8()
	Endif
Endif

RestArea(aArea)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GMA030Gra � Autor � Telso Carneiro        � Data � 01/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Cartorios                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GMA030Gra(ExpN1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao do Browse                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGEM                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function GMA030Gra(nOpc)

Local lRecLock := .F.
Local nI       := 0
Local aArea    := GetArea()

If nOpc == 3
	lRecLock:= .T.
EndIf

DbSelectArea("LE7")
LE7->(dbSetOrder(1)) // LE7_FILIAL+LE7_GRUPO+LE7_COD+LE7_LOJA

Begin Transaction
	RecLock("LE7",lRecLock)
	M->LE7_FILIAL:=XFILIAL("LE7")
	For nI := 1 TO FCount()
		FieldPut(nI,M->&(Eval(bCampo,nI)))
	Next nI
	MsUnLock()      
End Transaction

RestArea(aArea)
	
Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � GMA030Dele � Autor � Telso Carneiro     � Data � 01/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Exclusao de registros do Cadastro de Grupos               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � GMA010Dele()                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � SIGAGEM                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function GMA030Dele()

Local lReturn:= .T.
Local cFil   := xFilial("LE7")
Local aArea  := GetArea()

//�������������������������������������������������Ŀ
//� Cria Indice Condicional nos arquivos utiLizados �
//���������������������������������������������������
Local cIndex1:= CriaTrab(Nil,.F.)
Local cKey   := LIQ->(IndexKey())	
Local cFiltro

IF !EMPTY(cFil)
	cFiltro:= 'LIQ->LIQ_FILIAL == "'+cFil+'" .And. '    
	cFiltro+= 'LIQ->LIQ_PARTRE == "'+LE7->LE7_COD+'" .OR. '            
	cFiltro+= 'LIQ->LIQ_PARTPA == "'+LE7->LE7_COD+'"'            
Else
	cFiltro:= 'LIQ->LIQ_PARTRE == "'+LE7->LE7_COD+'" .OR. '            
	cFiltro+= 'LIQ->LIQ_PARTPA == "'+LE7->LE7_COD+'"'            
Endif

IndRegua("LIQ",cIndex1,cKey,,cFiltro,OemToAnsi(STR0007)) //"Selecionando Registros.."

LIQ->(DbGotop())
IF !LIQ->(EOF())
	lReturn:= .F. 
Endif	

RetIndex("LIQ")
dbClearFilter() //Set Filter to

DbSelectARea("LE7")

If lReturn
	Begin Transaction
		RecLock("LE7",.F.)
		LE7->(DbDelete())
		MsUnlock()			
	End Transaction   
	LE7->(DbSkip())
Else      
	Help("",1,"GEM_EMPEXT",,OemToAnsi(STR0008),1)  //"Existe Empreendimentos cadastrados associados a esta informacao."
EndIf

RestArea(aArea)

Return

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �05/12/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina  := {{OemToAnsi(STR0002),"AxPesqui"  ,0 ,1,,.F.},;  //'Pesquisar'
				   {OemToAnsi(STR0003),"GM030TELAS",0 ,2},;  //'Visualizar'
				   {OemToAnsi(STR0004),"GM030TELAS",0 ,3},;  //'Incluir'
				   {OemToAnsi(STR0005),"GM030TELAS",0 ,4},; //'Alterar'
				   {OemToAnsi(STR0006),"GM030TELAS",0 ,5} } //'Excluir'
Return(aRotina)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � AjustaSX   � Autor � Wilker Valladares  � Data � 23/05/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Ajusta Dicionario                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � AjustaSX()                                                ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � SIGAGEM                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function AjustaSX()
Local aArea	:= GetArea()
Local cCampoX7  := "LE7_COD   "
Local cCampoXB  := "LE7_EMPFIL"
Local cSeqX7	 := "001"

//:: SX7 - Adicionar Gatilho
SX7->( dbSetOrder(1) )
if ! SX7->( dbSeek(cCampoX7+cSeqX7) )
	RecLock("SX7", .T. )
	SX7->X7_CAMPO 	 	:= cCampoX7
	SX7->X7_SEQUENC	:= cSeqX7
	SX7->X7_REGRA 		:= "SA2->A2_LOJA"
	SX7->X7_CDOMIN 	:=	"LE7_LOJA"
	SX7->X7_ALIAS 		:= "SA2"
	SX7->X7_TIPO 		:= "P"
	SX7->X7_SEEK 		:= "S"     
	SX7->X7_ORDEM     := 1
	SX7->X7_CHAVE 		:= "XFILIAL('SA2')+M->LE7_COD"
	SX7->X7_PROPRI 	:= "S"
	SX7->( MsUnLock() )
endif
	                   
//:: SX3	- Configurar Gatilho
SX3->( dbSetOrder(2) )
If SX3->( dbSeek(cCampoX7) )
	RecLock("SX3",.F.)
	SX3->X3_TRIGGER := "S"
	SX3->( MsUnLock() )
Endif
                             
//:: SX3 - Incluir nova pesquisa F3
SX3->( dbSetOrder(2) )
If SX3->( dbSeek(cCampoXB) )
	RecLock("SX3",.F.)
	SX3->X3_F3 := "L33"
	SX3->( MsUnLock() )
Endif
                                                                  
//:: SX3 - LE7_GRUPO
SX3->( dbSetOrder(2) )
If SX3->( dbSeek("LE7_GRUPO") )
	RecLock("SX3",.F.)
	SX3->X3_VALID := 'ExistChav("LE7",M->LE7_GRUPO+M->LE7_COD+M->LE7_LOJA,1)'
	SX3->( MsUnLock() )
Endif
                
//:: SX3 - LE7_COD
SX3->( dbSetOrder(2) )
If SX3->( dbSeek("LE7_COD") )
	RecLock("SX3",.F.)
	SX3->X3_VALID := 'ExistChav("LE7",M->LE7_GRUPO+M->LE7_COD+M->LE7_LOJA,1) .AND. ExistCpo("SA2",M->LE7_COD,1)'
	SX3->( MsUnLock() )
Endif

//:: SX3 - LE7_LOJA
SX3->( dbSetOrder(2) )
If SX3->( dbSeek("LE7_LOJA") )
	RecLock("SX3",.F.)
	SX3->X3_VALID := 'ExistChav("LE7",M->LE7_GRUPO+M->LE7_COD+M->LE7_LOJA,1) .AND. ExistCpo("SA2",M->LE7_COD+M->LE7_LOJA,1)'
	SX3->( MsUnLock() )
Endif

//:: SX3 - LE7_EMPFIL
SX3->( dbSetOrder(2) )
If SX3->( dbSeek("LE7_EMPFIL") ) .And. SX3->X3_TAMANHO <> Len(cFilAnt)
	RecLock("SX3",.F.)
	SX3->X3_TAMANHO := Len(cFilAnt)
	SX3->X3_GRPSXG  := "033"
	SX3->( MsUnLock() )
	X31UpdTable( "LE7" )
Endif

//:: SXB - Incluir Pesquisa no SXB
GEMAtuSXB()

RestArea( aArea )
Return Nil


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � GEMAtuSXB  � Autor � Wilker Valladares  � Data � 23/05/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Exclusao de registros do Cadastro de Grupos               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � GMA010Dele()                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � SIGAGEM                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function GEMAtuSXB()
//  XB_ALIAS XB_TIPO XB_SEQ XB_COLUNA XB_DESCRI XB_DESCSPA XB_DESCENG XB_CONTEM 
Local aSXB   := {}                                       
Local aEstrut:= {}
Local i      := 0
Local j      := 0

aEstrut:= {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM"}
Aadd(aSXB,{"L33   ","1","01","DB","Filiais","Sucursales","Branches","SM0"})
Aadd(aSXB,{"L33   ","2","01","01","C�digo","Codigo","Code",""})
Aadd(aSXB,{"L33   ","4","01","01","C�digo","Codigo","Code","M0_CODFIL"})
Aadd(aSXB,{"L33   ","4","01","02","Empresa","Empresa","Empresa","M0_NOME"})
Aadd(aSXB,{"L33   ","4","01","03","Filial","Filial","Filial","M0_FILIAL"})
Aadd(aSXB,{"L33   ","4","01","04","Municipio","Municipios","City","M0_CIDENT"})
Aadd(aSXB,{"L33   ","5","01","","","","","SM0->M0_CODFIL"})
Aadd(aSXB,{"L33   ","6","01","","","","","SM0->M0_CODIGO=M->LE7_EMPRES"})

dbSelectArea("SXB")
dbSetOrder(1) // XB_ALIAS + XB_TIPO + XB_SEQ + XB_COLUNA
For i:= 1 To Len(aSXB)
	If !Empty(aSXB[i][1])
		If !dbSeek(aSXB[i,1]+aSXB[i,2]+aSXB[i,3]+aSXB[i,4])
			RecLock("SXB",.T.)
	   
			For j:=1 To Len(aSXB[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSXB[i,j])
				EndIf
			Next j
	  
			dbCommit()        
			MsUnLock()
		EndIf
	EndIf
Next i
Return(.T.)
