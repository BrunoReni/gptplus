#INCLUDE "Protheus.ch"
#INCLUDE "MotivoCanc.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MotivoCanc�Autor  �Itamar				 � Data �  13/06/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Motivo do cancelamento da viagem							  ���
�������������������������������������������������������������������������͹��
���Uso       �CDV - Controle de Despesas de viagens						  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function MotivoCanc()
Private cMotivo:=Space(50)

ChkTemplate("CDV")


oSize := FWDefSize():New(.T.)
oSize:AddObject("MASTER",60,40,.T.,.T.)
oSize:lLateral := .F.				
oSize:lProp := .T.
		
oSize:Process()
DEFINE MSDIALOG oPrincipal TITLE STR0001 FROM  000,000 TO 200,650 PIXEL //'Motivo do Cancelamento da Viagem'

nLinIni := oSize:GetDimension("MASTER","LININI")
nColIni := oSize:GetDimension("MASTER","COLINI")
nLinFin := oSize:GetDimension("MASTER","LINEND")
nColFin := oSize:GetDimension("MASTER","COLEND")

@ nLinIni+5,05 SAY STR0002 OF oPrincipal PIXEL //'Informe o Motivo do Cancelamento'
oGet := TMultiGet():New(nLinIni+013, 05, bSETGET(cMotivo), oPrincipal, 317, 50,,,,,,.T.)

ACTIVATE MSDIALOG oPrincipal CENTERED ON INIT EnchoiceBar(oPrincipal, {|| OKT()}, {|| oPrincipal:End()}, , )

Return cMotivo

Static Function OKT()
	If AllTrim(cMotivo) == "" 
		MsgInfo(STR0003) //"A Rotina n�o poder� ser cancelada sem o motivo estar digitado."
	Else
		oPrincipal:End()
	EndIf                   
Return


/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �AE_VisMotCanc�Autor  �Pablo S.G. Carreras � Data �  14/12/09   ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao para visualizacao do motivo de cancelamento de solicita.���
���          �de viagens.                                                    ���
����������������������������������������������������������������������������͹��
���Uso       �SIGAFIN-CDV-FNC 00000028861/2009                               ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/

Template Function AE_VisMotCanc(cProc)

Local	aArea		:= GetArea()
Private cMotivo	:= Space(50)

ChkTemplate("CDV")

dbSelectArea("LJH")
LJH->(dbSetOrder(1))
If LJH->(dbSeek(xFilial("LJH") + cProc))
	cMotivo := Upper(LJH->LJH_MOTIVO)
	If AllTrim(PtGetTheme()) $ "MDI/TEMAP10"	
		DEFINE MSDIALOG oPrincipal FROM  000,000 TO 170,400 TITLE STR0001 PIXEL //'Motivo do Cancelamento da Viagem'
	Else
		DEFINE MSDIALOG oPrincipal FROM  000,000 TO 140,400 TITLE STR0001 PIXEL	 //'Motivo do Cancelamento da Viagem'
	Endif

	@ 20,05 SAY OemToAnsi(STR0004) + LTrim(LJH->LJH_CODSOL) OF oPrincipal PIXEL //"Motivo do cancelamento da solicita��o "
	oGet := TMultiGet():New(028,05, bSETGET(cMotivo), oPrincipal,190,40,,,,,,.T.,,,{|u|.F.})
	oGet:EnableVScroll(.T.)                                     

	ACTIVATE MSDIALOG oPrincipal CENTERED ON INIT EnchoiceBar(oPrincipal, {||oPrincipal:End()}, {|| oPrincipal:End()}, , )
Else 
	MsgAlert(STR0005) //"Motivo de cancelamento nao encontrado!"
Endif
RestArea(aArea)

Return cMotivo
