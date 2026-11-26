unit FormaDevices;

// Muestra los dispositivos virtuales de EMU8086 que usan los .asm y
// cuales estan EN USO. Un dispositivo se considera "en uso" cuando su
// programa (Thermometer.exe, Traffic_Lights.exe, ...) esta corriendo,
// cosa que EMU8086 hace solo al ejecutar main.asm (#start=...).
// El boton de cada tarjeta abre el dispositivo o trae su ventana al frente.

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, Winapi.TlHelp32,
  System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormDevices = class(TForm)
    PanelSuperior: TPanel;
    LblTitulo: TLabel;
    LblSubtitulo: TLabel;
    LblResumen: TLabel;
    SbDispositivos: TScrollBox;
    PanelFooter: TPanel;
    LblNota: TLabel;
    BtnCerrar: TButton;
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    FBarra: array of TPanel;
    FEstado: array of TLabel;
    FBoton: array of TButton;
    procedure CrearTarjeta(Indice: Integer);
    procedure ActualizarEstados;
    procedure BotonClick(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FormDevices: TFormDevices;

implementation

{$R *.dfm}

type
  TDispositivo = record
    Nombre: string;
    Clave: string;      // texto (minusculas) que identifica su proceso
    Archivo: string;    // programa a abrir desde la carpeta de EMU8086
    Puertos: string;
    Funcion: string;
  end;

const
  // ---------------------------------------------------------------
  // EDITA AQUI: carpetas donde EMU8086 guarda los dispositivos
  // (Thermometer.exe, Traffic_Lights.exe, ...). Deben terminar en \
  // ---------------------------------------------------------------
  CarpetasEmu: array[0..2] of string = (
    'C:\emu8086\devices\',
    'C:\emu8086\',
    'C:\Program Files (x86)\emu8086\devices\');

  Dispositivos: array[0..5] of TDispositivo = (
    (Nombre: 'Thermometer';
     Clave: 'thermometer';
     Archivo: 'Thermometer.exe';
     Puertos: 'Puertos 125 (lectura) y 127 (encendido)';
     Funcion: 'Módulo Said · mide la temperatura, alerta si pasa de 40 °C'),
    (Nombre: 'Printer';
     Clave: 'printer.exe';
     Archivo: 'Printer.exe';
     Puertos: 'Puerto 130';
     Funcion: 'Módulo Said · imprime REPORTES.TXT'),
    (Nombre: 'LED Display';
     Clave: 'led_display';
     Archivo: 'LED_Display.exe';
     Puertos: 'Puerto 199';
     Funcion: 'Módulo Said · muestra la temperatura'),
    (Nombre: 'Traffic Lights';
     Clave: 'traffic_lights';
     Archivo: 'Traffic_Lights.exe';
     Puertos: 'Puerto 4';
     Funcion: 'Módulo Alfredo · semáforo de acceso'),
    (Nombre: 'Stepper Motor';
     Clave: 'stepper_motor';
     Archivo: 'Stepper_motor.exe';
     Puertos: 'Puerto 7';
     Funcion: 'Módulo Alfredo · cerradura (abre y cierra la puerta)'),
    (Nombre: 'Emulation Kit';
     Clave: 'emulation';
     Archivo: 'Emulation Kit.exe';
     Puertos: 'LCD 2040h, 7 seg. 2030h, Matriz 2000h, LEDs 2070h, Sw. 2084h';
     Funcion: 'Ambos módulos · LCD, intentos, matriz de puntos y LEDs')
  );

  COLOR_ACTIVO   = $0078DC50;   // verde  (RGB 80,220,120)
  COLOR_INACTIVO = $00B0968C;   // gris azulado (RGB 140,150,176)

// ---------------------------------------------------------------
// Utilidades de procesos
// ---------------------------------------------------------------

// True si hay un proceso cuyo nombre contiene Clave; devuelve su PID.
function ProcesoEnEjecucion(const Clave: string; out Pid: DWORD): Boolean;
var
  Snap: THandle;
  PE: TProcessEntry32;
begin
  Result := False;
  Pid := 0;
  Snap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Snap = INVALID_HANDLE_VALUE then
    Exit;
  try
    PE.dwSize := SizeOf(PE);
    if Process32First(Snap, PE) then
      repeat
        if Pos(Clave, LowerCase(string(PE.szExeFile))) > 0 then
        begin
          Pid := PE.th32ProcessID;
          Exit(True);
        end;
      until not Process32Next(Snap, PE);
  finally
    CloseHandle(Snap);
  end;
end;

type
  TBusquedaVentana = record
    Pid: DWORD;
    Ventana: HWND;
  end;
  PBusquedaVentana = ^TBusquedaVentana;

function EnumVentanasProc(Wnd: HWND; LParam: LPARAM): BOOL; stdcall;
var
  Busqueda: PBusquedaVentana;
  PidVentana: DWORD;
begin
  Result := True;
  Busqueda := PBusquedaVentana(LParam);
  GetWindowThreadProcessId(Wnd, PidVentana);
  if (PidVentana = Busqueda^.Pid) and IsWindowVisible(Wnd) and
     (GetWindow(Wnd, GW_OWNER) = 0) then
  begin
    Busqueda^.Ventana := Wnd;
    Result := False;     // ya la encontramos
  end;
end;

procedure TraerAlFrente(Pid: DWORD);
var
  Busqueda: TBusquedaVentana;
begin
  Busqueda.Pid := Pid;
  Busqueda.Ventana := 0;
  EnumWindows(@EnumVentanasProc, LPARAM(@Busqueda));
  if Busqueda.Ventana <> 0 then
  begin
    ShowWindow(Busqueda.Ventana, SW_RESTORE);
    SetForegroundWindow(Busqueda.Ventana);
  end;
end;

function BuscarProgramaEmu(const Archivo: string): string;
var
  I: Integer;
begin
  for I := Low(CarpetasEmu) to High(CarpetasEmu) do
  begin
    Result := CarpetasEmu[I] + Archivo;
    if FileExists(Result) then
      Exit;
  end;
  Result := '';
end;

// ---------------------------------------------------------------
// Formulario
// ---------------------------------------------------------------

procedure TFormDevices.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  SetLength(FBarra, Length(Dispositivos));
  SetLength(FEstado, Length(Dispositivos));
  SetLength(FBoton, Length(Dispositivos));
  for I := Low(Dispositivos) to High(Dispositivos) do
    CrearTarjeta(I);
  ActualizarEstados;
  Timer.Interval := 1000;
  Timer.Enabled := True;
end;

procedure TFormDevices.CrearTarjeta(Indice: Integer);
var
  Tarjeta: TPanel;
  Etiqueta: TLabel;
begin
  Tarjeta := TPanel.Create(SbDispositivos);
  Tarjeta.Parent := SbDispositivos;
  Tarjeta.Top := Indice * 100;            // conserva el orden de la lista
  Tarjeta.Height := 84;
  Tarjeta.Align := alTop;
  Tarjeta.AlignWithMargins := True;
  Tarjeta.Margins.SetBounds(24, 8, 24, 0);
  Tarjeta.BevelOuter := bvNone;
  Tarjeta.ParentBackground := False;
  Tarjeta.Color := 5061424;
  Tarjeta.Caption := '';
  Tarjeta.ShowCaption := False;

  FBarra[Indice] := TPanel.Create(Tarjeta);
  FBarra[Indice].Parent := Tarjeta;
  FBarra[Indice].Align := alLeft;
  FBarra[Indice].Width := 6;
  FBarra[Indice].BevelOuter := bvNone;
  FBarra[Indice].ParentBackground := False;
  FBarra[Indice].Color := COLOR_INACTIVO;
  FBarra[Indice].Caption := '';
  FBarra[Indice].ShowCaption := False;

  Etiqueta := TLabel.Create(Tarjeta);
  Etiqueta.Parent := Tarjeta;
  Etiqueta.SetBounds(24, 8, 430, 22);
  Etiqueta.Caption := Dispositivos[Indice].Nombre;
  Etiqueta.Font.Name := 'Segoe UI';
  Etiqueta.Font.Height := -17;
  Etiqueta.Font.Style := [fsBold];
  Etiqueta.Font.Color := clWhite;

  Etiqueta := TLabel.Create(Tarjeta);
  Etiqueta.Parent := Tarjeta;
  Etiqueta.SetBounds(24, 34, 430, 18);
  Etiqueta.Caption := Dispositivos[Indice].Puertos;
  Etiqueta.Font.Name := 'Segoe UI';
  Etiqueta.Font.Height := -13;
  Etiqueta.Font.Color := RGB(120, 190, 255);

  Etiqueta := TLabel.Create(Tarjeta);
  Etiqueta.Parent := Tarjeta;
  Etiqueta.SetBounds(24, 56, 430, 18);
  Etiqueta.Caption := Dispositivos[Indice].Funcion;
  Etiqueta.Font.Name := 'Segoe UI';
  Etiqueta.Font.Height := -13;
  Etiqueta.Font.Color := RGB(170, 180, 200);

  FEstado[Indice] := TLabel.Create(Tarjeta);
  FEstado[Indice].Parent := Tarjeta;
  FEstado[Indice].AutoSize := False;
  FEstado[Indice].Alignment := taRightJustify;
  FEstado[Indice].SetBounds(470, 30, 110, 22);
  FEstado[Indice].Font.Name := 'Segoe UI';
  FEstado[Indice].Font.Height := -16;
  FEstado[Indice].Font.Style := [fsBold];

  FBoton[Indice] := TButton.Create(Tarjeta);
  FBoton[Indice].Parent := Tarjeta;
  FBoton[Indice].SetBounds(592, 24, 100, 36);
  FBoton[Indice].Tag := Indice;
  FBoton[Indice].OnClick := BotonClick;
end;

procedure TFormDevices.ActualizarEstados;
var
  I, EnUso: Integer;
  Pid: DWORD;
  Activo: Boolean;
begin
  EnUso := 0;
  for I := Low(Dispositivos) to High(Dispositivos) do
  begin
    Activo := ProcesoEnEjecucion(Dispositivos[I].Clave, Pid);
    if Activo then
    begin
      Inc(EnUso);
      FEstado[I].Caption := '● En uso';
      FEstado[I].Font.Color := COLOR_ACTIVO;
      FBarra[I].Color := COLOR_ACTIVO;
      FBoton[I].Caption := 'Mostrar';
    end
    else
    begin
      FEstado[I].Caption := '○ Inactivo';
      FEstado[I].Font.Color := COLOR_INACTIVO;
      FBarra[I].Color := COLOR_INACTIVO;
      FBoton[I].Caption := 'Abrir';
    end;
  end;
  LblResumen.Caption := Format('%d de %d dispositivos en uso',
    [EnUso, Length(Dispositivos)]);
end;

procedure TFormDevices.TimerTimer(Sender: TObject);
begin
  ActualizarEstados;
end;

procedure TFormDevices.BotonClick(Sender: TObject);
var
  Indice: Integer;
  Pid: DWORD;
  Ruta: string;
  Resultado: HINST;
begin
  Indice := TButton(Sender).Tag;

  // Si ya esta corriendo, solo traemos su ventana al frente
  if ProcesoEnEjecucion(Dispositivos[Indice].Clave, Pid) then
  begin
    TraerAlFrente(Pid);
    Exit;
  end;

  Ruta := BuscarProgramaEmu(Dispositivos[Indice].Archivo);
  if Ruta = '' then
  begin
    MessageDlg('No se encontró "' + Dispositivos[Indice].Archivo +
      '" en las carpetas de EMU8086.' + sLineBreak + sLineBreak +
      'Ábrelo desde EMU8086 (menú Virtual Devices) o ajusta la lista ' +
      'CarpetasEmu en FormaDevices.pas.', mtWarning, [mbOK], 0);
    Exit;
  end;

  Resultado := ShellExecute(Handle, 'open', PChar(Ruta), nil,
    PChar(ExtractFilePath(Ruta)), SW_SHOWNORMAL);
  if NativeInt(Resultado) <= 32 then
    MessageDlg('No se pudo abrir ' + Dispositivos[Indice].Nombre + '.',
      mtError, [mbOK], 0);
end;

end.
