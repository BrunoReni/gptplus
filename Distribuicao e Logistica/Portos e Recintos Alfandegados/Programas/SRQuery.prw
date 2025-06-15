#Include 'Protheus.ch'
/*
CLASS SRField
Data Name
Data Value
Return
*/

Class SRQuery
	Method New(aSql) Constructor
	Data Fields
	Data SQL
	Data AliasQry
	
	Method Open() 
	Method OpenSQL(aSQL) 
	Method Exec()
	Method ExecSQL(aSql)
	Method FieldByName(aName)
	Method Destroy()
	Method Prior()
	Method Next_()
	Method Eof_()
EndClass

Method New(aSql) Class SRQuery
	::Fields   := [] 
	::SQL      := aSql
	::AliasQry := GetNextAlias()
Return Self

Method Open() Class SRQuery
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,::SQL),::AliasQry,.F.,.T.)
	//::Fields := (::AliasQry)->(dbStruct())
Return Self

Method OpenSQL(aSQL) Class SRQuery
	::SQL := aSQL
	Open()
Return Self

Method FieldByName(aName) Class SRQuery
Return aName

Method Exec() Class SRQuery
	TcSqlExec(::SQL)
	//TcRefresh(::AliasQry) 
Return

Method ExecSQL(aSql) Class SRQuery
	::SQL := aSql
	Exec() 
Return

Method Destroy() Class SRQuery 
	(::AliasQry)->(dbCloseArea())	
	FreeObj(Self)
Return

Method Prior() Class SRQuery
	(::AliasQry)->(dbSkip(-1))
Return

Method Next_() Class SRQuery
	(::AliasQry)->(dbSkip())
Return

Method Eof_() Class SRQuery
Return (::AliasQry)->(Eof())









