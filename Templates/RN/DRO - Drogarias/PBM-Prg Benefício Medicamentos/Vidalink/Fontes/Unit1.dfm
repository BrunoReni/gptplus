object Form1: TForm1
  Left = 346
  Top = 249
  BorderIcons = []
  Caption = 'Protheus - Vidalink'
  ClientHeight = 283
  ClientWidth = 297
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesktopCenter
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox2: TGroupBox
    Left = 8
    Top = 8
    Width = 289
    Height = 241
    Caption = 'Controle de acesso:'
    TabOrder = 0
    object Label7: TLabel
      Left = 194
      Top = 74
      Width = 23
      Height = 13
      Alignment = taRightJustify
      Caption = 'Filial:'
    end
    object Label1: TLabel
      Left = 33
      Top = 51
      Width = 47
      Height = 13
      Alignment = taRightJustify
      Caption = 'Ambiente:'
    end
    object Label2: TLabel
      Left = 36
      Top = 74
      Width = 44
      Height = 13
      Alignment = taRightJustify
      Caption = 'Empresa:'
    end
    object Label3: TLabel
      Left = 41
      Top = 100
      Width = 39
      Height = 13
      Alignment = taRightJustify
      Caption = 'Usu'#225'rio:'
    end
    object Label4: TLabel
      Left = 46
      Top = 124
      Width = 34
      Height = 13
      Alignment = taRightJustify
      Caption = 'Senha:'
    end
    object Label5: TLabel
      Left = 20
      Top = 148
      Width = 60
      Height = 13
      Alignment = taRightJustify
      Caption = 'Conf. senha:'
    end
    object Label6: TLabel
      Left = 189
      Top = 26
      Width = 28
      Height = 13
      Alignment = taRightJustify
      Caption = 'Porta:'
    end
    object Label8: TLabel
      Left = 38
      Top = 26
      Width = 42
      Height = 13
      Alignment = taRightJustify
      Caption = 'Servidor:'
    end
    object cUser: TEdit
      Left = 88
      Top = 96
      Width = 177
      Height = 21
      MaxLength = 30
      TabOrder = 5
    end
    object cPass: TEdit
      Left = 88
      Top = 120
      Width = 177
      Height = 21
      MaxLength = 30
      PasswordChar = '*'
      TabOrder = 6
    end
    object cConfPass: TEdit
      Left = 88
      Top = 144
      Width = 177
      Height = 21
      MaxLength = 30
      PasswordChar = '*'
      TabOrder = 7
    end
    object cAmbiente: TEdit
      Left = 88
      Top = 47
      Width = 177
      Height = 21
      MaxLength = 30
      TabOrder = 2
    end
    object cEmpresa: TEdit
      Left = 88
      Top = 71
      Width = 49
      Height = 21
      TabOrder = 3
    end
    object cFilial: TEdit
      Left = 224
      Top = 71
      Width = 41
      Height = 21
      TabOrder = 4
    end
    object GroupBox4: TGroupBox
      Left = 16
      Top = 174
      Width = 257
      Height = 52
      Caption = 'DLL API Protheus:'
      TabOrder = 8
      object Label9: TLabel
        Left = 20
        Top = 21
        Width = 44
        Height = 13
        Alignment = taRightJustify
        Caption = 'Caminho:'
      end
      object cArqAPI: TEdit
        Left = 72
        Top = 21
        Width = 177
        Height = 21
        TabOrder = 0
      end
    end
    object cPort: TEdit
      Left = 224
      Top = 23
      Width = 41
      Height = 21
      MaxLength = 4
      TabOrder = 1
      OnKeyPress = cPortKeyPress
    end
    object cServer: TEdit
      Left = 88
      Top = 23
      Width = 89
      Height = 21
      TabOrder = 0
    end
  end
  object Button1: TButton
    Left = 128
    Top = 257
    Width = 81
    Height = 25
    Caption = '&Confirmar'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 216
    Top = 257
    Width = 81
    Height = 25
    Cancel = True
    Caption = 'Ca&ncelar'
    TabOrder = 2
    OnClick = Button2Click
  end
end
