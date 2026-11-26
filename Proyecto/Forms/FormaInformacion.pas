unit FormaInformacion;

// Reproduce el trailer del proyecto dentro de la ventana con TMediaPlayer.
// Busca automáticamente el archivo Trailer (.avi, .wmv, .mpg, .mp4) en la
// carpeta donde se encuentra el ejecutable (.exe).

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.MPlayer, System.IOUtils;

type
  TFormInformacion = class(TForm)
    PanelSuperior: TPanel;
    LblTitulo: TLabel;
    LblSubtitulo: TLabel;
    PanelFooter: TPanel;
    MediaPlayer: TMediaPlayer;
    BtnCerrar: TButton;
    PanelCuerpo: TPanel;
    PanelVideo: TPanel;
    LblEstado: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure MostrarEstado(const Texto: string);
    function BuscarVideoLocal(const NombreBase: string; out CarpetaBuscada: string): string;
  public
    { Public declarations }
  end;

var
  FormInformacion: TFormInformacion;

implementation

{$R *.dfm}

function TFormInformacion.BuscarVideoLocal(const NombreBase: string; out CarpetaBuscada: string): string;
const
  // Extensiones soportadas en orden de prioridad
  Extensiones: array[0..3] of string = ('.avi', '.wmv', '.mpg', '.mp4');
var
  Ext, RutaCompleta: string;
begin
  Result := '';
  // Obtiene automáticamente la ruta exacta donde está tu programa (.exe)
  CarpetaBuscada := ExtractFilePath(ParamStr(0));

  // Si tienes los videos en una subcarpeta (ej. "Videos"), descomenta la siguiente línea:
  // CarpetaBuscada := TPath.Combine(CarpetaBuscada, 'Videos');

  for Ext in Extensiones do
  begin
    RutaCompleta := TPath.Combine(CarpetaBuscada, NombreBase + Ext);
    if FileExists(RutaCompleta) then
    begin
      Result := RutaCompleta;
      Exit;
    end;
  end;
end;

procedure TFormInformacion.FormShow(Sender: TObject);
var
  Ruta, Carpeta: string;
begin
  LblEstado.Visible := False;
  Ruta := BuscarVideoLocal('Trailer', Carpeta);

  if Ruta = '' then
  begin
    MostrarEstado('No se encontró el video del trailer.' + sLineBreak +
      sLineBreak + 'Se buscó en:' + sLineBreak + Carpeta +
      sLineBreak + sLineBreak + 'El archivo debe llamarse Trailer ' +
      '(por ejemplo Trailer.avi).');
    Exit;
  end;

  try
    MediaPlayer.FileName := Ruta;
    MediaPlayer.Open;
    MediaPlayer.Display := PanelVideo;
    MediaPlayer.DisplayRect := PanelVideo.ClientRect;
    MediaPlayer.Play;
  except
    on E: Exception do
      MostrarEstado('No se pudo reproducir el video.' + sLineBreak +
        sLineBreak + E.Message + sLineBreak + sLineBreak +
        'Prueba con el video en formato .avi, .wmv o .mpg.');
  end;
end;

procedure TFormInformacion.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  try
    MediaPlayer.Close;   // detiene el video y libera el archivo
  except
    // si no habia nada abierto, no pasa nada
  end;
end;

procedure TFormInformacion.MostrarEstado(const Texto: string);
begin
  LblEstado.Caption := Texto;
  LblEstado.Visible := True;
end;

end.
