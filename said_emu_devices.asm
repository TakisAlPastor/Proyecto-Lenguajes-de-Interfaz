; =================================================================
; SAID - DISPOSITIVOS EMU8086 (Thermometer, Printer, LED_Display)
; Responsable: Ricardo Said Ramirez Cortez
; =================================================================

; Enciende Thermometer (127), lee temp (125), evalua umbral > 40 C
ESCANEAR_TERMOMETRO PROC
    CALL CLEAN_SCREEN
    SCROLL_ARRIBA 0,  2, 14,  4, 65, 30H
    SCROLL_ARRIBA 0,  6, 14, 16, 65, 70H
    SCROLL_ARRIBA 0, 18, 14, 20, 65, 0EH

    IMPCAD_COLOR titTermoM2,     48,  3, 16, 0, 0, 30H
    IMPCAD_COLOR msjDevTermOnM2, 48, 18, 16, 0, 0, 1FH
    CALL TECLA

    ; Encender termometro (puerto 127)
    MOV AL, 1
    MOV DX, 127
    OUT DX, AL

    IMPCAD_COLOR msjTermoOnM2, 48,  8, 16, 0, 0, 71H
    CALL TECLA

    ; Leer temperatura (puerto 125) y apagar sensor
    MOV DX, 125
    XOR AX, AX
    IN AL, DX
    MOV tempActual, AL

    MOV AL, 0
    MOV DX, 127
    OUT DX, AL

    ; Si valor > 127 (negativo en complemento a 2), reportar bajo cero seguro
    CMP tempActual, 127
    JA TEMP_BAJO_CERO_M2

    ; Convertir 0..127 a 3 digitos ASCII usando restas de 100 + AAM
    MOV tempCentenas, '0'
    MOV AL, tempActual
CICLO_CENT_M2:
    CMP AL, 100
    JB FIN_CENT_M2
    SUB AL, 100
    INC tempCentenas
    JMP CICLO_CENT_M2

FIN_CENT_M2:
    AAM
    ADD AX, 3030H
    MOV tempAscii[0], '0'
    CMP tempCentenas, '1'
    JNE GUARDAR_DEC_M2
    MOV tempAscii[0], '1'

GUARDAR_DEC_M2:
    MOV tempAscii[1], AH
    MOV tempAscii[2], AL

    IMPCAD_COLOR msjTermoLecM2, 48, 11, 16, 0, 0, 70H
    IMPCAD_COLOR tempAscii,      3, 11, 45, 0, 0, 71H

    CMP tempActual, 40
    JA TEMP_PELIGRO_M2

    ; Temperatura normal <= 40 C
    IMPCAD_COLOR msjDevTermOkM2, 48, 18, 16, 0, 0, 1FH
    CALL TECLA

    MOV AH, 0
    MOV AL, tempActual
    MOV valorLedDisplay, AX
    CALL ACTUALIZAR_LED_DISPLAY
    CALL MOSTRAR_LCD_TEMP
    MOV AX, 0924H               ; Traffic_Lights verde
    OUT 4, AX
    MOV DX, 2070H
    MOV AL, 00000011B           ; Bit 0 (Sis) + Bit 1 (Puerta)
    OUT DX, AL
    CALL MOSTRAR_DOT_MATRIX_OK
    IMPCAD_COLOR msjTermoOkM2, 48, 19, 16, 0, 0, 2FH
    JMP FIN_TERMO_M2

TEMP_PELIGRO_M2:
    IMPCAD_COLOR msjDevTermAlM2, 48, 18, 16, 0, 0, 4FH
    CALL TECLA

    CALL REGISTRAR_ALERTA_TERMICA
    MOV AH, 0
    MOV AL, tempActual
    MOV valorLedDisplay, AX
    CALL ACTUALIZAR_LED_DISPLAY
    CALL MOSTRAR_LCD_TEMP
    MOV AX, 0249H               ; Traffic_Lights rojo
    OUT 4, AX
    MOV DX, 2070H
    MOV AL, 00010011B           ; Bit 0 (Sis) + Bit 1 (Salida) + Bit 4 (Term)
    OUT DX, AL
    CALL MOSTRAR_DOT_MATRIX_ERROR
    CALL ABRIR_CERRADURA_STEPPER ; Liberar salida de emergencia
    IMPCAD_COLOR msjTermoAleM2, 48, 19, 16, 0, 0, 4FH
    JMP FIN_TERMO_M2

TEMP_BAJO_CERO_M2:
    MOV tempAscii[0], '0'
    MOV tempAscii[1], '0'
    MOV tempAscii[2], '0'
    MOV valorLedDisplay, 0
    CALL ACTUALIZAR_LED_DISPLAY
    CALL MOSTRAR_LCD_TEMP
    CALL MOSTRAR_DOT_MATRIX_OK
    IMPCAD_COLOR msjTermoBajoM2, 48, 19, 16, 0, 0, 2FH

FIN_TERMO_M2:
    CALL TECLA
    RET
ESCANEAR_TERMOMETRO ENDP

; Imprime exclusivamente REPORTES.TXT en Printer (puerto 130)
IMPRIMIR_REPORTES_PRINTER PROC
    IMPCAD_COLOR msjDevPrintM2, 48, 20, 16, 0, 0, 1FH
    CALL TECLA

    ABRIR_ARCHIVO rutaReportes, 0
    JC ERR_PRINT_M2
    CALL ENVIAR_ARCHIVO_A_PRINTER
    CERRAR_ARCHIVO ID
    IMPCAD_COLOR msjPrintOkM2, 48, 20, 16, 0, 0, 2FH
    CALL TECLA
    RET

ERR_PRINT_M2:
    IMPCAD_COLOR msjErrorVis, 48, 20, 16, 0, 0, 4FH
    CALL TECLA
    RET
IMPRIMIR_REPORTES_PRINTER ENDP

; Envia bytes del archivo abierto en ID hacia Printer (puerto 130)
ENVIAR_ARCHIVO_A_PRINTER PROC
SIG_BLOQ_PRT_M2:
    LEER_ARCHIVO 512, bufferArchivo, ID
    JC FIN_PRT_ARCH_M2
    MOV bytesLeidos, AX
    CMP bytesLeidos, 0
    JE SALTO_FINAL_PRT_M2
    MOV SI, 0

SIG_CAR_PRT_M2:
    CMP SI, bytesLeidos
    JAE SIG_BLOQ_PRT_M2
    MOV AL, bufferArchivo[SI]
    OUT 130, AL
    CALL ESPERAR_PRINTER_M2
    INC SI
    JMP SIG_CAR_PRT_M2

SALTO_FINAL_PRT_M2:
    MOV AL, 0DH
    OUT 130, AL
    CALL ESPERAR_PRINTER_M2
    MOV AL, 0AH
    OUT 130, AL
    CALL ESPERAR_PRINTER_M2

FIN_PRT_ARCH_M2:
    RET
ENVIAR_ARCHIVO_A_PRINTER ENDP

ESPERAR_PRINTER_M2 PROC
    MOV esperaM2, 1000
CICLO_ESP_PRT_M2:
    IN AL, 130
    CMP AL, 0
    JE LISTO_PRT_M2
    DEC esperaM2
    JNZ CICLO_ESP_PRT_M2
LISTO_PRT_M2:
    RET
ESPERAR_PRINTER_M2 ENDP

; Envia valorLedDisplay (DW = temperatura) al dispositivo LED_Display (199)
ACTUALIZAR_LED_DISPLAY PROC
    MOV AX, valorLedDisplay
    OUT 199, AX
    RET
ACTUALIZAR_LED_DISPLAY ENDP
