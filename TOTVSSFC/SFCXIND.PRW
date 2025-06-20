#INCLUDE "SFCXIND.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FILEIO.CH"
#DEFINE GERALOG .T.		// Gera��o do Log
#DEFINE LOGDETALHE .F.	// Log Detalhado

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCCalendario
Busca o Calend�rio do Centro de Trabalho da M�quina passada como
par�metro, ou do Centro de Trabalho passado como par�metro. Caso
seja inv�lido ou branco, pega a informa��o da �rea de Produ��o se
existir. Se ainda for inv�lido ou branco, busca do par�metro (MV_SFCCDCL).

@param  cCdMaq		C�digo da M�quina
@param  cCdCentro	C�digo do Centro de Trabalho
@param  cAliasCYB	Alias da tabela M�quina (CYB), caso a tabela j� esteja posicionada (Opcional)

@return
	Retorna o c�digo do calend�rio

@author Israel A Possoli
@since 17/02/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCCalendario(cCdMaq, cCdCentro, cAliasCYB)
	Local cCDCL     := ''
	Local cCdArea
	Local aArea		:= GetArea()
	Local aAreaCYB  := CYB->(GetArea())
	Local aAreaCYI  := CYI->(GetArea())
	Local aAreaCYG  := CYG->(GetArea())
	Local aAreaCYA  := CYA->(GetArea())
	Default cCdMaq 	  := Nil
	Default cAliasCYB := Nil
	
	if Empty(cCdCentro)
		// Busca o Centro de trabalho da m�quina
		If Empty(cAliasCYB)
			dbSelectArea("CYB")
			dbSetOrder(1)
			If dbSeek(xFilial("CYB") + cCdMaq)
				cCdCentro := CYB->CYB_CDCETR	
			EndIf
		Else
			cCdCentro := (cAliasCYB)->CYB_CDCETR
		EndIf
	Endif
	
	// Busca o Calend�rio do Centro de Trabalho
	If !Empty(cCdCentro)
		dbSelectArea("CYI")
		dbSetOrder(1)
		If dbSeek(xFilial("CYI") + cCdCentro)
			cCDCL   := CYI->CYI_CDCL
			cCdArea := CYI->CYI_CDARPO
			
			if !Empty(cCDCL)
				dbSelectArea('CYG')
				CYG->(dbSetOrder(1))
				if !(CYG->(dbSeek(xFilial('CYG')+cCDCL)))
					cCDCL := ''
				Endif
			Endif
		EndIf
	EndIf

	
	// Busca o Calend�rio da �rea de Produ��o
	IF Empty(cCDCL) //.AND. Empty(cCdCentro)
		dbSelectArea('CYA')
		CYA->(dbSetOrder(1))
		if CYA->(dbSeek(xFilial('CYA')+CYI->CYI_CDARPO))
			cCDCL := CYA->CYA_CDCL
			
			if !Empty(cCDCL)
				dbSelectArea('CYG')
				CYG->(dbSetOrder(1))
				if !(CYG->(dbSeek(xFilial('CYG')+cCDCL)))
					cCDCL := ''
				Endif
			Endif
		Endif
	Endif
	
	// Busca o Calend�rio do par�metro (MV_SFCCDCL)
	if !Empty(cCDCL)
		dbSelectArea('CYG')
		CYG->(dbSetOrder(1))
		if !(CYG->(dbSeek(xFilial('CYG')+cCDCL)))
			cCDCL := PADR(GetMv("MV_SFCCDCL"),TamSx3("CYZ_CDCL")[1],"")
		Endif
	Else
		cCDCL := PADR(GetMv("MV_SFCCDCL"),TamSx3("CYZ_CDCL")[1],"")
	Endif
	
	if !Empty(cCDCL)
		dbSelectArea('CYG')
		CYG->(dbSetOrder(1))
		if !(CYG->(dbSeek(xFilial('CYG')+cCDCL)))
			cCDCL := ''
		Endif
	Endif

	RestArea(aAreaCYI)
	RestArea(aAreaCYG)
	RestArea(aAreaCYA)
	RestArea(aAreaCYB)
	RestArea(aArea)
Return(cCDCL)

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCTurnoMaq
Retorna o turno da m�quina relacionado a data de refer�ncia.

A busca funciona da seguinte forma:
- Procura um turno v�lido para a data de refer�ncia;
- Caso n�o exista, busca na �rea de produ��o;
- Caso n�o exista, utiliza do par�metro MV_SFCCDTN.


@param  CDMQ  		C�digo da m�quina
@param	cDataRef   	Data de Refer�ncia, caso s� haja turno por m�quina 

@author Israel A Possoli
@since 07/02/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCTurnoMaq(cCDMQ, cDataRef)
	Local lTurnOk	:= .F.
	Local cTurno	:= ''
	Local aArea		:= GetArea()
	Local aAreaCYB  := CYB->(GetArea())
	Local aAreaCYI  := CYI->(GetArea())
	Local aAreaCYA  := CYA->(GetArea())
	Local aAreaCYL  := CYL->(GetArea())
	
	dbSelectArea("CYB")	// M�quina
	CYB->(dbSetOrder(1))
	If CYB->(dbSeek(xFilial("CYB") + cCDMQ))
	
		dbSelectArea("CYL")	// M�quinaTurno
		CYL->(dbSetOrder(2))
		CYL->(dbSeek(xFilial("CYL") + cCDMQ))
		While CYL->(!EOF()) .AND. CYL->CYL_CDMQ == cCDMQ
			// Verifica se a data de refer�ncia est� dentro da data de validade do turno da m�quin
			If cDataRef >= CYL->CYL_DTVDBG .AND. cDataRef < CYL->CYL_DTVDED
			
				dbSelectArea('CYM')
				CYM->(dbSetOrder(1))
				if !CYM->(dbSeek(xFilial('CYM')+CYL->CYL_CDTN))
					lTurnOk := .F.
				Else
					cTurno := CYL->CYL_CDTN
					lTurnOk := .T.
				Endif
							
				Exit
			EndIf
			
			CYL->(dbSkip())
		End
		
		IF !lTurnOk		
			dbSelectArea("CYI")	// Centro de Trabalho
			CYI->(dbSetOrder(1))
			IF CYI->(dbSeek(xFilial("CYI") + CYB->CYB_CDCETR))
				// Verifica se o Centro de trabalho possui �rea de Produ��o
				If !Empty(CYI->CYI_CDARPO)
					dbSelectArea("CYA") // �rea de Produ��o
					CYA->(dbSetOrder(1))
					If CYA->(dbSeek(xFilial("CYA") + CYI->CYI_CDARPO))
					
						dbSelectArea('CYM')
						CYM->(dbSetOrder(1))
						if !CYM->(dbSeek(xFilial('CYM')+CYA->CYA_CDTN))
							lTurnOk := .F.
						Else
							cTurno	:= CYA->CYA_CDTN
							lTurnOk := .T.
						Endif
					EndIf
				Endif
			EndIf
		Endif
		
		// Se o turno n�o foi encontrado pela �rea de produ��o, busca pelo Turno da M�quina
		If lTurnOk == .F.
			cTurno := PADR(GetMv('MV_SFCCDTN'),TamSx3("CYM_CDTN")[1],"")
		
			dbSelectArea('CYM')
			CYM->(dbSetOrder(1))
			if !CYM->(dbSeek(xFilial('CYM')+cTurno))
				cTurno := ''
			Endif
		Endif
	EndIf
	
	RestArea(aArea)
	RestArea(aAreaCYB)
	RestArea(aAreaCYI)
	RestArea(aAreaCYA)
	RestArea(aAreaCYL)
Return cTurno

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCParAber
Verifica se existe apontamento de parada em aberto para a m�quina

@param  cMaquina    C�digo da m�quina
@param  lMotivo     Se considera motivo de parada ou n�o

@return lRet        Se encontrou para retorna false

@author Samantha Preima
@since 06/08/2014
@version 11
/*/
//-------------------------------------------------------------------
Function SFCParAber(cMaquina, lMotivo, nTipMsg,cMsgErro)
Local lRet := .T.
Default lMotivo := .F.
Default nTipMsg := 0

cMaquina := PadR(cMaquina,TamSX3("CYV_CDMQ")[1])

dbSelectArea('CYX')
CYX->(dbSetOrder(2))
IF CYX->(dbSeek(xFilial('CYX')+cMaquina+'99991231'))

	// Verifica se � parada de setup, pois se for, a parada 
	// pode ser finalizada no apontamento de produ��o
	if lMotivo
		dbSelectArea('CYN')
		CYN->(dbSetOrder(1))
		IF !(CYN->(dbSeek(xFilial('CYN')+CYX->CYX_CDSP)) .AND. CYN->CYN_LGSU)
			
			If nTipMsg == 1
				cMsgErro := (STR0017) //"Existe apontamento de parada em aberto para a m�quina"
				lRet := .F.
			Else			
				SFCMsgErro('SFC_PARADAABER',"SFCXIND",3) // "Existe apontamento de parada em aberto para a m�quina"
				lRet := .F.
			EndIf
		Endif
	Else
		If nTipMsg == 1
			cMsgErro := (STR0017) //"Existe apontamento de parada em aberto para a m�quina"
			lRet := .F.
		Else			
			SFCMsgErro('SFC_PARADAABER',"SFCXIND",3) // "Existe apontamento de parada em aberto para a m�quina"
			lRet := .F.
		EndIf
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCApAbeMq
Verifica se existe apontamento de produ��o em aberto para a m�quina

@param  cMaquina    C�digo da m�quina

@return lRet        Se encontrou para retorna false

@author Samantha Preima
@since 06/08/2014
@version 11
/*/
//-------------------------------------------------------------------
Function SFCApAbeMq(cMaquina,cSequencia,nTipMsg,cMsgErro, cNRORPO)
Local lRet      := .T.
Local cAliasCYV := GetNextAlias()
Default nTipMsg := 0

if cSequencia == nil
	
	If cNRORPO == nil 
		BeginSql Alias cAliasCYV
			    	
			SELECT COUNT(*) AS QTD FROM %Table:CYV% CYV
				WHERE CYV.CYV_FILIAL=%xFilial:CYV% AND 
					  CYV.CYV_CDMQ=%Exp:cMaquina% AND
				  	  CYV.CYV_TPSTRP='1' AND
				  	  CYV.CYV_LGRPEO='F' AND
				      CYV.%NotDel%				  				  
		EndSql
	Else
		BeginSql Alias cAliasCYV
			    	
			SELECT COUNT(*) AS QTD FROM %Table:CYV% CYV
				WHERE CYV.CYV_FILIAL=%xFilial:CYV% AND 
					  CYV.CYV_CDMQ=%Exp:cMaquina% AND
				  	  CYV.CYV_TPSTRP='1' AND
				  	  CYV.CYV_LGRPEO='F' AND
					  CYV.CYV_NRORPO<>%Exp:cNRORPO% AND
				      CYV.%NotDel%				  				  
		EndSql
	EndIf
Else
	BeginSql Alias cAliasCYV
			    	
		SELECT COUNT(*) AS QTD FROM %Table:CYV% CYV
			WHERE CYV.CYV_FILIAL=%xFilial:CYV% AND 
				  CYV.CYV_CDMQ=%Exp:cMaquina% AND
				  CYV.CYV_TPSTRP='1' AND
				  CYV.CYV_LGRPEO='F' AND
				  CYV.CYV_NRSQRP<>%Exp:cSequencia% AND
				  CYV.%NotDel%
				  
	EndSql
Endif

IF (cAliasCYV)->QTD > 0
	If nTipMsg == 1
		cMsgErro := (STR0018) //"Existe apontamento de produ��o em aberto para esta m�quina"
		lRet := .F.
	Else			
		SFCMsgErro('SFC_APONTABEMQ',"SFCXIND",3) // "Existe apontamento de produ��o em aberto para esta m�quina"
		lRet := .F.
	EndIf
Endif

(cAliasCYV)->(dbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCApAbeSp
Verifica se existe apontamento de produ��o em aberto do split

@param  cNRORPO    Ordem de Produ��o
@param  cIDAT      Identificador Opera��o
@param  cIDATQO    Identificador Split

@return lRet        Se encontrou para retorna false

@author Samantha Preima
@since 06/08/2014
@version 11
/*/
//-------------------------------------------------------------------
Function SFCApAbeSp(cNRORPO, cIDAT, cIDATQO, cNRSQRP,nTipMsg,cMsgErro)
Local lRet      := .T.
Local cAliasCYV := GetNextAlias()
Default cNRSQRP := ""

BeginSql Alias cAliasCYV
			    	
	SELECT COUNT(*) AS QTD FROM %Table:CYV% CYV
		WHERE CYV.CYV_FILIAL = %xFilial:CYV% AND 
			  CYV.CYV_NRORPO = %Exp:cNRORPO% AND
			  CYV.CYV_IDAT   = %Exp:cIDAT% AND
			  CYV.CYV_IDATQO = %Exp:cIDATQO% AND
			  CYV.CYV_TPSTRP = '1' AND
			  CYV.CYV_LGRPEO = 'F' AND
			  CYV.CYV_NRSQRP <> %Exp:cNRSQRP% AND
			  CYV.%NotDel%
EndSql

IF (cAliasCYV)->QTD > 0
	If nTipMsg == 1
		cMsgErro := (STR0022) // "Existe apontamento de produ��o em aberto para este split"
		lRet := .F.
	Else			
		SFCMsgErro('SFC_APONTABESP',"SFCXIND",3) // "Existe apontamento de produ��o em aberto para este split"
		lRet := .F.
	EndIf
Endif

(cAliasCYV)->(dbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCSetupIn
Verifica se existe apontamento de parada de prepara��o iniciado
para a M�quina

@param  cMaquina    C�digo da m�quina

@return lRet        Se encontrou para retorna true

@author Samantha Preima
@since 24/09/2014
@version 11
/*/
//-------------------------------------------------------------------
Function SFCSetupIn(cMaquina,nTipMsg,cMsgErro)
Local lRet := .F.

Default nTipMsg := 0

cMaquina := PadR(cMaquina,TamSX3("CYV_CDMQ")[1])

dbSelectArea('CYX')
CYX->(dbSetOrder(2))
IF CYX->(dbSeek(xFilial('CYX')+cMaquina+'99991231'))

	dbSelectArea('CYN')
	CYN->(dbSetOrder(1))
	IF CYN->(dbSeek(xFilial('CYN')+CYX->CYX_CDSP)) .AND. CYN->CYN_LGSU
		If nTipMsg == 1
			cMsgErro := (STR0021) //"Existe apontamento de parada de prepara��o em aberto para a m�quina"
		EndIf
		lRet := .T.
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCExtPrep
Valida se a M�quina n�o pode iniciar apontamento pois exige prepara��o

@param  cMaquina    N�mero Ordem Produ��o

@return lRet       Se exige prepara��o para retorna false

@author Michele Girardi
@since 20/07/2020
@version 12
/*/
//-------------------------------------------------------------------
Function SFCExtPrep(cMaquina,nTipMsg,cMsgErro)
Local lRet := .T.

Default nTipMsg := 0

cMaquina := PadR(cMaquina,TamSX3("CYV_CDMQ")[1])

	dbSelectArea('CYB')
	CYB->(dbSetOrder(1))
	CYB->(dbSeek(xFilial('CYB')+cMaquina))
	
	if CYB->CYB_LGSU .AND. Empty(CYY->CYY_DTBGSU)
		If nTipMsg == 1
			cMsgErro := (STR0019) //"M�quina n�o pode iniciar apontamento pois exige prepara��o"
			lRet := .F.
		Else	
			SFCMsgErro('SFCA319_INMQPR','SFCA319', 3) // "M�quina n�o pode iniciar apontamento pois exige prepara��o"
			lRet := .F.
		EndIf
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCPerIni
Valida se a M�quina n�o pode iniciar apontamento

@param  cMaquina    N�mero Ordem Produ��o

@return lRet       Se exige n�o pode iniciar apontamento retorna false

@author Michele Girardi
@since 20/07/2020
@version 12
/*/
//-------------------------------------------------------------------
Function SFCPerIni(cMaquina, nTipMsg,cMsgErro)
Local lRet := .T.

Default nTipMsg := 0

cMaquina := PadR(cMaquina,TamSX3("CYV_CDMQ")[1])

	dbSelectArea('CYB')
	CYB->(dbSetOrder(1))
	CYB->(dbSeek(xFilial('CYB')+cMaquina))
	
	if !CYB->CYB_LGBGQO
		If nTipMsg == 1			
			cMsgErro := (STR0020)
			lRet := .F.
		Else
			SFCMsgErro('SFCA319_INIMAQ','SFCA319',3) // M�quina n�o pode iniciar apontamento
			lRet := .F.
		EndIf
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCApAbNSp
Verifica se existe apontamento de produ��o em aberto 
para a m�quina e op em outro split

@param  cMaquina    C�digo da m�quina
@param  cSplit      C�digo do split
@param  cNRORPO     N�mero da OP

@return lRet        Se encontrou para retorna false

@author Michele Girardi
@since 18/08/2020
@version 11
/*/
//-------------------------------------------------------------------
Function SFCApAbNSp(cMaquina,cSplit,nTipMsg,cMsgErro, cNRORPO)
Local lRet      := .T.
Local cAliasCYV := GetNextAlias()
Default nTipMsg := 0

BeginSql Alias cAliasCYV
			    	
	SELECT COUNT(*) AS QTD FROM %Table:CYV% CYV
	WHERE CYV.CYV_FILIAL=%xFilial:CYV% AND 
		  CYV.CYV_CDMQ=%Exp:cMaquina% AND
	  	  CYV.CYV_TPSTRP='1' AND
	  	  CYV.CYV_LGRPEO='F' AND
		  CYV.CYV_NRORPO=%Exp:cNRORPO% AND
		  CYV.CYV_IDATQO<>%Exp:cSplit% AND
	      CYV.%NotDel%				  				  
EndSql
	
IF (cAliasCYV)->QTD > 0
	If nTipMsg == 1
		cMsgErro := (STR0023) //"Existe apontamento de produ��o em aberto para esta m�quina e OP, por�m para outro Split."
		lRet := .F.
	Else			
		SFCMsgErro('SFC_APONTAMQSP',"SFCXIND",3) //"Existe apontamento de produ��o em aberto para esta m�quina e OP, por�m para outro Split."
		lRet := .F.
	EndIf
Endif

(cAliasCYV)->(dbCloseArea())

Return lRet