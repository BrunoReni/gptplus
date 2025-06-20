#include "AVERAGE.CH"
#include "AVINT103.CH"

/*
Programa   : AvInt103.prw
Objetivo   : Reunir as classes de integra��o do EasyLink (Boundary Manager)
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Obs        : 
*/

/*
Classe      : ELinkBdMan (Easy Link Boundary Manager)
Objetivos   : Enviar e receber via FTP arquivos de integra��o do EasyLink
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/07
Revisao     : 
Obs.        : 
*/

Function AvInt103()
Return Nil

*===============*
Class ELinkBdMan
*===============*

Data cType
Data cServer
Data nPort
Data cUser
Data cPass
Data cDirFtpIn
Data cDirFtpOut
Data cDirLocIn
Data cDirLocOut
Data cFileMode
Data aFilesFtp
Data aFilesLoc
Data aFilesDownload
Data aFilesUpload
Data cError
Data lInterface
Data lRemoveFiles
Data bDownload
Data bUpload

Method New(cType) Constructor
Method SetComType(cType)
Method Connect()
Method AuxConnect()
Method Disconnect()
Method UploadFiles()
Method DownloadFiles()
Method AuxUpldFiles()
Method AuxDownFiles()
Method SetFileMode(cMode)
Method ChangeStoreMode(cMode)
Method GoToFtpDir()
Method SetDirFtpIn(cDir)
Method SetDirFtpOut(cDir)
Method SetDirLocIn(cDir)
Method SetDirLocOut(cDir)
Method SetServer(cServer)
Method SetPort(nPort)
Method SetUser(cUser)
Method SetPass(cPass)
Method GetFtpFileList()
Method GetLocFileList()
Method DownloadList(xFile)
Method UploadList(xFile)
Method GetError()

End Class


/*
M�todo      : New(cType)
Classe      : ELinkBdMan
Par�metros  : cType - Define o tipo de comunica��o (Atualmente est� dispon�vel apenas a op��o FTP)
Retorno     : Self - Inst�ncia da classe
Objetivos   : Gerar nova inst�ncia da classe
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method New(cType) Class ELinkBdMan
Default cType := ""

   ::cType        := cType
   ::cUser        := ""
   ::cPass        := ""
   ::cServer      := ""
   ::nPort        := 21
   ::cError       := ""
   ::lRemoveFiles := .F.
   ::lInterface   := .T.
   ::SetComType(cType)

Return Self

/*
M�todo      : SetComType(cType)
Classe      : ELinkBdMan
Par�metros  : cType - Define o tipo de comunica��o (Atualmente est� dispon�vel apenas a op��o FTP)
Retorno     : Nenhum
Objetivos   : Definir o tipo de comunica��o utilizado
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetComType(cType) Class ELinkBdMan
Default cType := ""

   If cType == "FTP"
      ::cDirFtpIn      := ""
      ::cDirFtpOut     := ""
      ::aFilesFtp      := {}
      ::aFilesLoc      := {}
      ::aFilesDownload := {}
      ::aFilesUpload   := {}
      ::cDirLocIn      := ""
      ::cDirLocOut     := ""
      ::cFileMode      := "COMPLETE"
   EndIf
   
Return Nil

/*
M�todo      : Connect()
Classe      : ELinkBdMan
Par�metros  : Nenhum
Retorno     : lRet - Indica se a conex�o foi conclu�da
Objetivos   : Fazer a conex�o ao servidor FTP com base nos atributos de defini��o de servidor, porta, usu�rio e senha.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method Connect() Class ELinkBdMan
Local lRet

   If ::lInterface
      Processa({|| lRet := ::AuxConnect() }, STR0001)//"Conectando ao servidor FTP"
   Else
      lRet := ::AuxConnect()
   EndIf

Return lRet


/*
M�todo      : AuxConnect()
Classe      : ELinkBdMan
Par�metros  : Nenhum
Retorno     : lRet - Indica se a conex�o foi conclu�da
Objetivos   : Auxiliar ao m�todo Connect()
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method AuxConnect() Class ELinkBdMan
Local lRet

   lRet := FtpConnect(::cServer, ::nPort, ::cUser, ::cPass)
   If !lRet
      ::cError += STR0002 + ENTER//"Erro na conex�o com o servidor FTP."
   EndIf

Return lRet

/*
M�todo      : Disconnect()
Classe      : ELinkBdMan
Par�metros  : Nenhum
Retorno     : lRet - Indica se foi poss�vel conex�o foi conclu�da
Objetivos   : Faz a desconex�o do servidor FTP
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method Disconnect() Class ELinkBdMan
Local lRet

   lRet := FtpDisconnect()

Return lRet

/*
M�todo      : UploadFiles()
Classe      : ELinkBdMan
Par�metros  : Nenhum
Retorno     : lRet - Indica o resultado da opera��o
Objetivos   : Faz o upload (envio) dos arquivos locais ao servidor de FTP
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method UploadFiles() Class ELinkBdMan
Local lRet

Begin Sequence

   If !Empty(::cError)
      lRet := .F.
      Break
   EndIf

   If ::lInterface
      Processa({|lEnd| lRet := ::AuxUpldFiles(@lEnd) }, STR0003)//"Efetuando upload dos arquivos."
   Else
      lRet := ::AuxUpldFiles()
   EndIf

End Sequence

Return lRet

/*
M�todo      : AuxUpldFiles(lEnd)
Classe      : ELinkBdMan
Par�metros  : lEnd - Termina e execu��o
Retorno     : lRet - Indica o resultado da opera��o
Objetivos   : Auxiliar ao m�todo UploadFiles()
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/

Method AuxUpldFiles(lEnd) Class ELinkBdMan
Local lRet := .T.
Local nTotal := Len(::aFilesUpload), nCount := 0

   If !(lRet := ::GoToFtpDir(::cDirFtpIn))
      ::cError += "O diret�rio de entrada de arquivos no servidor de FTP n�o foi encontrado." + ENTER
   EndIf
   ProcRegua(nTotal)
   While lRet .And. (Len(::aFilesUpload) > 0)
      ++nCount
      IncProc(StrTran(StrTran(STR0004, "XXX", AllTrim(Str(nCount))), "YYY", AllTrim(Str(nTotal))))//"Efetuando upload do arquivo XXX/YYY"
      If (lRet := FtpUpload(::cDirLocOut + ::aFilesUpload[1], ::aFilesUpload[1]))
         If ValType(::bUpload) == "B"
            Eval(::bUpload, ::aFilesUpload[1], Self)
         EndIf
         If ::lRemoveFiles
            If !(lRet := !(FErase(::cDirLocOut + ::aFilesUpload[1]) == -1))
               ::cError += StrTran(STR0005, "###", ::aFilesUpload[1])//"Erro ao excluir o arquivo '###' do diret�rio local de envio de arquivos"
               Exit
            EndIf
         EndIf
         aDel(::aFilesUpload, 1)
         aSize(::aFilesUpload, Len(::aFilesUpload) - 1)
      Else
         ::cError += StrTran(STR0006, "###", ::aFilesUpload[1]) + ENTER//"Erro ao enviar o arquivo '###' para o diret�rio de destino de arquivos no servidor de FTP"
      EndIf
      IncProc()
      If lEnd
         Exit
      EndIf
   EndDo
   ::GoToFtpDir("/")

Return lRet

/*
M�todo      : DownloadFiles()
Classe      : ELinkBdMan
Par�metros  : Nenhum
Retorno     : lRet
Objetivos   : Fazer o download (recebimento) dos arquivos do servidor FTP no sistema local
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method DownloadFiles() Class ELinkBdMan
Local lRet

Begin Sequence
   
   If !Empty(::cError)
      lRet := .F.
      Break
   EndIf
   
   If ::lInterface
      Processa({|lEnd| lRet := ::AuxDownFiles(@lEnd) }, STR0007,, .T.)//"Efetuando download dos arquivos."
   Else
      lRet := ::AuxDownFiles()
   EndIf

End Sequence

Return lRet

/*
M�todo      : AuxDownFiles()
Classe      : ELinkBdMan
Par�metros  : lEnd - Termina a execu��o
Retorno     : lRet - Indica o sucesso da opera��o
Objetivos   : Auxiliar ao m�todo Download files
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method AuxDownFiles(lEnd) Class ELinkBdMan
Local lRet := .T.
Local nTotal := Len(::aFilesDownload), nCount := 0

   If !(lRet := ::GoToFtpDir(::cDirFtpOut))
      ::cError += "O diret�rio de sa�da de arquivos no servidor de FTP (" + ::cDirFtpOut + ") n�o foi encontrado." + ENTER
   EndIf
   ProcRegua(nTotal)
   While lRet .And. Len(::aFilesDownload) > 0
      ++nCount
      IncProc(StrTran(StrTran(STR0008, "XXX", AllTrim(Str(nCount))), "YYY", AllTrim(Str(nTotal))))//"Efetuando download do arquivo XXX/YYY"
      If (lRet := FtpDownload(::aFilesDownload[1], ::aFilesDownload[1]))
         If ValType(::bDownload) == "B"
            Eval(::bDownload, ::aFilesDownload[1], Self)
         EndIf
         AvCpyFile("\" + ::aFilesDownload[1], ::cDirLocIn + ::aFilesDownload[1], .F., .T.)
         If ::lRemoveFiles
            FtpDeleteFile(::aFilesDownload[1])
         EndIf
         aDel(::aFilesDownload, 1)
         aSize(::aFilesDownload, Len(::aFilesDownload) - 1)
      Else
         ::cError += StrTran(STR0009, "###", ::aFilesDownload[1]) + ENTER//"Erro ao receber o arquivo '###' do diret�rio de sa�da de arquivos no servidor de FTP"
      EndIf
      If lEnd
         Exit
      EndIf
   EndDo
   ::GoToFtpDir("/")

Return lRet

/*
M�todo      : SetFileMode(cMode)
Classe      : ELinkBdMan
Par�metros  : cMode - Modo de exibi��o (Completo/Normal)
Retorno     : Self:cFileMode - Modo atual
Objetivos   : Definir o modo de exibi��o dos arquivos
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     : 
Obs.        :
*/
Method SetFileMode(cMode) Class ELinkBdMan
Default cMode := ""

   If cMode $ "NORMAL/COMPLETE"
      ::ChangeStoreMode(cMode)
      ::cFileMode := cMode
   EndIf

Return ::cFileMode

/*
M�todo      : ChangeStoreMode(cNewMode, cOldMode, aChange)
Classe      : ELinkBdMan
Par�metros  : cNewMode, cOldMode, aChange
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method ChangeStoreMode(cNewMode, cOldMode, aChange) Class ELinkBdMan
Local nInc
Private aTemp
Private aProps
Private oSelf := Self
Private cSelf := ""
Private bSetMode := {|x, y| nInd := x, aTemp := &(cSelf + aProps[nInd]), &(cSelf + aProps[nInd]) := {}, aEval(aTemp, y) },;
        bComp2Norm := {|x| aAdd(&(cSelf + aProps[nInd]), x[1]) },;
        bNorm2Comp := {|x| aAdd(&(cSelf + aProps[nInd]), {x,"","","",""}) }
Private aUpdate
Default cOldMode := ::cFileMode
Default cNewMode := ""

   If ValType(aChange) == "A"
      aUpdate := aChange
      aProps := {"aUpdate"}
   Else
      aProps := {"aFilesFtp", "aFilesLoc", "aFilesDownload", "aFilesUpload"}
      cSelf := "oSelf:"
   EndIf
        
   If cOldMode == "COMPLETE" .And. cNewMode == "NORMAL"
      For nInc := 1 To Len(aProps)
         Eval(bSetMode, nInc, bComp2Norm)
      Next
      
   ElseIf cOldMode == "NORMAL" .And. cNewMode == "COMPLETE"
      For nInc := 1 To Len(aProps)
         Eval(bSetMode, nInc, bNorm2Comp)
      Next
      
   EndIf

Return aUpdate

/*
M�todo      : GoToFtpDir(cDir)
Classe      : ELinkBdMan
Par�metros  : cDir - Diret�rio a ser acessado
Retorno     : lRet
Objetivos   : Altera o diret�rio atual do servidor de FTP
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method GoToFtpDir(cDir) Class ELinkBdMan
Local lRet := .F.
Default cDir := ""
   
   If Len(cDir) <> 0
      lRet := FtpDirChange(cDir)
   EndIf

Return lRet

/*
M�todo      : SetDirFtpIn(cDir)
Classe      : ELinkBdMan
Par�metros  : cDir - Nome do diret�rio
Retorno     : lRet
Objetivos   : Define o diret�rio de entrada de arquivos (enviados pela classe) no servidor de FTP
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetDirFtpIn(cDir) Class ELinkBdMan
Local lRet := .F.

   If ValType(cDir) == "C"
      ::cDirFtpIn := cDir
      lRet := .T.
   EndIf
   
Return lRet

/*
M�todo      : SetDirFtpOut(cDir)
Classe      : ELinkBdMan
Par�metros  : cDir - Nome do diret�rio
Retorno     : lRet
Objetivos   : Alterar o diret�rio de sa�da de arquivos no servidor de FTP
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetDirFtpOut(cDir) Class ELinkBdMan
Local lRet := .F.

   If ValType(cDir) == "C"
      ::cDirFtpOut := cDir
      lRet := .T.
   EndIf

Return lRet

/*
M�todo      : SetDirLocIn(cDir)
Classe      : ELinkBdMan
Par�metros  : cDir - Nome do diret�rio
Retorno     : lRet
Objetivos   : Definir o diret�rio local (no servidor Protheus) de recebimento de arquivos
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetDirLocIn(cDir) Class ELinkBdMan
Local lRet := .F.

   If ValType(cDir) == "C"
      ::cDirLocIn := cDir
      lRet := .T.
   EndIf
   
Return lRet

/*
M�todo      : SetDirLocOut(cDir)
Classe      : ELinkBdMan
Par�metros  : cDir - Nome do diret�rio
Retorno     : lRet
Objetivos   : Definir o diret�rio local (no servidor Protheus) de envio de arquivos
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetDirLocOut(cDir) Class ELinkBdMan
Local lRet := .F.

   If ValType(cDir) == "C"
      ::cDirLocOut := cDir
      lRet := .T.
   EndIf
   
Return lRet

/*
M�todo      : SetServer(cServer)
Classe      : ELinkBdMan
Par�metros  : cServer - Endere�o do servidor
Retorno     : lRet
Objetivos   : Definir o endere�o do servidor (remoto) de FTP que ir� ser acessado
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetServer(cServer) Class ELinkBdMan
Local lRet := .F.

   If ValType(cServer) == "C"
      ::cServer := cServer
      lRet := .T.
   EndIf

Return lRet

/*
M�todo      : SetPort(nPort)
Classe      : ELinkBdMan
Par�metros  : nPort - N�mero da porta
Retorno     : lRet
Objetivos   : Definir a porta de acesso ao servidor (remoto) de FTP
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetPort(nPort) Class ELinkBdMan
Local lRet := .F.

   If ValType(nPort) == "N"
      ::nPort := nPort
      lRet := .T.
   EndIf
   
Return lRet

/*
M�todo      : SetUser(cUser)
Classe      : ELinkBdMan
Par�metros  : cUser - Nome do usu�rio
Retorno     : lRet
Objetivos   : Definir o usu�rio que ser� informado ao efetuar acesso no servidor de FTP
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetUser(cUser) Class ELinkBdMan
Local lRet := .F.

   If ValType(cUser) == "C"
      ::cUser := cUser
      lRet := .T.
   EndIf
   
Return lRet

/*
M�todo      : SetPass(cPass)
Classe      : ELinkBdMan
Par�metros  : cPass - Senha do usu�rio
Retorno     : lRet
Objetivos   : Definir a senha de usu�rio que ser� informada ao efetuar acesso ao servidor de FTP
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetPass(cPass) Class ELinkBdMan
Local lRet := .F.

   If ValType(cPass) == "C"
      ::cPass := cPass
      lRet := .T.
   EndIf
   
Return .T.

/*
M�todo      : GetFtpFileList(cOpc)
Classe      : ELinkBdMan
Par�metros  : cOpc - (DOWNLOAD/UPLOAD) - Define qual diret�rio ser� verificado
Retorno     : Self:aFilesFtp
Objetivos   : Retorna e armazena no atributo aFilesFtp a lista de arquivos de diret�rio de entrada (UPLOAD) ou de sa�da (DONWLOAD) do servidor FTP, conforme
              o tipo de arquivos definido
              Ex: Modo normal - Self:aFilesFtp = {"ARQUIVO1", "ARQUIVO2", ..., "ARQUIVOn"}
                  Modo completo - Self:aFilesFto = {{"ARQUIVO1", "ATRIBUTO", "ATRIBUTO", "ATRIBUTO", "ATRIBUTO"}, ...}
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method GetFtpFileList(cOpc) Class ELinkBdMan
Local cDir
Default cOpc := ""

   If cOpc == "DOWNLOAD"
      cDir := ::cDirFtpOut
   ElseIf cOpc == "UPLOAD"
      cDir := ::cDirFtpIn
   EndIf
   If ::GoToFtpDir(cDir)
      ::aFilesFtp := FtpDirectory("*.*")
      If ::cFileMode <> "COMPLETE"
         ::aFilesFtp := ::ChangeStoreMode(::cFileMode, "COMPLETE", ::aFilesFtp)
      EndIf
      ::GoToFtpDir("/")
   EndIf

Return ::aFilesFtp

/*
M�todo      : GetLocFileList()
Classe      : ELinkBdMan
Par�metros  : cOpc - (DOWNLOAD/UPLOAD) - Define qual diret�rio ser� verificado
Retorno     : Self:aFilesLoc
Objetivos   : Retorna e armazena no atributo aFilesLoc a lista de arquivos de diret�rio de entrada (UPLOAD) ou de sa�da (DONWLOAD) locais, conforme
              o tipo de arquivos definido
              Ex: Modo normal - Self:aFilesLoc = {"ARQUIVO1", "ARQUIVO2", ..., "ARQUIVOn"}
                  Modo completo - Self:aFilesLoc = {{"ARQUIVO1", "ATRIBUTO", "ATRIBUTO", "ATRIBUTO", "ATRIBUTO"}, ...}
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method GetLocFileList(cOpc) Class ELinkBdMan
Local cDir := ""
Default cOpc := ""

   If cOpc == "DOWNLOAD"
      cDir := ::cDirLocIn
   ElseIf cOpc == "UPLOAD"
      cDir := ::cDirLocOut
   EndIf
   ::aFilesLoc := Directory(cDir + "*.*")
   If ::cFileMode <> "COMPLETE"
      ::aFilesLoc := ::ChangeStoreMode(::cFileMode, "COMPLETE", ::aFilesLoc)
   EndIf
   
Return ::aFilesLoc

/*
M�todo      : DownloadList(xFile)
Classe      : ELinkBdMan
Par�metros  : xFile - Nome do arquivo a ser inclu�do na lista, ou array com v�rios arquivos, conforme modo definido
Retorno     : ::aFilesDownload - Lista de arquivos definidos para download (conforme modo de armazenamento)
Objetivos   : Inclui um arquivo (ou uma lista) na lista de arquivos marcados para download
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method DownloadList(xFile) Class ELinkBdMan
Default xFile := ""

Begin Sequence

   If ValType(xFile) == "A"
      If Len(xFile) > 0 .And. ValType(xFile[1]) == "A"
         If Len(xFile[1]) == 5
            xFile[1] := xFile[1][1]
         Else
            Break
         EndIf
      EndIf
      aEval(xFile, {|x| ::DownloadList(x)})
   ElseIf ValType(xFile) == "C" .And. Len(xFile) > 0
      aAdd(::aFilesDownload, xFile)
   EndIf
   
End Sequence

Return ::aFilesDownload

/*
M�todo      : UploadList(xFile)
Classe      : ELinkBdMan
Par�metros  : xFile - Nome do arquivo a ser inclu�do na lista, ou array com v�rios arquivos, conforme modo definido
Retorno     : ::aFilesUpload - Lista de arquivos definidos para upload (conforme modo de armazenamento)
Objetivos   : Inclui um arquivo (ou uma lista) na lista de arquivos marcados para upload
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method UploadList(xFile) Class ELinkBdMan
Default xFile := ""

Begin Sequence

   If ValType(xFile) == "A"
      If Len(xFile) > 0 .And. ValType(xFile[1]) == "A"
         If Len(xFile[1]) == 5
            xFile[1] := xFile[1][1]
         Else
            Break
         EndIf
      EndIf
      aEval(xFile, {|x| ::UploadList(x)})
   ElseIf ValType(xFile) == "C" .And. Len(xFile) > 0
      aAdd(::aFilesUpload, xFile)
   EndIf
   
End Sequence

Return ::aFilesUpload

/*
M�todo      : GetError()
Classe      : ELinkBdMan
Par�metros  : Nenhum
Retorno     : Self:cError - Log de erros
Objetivos   : Retornar o log de erros encontrados na execu��o da inst�ncia da classe
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method GetError() Class ELinkBdMan
Return ::cError
