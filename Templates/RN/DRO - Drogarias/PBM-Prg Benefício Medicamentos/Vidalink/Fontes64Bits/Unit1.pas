unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.IniFiles;

type
  TForm1 = class(TForm)
    GroupBox2: TGroupBox;
    cUser: TEdit;
    cPass: TEdit;
    cConfPass: TEdit;
    Button1: TButton;
    Button2: TButton;
    cAmbiente: TEdit;
    cEmpresa: TEdit;
    Label7: TLabel;
    cFilial: TEdit;
    GroupBox4: TGroupBox;
    Label9: TLabel;
    cArqAPI: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    cPort: TEdit;
    Label6: TLabel;
    cServer: TEdit;
    Label8: TLabel;

    procedure Button1Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Button2Click(Sender: TObject);
    procedure cPortKeyPress(Sender: TObject; var Key: Char);
//    procedure OnDestroy(Sender: TObject);
//    procedure FormOnClose(Sender: TObject);
  private
     { Private declarations }
  public
     bConfirmou   : Boolean; //Se clicou no bot�o Confirmar da tela de configura��es
  published
     //destructor Destroy; override;
  end;


var
  Form1: TForm1;

  Procedure Desconectar();
  Procedure HideDLLForm;
  Procedure SetApplicationHandle(Handle: HWnd);
  Procedure GravaIni(Inifile, Secao, Chave, valor: String);
  procedure WriteLog2( Texto:String );

  Function ShowDLLForm() : Boolean;
  Function LeIni(vArquivo, vSecao, vChave, vDefault: String): String;
  Function Criptografa(sString : String; bDescriptografa : Boolean) : String;
  Function LeArquivo(var vServer, vAmbiente, vPorta, vUsuario, vSenha, vEmpresa, vFilial, vArqAPI: String) : Boolean;
  Function RetProdProtheus(sCateg, sKey : AnsiString;
            byTrataPeso, byDeciPeso, byArredonda, byDescr40 : Byte;
             var ptrBuffProd: AnsiString; prtBuffAssoc : AnsiString ): ShortInt; stdcall;
  Function EhNumerico(vTexto : String) : Boolean;
//  Function CarregaDLL(vAPIPath : String) : Boolean;
  Function UGetSystemDirectory(var S: String): Boolean;
  Function Space(nCount: Integer): String;

  { Fun��es externas da APAPI.DLL }
  Function  AP5CreateConnControl(cServer: AnsiString; nPort: integer;
       cEnvironment,cUser,cPassWord: AnsiString): integer; stdcall; external 'APAPI64.DLL';
  Function  AP5DestroyConnControl(ObjectID: integer): boolean; stdcall; external 'APAPI64.DLL';
  Function  AP5Connect(ObjectID: integer): boolean; stdcall; external 'APAPI64.DLL';
  Procedure APSecure(ObjectID: integer; value: boolean); stdcall; external 'APAPI64.DLL';
  Procedure AP5Disconnect(ObjectID: integer); stdcall; external 'APAPI64.DLL';
  Function  AddNumericParam(ObjectID: integer; value: double): boolean; stdcall; external 'APAPI64.DLL';
  Function  AddStringParam(ObjectID: integer; value: Ansistring): boolean; stdcall; external 'APAPI64.DLL';
  Function  ResultAsString( ObjectID: integer; cResult: pAnsichar; nSize: integer): integer; stdcall; external 'APAPI64.DLL';
  Function  CallProc(ObjectID: integer; cFunction: AnsiString): boolean; stdcall; external 'APAPI64.DLL';

exports
  ShowDLLForm,
  HideDLLForm,
  SetApplicationHandle,
  RetProdProtheus,
  Desconectar;

implementation

  Const
    {Arquivos utilizados}
    sArqCFG  = 'PROTVIDA.CFG';
    sArqAPI  = 'APAPI.DLL'; //Implica necessidade de APCONN.DLL.
    sArqINI  = 'SIGALOJA.INI';

  var
    {Fun��es da APAPI.DLL - sem indicar refer�ncia externa - est� ser� dada na fun��o CarregaDLL
    fAP5CreateConnControl  : function (cServer: pchar; nPort: integer; cEnvironment: pchar; cUser: pchar; cPassWord: pchar) : integer; stdcall;
    fAP5DestroyConnControl : function (ObjectID: integer) : boolean; stdcall;
    fAP5Connect            : function (ObjectID: integer) : boolean; stdcall;
    fAPSecure              : procedure(ObjectID: integer; value: boolean); stdcall;
    fAP5Disconnect         : procedure(ObjectID: integer); stdcall;
    fAddNumericParam       : function (ObjectID: integer; value: double) : boolean; stdcall;
    fAddStringParam        : function (ObjectID: integer; value: string) : boolean; stdcall;
    fResultAsString        : function (ObjectID: integer; cResult: pchar; nSize: integer) : integer; stdcall;
    fCallProc              : function (ObjectID: integer; cFunction: pchar) : boolean; stdcall;
    }

//    bOpened      : Boolean;
//    fHandle      : THandle; //'APAPI.DLL'
    blnConectado : Boolean; //Indica se j� est� conectado
    nConect      : Integer; //Numero da conexao
    {$R *.DFM}

{Descarrega o Formul�rio da mem�ria}
Procedure HideDLLForm;
Begin
  FreeAndNil(Form1);
End;

{Fun��o de exibi��o do formul�rio de configura��o
  > True caso o usu�rio Confirmou / False caso o usu�rio Cancelou}
Function ShowDLLForm() : Boolean;
   var
      vServer, vAmbiente, vPorta, vUsuario, vSenha, vEmpresa, vFilial, vArqAPI: String;
Begin
  If Form1 = Nil Then
     Form1 := TForm1.Create(Application);

  {Carrega informa��es do arquivo sArqCFG}
  If LeArquivo(vServer, vAmbiente, vPorta, vUsuario, vSenha, vEmpresa, vFilial, vArqAPI) then
  Begin
     {Repassa valores para os textboxes}
     Form1.cServer.Text := vServer;
     Form1.cPort.Text := vPorta;
     Form1.cAmbiente.Text := vAmbiente;
     Form1.cUser.Text := vUsuario;
     Form1.cPass.Text := vSenha;
     Form1.cConfPass.Text := vSenha;
     Form1.cEmpresa.Text := vEmpresa;
     Form1.cFilial.Text := vFilial;
     Form1.cArqAPI.Text := vArqAPI;
  End
  Else
  Begin
     {Repassa valores vazios para os textboxes}
     Form1.cServer.Text   := '';
     Form1.cPort.Text     := '';
     Form1.cAmbiente.Text := '';
     Form1.cUser.Text     := '';
     Form1.cPass.Text     := '';
     Form1.cConfPass.Text := '';
     Form1.cEmpresa.Text  := '';
     Form1.cFilial.Text   := '';
     Form1.cArqAPI.Text   := '';
  End;

  {Exibe o Formulario}
  Form1.ShowModal;
  Result := Form1.bConfirmou;
End;

Procedure SetApplicationHandle(Handle: HWnd);
Begin
  Application.Handle := Handle;
End;

{Bot�o Confirmar}
Procedure TForm1.Button1Click(Sender: TObject);
Var
    //nPort   : Integer  ;   // Variavel para controle da Porta do RPC
    sPath   : STRING   ;   // Variavel com o caminho da dll
    Arquivo : TextFile ;   // Variavel do Tipo Texto para gravacao do dados do Server.
    cString : STRING   ;   // Variavel para controle da gravacao dos dados do Sever.
    nI      : Integer  ;   // Variavel auxiliar para o For
    cResult : String   ;   // Variavel para gravacao dos dados
    fHando  : integer  ;   // Controle do arquivo CFG

Begin
    //nPort := 0;

    {sPath recebe o diret�rio de sistema (System32)}
    If Not UGetSystemDirectory(sPath) then
    Begin
       //ShowMessage('Imposs�vel definir diret�rio de sistema do sistema operacional');
       MessageDlg('Imposs�vel definir diret�rio de sistema do sistema operacional',mtWarning,[mbOK],0);
       System.Exit;
    End;

    {Verifica se todas as informa��es foram preenchidas}
    If (cServer.Text = '') Or (cPort.Text = '') Or (cAmbiente.Text = '') Or (cEmpresa.Text = '') Or (cFilial.Text = '') Or (cUser.Text = '') Or (cArqAPI.Text = '') Then
    Begin
        //ShowMessage('Preencha todas as informa��es antes de confirmar!' );
        MessageDlg('Preencha todas as informa��es antes de confirmar!',mtWarning,[mbOK],0);
        cServer.SetFocus;
    End
    Else
    Begin
       { Verifica se a senha digitada confere com a confirma��o }
       If cConfPass.Text <> cPass.text Then
       Begin
          //ShowMessage('Confirma��o de senha n�o confere com a senha!' );
          MessageDlg('Confirma��o de senha n�o confere com a senha!',mtWarning,[mbOK],0);
          cPass.SetFocus;
       End
       Else
       Begin
          {Verifica se o arquivo CFG existe, se existir deleta e cria um novo em seguida.}
          If FileExists(sPath + '\' + sArqCFG) = True Then
             DeleteFile(sPath + '\' + sArqCFG) ;

          {Cria arquivo CFG}
          fHando := FileCreate(sPath + '\' + sArqCFG) ;
          FileClose(fHando) ;
          AssignFile(Arquivo, sPath + '\' + sArqCFG);
          Reset(Arquivo);
          Rewrite(Arquivo);
          For nI := 1 To 3 Do
          Begin
              Case nI Of
                 1 : cString := cUser.Text;
                 2 : cString := cPass.Text;
                 3 : cString := cArqAPI.Text;
              End ;
              {Grava informa��es criptografadas no arquivo CFG}
              cResult := Criptografa(cString, False);
              Write(Arquivo, cResult);
              WriteLn(Arquivo);
          End;
          CloseFile(Arquivo);

          {sPath recebe o diretorio onde est� a DLL + SIGALOJA.INI}
          sPath := ExtractFilePath(cArqAPI.Text) + sArqINI;

          {Grava informa��es no SIGALOJA.INI}
          GravaINI(sPath, 'Vidalink', 'Servidor', cServer.Text);
          GravaINI(sPath, 'Vidalink', 'Ambiente', cAmbiente.Text);
          GravaINI(sPath, 'Vidalink', 'Porta', cPort.Text);
          GravaINI(sPath, 'Vidalink', 'Empresa', cEmpresa.Text);
          GravaINI(sPath, 'Vidalink', 'Filial', cFilial.Text);

          {Flag apontando que as informa��es foram alteradas}
          bConfirmou := True;
          Form1.Close;
       End ;
    End ;
end;

{Funcao de retorno do produto}
{Quando OK retorna = 0, quando n�o = 1}
function RetProdProtheus(sCateg, sKey : AnsiString; byTrataPeso, byDeciPeso, byArredonda,
 byDescr40 : Byte; var ptrBuffProd: AnsiString; prtBuffAssoc : AnsiString ): ShortInt; stdcall;
Var cServer    : String;
    cAmbiente  : String;
    cPort      : String;
    cUser      : String;
    cPass      : String;
    cEmpresa   : String;
    cFilial    : String;
    cArqAPI    : String;
    cMensagem  : String;
    nPort      : Integer;
    cResultado : pAnsiChar;
    bytCont    : Byte;
    bCancelou  : Boolean;

Begin
    WriteLog2('Fun��o RetProdProtheus - inicio');

   {Controla se o arquivo de configura��o existe e se o usu�rio cancelou a tela de informa��es do server}
   bCancelou := False;

   {Se n�o obter as informa��es de conex�o, a tela de configura��es ser� aberta}
   While Not LeArquivo(cServer, cAmbiente, cPort, cUser, cPass, cEmpresa, cFilial, cArqAPI) And Not bCancelou Do
   Begin
      bCancelou := Not ShowDLLForm();
   End;

   {Se o usu�rio cancelou a tela de configura��es a rotina � abortada}
   If bCancelou Then
   Begin
      Result := 1;
      System.Exit;
   End;

   nPort := StrToInt(cPort);
   {Cria o controle de conex�o}
   WriteLog2('Antes da Chamada de AP5CreateConnControl ');
   WriteLog2('Parametro 1:' + cServer);
   WriteLog2('Parametro 2:' + IntToStr(nPort));
   WriteLog2('Parametro 3:' + cAmbiente);
   WriteLog2('Parametro 4:' + cUser);
   WriteLog2('Parametro 5: [Reservado]');
   nConect := AP5CreateConnControl(cServer,nPort,cAmbiente,cUser,cPass);
   WriteLog2('Depois da Chamada de AP5CreateConnControl - Retorno [' + IntToStr(nConect) + ']' );

   //Segundo auxilio da TotvsTEC deve-se enviar esse comando
   //depois AP5CreateConnControl e antes AP5Connect para validar
   //a conex�o com o server como segura e permitir a comunica��o
   WriteLog2('Antes da chamada APSecure');
   APSecure( nConect, True );
   WriteLog2('Depois da chamada APSecure');

   {Verifica se � uma conex�o v�lida}
   WriteLog2('Antes da Chamada de AP5Connect ');
   If AP5Connect(nConect) Then
   Begin
        WriteLog2(' AP5Connect - conex�o efetuada com sucesso ');
        {Passagem de par�metros para a fun��o}
        AddStringParam(nConect, '');
        AddStringParam(nConect, cServer);
        AddNumericParam(nConect, nPort);
        AddStringParam(nConect, cAmbiente);
        AddStringParam(nConect, cEmpresa);
        AddStringParam(nConect, cFilial);
        AddStringParam(nConect, sKey);
        WriteLog2(' AP5Connect - Par�metros adicionados ');

        WriteLog2(' AP5Connect - Antes da chamada de CallProc ');
      If CallProc(nConect, 'T_DroVlCall') Then
      Begin
         WriteLog2(' AP5Connect - fun��o CallProc executada com sucesso');
         {Obtem retorno da fun��o}
         cResultado := pAnsiChar(Space(600));
         bytCont := ResultAsString(nConect, cResultado, 600);
         {Preenche variavel de refer�ncia 'ptrBuffProd'}
         ptrBuffProd := System.SysUtils.StrPas(cResultado);
         cResultado := '';
         WriteLog2(' AP5Connect - fun��o CallProc -> Colhendo o resultado da ' +
                                                  ' consulta no BD Protheus');

         WriteLog2(' AP5Connect - fun��o CallProc -> preencheu ' +
                            'a vari�vel interna ptrBuffProd ->' + String(ptrBuffProd));

         {Se o retorno for ok, retorna para a fun��o 0, sen�o 1}
         If ptrBuffProd <> '' then
         Begin
            Result := 0;
            WriteLog2(' AP5Connect - fun��o CallProc -> Result 0');
         End
         Else
         Begin
            Result := 1;
            WriteLog2(' AP5Connect - fun��o CallProc -> Result 1');
         End;
      End
      Else
      Begin
         WriteLog2(' CallProc - Tentativa de chamada sem sucesso ');
         Result := 1;
         cMensagem := 'N�o foi poss�vel estabelecer conex�o com o servidor.' + #13
                + 'Verifique se o servidor est� ativo.' + #13
                + 'Sem comunica��o com o CallProc - T_DroVLCall';
         MessageDlg(cMensagem,mtWarning,[mbOK],0);
         WriteLog2(cMensagem);
      End;

      WriteLog2(' AP5Connect - Antes da chamada de AP5DestroyConnControl ');
      AP5DestroyConnControl(nConect);
      WriteLog2(' AP5Connect - Depois da chamada de AP5DestroyConnControl ');
   End
   Else
   Begin
      WriteLog2(' AP5Connect - Tentativa de chamada sem sucesso ');
      Result := 1;
      cMensagem := 'N�o foi poss�vel estabelecer conex�o com o servidor.' + #13
                + 'Verifique se o servidor est� ativo.' + #13
                + 'Sem comunica��o com o AP5Connect';
      MessageDlg(cMensagem,mtWarning,[mbOK],0);
      WriteLog2(cMensagem);
   End;

   WriteLog2('Fun��o RetProdProtheus - fim');
End;


{---------------------------------------------------------------------------------------}

//   blnConectado := False; //For�a

   {Se ainda n�o estiver conectado com o servidor (1� produto), carrega a conex�o}
//   If Not blnConectado Then
//   Begin
//      {Se n�o coneseguir carregar as fun��es da DLL, significa que o arquivo DLL n�o foi encontrado ou vers�o incompat�vel
//      If Not CarregaDLL(cArqAPI) Then
//      Begin
//         Result := 1;
//         ShowMessage('Arquivo ' + cArqAPI + ' n�o encontrado ou vers�o da DLL incompat�vel.' + #13 + 'Revise as configura��es.');
//         System.Exit;
//      End;
//      }

//      nPort := StrToInt(cPort);

      {Cria o controle de conex�o}
//      nConect := AP5CreateConnControl(pchar(cServer), nPort, pchar(cAmbiente), pChar(cUser), pChar(cPass));

      {Verifica se � uma conex�o v�lida}
//      If AP5Connect(nConect) Then
//      Begin
         {Chamada da fun��o de conex�o do Protheus}
//         AddStringParam(nConect, 'VLRPCConn');

         {Passagem de par�metros para a fun��o}
//         AddStringParam(nConect, cServer);
//         AddNumericParam(nConect, nPort);
//         AddStringParam(nConect, cAmbiente);
//         AddStringParam(nConect, cEmpresa);
 //        AddStringParam(nConect, cFilial);

         {Executa a fun��o de conex�o}
//        If CallProc(nConect, 'VLCall') Then
//         Begin
            {Instancia o Form para for�ar a DLL a executar o Destroy do Form, onde realiza a desconex�o}
            //If Form1 = Nil Then
            //   Form1 := TForm1.Create(application);

            {Indica que est� com a conex�o ativa}
//            blnConectado := True;
//         End;
//      End
//      Else
//      Begin
         {ShowMessage('N�o foi poss�vel estabelecer conex�o com o servidor.' + #13
                   + 'Verifique se o servidor est� ativo.');}
//         MessageDlg('N�o foi poss�vel estabelecer conex�o com o servidor.' + #13
//                   + 'Verifique se o servidor est� ativo.',mtWarning,[mbOK],0);
//      End;
//   End;

//   {Se estiver conectado, busca o produto}
//   If blnConectado Then
//   Begin
//      blnConectado := False;
//      {Chamada da fun��o de busca de produto do Protheus}
//      AddStringParam(nConect, 'VLBuscaPro');

      {Passagem de par�metro}
//      AddStringParam(nConect, strPas(sKey));

      {Se executou com sucesso, processa}
//      If CallProc(nConect, 'VLCall') Then
//      Begin
//         cResultado := pChar(strAlloc(75));

         {Obtem retorno da fun��o}
//         ResultAsString(nConect, cResultado, 75);

         {Preenche variavel de refer�ncia 'ptrBuffProd'}
//         For bytCont := 0 To 74 Do
//         Begin
//            ptrBuffProd[bytCont] := cResultado[bytCont];
//         End;

         {Se o retorno for ok, retorna para a fun��o 0, sen�o 1}
//         if StrPas(ptrBuffProd) <> '' then
//         Begin
//            Result := 0;
//         End
//         Else
//         Begin
//            Result := 1;
//         End;
//      End
//      Else
//      Begin
//         Result := 1 ;
//      End;
//   End
//   Else
//   Begin
//      Result := 1 ;
//   End;
//End;

{ Recupera configura��es para conex�o com o servidor
    > Usu�rio, Senha e Path da DLL ficam no arquivo PROTVIDA.CFG, no diret�rio do sistema (System32)
    > Demais informa��es ficam no SIGALOJA.INI, localizado atravez do caminho da DLL obitido anteriormente }
Function LeArquivo(var vServer, vAmbiente, vPorta, vUsuario, vSenha, vEmpresa, vFilial, vArqAPI: String) : Boolean;
Var Arquivo   : TextFile ;   // Variavel do Tipo Texto para gravacao do dados do Server.
    linha     : string   ;   //
    sPath     : String   ;   // Variavel com o caminho da dll
    nI        : Integer  ;
    cString   : String   ;

Begin
     cString   := '';

     {Se n�o obter o diret�rio de sistema, aborta}
     If Not UGetSystemDirectory(sPath) then
     Begin
        //ShowMessage('Imposs�vel definir diret�rio de sistema do sistema operacional');
        MessageDlg('Imposs�vel definir diret�rio de sistema do sistema operacional',mtWarning,[mbOK],0);
        Result := False;
        System.Exit;
     End;

     {Configura��es do arquivo ProtVida.CFG :: Somente Usu�rio e Senha}
     If FileExists(sPath + '\' + sArqCFG) Then
     Begin
         AssignFile(Arquivo, sPath + '\' + sArqCFG);
         Reset(Arquivo);
         nI := 1;
         While not EOF(Arquivo) do
         Begin
             Readln(Arquivo,linha);
             cString := Criptografa(linha, True);
             Case nI  of
                  1 : vUsuario := cString;
                  2 : vSenha   := cString;
                  3 : vArqAPI  := cString;
             End;
             nI := nI + 1;
         End;
         CloseFile(Arquivo);

         {Configura��es do arquivo SIGALOJA.INI - Configura��es de conex�o}
         sPath := ExtractFilePath(vArqAPI) + sArqINI;
         If FileExists(sPath) Then
         Begin
             vServer   := LeIni(sPath, 'Vidalink', 'Servidor', '');
             vAmbiente := LeIni(sPath, 'Vidalink', 'Ambiente', '');
             vPorta    := LeIni(sPath, 'Vidalink', 'Porta', '');
             vEmpresa  := LeIni(sPath, 'Vidalink', 'Empresa', '');
             vFilial   := LeIni(sPath, 'Vidalink', 'Filial', '');
             Result := True;
         End
         Else
         Begin
             Result := False;
         End;
     End
     Else
     Begin
         Result := False;
     End;
End;

{Fun��o para ativar o enter para a troca de campo no Form}
procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
   If key = #13 then
   Begin
      Key:= #0;
      Perform(Wm_NextDlgCtl,0,0);
   end;
end;

{Botao Cancelar}
procedure TForm1.Button2Click(Sender: TObject);
begin
  bConfirmou := False;
  form1.Close
end;

{
14/01/2010 - Rodrigo - CRM Sustenta��o
[ Fun��o de Criptografia e Descriptografia ]
*** sString         : Texto que deseja Criptografar/Descriptografar
*** bDescriptografa : [False = Criptografa / True = Descriptografa]
}
Function Criptografa(sString : String; bDescriptografa : Boolean) : String ;
Const
    bAlternancia  = 128; // Quantidade para alternar para mais ou para menos o c�digo ASCII (EX: [66-'A'] + [128] = [194-'�']).
    bAlternancia2 = 5;   // Quantidade para alternar o caracter por uma segunda vez, para mais ou para menos, mas dentro de uma condi��o, conforme a bAltMOD.
    bAltMOD       = 3;   // Valor definido para ocorrer uma segunda alternancia. Dentro do la�o, a cada X caracteres, fa�a uma segunda alternancia.

Var
    bAltChar      : Byte;   // Novo caractere que ser� atribuido.
    bContChar     : Byte;   // Contador.
    sTexto        : String; // Texto de retorno da fun��o.

Begin
    For bContChar := 1 To Length(sString) Do
    Begin
        If bDescriptografa Then
        Begin
            bAltChar := Byte(sSTring[bContChar]) + bAlternancia;
            If bContChar Mod bAltMOD = 0 Then
                bAltChar := bAltChar - bAlternancia2;
        End
        Else
        Begin
            bAltChar := Byte(sSTring[bContChar]) - bAlternancia;
            If bContChar Mod bAltMOD = 0 Then
                bAltChar := bAltChar + bAlternancia2;
        End;

        sTexto := sTexto + char(bAltChar);
    End;

    Result:= sTexto ;
End ;

{L� valores de um arquivo INI}
Function LeIni(vArquivo, vSecao, vChave, vDefault: String): String;
var
   ArqIni: TIniFile;
   cTexto: String;
begin
   ArqIni := TIniFile.Create(vArquivo);
   try
      cTexto := ArqIni.ReadString(vSecao, vChave, vDefault);
   finally
      ArqIni.Free;
   end;
   Result := cTexto;
end;

{Grava valores dentro de um arquivo INI}
procedure GravaIni(Inifile, Secao, Chave, valor: String);
var
   Ini: TIniFile;
begin
   Ini := TInifile.Create(Inifile);
   try
      Ini.WriteString(Secao, chave, valor);
   finally
      Ini.Free;
   end;
end;

{Verifica se o texto cont�m somente n�meros}
function EhNumerico(vTexto : String) : Boolean;
Var
   i : Integer;
   Ret : Boolean;
Begin
   Ret := True;

   For i := 1 To Length(vTexto) Do
   Begin
      if (Byte(vTexto[i]) < Byte('0')) Or (Byte(vTexto[i]) > Byte('9')) Then
      Begin
          Ret := False;
      End;
   End;

   Result := Ret;
End;

Function Space(nCount: Integer): String;
var
  nX : Integer;
begin
for nX := 0 to Pred(nCount) do
  Result := Result + ' ';
end;

{Atribui��o de fun��es da DLL para as vari�veis do tipo 'Function'}
{Function CarregaDLL(vAPIPath:String) : Boolean;
  function ValidPointer(aPointer: Pointer; sMSg:String) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      MessageDlg('A fun��o "' + sMsg + '" n�o existe na Dll: ' + vAPIPath +#13+
                  '(Atualize as DLLs)',mtWarning,[mbOK],0);
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  bRet : Boolean;
  pTempPath  : PChar;
  sTempPath  : String;
  BufferTemp : Array[0..144] of Char;
  cFlag : String;

  begin
  cFlag  := '1';
  Result := False;
  If Not bOpened Then
  Begin
    fHandle  := LoadLibrary(pChar(vAPIPath));

    If (fHandle = 0) Then
    Begin
        GetTempPath(144, BufferTemp);
        sTempPath := trim(StrPas(BufferTemp)) + sArqAPI;
        pTempPath := PChar(sTempPath);
        fHandle   := LoadLibrary(pTempPath);
    End;

    if (fHandle <> 0) Then
    begin
      bRet := True;

      aFunc := GetProcAddress(fHandle,'AP5CreateConnControl');
      if ValidPointer( aFunc, 'AP5CreateConnControl') then
        fAP5CreateConnControl := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'AP5DestroyConnControl');
      if ValidPointer( aFunc, 'AP5DestroyConnControl') then
        fAP5DestroyConnControl := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'AP5Connect');
      if ValidPointer( aFunc, 'AP5Connect') then
        fAP5Connect := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'APSecure');
      if ValidPointer( aFunc, 'APSecure') then
        fAPSecure := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'AP5Disconnect');
      if ValidPointer( aFunc, 'AP5Disconnect') then
        fAP5Disconnect := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'AddNumericParam');
      if ValidPointer( aFunc, 'AddNumericParam') then
        fAddNumericParam := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'AddStringParam');
      if ValidPointer( aFunc, 'AddStringParam') then
        fAddStringParam := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'ResultAsString');
      if ValidPointer( aFunc, 'ResultAsString') then
        fResultAsString := aFunc
      else
        bRet := False;

      aFunc := GetProcAddress(fHandle,'CallProc');
      if ValidPointer(aFunc, 'CallProc') then
        fCallProc := aFunc
      else
        bRet := False;

    end
    else
    begin
      bRet := False;
    end;

    Result := bRet;
  End;
End;
}


{Repassa para S o diret�rio de sistema - retorna true se ok, ou false se n�o tiver sucesso}
function UGetSystemDirectory(var S: String): Boolean;
var
  Len: Integer;
begin
  Len := GetSystemDirectory(nil, 0);
  if Len > 0 then
  begin
    SetLength(S, Len);
    Len := GetSystemDirectory(PChar(S), Len);
    SetLength(S, Len);
    Result := Len > 0;
  end else
    Result := False;
end;

{Fecha a conex�o}
Procedure Desconectar();
Begin
   AddStringParam(nConect, 'VLRPCDesc');
   CallProc(nConect, 'VLCall');

   {
   carregadll('c:\mp10\BIN\smartclient\apapi.dll');
   fCallProc(nConect, 'TesteMensagem');
   fCallProc(nConect, 'TesteMensagem');
   fCallProc(nConect, 'TesteMensagem');
   fCallProc(nConect, 'TesteMensagem');
   fCallProc(nConect, 'TesteMensagem');
   fCallProc(nConect, 'TesteMensagem');
   }

   blnConectado := False;
End;

{Somente N�meros na text cPort}
procedure TForm1.cPortKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8, #9]) then
    Key := #0;
end;

{
Procedure TForm1.OnDestroy(Sender: TObject);
begin
   Desconectar;
   inherited Destroy;
end;
}

procedure WriteLog2(Texto:String );
const
  Arquivo = 'TotvsVida64.Log';
var
  Lista : TStringList;
  cDataHora : String;
begin
  cDataHora := DateTimeToStr(Now) + '  ';
  Lista := TStringList.Create();
  Lista.Clear;

  if FileExists(Arquivo) = False
  then Lista.SaveToFile(Arquivo);

  Lista.LoadFromFile(Arquivo);
  Lista.Add( cDataHora + Texto);
  Lista.SaveToFile(Arquivo);
end;

End.

