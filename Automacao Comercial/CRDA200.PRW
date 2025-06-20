#INCLUDE "CRDA200.CH"
#INCLUDE "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRDA200   � Autor �Marcos R. Andrade      � Data �29.11.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastro de motivo para liberacao do uso do vale compra     ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Campanha de Fidelizacao             					      ���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          

Function CRDA200                   

Private aRotina := MenuDef()

Private cCadastro := STR0006 //Motivo de Liberacao
DbSelectArea("MAW")   
dbSetOrder(2) 

DbGotop() 
mBrowse( 06, 01, 15, 75, "MAW" )

Return 

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Conrado Q. Gomes      � Data � 13.12.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CRDA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
	Local aRotina := {	{ STR0001	,"AxPesqui"	,0	,1	,0	,.F.	}	,; 	//"Pesquisar"
						{ STR0002	,"AxVisual"	,0	,2	,0	,.T.	}	,; 	//"Visualizar"
						{ STR0003	,"AxInclui"	,0	,3	,0	,.T.	}	,; 	//"Incluir"
						{ STR0004	,"AxAltera"	,0	,4	,0	,.T.	}	,; 	//"Alterar"
						{ STR0005	,"Crd200Del",0	,0	,0	,.T.	}	}  	//"Excluir"
Return(aRotina)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRD200Del � Autor �Marcos R. Andrade      � Data �29.11.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Exclusao do motivo da liberacao do uso do vale compra       ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Campanha de Fidelizacao             					      ���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          
Function Crd200Del(cAlias,nReg,nOpc)

If Crd200CanDel()
	AxDeleta(cAlias,nReg,nOpc,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL)
Else
	Help(" ",1,"NODELETA")	
Endif

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRD200CanDel� Autor �Marcos R. Andrade    � Data �29.11.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da exclusao do motivo da liberacao                ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Campanha de Fidelizacao             					      ���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                          

Function Crd200CanDel()

Local lRet 		:= .T.
Local cAliasMAZ	:= "MAZ"


#IFDEF TOP
	Local cQuery	:= ""
	Local lQuery	:= .F.
#ELSE
	Local cIndMAZ	:= ""		
	Local cKey		:= ""	
	Local nIndMAZ	:= 0
#ENDIF	

#IFDEF TOP

    lQuery := .T.
    
    cAliasMAZ := "QRYMAZ"
    
    cQuery := "SELECT COUNT(*) QTDMAZ "
    cQuery += " FROM "
    cQuery += RetSqlName("MAZ")+ " MAZ "
    cQuery += " WHERE "
    
    cQuery += "MAZ_FILIAL = '" + xFilial( "MAZ" ) +"' AND "
    cQuery += "MAZ_CODMOT = '" + MAW->MAW_CODIGO +"' AND "    
    cQuery += "MAZ.D_E_L_E_T_ = ' ' "
    
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasMAZ,.F.,.T.)

	If (cAliasMAZ)->QTDMAZ > 0
		lRet := .F.
	Endif	

	dbCloseArea()
	
	dbSelectArea("MAZ")
	
#ELSE
                                 
	dbSelectArea( "MAZ" )
	dbSetOrder( 1 )
	cIndMAZ := CriaTrab( NIL, .F.)

	cKey      := "MAZ_FILIAL+MAZ_CODMOT"

	IndRegua( "MAZ", cIndMAZ, cKey)
	nIndMAZ := RetIndex( "MAZ" )
	dbSetIndex( cIndMAZ + OrdBagExT() )
	dbSetOrder( nIndMAZ + 1 )	

    If MAZ->( DbSeek(xFilial("MAZ")+ MAW->MAW_CODIGO ) )
		lRet := .F.
	Endif	
 
	dbSelectArea("MAZ")
	dbClearFilter()
	RetIndex("MAZ")
	Ferase(cIndMAZ+OrdBagExt())
                          
#ENDIF

Return(lRet)





