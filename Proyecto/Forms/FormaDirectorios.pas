unit FormaDirectorios;

// Muestra el contenido de BIBLIOTECA.TXT (la biblioteca de macros que
// main.asm incluye con INCLUDE 'BIBLIOTECA.TXT').

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, System.SysUtils,
  System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormDirectorios = class(TForm)
    PanelSuperior: TPanel;
    LblTitulo: TLabel;
    PanelFooter: TPanel;
    LblRuta: TLabel;
    BtnAbrir: TButton;
    BtnCerrar: TButton;
    PanelCuerpo: TPanel;
    MemoBiblioteca: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure BtnAbrirClick(Sender: TObject);
  private
    FRuta: string;
    function BuscarBiblioteca: string;
  public
    { Public declarations }
  end;

var
  FormDirectorios: TFormDirectorios;

implementation

{$R *.dfm}

const
  NOMBRE_ARCHIVO = 'BIBLIOTECA.TXT';

  // ---------------------------------------------------------------
  // EDITA AQUI si tu BIBLIOTECA.TXT esta en otra carpeta.
  // Las rutas relativas parten de la carpeta del .exe (Win32\Debug).
  // Deben terminar en \  (la vacia '' es la carpeta del .exe).
  // ---------------------------------------------------------------
  Carpetas: array[0..5] of string = (
    '..\..\emu\', '..\emu\', 'emu\', '', '..\..\..\emu\',
    'C:\MARCAHUELLA\');

function TFormDirectorios.BuscarBiblioteca: string;
var
  Base: string;
  I: Integer;
begin
  Base := ExtractFilePath(Application.ExeName);
  for I := Low(Carpetas) to High(Carpetas) do
  begin
    if (Length(Carpetas[I]) > 1) and (Carpetas[I][2] = ':') then
      Result := Carpetas[I] + NOMBRE_ARCHIVO          // ruta absoluta
    else
      Result := ExpandFileName(Base + Carpetas[I] + NOMBRE_ARCHIVO);
    if FileExists(Result) then
      Exit;
  end;
  Result := '';
end;

procedure TFormDirectorios.FormCreate(Sender: TObject);
begin
  FRuta := BuscarBiblioteca;
  if FRuta = '' then
  begin
    MemoBiblioteca.Text := 'No se encontró ' + NOMBRE_ARCHIVO + '.' +
      sLineBreak + sLineBreak +
      'Colócalo en la carpeta emu del proyecto, junto a main.asm.';
    LblRuta.Caption := 'Archivo no encontrado';
    BtnAbrir.Enabled := False;
    Exit;
  end;

  LblRuta.Caption := FRuta;
  try
    MemoBiblioteca.Lines.LoadFromFile(FRuta);
  except
    on E: Exception do
    begin
      MemoBiblioteca.Text := 'No se pudo leer ' + NOMBRE_ARCHIVO + '.' +
        sLineBreak + sLineBreak + E.Message;
      BtnAbrir.Enabled := False;
    end;
  end;
end;

procedure TFormDirectorios.BtnAbrirClick(Sender: TObject);
var
  Resultado: HINST;
begin
  Resultado := ShellExecute(Handle, 'open', PChar(FRuta), nil, nil,
    SW_SHOWNORMAL);
  if NativeInt(Resultado) <= 32 then
    MessageDlg('No se pudo abrir ' + NOMBRE_ARCHIVO + '.', mtError,
      [mbOK], 0);
end;

end.
