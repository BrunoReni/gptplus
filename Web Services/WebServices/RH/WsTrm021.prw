#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "WSTRM021.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �WSRH020   � Autor �Emerson Grassi Rocha   � Data �04/08/2003  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Web Service responsavel pela Consulta de Fatores/Habilidades ���
���          � do Cargo.                                                    ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Portal RH			                                        ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

//������������������������������������������������������������������������Ŀ
//�Definicao do Web Service 						                       �
//��������������������������������������������������������������������������
WSSERVICE RhFactors DESCRIPTION STR0003 //"Requisitos do Cargo <b>(Fatores / Habilidades)</b>"

	WSDATA UserCode                 AS String
	WSDATA PositionCode				AS String 
	WSDATA CostCenterCode			AS String OPTIONAL 
	WSDATA ListOfFactors        	AS Array Of FactorsView
	WSDATA ListOfHability        	AS Array Of HabilityView
   
    WSMETHOD BrwFactors		DESCRIPTION STR0004 //"M�todo de visualiza��o de Fatores de Avaliacao (Requisitos)"
    WSMETHOD BrwHability 	DESCRIPTION STR0005 //"M�todo de visualiza��o de Habilidades do Cargo"
    
ENDWSSERVICE

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �BrwFactors�Autor  � Emerson Grassi Rocha  � Data �04/08/2003 ���
��������������������������������������������������������������������������Ĵ��
���          �Browse de Fatores de Avaliacao do Cargo.			           ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Codigo do usuario                                     ���
���			 �ExpC2: Codigo do Cargo	                                   ���
���			 �ExpC3: Codigo do Centro de Custo	                           ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica que o metodo foi avaliado com sucesso          ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Este metodo devolve as Fatores do Cargo conforme estrutura.  ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Portal RH				                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
WSMETHOD BrwFactors WSRECEIVE UserCode,PositionCode,CostCenterCode WSSEND ListOfFactors WSSERVICE RhFactors

Local lRetorno	:= .T.
Local aArea    	:= GetArea()
Local nX       	:= 0  
Local cChave		:= "  "
Local cChave2		:= "  "

//Verifica se os fatores e habilidades devem ser carregados
// "0" -> carrega requisitos e habilidades do cargo
// "1" -> carrega apenas as habilidades
// "2" -> carrega apenas os requisitos/fatores do cargo
// "3" -> n�o carrega nada
Local cHabFat  := GetMv("MV_HABFAT", NIL, "0")

If !cHabFat $ ("0123")
	cHabFat := "0"
EndIf

If PrtChkUser(::UserCode,"RhFactors")  

   If cHabFat == "0" .Or. cHabFat =="2"
		dbSelectArea("SQ3")
		dbSetOrder(1)
		cChave2:= "SQ4->Q4_CARGO+SQ4->Q4_CC"
		If !Empty(::CostCenterCode) .And. dbSeek(xFilial("SQ3") + ::PositionCode + ::CostCenterCode)
			cChave := ::PositionCode + ::CostCenterCode	
		ElseIf dbSeek(xFilial("SQ3") + ::PositionCode + Space(TamSx3("Q3_CC")[1]))
			cChave := ::PositionCode + Space(TamSx3("Q3_CC")[1])
		EndIf
	       
		dbSelectArea("SQ4") 
		dbSetOrder(2)
		If dbSeek(xFilial("SQ4")+cChave) 
			While !Eof() .And. cChave == &cChave2
				aadd(::ListOfFactors,WSClassNew("FactorsView"))
				nX++      

				::ListOfFactors[nX]:GroupCode 			:= SQ4->Q4_GRUPO															//Grupo
				::ListOfFactors[nX]:GroupDescription	:= FDesc("SQ0",SQ4->Q4_GRUPO,"Q0_DESCRIC")							// Descricao do Grupo
				::ListOfFactors[nX]:PositionCode		:= SQ4->Q4_CARGO 															// Cargo
				::ListOfFactors[nX]:PositionDescription:= FDesc("SQ3",SQ4->Q4_CARGO,"Q3_DESCSUM")							// Descricao do Cargo
				::ListOfFactors[nX]:FactorCode 			:= SQ4->Q4_FATOR															// Codigo do Fator 
				::ListOfFactors[nX]:FactorDescription	:= FDesc("SQ1",SQ4->Q4_GRUPO+SQ4->Q4_FATOR,"Q1_DESCSUM") 			// Descricao do Fator
				::ListOfFactors[nX]:DegreeCode	  		:= SQ4->Q4_GRAU							   								// Grau do Fator
				::ListOfFactors[nX]:DegreeDescription	:= FDesc("SQ2",SQ4->Q4_GRUPO+SQ4->Q4_FATOR+SQ4->Q4_GRAU,"Q2_DESC")	// Descricao da Graduacao do Fator
				::ListOfFactors[nX]:FactorScore	  		:= SQ4->Q4_PONTOS															// Pontos   
			
 	    	    UserFields("SQ4",@::ListOfFactors[nX]:UserFields)			
 	        
	 	        dbSelectArea("SQ4")
 		        dbSetOrder(2)
				dbSkip()
			EndDo
		
		Else 
			aadd(::ListOfFactors,WSClassNew("FactorsView"))
		
			lRetorno := .F.
			SetSoapFault("BrwFactors01",STR0001)	//"Cargo nao localizado na Tabela."
		EndIf
	EndIf	
		
Else
	lRetorno := .F.
	SetSoapFault("BrwFactors02",STR0002)	//"Usuario nao autorizado"
EndIf

RestArea(aArea)
Return(lRetorno)


/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �BrwHability�Autor  � Emerson Grassi Rocha  � Data �09/08/2004���
��������������������������������������������������������������������������Ĵ��
���          �Browse de Habilidades do Cargo.	  				           ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Codigo do usuario                                     ���
���			 �ExpC2: Codigo do Cargo	                                   ���
���			 �ExpC3: Codigo do Centro de Custo	                           ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica que o metodo foi avaliado com sucesso          ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Este metodo devolve as Habilidades do Cargo conforme 		   ���
���          �estrutura.	                                               ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Portal RH				                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
WSMETHOD BrwHability WSRECEIVE UserCode,PositionCode,CostCenterCode WSSEND ListOfHability WSSERVICE RhFactors

Local lRetorno	:= .T.
Local aArea    	:= GetArea()
Local nX       	:= 0  
Local cChave		:= ""
Local cChave2		:= ""

//Verifica se os fatores e habilidades devem ser carregados
// "0" -> carrega requisitos e habilidades do cargo
// "1" -> carrega apenas as habilidades
// "2" -> carrega apenas os requisitos/fatores do cargo
// "3" -> n�o carrega nada
Local cHabFat  := GetMv("MV_HABFAT", NIL, "0")
If !cHabFat $ ("0123")
	cHabFat := "0"
EndIf

If PrtChkUser(::UserCode,"RhFactors") 

   If cHabFat == "0" .Or. cHabFat =="1"
		dbSelectArea("SQ3")
		dbSetOrder(1)
		cChave2:= "RBH->RBH_GRUPO+RBH->RBH_CARGO+RBH->RBH_CC"
		If !Empty(::CostCenterCode) .And. dbSeek(xFilial("SQ3") + ::PositionCode + ::CostCenterCode)
			cChave := SQ3->Q3_GRUPO + ::PositionCode + ::CostCenterCode	
		ElseIf dbSeek(xFilial("SQ3") + ::PositionCode + Space(TamSx3("Q3_CC")[1]) )
			cChave := SQ3->Q3_GRUPO + ::PositionCode + Space(TamSx3("Q3_CC")[1])
		EndIf
    
		dbSelectArea("RBH")  
		dbSetOrder(2)
		If dbSeek(xFilial("RBH")+cChave) 
			While !Eof() .And. cChave == &cChave2

				aadd(::ListOfHability,WSClassNew("HabilityView"))
				nX++      

				::ListOfHability[nX]:CompetenceCode 			:= RBH->RBH_CODCOM													// Codigo da Competencia
				::ListOfHability[nX]:CompetenceDescription	:= FDesc("RDM",RBH->RBH_CODCOM,"RDM_DESC") 						// Descricao da Competencia
				::ListOfHability[nX]:CompetenceItemCode		:= RBH->RBH_ITECOM													// Item de Competencia
				::ListOfHability[nX]:CompetenceItemDescription:= FDesc("RD2",RBH->RBH_CODCOM+RBH->RBH_ITECOM,"RD2_DESC")		// Descricao Item Competencia
				::ListOfHability[nX]:HabilityCode	  			:= RBH->RBH_HABIL														// Habilidade
				::ListOfHability[nX]:HabilityDescription		:= FDesc("RBG",RBH->RBH_HABIL,"RBG_DESC")							// Descricao de Habilidades   			
				::ListOfHability[nX]:ScaleCode		  			:= RBH->RBH_ESCALA													// Escala   			
				::ListOfHability[nX]:ScaleDescription  		:= FDesc("RBK",RBH->RBH_ESCALA,"RBK_DESCRI")						// Descricao da Escala   			
				::ListOfHability[nX]:ScaleItemCode				:= RBH->RBH_ITESCA													// Item Escala   						
				::ListOfHability[nX]:ScaleItemDescription		:= FDesc("RBL",RBH->RBH_ESCALA+RBH->RBH_ITESCA,"RBL_DESCRI")	// Descricao Item Escala   			
				::ListOfHability[nX]:ScaleItemValue			:= FDesc("RBL",RBH->RBH_ESCALA+RBH->RBH_ITESCA,"RBL_VALOR") 	// Valor do Item Escala
				::ListOfHability[nX]:ImportanceLevelCode		:= RBH->RBH_IMPORT													// Grau Importancia
				::ListOfHability[nX]:ImportanceLevelDescription:= FDesc("RBK",RBH->RBH_IMPORT,"RBK_DESCRI")					// Descricao Grau Importancia   			
				::ListOfHability[nX]:ImportLevelItemCode		:= RBH->RBH_ITIMPO													// Item Grau Importancia   			
				::ListOfHability[nX]:ImportLevelItemDescription:= FDesc("RBL",RBH->RBH_IMPORT+RBH->RBH_ITIMPO,"RBL_DESCRI")	// Descricao Grau Importancia   						
				::ListOfHability[nX]:ImportLevelItemValue		:= FDesc("RBL",RBH->RBH_IMPORT+RBH->RBH_ITIMPO,"RBL_VALOR")		// Valor do Grau Importancia
			
 		        UserFields("RBH",@::ListOfHability[nX]:UserFields)			
 	    
	 	    	dbSelectArea("RBH")
 		    	dbSetOrder(2)    
				dbSkip()
			EndDo
		
		Else 
			aadd(::ListOfHability,WSClassNew("HabilityView"))
		
			lRetorno := .F.
			SetSoapFault("BrwFactors03",STR0001)	//"Cargo nao localizado na Tabela."
		EndIf
	EndIf	
		
Else
	lRetorno := .F.
	SetSoapFault("BrwFactors04",STR0002)	//"Usuario nao autorizado"
EndIf

RestArea(aArea)
Return(lRetorno)

Function wstrm021()
Return