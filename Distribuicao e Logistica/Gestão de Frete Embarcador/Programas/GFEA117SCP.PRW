#INCLUDE 'PROTHEUS.CH'

Function GFEA117SCP(aParam)

	GFEA117PRO() //Inicia o processamento

Return

//-------------------------------------------------------
//Fun��o SchedDef
//-------------------------------------------------------
Static Function SchedDef()
	Local aParam := {}
	Local aOrd   := {}

	aParam := {;
	"P"         ,;  // Tipo R para relatorio P para processo
	"PARAMDEF"  ,;  // Pergunte do relatorio, caso nao use passar "PARAMDEF"
	"GXG"       ,;  // Alias
	aOrd        ,;  // Array de ordens
	Nil         ,;
	}

Return aParam