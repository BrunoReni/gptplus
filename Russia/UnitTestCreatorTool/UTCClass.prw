#include 'totvs.ch'
#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} UTCClass
(long_description)
@author    andrews.egas
@since     06/04/2018
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
CLASS UTCClass FROM FwModelEvent
	DATA _cProgram as char
	DATA cNegField as char
	DATA cNegVal	 as char
	DATA Def0		 	as Array
	DATA VERSION	 	as Array
	DATA RELEASE	 	as Array
	DATA SEEK	 	as Array
	DATA COUNTRY	 	as Array
	DATA OPERATION 		as Array
	DATA BRANCH		 	as Array
	DATA STEP		 	as Array
	DATA DEF_SX1	 	as Array
	DATA DATA_SX1	 	as Array
	DATA DEF_SX6	 	as Array
	DATA DATA_SX6	 	as Array
	DATA DEF_VARS	 	as Array
	DATA DATA_VARS 		as Array
	DATA DEF_MASTER 	as Array
	DATA DATA_MASTER 	as Array
	DATA DEF_ITEMS		as Array
	DATA DATA_ITEMS		as Array
	DATA CKP_QUERY		as Array
	DATA CKP_DEF		as Array
	DATA CKP_RELEASE	as Array
	DATA CKP_RESULT		as Array
	DATA CKP_ASSERT 	as Array
	DATA lNegativeTest		as logical
	
	METHOD New()  constructor 	
	METHOD SetProgram()
	METHOD DeActivate()
	METHOD Activate()
	METHOD GridLinePreVld()
	METHOD FieldPreVld()
	METHOD SetOperation()
	METHOD FieldPosVld()
	METHOD GridLinePosVld()
	METHOD UpdCheckPoint()
	METHOD UpdDetail()
	METHOD UpdMaster()
	METHOD getRelatVal()
	METHOD GenerateCsv()
	METHOD SetNegative()
	METHOD UpdNegative()
	METHOD AddSeek()
	

END CLASS

/*/{Protheus.doc} new
constructor
@author andrews.egas
@since 05/04/2018
@version 1.0
/*/
METHOD new() class UTCClASS
::_cProgram := ""

//Def0
::Def0		:= Array(3)
::Def0[1]	:= "Def0"
::Def0[2]	:= "Key"
::Def0[3]	:= "Def 1"

//Version
::VERSION	:= Array(3)
::VERSION[1]	:="VERSION"

//Release
::RELEASE	:= Array(3)
::RELEASE[1]	:="RELEASE"
//Country
::COUNTRY	:= Array(3)
::COUNTRY[1]	:="COUNTRY"
::COUNTRY[3]	:=IIf(!Empty(cPaisLoc),cPaisLoc,"")

//Operation
::OPERATION	:= Array(3)
::OPERATION[1]	:="OPERATION"

//Branch
::BRANCH	:= Array(3)
::BRANCH[1]		:="BRANCH"
::BRANCH[3]		:=xFilial()

//Step
::STEP		:= Array(3)
::STEP[1]		:="STEP"

//Defines SX1
::DEF_SX1	:= Array(3)
::DATA_SX1	:= Array(3)
::DEF_SX1[1]	:="DEFINITION"
::DEF_SX1[2]	:="SX1"

::DATA_SX1[1]	:="DATA"
::DATA_SX1[2]	:="SX1"

//Defines SX6
::DEF_SX6	:= Array(3)
::DATA_SX6	:= Array(3)
::DEF_SX6[1]	:="DEFINITION"
::DEF_SX6[2]	:="SX6"

::DATA_SX6[1]	:="DATA"
::DATA_SX6[2]	:="SX6"

//Defines Variables
::DEF_VARS	:= Array(3)
::DATA_VARS	:= Array(3)
::DEF_VARS[1]	:="DEFINITION"
::DEF_VARS[2]	:="VARS"
::DEF_VARS[3]	:= "dDatabase"

::DATA_VARS[1]	:="DATA"
::DATA_VARS[2]	:="VARS"
::DATA_VARS[3]	:= "'" + dtoc(dDatabase) + "'"


Return

/*/{Protheus.doc} setProgram
Set the program  - routine

@author Andrews.Egas
@since 06/04/2018
@version 1.0
/*/
Method SetProgram(cProgram) Class UTCClass

::_cProgram := cProgram

Return

/*/{Protheus.doc} Activate
Model Activate to start variables
@author Andrews.Egas
@since 06/04/2018
@version 1.0
/*/
Method Activate(oModel,lCopy) Class UTCClass
::cNegField := ""
::cNegVal	:= ""
::lNegativeTest := .F.

If !Empty(::DEF_MASTER)
	//clear arrays for a new test case
	aSize(::DEF_MASTER, 0)
	aSize(::DATA_MASTER, 0)
	aSize(::SEEK, 0)
	
	aSize(::DEF_ITEMS, 0)
	aSize(::DATA_ITEMS, 0)
	
	aSize(::CKP_QUERY, 0)
	aSize(::CKP_DEF, 0)
	aSize(::CKP_RELEASE, 0)
	aSize(::CKP_RESULT, 0)
	aSize(::CKP_ASSERT, 0)

EndIf

//Defines Master - Header
::DEF_MASTER	:= Array(1,3)
::DATA_MASTER	:= Array(1,3)
//Defines Details Grid
::DEF_ITEMS		:= Array(1,3)
::DATA_ITEMS	:= Array(1,3)
::SEEK			:= Array(4)

//Defines Check Points
::CKP_QUERY		:= Array(1,3)
::CKP_DEF		:= Array(1,2)
::CKP_RELEASE	:= Array(1,2)
::CKP_RESULT	:= Array(1,2)
::CKP_ASSERT 	:= Array(1,3)

::SetOperation(oModel:getOperation()) //Set Operation

If ::OPERATION[2] == "4" .OR. ::OPERATION[2] == "5" //edit or delete
	::AddSeek(oModel)
EndIf

Return .T.

/*/{Protheus.doc} DeActivate
Model pos validation method to generate CSV
@author Andrews.Egas
@since 06/04/2018
@version 1.0
/*/
Method DeActivate(oModel) Class UTCClass
Local oSubModel as object
Local cModelId as character

If Empty(::CKP_QUERY[1][2]) .And. ::lNegativeTest
	//if is negative test we neet to set just one checkpoint
	cModelId := oModel:GetDependency()[1][2]
	oSubModel := oModel:GetModel(cModelId)
	
	::UpdNegative(oSubModel,cModelId)
	::GenerateCsv()

ElseIf !Empty(::CKP_QUERY[1][2]) .Or. ::OPERATION[2] == "5" // if is empty, it is just closing the routine
								//or delete operation
	::GenerateCsv()

EndIf

Return .T.

/*/{Protheus.doc} FieldPreVld
pre validation to update Master fields that were changed
Model pos validation method.
@author Andrews.Egas
@since 06/04/2018
@version 1.0
/*/
Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Class UTCClass
Local cValue as character

If cAction == "SETVALUE" .And. xValue <> NIL
	If ValType(xValue) == "C"
		cValue := xValue
	ElseIf ValType(xValue) == "D"
		cValue := allTrim(dtos(xValue))
	Else
		cValue := allTrim(str(xValue))
	EndIf
	
	If ::lNegativeTest
		::cNegField := cId
		::cNegVal := cValue

		::UpdNegative(oSubModel,cModelId,0)
	EndIf

	::UpdMaster(cModelID,cId,cValue)
	
	conout(cId + " FIELD PRE")
EndIf



Return .T.

/*/{Protheus.doc} GridLinePreVld
pre validation to update CSV
Grid Model pos validation method.
@author Andrews.Egas
@since 06/04/2018
@version 1.0
/*/
Method GridLinePreVld(oSubModel, cModelId, nLine, cAction, cId, xValue, xCurrentValue) Class UTCClass
Local nPosModel as numeric
Local nPosField as numeric
Local cValue	as character

If cAction == "SETVALUE" .And. xValue <> NIL
	If ValType(xValue) == "C"
		cValue := xValue
	ElseIf ValType(xValue) == "D"
		cValue := allTrim(dtos(xValue))
	Else
		cValue := allTrim(str(xValue))
	EndIf

	 ::UpdDetail(cModelID,nLine,cId,cValue)
	
	If ::lNegativeTest
		::cNegField := cId
		::cNegVal := cValue
		
		::UpdNegative(oSubModel,cModelId,nLine)
	EndIf

	conout(cId + " GRID PRE")
EndIf



Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FieldPosVld
Field Pos validation

@author andrews.egas
@since 12/04/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Method FieldPosVld(oSubModel, cModelID) Class UTCClass
local n as numeric
Local ctable as character
Local cQuery as character
Local aKey as Array
Local aValues as Array
Local xValue
Local nNext as numeric
Local aFunc as array

aFunc := array(2)
cQuery := ""
ctable := oSubModel:GetStruct():GetTable()[1] 
	
	If !Empty(ctable )
		aKey := STRTOKARR((ctable)->(IndexKey(1)),'+')
		If at("_FILIAL",aKey[1] ) > 0
			aDel(aKey,1)	
			aSize(aKey,Len(aKey)-1)
		EndIf
		aValues:= array(len(aKey))

		For n:=1 to Len(aKey)	
			//validation for fields with function in the KEY example DTOS(FIELD)
			If oSubModel:GetModel():GetIdField(aKey[n]) > 0
				aValues[n] := oSubModel:GetValue(aKey[n])
			Else
				//delete functions in the key, example DTOS(FIELD)
				If (at("(",akey[n]) > 0) 
					aFunc[1] := substr(akey[n],1,at("(",akey[n])) //save first part of function
					aKey[n] := substr(aKey[n],at("(",akey[n])+1) 
					
					nNext := Iif(at(",",akey[n])>0,at(",",akey[n]),at(")",akey[n])) //take next point
					aFunc[2] := substr(akey[n],nNext,len(akey[n])) //save seconf part of function
					aKey[n]	:= substr(aKey[n],1,nNext-1)
					
					xValue := oSubModel:GetValue(aKey[n])
					If ValType(xValue) == "D"
						aValues[n] := DTOS(xValue)
					ElseIf ValType(xValue) == "N"
						aValues[n] := alltrim(STR(xValue))
						aValues[n] := &(afunc[1]+aValues[n]+aFunc[2]) //exec function with parameters that was in the key
					Else
						aValues[n] := xValue
					EndIf
				EndIf
			EndIf

			cQuery += AllTrim(aKey[n]) + " = '" + aValues[n]+ "'" //return values for query
			If n < Len(aKey)
				cQuery += " AND "
			Else
				cQuery += " AND d_e_l_e_t_ <> '*'"
			EndIf
			If ::OPERATION[2] <> "4" // update doesn't need set key
				//update KEY fields, maybe they were not  changed manually
				::UpdMaster(cModelID,aKey[n],aValues[n]) 
			EndIf
		Next
	EndIf

	::UpdCheckPoint(ctable,cQuery,aKey,aValues,"")

conout(cModelId +" FIELD POS OK")

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld
Grid Pos valid

@author andrews.egas
@since 12/04/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Method GridLinePosVld(oSubModel, cModelID, nLine) Class UTCClass
local n as numeric
Local ctable as character
Local cQuery as character
Local aKey as Array
Local aValues as Array
Local aRelation as Array
Local nIsInRel	as numeric
local aFunc	as Array
Local nNext as numeric
Local xValue

aFunc := array(2)
cQuery := ""
ctable := oSubModel:oFormModelStruct:getTable()[1]
aRelation:= oSubModel:getrelation()[1]

	aKey := STRTOKARR((ctable)->(IndexKey(1)),'+')
	If at("_FILIAL",aKey[1] ) > 0
		aDel(aKey,1)
		aSize(aKey,Len(aKey)-1)
	EndIf
	aValues:= array(len(aKey))

	For n:=1 to Len(aKey)
		//if the key field is in relation it was not update manually, lets update
		nIsInRel := Ascan(aRelation,{|x| Alltrim(x[1]) == allTrim(aKey[n])})
		if nIsInRel > 0
			aValues[n] := ::getRelatVal(oSubModel,cModelId,aRelation[nIsInRel]) //Take the resault of relation
		Else
			If oSubModel:GetModel():GetIdField(aKey[n]) > 0
				aValues[n] := oSubModel:GetValue(aKey[n],nLine)
			Else
				//delete functions in the key, example DTOS(FIELD)
				If (at("(",akey[n]) > 0) 
					aFunc[1] := substr(akey[n],1,at("(",akey[n])) //save first part of function
					aKey[n] := substr(aKey[n],at("(",akey[n])+1) 
					
					nNext := Iif(at(",",akey[n])>0,at(",",akey[n]),at(")",akey[n])) //take next point
					aFunc[2] := substr(akey[n],nNext,len(akey[n])) //save seconf part of function
					aKey[n]	:= substr(aKey[n],1,nNext-1)

					xValue := oSubModel:GetValue(aKey[n],nLine)
					If ValType(xValue) == "D"
						aValues[n] := DTOS(xValue) //no parameters
					ElseIf ValType(xValue) == "N"
						aValues[n] := alltrim(STR(xValue))
						aValues[n] := &(afunc[1]+aValues[n]+aFunc[2]) //exec function with parameters that was in the key
					Else
						aValues[n] := xValue
					EndIf
				EndIf
			EndIf
		EndIf
		
		cQuery += AllTrim(aKey[n]) + " = '"  + aValues[n] + "'" //return values for query
		If n < Len(aKey)
			cQuery += " AND "
		Else
			cQuery += " AND d_e_l_e_t_ <> '*'"
		EndIf
		
		If ::OPERATION[2] <> "4" // update doesnt need to set key
			//update KEY fields, maybe they were not  changed manually
			::UpdDetail(cModelID,nLine,aKey[n],aValues[n])
		EndIf

	Next

	::UpdCheckPoint(ctable,cQuery,aKey,aValues,AllTrim(str(nLine)))

conout(" GRID POS ")

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} SetOperation

set the operation 
@param nOperation, 	numeric, Operation

@author andrews.egas
@since 12/04/2018
@version 1.0

/*/
//-------------------------------------------------------------------
METHOD SetOperation( nOperation ) Class UTCClass

::OPERATION[2] := AllTrim(str(nOperation))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdMaster
Update Master definitions or create

@param cModelID, 	character, Model Id
@param cId, 		character, Field Id
@param cValue, 		character, Value

@author andrews.egas
@since 13/04/2018
@version 1.0

/*/
//-------------------------------------------------------------------
METHOD UpdMaster(cModelID,cId,cValue) Class UTCClASS
Local nPosModel as numeric
Local nPosField as numeric

//First time to fill Master data
	If Empty(::DEF_MASTER[1][2]) 
		::DEF_MASTER[1][1]	:="DEFINITION"
		::DATA_MASTER[1][1]	:="DATA"
		
		::DEF_MASTER[1][2]	:=cModelID
		::DATA_MASTER[1][2]	:=cModelID
		
		::DEF_MASTER[1][3]	:=cId
		::DATA_MASTER[1][3]	:=cValue
	Else
		nPosModel := Ascan(::DEF_MASTER,{|x| Alltrim(x[2]) == allTrim(cModelID)}) //seek structure id of model
		
		If nPosModel > 0
			//master already exist
			nPosField := Ascan(::DEF_MASTER[nPosModel],allTrim(cId) ) //seek field inside this model
			
			If nPosField > 0 
				//field already exist, just update value
				::DEF_MASTER[nPosModel][nPosField]	:=cId
				::DATA_MASTER[nPosModel][nPosField]	:=cValue
			Else
				//add new field in the structure
				aAdd(::DEF_MASTER[nPosModel],cId)
				aAdd(::DATA_MASTER[nPosModel],cValue)
			EndIf
		Else
			//add new Master
			aAdd(::DEF_MASTER,{"DEFINITION",cModelID,cId})
			aAdd(::DATA_MASTER,{"DATA",cModelID,cValue})
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdDetail
Update Details definitions or create

@param cModelID, 	character, Detail Id
@param nLine, 		numeric, Grid Line
@param cId, 		character, Field Id
@param cValue, 		character, Value

@author andrews.egas
@since 13/04/2018
@version 1.0

/*/
//-------------------------------------------------------------------
METHOD UpdDetail(cModelID,nLine,cId,cValue) Class UTCClASS
Local nPosModel as numeric
Local nPosField as numeric
Local cLine as character

cLine := AllTrim(str(nLine))
//First time to fill Master data
	If Empty(::DEF_ITEMS[1][2]) 
		::DEF_ITEMS[1][1]	:="DEFINITION"
		::DATA_ITEMS[1][1]	:="DATA_ITEMS"
		
		::DEF_ITEMS[1][2]	:=cModelID + cLine //Here is the line control
		::DATA_ITEMS[1][2]	:=cModelID
		
		::DEF_ITEMS[1][3]	:=cId
		::DATA_ITEMS[1][3]	:=cValue
	Else
		nPosModel := Ascan(::DEF_ITEMS,{|x| Alltrim(x[2]) == allTrim(cModelID + cLine)}) //seek structure id of model + line
		
		If nPosModel > 0
			//Details ID already exist
			nPosField := Ascan(::DEF_ITEMS[nPosModel],allTrim(cId) ) //seek field inside this model
			
			If nPosField > 0 
				//field already exist, just update value
				::DEF_ITEMS[nPosModel][nPosField]	:=cId
				::DATA_ITEMS[nPosModel][nPosField]	:=cValue
			Else
				//add new field in the structure
				aAdd(::DEF_ITEMS[nPosModel],cId)
				aAdd(::DATA_ITEMS[nPosModel],cValue)
			EndIf
		Else
			//add new Details ID
			aAdd(::DEF_ITEMS,{"DEFINITION",cModelID + cLine,cId})
			aAdd(::DATA_ITEMS,{"DATA_ITEMS",cModelID,cValue})
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdCheckPoint
Update Details definitions or create

@param ctable, 		character, Table
@param cQuery, 		numeric	, SQL Query
@param aFields, 	array	, fields to check
@param aValues, 	array	, Values of aFields

@author andrews.egas
@since 13/04/2018
@version 1.0

/*/
//-------------------------------------------------------------------
METHOD UpdCheckPoint(ctable,cQuery,aFields,aValues,cLine,lNegativeTest) Class UTCClASS
Local nPosCKP as numeric
Local n as numeric
Local nA as numeric
Default lNegativeTest := .F.

If lNegativeTest
	//Clean array, negative test must be just one checkpoint
	for nA := 2 to Len(::CKP_QUERY)
		aDel(::CKP_QUERY,nA)
		aDel(::CKP_DEF,nA)
		aDel(::CKP_RESULT,nA)
		aDel(::CKP_ASSERT,nA)
	Next
	aSize(::CKP_QUERY,1)
	aSize(::CKP_DEF,1)
	aSize(::CKP_DEF[1],2)
	aSize(::CKP_RESULT,1)
	aSize(::CKP_RESULT[1],2)
	aSize(::CKP_ASSERT,1)
	::CKP_QUERY[1][2] := "" //force to entry in the <First time to fill check point data>
EndIf
	//First time to fill CheckPoint data
	If Empty(::CKP_QUERY[1][2]) 
		::CKP_QUERY[1][1]	:="CHECKPOINT_QUERY"
		::CKP_DEF[1][1]		:="CHECKPOINT_DEFINITION"
		::CKP_RESULT[1][1]	:="CHECKPOINT_RESULT"
		::CKP_ASSERT[1][1] 	:="CHECKPOINT_ASSERT"
		
		::CKP_QUERY[1][2]	:= ctable
		::CKP_DEF[1][2]		:= ctable + cLine //Include line if is grid
		::CKP_RESULT[1][2]	:= ctable
		::CKP_ASSERT[1][2] 	:=""

		::CKP_QUERY[1][3]	:=cQuery
		for n := 1 to Len(aFields)
			aAdd(::CKP_DEF[1]	,aFields[n])
			aAdd(::CKP_RESULT[1],aValues[n])
		Next
		If lNegativeTest .Or. ::OPERATION[2] == "5" // delete
			::CKP_ASSERT[1][3] 	:="False"
		Else
			::CKP_ASSERT[1][3] 	:="True"
		EndIf
	Else		
		nPosCKP := Ascan(::CKP_DEF,{|x| Alltrim(x[2]) == allTrim(ctable + cLine)}) //seek structure id of model + line
		
		If nPosCKP > 0
			//CheckPoint already exist

			::CKP_QUERY[nPosCKP][3]	:= cQuery

			for n := 1 to Len(aFields)
				::CKP_DEF[nPosCKP][(n+2)] := aFields[n]
				::CKP_RESULT[nPosCKP][(n+2)] := aValues[n]
			Next

			::CKP_ASSERT[nPosCKP][3] 	:="True"
		Else
			//there is no checkPont for this table + line
			aAdd(::CKP_QUERY,{"CHECKPOINT_QUERY"	,ctable 		,cQuery})
			aAdd(::CKP_DEF	,{"CHECKPOINT_DEFINITION",ctable + cLine})
			aAdd(::CKP_RESULT,{"CHECKPOINT_RESULT"	,ctable})
			aAdd(::CKP_ASSERT,{"CHECKPOINT_ASSERT"	,""				,"True"})
			
			for n := 1 to Len(aFields)
				aAdd(::CKP_DEF[Len(::CKP_DEF)]		, aFields[n])
				aAdd(::CKP_RESULT[Len(::CKP_RESULT)], aValues[n])
			Next
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdCheckPoint
Get value from relation between tables

@param oSubModel	object		, Model structure
@param cModelId, 	character	, Id do model
@param aRelation, 	array		, relation to return

@author andrews.egas
@since 13/04/2018
@version 1.0

/*/
//-------------------------------------------------------------------
METHOD getRelatVal(oSubModel,cModelId,aRelation) Class UTCClASS
Local cIdOwner as character
Local oModelOw as object
Local xReturn

If oSubModel:GetModel():GetIdField(aRelation[2],@oModelOw) > 0
	xReturn := oModelOw:GetValue(aRelation[2]) //Take the value in oModelOw (Model with the field)
Else	
	xReturn := &(aRelation[2]) //advpl expression
EndIf

Return xReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} GenerateCsv
generates the CSV file

@author andrews.egas
@since 13/04/2018
@version 1.0

/*/
//-------------------------------------------------------------------
METHOD GenerateCsv() Class UTCClASS
Local lRet as logical 
Local nBFile as numeric
Local cFileName as Character
Local cContFile as Character
Local n 	as numeric
Local nItem as numeric
Local cName as character
Local nLenComma as numeric
Local cWithComma as character
lRet := .T.


If FindFunction(::_cProgram + cPaisLoc)
	//generate Test Case with RUS name	
Else
	//Generate Test Case normal
EndIf

cName := Alltrim(GetRoutine("Test Name"))

cFileName := ::_cProgram 

// CSV Creation 
If !File(cFileName + "_" + cName + ".CSV") //check if the file already exist, and create next one
	nBFile := FCREATE(cFileName + "_" +  cName + ".CSV")
Else
	nBFile := FCREATE(cFileName + "_" + cName + "_002"+".CSV")//changehere
EndIf

If nBFile == -1 //check if was possible to crate the file
  MsgStop('Erro ao criar destino. Ferror = '+str(ferror(),4),'Erro')
  lRet := .F.
Else
	cContFile :="" //start to write the file
	For n := 1 to Len(::Def0) 
		cContFile += IIF(::Def0[n] == NIL,"",::Def0[n]) + ","
	Next
	
	cContFile += CRLF
	For n := 1 to Len(::VERSION) 
		cContFile += IIF(::VERSION[n] == NIL,"",::VERSION[n]) + ","
	Next
	
	cContFile += CRLF
	For n := 1 to Len(::RELEASE) 
		cContFile += IIF(::RELEASE[n] == NIL,"",::RELEASE[n]) + ","
	Next
	
	cContFile += CRLF
	For n := 1 to Len(::COUNTRY) 
		cContFile += IIF(::COUNTRY[n] == NIL,"",::COUNTRY[n]) + ","
	Next
	
	cContFile += CRLF
	For n := 1 to Len(::BRANCH) 
		cContFile += IIF(::BRANCH[n] == NIL,"",::BRANCH[n]) + ","
	Next
	
	cContFile += CRLF
	For n := 1 to Len(::STEP) 
		cContFile += IIF(::STEP[n] == NIL,"",::STEP[n]) + ","
	Next
	
	cContFile += CRLF
	For n := 1 to Len(::OPERATION) 
		cContFile += IIF(::OPERATION[n] == NIL,"",::OPERATION[n]) + ","
	Next

	cContFile += CRLF
	For n := 1 to Len(::DEF_VARS) 
		cContFile += IIF(::DEF_VARS[n] == NIL,"",::DEF_VARS[n]) + ","
	Next
	
	cContFile += CRLF
	For n := 1 to Len(::DATA_VARS) 
		cContFile += IIF(::DATA_VARS[n] == NIL,"",::DATA_VARS[n]) + ","
	Next

	cContFile += CRLF
	For n := 1 to Len(::DEF_SX1) 
		cContFile += IIF(::DEF_SX1[n] == NIL,"",::DEF_SX1[n]) + ","
	Next

	cContFile += CRLF
	For n := 1 to Len(::DATA_SX1) 
		cContFile += IIF(::DATA_SX1[n] == NIL,"",::DATA_SX1[n]) + ","
	Next

	cContFile += CRLF
	For n := 1 to Len(::DEF_SX6) 
		cContFile += IIF(::DEF_SX6[n] == NIL,"",::DEF_SX6[n]) + ","
	Next

	cContFile += CRLF
	For n := 1 to Len(::DATA_SX6) 
		cContFile += IIF(::DATA_SX6[n] == NIL,"",::DATA_SX6[n]) + ","
	Next

	If !Empty(::SEEK[1]) //check if there is SEEK in this test case (Update or delete)
		cContFile += CRLF
		For n := 1 to Len(::SEEK) 
			cContFile += ::SEEK[n] + ","
		Next
	EndIf
	
	If !Empty(::DEF_MASTER[1][2]) //If we don't have Master it is DELETE
		For n := 1 to Len(::DEF_MASTER) 
			cContFile += CRLF //master Head
			//master
			For nItem := 1 to Len(::DEF_MASTER[n]) 
				cContFile += ::DEF_MASTER[n][nItem] + ","
			Next
			
			cContFile += CRLF
			// data master
			For nItem := 1 to Len(::DATA_MASTER[n])
				If nItem > 2 
					If "," $ Trim(::DATA_MASTER[n][nItem])
						aWithComma := Str2Arr(::DATA_MASTER[n][nItem],",",.F.) 
						cWithComma := ""
						For nLenComma := 1 to Len(aWithComma)
							If nLenComma < Len(aWithComma)
								cWithComma += aWithComma[nLenComma] + "*,"
							Else 
								cWithComma += aWithComma[nLenComma]
							EndIf
						Next
						cContFile +='"' + cWithComma + '",'
					Else	 
						cContFile +='"' + ::DATA_MASTER[n][nItem] + '",'
					EndIf
				Else
					cContFile += ::DATA_MASTER[n][nItem] + ","
				EndIf
			Next
		Next
	EndIf

	If !Empty(::DEF_ITEMS[1][2]) //check if we have details in this test
		For n := 1 to Len(::DEF_ITEMS) 
			cContFile += CRLF //start Details

			For nItem := 1 to Len(::DEF_ITEMS[n])
				If nItem == 2 //If is the second, the line is here, use data_items
					cContFile += ::DATA_ITEMS[n][nItem] + ","
				Else 
					cContFile += ::DEF_ITEMS[n][nItem] + ","
				EndIf
			Next
			cContFile += CRLF
			// data details
			For nItem := 1 to Len(::DATA_ITEMS[n])
				If nItem > 2 
					cContFile += '"' + ::DATA_ITEMS[n][nItem] + '",'
				Else
					cContFile += ::DATA_ITEMS[n][nItem] + ","
				EndIf
			Next
		Next
	EndIf

	For n := 1 to Len(::CKP_QUERY) 
		cContFile += CRLF //Check Points
		//Query
		For nItem := 1 to Len(::CKP_QUERY[n]) 
			cContFile += IIF(::CKP_QUERY[n][nItem] == NIL,"",::CKP_QUERY[n][nItem]) + ","
		Next
		
		cContFile += CRLF
		// Definitions of fields to check
		For nItem := 1 to Len(::CKP_DEF[n])
			If nItem == 2 //If is the second, the line is here, use ckp_result 
				cContFile += IIF(::CKP_RESULT[n][nItem] == NIL,"",::CKP_RESULT[n][nItem]) + ","
			Else
				cContFile += IIF(::CKP_DEF[n][nItem] == NIL,"",::CKP_DEF[n][nItem]) + ","
			EndIf
		Next

		cContFile += CRLF
		// Result of fields
		For nItem := 1 to Len(::CKP_RESULT[n]) 
			If nItem > 2 
				cContFile += '"' + ::CKP_RESULT[n][nItem] + '",'
			Else
				cContFile += ::CKP_RESULT[n][nItem] + ","
			EndIf
		Next

		cContFile += CRLF
		// Assert
		For nItem := 1 to Len(::CKP_ASSERT[n]) 
			cContFile += IIF(::CKP_ASSERT[n][nItem] == NIL,"",::CKP_ASSERT[n][nItem]) + ","
		Next
	Next

	conout("criado")
	
	
	
	
	FWRITE(nBFile,cContFile)
	FCLOSE(nBFile)
	MsgInfo(cFileName + "_" +  cName + ".CSV successfully generated", 'Test Case')
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetNegative
Negative Test

@author andrews.egas
@since 12/04/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Method SetNegative() Class UTCClass

MsgInfo('Your next change (FIELD OR CONFIRMATION) must be the last, ','Negative Test')
::lNegativeTest := .T.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdNegative
Creation JUST negative check point and delete others

@param oSubModel, 		object, SubModel
@param cModelId, 		character	, Model id
@param nLine, 			numeric	, line if grid

@author andrews.egas
@since 13/04/2018
@version 1.0

/*/
//-------------------------------------------------------------------
METHOD UpdNegative(oSubModel,cModelId,nLine) Class UTCClASS
Local cQuery as character
Local ctable as character
Local aKey as Array
Local aValues as Array
Local aRelation as Array
Local nIsInRel as numeric
Local cLine as character
Local n as numeric
Default nLine := 0
cLine := ""

	cQuery := ""
	ctable := oSubModel:GetStruct():GetTable()[1]
	aKey := STRTOKARR((ctable)->(IndexKey(1)),'+')
	If at("_FILIAL",aKey[1] ) > 0
		aDel(aKey,1)
		aSize(aKey,Len(aKey)-1)
	EndIf
	aValues:= array(len(aKey))
	If !Empty(nLine)
		cLine := AllTrim(str(nLine))
		aRelation:= oSubModel:getrelation()[1]
	EndIf
	For n:=1 to Len(aKey)
		if aKey[n]	== ::cNegField
			aValues[n] := ::cNegVal
		Else
			If Empty(nLine) 
				//Master
				If !isincallstack("DEACTIVATE") //when it comes from DEACTIVATE the Model is already not active
					If  "DTOS(" $ aKey[n]
						aKey[n]:= STRTRAN(aKey[n], "DTOS(", "")
						aKey[n]:= STRTRAN(aKey[n], ")", "")	
						aValues[n] := DTOS(oSubModel:GetValue(aKey[n]))
					Else 
						aValues[n] := oSubModel:GetValue(aKey[n])	//master doesnt have relation			
					EndIf
					
				Else
					aValues[n] := &(aKey[n])
				EndIf
			Else
				nIsInRel := Ascan(aRelation,{|x| Alltrim(x[1]) == allTrim(aKey[n])})
				if nIsInRel > 0
					aValues[n] := ::getRelatVal(oSubModel,cModelId,aRelation[nIsInRel]) //Take the resault of relation
				Else
					aValues[n] := oSubModel:GetValue(aKey[n],nLine)
				EndIf
			EndIf
		EndIf
		cQuery += AllTrim(aKey[n]) + " = '"  + aValues[n] + "'" //return values for query
		If n < Len(aKey)
			cQuery += " AND "
		Else
			cQuery += " AND d_e_l_e_t_ <> '*'"
		EndIf
	Next

	::UpdCheckPoint(ctable,cQuery,aKey,aValues,cLine,.T.)//last param is Negative Test

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddSeek
Create seek based on model and data positioned

@param oModel, 		object, Model

@author andrews.egas
@since 28/04/2018
@version 1.0

/*/
//-------------------------------------------------------------------
METHOD AddSeek(oModel) Class UTCClASS
Local cValue as character
Local cModelID as character
Local oSubModel as object
Local cTable as character
Local aKey as array
Local aValues as array
Local n as numeric
Local cQuery as character

//take master data, key and fields
cModelId := oModel:GetDependency()[1][2]
oSubModel := oModel:GetModel(cModelId)
cTable := oSubModel:GetStruct():GetTable()[1]
aKey := STRTOKARR((ctable)->(IndexKey(1)),'+')

//delete filial from the key
/*If at("_FILIAL",aKey[1] ) > 0
	aDel(aKey,1)
	aSize(aKey,Len(aKey)-1)
EndIf*/

aValues:= array(len(aKey))
//Get the key for SEEK, direct in the table
cValue := '"'
For n:=1 to Len(aKey) 
	IF  "DTOS(" $ aKey[n]
		aKey[n]:= STRTRAN(aKey[n], "DTOS(", "")
		aKey[n]:= STRTRAN(aKey[n], ")", "")
		cValue += DTOS(&(cTable + "->" + aKey[n]))
		aValues[n] := DTOS(&(cTable + "->" + aKey[n]))
	Else	
		cValue += &(cTable + "->" + aKey[n])
		aValues[n] := &(cTable + "->" + aKey[n])
	EndIf	
Next
cValue += '"'

::SEEK[1] := "SEEK"
::SEEK[2] := cTable	//table
::SEEK[3] := "1"	//index 
::SEEK[4] := cValue //key 

If ::OPERATION[2] == "5" // delete
	
	cQuery := ""
	For n := 1 to Len(aValues)
		cQuery += AllTrim(aKey[n]) + " = '"  + aValues[n] + "'" //return values for query
		If n < Len(aKey)
			cQuery += " AND "
		Else
			cQuery += " AND d_e_l_e_t_ <> '*'"
		EndIf
	Next

	::UpdCheckPoint(ctable,cQuery,aKey,aValues,"")
EndIf

Return 
// Russia_R5
