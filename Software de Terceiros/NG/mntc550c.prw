#INCLUDE "TOTVS.CH"
#INCLUDE "mntc550.ch"

//--------------------------------------------------
/*/{Protheus.doc} MNTC550C
Monta um browse com os problemas da ordem

@author Cauê Girardi Petri
@since 22/11/22
@return Nil
/*/
//--------------------------------------------------
Function MNTC550C()
	
    Local cFuncBkp := FunName()
    Local OldRot
	Local aRotina :=  MenuDef()   

	Private cAliSTJTp := GetNextAlias()
	Private cCadastro := OemtoAnsi(STR0005) //"Ordem Servico Manutencao"
	Private lCORRET   := .F.
    
    SetFunName( 'MNTC550C' )


	OldRot  := aClone(aROTINA)
	cMESTRE := "STJ"

	//---------------------------------------------------------------------
	//| Variaveis utilizadas para parametros                         	  |
	//| mv_ch1     // Tipo de Ordens (Todas, Abertas, Terminadas )   	  |
	//| mv_ch2     // De                                             	  |
	//| mv_ch3     // Ate                                            	  |
	//---------------------------------------------------------------------

	If !Pergunte("MNT550",.T.)
		aRotina := aClone( OldRot )
		Return
	EndIf

	//---------------------------------------------------------------------
	//| Variaveis utilizadas para parametros  Retorno                     |
	//| mv_par01 = 1 // Ordens de Manutencao abertas ou terminadas        |
	//| mv_par01 = 2 // Ordens de Manutencao abertas                      |
	//| mv_par01 = 3 // Ordens de Manutencao terminadas                   |
	//---------------------------------------------------------------------
	M->TI_PLANO := STI->TI_PLANO

	dbSelectArea("STJ")

	bWHILE := {|| !EoF() .And. STJ->TJ_PLANO == M->TI_PLANO}

	If MV_PAR01 == 1
		bFOR := {|| TJ_FILIAL  == xFilial("STJ") .And. TJ_PLANO == M->TI_PLANO .And.;
		TJ_DTMPINI >= MV_PAR02 .And. TJ_DTMPINI <= MV_PAR03}
	ElseIf MV_PAR01 == 2
		bFOR := {|| TJ_FILIAL  == xFilial("STJ") .And. TJ_PLANO == M->TI_PLANO .And.;
		TJ_SITUACA == "L" .And. TJ_TERMINO != "S"                  .And.;
		TJ_DTMPINI >= MV_PAR02 .And. TJ_DTMPINI <= MV_PAR03}
	ElseIf MV_PAR01 == 3
		bFOR := {|| TJ_FILIAL  == xFilial("STJ") .And. TJ_PLANO == M->TI_PLANO .And.;
		TJ_TERMINO == "S" .And. TJ_DTMPINI >= MV_PAR02             .And.;
		TJ_DTMPINI <= MV_PAR03 }
	EndIf

	dbSelectArea("STJ")
	dbSetOrder(05)

	NGCONSULTA(cAliSTJTp, M->TI_PLANO, bWHILE, bFOR, aRotina, {} )

	dbSelectArea("STJ")
	dbSetOrder(01)
	aRotina := aClone( OldRot )

    SetFunName( cFuncBkp )

Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} Menudef
Menu da rotina

@author Cauê Girardi Petri
@since 17/11/22
@return array
/*/
//---------------------------------------------------------------------
Static Function Menudef()

    Local aReturn  := {{STR0006,'NGVISUAL(,,, "NGCAD01" )', 0, 2},; //"Visual."
				        {STR0007,"MNTC550D" , 0, 3},;    		//"Detalhes"
				        {STR0008,"MNTC550E"  , 0, 4},;    		//"Ocorren."
				        {STR0009,"MNTC550A", 0, 4},;    		//"proBlemas"
				        {STR0018,"NGATRASOS" , 0, 4, 0},; 		//"Motivo Atraso"
				        {STR0010,"MNTC550B"  , 0, 4},;    		//"Etapas"
				        {STR0038,"MNTC550IMPR", 0, 4},;	  		//"Imprimir"
				        {STR0047,"MNT550DOC" , 0, 4}} 			//"Conhecimento"

Return aReturn
