; =================================================================
; PROYECTO FINAL: MARCAHUELLA
; Lenguajes de Interfaz
; Integrantes:
;   - Jose Alfredo Camarena Martinez (Modulo 1: Acceso y Seguridad)
;   - Ricardo Said Ramirez Cortez    (Modulo 2: Alertas y Monitoreo)
; =================================================================

#start=Thermometer.exe#
#start=Traffic_Lights.exe#
#start=Stepper_motor.exe#
#start=Printer.exe#
#start=LED_Display.exe#
; Emulation Kit.exe (abrir en Virtual Devices -> Emulation Kit)

INCLUDE 'BIBLIOTECA.TXT'

.MODEL SMALL
.STACK
.DATA
    ID              DW 0
    bytesLeidos     DW 0
    longEscribir    DW 0
    tempByte        DB 0
    renVisor        DB 0
    colVisor        DB 0
    opcionMenu      DB 0

    ; --- Arbol de directorios y rutas  ---
    dirRaiz         DB 'C:\MARCAHUELLA', 0
    dirAlfredo      DB 'C:\MARCAHUELLA\ALFREDO', 0
    dirSaid         DB 'C:\MARCAHUELLA\SAID', 0

    rutaUsuarios    DB 'C:\MARCAHUELLA\ALFREDO\USUARIOS.TXT', 0
    rutaAccesos     DB 'C:\MARCAHUELLA\ALFREDO\ACCESOS.TXT', 0
    rutaAlertas     DB 'C:\MARCAHUELLA\SAID\ALERTAS.TXT', 0
    rutaReportes    DB 'C:\MARCAHUELLA\SAID\REPORTES.TXT', 0

    ; --- Estado global compartido entre modulos ---
    usuarioActivo   DB 16 DUP(' ')
    longUsuarioAct  DW 0
    loginValido     DB 0
    intentosRest    DB 3
    tempActual      DB 0
    totalAccesos    DW 0
    totalReportes   DW 0

    ; --- Buffers ---
    bufferArchivo   DB 512 DUP(0)
    bufferChico     DB 64 DUP(0)

    ; --- Textos del Menu Principal (48 chars c/u) ---
    titPrincipal    DB '  MARCAHUELLA                                   '
    subPrincipal    DB '  Menu Principal                                '
    opMain1         DB '[1] Modulo 1: Acceso, Usuarios y Seg.           '
    opMain2         DB '[2] Modulo 2: Alertas y Reportes                '
    opMain3         DB '[3] Informacion del Sistema y Rutas             '
    opMain4         DB '[4] Salir                                       '
    msjEligeOp      DB 'Seleccione una opcion [1-4]:                    '

    msjPendMod1     DB 'Modulo 1 (Alfredo) en construccion - Parte 2    '
    msjPendMod2     DB 'Modulo 2 (Said) en construccion - Parte 3       '
    msjMasVisor     DB 'Presiona una tecla para ver mas...              '
    msjErrorVis     DB 'Error al abrir o leer archivo. Presiona tecla.. '
    titSubVisor     DB ' CONTENIDO DEL ARCHIVO:                         '

    ; --- Textos pantalla de Informacion del Sistema (48 chars c/u) ---
    msjInfoCab      DB '  INFORMACION DEL SISTEMA - MARCAHUELLA         '
    msjInfo1        DB 'Raiz:     C:\MARCAHUELLA                        '
    msjInfo2        DB 'Alfredo:  C:\MARCAHUELLA\ALFREDO                '
    msjInfo3        DB '  Files:  USUARIOS.TXT  |  ACCESOS.TXT          '
    msjInfo4        DB '  Hw:     Traffic, Stepper, LEDs, Switches      '
    msjInfo5        DB 'Said:     C:\MARCAHUELLA\SAID                   '
    msjInfo6        DB '  Files:  ALERTAS.TXT   |  REPORTES.TXT         '
    msjInfo7        DB '  Hw:     Thermo, Print(Rep), LED_D(T), LCD,7S,M'
    msjVolver       DB 'Presiona una tecla para regresar...             '
    msjSalidaHw     DB 'Activando: Stepper(Cerrar), Traffic/LEDs(Off)...'

    INCLUDE 'alfredo_datos.asm'
    INCLUDE 'said_datos.asm'

.CODE
INICIO:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    CALL INIT_DIRECTORIOS_BASE
    CALL INIT_ARCHIVOS_ALFREDO
    CALL INIT_ARCHIVOS_SAID

    CALL MODULO_LOGIN
    CMP loginValido, 1
    JNE FIN

CICLO_MENU_PRINCIPAL:
    CALL DIBUJAR_MENU_PRINCIPAL
    CURSOR 15, 45, 0
    RASTREO
    MOV opcionMenu, AL

    CMP opcionMenu, '1'
    JE IR_MODULO_1
    CMP opcionMenu, '2'
    JE IR_MODULO_2
    CMP opcionMenu, '3'
    JE IR_INFO_SISTEMA
    CMP opcionMenu, '4'
    JE FIN
    JMP CICLO_MENU_PRINCIPAL

IR_MODULO_1:
    CALL MENU_ALFREDO
    JMP CICLO_MENU_PRINCIPAL

IR_MODULO_2:
    CALL MENU_SAID
    JMP CICLO_MENU_PRINCIPAL

IR_INFO_SISTEMA:
    CALL PANTALLA_INFO_SISTEMA
    JMP CICLO_MENU_PRINCIPAL

FIN:
    CMP loginValido, 1
    JNE SALIDA_LIMPIA_FIN
    IMPCAD_COLOR msjSalidaHw, 48, 18, 16, 0, 0, 1FH
    CALL TECLA
    CALL CERRAR_CERRADURA_STEPPER
    MOV AX, 0000H               ; Apagar Traffic_Lights
    OUT 4, AX
    MOV DX, 2070H               ; Apagar LEDs Output
    MOV AL, 00H
    OUT DX, AL

SALIDA_LIMPIA_FIN:
    SCROLL_ARRIBA 0, 0, 0, 24, 79, 07H
    CURSOR 0, 0, 0
    MOV AX, 4C00H
    INT 21H

; ======================== ZONA DE PROC ==========================

; Espera una tecla
TECLA PROC
    MOV AH, 0
    INT 16H
    RET
TECLA ENDP

; Limpia toda la pantalla con fondo azul
CLEAN_SCREEN PROC
    MOV AH, 6
    MOV AL, 0
    MOV CH, 0
    MOV CL, 0
    MOV DH, 24
    MOV DL, 79
    MOV BH, 17H
    INT 10H
    RET
CLEAN_SCREEN ENDP

; Crea la carpeta raiz C:\MARCAHUELLA
INIT_DIRECTORIOS_BASE PROC
    CREAR_DIRECTORIO dirRaiz
    RET
INIT_DIRECTORIOS_BASE ENDP

; Pinta interfaz principal
DIBUJAR_MENU_PRINCIPAL PROC
    CALL CLEAN_SCREEN
    ; Barra de titulo superior
    SCROLL_ARRIBA 0, 2, 14, 4, 65, 30H
    ; Panel central gris claro
    SCROLL_ARRIBA 0, 6, 14, 16, 65, 70H
    ; Barra inferior de avisos
    SCROLL_ARRIBA 0, 18, 14, 19, 65, 0EH

    IMPCAD_COLOR titPrincipal, 48,  3, 16, 0, 0, 30H
    IMPCAD_COLOR subPrincipal, 48,  7, 16, 0, 0, 71H
    IMPCAD_COLOR opMain1,      48,  9, 16, 0, 0, 70H
    IMPCAD_COLOR opMain2,      48, 10, 16, 0, 0, 70H
    IMPCAD_COLOR opMain3,      48, 11, 16, 0, 0, 70H
    IMPCAD_COLOR opMain4,      48, 12, 16, 0, 0, 74H
    IMPCAD_COLOR msjEligeOp,   48, 15, 16, 0, 0, 71H
    RET
DIBUJAR_MENU_PRINCIPAL ENDP

; Muestra carpetas, archivos y dispositivos
PANTALLA_INFO_SISTEMA PROC
    CALL CLEAN_SCREEN
    SCROLL_ARRIBA 0,  2, 14,  4, 65, 30H
    SCROLL_ARRIBA 0,  6, 14, 17, 65, 70H
    SCROLL_ARRIBA 0, 19, 14, 20, 65, 0EH

    IMPCAD_COLOR msjInfoCab, 48,  3, 16, 0, 0, 30H
    IMPCAD_COLOR msjInfo1,   48,  7, 16, 0, 0, 71H
    IMPCAD_COLOR msjInfo2,   48,  9, 16, 0, 0, 70H
    IMPCAD_COLOR msjInfo3,   48, 10, 16, 0, 0, 70H
    IMPCAD_COLOR msjInfo4,   48, 11, 16, 0, 0, 70H
    IMPCAD_COLOR msjInfo5,   48, 13, 16, 0, 0, 70H
    IMPCAD_COLOR msjInfo6,   48, 14, 16, 0, 0, 70H
    IMPCAD_COLOR msjInfo7,   48, 15, 16, 0, 0, 70H
    IMPCAD_COLOR msjVolver,  48, 19, 16, 0, 0, 0EH
    CALL TECLA
    RET
PANTALLA_INFO_SISTEMA ENDP

; Lleva puntero al final leyendo bloques
; Requiere archivo previamente abierto con handle en ID
POSICIONAR_FIN_ARCHIVO PROC
CICLO_FIN_ARCH:
    LEER_ARCHIVO 512, bufferArchivo, ID
    JC FIN_POS_ARCH
    CMP AX, 512
    JE CICLO_FIN_ARCH
FIN_POS_ARCH:
    RET
POSICIONAR_FIN_ARCHIVO ENDP

; Imprime archivo dentro del recuadro
; Area util: filas 12..21, columnas 6..73. Requiere handle abierto en ID
MOSTRAR_ARCHIVO_VISOR PROC
    MOV renVisor, 12
    MOV colVisor, 6

SIG_BLOQUE_VISOR:
    LEER_ARCHIVO 512, bufferArchivo, ID
    JC ERROR_VISOR
    MOV bytesLeidos, AX
    CMP bytesLeidos, 0
    JE FIN_VISOR
    MOV SI, 0

SIG_CAR_VISOR:
    CMP SI, bytesLeidos
    JAE SIG_BLOQUE_VISOR
    MOV AL, bufferArchivo[SI]
    MOV tempByte, AL
    INC SI

    CMP tempByte, 0DH
    JE SIG_CAR_VISOR
    CMP tempByte, 0AH
    JE SALTO_LINEA_VISOR

    CMP colVisor, 74
    JB IMPRIMIR_CAR_VISOR
    INC renVisor
    MOV colVisor, 6
    CMP renVisor, 22
    JB IMPRIMIR_CAR_VISOR
    CALL PAUSA_SIG_PAGINA_VISOR

IMPRIMIR_CAR_VISOR:
    CURSOR renVisor, colVisor, 0
    IMP_CARACTER tempByte
    INC colVisor
    JMP SIG_CAR_VISOR

SALTO_LINEA_VISOR:
    INC renVisor
    MOV colVisor, 6
    CMP renVisor, 22
    JB SIG_CAR_VISOR
    CALL PAUSA_SIG_PAGINA_VISOR
    JMP SIG_CAR_VISOR

ERROR_VISOR:
    IMPCAD_COLOR msjErrorVis, 48, 23, 6, 0, 0, 4FH

FIN_VISOR:
    RET
MOSTRAR_ARCHIVO_VISOR ENDP

; Pausa cuando se llena el recuadro y limpia
PAUSA_SIG_PAGINA_VISOR PROC
    IMPCAD_COLOR msjMasVisor, 48, 23, 6, 0, 0, 1FH
    CALL TECLA
    SCROLL_ARRIBA 0, 12, 4, 21, 75, 0EH
    SCROLL_ARRIBA 0, 23, 4, 23, 75, 17H
    MOV renVisor, 12
    MOV colVisor, 6
    RET
PAUSA_SIG_PAGINA_VISOR ENDP

; Dibuja la estructura comun del visor FormaAlertas
DIBUJAR_MARCO_VISOR_COMUN PROC
    CALL CLEAN_SCREEN
    SCROLL_ARRIBA 0,  1,  4,  3, 75, 30H
    SCROLL_ARRIBA 0,  5,  4,  9, 75, 70H
    SCROLL_ARRIBA 0, 10,  4, 22, 75, 0EH

    IMPCAD_COLOR msjVolver,   48,  7, 6, 0, 0, 71H
    IMPCAD_COLOR titSubVisor, 48, 10, 6, 0, 0, 1FH
    RET
DIBUJAR_MARCO_VISOR_COMUN ENDP

INCLUDE 'alfredo_login.asm'
INCLUDE 'alfredo_archivos.asm'
INCLUDE 'alfredo_dispositivos.asm'
INCLUDE 'said_archivos.asm'
INCLUDE 'said_emu_devices.asm'
INCLUDE 'said_emulation_kit.asm'
END INICIO
