#include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"
#INCLUDE "TMSA115.Ch"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Program   �TMSA115   � Autor � Richard Anderson      � Data �29/10/2002  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Grupos de Regiao                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA115(ExpA1, ExpcN1)                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 - Array Contendo os Campos (Rot. Automatica)           ���
���          � ExpN1 - Opcao Selecionada (Rot. Automatica)                  ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � NIL                                                          ���
���������������������������������������������������������������������������Ĵ��
���Uso       � SigaTMS - Gestao de Transporte                               ���
���������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                           ���
���������������������������������������������������������������������������Ĵ��
��� 12/08/13 � Mauro Paladini�Conversao da rotina para o padrao MVC         ���
��� 06/12/13 � Mauro Paladini�Ajustes para funcionamento do Mile            ���
����������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/

Function TMSA115(aRotAuto, nOpcAuto)

Local oMBrowse	:= Nil
Local aAutoCab	:= {}

Local lTM115Mem  := ExistBlock("TM115Mem")
Local aMemUser   := {}

Private l115Auto := (ValType(aRotAuto) == "A")
Private aMemos   := {}
Private aRotina	 := MenuDef()

Default nOpcAuto	:= 0

If lTM115Mem
	aMemUser := ExecBlock( "TM115Mem", .F., .F. )
	If ValType( aMemUser ) == "A" .And. Len(  aMemUser ) > 0
		AEval( aMemUser, { |x| AAdd( aMemos, x ) } )
	EndIf
EndIf

If l115Auto
	Private aRotina := {	{Nil,"TMSA115Inc", 0 , 3},; //"Incluir"
							{Nil,"TMSA115Inc", 0 , 4},; //"Alterar"
							{Nil,"TMSA115Inc", 0 , 5} } //"Excluir"
	Private lMsHelpAuto := .T.
EndIf

If l115Auto
	aAutoCab   := Aclone( aRotAuto )
	FwMvcRotAuto( ModelDef(), 'DUY', nOpcAuto, { { 'MdFieldDUY', aAutoCab } } )  
Else
	oMBrowse	:= FwMBrowse():New()
	oMBrowse:SetAlias( 'DUY' )
	oMBrowse:SetDescription( STR0001 ) // Grupo de Regi~oes
	oMBrowse:Activate()
EndIf

Return .T.
     


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ModelDef � Autor � Mauro Paladini        � Data �12.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo de dados                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oModel Objeto do Modelo                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function ModelDef()

Local oModel	:= Nil
Local oStruDUY	:= Nil
Local bPreValid	:= Nil
Local bPosValid := { |oMdl| PosVldMdl(oMdl) }
Local bComValid := Nil
Local bCancel	:= Nil

oStruDUY := FWFormStruct(1,"DUY")  

oModel:= MpFormMOdel():New("TMSA115",  /*bPreValid*/ , bPosValid , /*bComValid*/ ,/*bCancel*/ )
oModel:AddFields("MdFieldDUY",Nil,oStruDUY,/*prevalid*/,,/*bCarga*/)
oModel:SetDescription(STR0001) 	// "Grupo de Regi�es"
oModel:GetModel("MdFieldDUY"):SetDescription(STR0001) // "Grupo de Regi�es"
oModel:SetPrimaryKey({ "DUY_FILIAL","DUY_GRPVEN" }) 

Return ( oModel )                   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ViewDef  � Autor � Mauro Paladini        � Data �09.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe browse de acordo com a estrutura                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oView do objeto oView                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function ViewDef()

Local oModel := FwLoadModel("TMSA115")
Local oView := Nil

oView := FwFormView():New()
oView:SetModel(oModel)
oView:AddField('VwFieldDUY', FWFormStruct(2,"DUY") , 'MdFieldDUY') 
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VwFieldDUY","TELA")

Return(oView)




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Mauro Paladini        � Data �09.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � MenuDef com as rotinas do Browse                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina array com as rotina do MenuDef                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 	ACTION "PesqBrw"         OPERATION 1 ACCESS 0   //"Pesquisar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.TMSA115" OPERATION 2 ACCESS 0   //"Visualizar"
ADD OPTION aRotina TITLE STR0005  	ACTION "VIEWDEF.TMSA115" OPERATION 3 ACCESS 0   //"Incluir"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.TMSA115" OPERATION 4 ACCESS 0   //"Alterar"
ADD OPTION aRotina TITLE STR0007 	ACTION "VIEWDEF.TMSA115" OPERATION 5 ACCESS 0   //"Excluir"

Return ( aRotina )


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PosVldMdl � Autor � Mauro Paladini        � Data �12/0820132���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de validacao da model (compatibilizacao)             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/

Static Function PosVldMdl(oMdl)

Local lRet := .T.

If oMdl <> Nil .And. oMdl:GetOperation() == MODEL_OPERATION_DELETE
	lRet := TMSA115Del()

Elseif 	oMdl <> Nil .And. ( oMdl:GetOperation() == MODEL_OPERATION_UPDATE .Or. oMdl:GetOperation() == MODEL_OPERATION_INSERT )
	lRet := TMSA115TOk( oMdl:GetOperation() )	
Endif

Return lRet



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �TMSA115Del� Autor � Richard Anderson      � Data �29/10/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de Tratamento da Exclusao                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function TMSA115Del()

Local aAreaAnt:= GetArea()
Local aAreaDT0:= DT0->(GetArea())
Local aRegiao := {}
Local cRegiao := ''
Local lExclui := .T.

//-- Verifica se o grupo foi usado numa estrutura
If ! Empty(DUY->DUY_GRPSUP)

	aRegiao := TmsNivSup( DUY->DUY_GRPVEN )

	If	! Empty(aRegiao)
		DUY->(DbSetOrder(1))
		If	DUY->(MsSeek(xFilial('DUY') + aRegiao[Len(aRegiao)])) .And. ! Empty(DUY->DUY_GRPSUP)
			cRegiao := DUY->DUY_GRPSUP
			If	cRegiao == 'MAINGR' .Or. DUY->(MsSeek(xFilial('DUY') + cRegiao)) .And. ! Empty(DUY->DUY_GRPSUP)
				lExclui := .F.
				Help(" ",1,"TMSA11501") // Grupo sendo usado em uma estrutura.
			EndIf
		EndIf
	EndIf

EndIf
//-- Se alguma tabela de frete utilizar a regiao como regiao de origem, a exclusao nao sera permitida
If	lExclui
	DT0->(DbSetOrder(2))
	If	DT0->(MsSeek(xFilial('DT0') + DUY->DUY_GRPVEN))
		Help('',1,'TMSA11503',, STR0002 + DT0->DT0_TABFRE + ' - ' + DT0->DT0_TIPTAB) //"Existem tabelas de frete utilizando esta regiao(DT0)" ### "Tabela: "
		lExclui := .F.
	EndIf
EndIf
//-- Se alguma tabela de frete utilizar a regiao como regiao de destino, a exclusao nao sera permitida
If lExclui
	DT0->(DbSetOrder(3))
	If	DT0->(MsSeek(xFilial('DT0') + DUY->DUY_GRPVEN))
		Help('',1,'TMSA11503',, STR0002 + DT0->DT0_TABFRE + ' - ' + DT0->DT0_TIPTAB) 	//"Existem tabelas de frete utilizando esta regiao(DT0)" ### "Tabela: "
		lExclui := .F.
	EndIf
EndIf
If lExclui
	lExclui := TMSA115TOk( MODEL_OPERATION_DELETE )
EndIf

RestArea(aAreaDT0)
RestArea(aAreaAnt)

Return(lExclui)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �TMSA115TOk� Autor � Robson Alves          � Data �17/01/2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Nao permite a alteracao/exclusao de regioes em rota.       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMSA115TOk( nOpc )

Local lOk      := .T.
Local aAreaDUN := DUN->(GetArea())
Local cGrpVen  := ""


If nOpc == MODEL_OPERATION_UPDATE
	//-- Posiciona devido ao campo de regiao coligada, que pode ter desposicionado
	DUY->(DbSetOrder(1))
	DUY->(MsSeek(xFilial('DUY')+M->DUY_GRPVEN))
EndIf	

If nOpc == MODEL_OPERATION_INSERT
	If ExistCpo('DUY',M->DUY_GRPVEN,1)
		Help("",1,"JAGRAVADO")
		lOk := .F.
	EndIf
EndIf	

If nOpc == MODEL_OPERATION_DELETE
	cGrpVen := DUY->DUY_GRPVEN
	DUN->(dbSetOrder(3))
	If DUN->(MsSeek(xFilial("DUN") + cGrpVen))
		Help(" ",1,"TMSA11502",,DUN->DUN_ROTEIR,5,1) // Grupo de regiao sendo utilizado na rota :
		lOk := .F.
	EndIf
EndIf

RestArea(aAreaDUN)

Return( lOk )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �TMSA115Whe� Autor � Raphael Zampieri      � Data �06/04/2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Nao permite a alteracao/exclusao de regioes em rota.       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMSA115Whe(cCampo)

Local lRet 	:= .T.
Local lMile       := IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT")

If !lMile

	l115Auto	:= IIF( Type("l115Auto") == "U" , .F. , l115Auto )
	
	Do Case
	
		Case AllTrim(cCampo) == "DUY_EST"
			lRet := IIF( IsInCallStack("TMSA120") .And. !l115Auto , .F. , Inclui )
		Case AllTrim(cCampo) == "DUY_ALQISS"
			lRet := .T.
		Case AllTrim(cCampo) == "DUY_CDRCOL"
		    lRet := .T.
		OtherWise
			If !Inclui
				DUN->(DbSetOrder(3))
				If DUN->(MsSeek(xFilial("DUN") + DUY->DUY_GRPVEN))
					lRet := .F.
				Else 
					lRet := .T.
				EndIf
			EndIf
	
	EndCase

EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA115Ini� Autor � Alex Egydio           � Data �10.04.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializador padrao p/o arq. de regioes                   ���
���          � Criamos esta funcao devido a necessidade de deslocar o     ���
���          � ponteiro do arq. DUY e retornar ao ponto de origem         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TmsA115Ini()

Local aAreaDUY := DUY->(GetArea())
Local cRet     := Posicione('DUY',1,xFilial('DUY')+DUY->DUY_CDRCOL,'DUY_DESCRI')

RestArea(aAreaDUY)

Return(cRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA115Vld� Autor � Alex Egydio           � Data �31.07.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes gerais                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TmsA115Vld()

Local aAreaDUY     := DUY->(GetArea())
Local lRet         := .T.
Local cCampo       := ReadVar()
Local cCodReg      := SuperGetMv("MV_CGRPREG",.F.,"")
Private __cEstReg  := ""
Private __cCodIbge := ""

If	cCampo == 'M->DUY_CDRCOL'

	If Empty(M->DUY_CDRCOL)
		M->DUY_REGCOL := Space(Len(DUY->DUY_DESCRI))
		M->DUY_EST    := Space(Len(DUY->DUY_EST))

		DUY->(DbSetOrder(1))
		If	DUY->(MsSeek(xFilial('DUY')+M->DUY_GRPSUP))
			M->DUY_EST := DUY->DUY_EST
		EndIf

	Else
		
		IF RTrim(M->DUY_CDRCOL) == RTrim(DUY_GRPVEN)
			lRet := .F.
			MsgInfo( STR0008 + RetTitle("DUY_GRPVEN") )
		Else
				
			DUY->(DbSetOrder(1))
			If DUY->(MsSeek(xFilial('DUY')+M->DUY_CDRCOL))
				M->DUY_REGCOL := DUY->DUY_DESCRI
				If	! Empty(DUY->DUY_EST)
					M->DUY_EST := DUY->DUY_EST
				EndIf
			Else
				Help('',1,'REGNOIS')
				lRet := .F.			
			EndIf
		Endif
		
	EndIf
		
	
ElseIf AllTrim(cCampo) == "M->DUY_EST"

	If AllTrim(FunName())=="TMSA120"
		lRet := Vazio() .Or. ExistCpo("SX5","12"+M->DUY_EST)
		If	M->DUY_CATGRP == StrZero(3,Len(DUY->DUY_CATGRP)) .And. lRet
			M->DUY_CODMUN := Space(Len(DUY->DUY_CODMUN))
			M->DUY_CDRCOL := Space(Len(DUY->DUY_CDRCOL))
			M->DUY_REGCOL := Space(Len(DUY->DUY_DESCRI))
			M->DUY_GRPVEN := IIF(Empty(&cCodReg),M->DUY_GRPVEN, Space(Len(DUY->DUY_GRPVEN)))
		EndIf
	Else
		lRet := ExistCpo("SX5","12"+M->DUY_EST)
	EndIf

ElseIf AllTrim(cCampo) == "M->DUY_CODMUN"

	If AllTrim(FunName())=="TMSA120"
		CC2->(dbSetOrder(1))
		If CC2->(dbSeek(xFilial('CC2')+M->DUY_EST+M->DUY_CODMUN))
			__cEstReg  := M->DUY_EST
			__cCodIbge := M->DUY_CODMUN
			cCodReg    := Iif(Empty(cCodReg),"",&(cCodReg))
			If !Empty(cCodReg) .And. M->DUY_CATGRP == StrZero(3,Len(DUY->DUY_CATGRP))
				M->DUY_GRPVEN := cCodReg
			EndIf
			M->DUY_DESCRI := PADR(CC2->CC2_MUN,TamSx3("DUY_DESCRI")[1])
		Else
			Help('',1,'REGNOIS')
			lRet := .F.
		EndIf
	Else
		lRet := ExistCpo("CC2",M->DUY_EST+M->DUY_CODMUN)
	EndIf

ElseIf AllTrim(cCampo) == "M->DUY_GRPVEN"
	lRet := ExistChav('DUY') .And. FreeForUse('DUY')
EndIf

RestArea(aAreaDUY)            

Return(lRet)
