#INCLUDE "Protheus.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "IMPRESC.CH"

// VARIAVEIS UTILIZADAS PARA ARMAZENAR AS INFORMACOES DAS PERGUNTES:
//VARIAVEL					   ORDEM
//nTipo			MV_PAR01  01	//	ZEBRADO/GRAFICO/PRE-IMPR/GRFC ZEBRADO/GRFC GRAFICA
//cFilialDe		MV_PAR02  02	//	FILIAL DE
//cFilialAte		MV_PAR03  03	//	FILIAL ATE
//cMatDe			MV_PAR04  04	//	MATRICULA DE
//cMatAte			MV_PAR05  05	//	MATRICULA ATE
//cCCDe			MV_PAR06  06	//	CENTRO DE CUSTO DE
//cCCAte			MV_PAR07  07	//	CENTRO DE CUSTO ATE
//cTipoRes			MV_PAR08  08	//	NORMAL OU COMPLEMENTAR
//cImprCGC			MV_PAR09  09	//	IMPRIME CGC  SIM OU NAO
//dDtDemDe			MV_PAR10  10	//	DATA DEMISSAO DE
//dDtDemAte		MV_PAR11  11	//	DATA DEMISSAO ATE
//dDtGerDe			MV_PAR12  12	//	DATA GERACAO DE
//dDtGerAte		MV_PAR13  13	//	DATA GERACAO ATE
//nImprDtHom		MV_PAR14  14	//	IMPRIME DATA DE HOMOLOGACAO
//nNumVias			MV_PAR15  15	//	N� DE VIAS
//cImprFerias		MV_PAR16  16	//	IMP. FERIAS    		 AVOS OU DIAS
//dDtHomDe			MV_PAR17  17	//	DATA DE HOMOLOGA�CAO DE
//dDtHomAte		MV_PAR18  18	//	DATA DE HOMOLOGA�CAO AT
//cContato			MV_PAR19  19	//	NOME PARA CONTATO
//					MV_PAR20  20	//	RODAPE DO RECIBO
//					MV_PAR21  21	//	COMP. VERB 50
//					MV_PAR22  22	//	RG
//					MV_PAR23  23	//	NOME DO EMPREGADOR
//					MV_PAR24  24	//	TIPO DO ORGAO HOMOLOGADOR
//					MV_PAR25  25	// CODIGO DO MINISTERIO
//dDtDissidio		MV_PAR26  26	//	DT PUBLIC.DISS/ACOR
//nTipSal			MV_PAR27  27	//	TIPO DO SALARIO?
//					MV_PAR28  28	//	IMPRIMIR INF. EXTRA?
//					MV_PAR29  29	//	GRUPO DE VERBAS QUE COMPOEM A REMUNERACAO
//					MV_PAR30  30	//	IMPRIME CABECALHO EM OUTRA PAGINA?
//					MV_PAR31  31	//	AJUSTA LINHAS EM BRANCO?
//cImpr13Sal		MV_PAR32  32	//	IMP. 13� SAL�RIO
//cTelefone		MV_PAR33  33	//	DDD/TELEFONE
//nSimples			MV_PAR34  34	//	OPTANTE DO SIMPLES
//dEntregaGRFC	MV_PAR35  35	//	DT. ENTREGA GRFC
//					MV_PAR36  36	//	TODAS RESCISOES COMPL?

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���RdMake    � ImpResc  � Autor � Mauro                        � Data � 10.03.97 ���
��������������������������������������������������������������������������������Ĵ��
���Descricao � Impressao da Rescisao em Formulario Continuo                      ���
��������������������������������������������������������������������������������Ĵ��
���Sintaxe e � ImpResC                                                           ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                          ���
��������������������������������������������������������������������������������Ĵ��
���               ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.              ���
��������������������������������������������������������������������������������Ĵ��
���PROGRAMADOR � DATA     �CHAMADO/REQ�  MOTIVO DA ALTERACAO                     ���
��������������������������������������������������������������������������������Ĵ��
��|MOHANAD     |07/02/2014|M12RH01    |UNIFICACAO DA FOLHA V12                   |��
��|            |          |     197401|                                          |��
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/

Function GPER999()        // incluido pelo assistente de conversao do AP5 IDE em 05/07/00
Local Imprime		:= 0
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= {"RA_NOME", "RA_NUMCP", "RA_SERCP", "RA_UFCP", "RA_PIS", "RA_CTDPFGTS", "RA_NASC", "RA_ADMISSA", "RG_DATADEM"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

//Declaracao de variaveis utilizadas no programa atraves da funcao
//SetPrvt, que criara somente as variaveis definidas pelo usuario,
//identificando as variaveis publicas do sistema utilizadas no codigo
//Incluido pelo assistente de conversao do AP5 IDE
SetPrvt("NLIN,CONTADOR,LNULL,DET")

nLin    := 0
Contador:= 1
lNull   := .F.

//Tratamento de acesso a Dados Sens�veis
If lBlqAcesso
	//"Dados Protegidos- Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Saiba mais em {link documenta��o centralizadora}"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Return
EndIf

fCabecalho()

For Imprime := 1 to Max(Len(aPdv),Len(aPdd))
	If Max(Len(aPdv)/2,Len(aPdd)) <= 16
		If Imprime <= 16 .And. Imprime <= Len(aPdv)
			Det := Space(3) + aPdv[Imprime]
		Else
			Det := Space(44)
		Endif

		If Imprime + 16 <= Len(aPdv)
			Det := Det + Space(3) + aPdv[Imprime + 16]
		Else
			Det := Det + Space(45)
		Endif

		If Imprime <= Len(aPdd)
			Det := Det + Space(3) + aPdd[Imprime]
		Else
			Det := Det + Space(45)
		EndIf

		If Len(Alltrim(Det)) <> 0
			@ nLin,0 PSAY ( Det )
			nLin := nLin + 1
			Contador := Contador + 1
		Else
			Exit
		Endif
	Else
		If Imprime <= Len(aPdv)/2 .And. Imprime <= Len(aPdv)
			Det := Space(3) + aPdv[Imprime]
		Else
			Det := Space(44)
		Endif

		If Imprime + If(Len(aPdv)%2>0,Len(aPdv)/2-1,Len(aPdv)/2) <= Len(aPdv)
			Det := Det + Space(3) + aPdv[Imprime + Len(aPdv)/2]
		Else
			Det := Det + Space(44)
		Endif

		If Imprime <= Len(aPdd)
			Det := Det + Space(3) + aPdd[Imprime]
		Else
			Det := Det + Space(44)
		EndIf
		Alert(Str(Len(AllTrim(Det))))
		If Len(Alltrim(Det)) <> 0
			@ nLin,0 PSAY ( Det )
			nLin := nLin + 1
			Contador := Contador + 1
		Else
			Exit
		Endif

		If Contador > 16
			lNull := .T.
			fRodape()
			lNull := .F.
			fCabecalho()
		EndIf
	EndIf
Next

fRodape()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fCabecalho� Autor � Recursos Humanos      � Data � 04.11.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Impressao do CABECALHO Modo Grafico                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RdMake                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fCabecalho()

Local nPenunSal	:= 0

nLin := 1
@ nLin,0 PSAY AvalImp( 132 )
nLin := nLin + 1
@ nLin,0 PSAY ( Space(3) + aInfo[3] + Space(32) + Alltrim(cCodFgts) )
nLin := nLin + 1
@ nLin,0 PSAY ( Chr(13) )
nLin := nLin + 1
@ nLin,0 PSAY ( Space(3) + aInfo[4] )
nLin := nLin + 1
@ nLin,0 PSAY ( Chr(13) )
nLin := nLin + 1
@ nLin,0 PSAY ( Space(3) + aInfo[7] + Space(6) + "               " + Space(12) + aInfo[5] + Space(19) + aInfo[6] )
nLin := nLin + 1
@ nLin,0 PSAY ( Chr(13) )
nLin := nLin + 1
@ nLin,0 PSAY ( Space(3) + Subs(SRA->RA_BCDPFGT,1,3)+'-'+DescBco(SRA->RA_BCDPFGT,sRA->rA_FILIAL,20) +"    "+DescBco(SRA->RA_BCDPFGT,SRA->RA_FILIAL,20,.T.)+"/" + SA6->A6_EST+ Space(21) + Subs(SRA->RA_BCDPFGT,4,5) )
nLin := nLin + 1
@ nLin,0 PSAY ( Chr(13) )
nLin := nLin + 1
@ nLin,0 PSAY ( Space(3) + SRA->RA_NOME + Space(10) + STR0001+SRA->RA_MAT+Space(6)+STR0002+SRA->RA_CC+Space(18)+ SRA->RA_NUMCP + Space(15) + SRA->RA_SERCP + Space(07) + SRA->RA_UFCP )	//"Matr.:"###"C.Custo:"
nLin := nLin + 1
@ nLin,0 PSAY ( Chr(13) )
nLin := nLin + 1
@ nLin,0 PSAY ( Space(3) + SRA->RA_PIS + Space(19) + Iif(SRA->RA_CTDPFGTS=="999999999999",SRA->RA_NUMCP+SRA->RA_SERCP,SRA->RA_CTDPFGT) + Space(16) + DtoC(SRA->RA_NASC) + Space(11) + DtoC(SRA->RA_ADMISSA) + Space(11) + DtoC(SRA->RA_OPCAO) + Space(11) + DtoC(SRG->RG_DATADEM) )
nLin := nLin + 1
@ nLin,0 PSAY ( Chr(13) )
nLin := nLin + 1

//TODO
If nTipSal == 1 // Sal�rio incorporado
	nPenunSal := PenunSal(SRA->RA_ADMISSA, SRG->RG_DATADEM, cVerbas_Aux, acodfol[318, 1])
	nPenunSal := If(Empty(nPenunSal), SRG->RG_SALMES, nPenunSal)
Else
	nPenunSal := SRG->RG_SALMES
EndIF

@ nLin,0 PSAY ( Space(3) + Transform(nPenunSal, "@E 999,999,999.99") + Space(18) + DtoC(SRG->RG_DTAVISO) + Space(10) + Transform(nPerPensa, "@E 99.99") + Space(08) + cCausa + Space(30) + cCodSaq )

nLin := nLin + 1
@ nLin,0 PSAY ( Chr(13) )
nLin := nLin + 1
@ nLin,0 PSAY ( Chr(13) )
Contador := 1

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Funcao   �fRodape   �Autor  �Microsiga           � Data �  04/11/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �fRodape - Impressao do Rodape da Rescisao (Grafico).        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fRodape()

Contador := Contador - 1
nLin := nlin + (17-Contador)
nLin := nLin + 1
@ nLin,0 PSAY ( Space(3) + STR0003+SPACE(1)+If(lNull,Space(14),Transform(nProv,"@E 999,999,999.99")) + Space(17) + STR0004+SPACE(1)+If(lNull,Space(14),Transform(nDesc,"@E 999,999,999.99")) + Space(14) + STR0005+SPACE(1)+If(lNull,Space(14),Transform(nProv - nDesc,"@E 999,999,999.99")) )	//"TOTAL PROVENTOS :"###"TOTAL DESCONTOS :"###"LIQUIDO A RECEBER :"
nLin := nLin + 3
@ nLin,3 PSAY If(nImprDtHom == 1 .And. !lNull , Rtrim(aInfo[5]) + " - "+ Dtoc(SRG->RG_DATAHOM)  , "        " )
nLin := nLin + 15
@ nLin,0 PSAY ( Space(3) + If (cImpSac #"N" .And. !lNull ,SRA->RA_NOME," "))
nLin := nLin + 12

nLin := nLin + 8

Return Nil

/*/{Protheus.doc} PenunSal
Obtem o penultimo salario do funcionario antes da demissao.
@author Mauricio MR
@since 16/02/11
@param dAdmissao, date, Data de admiss�o do funcion�rio
@param dDemissao, date, Data de demiss�o do funcion�rio
@param cVerbas, characters, Verbas que ser�o incorporadas ao sal�rio
@param cVerbSal, characters, C�digo da verba de sal�rio
/*/
Static Function PenunSal(dAdmissao, dDemissao, cVerbas, cVerbSal)

	Local nEpoch		:= Set(_SET_EPOCH)	//OBTEM A CONFIGURACAO DE SECULO CORRENTE
	Local aArea			:= GetArea()
	Local aSRCArea		:= SRC->(GetArea())
	Local aPerAtual		:= {}
	//DATA DO PENULTIMO SALARIO
	Local dDTPenSal
	Local dDataDe
	Local dDataAte
	Local nValPenSal
	Local cFilMat		:= SRA->(RA_FILIAL+RA_MAT)

	DEFAULT dAdmissao	:= SRA->RA_ADMISSA
	DEFAULT dDemissao	:= SRG->RG_DATADEM
	DEFAULT cVerbas		:= ''
	DEFAULT cVerbSal	:= acodfol[318, 1]

	fGetPerAtual(@aPerAtual, xFilial("RCH", SRA->RA_FILIAL), SRA->RA_PROCES, fGetCalcRot('1'))
	If ! Empty(aPerAtual)
		dDataDe  := aPerAtual[1, 6]
		dDataAte := aPerAtual[1, 7]
	EndIf

	Set(_SET_EPOCH, 1920)	//ALTERA O SET EPOCH PARA 1920

	dDTPenSal := If(Month(dDemissao) - 1 != 0, CtoD( '01/' + StrZero(Month(dDemissao) - 1, 2) + '/' + Right(StrZero(Year(dDemissao), 4), 2)), CtoD('01/12/' + Right(StrZero(Year(dDemissao) - 1, 4), 2)) )

	If MesAno(dDtPenSal) < MesAno(dAdmissao)
		dDTPenSal 	:= CTOD("  /  /  ")
		nValPenSal 	:= 0.00
	Endif
	//PENULTIMO
	If ! Empty(dDTPenSal)
		nValPenSal := fBuscaAcm(cVerbas + cVerbSal, , dDTPenSal, dDTPenSal, "V")	//SALARIO DO MES + VERBAS QUE INCORPORARAM  AO SALARIO
		//PESQUISA NO MOVIMENTO MENSAL QUANDO O MES CORRENTE ESTIVER ABERTO
		//E NAO ENCONTRAR SALARIO NOS ACUMULADOS ANUAIS
		If nValPenSal == 0 .AND. MesAno(dDTPenSal) == MesAno(dDataDe)
			If SRC->(Dbseek(cFilMat))
				While ! SRC->(Eof()) .And. cFilMat == SRC->(RC_FILIAL + RC_MAT)
					If SRC->RC_PD $ cVerbas + cVerbSal
						nValPenSal += SRC->RC_VALOR
					Endif
					SRC->(dbskip())
				Enddo
			Endif
		Endif
	Endif

	//RESTAURA O SET EPOCH PADRAO
	Set(_SET_EPOCH, nEpoch)

	RestArea(aSRCArea)
	RestArea(aArea)

Return(nValPenSal)
