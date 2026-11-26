object FormDevices: TFormDevices
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Devices'
  ClientHeight = 700
  ClientWidth = 760
  Color = 4335905
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object PanelSuperior: TPanel
    Left = 0
    Top = 0
    Width = 760
    Height = 90
    Align = alTop
    BevelOuter = bvNone
    Color = 4791061
    ParentBackground = False
    TabOrder = 0
    object LblTitulo: TLabel
      Left = 24
      Top = 10
      Width = 105
      Height = 45
      Caption = 'Devices'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -32
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LblSubtitulo: TLabel
      Left = 26
      Top = 56
      Width = 200
      Height = 21
      Caption = 'Dispositivos virtuales de EMU8086'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13153450
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object LblResumen: TLabel
      Left = 396
      Top = 34
      Width = 340
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = '0 de 6 dispositivos en uso'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object SbDispositivos: TScrollBox
    Left = 0
    Top = 90
    Width = 760
    Height = 554
    VertScrollBar.Tracking = True
    Align = alClient
    BorderStyle = bsNone
    Color = 4335905
    TabOrder = 1
  end
  object PanelFooter: TPanel
    Left = 0
    Top = 644
    Width = 760
    Height = 56
    Align = alBottom
    BevelOuter = bvNone
    Color = 4791061
    ParentBackground = False
    TabOrder = 2
    object LblNota: TLabel
      Left = 24
      Top = 8
      Width = 580
      Height = 40
      AutoSize = False
      Caption = 
        'Un dispositivo aparece "En uso" cuando su ventana de EMU8086 est' +
        #225' abierta. Se abren solas al ejecutar main.asm.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13153450
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      WordWrap = True
    end
    object BtnCerrar: TButton
      Left = 626
      Top = 10
      Width = 110
      Height = 36
      Cancel = True
      Caption = 'Cerrar'
      Default = True
      ModalResult = 2
      TabOrder = 0
    end
  end
  object Timer: TTimer
    OnTimer = TimerTimer
    Left = 680
    Top = 16
  end
end
