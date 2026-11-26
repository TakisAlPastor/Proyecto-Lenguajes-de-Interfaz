unit FormaAcercaDe;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, System.SysUtils,
  System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormAcercaDe = class(TForm)
    PanelSuperior: TPanel;
    LblTitulo: TLabel;
    PanelTituloEquipo: TPanel;
    LblEquipo: TLabel;
    SbEquipo: TScrollBox;
    PanelFooter: TPanel;
    LblInstituto: TLabel;
    BtnCerrar: TButton;
    Label1: TLabel;

  private

  public
    { Public declarations }
  end;

var
  FormAcercaDe: TFormAcercaDe;

implementation

{$R *.dfm}

type
  TIntegrante = record
    Nombre: string;
    Rol: string;
    Correo: string;
  end;

const
  // ---------------------------------------------------------------
  // EDITA AQUI: nombres, roles y correos institucionales del equipo.
  // Para agregar o quitar integrantes cambia el tamano del arreglo
  // (array[0..N-1]) y la lista de abajo.
  // ---------------------------------------------------------------
  Integrantes: array[0..2] of TIntegrante = (
    (Nombre: 'José Alfredo Camarena Martínez';
     Rol: 'Módulo 1: Acceso y Seguridad';
     Correo: 'CAMBIAR@tepic.tecnm.mx'),
    (Nombre: 'Ricardo Said Ramírez Cortez';
     Rol: 'Módulo 2: Alertas y Monitoreo';
     Correo: 'risaramirezco@ittepic.edu.mx'),
    (Nombre: 'NOMBRE DEL TERCER INTEGRANTE';
     Rol: 'Rol / módulo';
     Correo: 'CAMBIAR@tepic.tecnm.mx')
  );

  // Los videos se buscan como Trailer.* y Entrevista.* dentro de la
  // carpeta "Videos" del proyecto (junto al .exe o hasta 3 niveles arriba).
  NOMBRE_TRAILER    = 'Trailer';
  NOMBRE_ENTREVISTA = 'Entrevista';



end.
