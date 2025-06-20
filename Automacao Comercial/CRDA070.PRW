#INCLUDE "CRDA070.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CRDA070   � Autor �Viviane M. Fernandes   � Data �05.07.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �CLASSIFICACAO DO CLIENTE                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Rotina de Classifica��o do cliente, apontar� se o cliente   ���
���          �atingiu a pontuacao, se baseando no cadastro de MAG e no    ���
���          �e no perfil do cliente  								      ���
�������������������������������������������������������������������������Ĵ��
���                Alteracoes desde sua criacao                           ���
�������������������������������������������������������������������������Ĵ��
���DATA    �BOPS �Programador�Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���04/07/05�81261�Machima    �Considerar a analise de perfil para a classi���
���        �     �           �ficacao do cliente                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                          
Function CRDA070

Private aRotina := MenuDef()
					
Private cCadastro := STR0006	 //"Classifica��o de clientes

DbSelectArea("SA1")     
dbSetOrder(1)

DbSeek(xFilial("SA1"))

mBrowse( 06, 01, 15, 75, "SA1" )

Return                          

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Conrado Q. Gomes      � Data � 13.12.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CRDA070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
	Local aRotina := {	{ STR0001 ,"AxPesqui"   ,0 ,1 ,0 ,.F.},; 	//"Pesquisar"
						{ STR0002 ,"CRC070_001" ,0 ,2 ,0 ,.T.}}	//"Visualizar"
Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao   �CRDA070_001  �Autor�Viviane M. Fernandes� Data �  05/07/03   ���
�������������������������������������������������������������������������͹��
���Desc.    �Classifica��o do Cliente, base de scripts de Perfil e cr�dito���
���         �                                                             ���
�������������������������������������������������������������������������͹��
���Parametro�EXPC1: Alias proveniente da MBrowse                          ���
���         �EXPN2: Registro posicionado na MBrowse                       ���
���         �EXPN3: Opcao de Menu Selecionada.                            ���
�������������������������������������������������������������������������͹��
���Uso      � AP7-Telecobran�a-Cadastro de Question�rio Socio Ecom. social���
�������������������������������������������������������������������������Ĵ��
���DATA    �Versa�Programador�Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���02/02/07�912  �Fernando   �Bops115955 Altera��o feita para utilizar    ���
���        �     �           �Walk Trhu                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRC070_001(cAlias, nReg, nOpc)

Local oEnchoice   						// Objeto para Enchoice
Local oDlg 								// Objeto da Dialog
Local oBar								// ToolBar superior
Local aButtons   := {}  				// Array de botoes para a toolBar superior (EnchoiceBar)
Local aAC        := {STR0007,STR0008} 	// "Abandona"###"Confirma"

//Size da Dialog
Local aSize      := {}					// Size da Dialog - Funcao de calculo para coordenadas de tela.
Local aObjects   := {}					// Array de controle utilizado nos calculos de didmensao da Dialog
Local aInfo      := {}					// Array de controle utilizado nos calculos de didmensao da Dialog
Local aPosObj    := {}					// Array de controle utilizado nos calculos de didmensao da Dialog

Local bOk        := Nil					// Bloco para Ok
Local bCancel    := Nil					// Bloco para Cancela
Local nSele      := 0					// Verifica o botao selecionado. 
Local nItem      := 0
Local nTipo      := 1 		            //  1 - consulta de classificacao do cliente, chamada do menu
                      	 	            //  2 - Classifica��o -  consulta geral (calcula a an�lise)- Ficha cadastral
                      		            //  3 - Classifica��o -  Libera��o para efetiva��o- Ficha cadastral
Local oBmp
Local aAnalise   :={}
Local lR5        := GetRpoRelease("R5") //Verifica caso seja release 11.5
Local nTamTela1  := 0                   //Adiciona posicoes aos objetos setados, Versao11.5

Private aHeader  := {} 					// Referencias trabalhos
Private aCols    := {} 

//bloco de c�digo para os bot�es

bOk     := {||(nSele := 1,oDlg:End())}
bCancel := {||(nSele := 2,oDlg:End())}

					    	//cAlias, cSkip,OnlyFields,lWalkThru
aHeader   := A610CriaHeader("MAG", "MAG_CODCLI, MAG_LOJA, MAG_EMPRES, MAG_FILEMP, MAG_REGRA",,.T.)

aAnalise:= CRC070_002(nTipo)

// fazer um tratamento para verificar se h� regraas no cadastro de cr�ticas
If Len(aAnalise) > 0

	// Calcula as dimensoes dos objetos
	aSize  := MsAdvSize( .T. , .T.)
	
	aObjects	:= {}
	AAdd( aObjects, { 50,15,.T.,.T. } )							// Horizontal superior.
	AAdd( aObjects, { 50,60,.T.,.T. } )							// Horizontal Inferior.
	
	//�����������������������������������������������������������������Ŀ
	//�LR5 = Verifica se utiliza vers�o 11.5                            �	
	//�Caso Utilize 11.5 retira -15 Posicoes no (quarto) 4�Parametro.�
	//� Realiza ajuste da posicao do Objeto na tela                     �
	//�������������������������������������������������������������������
	If lR5
		nTamTela1 := 15 
    EndIf
    aInfo := { aSize[1],aSize[2],aSize[3],aSize[4]-nTamTela1, 0, 0 }
	aPosObj	:= MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE MSDIALOG oDlg FROM aSize[7],0 TO aSize[6],aSize[5];
	TITLE STR0006 PIXEL 
	
	RegToMemory("SA1",IIf(nOpc == 3,.T.,.F.))
	
	@aPosObj[1,1], aPosObj[1,2] TO aPosObj[1,3],(aPosObj[1,4] - 30) LABEL "" PIXEL 
	@aPosObj[1,1] + 7, aPosObj[1,2] + 5  SAY STR0015	SIZE 50,8 of ODLG PIXEL  //"Cliente"
	@aPosObj[1,1] + 7, aPosObj[1,2] + 25  SAY M->A1_NOME SIZE 100,8 of ODLG PIXEL //Nome do cliente
		
	@aPosObj[1,1] + 7, aPosObj[1,2] + 180 SAY STR0009 SIZE 50,10 of ODLG PIXEL 
	@aPosObj[1,1] + 7, aPosObj[1,2] + 210 SAY STR0010 SIZE 50,10 of ODLG PIXEL
	@aPosObj[1,1] + 7, aPosObj[1,2] + 240 SAY aAnalise[1] SIZE 40,8 of ODLG PIXEL //pontos acumulados
		
	@aPosObj[1,1] + 17, aPosObj[1,2] + 180 SAY STR0009  SIZE 50,10  of ODLG PIXEL
	@aPosObj[1,1] + 17, aPosObj[1,2] + 210 SAY STR0011 SIZE 50,10  of ODLG PIXEL 
	@aPosObj[1,1] + 17, aPosObj[1,2] + 240 SAY aAnalise[2] SIZE 40,8 of ODLG PIXEL // parametro MAXPONT
	
	@aPosObj[1,1] + 17, aPosObj[1,2] + 5  SAY aAnalise[3] SIZE 150,8 of ODLG PIXEL //Mensagem de classificacao do cliente
	
	//conforme a classifica��o do cliente � exibido a imagem do semaforo 
	@aPosObj[1,1] + 5, aPosObj[1,2] + 290   BITMAP oBmp RESOURCE aAnalise[4] Of oDlg NOBORDER SIZE 50,20 PIXEL
		                                                                        
	@aPosObj[2,1], aPosObj[2,2] TO aPosObj[2,3],aPosObj[2,4] LABEL "" PIXEL 
	oGet:= MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"","","",.T.)
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons))

Else                    

	//N�o h� regras no cadastro de de cr�ticas de cr�dito
	MsgStop( STR0012,  STR0013 )

EndIf

Return .T.                                                 

               
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao   �CRC070_002   �Autor�Viviane M. Fernandes� Data �  05/07/03    ���
�������������������������������������������������������������������������͹��
���Desc.    �Retorna um array com os dados necess�rios para a visualizacao���
���         �da tela                                                      ���
�������������������������������������������������������������������������͹��
���Parametro�EXPN1: Tipo da Consulta que ser� chamando	                  ���
���         �       1 - Classificacao/consulta a tabela de pontos         ���
���         �       2 - Consulta sem permissao para liberar               ���
���         �       3 - Consulta com permiss�o para liberar               ���
���         �EXPN2: Cliente da mBrowse                                    ���
���         �EXPN3: Loja do Cliente                                       ���
�������������������������������������������������������������������������͹��
���Retorno  �EXPN1: Total de pontos obtido pela cosulta do cliente        ���
���         �EXPN2: Total M�ximo de pontos que o cliente pode obter - ver ���
��� 		�	    parametro MV_MAXPONT                                  ���
���         �EXPC3: Mensagem de classifica��o da an�lise de cr�dito       ��� 
���         �EXPC4: Bitmap que dever� ser visualizado                     ��� 
���         �EXPC5: Resultado da an�lise de Cr�dito                       ��� 
���         �EXPC6: REsultado da an�lise pessoal                          ��� 
���         �EXPN7: Numero de regras que foi respondida pelo cliente      ��� 
�������������������������������������������������������������������������͹��
���Uso      � AP7-Telecobran�a-Cadastro de Question�rio Socio Ecom. social���
�������������������������������������������������������������������������Ĵ��
���DATA    �Versa�Programador�Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���02/02/07�912  �Fernando   �Bops115955 Altera��o feita para tratar aCols���
���        �     �           �com os campos do Walk trhu                  ���
���03/10/07�133686�Nunzio     �Considera so os scrits da filial corrente,  ���
���        �      �           �se o arquivo for compartilhado e MAG_FILEMP ���
���        �      �           �estiver vazio							   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function CRC070_002(nTipo,cCliente,cLoja) // selecionando as criticas a serem executadas			

Local aCritica 		:= {}                  	//Array com os scripts de avaliacao
Local cMsg     		:= ""                  	//Retorna a mensagem da funcao
Local nTotPont 		:= 0                   	//Total de pontos
Local cSemaf   		:= ""					//Nao devera aparecer o semaforo
Local cSitCr   		:= ""					//Nao devera aparecer o botaozinho vermelho
Local cSitPer  		:= ""					//Define a cor do semafaro
Local nTotCrit 		:= 0 					//total de criticas para serem executadas 
Local nTotPer  		:= 0                    //Total de perguntas
Local cValorMacro 	:= ""					//Utilizada para executar uma macro
Local nPontos  		:= 0                   	//Total de pontos
Local nItem			:= 0                   	//Varialvel de controle contador

Private nMaxPont 	:= SuperGetMv("MV_MAXPONT")

If nMaxPont = 0                                                       
   cMsg     := STR0014 //"O valor de pontuac�o n�o foi informado corretamente"
   nTotPont := 0  
   cSitCr:= ""   // n�o dever� aparecer o botaozinho vermelho
	nTotCrit := 0        
   cSemaf:= ""  // n�o dever� aparecer o sem�foro
   Return({nTotpont,nMaxPont,cMsg, cSemaf, cSitCr ,cSitPer ,nTotcrit})

EndIf

dbSelectArea("MAG")
dbSetOrder(2)

//selecionando as criticas que forem da Empresa atual
MAG->(DbSeek(xFilial("MAG"), .T.))


While !Eof() // MAG->MAG_EMPRES == cEmpAnt .and. ( MAG->MAG_FILEMP == cFilAnt .or. Empty(MAG->MAG_FILEMP ) )  .and. !eof()

	If !Empty(MAG->MAG_EMPRES) .and. MAG->MAG_EMPRES <> cEmpAnt
		dbSkip()
		Loop
	EndIf
	
	If !Empty(MAG->MAG_FILIAL) .and. MAG->MAG_FILIAL <> cFilAnt
		dbSkip()
		Loop
	EndIF

    //Considera so os registros da filial corrente, se o arquivo for compartilhado e MAG_FILEMP estiver vazio
	If 	Empty(MAG->MAG_FILIAL) .AND. !Empty(MAG->MAG_FILEMP) .AND. MAG->MAG_FILEMP <> cFilAnt
		dbSkip()
		Loop
	EndIf  
	If !Empty(MAG->MAG_CRITIC) .and. !Empty(MAG->MAG_REGRA) // se existe o execblock (regra) a ser executada

  		AADD(aCritica, {MAG->MAG_CRITIC,MAG->MAG_REGRA,MAG->(Recno())})

  	EndIf
    	
  	MAG->(dbSkip())	    
    
End

//Verifica se o Perfil do cliente ser� analisado
	
nTotCrit := Len(aCritica) //Totalizador de perguntas para fazer a regra
								// de c�lculo com base no par�metro.
If nTotCrit > 0 

	For nItem:=1 to len(aCritica)

        dbSelectArea("MAG")
        dbGoto(aCritica[nItem,3])
		
		cValorMacro := ExecMacroInServer( aCritica[nItem,2] )

		If SubStr( cValorMacro,1,1) == "N"

			nPontos := Val( SubStr( cValorMacro,2 ))

		Else 

		   MsgStop( STR0016 + Chr(10) + Chr(10) + SubStr( cValorMacro, 2 ), STR0017 ) // "Houve problemas na execu��o da regra." ### "Aten��o"
			nPontos := 0

		EndIf		
		
		If nTipo == 1 

		   Aadd(aCols,Array(Len(aHeader) + 1))	
	       aCols[nItem,ascan(aHeader,{|x|Trim(x[2])=="MAG_CRITIC"})]:= aCritica[nItem,1]
       	   aCols[nItem,ascan(aHeader,{|x|Trim(x[2])=="MAG_PESO"}) ]:= nPontos
		   aCols[nItem,ascan(aHeader,{|x|Trim(x[2])=="MAG_ALI_WT"}) ]:= "MAG"
		   aCols[nItem,ascan(aHeader,{|x|Trim(x[2])=="MAG_REC_WT"}) ]:= aCritica[nItem,3]		       
	       aCols[nItem,Len(aHeader) + 1]:= .F.                         	       
       	   nTotPont:= nTotPont + aCols[nItem,ascan(aHeader,{|x|Trim(x[2])=="MAG_PESO"})]
     	Else
       	   nTotPont:= nTotPont + nPontos
     	EndIf   
	Next
Else    

	// nao h� regras para classificar o cliente
   cMsg := STR0013	              
   nTotPont := 0  
   cSitCr:= ""   // n�o dever� aparecer o botaozinho vermelho
	nTotCrit := 0        
   cSemaf:= ""  // n�o dever� aparecer o sem�foro
   Return({nTotpont,nMaxPont,cMsg, cSemaf, cSitCr ,cSitPer ,nTotcrit}) 

EndIf

// calculo das resposta do questionario socio economico cultural
If nTipo == 3 .or. nTipo == 2

	nTotPer := CRC070_003(cCliente, cLoja)

EndIf				

// pra utilizar os dois quadrados eu tenho que ver se este parametro est� ativo
If SuperGetMv("MV_PERFIL") 

	If nTotPer >= nMaxPont

		cSitPer:= "VERDE"

	Elseif nTotPer >= (nMaxPont / 2)	

	    cSitPer:= "AMARELO"

	Else              

	    cSitPer:= "VERMELHO"

	EndIf          	

EndIf

// se o valor total de analise credito - MAG
//
If nTotPont >= nMaxPont

	cMsg:= STR0018	// "Cliente padr�o excelente."
	cSemaf:= "SVD"
	cSitCr := "VERDE"                    //s� analiso o cr�dito

Elseif nTotPont >= (nMaxPont / 2)	

   cMsg:= STR0019 	// "Cliente com potencial de classifica��o."
   cSemaf:= "SAM"  
   cSitCr:= "AMARELO"

Else              

	cMsg:= STR0020 	// "Fora da faixa de pontua��o."
	cSemaf:= "SVM"   
	cSitCr:= "VERMELHO"

EndIf                                   
	
// pergunto se o perfil � analisado e verifico a classifi��o do cliente com base neste parametro
If SuperGetMv("MV_PERFIL") 

	If cSitCr == "VERDE" .AND. (cSitPer == "VERDE" .OR. !SuperGetMv("MV_PERFIL") .OR. nTipo == 1 )// pra ser verde tenho que ter as duas an�lises 

		cMsg:= STR0018	// "Cliente padr�o excelente."
		cSemaf:= "SVD"

	ElseIf cSitCr == "VERMELHO" .AND. (cSitPer == "VERMELHO" .OR. !SuperGetMv("MV_PERFIL") .OR. nTipo == 1 )

		cMsg:= STR0020	// "Fora da faixa de pontua��o."
	    cSemaf:= "SVM"                                                               

	ELSE
	   
	   cMsg:= STR0019	// "Cliente com potencial de Classifica��o."
	   cSemaf:= "SAM"  

	ENDIF    

EndIf

Return({nTotpont,nMaxPont,cMsg, cSemaf, cSitCr ,cSitPer ,nTotcrit}) 


               
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao   �CRDA070_003  �Autor�Viviane M. Fernandes� Data �  05/07/03   ���
�������������������������������������������������������������������������͹��
���Desc.    �Retorna a pontuacao obtida ao responder o questinario socio- ���
��          �economico-social											  ���
�������������������������������������������������������������������������͹��
���Parametro�EXPC1: Codigo do cliente  									  ���
���         �EXPC2: Loja do cliente 									  ���
�������������������������������������������������������������������������͹��
���Retorno  �EXPN1: Total de pontos obtido no question�rio                ���
�������������������������������������������������������������������������͹��
���Uso      � AP7-Telecobran�a-Cadastro de Question�rio Socio Ecom. social���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

FUNCTION CRC070_003(cCliente,cLoja)
Local cValorMacro 	:= ""
Local nTotPontos		:= 0
Local nPontos			:= 0

dbSelectArea("MAI")
dbSetOrder(1)

If dbseek(xFilial("SA1")+cCliente+cLoja )
	
	While !eof() .and. MAI->MAI_CODCLI == cCliente
		
		nTotPontos:= nTotPontos +   MAI->MAI_PONTO
		dbSkip()
		
	End
	
EndIf

If SuperGetMv("MV_PERFIL") .and. !empty(SuperGetMv("MV_PEROT"))
	
	cValorMacro := ExecMacroInServer( SuperGetMv("MV_PEROT") )
	
	If SubStr( cValorMacro,1,1) == "N"
		
		nPontos := Val( SubStr( cValorMacro,2 ))
		
	Else
		
		MsgStop( STR0016 + Chr(10) + Chr(10) + SubStr( cValorMacro, 2 ), STR0017 )	// "Houve problemas na execu��o da regra." ### "Aten��o"
		nPontos := 0
		
	EndIf
	
	nTotPontos += nPontos
	
EndIf

Return(nTotPontos)
