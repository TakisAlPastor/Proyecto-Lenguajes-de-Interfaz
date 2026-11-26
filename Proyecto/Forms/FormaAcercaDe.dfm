object FormAcercaDe: TFormAcercaDe
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Acerca de MarcaHuella'
  ClientHeight = 600
  ClientWidth = 750
  Color = 4335905
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object PanelSuperior: TPanel
    Left = 0
    Top = 0
    Width = 750
    Height = 90
    Align = alTop
    BevelOuter = bvNone
    Color = 4791061
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 718
    object LblTitulo: TLabel
      Left = 24
      Top = 10
      Width = 344
      Height = 45
      Caption = 'Acerca de MarcaHuella'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -32
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object PanelTituloEquipo: TPanel
    Left = 0
    Top = 90
    Width = 750
    Height = 36
    Align = alTop
    BevelOuter = bvNone
    Color = 4335905
    ParentBackground = False
    TabOrder = 1
    ExplicitWidth = 718
    object LblEquipo: TLabel
      Left = 24
      Top = 9
      Width = 158
      Height = 21
      Caption = 'Equipo de desarrollo'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object SbEquipo: TScrollBox
    Left = 0
    Top = 126
    Width = 750
    Height = 418
    VertScrollBar.Tracking = True
    Align = alClient
    BorderStyle = bsNone
    TabOrder = 2
    ExplicitHeight = 412
    object Label1: TLabel
      Left = 24
      Top = 16
      Width = 533
      Height = 300
      Caption = 
        'Ricardo Said Ramirez Cort'#233'z'#13#10'risaramirezco@ittepic.edu.mx'#13#10#13#10#13#10'J' +
        'os'#233' Alfredo Camarena Martinez'#13#10'joalcamarenama@ittepic.edu.mx'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -37
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object PanelFooter: TPanel
    Left = 0
    Top = 544
    Width = 750
    Height = 56
    Align = alBottom
    BevelOuter = bvNone
    Color = 4791061
    ParentBackground = False
    TabOrder = 3
    ExplicitTop = 536
    ExplicitWidth = 718
    object LblInstituto: TLabel
      Left = 24
      Top = 18
      Width = 287
      Height = 15
      Caption = 'Instituto Tecnol'#243'gico de Tepic  -  Lenguajes de Interfaz'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13153450
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object BtnCerrar: TButton
      Left = 586
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
end
