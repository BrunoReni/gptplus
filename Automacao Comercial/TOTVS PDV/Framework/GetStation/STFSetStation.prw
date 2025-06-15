#INCLUDE "PROTHEUS.CH"

//�����������������������������������������������������������������������������
/*/{Protheus.doc} STFSetStat
Grava o(s) valor(es) do(s) campo(s) da SLG

@param   	uCampos - Informa o campo ou os campos que deseja atualizar o valor da SLG
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	lSet - Retorna se o campo foi gravado ou n�o
@obs     
@sample
/*/
//�����������������������������������������������������������������������������
Function STFSetStat(aCampos)

	Local aArea		:= GetArea() 				//Salva area
	Local lSet		:= .T. //Retorno da fun��o
	Local nI		:= 0
	
	
	
	DbSelectArea("SLG")                                      
	DbSetOrder(1)
	If DbSeek(xFilial("SLG") + cEstacao)  
		
		If RecLock("SLG", .F.)
	

				
			For nI := 1 To Len(aCampos)
			
				FieldPut( FieldPos( If(! Left(aCampos[nI, 1],3) == "LG_","LG_","") + aCampos[nI, 1]), aCampos[nI, 2])
				
				
			Next nI			
		
			
			SLG->(MsUnLock())
			

		
		EndIf
			

	Else
		lSet := .F.
	EndIf
	
RestArea(aArea)	

Return lSet

//�����������������������������������������������������������������������������
/*/{Protheus.doc} STFSendSta
Grava o(s) valor(es) do(s) campo(s) da SLG recebido via componente de comunica��o

@param1   	cFilStation - Filial da Esta��o
@param2   	cCodigo - Codigo da Esta��o
@param3   	aDados - Dados da Esta��o
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	lSet - Retorna se o campo foi gravado ou n�o
@obs     
@sample
/*/
//�����������������������������������������������������������������������������

Function STFSendSta( cFilStation , cCodigo , aDados )
 
Local aArea		:= GetArea()	 //	Guarda area 
Local lRet      :=    .T.		//  Retorno
Local nX		:= 0            //contado

Default cFilstation 	:= ""
Default cCodigo         := "" 
Default aDados          := {}  

DbSelectArea("SLG")
DbSetOrder(1)//LG_FILIAL+LG_CODIGO

If DbSeek( cFilstation + cCodigo  )

      Reclock( "SLG", .F. )   
            
      For nX := 1 To Len(aDados)
            Replace SLG->&(aDados[nX][1])      with aDados[nX][2]
      Next nI
            
      MsUnlock()
      
      lRet := .T.
      
EndIf

RestArea(aArea)

Return lRet


//--------------------------------------------------------
/*/{Protheus.doc} STFSetTefStat
Grava o(s) valor(es) do(s) campo(s) da MDG

@param   	aCampos - Informa o campo ou os campos que deseja atualizar o valor da MDG
@author  	Varejo
@version 	P11.8
@since   	02/036/2015
@return  	lSet - Retorna se o campo foi gravado ou n�o
@obs     
@sample
/*/
//--------------------------------------------------------
Function STFSetTefStat(aCampos)

Local aArea		:= GetArea()	//Salva area
Local lSet			:= .T. 		//Retorno da fun��o 
Local nI			:= 0			//Contador
	
Default aCampos := {}
	
DbSelectArea("MDG")                                      
DbSetOrder(1)//MDG_FILIAL+MDG_CODEST	
If DbSeek(xFilial("MDG") + cEstacao)  
	
	If RecLock("MDG", .F.)
			
		For nI := 1 To Len(aCampos)
			FieldPut( FieldPos( If(! Left(aCampos[nI, 1],3) == "MDG_","MDG_","") + aCampos[nI, 1]), aCampos[nI, 2])
		Next nI			
		
		MDG->(MsUnLock())
	
	EndIf

Else
	lSet := .F.
EndIf
	
RestArea(aArea)	

Return lSet

