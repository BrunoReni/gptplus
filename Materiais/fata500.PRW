#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"
#INCLUDE "FATA500.CH"
#INCLUDE 'FWMVCDEF.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATA500   �Autor  �Vendas Clientes     � Data �  22/11/2007 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina usada para realizar manueten��o na tabela CC3.      ���
�������������������������������������������������������������������������͹��
���Uso       �FATA500                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FATA500(aCC3Master,nOperation)

Local oBrowse	:= Nil
Local oModel	:= Nil
Local aAutoRot	:= {}

Private cCadastro	:= STR0001	//"Manutencao  - CNAE" 

Default aCC3Master	:= {}
Default nOperation	:= MODEL_OPERATION_INSERT

If Empty( aCC3Master ) 
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('CC3')                                       
	oBrowse:SetDescription(STR0001)
	oBrowse:Activate()
Else
	oModel := ModelDef()
	aAdd(aAutoRot,{"CC3MASTER",aCC3Master})
	FwMvcRotAuto(oModel,'CC3',nOperation,aAutoRot,/*lSeek*/,.T.) 
EndIf

Return .T.       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Vendas CRM          � Data �  22/11/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina usada para realizar manueten��o na tabela CC3       ���
�������������������������������������������������������������������������͹��
���Uso       �  SIGAFAT                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
				  
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FATA500'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FATA500'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FATA500'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FATA500'	OPERATION 5	ACCESS 0				
					
Return(aRotina)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados do grupo de atendimento (MVC)      ���
�������������������������������������������������������������������������͹��
���Uso       �FATA500                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel	:= Nil
Local oStruCC3	:= FWFormStruct(1,'CC3', /*bAvalCampo*/,/*lViewUsado*/ )
Local bPosValid	:= {| oModel | FT500PValid( oModel ) }		//Gravacao dos dados

oModel := MPFormModel():New('FATA500', /*bPreValidacao*/,bPosValid,/*bCommit*/,/*bCancel*/)
oModel:AddFields('CC3MASTER',/*cOwner*/,oStruCC3, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetPrimaryKey({'CC3_FILIAL'},{'CC3_COD'})
oModel:SetDescription(STR0001)

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Vendas CRM          � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro de grupo de atendimento em ���
���          �MVC.                                                        ���
�������������������������������������������������������������������������͹��
���Uso       �FATA500                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()   

Local oView	  	:= Nil
Local oModel	:= FWLoadModel('FATA500')
Local oStruCC3	:= FWFormStruct( 2,'CC3')  
   
oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_CC3',oStruCC3,'CC3MASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_CC3','TELA') 
  
Return oView

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  FT500PValid � Autor  �Vendas CRM         � Data �  21/09/10  ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco executado na validacao dos dados do formulario.		  ���
�������������������������������������������������������������������������͹��
���Uso       �FATA500                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FT500PValid( oModel )

Local lRetorno 		:= .T.
Local aArea			:= GetArea()
Local nOperation	:= oModel:GetOperation()

If nOperation == MODEL_OPERATION_DELETE
	lRetorno := FT500VdDel("CC3", CC3->( Recno() ), nOperation)
EndIf

RestArea( aArea )

Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FT500VdDel �Autor  �Vendas Clientes     � Data �  22/11/2007 ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina usada para valida a exclusao de registros do CNAE.   ���
�������������������������������������������������������������������������͹��
���Uso       �SIGAFAT                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FT500VdDel(cAlias, nReg, nOpc)

Local cTemp		:= GetNextAlias()
Local lDeleta	:= .T.
Local aArea		:= GetArea()
Local cCodCNAE	:= CC3->CC3_COD
Local aRelac	:= {}
Local nX		:= 0
Local cQuery	:= "" 

//�������������������������������������������������������Ŀ
//�Monta lista de campos e tabelas que se relacionam com o�
//�CNAE, onde:                                            �
//�[1] = Alias                                            �
//�[2] = Campo que referencia o codigo do cnae            �
//�[3] = Indice pelo campo do CNAE, quando houver (so DBF)�
//���������������������������������������������������������
AAdd(aRelac,{"ACH", "ACH_CNAE"	, Nil}) 
AAdd(aRelac,{"SUS", "US_CNAE"	, Nil})
AAdd(aRelac,{"SA1", "A1_CNAE"	, Nil})

For nX := 1 To Len( aRelac )
	If lDeleta .And. (aRelac[nX][1])->(FieldPos(aRelac[nX][2])) > 0
		cQuery	:= "SELECT COUNT (*) AS TOTAL FROM " + RetSqlName(aRelac[nX][1])
		cQuery	+= " WHERE D_E_L_E_T_ = '' AND " + aRelac[nX][2] + " = '" + cCodCNAE + "'" 
		cQuery := ChangeQuery( cQuery )
		
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cTemp,.T.,.T.)
		
		If (cTemp)->TOTAL > 0
			lDeleta := .F.
		EndIf
		
		(cTemp)->( DBCloseArea() )
	EndIf
Next nX 

If !lDeleta
	Help(" ",1,"NODELETA",,STR0007 + CRLF + STR0008,2,0)//"Este registro est� associado a algum outro"###" cadastro"
EndIf

Return( lDeleta )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft500Psq  �Autor  �Vendas Clientes     � Data �  22/11/2007 ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta tela para que seja informada a palavra a ser         ���
���          � pesquisada.                                                ���
�������������������������������������������������������������������������͹��
���Uso       �SIGAFAT                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft500Psq()

Local aArea		:= GetArea()
Local cPesquisa	:= Space(100)
Local cQualCnae	:= Space(9)
Local lRet		:= .F.
Local oDlg		:= Nil

DEFINE MSDIALOG oDlg TITLE STR0009 From 000,000 TO 100,380 OF oMainWnd PIXEL //"CNAE - Pesquisa Avan�ada"

@ 004,002 TO 030,190 TITLE STR0010 //"Informe a palavra a ser pesquisada:"

@ 012,004 Get cPesquisa Picture "@!" Size 184,10 Of Odlg Pixel 
	
@ 035,075 Button STR0011 Size 50,10 OF oDlg PIXEL Action Ft500Pesq(cPesquisa,@cQualCnae,@oDlg) //"&Confirma"
@ 035,135 Button STR0012 Size 50,10 OF oDlg PIXEL Action oDlg:End() //"Cance&la"
	
ACTIVATE MSDIALOG oDlg CENTER

RestArea(aArea)

//�����������������������������������������������������Ŀ
//�Posiciona o CC3 para que a pesquisa do SXB recupere o�
//�registro localizado pelo usuario                     �
//�������������������������������������������������������
If !Empty(cQualCnae)
	CC3->(DbSetOrder(1))
	If CC3->(DbSeek(xFilial("CC3")+cQualCnae))
		lRet := .T.
	EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft500Pesq �Autor  �Vendas Clientes     � Data �  22/11/2007 ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria query para que seja feita a pesquisa com a palavra    ���
���          � informada e caso retorno seja verdadeiro mostra as         ���
���          � ocorrencias encontrdas.                                    ���
�������������������������������������������������������������������������͹��
���Uso       �SIGAFAT                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft500Pesq(cPesquisa,cQualCnae,oDlg)

Local cTemp			:= GetNextAlias()
Local aCnae			:=	{}
Local nCnae			:=	1
Local oCnae			:= Nil	
Local nOcorrencia	:=	0
Local lRetorno 		:= .T.

cQuery := "SELECT CC3_COD,CC3_DESC FROM " + RetSqlName("CC3")
cQuery += " WHERE"
cQuery += " CC3_FILIAL = '" + xFilial("CC3") + "' AND"
cQuery += " D_E_L_E_T_ = ''"   

If !("DB2" $ TCGetDB())
	cQuery += " AND LOWER(CC3_DESC) LIKE '%"+AllTrim(RetSqlAce(cPesquisa))+"%'"
Else 
	cQuery += " AND UPPER(CC3_DESC) LIKE '%"+AllTrim(UPPER(cPesquisa))+"%'"
EndIf

cQuery := ChangeQuery( cQuery )

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cTemp,.T.,.T.)

While (cTemp)->( !Eof() )

	If !Empty(CC3_COD)
		Aadd(aCnae,{CC3_COD,CC3_DESC})
		nOcorrencia++
	Endif		

	(cTemp)->( DbSkip() )

EndDo

(cTemp)->( DbCloseArea() )

If	Len(aCnae)==0
    MsgAlert(STR0013,STR0014) //"Nenhuma Ocorr�ncia encontrada com a palavra digitada."###
    lRetorno := .F.
Endif 

If lRetorno

	DEFINE MSDIALOG oDlgRe TITLE STR0015 From 200,001 TO 422,600 OF oMainWnd PIXEL //"Resultado da Pesquisa"
	
	@ 006,002 ListBox oCnae VAR nCnae Fields Header STR0016,STR0017 Size 295,080 PIXEL OF oDlgRe On dblClick(cQualCnae:=aCnae[oCnae:nAt][1],(oDlgRe:End()),Close(oDlg)) //"C�digo"###"Descri��o"
	oCnae:SetArray(aCnae)
	oCnae:bLine :={|| {aCnae[oCnae:nAt][1],aCnae[oCnae:nAt][2]}}
	
	@ 098,040 SAY StrZero(nOcorrencia,6) + STR0018//" Ocorr�ncia(s) encontrada(s)" 
	
	@ 096,180 Button STR0011 Size 50,10 Action (cQualCnae:=aCnae[oCnae:nAt][1],oDlgRe:End(),oDlg:End()) //"&Confirma"
	@ 096,240 Button STR0019 Size 50,10 Action (Close(oDlgRe),DbCloseArea()) //"&Retonar"
	
	ACTIVATE Dialog oDlgRe CENTERED

EndIf

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft500FOk     �Autor  �Vendas Clientes  � Data �  21/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria pesquisa no SXB                                        ���
���          |                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SIGAFAT                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft500FOk()
 
Local nPCod  := aScan(aHeader,{|x|AllTrim(x[2])=="CCG_DIVISA"})
Local nPDesc := aScan(aHeader,{|x|AllTrim(x[2])=="CCG_DESC"})
Local cDescri:= ""
 
If AllTrim(ReadVar()) == "M->CCG_DIVISA
    cDescri := Posicione("CDI",1,xFilial("CDI")+M->CCG_DIVISA,"CDI_DESCRI")
    If Empty(cDescri)
    	Aviso( STR0014, STR0021, { STR0022 }, 2 )    //"ATENCAO"###"Codigo de Divis�o CNAE Inexistente"###"Ok"
    	aCols[n][nPCod]  := Space(TamSX3("CCG_DIVISA")[1])
    	aCols[n][nPDesc] := Space(TamSX3("CCG_DESC")[1])
        Return .F.
     Else
        aCols[n][nPDesc] := cDescri
    Endif
EndIf
 
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft500Cod     �Autor  �Vendas Clientes  � Data �  21/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza os campo de descricao                              ���
���          |                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SIGAFAT                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Ft500Cod(cCod)

Local lRet		:= .T.
Local cCDIVIS	:=	""
Local cCGRUPO	:=	""
Local cCCLASS	:=	""
Local aArea     := CC3 ->(GetArea())
Local oMdl      := Nil
Local oMdlCC3   := Nil

DbselectArea("CCG")
DbSetOrder(1)

If Inclui
	oMdl    := FWModelActive()
	If oMdl <> Nil
		oMdlCC3 := oMdl:GetModel('CC3MASTER')
	EndIf
	If oMdlCC3 <> Nil
		cCDIVIS	:= Substr(cCod,1,2)+SPACE(TamSX3("CCG_COD")[1]-Len(Substr(cCod,1,2)))
		If DbSeek(xFilial("CCG")+cCDIVIS)
		  	oMdlCC3:SetValue("CC3_CDIVIS",Alltrim(CCG->CCG_COD))
		   oMdlCC3:SetValue("CC3_DDIVIS",CCG->CCG_DESC)
		EndIf
	
		cCGRUPO	:=Substr(cCod,1,2)+Substr(cCod,3,1)+SPACE(TamSX3("CCG_COD")[1]-Len(Substr(cCod,1,2)+Substr(cCod,2,1)))
		If DbSeek(xFilial("CCG")+cCGRUPO)
		   oMdlCC3:SetValue("CC3_CGRUPO",Alltrim(CCG->CCG_COD))
		   oMdlCC3:SetValue("CC3_DGRUPO",CCG->CCG_DESC)
		EndIf
	
		cCCLASS	:=Substr(cCod,1,2)+Substr(cCod,3,2)+Substr(cCod,6,1)+SPACE(TamSX3("CCG_COD")[1]-Len(Substr(cCod,1,2)+Substr(cCod,2,2)+Substr(cCod,6,1)))
		If DbSeek(xFilial("CCG")+cCCLASS)
		   oMdlCC3:SetValue("CC3_CCLASS",Alltrim(CCG->CCG_COD))
		   oMdlCC3:SetValue("CC3_DCLASS",CCG->CCG_DESC)
		EndIf
	Else
		//Se estiver incluindo um CNAE pelo Cadastro de Cliente via consulta F3.
		cCDIVIS	:= Substr(cCod,1,2)+SPACE(TamSX3("CCG_COD")[1]-Len(Substr(cCod,1,2)))
		If DbSeek(xFilial("CCG")+cCDIVIS)
		   M->CC3_CDIVIS    :=CCG->CCG_COD
		   M->CC3_DDIVIS	:=CCG->CCG_DESC
		EndIf
	
		cCGRUPO	:=Substr(cCod,1,2)+Substr(cCod,3,1)+SPACE(TamSX3("CCG_COD")[1]-Len(Substr(cCod,1,2)+Substr(cCod,2,1)))
		If DbSeek(xFilial("CCG")+cCGRUPO)
		   M->CC3_CGRUPO	:=CCG->CCG_COD
		   M->CC3_DGRUPO	:=CCG->CCG_DESC
		EndIf
	
		cCCLASS	:=Substr(cCod,1,2)+Substr(cCod,3,2)+Substr(cCod,6,1)+SPACE(TamSX3("CCG_COD")[1]-Len(Substr(cCod,1,2)+Substr(cCod,2,2)+Substr(cCod,6,1)))
		If DbSeek(xFilial("CCG")+cCCLASS)
		   M->CC3_CCLASS	:=CCG->CCG_COD
		   M->CC3_DCLASS	:=CCG->CCG_DESC
		EndIf
	EndIf
Endif

RestArea(aArea) 

Return lRet 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft500Gth     �Autor  �Vendas Clientes  � Data �  21/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza os campo de descricao                              ���
���          |                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SIGAFAT                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft500Gth(cCod,ctipo)

Local lRet	:= .T.            
Local aArea := GetArea()

cCod:= cCod+SPACE(TamSX3("CCG_COD")[1]-Len(cCod))

DbselectArea("CCG")
DbSetOrder(1)

If DbSeek(xFilial("CCG")+cCod+ctipo)
   If 		ctipo = "1"
      M->CC3_DSECAO	:=CCG->CCG_DESC
   ElseIf 	ctipo = "2"   
      M->CC3_DDIVIS	:=CCG->CCG_DESC
   ElseIf 	ctipo = "3"   
      M->CC3_DGRUPO	:=CCG->CCG_DESC
   ElseIf 	ctipo = "4"   
      M->CC3_DCLASS	:=CCG->CCG_DESC
   Endif
Endif

RestArea(aArea)

Return lRet
