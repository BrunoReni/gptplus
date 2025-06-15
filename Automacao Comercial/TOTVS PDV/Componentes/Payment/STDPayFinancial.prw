#INCLUDE 'Protheus.ch'
#INCLUDE "STDPAYFINANCIAL.CH"

//�����������������������������������������������������������������������������
/*/{Protheus.doc} STDGetAdmFin


@param   	
@author  	Vendas & CRM
@version 	P12
@since   	11/01/2013
@return  	
@obs     
@sample
/*/
//������������������������������������������������������������������������������
Function STDGetAdmFin(cTpForm)
Local aArea := GetArea()
Local aRet  := {""}
Local cFilSAE := ""

DbSelectArea("SAE")
cFilSAE := xFilial("SAE")
SAE->(DbGoTop())
While !SAE->(EOF()) .AND. cFilSAE == SAE->AE_FILIAL
	If AllTrim(SAE->AE_TIPO) == cTpForm
		Aadd(aRet,SAE->AE_COD+" - "+SAE->AE_DESC)
	EndIf 	
	SAE->(DbSkip())
EndDo

If Len(aRet) == 1
	STFMessage(ProcName(),"ALERT",STR0001 + " " + cTpForm + " " + STR0002) //"Nao existe Adm. Financeira do tipo 'FI' cadastrada"
	STFShowMessage(ProcName())
	STFCleanMessage(ProcName())
EndIf

STISetAdm(aRet)

RestArea(aArea)

Return aRet

//������������������������������������������������������������������������������
/*/{Protheus.doc} STDVencAdmFin
Respons�vel por efetuar o posicionamento da Adm.Financeira e retornar a data do 
vencimento da parcela 
@param   	cCodAdmFin - Codigo da adm. financeira a ser posicionada
@param   	dData - Data a partir daqual ser� calculado o proximo vencimento
			
@author  	Vendas & CRM
@version 	P11
@since   	29/04/2015
@return  	
@obs     
@sample
/*/
//������������������������������������������������������������������������������
Function STDVencAdmFin(cCodAdmFin,dData)
Local dDataRet := dDataBase
Local aArea	 := GetArea("SAE")
 
Default dData := dDataBase

SAE->(DBSetOrder(1)) //AE_FILIAL+AE_COD
If SAE->(DbSeek(xFilial("SAE")+cCodAdmFin))
	dDataRet := LJCalcVenc(.F.,dData)
EndIf

RestArea(aArea)

Return dDataRet