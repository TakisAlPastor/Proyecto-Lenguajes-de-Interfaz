; =================================================================
; MODULO 1: LOGIN DESDE ARCHIVO Y BITACORA DE ACCESOS
; Responsable: Jose Alfredo Camarena Martinez
; =================================================================

MODULO_LOGIN PROC
    CALL INIT_ARCHIVOS_ALFREDO
    MOV intentosRest, 3
    MOV loginValido, 0

CICLO_INTENTO_M1:
    CALL DIBUJAR_PANTALLA_LOGIN

    ; Captura de usuario y clave
    CURSOR 9, 29, 0
    LEER_CADENA entradaUsuario

    CURSOR 12, 29, 0
    LEER_CADENA entradaClave

    CALL VERIFICAR_CREDENCIALES
    CMP loginValido, 1
    JE  LOGIN_EXITOSO_M1

    ; Registrar intento fallido y descontar intentos
    MOV estadoAcceso, 0
    CALL REGISTRAR_ACCESO
    DEC intentosRest
    CMP intentosRest, 0
    JE  LOGIN_BLOQUEADO_M1

    IMPCAD_COLOR msjLoginError, 57, 18, 11, 0, 0, 4FH
    MOV AL, intentosRest
    ADD AL, '0'
    MOV digitoIntento, AL
    IMPCAD_COLOR digitoIntento, 1, 18, 55, 0, 0, 4FH
    RASTREO
    JMP CICLO_INTENTO_M1

LOGIN_EXITOSO_M1:
    MOV estadoAcceso, 1
    CALL REGISTRAR_ACCESO
    IMPCAD_COLOR msjLoginOk, 57, 18, 11, 0, 0, 2FH
    RASTREO
    SCROLL_ARRIBA 0, 0, 0, 24, 79, 07H
    CURSOR 0, 0, 0
    RET

LOGIN_BLOQUEADO_M1:
    IMPCAD_COLOR msjLoginBloq, 57, 18, 11, 0, 0, 4FH
    RASTREO
    SCROLL_ARRIBA 0, 0, 0, 24, 79, 07H
    CURSOR 0, 0, 0
    RET
MODULO_LOGIN ENDP

; -----------------------------------------------------------------
; PROCEDIMIENTO: Dibuja la pantalla de login y sus cuadros de texto
; -----------------------------------------------------------------
DIBUJAR_PANTALLA_LOGIN PROC
    SCROLL_ARRIBA 0, 0, 0, 24, 79, 17H
    SCROLL_ARRIBA 0, 1, 10, 2, 69, 30H
    SCROLL_ARRIBA 0, 5, 10, 15, 69, 70H
    SCROLL_ARRIBA 0, 17, 10, 19, 69, 0EH

    IMPCAD_COLOR titLogin, 47, 1, 16, 0, 0, 30H
    IMPCAD_COLOR subtitLogin, 47, 6, 16, 0, 0, 70H
    IMPCAD_COLOR etqUsuario, 12, 9, 16, 0, 0, 70H
    SCROLL_ARRIBA 0, 9, 29, 9, 46, 0FH
    IMPCAD_COLOR etqClave, 12, 12, 16, 0, 0, 70H
    SCROLL_ARRIBA 0, 12, 29, 12, 46, 0FH
    RET
DIBUJAR_PANTALLA_LOGIN ENDP

; -----------------------------------------------------------------
; PROCEDIMIENTO: Crea C:\BUZON\ALFREDO y sus 2 archivos iniciales
; -----------------------------------------------------------------
INIT_ARCHIVOS_ALFREDO PROC
    CREAR_DIRECTORIO dirRaiz
    CREAR_DIRECTORIO dirAlfredo

    CREAR_ARCHIVO rutaUsuarios, 0
    JC  CREAR_ACC_INIT_M1
    MOV ID, AX
    ESCRIBIR_ARCHIVO 38, txtUsuariosBase, ID
    CERRAR_ARCHIVO ID

CREAR_ACC_INIT_M1:
    CREAR_ARCHIVO rutaAccesos, 0
    JC  FIN_INIT_ALFREDO_M1
    MOV ID, AX
    ESCRIBIR_ARCHIVO 29, txtEncabezadoAcc, ID
    CERRAR_ARCHIVO ID

FIN_INIT_ALFREDO_M1:
    RET
INIT_ARCHIVOS_ALFREDO ENDP

; -----------------------------------------------------------------
; PROCEDIMIENTO: Valida entradaUsuario/entradaClave contra USUARIOS.TXT
; Actualiza loginValido (1 = valido, 0 = invalido)
; -----------------------------------------------------------------
VERIFICAR_CREDENCIALES PROC
    MOV loginValido, 0

    CMP entradaUsuario[1], 0
    JE  FIN_VERIFICAR_M1
    CMP entradaClave[1], 0
    JE  FIN_VERIFICAR_M1

    ABRIR_ARCHIVO rutaUsuarios, 0
    JC  FIN_VERIFICAR_M1
    LEER_ARCHIVO 511, bufferUsuarios, ID
    JC  ERR_LEER_USR_M1
    MOV SI, AX
    MOV bufferUsuarios[SI], 0
    CERRAR_ARCHIVO ID

    MOV SI, 0

ANALIZAR_LINEA_M1:
    CMP bufferUsuarios[SI], 0
    JE  FIN_VERIFICAR_M1
    CMP bufferUsuarios[SI], 0DH
    JE  SALTAR_SALTO_M1
    CMP bufferUsuarios[SI], 0AH
    JE  SALTAR_SALTO_M1

    ; Comparar usuario contra el texto previo a ':'
    MOV CH, 0
    MOV CL, entradaUsuario[1]
    MOV DI, 2
COMP_USUARIO_M1:
    MOV AL, entradaUsuario[DI]
    CMP bufferUsuarios[SI], AL
    JNE SALTAR_LINEA_M1
    INC SI
    INC DI
    LOOP COMP_USUARIO_M1

    CMP bufferUsuarios[SI], ':'
    JNE SALTAR_LINEA_M1
    INC SI

    ; Comparar clave hasta fin de linea o fin de archivo
    MOV CH, 0
    MOV CL, entradaClave[1]
    MOV DI, 2
COMP_CLAVE_M1:
    MOV AL, entradaClave[DI]
    CMP bufferUsuarios[SI], AL
    JNE SALTAR_LINEA_M1
    INC SI
    INC DI
    LOOP COMP_CLAVE_M1

    CMP bufferUsuarios[SI], 0DH
    JE  CREDS_OK_M1
    CMP bufferUsuarios[SI], 0AH
    JE  CREDS_OK_M1
    CMP bufferUsuarios[SI], 0
    JE  CREDS_OK_M1

SALTAR_LINEA_M1:
    CMP bufferUsuarios[SI], 0
    JE  FIN_VERIFICAR_M1
    CMP bufferUsuarios[SI], 0AH
    JE  SALTAR_SALTO_M1
    INC SI
    JMP SALTAR_LINEA_M1

SALTAR_SALTO_M1:
    INC SI
    JMP ANALIZAR_LINEA_M1

CREDS_OK_M1:
    MOV loginValido, 1

FIN_VERIFICAR_M1:
    RET

ERR_LEER_USR_M1:
    CERRAR_ARCHIVO ID
    RET
VERIFICAR_CREDENCIALES ENDP

; -----------------------------------------------------------------
; PROCEDIMIENTO: Agrega intento de login al final de ACCESOS.TXT
; Usa estadoAcceso (1 = concedido, 0 = denegado)
; -----------------------------------------------------------------
REGISTRAR_ACCESO PROC
    ABRIR_ARCHIVO rutaAccesos, 2
    JC  FIN_LOG_M1

    ; Leer hasta el final para dejar el puntero al termino del archivo
LEER_FIN_LOG_M1:
    LEER_ARCHIVO 500, bufferUsuarios, ID
    CMP AX, 500
    JE  LEER_FIN_LOG_M1

    ESCRIBIR_ARCHIVO 9, prefijoUsuarioLog, ID
    MOV AH, 0
    MOV AL, entradaUsuario[1]
    MOV longUsuario, AX
    CMP longUsuario, 0
    JE  ESC_ESTADO_M1
    ESCRIBIR_ARCHIVO longUsuario, entradaUsuario+2, ID

ESC_ESTADO_M1:
    CMP estadoAcceso, 1
    JE  ESC_CONCEDIDO_M1
    ESCRIBIR_ARCHIVO 21, msjLogDenegado, ID
    JMP CERRAR_LOG_M1

ESC_CONCEDIDO_M1:
    ESCRIBIR_ARCHIVO 22, msjLogConcedido, ID

CERRAR_LOG_M1:
    CERRAR_ARCHIVO ID

FIN_LOG_M1:
    RET
REGISTRAR_ACCESO ENDP
