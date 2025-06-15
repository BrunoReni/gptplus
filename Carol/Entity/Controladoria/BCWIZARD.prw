#INCLUDE 'totvs.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} BCWizard
Fun√ß√£o principal, que tem por  obtivo abrir Wizard para  configurar as
contas contab√©is.
@param aEmpresas, array, array contendo as empresas selecionadas.

@author Rodrigo Soares  
@since 10/03/2020
/*/
//-------------------------------------------------------------------
Main Function BCWizard(aEmpresas)
    
    oProcess:SetRegua1(3)
    
    aWizard := BCWizardStr(aEmpresas)

    aWizard := BCWizardSc(aWizard)

    BCWizardTable(aWizard)
    
    BCWizardRec(aWizard)

    
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BCWizardTable
Cria a estrutura da tabela I13, que ser√° a responsavel por guardar as informa√ß√µes
provenientes do wizard.

@author Rodrigo Soares  
@since 10/03/2020
/*/
//-------------------------------------------------------------------
Function BCWizardTable(aWizard)
	Local oQuery        := Nil
	Local aTable        := {}
	Local nTable        := 1
    Local cAlias        := GetNextAlias()
    Local cAliasTMP        := GetNextAlias()
    Local oTempTable    := FWTemporaryTable():New(cAliasTMP)
    Local nI            := 0
    Local cNotIn        := ""
    Local nStatus       := 0
    Local _Stru         :={}
    Local aStruI13      :={}
    Local cCampos       :=""
    Local nX            := 0
    
    // Instancia a tabela de processos. 
    //-------------------------------------------------------------------  
    oQuery := TBITable():New( "I13", "I13" )

    If TCCanOpen( 'I13')
        oQuery:lOpen()
        //para evitar divergencia com a I13
        //Utilizo a mesma estrutura
        DBSelectArea('I13')
        aStruI13 := dBStruct()
        _Stru := aStruI13

        //tratamento para evitar quebra no caso de teste
         If(GetRemoteType() == -1)
            aEmpresas := BCLoadComp()
            for nX := 1 to len(aEmpresas) 
                aEmpresas[nX][1] := .T.
            next
            aWizard := ACLONE(aEmpresas)
        endIf

        //Tabela existente, gera um bkp das empresas que nao foram alteradas
        For nI:= 1 to Len(aWizard)
            cNotIn:= cNotIn + "'"+ AllTrim(aWizard[nI][1]) +"'"
            If nI < Len(aWizard)
                cNotIn+=","
            EndIf
        Next
        cNotIn:= "("+cNotIn+")"
        //Caso exista empresas configuradas seleciono as que nao foram alteradas
        oTemptable:SetFields( _stru )

		oTempTable:AddIndex("I131", {"I13_EMPRES", "I13_FILIAL", "I13_ISTCIA"} )
        //------------------
		//CriaÁ„o da tabela Temporaria para manter dados da I13
		//------------------
		oTempTable:Create()
        For nI:= 1 to Len(_stru)
            cCampos+=_stru[nI][1]
            If nI < Len(_stru)
                cCampos+=","
            EndIf
        Next
        //Insiro os dados na tabela temporaria
        cQuery := "INSERT INTO "+oTempTable:GetRealName()+"("+cCampos+") SELECT "+cCampos+" FROM I13 WHERE D_E_L_E_T_ = ' ' AND I13_EMPRES NOT IN"+cNotIn
        nStatus := TCSqlExec(cQuery)
		If (nStatus < 0)
			ConOut( "TCSQLError() " + TCSQLError())
		EndIf
        cQuery := "SELECT * FROM "+oTempTable:GetRealName()
        DBUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), cAlias , .T., .F. )
        //Removo os dados para garantir as alteraÁıes
        nStatus := TCSqlExec("DELETE FROM I13")
		If (nStatus < 0)
			ConOut( "TCSQLError() " + TCSQLError())
		EndIf
        //Empresas existentes que nao sofreram alteracoes 
        // sao adicionadas novamente
        DBSelectArea('I13')
        (cAlias)->(dBGoTop())
        While (cAlias)->(!EOF())
            If( RecLock( "I13", .t. ) )
                For nI:=1 to Len(_Stru)
                    I13->&(_Stru[nI][1]):=(cAlias)->&(_Stru[nI][1])
                Next
                I13->( MsUnlock() )
            ENDIF
            (cAlias)->(DBSkip())
        End
        (cAlias)->(DbCloseArea())
        oTempTable:Delete()
    Else
        // Cria a tabela de processos. 
        //-------------------------------------------------------------------
        // Campos da tabela. 
        //-------------------------------------------------------------------  
        oQuery:AddField( TBIField():New( "I13_ORIGIN", "C", 03, 0)) // Tabela de Origem do Protheus 
        oQuery:AddField( TBIField():New( "I13_ISTCIA", "C", 02, 0)) // InstÔøΩncia
        oQuery:AddField( TBIField():New( "I13_EMPRES", "C", 12, 0)) // Empresa
        oQuery:AddField( TBIField():New( "I13_FILIAL", "C", 12, 0)) // Filial
        oQuery:AddField( TBIField():New( "I13_COD_CC", "C", 50, 0)) // C√≥digo Conta Contabil
        oQuery:AddField( TBIField():New( "I13_CC_SUP", "C", 50, 0)) // C√≥digo Conta Superior
        oQuery:AddField( TBIField():New( "I13_DES_CC", "C", 50, 0)) // Descri√ß√£o Conta Contabil
        oQuery:AddField( TBIField():New( "I13_TIPO"  , "C", 01, 0)) // Descri√ß√£o Conta Contabil
        //-------------------------------------------------------------------
        // ÔøΩndices da tabela. 
        //-------------------------------------------------------------------  
        oQuery:addIndex( TBIIndex():New( "I131", {"I13_EMPRES", "I13_FILIAL", "I13_ISTCIA"}, .T.) )

        aAdd( aTable, oQuery )

        TCDelFile( "I13" )
        //-------------------------------------------------------------------
        // Abre a tabela. 
        //------------------------------------------------------------------- 
        For nTable := 1 To Len( aTable )
            If !( aTable[nTable]:lIsOpen() )
                aTable[nTable]:ChkStruct(.T.)
                aTable[nTable]:lOpen()
            EndIf
        Next nTable

        aSize(aTable, 0)
    EndIf
    
   
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BCWizardStr
Fun√ß√£o responsabel pela busca e cria√ß√£o das estrutura das contas 
contab√©is das empresas selecionadas.

@param aEmpresas, array, array contendo as empresas selecionadas.
@return aPlano, array, array contendo o plano de contas com sua 
estrutura das empresas selecionadas.

@author Rodrigo Soares  
@since 10/03/2020
/*/
//-------------------------------------------------------------------
static function BCWizardStr(aCompany)
    local nCompany
    local aPlano    := {}
    Local cFilAux   := ""
    Local nArvores  := 0
    oProcess:IncRegua1("Construindo ·rvores")
    
    For nCompany := 1 To Len( aCompany )
        If aCompany[nCompany][1]
        nArvores++
        EndIf
    Next
    ASORT(aCompany, , , { | x,y | x[2] < y[2] } )


    oProcess:SetRegua2(nArvores)

    // Executando o processo para cada empresa. 
	//-------------------------------------------------------------------  
    For nCompany := 1 To Len( aCompany )
        If aCompany[nCompany][1]
            oProcess:IncRegua2("Construindo ·rvore empresa "+aCompany[nCompany][2])

            cFilAux := 'ZZZZZZZZZ'
            nFil := 1
            AADD(aPlano, {aCompany[nCompany][2]})
            //-------------------------------------------------------------------
            // Prepara o ambiente para execu√ß√£o da Query. 
            //------------------------------------------------------------------- 
            RPCSetType( 3 )
            RPCSetEnv( aCompany[nCompany][2] )
            If !ValidTabs(aCompany[nCompany][2])
                Loop
            EndIf
            //-------------------------------------------------------------------
            // Carrega a tabela tempor√°ria. 
            //------------------------------------------------------------------- 
            cflow := flow(aCompany[nCompany][2])
            //-------------------------------------------------------------------
            // Percorre a tabela temporaria para a cria√ß√£o do array
            //------------------------------------------------------------------- 
            While ! (cFlow)->( Eof() )

                IF ! ( Upper(Alltrim((cflow)->FILIAL)) == Upper(Alltrim(cFilAux)) )
                    aadd(aPlano[len(aPlano)], {(cflow)->FILIAL} )
                    nFil++
                ENDIF
                cFilAux :=  Upper(Alltrim((cflow)->FILIAL))
                AADD(aPlano[len(aPlano)][nFil], {(cflow)->COD_CONTA_CONTABIL, (cflow)->CONTA_SUPERIOR,;
                 iif(LEN(ALLTRIM((cFlow)->TIPO)) > 0,(cFlow)->TIPO,getStatus((cflow)->COD_CONTA_CONTABIL)), (cflow)->DESC_CONTA })
                
                (cFlow)->( DBSkip() )
            ENDDO
            RpcClearENv()
        EndIf
    NEXT
    RPCSetEnv(aCompany[1][2])

    aPlano := validPlanos(aPlano)
    
return aPlano


/*/{Protheus.doc} validPlanos
    (long_description)
    @type  Static Function
    @author user
    @since 01/03/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function validPlanos(aPlano)
    Local nCC       := 0
    Local aValid    := {}
    Local nFail     := 0
    Local cMsg      :=""
    Local cMsgFail  :=""
    Local nI        := 0
    Local nJ        := 0
//Valida dados de criacao das ·rvores
For nCC := 1 to Len(aPlano)
    If Len(aPlano[nCC]) < 2
        nFail++
            If len(cMsg)>0
                If (nFail < 3)
                    cMsg += ", " + aPlano[nCC][1]
                EndIf
            Else
                cMsg += aPlano[nCC][1]
            EndIf
    Else
        aadd(aValid,aPlano[nCC])
    EndIf
Next

For nI := 1 to Len(aCompany)
    aCompany[nI][1] := .F.
    For nJ := 1 to Len(aValid)
        If aValid[nJ][1]==aCompany[nI][2]
            aCompany[nI][1] := .T.
            Exit
        EndIf
    Next
Next

If nFail > 0
    If nFail > 1
        If nFail > 3
            cMsgFail := "N„o foi possivel criar a ·rvore das filiais "+cMsg+" e mais "+cValToChar(nFail-3)+" deseja proseguir?"
        Else
            cMsgFail := "N„o foi possivel criar a ·rvore das filiais "+cMsg+" deseja proseguir?"
        EndIf
    Else
        cMsgFail := "N„o foi possivel criar a ·rvore da filial "+cMsg+" deseja proseguir?"
    EndIf
    If Len(aValid)<1
        If nFail > 1
            MessageBox("As filiais selecionadas possuem problemas cadastrais.","Instalador Carol",0)
        Else
            MessageBox("A filial selecionada possui problemas cadastrais.","Instalador Carol",0)
        EndIf
        oDialog:End()
    Else
        If MsgYesNo(cMsgFail,"Instalador Carol")
            MessageBox("As filiais com problemas n„o ser„o configuradas.","Instalador Carol",0)
        Else
            oDialog:End()
        EndIf
    EndIf
EndIf
Return aValid


/*/{Protheus.doc} ValidTabs
    (long_description)
    @type  Static Function
    @author leandro Oliveira
    @since 02/03/2021
    @version version
    @param cCompany, char, para informar no console qual a empresa
    @return lRet, boolean, caso alguma tabela n„o possa ser aberta retorna false
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function ValidTabs(cCompany)
    Local lRet  := .T.
    Local aTabs := {}
    Local nI    := 0
    Local lOpen := .T.
    Aadd(aTabs,{RetSqlName('SFT'),.T.})
	Aadd(aTabs,{RetSqlName('SF1'),.T.})
	Aadd(aTabs,{RetSqlName('CQ0'),.T.})
	Aadd(aTabs,{RetSqlName('CTG'),.T.})
	Aadd(aTabs,{RetSqlName('CTO'),.T.})
	Aadd(aTabs,{RetSqlName('CTE'),.T.})
	Aadd(aTabs,{RetSqlName('CT1'),.T.})
	Aadd(aTabs,{RetSqlName('CT0'),.T.})
	Aadd(aTabs,{RetSqlName('CTN'),.T.})
	Aadd(aTabs,{RetSqlName('CQ1'),.T.})
	Aadd(aTabs,{RetSqlName('CTS'),.T.})

    For nI := 1 to Len(aTabs)
        lOpen := TCCanOpen(aTabs[nI][1])
        aTabs[nI][2]:= lOpen
        If !lOpen
            ConOut("Falha ao abrir tabela: "+aTabs[nI][1]+ " Empresa: "+cCompany)
            lRet := .F.
        EndIf
    Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} flow
Cria√ß√£o de uma tabela temporaria com as contas contabeis da empresa
posicionada.
@return cFlow, string, Nome da tabela temporaria gerada.

@author Rodrigo Soares  
@since 10/03/2020
/*/
//-------------------------------------------------------------------
static function flow(_xEmp)
	Local cDML 		:= ""
    Local cAlias    := GetNextAlias()
    Local cFlow     := cAlias
    default _xEmp := xFilial('CT1')

    
	//-------------------------------------------------------------------
	// Monta o DML. 
	//------------------------------------------------------------------- 
    cDML += "SELECT CT1_FILIAL AS FILIAL, CT1_CONTA AS COD_CONTA_CONTABIL, CT1_CTASUP AS CONTA_SUPERIOR, CT1_DESC01 AS DESC_CONTA"
    //Recupera dados na I13 para casos de manutenÁ„o
    If TCCanOpen( 'I13')
        cDML += ", I13_TIPO AS TIPO FROM  " + RetSQLName( "CT1" ) + " CT1  
        cDML += "LEFT JOIN I13 ON (I13_COD_CC= CT1_CONTA AND I13_EMPRES = '"+_xEmp+"' AND CT1_CTASUP = I13_CC_SUP AND I13.D_E_L_E_T_ = ' ')
    else
        cDML += ", '' AS TIPO FROM  " + RetSQLName( "CT1" ) + " CT1  
    EndIf
    cDML += "WHERE CT1.D_E_L_E_T_ = ' ' order by FILIAL, COD_CONTA_CONTABIL 
  	//-------------------------------------------------------------------
	// Transforma o DML em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML )  

	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,cDML ), cFlow := GetNextAlias() , .T., .F. )
Return cFlow 

//-------------------------------------------------------------------
/*/{Protheus.doc} getStatus
Fun√ß√£o responsavel por classificar a conta.
@param cAccount, string, nome da conta a ser classificada.
@return cClass, string, nome da classe que a conta foi classificada.

@author Rodrigo Soares  
@since 10/03/2020
/*/
//-------------------------------------------------------------------
static function getStatus(cAccount)
    cClass := 'N'

    cAccount := SUBSTR(alltrim(cAccount),1,1)

    DO CASE
        CASE cAccount == '1'
            cClass := "A"
        CASE cAccount == '2'
            cClass := "P"
        CASE cAccount == '3'
            cClass := "C"
        CASE cAccount == '4'
            cClass := "D"
        CASE cAccount == '5'
            cClass := "R"
    ENDCASE

return cClass
//-------------------------------------------------------------------
/*/{Protheus.doc} BCWizardRec
Fun√ß√£o responsavel por gravar as informa√ß√µes no banco.
@param aWizard, array, Array com a estrutura a ser gravada no banco

@author Rodrigo Soares  
@since 10/03/2020
/*/
//-------------------------------------------------------------------
static function BCWizardRec(aWizard)
    Local cInstance := BIInstance()
    Local nEmp
    Local nFil
    Local nCC

    DBSelectArea('I13')
    oProcess:IncRegua1("Cadastrando empresas")
    oProcess:SetRegua2(len(aWizard ))
    ProcessMessage()
    FOR nEmp := 1 to len(aWizard ) // Executa por empresa
        oProcess:IncRegua2("Cadastrando a empresa "+(aWizard[nEmp][1]))
        FOR nFil := 2 to len(aWizard[nEmp]) // Executa por filial
            FOR nCC := 2 to len(aWizard[nEmp][nFil]) // Executa por Conta;
                If( RecLock( "I13", .t. ) )
                    I13->I13_ORIGIN		:= 'CT1'
                    I13->I13_ISTCIA	    := cInstance
                    I13->I13_EMPRES		:= aWizard[nEmp][1]
                    I13->I13_FILIAL	    := aWizard[nEmp][nFil][1]
                    I13->I13_COD_CC	    := aWizard[nEmp][nFil][nCC][1]
                    I13->I13_CC_SUP	    := aWizard[nEmp][nFil][nCC][2]
                    I13->I13_DES_CC	    := aWizard[nEmp][nFil][nCC][4]
                    I13->I13_TIPO	    := aWizard[nEmp][nFil][nCC][3]

                    I13->( MsUnlock() )
                ENDIF
            NEXT
        NEXT
    NEXT

RETURN NIL


