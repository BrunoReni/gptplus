#Include 'Protheus.ch'
#INCLUDE 'TopConn.ch'
#INCLUDE 'OGR700.CH'
/*                                                                                                 
+=================================================================================================+
| Programa  : OGR700                                                                              |
| Descri��o : Programa saldos de contrato de venda                                                |
| Autor     : In�cio Luiz Kolling                                                                 |
| Data      : 25/03/2016                                                                          | 
+=================================================================================================+                                                                           |  
*/
Function OGR700()
Local aArAt 		:= GetArea()
Private oReport	:= Nil
Private cPerg		:= "OGR700"
Private vRetR,cNoT1,cAlT1,aAlT1,vRetT,cNoTT,cAlTT,aAlTT
		
OGRSALDOTRB("OGR700","2") // No OGR400
	
If TRepInUse()
	Pergunte(cPerg,.f.)
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

AGRDELETRB(cAlT1,cNoT1)
AGRDELETRB(cAlTT,cNoTT)
RestArea(aArAt)	
Return( Nil )

/*                                                                                                 
+=================================================================================================+
| Fun��o    : ReportDef                                                                           |
| Descri��o : Cria��o da se��o                                                                    |
| Autor     : In�cio Luiz Kolling                                                                 |
| Data      : 25/03/2016                                                                          | 
+=================================================================================================+                                                                           |  
*/
Static Function ReportDef()
oReport	:= TReport():New(STR0001,STR0002,cPerg,{|oReport|OGRSALDOPRI(oReport,'2')},STR0002) // No OGR400
oReport:SetTotalInLine(.f.)
oReport:SetLandScape()
OGRSALDOCOL(oReport,STR0002,"2") // No OGR400
Return oReport