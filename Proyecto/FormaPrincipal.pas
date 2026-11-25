unit FormaPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg, Vcl.Imaging.pngimage;

type
  TForm1 = class(TForm)
    PanelSuperior: TPanel;
    LblTitulo: TLabel;
    Label1: TLabel;
    PanelContenido: TPanel;
    PanelLogin: TPanel;
    PanelDirectorios: TPanel;
    PanelAlertas: TPanel;
    PanelInfo: TPanel;
    PanelDevices: TPanel;
    PanelAcercaDe: TPanel;
    btnSalir: TButton;
    ImgLogin: TImage;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

end.
