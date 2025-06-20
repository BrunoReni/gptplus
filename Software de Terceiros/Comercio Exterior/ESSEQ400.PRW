/*
Programa   : ESSEQ400()
Objetivo   : Rotina de Cadastro de Enquadramentos
Retorno    : Nil
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 18/03/2013 13:39 
Revisao    : 
*/

#Include 'Protheus.ch'               
#Include "Average.ch"
Function ESSEQ400() 
Local cDelOK := "EQ400DELET()"  
   Private aRotina := MenuDef()
   
   AxCadastro("ELC","Enquadramentos",cDelOK)  
Return

Static Function MenuDef()
   Local aRotina := {}

   Aadd(aRotina, { "Pesquisar" , "AxPesqui" , 0 , 1}) //"Pesquisar"
   Aadd(aRotina, { "Visualizar", "AxVisual" , 0 , 2}) //"Visualizar"
   Aadd(aRotina, { "Incluir"   , "AxInclui" , 0 , 3}) //"Incluir"
   Aadd(aRotina, { "Alterar"   , "AxAltera" , 0 , 4}) //"Alterar"
   Aadd(aRotina, { "Excluir"   , "AxExclui" , 0 , 5}) //"Excluir"                                            
Return aRotina   

Function EQ400DELET()
Local lRet := .T.
Local cQuery := "",nTotalReg := 0

If Select("TOTALREG") > 0
   TOTALREG->( dbCloseArea() )
Endif

cQuery := " SELECT COUNT(*) AS TOTAL FROM "+ RetSqlName("EJX")+" EJX " 
cQuery += " INNER JOIN " + RetSqlName("ELC") + " ELC "
cQuery += " ON EJX.EJX_FILIAL = '" + xFilial("EJX") + "'"
cQuery += " AND EJX.EJX_ENQ01 = ELC.ELC_CODENQ"
cQuery += " OR EJX.EJX_ENQ02 = ELC.ELC_CODENQ"
cQuery += " OR EJX.EJX_ENQ03 = ELC.ELC_CODENQ"
cQuery += " Where (EJX.EJX_ENQ01 ='" + ELC->ELC_CODENQ +"'"  
cQuery += " OR EJX.EJX_ENQ02 ='" + ELC->ELC_CODENQ +"'" 
cQuery += " OR EJX.EJX_ENQ03 ='" + ELC->ELC_CODENQ +"')" 
cQuery += " AND EJX.D_E_L_E_T_ <> '*' "

dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"TOTALREG", .F., .F. )

nTotalReg:= TOTALREG->TOTAL

TOTALREG->( dbCloseArea() )

If nTotalReg > 0
   MsgStop("Enquadramento localizada em um processo de Aquisi��o/Venda! Para deletar o registro retire " +;
           "o c�digo do enquadramento do(s) processo(s) e refa�a o procedimento de exclus�o.","Aten��o")
   lRet := .F.     
EndIF

Return lRet