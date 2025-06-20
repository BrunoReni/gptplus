#INCLUDE "PLSA094.ch"
#INCLUDE "PROTHEUS.CH"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA094A � Autor � Tulio Cesar           � Data � 24.11.03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Chama o programa de Autorizacao de SADT/Consulta           ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function PLSA094A()

// TISS 2.2 - Requisitos minimos � a existencia da tabela BRI e a existencia da fun��o PLSRETLDP
If ! ( PLSALIASEX("BRI") .And. FindFunction("PLSRETLDP") ) 
   Final("Necess�rio atualizar pacote da TISS 2.2 para se utilizar esta funcionalidade.")
Endif

PLSA090("1")

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA094B � Autor � Tulio Cesar           � Data � 24.11.03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Chama o programa de Liberacao                              ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA094B()

//TISS 2.2 - Requisitos minimos � a existencia da tabela BRI e a existencia da fun��o PLSRETLDP
If ! ( PLSALIASEX("BRI") .And. FindFunction("PLSRETLDP") ) 
   Final("Necess�rio atualizar pacote da TISS 2.2 para se utilizar esta funcionalidade.")
Endif

PLSA090("2")


Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA094C � Autor � Tulio Cesar           � Data � 24.11.03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Chama o programa odontologico                              ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA094C()
//TISS 2.2 - Requisitos minimos � a existencia da tabela BRI e a existencia da fun��o PLSRETLDP
If ! ( PLSALIASEX("BRI") .And. FindFunction("PLSRETLDP") ) 
   Final("Necess�rio atualizar pacote da TISS 2.2 para se utilizar esta funcionalidade.")
Endif

PLS090O("1")

Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA094D � Autor � Tulio Cesar           � Data � 24.11.03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Chama o programa Liberacao odontologico                    ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA094D()

//TISS 2.2 - Requisitos minimos � a existencia da tabela BRI e a existencia da fun��o PLSRETLDP
If ! ( PLSALIASEX("BRI") .And. FindFunction("PLSRETLDP") ) 
   Final("Necess�rio atualizar pacote da TISS 2.2 para se utilizar esta funcionalidade.")
Endif


PLS090O("2")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLVLQTDEX

Valida se a quantidade executada � maior que o saldo na inclus�o
do procedimento na guia de SADT no remote.

@author Thiago Guilherme
@since 08/11/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLVLQTDEX() 

LOCAL lRet := .T.

If !EMPTY(M->BE1_NUMLIB)

	BE2->(dbSetOrder(6))
	
	If BE2->(MsSeek(xFilial("BE2") + M->BE1_NUMLIB + M->BE2_CODPAD + M->BE2_CODPRO))
		If M->BE2_QTDPRO > BE2->BE2_SALDO
		
			MsgInfo(STR0002 + ALLTRIM(STR(BE2->BE2_SALDO)), STR0003) //"Quantidade dispon�vel para execu��o: "##"Aten��o"
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSGUIPRI
Verifica se a guia principal inserida � do benefici�rio ou n�o.

@author  Victor Alves dos Santos
@since   16/03/2021
@version Protheus 12
/*/
//------------------------------------------------------------------- 

Function PLSGUIPRI(lAutoma)
Local cSql 		:= ""
Local nQtdReg   := 0
Local lRet		:= .f.
Local cMatric	:= M->BE1_USUARI
Local cGuiPri	:= M->BE1_GUIPRI
Default lAutoma := .f.

	If Empty(cGuiPri)
		lRet := .T.
		return lRet
	EndIf

//Query que verifica se h� alguma guia vinculada ao benefici�rio
    cSql := " SELECT COUNT(*) CONT FROM " + RetSQLName("BEA") + " BEA "
    cSql += " LEFT JOIN " + RetSqlName("BE4") + " BE4"
    cSql += " ON BE4_FILIAL = '"  + xFilial("BE4")+ "' "
    cSql += " AND BEA_OPEMOV = BE4_CODOPE"
	cSql += " AND BEA_ANOAUT = BE4_ANOINT"
	cSql += " AND BEA_MESAUT = BE4_MESINT"
	cSql += " AND BEA_NUMAUT = BE4_NUMINT"
	cSql += " AND BE4.D_E_L_E_T_ = ' ' "
	cSql += " WHERE BEA_FILIAL = '" + xFilial("BEA")+ "' AND"
	cSQL += " BEA_OPEUSR = '"+SubStr(cMatric,1,4)+"' AND "
	cSQL += " BEA_CODEMP = '"+SubStr(cMatric,5,4)+"' AND "
	cSQL += " BEA_MATRIC = '"+SubStr(cMatric,9,6)+"' AND "
	cSQL += " BEA_TIPREG = '"+SubStr(cMatric,15,2)+"' AND "
	cSQL += " BEA_DIGITO = '"+SubStr(cMatric,17,1)+"' AND "
	cSQL += " BEA_OPEMOV = '"+SubStr(cGuiPri,1,4)+"' AND "
	cSQL += " BEA_ANOAUT = '"+SubStr(cGuiPri,5,4)+"' AND "
	cSQL += " BEA_MESAUT = '"+SubStr(cGuiPri,9,2)+"' AND "
	cSQL += " BEA_NUMAUT = '"+SubStr(cGuiPri,11,8)+"' "
	cSql += " AND BEA_DATPRO <> ' ' "
	cSql += " AND BEA_CANCEL <> '1' "
	cSql += " AND BEA_STATUS <> '3' "
	
	BE4->(DbSetOrder(2))
	If BE4->(MsSeek(xFilial("BE4")+cGuiPri))
		cSql += " AND BE4_DATPRO <> ' ' "
		cSql += " AND BE4_DTALTA = ' ' "
	EndIf

	cSql += " AND BEA.D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)

    nQtdReg := MPSysExecScalar(cSql, "CONT")

    If nQtdReg > 0
        lRet := .T.
    Else
        lRet := .F.
		If !lAutoma
        	Alert("Guia n�o pertence ao benefici�rio ou n�o est� ativa. Favor informar uma guia v�lida !")
		EndIf
    EndIf

Return lRet
