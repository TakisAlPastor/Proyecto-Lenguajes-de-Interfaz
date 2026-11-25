; =================================================================
; ALFREDO - MENU, FORMULARIO ALTA USUARIOS Y VISORES FormaAlertas
; Responsable: Jose Alfredo Camarena Martinez
; =================================================================

MENU_ALFREDO PROC
CICLO_MENU_M1:
    CALL CLEAN_SCREEN
    SCROLL_ARRIBA 0,  2, 14,  4, 65, 30H
    SCROLL_ARRIBA 0,  6, 14, 17, 65, 70H
    SCROLL_ARRIBA 0, 19, 14, 20, 65, 0EH

    IMPCAD_COLOR titMod1M1,  48,  3, 16, 0, 0, 30H
    IMPCAD_COLOR opMod1_1,   48,  8, 16, 0, 0, 70H
    IMPCAD_COLOR opMod1_2,   48,  9, 16, 0, 0, 70H
    IMPCAD_COLOR opMod1_3,   48, 10, 16, 0, 0, 70H
    IMPCAD_COLOR opMod1_4,   48, 11, 16, 0, 0, 70H
    IMPCAD_COLOR opMod1_5,   48, 12, 16, 0, 0, 74H
    IMPCAD_COLOR msjEligeOp, 48, 15, 16, 0, 0, 71H

    CURSOR 15, 45, 0
    RASTREO

    CMP AL, '1'
    JE IR_ALTA_USR_M1
    CMP AL, '2'
    JE IR_VER_ACC_M1
    CMP AL, '3'
    JE IR_VER_USR_M1
    CMP AL, '4'
    JE IR_HW_ALFREDO_M1
    CMP AL, '5'
    JE FIN_MENU_M1
    JMP CICLO_MENU_M1

IR_ALTA_USR_M1:
    CALL FORMULARIO_ALTA_USUARIO
    JMP CICLO_MENU_M1

IR_VER_ACC_M1:
    CALL VER_BITACORA_ACCESOS
    JMP CICLO_MENU_M1

IR_VER_USR_M1:
    CALL VER_USUARIOS_ARCHIVO
    JMP CICLO_MENU_M1

IR_HW_ALFREDO_M1:
    CALL PANEL_DISPOSITIVOS_ALFREDO
    JMP CICLO_MENU_M1

FIN_MENU_M1:
    RET
MENU_ALFREDO ENDP

; Formulario de captura multiple en ciclo [S/N] para USUARIOS.TXT
FORMULARIO_ALTA_USUARIO PROC
CICLO_ALTA_M1:
    CALL CLEAN_SCREEN
    SCROLL_ARRIBA 0,  2, 14,  4, 65, 30H
    SCROLL_ARRIBA 0,  6, 14, 17, 65, 70H
    SCROLL_ARRIBA 0, 19, 14, 20, 65, 0EH

    IMPCAD_COLOR titAltaM1,    48,  3, 16, 0, 0, 30H
    IMPCAD_COLOR etqUsuarioM1, 20,  8, 16, 0, 0, 70H
    IMPCAD_COLOR barraCampoM1, 14,  8, 37, 0, 0, 0FH
    IMPCAD_COLOR etqClaveM1,   20, 10, 16, 0, 0, 70H
    IMPCAD_COLOR barraCampoM1, 14, 10, 37, 0, 0, 0FH
    IMPCAD_COLOR etqHuellaM1,  20, 12, 16, 0, 0, 70H
    IMPCAD_COLOR barraChicaM1,  4, 12, 37, 0, 0, 0FH

    CURSOR 8, 37, 0
    LEER_CADENA entradaUsuario
    CURSOR 10, 37, 0
    LEER_CADENA entradaClave
    CURSOR 12, 37, 0
    LEER_CADENA entradaHuella

    CMP entradaUsuario[1], 0
    JE ALTA_DATO_INV_M1
    CMP entradaClave[1], 0
    JE ALTA_DATO_INV_M1
    CMP entradaHuella[1], 2
    JNE ALTA_DATO_INV_M1

    CMP entradaHuella[2], '0'
    JB ALTA_DATO_INV_M1
    CMP entradaHuella[2], '9'
    JA ALTA_DATO_INV_M1
    CMP entradaHuella[3], '0'
    JB ALTA_DATO_INV_M1
    CMP entradaHuella[3], '9'
    JA ALTA_DATO_INV_M1

    CMP entradaHuella[2], '0'
    JNE GUARDAR_ALTA_M1
    CMP entradaHuella[3], '0'
    JE ALTA_DATO_INV_M1

GUARDAR_ALTA_M1:
    ABRIR_ARCHIVO rutaUsuarios, 2
    JC ALTA_ERR_ARCH_M1
    CALL POSICIONAR_FIN_ARCHIVO

    MOV AH, 0
    MOV AL, entradaUsuario[1]
    MOV longEscribir, AX
    ESCRIBIR_ARCHIVO longEscribir, entradaUsuario+2, ID
    ESCRIBIR_ARCHIVO 1, sepDosPuntos, ID

    MOV AH, 0
    MOV AL, entradaClave[1]
    MOV longEscribir, AX
    ESCRIBIR_ARCHIVO longEscribir, entradaClave+2, ID
    ESCRIBIR_ARCHIVO 1, sepDosPuntos, ID

    ESCRIBIR_ARCHIVO 2, entradaHuella+2, ID
    ESCRIBIR_ARCHIVO 2, saltoLineaM1, ID
    CERRAR_ARCHIVO ID

    IMPCAD_COLOR msjAltaOkM1, 48, 19, 16, 0, 0, 2FH
    JMP PREGUNTAR_OTRO_USR_M1

ALTA_DATO_INV_M1:
    IMPCAD_COLOR msjAltaErrM1, 48, 19, 16, 0, 0, 4FH
    JMP PREGUNTAR_OTRO_USR_M1

ALTA_ERR_ARCH_M1:
    IMPCAD_COLOR msjErrorVis, 48, 19, 16, 0, 0, 4FH

PREGUNTAR_OTRO_USR_M1:
    IMPCAD_COLOR msjOtroUsrM1, 48, 15, 16, 0, 0, 71H
    CURSOR 15, 53, 0
    RASTREO
    CMP AL, 'S'
    JE CICLO_ALTA_M1
    CMP AL, 's'
    JE CICLO_ALTA_M1
    RET
FORMULARIO_ALTA_USUARIO ENDP

; Visor estilo FormaAlertas para ACCESOS.TXT
VER_BITACORA_ACCESOS PROC
    CALL DIBUJAR_MARCO_VISOR_COMUN
    IMPCAD_COLOR titVisorAccM1, 48, 2, 16, 0, 0, 30H

    ABRIR_ARCHIVO rutaAccesos, 0
    JC ERR_VIS_ACC_M1
    CALL MOSTRAR_ARCHIVO_VISOR
    CERRAR_ARCHIVO ID
    JMP ESP_VIS_ACC_M1

ERR_VIS_ACC_M1:
    IMPCAD_COLOR msjErrorVis, 48, 12, 6, 0, 0, 4FH

ESP_VIS_ACC_M1:
    CALL TECLA
    RET
VER_BITACORA_ACCESOS ENDP

; Visor estilo FormaAlertas para USUARIOS.TXT
VER_USUARIOS_ARCHIVO PROC
    CALL DIBUJAR_MARCO_VISOR_COMUN
    IMPCAD_COLOR titVisorUsrM1, 48, 2, 16, 0, 0, 30H

    ABRIR_ARCHIVO rutaUsuarios, 0
    JC ERR_VIS_USR_M1
    CALL MOSTRAR_ARCHIVO_VISOR
    CERRAR_ARCHIVO ID
    JMP ESP_VIS_USR_M1

ERR_VIS_USR_M1:
    IMPCAD_COLOR msjErrorVis, 48, 12, 6, 0, 0, 4FH

ESP_VIS_USR_M1:
    CALL TECLA
    RET
VER_USUARIOS_ARCHIVO ENDP
