; =================================================================
; ALFREDO - LOGIN DUAL DESDE ARCHIVO Y BITACORA DE ACCESOS
; Responsable: Jose Alfredo Camarena Martinez
; =================================================================

; Crea C:\MARCAHUELLA\ALFREDO y sus archivos iniciales solo la primera vez
INIT_ARCHIVOS_ALFREDO PROC
    CREAR_DIRECTORIO dirAlfredo
    JC FIN_INIT_ALFREDO_M1

    CREAR_ARCHIVO rutaUsuarios, 0
    JC VERIF_ACC_INIT_M1
    MOV ID, AX
    ESCRIBIR_ARCHIVO 31, txtUsuariosBase, ID
    CERRAR_ARCHIVO ID

VERIF_ACC_INIT_M1:
    CREAR_ARCHIVO rutaAccesos, 0
    JC FIN_INIT_ALFREDO_M1
    MOV ID, AX
    ESCRIBIR_ARCHIVO 29, txtEncabezadoAcc, ID
    CERRAR_ARCHIVO ID

FIN_INIT_ALFREDO_M1:
    RET
INIT_ARCHIVOS_ALFREDO ENDP

; Login Dual desde USUARIOS.TXT ([1] Clave | [2] Huella Switches 2084h)
MODULO_LOGIN PROC
    MOV intentosRest, 3
    MOV loginValido, 0

CICLO_INTENTO_M1:
    CALL DIBUJAR_PANTALLA_LOGIN
    IMPCAD_COLOR msjDevEsperaM1, 48, 20, 16, 0, 0, 1FH
    CALL TECLA

    MOV AX, 0492H               ; Traffic_Lights amarillo (espera)
    OUT 4, AX
    MOV DX, 2070H
    MOV AL, 00000001B           ; Bit 0: sistema activo
    OUT DX, AL
    CALL MOSTRAR_INTENTOS_7SEG  ; Seven Segment: intentos restantes

    CURSOR 11, 45, 0
    RASTREO
    MOV opcionMenu, AL

    CMP opcionMenu, '1'
    JE LOGIN_MODO_CLAVE
    CMP opcionMenu, '2'
    JE LOGIN_MODO_HUELLA
    CMP opcionMenu, '3'
    JE LOGIN_SALIR_M1
    JMP CICLO_INTENTO_M1

LOGIN_MODO_CLAVE:
    MOV metodoAcceso, 'C'
    CALL DIBUJAR_FORM_CLAVE
    CURSOR 14, 37, 0
    LEER_CADENA entradaUsuario
    CURSOR 16, 37, 0
    LEER_CADENA entradaClave
    CALL VERIFICAR_CLAVE_ARCHIVO
    JMP EVALUAR_LOGIN_M1

LOGIN_MODO_HUELLA:
    MOV metodoAcceso, 'H'
    CALL DIBUJAR_FORM_HUELLA
    IMPCAD_COLOR msjDevHuellaM1, 48, 20, 16, 0, 0, 1FH
    CALL TECLA

    MOV DX, 2084H               ; Leer Switches Input (2084h)
    IN AL, DX
    MOV huellaLeida, AL

    MOV DX, 2070H               ; Reflejar patron de huella en LEDs (2070h)
    OUT DX, AL

    CMP huellaLeida, 1
    JB HUELLA_INVALIDA_M1
    CMP huellaLeida, 99
    JA HUELLA_INVALIDA_M1

    MOV AH, 0
    MOV AL, huellaLeida
    AAM
    ADD AX, 3030H
    MOV huellaAscii[0], AH
    MOV huellaAscii[1], AL

    IMPCAD_COLOR msjHuellaCodM1, 48, 16, 16, 0, 0, 70H
    IMPCAD_COLOR huellaAscii, 2, 16, 44, 0, 0, 71H

    CALL VERIFICAR_HUELLA_ARCHIVO
    JMP EVALUAR_LOGIN_M1

HUELLA_INVALIDA_M1:
    MOV entradaUsuario[1], 0
    MOV loginValido, 0

EVALUAR_LOGIN_M1:
    CMP loginValido, 1
    JE LOGIN_EXITO_M1

    MOV estadoAcceso, 0
    CALL REGISTRAR_ACCESO
    DEC intentosRest

    IMPCAD_COLOR msjDevFalloM1, 48, 20, 16, 0, 0, 4FH
    CALL TECLA

    MOV AX, 0249H               ; Traffic_Lights rojo
    OUT 4, AX
    MOV DX, 2070H
    MOV AL, 00100001B           ; Bit 0 (sistema) + Bit 5 (bloqueo/fallo)
    OUT DX, AL
    CALL MOSTRAR_DOT_MATRIX_ERROR
    CALL MOSTRAR_INTENTOS_7SEG
    MOV idMsgLcd, 1             ; ASCII LCD: acceso denegado
    CALL MOSTRAR_LCD_ESTADO

    CMP intentosRest, 0
    JE LOGIN_BLOQUEO_M1

    IMPCAD_COLOR msjLoginErrM1, 48, 20, 16, 0, 0, 4FH
    CALL TECLA
    JMP CICLO_INTENTO_M1

LOGIN_EXITO_M1:
    CALL GUARDAR_USUARIO_ACTIVO
    MOV estadoAcceso, 1
    CALL REGISTRAR_ACCESO
    INC totalAccesos

    IMPCAD_COLOR msjDevExitoM1, 48, 20, 16, 0, 0, 2FH
    CALL TECLA

    MOV AX, 0924H               ; Traffic_Lights verde
    OUT 4, AX
    MOV DX, 2070H
    CMP metodoAcceso, 'H'
    JE LEDS_HUELLA_OK_M1
    MOV AL, 00001011B           ; Bit 0 (Sis) + Bit 1 (Puerta) + Bit 3 (Clave)
    JMP ENV_LEDS_OK_M1
LEDS_HUELLA_OK_M1:
    MOV AL, 00000111B           ; Bit 0 (Sis) + Bit 1 (Puerta) + Bit 2 (Huella)
ENV_LEDS_OK_M1:
    OUT DX, AL

    CALL MOSTRAR_DOT_MATRIX_OK
    CALL MOSTRAR_LCD_ACCESO_OK
    CALL ABRIR_CERRADURA_STEPPER

    IMPCAD_COLOR msjLoginOkM1, 48, 20, 16, 0, 0, 2FH
    CALL TECLA
    RET

LOGIN_BLOQUEO_M1:
    IMPCAD_COLOR msjDevBloqM1, 48, 20, 16, 0, 0, 4FH
    CALL TECLA
    CALL CERRAR_CERRADURA_STEPPER
    IMPCAD_COLOR msjLoginBloqM1, 48, 20, 16, 0, 0, 4FH
    CALL TECLA
    MOV loginValido, 0
    RET

LOGIN_SALIR_M1:
    MOV loginValido, 0
    RET
MODULO_LOGIN ENDP

DIBUJAR_PANTALLA_LOGIN PROC
    CALL CLEAN_SCREEN
    SCROLL_ARRIBA 0,  2, 14,  4, 65, 30H
    SCROLL_ARRIBA 0,  6, 14, 18, 65, 70H
    SCROLL_ARRIBA 0, 20, 14, 21, 65, 0EH

    IMPCAD_COLOR titLoginM1,    48,  3, 16, 0, 0, 30H
    IMPCAD_COLOR subLoginM1,    48,  7, 16, 0, 0, 71H
    IMPCAD_COLOR opLogin1M1,    48,  8, 16, 0, 0, 70H
    IMPCAD_COLOR opLogin2M1,    48,  9, 16, 0, 0, 70H
    IMPCAD_COLOR opLogin3M1,    48, 10, 16, 0, 0, 74H
    IMPCAD_COLOR msjIntentosM1, 48, 12, 16, 0, 0, 71H

    MOV AL, intentosRest
    ADD AL, '0'
    MOV digitoM1, AL
    IMPCAD_COLOR digitoM1, 1, 12, 36, 0, 0, 74H
    RET
DIBUJAR_PANTALLA_LOGIN ENDP

DIBUJAR_FORM_CLAVE PROC
    SCROLL_ARRIBA 0, 13, 14, 18, 65, 70H
    IMPCAD_COLOR etqUsuarioM1, 20, 14, 16, 0, 0, 70H
    IMPCAD_COLOR barraCampoM1, 14, 14, 37, 0, 0, 0FH
    IMPCAD_COLOR etqClaveM1,   20, 16, 16, 0, 0, 70H
    IMPCAD_COLOR barraCampoM1, 14, 16, 37, 0, 0, 0FH
    RET
DIBUJAR_FORM_CLAVE ENDP

DIBUJAR_FORM_HUELLA PROC
    SCROLL_ARRIBA 0, 13, 14, 18, 65, 70H
    IMPCAD_COLOR msjPonHuellaM1, 48, 14, 16, 0, 0, 71H
    RET
DIBUJAR_FORM_HUELLA ENDP

; Valida entradaUsuario:entradaClave contra USUARIOS.TXT
VERIFICAR_CLAVE_ARCHIVO PROC
    MOV loginValido, 0

    CMP entradaUsuario[1], 0
    JE FIN_VERIF_CLAVE_M1
    CMP entradaClave[1], 0
    JE FIN_VERIF_CLAVE_M1

    ABRIR_ARCHIVO rutaUsuarios, 0
    JC FIN_VERIF_CLAVE_M1
    LEER_ARCHIVO 511, bufferArchivo, ID
    JC ERR_VERIF_CLAVE_M1
    MOV SI, AX
    MOV bufferArchivo[SI], 0
    CERRAR_ARCHIVO ID

    MOV SI, 0

ANALIZAR_CLAVE_M1:
    CMP bufferArchivo[SI], 0
    JE FIN_VERIF_CLAVE_M1
    CMP bufferArchivo[SI], 0DH
    JE SIG_SALTO_CLAVE_M1
    CMP bufferArchivo[SI], 0AH
    JE SIG_SALTO_CLAVE_M1

    MOV CH, 0
    MOV CL, entradaUsuario[1]
    MOV DI, 2
COMP_USR_CLAVE_M1:
    MOV AL, entradaUsuario[DI]
    CMP bufferArchivo[SI], AL
    JNE SALTAR_LIN_CLAVE_M1
    INC SI
    INC DI
    LOOP COMP_USR_CLAVE_M1

    CMP bufferArchivo[SI], ':'
    JNE SALTAR_LIN_CLAVE_M1
    INC SI

    MOV CH, 0
    MOV CL, entradaClave[1]
    MOV DI, 2
COMP_PASS_CLAVE_M1:
    MOV AL, entradaClave[DI]
    CMP bufferArchivo[SI], AL
    JNE SALTAR_LIN_CLAVE_M1
    INC SI
    INC DI
    LOOP COMP_PASS_CLAVE_M1

    CMP bufferArchivo[SI], ':'
    JE CLAVE_OK_M1

SALTAR_LIN_CLAVE_M1:
    CMP bufferArchivo[SI], 0
    JE FIN_VERIF_CLAVE_M1
    CMP bufferArchivo[SI], 0AH
    JE SIG_SALTO_CLAVE_M1
    INC SI
    JMP SALTAR_LIN_CLAVE_M1

SIG_SALTO_CLAVE_M1:
    INC SI
    JMP ANALIZAR_CLAVE_M1

CLAVE_OK_M1:
    MOV loginValido, 1

FIN_VERIF_CLAVE_M1:
    RET

ERR_VERIF_CLAVE_M1:
    CERRAR_ARCHIVO ID
    RET
VERIFICAR_CLAVE_ARCHIVO ENDP

; Busca huellaAscii[0..1] tras el segundo ':' y recupera usuario
VERIFICAR_HUELLA_ARCHIVO PROC
    MOV loginValido, 0

    ABRIR_ARCHIVO rutaUsuarios, 0
    JC FIN_VERIF_HUE_M1
    LEER_ARCHIVO 511, bufferArchivo, ID
    JC ERR_VERIF_HUE_M1
    MOV SI, AX
    MOV bufferArchivo[SI], 0
    CERRAR_ARCHIVO ID

    MOV SI, 0

ANALIZAR_HUE_M1:
    CMP bufferArchivo[SI], 0
    JE FIN_VERIF_HUE_M1
    CMP bufferArchivo[SI], 0DH
    JE SIG_SALTO_HUE_M1
    CMP bufferArchivo[SI], 0AH
    JE SIG_SALTO_HUE_M1

    MOV inicioLineaM1, SI

BUSCAR_COL1_HUE_M1:
    CMP bufferArchivo[SI], 0
    JE FIN_VERIF_HUE_M1
    CMP bufferArchivo[SI], 0AH
    JE SIG_SALTO_HUE_M1
    CMP bufferArchivo[SI], ':'
    JE HALLO_COL1_HUE_M1
    INC SI
    JMP BUSCAR_COL1_HUE_M1

HALLO_COL1_HUE_M1:
    INC SI

BUSCAR_COL2_HUE_M1:
    CMP bufferArchivo[SI], 0
    JE FIN_VERIF_HUE_M1
    CMP bufferArchivo[SI], 0AH
    JE SIG_SALTO_HUE_M1
    CMP bufferArchivo[SI], ':'
    JE HALLO_COL2_HUE_M1
    INC SI
    JMP BUSCAR_COL2_HUE_M1

HALLO_COL2_HUE_M1:
    INC SI
    MOV AL, huellaAscii[0]
    CMP bufferArchivo[SI], AL
    JNE SALTAR_LIN_HUE_M1
    INC SI
    MOV AL, huellaAscii[1]
    CMP bufferArchivo[SI], AL
    JNE SALTAR_LIN_HUE_M1
    INC SI

    CMP bufferArchivo[SI], 0DH
    JE HUELLA_OK_M1
    CMP bufferArchivo[SI], 0AH
    JE HUELLA_OK_M1
    CMP bufferArchivo[SI], 0
    JE HUELLA_OK_M1

SALTAR_LIN_HUE_M1:
    CMP bufferArchivo[SI], 0
    JE FIN_VERIF_HUE_M1
    CMP bufferArchivo[SI], 0AH
    JE SIG_SALTO_HUE_M1
    INC SI
    JMP SALTAR_LIN_HUE_M1

SIG_SALTO_HUE_M1:
    INC SI
    JMP ANALIZAR_HUE_M1

HUELLA_OK_M1:
    MOV SI, inicioLineaM1
    MOV DI, 2
    MOV entradaUsuario[1], 0

COPIAR_USR_HUE_M1:
    MOV AL, bufferArchivo[SI]
    CMP AL, ':'
    JE FIN_COPIA_HUE_M1
    CMP AL, 0
    JE FIN_COPIA_HUE_M1
    CMP entradaUsuario[1], 12
    JAE FIN_COPIA_HUE_M1
    MOV entradaUsuario[DI], AL
    INC SI
    INC DI
    INC entradaUsuario[1]
    JMP COPIAR_USR_HUE_M1

FIN_COPIA_HUE_M1:
    MOV loginValido, 1

FIN_VERIF_HUE_M1:
    RET

ERR_VERIF_HUE_M1:
    CERRAR_ARCHIVO ID
    RET
VERIFICAR_HUELLA_ARCHIVO ENDP

GUARDAR_USUARIO_ACTIVO PROC
    MOV AH, 0
    MOV AL, entradaUsuario[1]
    MOV longUsuarioAct, AX

    MOV CX, 16
    MOV SI, 0
LIMPIAR_ACT_M1:
    MOV usuarioActivo[SI], ' '
    INC SI
    LOOP LIMPIAR_ACT_M1

    CMP longUsuarioAct, 0
    JE FIN_GUARDAR_ACT_M1

    MOV CX, longUsuarioAct
    MOV SI, 0
    MOV DI, 2
COPIAR_ACT_M1:
    MOV AL, entradaUsuario[DI]
    MOV usuarioActivo[SI], AL
    INC SI
    INC DI
    LOOP COPIAR_ACT_M1

FIN_GUARDAR_ACT_M1:
    RET
GUARDAR_USUARIO_ACTIVO ENDP

REGISTRAR_ACCESO PROC
    ABRIR_ARCHIVO rutaAccesos, 2
    JC FIN_REG_ACC_M1
    CALL POSICIONAR_FIN_ARCHIVO

    ESCRIBIR_ARCHIVO 5, prefijoAccUsr, ID

    MOV AH, 0
    MOV AL, entradaUsuario[1]
    MOV longTempM1, AX
    CMP longTempM1, 0
    JE ESC_METODO_ACC_M1
    ESCRIBIR_ARCHIVO longTempM1, entradaUsuario+2, ID

ESC_METODO_ACC_M1:
    CMP metodoAcceso, 'H'
    JE ESC_MET_HUE_M1
    ESCRIBIR_ARCHIVO 13, prefijoAccMetC, ID
    JMP ESC_EST_ACC_M1

ESC_MET_HUE_M1:
    ESCRIBIR_ARCHIVO 13, prefijoAccMetH, ID

ESC_EST_ACC_M1:
    CMP estadoAcceso, 1
    JE ESC_ACC_OK_M1
    ESCRIBIR_ARCHIVO 10, msjLogFail, ID
    JMP CERRAR_REG_ACC_M1

ESC_ACC_OK_M1:
    ESCRIBIR_ARCHIVO 11, msjLogOk, ID

CERRAR_REG_ACC_M1:
    CERRAR_ARCHIVO ID

FIN_REG_ACC_M1:
    RET
REGISTRAR_ACCESO ENDP
