INCLUDE BIBLIOTECA.TXT

.MODEL SMALL
.STACK
.DATA
    ; --- Rutas de directorios y los 2 archivos de Carlos ---
    dirRaiz       DB 'C:\BUZON', 0
    dirCarlos     DB 'C:\BUZON\CARLOS', 0
    rutaReportes  DB 'C:\BUZON\CARLOS\REP_01.TXT', 0
    rutaAlertas   DB 'C:\BUZON\CARLOS\ALERTAS.TXT', 0
    ID            DW 0

    ; --- Textos base para inicializar archivos si no existen ---
    txtRepBase    DB 'FOLIO 01: Mejorar iluminacion en sala de lectura.', 0DH, 0AH
                  DB 'FOLIO 02: Agregar mas contactos electricos.', '$'
    txtAleBase    DB 'LOG 01: Sistema de buzon inicializado OK.', 0DH, 0AH, '$'
    txtAleFuego   DB 'ALERTA CRITICA: Temperatura > 40C detectada en buzon!', 0DH, 0AH, '$'
    txtAleRobot   DB 'ACCESO FISICO: Robot abrio compartimento de quejas.', 0DH, 0AH, '$'

    ; --- Buffer de lectura ---
    bufferLectura DB 250 DUP('$')

    ; --- Datos para Impresora y LED Display ---
    mensajeImpresora DB 'REPORTE DE BUZON BIBLIOTECA ALAMEDA', 0DH, 0AH, 0
    msjImpresora     DB 'Datos enviados a la impresora. Presiona una tecla...$'
    numeroDisplay    DW 1234
    msjDisplay       DB 0DH, 0AH, 'Numero enviado al LED Display. Presiona una tecla...$'

    ; --- Textos de la interfaz (FormaAlertas) ---
    titCabecera   DB ' PANEL DE PERSONAL - BUZON BIBLIOTECA ALAMEDA ' ; 46 chars
    op1           DB '[1] Leer Sugerencias Guardadas (REP_01.TXT) '   ; 44 chars
    op2           DB '[2] Leer Bitacora de Alertas (ALERTAS.TXT)  '   ; 44 chars
    op3           DB '[3] Activar Robot (Extraer Sobres del Buzon)'   ; 44 chars
    op4           DB '[4] Escanear Termometro (Sensor Anti-Fuego) '   ; 44 chars
    op5           DB '[5] Salir del Modulo de Personal            '   ; 44 chars
    titVisor      DB ' CONTENIDO DEL ARCHIVO / ESTADO DEL SISTEMA: '  ; 45 chars

    msjRobotOK    DB 'Robot activado: Puerta abierta y sobres recolectados.$'
    msjTempOk     DB 'Temperatura normal (<40 C). Buzon seguro.            $'
    msjTempAlta   DB 'PELIGRO (>40 C)! Alerta guardada en ALERTAS.TXT      $'
    msjErrorArch  DB 'Error al abrir o procesar el archivo en disco.       $'

    ; --- Rutas de directorios y archivos del login ---
    dirAlfredo       DB 'C:\BUZON\ALFREDO', 0
    rutaUsuarios     DB 'C:\BUZON\ALFREDO\USUARIOS.TXT', 0
    rutaAccesos      DB 'C:\BUZON\ALFREDO\ACCESOS.TXT', 0

    txtUsuariosBase   DB 'alfredo:1234', 0DH, 0AH
                      DB 'carlos:5678', 0DH, 0AH
                      DB 'said:abcd', 0DH, 0AH ; 38 chars

    txtEncabezadoAcc  DB '=== BITACORA DE ACCESOS ===', 0DH, 0AH ; 29 chars

    prefijoUsuarioLog DB 'USUARIO: ' ; 9 chars
    msjLogConcedido   DB ' -> ACCESO CONCEDIDO', 0DH, 0AH ; 22 chars
    msjLogDenegado    DB ' -> ACCESO DENEGADO', 0DH, 0AH ; 21 chars

    bufferUsuarios    DB 512 DUP(0)
    entradaUsuario    DB 16, 0, 17 DUP(' ')
    entradaClave      DB 16, 0, 17 DUP(' ')
    longUsuario       DW 0
    intentosRest      DB 3
    digitoIntento     DB '0'
    loginValido       DB 0
    estadoAcceso      DB 0

    titLogin          DB ' ACCESO DE PERSONAL - BUZON BIBLIOTECA         ' ; 47 chars
    subtitLogin       DB ' Ingrese sus credenciales                      ' ; 47 chars
    etqUsuario        DB 'Usuario:    ' ; 12 chars
    etqClave          DB 'Contrasena: ' ; 12 chars
    msjLoginOk        DB 'Acceso concedido. Presiona una tecla para continuar...   ' ; 57 chars
    msjLoginError     DB 'Credenciales invalidas. Intentos restantes:              ' ; 57 chars
    msjLoginBloq      DB 'Acceso denegado: 3 intentos fallidos. Cerrando sistema.  ' ; 57 chars

.CODE
INICIO:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

MAIN:
    CALL MODULO_LOGIN
    CMP loginValido, 1
    JNE FIN
    
    CALL MODULO_PERSONAL  
    CALL MODULO_IMPRESORA
    CALL MODULO_LED_DISPLAY

FIN:
    MOV AX, 4C00H
    INT 21H

INCLUDE modulo1.asm
INCLUDE modulo3.asm
INCLUDE Impresora_Display.asm
END                
