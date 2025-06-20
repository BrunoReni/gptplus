#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER014.CH"
#INCLUDE "REPORT.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GPER014   �Autor  �Claudinei Soares    � Data � 12/01/2016   ���
��������������������������������������������������������������������������͹��
���Desc.     � Relatorio para conferencia dos valores acumulados de Planos ���
���          � de Saude, Odontologico, Co-Participa��o e Reembolso         ���
��������������������������������������������������������������������������͹��
���Uso       � Folha de pagamento  - Brasil                                ���
��������������������������������������������������������������������������͹��
���            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.           ���
��������������������������������������������������������������������������͹��
���Programador� Data     �    FNC    | Motivo da Alteracao                 ���
��������������������������������������������������������������������������͹��
���Mariana M.  �21/01/2016�          |Inclusao do relatorio                ���
���Claudinei S.�26/01/2016�TUIFD8    |Ajustada em fNomePlano a variavel    ���
���            �          �          |cTpOrigem para nao gerar erro quando ���
���            �          �          |tipo de plano nao for faixa salarial ���
���Claudinei S.�27/01/2016�TUIFD8    |Ajustada em fNomePlano a variavel    ���
���            �          �          |cTpOrigem para nao gerar erro quando ���
���            �          �          |tipo de plano nao for faixa salarial ���
���            �          �          |e possuir agregados.                 ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function GPER014()

Local	oReport
Local	aArea 		:= GetArea()
Private cPerg		:= "GP014R"
Private aOrd		:={	OemToAnsi(STR0004)+"+"+OemToAnsi(STR0005)+"+"+OemToAnsi(STR0007) }	//,;	//1 - "Matricula + Lan�amentos + Verba"	
Private cAliasQry	:= ""
Private cTitulo	:= OemToAnsi(STR0001)	//"Valores Acumulados de "
Private nOrdem		:= 1
Private nRelat	:= 2
Private lCorpManage	:= fIsCorpManage( FWGrpCompany() )	// VERIFICA SE O CLIENTE POSSUI GEST�O CORPORATIVA NO GRUPO LOGADO
If lCorpManage
	Private lEmpFil	  	:= !Empty(FWSM0Layout(cEmpAnt, 1)) // VERIFICA SE POSSUI TRATAMENTO PARA EMPRESA
	Private cLayoutGC 	:= FWSM0Layout(cEmpAnt)
	Private nStartEmp	:= At("E",cLayoutGC)
	Private nStartUnN	:= At("U",cLayoutGC)
	Private nEmpLength:= Len(FWSM0Layout(cEmpAnt, 1))
	Private nUnNLength:= Len(FWSM0Layout(cEmpAnt, 2))
EndIf 

Private aFldRot 	:= {'RA_NOME','RB_NOME','RHN_NOME'}
Private aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Private lOfuscaSRA 	:= .F. 
Private lOfuscaSRB 	:= .F. 
Private lOfuscaRHN 	:= .F. 
Private aFldOfusca	:= {}
Private aTabForn	:= {}

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
		lOfuscaSRA := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RB_NOME" } ) > 0
		lOfuscaSRB := FwProtectedDataUtil():IsFieldInList( "RB_NOME" )
	ENDIF
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RHN_NOME" } ) > 0
		lOfuscaRHN := FwProtectedDataUtil():IsFieldInList( "RHN_NOME" )
	ENDIF
ENDIF

Pergunte(cPerg,.F.)

oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportDef  � Autor � Claudinei Soares      � Data �12/01/2016���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Valores por Verba Vertical                      ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � GPER014                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function ReportDef()
Local oReport 
Local oSecFun 
Local oSecLan      
Local oSecPD
Local oSecNom
Local cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0002) + OemToAnsi(STR0003)
//"RELATORIO POR CODIGO" ### "SERA�IMPRESSO DE ACORDO COM OS PARAMETROS SOLICITADOS PELO" ### "USUARIO."
//CRIACAO DOS COMPONENTES DE IMPRESSAO

nRelat	:= mv_par05

If nRelat == 1
	cTitulo := OemToAnsi(STR0001) + OemToAnsi(STR0008)// Valores Acumulados + Assist�ncia M�dica e Odontol�gica
Else
	cTitulo := OemToAnsi(STR0001) + OemToAnsi(STR0010)// Valores Acumulados + Co-Participa��o e Reembolso
EndIf


DEFINE REPORT oReport NAME "GPER014" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| R014Imp(oReport)} DESCRIPTION cDesc1

	oReport:SetTotalInLine(.F.)     // PARA TOTALIZAR EM LINHAS
	oReport:SetDynamic()   

	DEFINE SECTION oSecFun OF oReport TITLE OemToAnsi(STR0004) TABLES "SRA" ORDERS aOrd	//"MATRICULA"

		DEFINE CELL NAME "RA_FILIAL"  OF oSecFun ALIAS "SRA"
		DEFINE CELL NAME "RA_MAT"     OF oSecFun ALIAS "SRA" SIZE 15 
		DEFINE CELL NAME "RA_NOME"    OF oSecFun ALIAS "SRA" BLOCK {||(cAliasQry)->NOME}
		DEFINE CELL NAME "RA_SALARIO" OF oSecFun ALIAS "SRA" 
	
		oSecFun:SetTotalInLine(.F.)
		oSecFun:Cell("RA_NOME"   ):SetCellBreak(.T.)
		oSecFun:Disable()
		oSecFun:SetDynamicKey(OemToAnsi(STR0004))	//"MATRICULA"

	DEFINE SECTION oSecPD OF oReport TITLE OemToAnsi(STR0004) TABLES "SRA","RHS","RHP" //"MATRICULA"

		DEFINE CELL NAME "RA_FILIAL" 	OF oSecPD ALIAS "SRA"
		DEFINE CELL NAME "RA_MAT" 		OF oSecPD ALIAS "SRA"

		DEFINE CELL NAME "NOME"   OF oSecPD TITLE OemToAnsi(STR0006) SIZE 45	PICTURE "@!"	; 	//"Nome"
			BLOCK {|| fNomeRel((cAliasQry)->ORIGEM)  }
		DEFINE CELL NAME "VERBA"  OF oSecPD TITLE OemToAnsi(STR0007) SIZE 08 PICTURE "@!"	;	//"Verba"
			BLOCK {||(cAliasQry)->PD}
		DEFINE CELL NAME "TPFORN" OF oSecPD TITLE OemToAnsi(STR0009) SIZE 25 PICTURE "@!"	;	//"Tipo Fornecedor"
			BLOCK {||Upper((cAliasQry)->TPFORN + "-" + Iif( (cAliasQry)->TPFORN=="1",OemToAnsi(STR0020), OemToAnsi(STR0021)))} //"Ass. M�dica" / "Ass. Odontol."
		DEFINE CELL NAME "FORNECEDOR" OF oSecPD TITLE OemToAnsi(STR0022) SIZE 40 PICTURE "@!"	;	//"Fornecedor"
			BLOCK {||fNomeForn( (cAliasQry)->TPFORN) }
		DEFINE CELL NAME "TPPLANO" OF oSecPD TITLE Iif(nRelat ==1, OemToAnsi(STR0023), OemToAnsi(STR0024)) SIZE 30 PICTURE "@!"	;	//"Tipo Plano" / "Tipo Lan�amento"
			BLOCK {||fTipoPlan((cAliasQry)->TPPLAN) }	
		If nRelat == 1
			DEFINE CELL NAME "PLANO" OF oSecPD TITLE OemToAnsi(STR0025) SIZE 30 PICTURE "@!"	;	//"Nome Plano"
				BLOCK {||fNomePlano((cAliasQry)->TPFORN, (cAliasQry)->TPPLAN, ,(cAliasQry)->ORIGEM) }
		Endif
		DEFINE CELL NAME "CNPJ" OF oSecPD TITLE OemToAnsi(STR0026) SIZE 30 PICTURE "@R 99.999.999/9999-99"	;	//"CNPJ"
			BLOCK {||fNomePlano((cAliasQry)->TPFORN, (cAliasQry)->TPPLAN,.T.,(cAliasQry)->ORIGEM)}

		oSecPD:SetLeftMargin(10)

		oSecPD:Cell("RA_FILIAL"):Disable()
		oSecPD:Cell("RA_MAT"   ):Disable()

		oSecPD:SetTotalInLine(.F.)
		oSecPD:Cell("NOME"   ):SetCellBreak(.T.)
		oSecPD:Disable()
		oSecPD:SetDynamicKey(OemToAnsi(STR0005))	//"LAN�AMENTOS"

	DEFINE SECTION oSecLan OF oReport TITLE OemToAnsi(STR0004) TABLES "SRA","RHS", "RHP"	//MATRICULA

		DEFINE CELL NAME "RA_FILIAL" 	OF oSecLan ALIAS "SRA"
		DEFINE CELL NAME "RA_MAT" 		OF oSecLan ALIAS "SRA"

		DEFINE CELL NAME "ORIGEM"     OF oSecLan TITLE OemToAnsi(STR0027) SIZE 14	PICTURE "@!"	; 	//"Origem"
			BLOCK {||Upper((cAliasQry)->ORIGEM)+ "-" + Iif( (cAliasQry)->ORIGEM=="1",OemToAnsi(STR0031), Iif( (cAliasQry)->ORIGEM=="2",OemToAnsi(STR0032),OemToAnsi(STR0033)) )} //"TITULAR" / "DEPENDENTE" / "AGREGADO"
		DEFINE CELL NAME "NOME"   OF oSecLan TITLE OemToAnsi(STR0006) SIZE 45	PICTURE "@!"	; 	//"Nome"
			BLOCK {|| fNomeRel((cAliasQry)->ORIGEM)  }
		DEFINE CELL NAME "COMPETEN"   OF oSecLan TITLE OemToAnsi(STR0028) SIZE 15	PICTURE "@!" 	;	//"Ano/M�s"
			BLOCK {||Upper((cAliasQry)->COMPPG)}
		DEFINE CELL NAME "VERBA"  OF oSecLan TITLE OemToAnsi(STR0007) SIZE 08 PICTURE "@!"	;	//"Verba"
			BLOCK {||(cAliasQry)->PD}
		DEFINE CELL NAME "VALOR" OF oSecLan TITLE OemToAnsi(STR0029) SIZE 15 PICTURE "@E 99,999,999,999.99"	;	//"Valor"
			BLOCK {||(cAliasQry)->VALOR}
		DEFINE CELL NAME "PAGAMENTO"   OF oSecLan TITLE OemToAnsi(STR0030) SIZE 17	PICTURE "@!" 	;	//"Data Pagto."
			BLOCK {||STOD((cAliasQry)->DDATA)}

		oSecLan:SetLeftMargin(20)
		
		oSecLan:Cell("VERBA" ):SetHeaderAlign("LEFT")
		oSecLan:Cell("VALOR" ):SetHeaderAlign("CENTER")
		oSecLan:Cell("PAGAMENTO" ):SetHeaderAlign("CENTER")

		oSecLan:Cell("ORIGEM"   ):Disable()
		oSecLan:Cell("NOME"   ):Disable()
		oSecLan:Cell("RA_FILIAL"   ):Disable()
		oSecLan:Cell("RA_MAT"   ):Disable()
		oSecLan:Cell("VERBA"   ):Disable()

		oSecLan:SetTotalInLine(.F.)
		oSecLan:SetCharSeparator(": ")     
		oSecLan:Disable()
		oSecLan:SetDynamicKey(OemToAnsi(STR0007))	//"VERBA"

Return(oReport)

/*
�������������������������������������������������������������������������������
���Fun�ao    � R014Imp    � Autor � Claudinei Soares      � Data �12/01/2016���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Valores por Verba                               ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � GPER014                                                      ���
�������������������������������������������������������������������������������*/
Static Function R014Imp(oReport)
Local oSectFunc
Local oSectPd
Local oSectLanc
Local cFiltro 		:= ""   
Local cFiltroC 		:= ""   
Local cSitQuery		:= ""
Local cOrdem		:= ""
Local cTitFun		:= ""
Local cCpoAdic		:= ""
Local cJoin			:= ""
Local cNotDel		:= ""
Local cAnoMesI := (substr(mv_par03,3,4) + substr(mv_par03,1,2))
Local cAnoMesF := (substr(mv_par04,3,4) + substr(mv_par04,1,2))
Local nReg			:= 0
Private cNomAlias	:= ""
Private lSubsTp		:=  "MSSQL" $  AllTrim( Upper( TcGetDb() ) ) .Or. AllTrim( Upper( TcGetDb() ) ) == 'SYBASE'

nRelat			:= mv_par05
cSituacao   	:= mv_par06
cCategoria 	:= mv_par07
nTipoForn		:= mv_par08

oSectFunc 	:= oReport:Section(1)
oSectPd 	:= oReport:Section(2)
oSectLanc	:= oReport:Section(3)

If nRelat == 1
	cMov := "RHS"
Else
	cMov := "RHP"
Endif

If !(AllTrim(oReport:Title()) == cTitulo)
	cTitulo	:= oReport:Title()
Endif

If nRelat == 1
	cTitulo := OemToAnsi(STR0001) + OemToAnsi(STR0008)// Valores Acumulados + Assist�ncia M�dica e Odontol�gica
Else
	cTitulo := OemToAnsi(STR0001) + OemToAnsi(STR0010)// Valores Acumulados + Co-Participa��o e Reembolso
EndIf

oReport:SetTitle(cTitulo)


oSectFunc:Cell("RA_MAT"    ):Enable()
oSectFunc:Cell("RA_NOME"   ):Enable()


DEFINE BREAK oBreakNom OF oSectLanc WHEN  oSectLanc:Cell("NOME") TITLE STR0012 //"TOTAL DO FUNCION�RIO"
DEFINE FUNCTION NAME "UTOTNOM" FROM oSectLanc:Cell("VALOR")  FUNCTION SUM     BREAK oBreakNom NO END SECTION NO END REPORT TITLE OemToAnsi(STR0012) PICTURE "@E 99,999,999,999.99" 	//"VALOR"

oBreakNom:OnBreak({|x,y|cTitFun:=OemToAnsi(STR0011)+" "+x})	 //"TOTAL DO "
oBreakNom:SetTotalText({||cTitFun})
oBreakNom:SetTotalInLine(.F.)

If nRelat == 1
	cCpoQuebra	:= "RHS_FILIAL"
	cNomAlias	:= "RHS_CODFOR"
	cNAlias	:= "RHS.RHS_"
Else
	cCpoQuebra	:= "RHP_FILIAL"         
	cNomAlias	:= "RHP_CODFOR"
	cNAlias	:= "RHP.RHP_"
Endif

DEFINE BREAK oBreakFil OF oReport WHEN  oSectFunc:Cell("RA_FILIAL") TITLE STR0012 //"TOTAL DO FUNCION�RIO"

cSitQuery	:= ""
For nReg:=1 to Len(cSituacao)
	cSitQuery += "'"+Subs(cSituacao,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cSituacao)
		cSitQuery += "," 
	Endif
Next nReg     

cCatQuery	:= ""
For nReg:=1 to Len(cCategoria)
	cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCategoria)
		cCatQuery += "," 
	Endif
Next nReg

MakeSqlExpr(cPerg)

cOrdem := "%RA_FILIAL,RA_MAT,ORIGEM,PD,CODIGO,TPFORN,DDATA%"

cSitQuery	:= "%" + cSitQuery + "%"
cCatQuery	:= "%" + cCatQuery + "%"
cAliasQry	:= GetNextAlias()

//-- Filial
If !Empty(mv_par01)
	cFiltro += mv_par01
EndIf

//=== Matricula
If !Empty(mv_par02)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro	+= mv_par02
EndIf

//=== Data Inicio
If !Empty(mv_par03)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	If lSubsTp
		cFiltro += " SUBSTRING("+cNAlias+"DATPGT,1,6) >=  '" + cAnoMesI + "'"
	Else
		cFiltro += " SUBSTR("+cNAlias+"DATPGT,1,6) >=  '" + cAnoMesI + "'"
	EndIf
EndIf

//=== Data Fim
If !Empty(mv_par04)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	If lSubsTp
		cFiltro += " SUBSTRING("+cNAlias+"DATPGT,1,6) <=  '" + cAnoMesF + "'"
	Else
		cFiltro += " SUBSTR("+cNAlias+"DATPGT,1,6) <=  '" + cAnoMesF + "'"
	EndIf
EndIf

//=== Tipo Fornecedor
If mv_par08 == 1
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += cNAlias+ "TPFORN = '1'"
ElseIf mv_par08 == 2
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += cNAlias+ "TPFORN = '2'"	
EndIf

//=== Fornecedor M�dico
If !Empty(mv_par09)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par09
Endif

//=== Fornecedor Odontol�gico
If !Empty(mv_par10)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par10
Endif

If nRelat == 1
	//=== Tipo de Plano De e Tipo Plano Ate
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro +="RHS.RHS_TPPLAN >= '"+ Alltrim(STR(mv_par11)) +"' AND RHS.RHS_TPPLAN <= '" + Alltrim(STR(mv_par12)) + "'"
Endif

If !Empty(cFiltro)
	cFiltroC	+= " AND "+cFiltro
EndIf

SRA->( dbCloseArea() ) //Fecha o SRA para uso da Query

If nRelat = 2
	If lSubsTp
		cCpoAdic	:= "% , TPPLAN = '6', PLANO = '6' %"
	Else
		cCpoAdic	:= "% , '6' AS TPPLAN, '6' AS PLANO %"	
	EndIf
Endif
cJoin		:= "%%"
cNotDel		:= "%%"
BEGIN REPORT QUERY oSectFunc

cFiltroC	:= Iif(Empty(cFiltroC),"%%","%"+cFiltroC+"%")
cFiltro		:= Iif(Empty(cFiltro ),"%%","%"+cFiltro +"%")
If nOrdem == 2
	cTitulo += " + " + OemToAnsi(STR0004)	//MATRICULA
EndIf

If nRelat == 1
	BeginSql alias cAliasQry
		SELECT	SRA.RA_FILIAL,         		SRA.RA_MAT,		      	SRA.RA_NOME NOME,
				SRA.RA_SALARIO,		      	SRA.RA_SITFOLH,        	SRA.RA_NASC,
				RHS.RHS_FILIAL,		      	RHS.RHS_MAT MAT,		  	RHS.RHS_FILIAL FILIAL,
				RHS.RHS_DATPGT DDATA,      	RHS.RHS_ORIGEM ORIGEM,  	RHS.RHS_TPFORN TPFORN,
				RHS.RHS_CODFOR CODFOR,     	RHS.RHS_TPPLAN TPPLAN, 	RHS.RHS_PLANO PLANO,
				RHS.RHS_PD PD,		      	RHS.RHS_VLRFUN VALOR,  	RHS.RHS_COMPPG COMPPG,
				RHS.RHS_CODIGO CODIGO
		FROM %table:SRA% SRA
		INNER JOIN %table:RHS% RHS
		ON 	    SRA.RA_FILIAL = RHS.RHS_FILIAL	AND
				SRA.RA_MAT    = RHS.RHS_MAT		
		WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
		  		SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
				SRA.%notDel% %exp:cFiltroC% AND RHS.%notDel% %exp:cNotDel%
		ORDER BY %exp:cOrdem%
	EndSql
Elseif nRelat == 2
	BeginSql alias cAliasQry
		SELECT	SRA.RA_FILIAL,         	SRA.RA_MAT,		      	SRA.RA_NOME NOME,
				SRA.RA_SALARIO,	      	SRA.RA_SITFOLH,			SRA.RA_NASC,
				RHP.RHP_FILIAL,	      	RHP.RHP_MAT MAT,	      	RHP.RHP_FILIAL FILIAL,
				RHP.RHP_DATPGT DDATA,   	RHP.RHP_ORIGEM ORIGEM,  	RHP.RHP_TPFORN TPFORN,
				RHP.RHP_CODFOR CODFOR,  	RHP.RHP_PD PD,	      	RHP.RHP_VLRFUN VALOR,
				RHP.RHP_COMPPG COMPPG,	RHP.RHP_CODIGO CODIGO,  	RHP.RHP_TPLAN TPLAN 	
				%exp:cCpoAdic%
		FROM %table:SRA% SRA
		INNER JOIN %table:RHP% RHP
		ON 	  	SRA.RA_FILIAL = RHP.RHP_FILIAL	AND
				SRA.RA_MAT    = RHP.RHP_MAT		
		WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
		   		SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
				SRA.%notDel% %exp:cFiltroC% AND RHP.%notDel% %exp:cNotDel%
		ORDER BY %exp:cOrdem%
	EndSql 
Endif

END REPORT QUERY oSectFunc

fCarrTab( @aTabForn, "S016", Nil)
fCarrTab( @aTabForn, "S017", Nil)

oSectPd:SetParentQuery()
oSectPd:SetParentFilter({|cParam|FILIAL+MAT == cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT})

oSectLanc:SetParentQuery()
If nRelat == 1
	oSectLanc:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT+(cAliasQry)->PD+(cAliasQry)->NOME+(cAliasQry)->ORIGEM+(cAliasQry)->CODIGO == cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT+(cAliasQry)->PD+(cAliasQry)->NOME+(cAliasQry)->ORIGEM+(cAliasQry)->CODIGO})
Else
	oSectLanc:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT+(cAliasQry)->PD+(cAliasQry)->NOME+(cAliasQry)->ORIGEM+(cAliasQry)->CODIGO+(cAliasQry)->TPLAN == cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT+(cAliasQry)->PD+(cAliasQry)->NOME+(cAliasQry)->ORIGEM+(cAliasQry)->CODIGO+(cAliasQry)->TPLAN})
Endif
//-- Define o total da regua da tela de processamento do relatorio
oReport:SetMeter(LastRec())
oSectFunc:OnPrintLine({||oReport:SkipLine()})
oSectFunc:Print()

Return

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � fNomeRel		�Autor� Claudinei Soares � Data �12/01/2016�
�����������������������������������������������������������������������Ĵ
�Descri��o �Impressao do Nome do Titular, Dependente, Agregado          �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									  �
�����������������������������������������������������������������������Ĵ
� Uso      �ALL			                                                �
�����������������������������������������������������������������������Ĵ
� Retorno  �cNomeRel    														  �
�����������������������������������������������������������������������Ĵ
�Parametros�cTpOrigem                     								  �
�������������������������������������������������������������������������*/
Static Function	fNomeRel(cTpOrigem)

Local cNome 	:= ""
Local cCodUsu := ""
Local cTipo	:= ""
Local lHasDep := .F.

If cTpOrigem == "1" //Titular
	cAtCodUsu := (cAliasQry)->MAT
Else
	cAtCodUsu := (cAliasQry)->CODIGO
EndIf

cCodUsu := cAtCodUsu

If cTpOrigem == "1" //Titular
	cNome := (cAliasQry)->NOME
	cNome := If(lOfuscaSRA,Replicate('*',15),cNome)
ElseIf cTpOrigem == "2" //Dependente
	DbSelectArea( "SRB" )
	DbSetOrder( RetOrdem( "SRB", "RB_FILIAL+RB_MAT" ) )
	DbSeek( (cAliasQry)->FILIAL + (cAliasQry)->MAT, .F. )
	lHasDep := .F.
	While SRB->( !EOF() ) .and. SRB->RB_FILIAL + SRB->RB_MAT == (cAliasQry)->FILIAL + (cAliasQry)->MAT
		If SRB->RB_COD == cCodUsu
			lHasDep := .T.
			cNome := SRB->RB_NOME
			cNome := If(lOfuscaSRB,Replicate('*',15),cNome)
			Exit
		EndIf
		SRB->( DbSkip() )
	EndDo
Else
	DbSelectArea( "RHM" ) 
	DbSetOrder( RetOrdem( "RHM", "RHM_FILIAL+RHM_MAT+RHM_TPFORN+RHM_CODFOR+RHM_CODIGO"))
	DbSeek( (cAliasQry)->FILIAL + (cAliasQry)->MAT + (cAliasQry)->TPFORN + (cAliasQry)->CODFOR + (cAliasQry)->CODIGO, .F.)
	If !Eof()
		cNome := RHM->RHM_NOME
	Else						
		DbSelectArea( "RHN" ) 
		DbSetOrder( RetOrdem( "RHN", "RHN_FILIAL+RHN_MAT+DTOS(RHN_DATA)"))
		DbSeek( (cAliasQry)->FILIAL + (cAliasQry)->MAT , .F.)
		cNome := RHN->RHN_NOME //Armazena o nome para o primeiro movimento n�o ficar em branco 
		While !Eof() .AND. (cAliasQry)->FILIAL+(cAliasQry)->MAT == RHN_FILIAL+RHN_MAT  
			If RHN->RHN_CODIGO == cCodUsu .And. RHN->RHN_ORIGEM == cTpOrigem .And. RHN->RHN_TPFORN + RHN->RHN_CODFOR + RHN_PERFIM == (cAliasQry)->TPFORN + (cAliasQry)->CODFOR + SUBSTR((cAliasQry)->COMPPG,5,2)+ SUBSTR((cAliasQry)->COMPPG,1,4)
				cNome := RHN->RHN_NOME //Armazena o nome caso haja altera��o do plano
				Exit
			EndIf
			RHN->( DbSkip() )
		EndDo
	EndIf
	cNome := If(lOfuscaRHN,Replicate('*',15),cNome)
EndIf

If cTpOrigem == '1'
	cTipo := OemToAnsi(STR0031)
ElseIf cTpOrigem == '2'
	cTipo := OemToAnsi(STR0032)
Else
	cTipo := OemToAnsi(STR0033)
Endif

cNomeRel := cTipo + " - " + cNome

Return cNomeRel

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � fNomeForn		�Autor� Claudinei Soares � Data �12/01/2016�
�����������������������������������������������������������������������Ĵ
�Descri��o �Impressao do Nome do Titular, Dependente, Agregado          �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									  �
�����������������������������������������������������������������������Ĵ
� Uso      �ALL			                                                �
�����������������������������������������������������������������������Ĵ
� Retorno  �cNomeForn    														  �
�����������������������������������������������������������������������Ĵ
�Parametros�cTpOrigem                     								  �
�������������������������������������������������������������������������*/
Static Function fNomeForn(cTpForn)

	Local cAux := ""
	Local nPosForn	:= 0
	Local cTabForn	:= ""
	
	DEFAULT cTpForn := "1"

	cTabForn := IIf(cTpForn == "1", "S016", "S017")

	If ( nPosForn := Ascan(aTabForn,{ |x|  AllTrim(x[1]) == cTabForn .And. AllTrim(x[2]) == AllTrim((cAliasQry)->RA_FILIAL) .And. x[5] == (cAliasQry)->CODFOR }) ) > 0
		cAux := AllTrim( aTabForn[nPosForn][6] )
	ElseIf ( nPosForn := Ascan(aTabForn,{ |x| AllTrim(x[1]) == cTabForn .And. Empty(x[2]) .And. x[5] == (cAliasQry)->CODFOR }) ) > 0
		cAux := AllTrim( aTabForn[nPosForn][6] )
	Else 
		cAux := " " 
	EndIf
	cAux := (cAliasQry)->CODFOR + "-" + cAux 
		
Return cAux		

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � fTipoPlan		�Autor� Claudinei Soares � Data �12/01/2016�
�����������������������������������������������������������������������Ĵ
�Descri��o �Impressao do Nome do Titular, Dependente, Agregado          �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									  �
�����������������������������������������������������������������������Ĵ
� Uso      �ALL			                                                �
�����������������������������������������������������������������������Ĵ
� Retorno  �cTpPlan  														  �
�����������������������������������������������������������������������Ĵ
�Parametros�cTpPlano                    								  �
�������������������������������������������������������������������������*/
Static Function fTipoPlan(cTpPlano)

Local cTpPlan := ""

If cTpPlano <> "6"
	If cTpPlano == "1"
		cTpPlan := cTpPlano + "-" + OemToAnsi(STR0013) //"Faixa Salarial" 
	ElseIf cTpPlano == "2"
		cTpPlan := cTpPlano + "-" + OemToAnsi(STR0014) //"Faixa Etaria" 
	ElseIf cTpPlano == "3"
		cTpPlan := cTpPlano + "-" + OemToAnsi(STR0015) //"Vlr Fixo por vida" 
	ElseIf cTpPlano == "4"
		cTpPlan := cTpPlano + "-" + OemToAnsi(STR0016) //"% Sobre salario" 
	ElseIf cTpPlano == "5"
		cTpPlan := cTpPlano + "-" + OemToAnsi(STR0017) //"Salarial/Etaria"
	EndIf
Else
	If (cAliasQry)->TPLAN == "1"
		cTpPlan := OemToAnsi(STR0018) //"Co-Participa��o"
	ElseIf (cAliasQry)->TPLAN == "2"
		cTpPlan := OemToAnsi(STR0019) //"Reembolso" 
	Endif
Endif

Return cTpPlan

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � fNomePlano		�Autor� Claudinei Soares � Data �12/01/2016�
�����������������������������������������������������������������������Ĵ
�Descri��o �Impressao do Nome do Plano                                  �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									  �
�����������������������������������������������������������������������Ĵ
� Uso      �ALL			                                                �
�����������������������������������������������������������������������Ĵ
� Retorno  �cNomeRel    														  �
�����������������������������������������������������������������������Ĵ
�Parametros�cTpOrigem                     								  �
�������������������������������������������������������������������������*/
Static Function fNomePlano(cTpForn, cTpPlano, lCNPJ, cTpOrigem)

	Local cAux		:= ""
	Local nBusca	:= (cAliasQry)->RA_SALARIO
	Local nPosForn	:= 0

	Default lCNPJ := .F.

	If cTpPlano == "6" .Or. lCNPJ

		If lCNPJ
			If cTpForn == "1"
				cTab := "S016"
			ElseIf cTpForn == "2"
				cTab := "S017"
			Endif

			nCol := 4
			nLinTab := 0
			fTabela(cTab,1,4,,)

			If ( nPosForn := Ascan(aTabForn,{ |x| AllTrim(x[1]) == cTab .And. AllTrim(x[2]) == AllTrim((cAliasQry)->RA_FILIAL) .And. x[5] == (cAliasQry)->CODFOR }) ) > 0
				cAux := AllTrim( aTabForn[nPosForn][7] )
			ElseIf ( nPosForn := Ascan(aTabForn,{ |x| AllTrim(x[1]) == cTab .And. Empty(x[2]) .And. x[5] == (cAliasQry)->CODFOR }) ) > 0
				cAux := AllTrim( aTabForn[nPosForn][7] )
			Else 
				cAux := " " 
			EndIf
		Else
			cAux := ""
		Endif

	Else
		If cTpForn == "1" 
			If cTpPlano == "1" 
				cTab := "S008"
				nCol := 13
			ElseIf cTpPlano == "2" 
				cTab := "S009"
				nCol := 13
			ElseIf cTpPlano == "3" 
				cTab := "S028" 
				nCol := 12
			ElseIf cTpPlano == "4" 
				cTab := "S029" 
				nCol := 15
			ElseIf cTpPlano == "5" 
				cTab := "S059"
				nCol := 14
			EndIf
		ElseIf cTpForn == "2"
			If cTpPlano == "1" 
				cTab := "S013" 
				nCol := 13
			ElseIf cTpPlano == "2" 
				cTab := "S014" 
				nCol := 13
			ElseIf cTpPlano == "3" 
				cTab := "S030" 
				nCol := 12
			ElseIf cTpPlano == "4" 
				cTab := "S031" 
				nCol := 15
			ElseIf cTpPlano == "5" 
				cTab := "S060" 
				nCol := 14
			EndIf
		EndIf
		
		nLinTab := 0
		
		fTabela(cTab,1,4,,)
		
		If cTpPlano == "1" .Or. cTpPlano == "5"
			If ( nPosTab := fPosTab( cTab, (cAliasQry)->CODFOR,"=", nCol, (cAliasQry)->PLANO,"=", 4, ,@nLinTab,,, (cAliasQry)->RA_FILIAL ) ) > 0
				If ( nPosTab := fPosTab(cTab, (cAliasQry)->PLANO,"=",4,nBusca,"<=",6,,nLinTab,,,(cAliasQry)->RA_FILIAL ) ) > 0
					cAux := fTabela(cTab,nPosTab,5,,(cAliasQry)->RA_FILIAL)
				EndIf
			Else 
				cAux := " " 
			EndIf
		ElseIf cTpPlano == "2"
			If ( nPosTab := fPosTab( cTab, (cAliasQry)->CODFOR, "=", 13, (cAliasQry)->PLANO, "=", 4, ,@nLinTab,,, (cAliasQry)->RA_FILIAL ) ) > 0
			
				If cTpOrigem == "1" 
					nBusca := Year( dDataBase ) - Year( (cAliasQry)->RA_NASC )
					If Month( (cAliasQry)->RA_NASC ) > Month( dDataBase ) .OR. ((Month( (cAliasQry)->RA_NASC )== Month( dDataBase )))
						nBusca--
					EndIf
				ElseIf cTpOrigem == "2" 
					nBusca := Year( dDataBase ) - Year( SRB->RB_DTNASC )
					If Month( SRB->RB_DTNASC ) > Month( dDataBase ) .OR. ((Month( SRB->RB_DTNASC )== Month( dDataBase )))
						nBusca--
					EndIf
				Else
					nBusca := Year( dDataBase ) - Year( RHM->RHM_DTNASC )
					If Month( RHM->RHM_DTNASC ) > Month( dDataBase ) .OR. ((Month( RHM->RHM_DTNASC )== Month( dDataBase )))
						nBusca--
					EndIf
				EndIf
		
				If ( nPosTab := fPosTab(cTab, (cAliasQry)->PLANO,"=",4,nBusca,"<=",6,,nLinTab,,,(cAliasQry)->RA_FILIAL ) ) > 0
					cAux := fTabela(cTab,nPosTab,5,,(cAliasQry)->RA_FILIAL)
				Else 
					cAux := " " 
				EndIf
			EndIf
		Else
			If ( nPosTab := fPosTab( cTab, (cAliasQry)->CODFOR,"=", nCol, (cAliasQry)->PLANO,"=", 4, ,@nLinTab,,, (cAliasQry)->RA_FILIAL ) ) > 0
				cAux := fTabela(cTab,nPosTab,5,,(cAliasQry)->RA_FILIAL)
			Else 
				cAux := " " 
			EndIf
		EndIf	
		If !Empty(cAux)	
			cAux := (cAliasQry)->PLANO + "-" + cAux 
		EndIf
	Endif

Return cAux


/*/��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 �fValComp  � Autor � Claudinei Soares       | Data �12/01/2016���
�������������������������������������������������������������������������Ĵ��
���Descricao �Ajuste de Pergunte.   		                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � < Vide Parametros Formais >							     	    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nao aplica.                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � GPER014						                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function fValComp() 
Local lRet:= .T. 
Local cMesAno := &(ReadVar())

Local aMesValid:= { "01","02","03","04","05","06","07","08","09","10","11","12" }
	//Verifica se a competencia informada e invalida e exibe uma mensagem de alerta
	If aScan( aMesValid, Subst( cMesAno, 1 , 2 ) ) == 0 
		lRet := .F.
		Aviso(STR0034 ,STR0035 + cMesAno + STR0036 + CHR(13)+CHR(10),{"Ok"}) //Formato Invalido Compet�ncia <Mes Ano Informado> Inv�lida (MMAAA) 
	Endif 

Return (lRet)
	