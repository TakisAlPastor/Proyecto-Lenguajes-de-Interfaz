; =================================================================
; MODULO 3: INTERFAZ DEL PERSONAL, LECTURA DE ALERTAS Y SENSORES
; Responsable: Carlos Alejandro Sanchez del Real
; =================================================================

MODULO_PERSONAL PROC
    CALL INIT_ARCHIVOS_CARLOS

CICLO_MENU_M3:
    CALL DIBUJAR_INTERFAZ_M3
    RASTREO                     ; Espera tecla, devuelve ASCII

    CMP AL, '1'
    JE  VER_SUGERENCIAS
    CMP AL, '2'
    JE  VER_ALERTAS
    CMP AL, '3'
    JE  ACCION_ROBOT
    CMP AL, '4'
    JE  ACCION_TERMOMETRO
    CMP AL, '5'
    JE  SALIR_M3
    JMP CICLO_MENU_M3

VER_SUGERENCIAS:
    CALL LIMPIAR_VISOR
    CALL LIMPIAR_BUFFER
    ABRIR_ARCHIVO rutaReportes, 0
    JC  ERR_LECTURA_M3
    LEER_ARCHIVO 240, bufferLectura, ID
    CERRAR_ARCHIVO ID
    CURSOR 13, 6, 0
    IMPCAD_SINCOLOR bufferLectura
    RASTREO
    JMP CICLO_MENU_M3

VER_ALERTAS:
    CALL LIMPIAR_VISOR
    CALL LIMPIAR_BUFFER
    ABRIR_ARCHIVO rutaAlertas, 0
    JC  ERR_LECTURA_M3
    LEER_ARCHIVO 240, bufferLectura, ID
    CERRAR_ARCHIVO ID
    CURSOR 13, 6, 0
    IMPCAD_SINCOLOR bufferLectura
    RASTREO
    JMP CICLO_MENU_M3

ACCION_ROBOT:
    CALL LIMPIAR_VISOR
    CALL EJECUTAR_ROBOT
    ; Registrar el acceso en ALERTAS.TXT
    CREAR_ARCHIVO rutaAlertas, 0
    JC  ERR_LECTURA_M3
    MOV ID, AX
    ESCRIBIR_ARCHIVO 53, txtAleRobot, ID
    CERRAR_ARCHIVO ID
    ; Mostrar confirmacion en el visor
    IMPCAD_COLOR msjRobotOK, 53, 15, 12, 0, 0, 02FH ; Fondo verde, letra blanca
    RASTREO
    JMP CICLO_MENU_M3

ACCION_TERMOMETRO:
    CALL LIMPIAR_VISOR
    IN  AL, 125                 ; Puerto 125 (7Dh): Leer termometro de Emu8086
    CMP AL, 40                  ; Verificar si supera los 40 grados Celsius
    JGE ALERTA_INCENDIO

    ; Temperatura segura (< 40 C)
    MOV AL, 0
    OUT 127, AL                 ; Puerto 127 (7Fh): Apagar calentador por seguridad
    IMPCAD_COLOR msjTempOk, 41, 15, 12, 0, 0, 02FH  ; Fondo verde
    RASTREO
    JMP CICLO_MENU_M3

ALERTA_INCENDIO:
    ; Apagar calentador y guardar incidente en ALERTAS.TXT
    MOV AL, 0
    OUT 127, AL
    CREAR_ARCHIVO rutaAlertas, 0
    JC  ERR_LECTURA_M3
    MOV ID, AX
    ESCRIBIR_ARCHIVO 54, txtAleFuego, ID
    CERRAR_ARCHIVO ID
    ; Mostrar alerta roja parpadeante
    IMPCAD_COLOR msjTempAlta, 47, 15, 12, 0, 0, 04EH ; Fondo rojo, texto amarillo
    RASTREO
    JMP CICLO_MENU_M3

ERR_LECTURA_M3:
    IMPCAD_COLOR msjErrorArch, 46, 15, 12, 0, 0, 04FH
    RASTREO
    JMP CICLO_MENU_M3

SALIR_M3:
    SCROLL_ARRIBA 0, 0, 0, 24, 79, 07H
    CURSOR 0, 0, 0
    RET
MODULO_PERSONAL ENDP

; -----------------------------------------------------------------
; PROCEDIMIENTO: Dibuja la interfaz estilo FormaAlertas
; -----------------------------------------------------------------
DIBUJAR_INTERFAZ_M3 PROC
    ; Fondo general azul oscuro
    SCROLL_ARRIBA 0, 0, 0, 24, 79, 17H
    ; Barra superior cian
    SCROLL_ARRIBA 0, 1, 4, 2, 75, 30H
    ; Panel de opciones gris claro
    SCROLL_ARRIBA 0, 4, 4, 9, 75, 70H
    ; Panel visor de archivos negro con texto amarillo
    SCROLL_ARRIBA 0, 11, 4, 22, 75, 0EH

    ; Textos del menu (CAD, LONG, REN, COL, PAG, MODO, COLOR)
    IMPCAD_COLOR titCabecera, 46, 1, 17, 0, 0, 30H
    IMPCAD_COLOR op1, 44, 4, 8, 0, 0, 70H
    IMPCAD_COLOR op2, 44, 5, 8, 0, 0, 70H
    IMPCAD_COLOR op3, 44, 6, 8, 0, 0, 70H
    IMPCAD_COLOR op4, 44, 7, 8, 0, 0, 70H
    IMPCAD_COLOR op5, 44, 8, 8, 0, 0, 74H
    IMPCAD_COLOR titVisor, 45, 11, 6, 0, 0, 1FH
    RET
DIBUJAR_INTERFAZ_M3 ENDP

; -----------------------------------------------------------------
; PROCEDIMIENTO: Limpia unicamente el recuadro negro de lectura
; -----------------------------------------------------------------
LIMPIAR_VISOR PROC
    SCROLL_ARRIBA 0, 12, 4, 22, 75, 0EH
    RET
LIMPIAR_VISOR ENDP

; -----------------------------------------------------------------
; PROCEDIMIENTO: Rellena bufferLectura con '$' antes de cada lectura
; -----------------------------------------------------------------
LIMPIAR_BUFFER PROC
    MOV CX, 245
    LEA DI, bufferLectura
    MOV AL, '$'
    CLD
    REP STOSB
    RET
LIMPIAR_BUFFER ENDP

; -----------------------------------------------------------------
; PROCEDIMIENTO: Crea C:\BUZON\CARLOS y sus 2 archivos iniciales
; -----------------------------------------------------------------
INIT_ARCHIVOS_CARLOS PROC
    CREAR_DIRECTORIO dirRaiz
    CREAR_DIRECTORIO dirCarlos

    ; Verificar si REP_01.TXT ya existe; si no, crearlo con datos base
    ABRIR_ARCHIVO rutaReportes, 0
    JNC CERRAR_REP_INIT
    CREAR_ARCHIVO rutaReportes, 0
    MOV ID, AX
    ESCRIBIR_ARCHIVO 95, txtRepBase, ID
CERRAR_REP_INIT:
    CERRAR_ARCHIVO ID

    ; Verificar si ALERTAS.TXT ya existe; si no, crearlo con datos base
    ABRIR_ARCHIVO rutaAlertas, 0
    JNC CERRAR_ALE_INIT
    CREAR_ARCHIVO rutaAlertas, 0
    MOV ID, AX
    ESCRIBIR_ARCHIVO 44, txtAleBase, ID
CERRAR_ALE_INIT:
    CERRAR_ARCHIVO ID
    RET
INIT_ARCHIVOS_CARLOS ENDP

; -----------------------------------------------------------------
; PROCEDIMIENTO: Controla el Robot por los puertos 9 (comando) y 11 (estado)
; -----------------------------------------------------------------
EJECUTAR_ROBOT PROC
    CALL ESPERAR_ROBOT
    MOV AL, 1                   ; Comando 1: Avanzar hacia el buzon
    OUT 9, AL

    CALL ESPERAR_ROBOT
    MOV AL, 4                   ; Comando 4: Examinar/Inspeccionar enfrente
    OUT 9, AL

    CALL ESPERAR_ROBOT
    MOV AL, 5                   ; Comando 5: Accionar mecanismo / tomar objeto
    OUT 9, AL

    CALL ESPERAR_ROBOT
    MOV AL, 3                   ; Comando 3: Girar a la derecha para entregar
    OUT 9, AL
    RET
EJECUTAR_ROBOT ENDP

ESPERAR_ROBOT PROC
    IN  AL, 11                  ; Leer registro de estado del robot (Puerto 11)
    TEST AL, 00000010B          ; Bit 1 = 1 indica que el robot sigue ocupado
    JNZ ESPERAR_ROBOT
    RET
ESPERAR_ROBOT ENDP
