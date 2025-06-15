#INCLUDE 'TOTVS.CH'
#Include 'Protheus.ch'
#include 'fwlibversion.ch'

Function cenpob2y()
    Local cMsg  := ""

    IF FwLibVersion() < "20210104"
        cMsg += "Atualize a vers�o da LIB para 20210104 ou posterior." + CRLF
    EndIf
    If GetSrvVersion() < "19.3.1.2"
        cMsg += "Atualize a vers�o de seu Appserver para 19.3.1.2 ou posterior" + CRLF
    EndIf
    If GetRmtVersion() < "19.3.1.1"
        cMsg += "Atualize a vers�o de seu Smartclient para 19.3.1.1 ou posterior" + CRLF
    EndIf
    If GetPvProfString("General", "App_Environment", "0", GetAdv97()) != GetEnvServer()
        cMsg += "Adicione seu ambiente na chave [App_Environment] no .ini do seu Appserver" + CRLF
    EndIf

    IF Empty(cMsg)
        FwCallApp("cenpob2y")
    Else
        //      MsgInfo("Seu ambiente n�o est� preparado para a ultima vers�o desta rotina." + CRLF +;
        //            cMsg + "Uma vers�o anterior desta rotina ser� executada." , "Central de Obriga��es")
        CenMvcB2Y()
    EndIf
Return
