#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA850.CH"

/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o    	� GPEA850    � Autor � Leandro Drumond       	      � Data � 18/06/12 ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o 	� Manutencao de Complementos Trabalhistas                      			���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   	� GPEA850()                                                    			���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      	� Generico ( DOS e Windows )                                   			���
���������������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               			���
���������������������������������������������������������������������������������������Ĵ��
���Programador  � Data     � FNC			�  Motivo da Alteracao                      ���
���������������������������������������������������������������������������������������Ĵ��
��� Cecilia C.  � 19/05/14 �TPPCSB          �Incluido o fonte da 11 para a 12 e efetuada���
���             �          �                �a limpeza.                                 ���
��� Sidney O.   � 29/07/14 �TPVN08          �Alterada a funcao Gp850VlPer. Ajuste na    ���
���             �          �                �validacao das datas.                       ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/

Function GPEA850()

Local oMBrowse
Local cFiltraRh
   
oMBrowse := FWMBrowse():New()

oMBrowse:SetAlias("RF1")
oMBrowse:SetDescription(OemToAnsi(STR0001)) //'Cadastro de Complementos Trabalhistas'

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
cFiltraRh := CHKRH("GPEA850","RF1","1")
oMBrowse:SetFilterDefault( cFiltraRh )

oMBrowse:Activate()

Return

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � ModelDef 		�Autor�  Leandro Drumond  � Data �18/06/2012�
�����������������������������������������������������������������������Ĵ
�Descri��o �Regras de Modelagem da gravacao.                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA850                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function ModelDef()

Local oModel
Local oStructRF1

// Criacao do Objeto de Modelagem de dados da tabela RF1 //
oModel     := MPFormModel():New("GPEA850", NIL, NIL, {|oModel| GPEA850Commit(oModel)})
oModel:SetDescription( OemToAnsi(STR0001) ) //'Cadastro de Complementos Trabalhistas'

// Estrutura de campos do Model //
oStructRF1 := FWFormStruct(1, "RF1")
oStructRF1:RemoveField("RF1_FILIAL")

oModel:AddFields("GPEA850_RF1", NIL, oStructRF1)
oModel:SetPrimaryKey({"RF1_IDCMPL"})

oModel:GetModel( "GPEA850_RF1" ):SetDescription( OemToAnsi(STR0001) ) //'Cadastro de Complementos Trabalhistas'

Return( oModel )

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � ViewDef  		�Autor�  Leandro Drumond  � Data �18/06/2012�
�����������������������������������������������������������������������Ĵ
�Descri��o �Regras de Interface com o Usuario                           �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA850                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�       
�������������������������������������������������������������������������*/
Static Function ViewDef()

Local oView 
Local oModel
Local oStructRF1

// Criacao da Interface //
oView := FWFormView():New()

// Vincular o View ao Model //
oModel := FWLoadModel("GPEA850")	
oStructRF1 := FWFormStruct(2, "RF1")

oStructRF1:RemoveField("RF1_FILIAL")

oView:SetModel(oModel)
oView:AddField("GPEA850_RF1", oStructRF1)

oView:CreateHorizontalBox("FIELDS", 100)

oView:SetOwnerView("GPEA850_RF1", "FIELDS")
	
Return oView

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � GPEA850Commit  �Autor�  Leandro Drumond  � Data �18/06/2012�
�����������������������������������������������������������������������Ĵ
�Descri��o �Gravacao das informacoes com as validacoes pertinentes      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA850                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function GPEA850Commit(oModel)

Local nOperation

nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE

	If GP850ValPer(oModel)
      	FWFormCommit(oModel)
    EndIf   

// Tratamento de exclus�o
ElseIf nOperation == MODEL_OPERATION_DELETE
	
	If Gpa850VldDel(oModel)
		FWFormCommit(oModel)
	EndIf

EndIf
	
Return( .T. )

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � Gpa850VldDel   �Autor�  Leandro Drumond  � Data �27/07/2012�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valida delecao dos registros							    �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA850                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function Gpa850VldDel(oModel)
Local aArea		:= GetArea()
Local cIdCmpl	:= ''
Local oRF1Struct:= oModel:GetModel( "GPEA850_RF1" )
Local lRet 		:= .T.

cIdCmpl := oRF1Struct:GetValue( "RF1_IDCMPL" )

DbSelectArea('RFC')
DbSetOrder(RetOrder('RFC','RFC_IDCMPL'))

If DbSeek(cIdCmpl)
	lRet := .F.
	MsgAlert(STR0008) //"Existem registros de RRA gerados para este complemento. Exclus�o n�o poder� ser realizada."
EndIf

RestArea(aArea)

Return lRet

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � Gp850VlPer	  �Autor� Equipe Inovacao RH  � Data �09/08/2013�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valida intervalo de periodo                                 �
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA850                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Function Gp850VlPer(dDataIni, dDataFim)
Local lRet := .T.

If !Empty(dDataIni)           
    If Len(Alltrim(dDataIni)) < 6
        Return(.F.)
    Else
        If Val(Left(dDataIni,2)) < 1 .OR. Val(Left(dDataIni,2)) > 12
            Return(.F.)                                              
        EndIf
    EndIf
EndIf

If !Empty(dDataFim)
    If Len(Alltrim(dDataFim)) < 6
        Return(.F.)
    Else
        If Val(Left(dDataFim,2)) < 1 .OR. Val(Left(dDataFim,2)) > 12
            Return(.F.)                                              
        EndIf
    EndIf

    If Right(dDataFim,4)+Left(dDataFim,2) < Right(dDataIni,4)+Left(dDataIni,2) 
        lRet := .F.
    EndIf                
EndIf

Return(lRet)
  
/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � GPEA850ValPer �Autor� Equipe Inovacao RH � Data �12/08/2013�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valida informacoes de periodo inicial e final               �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA850                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function GP850ValPer(oModel)
Local oRF1Struct:= oModel:GetModel( "GPEA850_RF1" )
Local dDataIni := oRF1Struct:GetValue( "RF1_AAMMI" ) 
Local dDataFim := oRF1Struct:GetValue( "RF1_AAMMF" ) 
Local lRet := .T.

If !Empty(dDataIni) .And. !Empty(dDataFim) 
    If Right(dDataFim,4)+Left(dDataFim,2) < Right(dDataIni,4)+Left(dDataIni,2) 
        MsgAlert( OemToAnsi( STR0010 ), OemToAnsi( STR0009 ) )  
        lRet := .F.
    EndIf
EndIf                             
Return( lRet )

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Leandro Drumond  � Data �18/06/2012�
�����������������������������������������������������������������������Ĵ
�Descri��o �Criacao do Menu do Browse.                                  �
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA850                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar'
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.GPEA850" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.GPEA850" 		OPERATION 3 ACCESS 0				//'Incluir'
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.GPEA850" 		OPERATION 4 ACCESS 0				//'Alterar'  
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.GPEA850" 		OPERATION 5 ACCESS 0				//'Excluir'
	ADD OPTION aRotina TITLE STR0007  ACTION 'VIEWDEF.GPEA850'		OPERATION 9 ACCESS 0 				//"Copiar" 

Return aRotina     

